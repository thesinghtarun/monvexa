import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monvexa/config/remote_config_service.dart';
import 'package:monvexa/services/ad_service.dart';
import 'package:monvexa/widgets/ads/ad_shimmer_container.dart';

class BannerAdWidget extends StatefulWidget {
  const BannerAdWidget({super.key});

  @override
  State<BannerAdWidget> createState() => _BannerAdWidgetState();
}

class _BannerAdWidgetState extends State<BannerAdWidget> {
  BannerAd? _bannerAd;
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _checkInitialStateAndLoad();
  }

  void _notifyBannerState(bool isShowing) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        AdService.to.updateBannerState(isShowing);
      }
    });
  }

  Future<void> _checkInitialStateAndLoad() async {
    final adService = AdService.to;
    final cfg = RemoteConfigService.to.adsConfig.value;
    final placement = cfg?.adsConfig.placements['bottom_banner'];

    if (!adService.shouldShowAds || cfg == null || placement == null || !placement.enabled) {
      _loadFailed = true;
      _isLoading = false;
      _notifyBannerState(false);
      return;
    }

    // Indicates banner is attempting to show (shimmer)
    _notifyBannerState(true);
    _loadBanner();
  }

  Future<void> _loadBanner() async {
    final adService = AdService.to;
    if (!adService.shouldShowAds) {
      if (mounted) {
        setState(() => _loadFailed = true);
        _notifyBannerState(false);
      }
      return;
    }

    final cfg = RemoteConfigService.to.adsConfig.value;
    if (cfg == null) {
      if (mounted) {
        setState(() => _loadFailed = true);
        _notifyBannerState(false);
      }
      return;
    }

    final placement = cfg.adsConfig.placements['bottom_banner'];
    if (placement == null || !placement.enabled) {
      if (mounted) {
        setState(() => _loadFailed = true);
        _notifyBannerState(false);
      }
      return;
    }

    final adUnits = cfg.adsData.bottomBannerList;
    final timeout = placement.timeout;

    for (final unit in adUnits) {
      final completer = Completer<BannerAd?>();

      final bAd = BannerAd(
        adUnitId: unit,
        size: AdSize.banner,
        request: const AdRequest(),
        listener: BannerAdListener(
          onAdLoaded: (ad) => completer.complete(ad as BannerAd),
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            completer.complete(null);
          },
        ),
      );

      bAd.load();

      final res = await completer.future.timeout(
        Duration(seconds: timeout),
        onTimeout: () => null,
      );

      if (res != null && mounted) {
        setState(() {
          _bannerAd = res;
          _isLoading = false;
        });
        _notifyBannerState(true);
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
      _notifyBannerState(false);
    }
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_loadFailed) {
      return const SizedBox.shrink();
    }

    if (_isLoading || _bannerAd == null) {
      return const Center(
        child: AdShimmerContainer(
          width: 320,
          height: 50,
          borderRadius: 8,
        ),
      );
    }

    return Container(
      width: _bannerAd!.size.width.toDouble(),
      height: _bannerAd!.size.height.toDouble(),
      alignment: Alignment.center,
      child: AdWidget(ad: _bannerAd!),
    );
  }
}
