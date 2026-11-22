import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monvexa/config/remote_config_service.dart';
import 'package:monvexa/services/pref_service.dart';
import 'package:monvexa/widgets/ads/ad_loading_dialog.dart';

class AdService extends GetxService {
  static AdService get to => Get.find<AdService>();

  final RemoteConfigService remoteConfig = Get.find<RemoteConfigService>();

  int _actionClickCounter = 0;
  Timer? _homeTickerTimer;
  int _timerElapsedSeconds = 0;

  /// Concurrency Guard: ensures only ONE full-screen ad shows at any given moment
  bool isFullScreenAdShowing = false;

  /// Bottom Banner State Tracker
  final RxBool isBannerShowing = false.obs;

  void updateBannerState(bool isShowing) {
    if (isBannerShowing.value != isShowing) {
      isBannerShowing.value = isShowing;
    }
  }

  bool get _isFirstUser => !PrefService.to.isOnboardingDone;

  bool get shouldShowAds {
    final cfg = remoteConfig.adsConfig.value;
    if (cfg == null || !cfg.showAds) return false;

    if (_isFirstUser) {
      return cfg.showAdsToFirstUser;
    } else {
      return cfg.showAdsToReturningUser;
    }
  }

  @override
  void onInit() {
    super.onInit();
    MobileAds.instance.initialize();
  }

  // ── HOME TAB TIMER LIFECYCLE ──────────────────────────────────────
  /// Starts 1-second ticker strictly on Home Tab
  void startHomeTimer() {
    stopHomeTimer();

    final cfg = remoteConfig.adsConfig.value;
    if (cfg == null || !shouldShowAds || !cfg.isTimerEnabled) {
      return;
    }

    _timerElapsedSeconds = 0;
    _homeTickerTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      if (isFullScreenAdShowing) {
        _timerElapsedSeconds = 0;
        return;
      }

      _timerElapsedSeconds++;
      if (_timerElapsedSeconds >= cfg.timerCount) {
        _timerElapsedSeconds = 0;
        _triggerTimerInterstitial();
      }
    });
    debugPrint('[AdService] Home timer started with threshold: ${cfg.timerCount}s');
  }

  void stopHomeTimer() {
    _homeTickerTimer?.cancel();
    _homeTickerTimer = null;
    _timerElapsedSeconds = 0;
  }

  void resetHomeTimer() {
    _timerElapsedSeconds = 0;
  }

  // ── 1. WATERFALL AD UNIT LOADER ───────────────────────────────────
  Future<T?> loadWithWaterfall<T>({
    required List<String> adUnits,
    required Future<T?> Function(String adUnitId) loadFunc,
  }) async {
    for (final unit in adUnits) {
      try {
        final ad = await loadFunc(unit);
        if (ad != null) {
          debugPrint('[AdService] Successfully loaded ad unit: $unit');
          return ad;
        }
      } catch (e) {
        debugPrint('[AdService] Ad unit failed: $unit, error: $e');
      }
    }
    return null;
  }

  // ── 2. ON-DEMAND INTERSTITIAL LOADER ──────────────────────────────
  Future<InterstitialAd?> loadInterstitial(String unitId, {int timeoutSeconds = 10}) async {
    final completer = Completer<InterstitialAd?>();

    InterstitialAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) {
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (err) {
          debugPrint('[AdService] Interstitial failed to load: ${err.message}');
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        debugPrint('[AdService] Interstitial timeout after $timeoutSeconds s');
        return null;
      },
    );
  }

  // ── 3. ON-DEMAND APP OPEN AD LOADER ───────────────────────────────
  Future<AppOpenAd?> loadAppOpen(String unitId, {int timeoutSeconds = 15}) async {
    final completer = Completer<AppOpenAd?>();

    AppOpenAd.load(
      adUnitId: unitId,
      request: const AdRequest(),
      adLoadCallback: AppOpenAdLoadCallback(
        onAdLoaded: (ad) {
          if (!completer.isCompleted) completer.complete(ad);
        },
        onAdFailedToLoad: (err) {
          debugPrint('[AdService] AppOpen failed to load: ${err.message}');
          if (!completer.isCompleted) completer.complete(null);
        },
      ),
    );

    return completer.future.timeout(
      Duration(seconds: timeoutSeconds),
      onTimeout: () {
        debugPrint('[AdService] AppOpen timeout after $timeoutSeconds s');
        return null;
      },
    );
  }

  // ── 4. SEQUENTIAL SPLASH WATERFALL FLOW WITH FAST SKIP ─────────────
  String _mapSplashTypeToPlacement(String type) {
    switch (type.toLowerCase()) {
      case 'native':
        return 'splash_native';
      case 'app_open':
        return 'splash_app_open';
      case 'interstitial':
      default:
        return 'splash_interstitial';
    }
  }

  Future<void> runSplashAdFlow({
    required Function(NativeAd? fallbackNative) onComplete,
  }) async {
    if (!shouldShowAds) {
      onComplete(null);
      return;
    }

    final cfg = remoteConfig.adsConfig.value;
    if (cfg == null) {
      onComplete(null);
      return;
    }

    final flow = cfg.adsConfig.splashFlow;
    final adsData = cfg.adsData;
    final placements = cfg.adsConfig.placements;

    for (final stepType in flow) {
      final placementKey = _mapSplashTypeToPlacement(stepType);
      final placement = placements[placementKey];

      // FAST SKIP: If disabled, skip immediately in 0ms!
      if (placement == null || !placement.enabled) {
        debugPrint('[SplashFlow] Fast-skipping disabled placement: $placementKey ($stepType)');
        continue;
      }

      final timeout = placement.timeout;
      debugPrint('[SplashFlow] Requesting step: $stepType (timeout: ${timeout}s)');

      if (stepType == 'interstitial') {
        final ad = await loadWithWaterfall<InterstitialAd>(
          adUnits: adsData.splashInterstitialList,
          loadFunc: (u) => loadInterstitial(u, timeoutSeconds: timeout),
        );

        if (ad != null) {
          if (isFullScreenAdShowing) {
            ad.dispose();
            onComplete(null);
            return;
          }

          isFullScreenAdShowing = true;
          resetHomeTimer();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isFullScreenAdShowing = false;
              resetHomeTimer();
              onComplete(null);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              isFullScreenAdShowing = false;
              onComplete(null);
            },
          );
          ad.show();
          return;
        }
      } else if (stepType == 'app_open') {
        final ad = await loadWithWaterfall<AppOpenAd>(
          adUnits: adsData.splashAppOpenList,
          loadFunc: (u) => loadAppOpen(u, timeoutSeconds: timeout),
        );

        if (ad != null) {
          if (isFullScreenAdShowing) {
            ad.dispose();
            onComplete(null);
            return;
          }

          isFullScreenAdShowing = true;
          resetHomeTimer();

          ad.fullScreenContentCallback = FullScreenContentCallback(
            onAdDismissedFullScreenContent: (ad) {
              ad.dispose();
              isFullScreenAdShowing = false;
              resetHomeTimer();
              onComplete(null);
            },
            onAdFailedToShowFullScreenContent: (ad, err) {
              ad.dispose();
              isFullScreenAdShowing = false;
              onComplete(null);
            },
          );
          ad.show();
          return;
        }
      } else if (stepType == 'native') {
        NativeAd? loadedNative;

        for (final unitId in adsData.splashNativeList) {
          final completer = Completer<NativeAd?>();
          final nAd = NativeAd(
            adUnitId: unitId,
            factoryId: 'full_native',
            request: const AdRequest(),
            listener: NativeAdListener(
              onAdLoaded: (ad) => completer.complete(ad as NativeAd),
              onAdFailedToLoad: (ad, err) {
                ad.dispose();
                completer.complete(null);
              },
            ),
          );
          nAd.load();

          final res = await completer.future.timeout(
            Duration(seconds: timeout),
            onTimeout: () => null,
          );
          if (res != null) {
            loadedNative = res;
            break;
          }
        }

        if (loadedNative != null) {
          onComplete(loadedNative);
          return;
        }
      }
    }

    // All flow steps exhausted or disabled
    onComplete(null);
  }

  // ── 5. ONBOARDING SWIPE INTERSTITIAL WITH GLASS LOADER ─────────────
  Future<void> handleOnboardingSwipe({
    required bool isNext,
    required VoidCallback onProceed,
  }) async {
    if (!shouldShowAds || isFullScreenAdShowing) {
      onProceed();
      return;
    }

    final cfg = remoteConfig.adsConfig.value;
    if (cfg == null) {
      onProceed();
      return;
    }

    final flow = cfg.adsConfig.onboardingFlow;
    final shouldShow = isNext ? flow.showNextInterstitial : flow.showPrevInterstitial;
    final timeout = isNext ? flow.nextTimeout : flow.prevTimeout;

    if (!shouldShow) {
      onProceed();
      return;
    }

    // Show Frosted Glass "Loading Ad..." Dialog
    final context = Get.overlayContext ?? Get.context;
    if (context != null) AdLoadingDialog.show(context);

    final ad = await loadWithWaterfall<InterstitialAd>(
      adUnits: cfg.adsData.onboardingInterstitialList,
      loadFunc: (u) => loadInterstitial(u, timeoutSeconds: timeout),
    );

    // Immediately dismiss dialog
    if (context != null) AdLoadingDialog.hide(context);

    if (ad != null) {
      if (isFullScreenAdShowing) {
        ad.dispose();
        onProceed();
        return;
      }

      isFullScreenAdShowing = true;
      resetHomeTimer();

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          isFullScreenAdShowing = false;
          resetHomeTimer();
          onProceed();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          isFullScreenAdShowing = false;
          onProceed();
        },
      );
      ad.show();
    } else {
      onProceed();
    }
  }

  // ── 6. CLICK & ACTION COUNTER INTERSTITIAL ────────────────────────
  Future<void> onUserAction({VoidCallback? onComplete}) async {
    final cfg = remoteConfig.adsConfig.value;
    if (cfg == null || !shouldShowAds || !cfg.isClickCounterEnabled) {
      onComplete?.call();
      return;
    }

    _actionClickCounter++;
    if (_actionClickCounter >= cfg.clickCount) {
      _actionClickCounter = 0;
      final placement = cfg.adsConfig.placements['click_interstitial'];
      final timeout = placement?.timeout ?? 10;

      await _showFullScreenInterstitial(
        adUnits: cfg.adsData.clickInterstitialList,
        timeoutSeconds: timeout,
        onComplete: onComplete,
      );
    } else {
      onComplete?.call();
    }
  }

  // ── 7. TIMER INTERSTITIAL ─────────────────────────────────────────
  Future<void> _triggerTimerInterstitial() async {
    final cfg = remoteConfig.adsConfig.value;
    if (cfg == null || !shouldShowAds || !cfg.isTimerEnabled) return;

    final placement = cfg.adsConfig.placements['timer_interstitial'];
    final timeout = placement?.timeout ?? 10;

    await _showFullScreenInterstitial(
      adUnits: cfg.adsData.timerInterstitialList,
      timeoutSeconds: timeout,
      onComplete: null,
    );
  }

  // Shared loader with Frosted Glass Dialog & Single Ad Guard
  Future<void> _showFullScreenInterstitial({
    required List<String> adUnits,
    required int timeoutSeconds,
    VoidCallback? onComplete,
  }) async {
    if (isFullScreenAdShowing) {
      onComplete?.call();
      return;
    }

    final context = Get.overlayContext ?? Get.context;
    if (context != null) AdLoadingDialog.show(context);

    final ad = await loadWithWaterfall<InterstitialAd>(
      adUnits: adUnits,
      loadFunc: (u) => loadInterstitial(u, timeoutSeconds: timeoutSeconds),
    );

    if (context != null) AdLoadingDialog.hide(context);

    if (ad != null) {
      if (isFullScreenAdShowing) {
        ad.dispose();
        onComplete?.call();
        return;
      }

      isFullScreenAdShowing = true;
      resetHomeTimer();

      ad.fullScreenContentCallback = FullScreenContentCallback(
        onAdDismissedFullScreenContent: (ad) {
          ad.dispose();
          isFullScreenAdShowing = false;
          resetHomeTimer();
          onComplete?.call();
        },
        onAdFailedToShowFullScreenContent: (ad, err) {
          ad.dispose();
          isFullScreenAdShowing = false;
          resetHomeTimer();
          onComplete?.call();
        },
      );
      ad.show();
    } else {
      resetHomeTimer();
      onComplete?.call();
    }
  }

  @override
  void onClose() {
    stopHomeTimer();
    super.onClose();
  }
}
