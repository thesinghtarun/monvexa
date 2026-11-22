import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:monvexa/config/remote_config_service.dart';
import 'package:monvexa/services/ad_service.dart';
import 'package:monvexa/widgets/ads/ad_shimmer_container.dart';

class DynamicNativeAdWidget extends StatefulWidget {
  final String placementKey; // e.g. 'onboarding_native'
  final ValueChanged<double>? onHeightChanged;

  const DynamicNativeAdWidget({
    super.key,
    required this.placementKey,
    this.onHeightChanged,
  });

  @override
  State<DynamicNativeAdWidget> createState() => _DynamicNativeAdWidgetState();
}

class _DynamicNativeAdWidgetState extends State<DynamicNativeAdWidget> {
  NativeAd? _nativeAd;
  bool _isLoading = true;
  bool _loadFailed = false;

  @override
  void initState() {
    super.initState();
    _checkInitialHeightAndLoad();
  }

  void _notifyHeight(double height) {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        widget.onHeightChanged?.call(height);
      }
    });
  }

  double _getDesiredHeight(String adsType) {
    switch (adsType) {
      case 'medium_native':
        return 180;
      case 'large_native':
        return 320;
      case 'small_native':
      default:
        return 90;
    }
  }

  void _checkInitialHeightAndLoad() {
    final adService = AdService.to;
    final cfg = RemoteConfigService.to.adsConfig.value;
    final placement = cfg?.adsConfig.placements[widget.placementKey];

    if (!adService.shouldShowAds || cfg == null || placement == null || !placement.enabled) {
      _loadFailed = true;
      _isLoading = false;
      _notifyHeight(0.0);
      return;
    }

    final targetHeight = _getDesiredHeight(placement.adsType);
    _notifyHeight(targetHeight);
    _loadNativeAd();
  }

  Future<void> _loadNativeAd() async {
    final adService = AdService.to;
    if (!adService.shouldShowAds) {
      if (mounted) {
        setState(() => _loadFailed = true);
        _notifyHeight(0.0);
      }
      return;
    }

    final cfg = RemoteConfigService.to.adsConfig.value;
    if (cfg == null) {
      if (mounted) {
        setState(() => _loadFailed = true);
        _notifyHeight(0.0);
      }
      return;
    }

    final placement = cfg.adsConfig.placements[widget.placementKey];
    if (placement == null || !placement.enabled) {
      if (mounted) {
        setState(() => _loadFailed = true);
        _notifyHeight(0.0);
      }
      return;
    }

    List<String> adUnits;
    if (widget.placementKey == 'onboarding_native') {
      adUnits = cfg.adsData.onboardingNativeList;
    } else {
      adUnits = cfg.adsData.splashNativeList;
    }

    final factoryId = placement.adsType; // e.g. 'small_native', 'medium_native', 'large_native'
    final targetHeight = _getDesiredHeight(factoryId);

    for (final unit in adUnits) {
      final completer = Completer<NativeAd?>();

      final ad = NativeAd(
        adUnitId: unit,
        factoryId: factoryId,
        request: const AdRequest(),
        listener: NativeAdListener(
          onAdLoaded: (ad) => completer.complete(ad as NativeAd),
          onAdFailedToLoad: (ad, err) {
            ad.dispose();
            completer.complete(null);
          },
        ),
      );

      ad.load();

      final res = await completer.future.timeout(
        const Duration(seconds: 12),
        onTimeout: () => null,
      );

      if (res != null && mounted) {
        setState(() {
          _nativeAd = res;
          _isLoading = false;
        });
        _notifyHeight(targetHeight);
        return;
      }
    }

    if (mounted) {
      setState(() {
        _isLoading = false;
        _loadFailed = true;
      });
      _notifyHeight(0.0);
    }
  }

  @override
  void dispose() {
    _nativeAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSize(
      duration: const Duration(milliseconds: 300),
      curve: Curves.easeInOut,
      child: _buildContent(),
    );
  }

  Widget _buildContent() {
    if (_loadFailed) {
      return const SizedBox.shrink();
    }

    final cfg = RemoteConfigService.to.adsConfig.value;
    final adsType = cfg?.adsConfig.placements[widget.placementKey]?.adsType ?? 'small_native';
    final targetHeight = _getDesiredHeight(adsType);

    if (_isLoading || _nativeAd == null) {
      return AdShimmerContainer(
        width: double.infinity,
        height: targetHeight,
      );
    }

    return Container(
      width: double.infinity,
      height: targetHeight,
      alignment: Alignment.center,
      child: AdWidget(ad: _nativeAd!),
    );
  }
}
