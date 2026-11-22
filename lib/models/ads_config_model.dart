class AdsConfigModel {
  final bool showAds;
  final bool showAdsToFirstUser;
  final bool showAdsToReturningUser;
  final int timerCount;
  final int clickCount;
  final AdsDataModel adsData;
  final AdsConfigFlowModel adsConfig;

  AdsConfigModel({
    required this.showAds,
    required this.showAdsToFirstUser,
    required this.showAdsToReturningUser,
    required this.timerCount,
    required this.clickCount,
    required this.adsData,
    required this.adsConfig,
  });

  bool get isClickCounterEnabled =>
      (adsConfig.placements['click_interstitial']?.enabled ?? false) && clickCount > 0;

  bool get isTimerEnabled =>
      (adsConfig.placements['timer_interstitial']?.enabled ?? false) && timerCount > 0;

  factory AdsConfigModel.fromJson(Map<String, dynamic> json) {
    return AdsConfigModel(
      showAds: json['show_ads'] as bool? ?? false,
      showAdsToFirstUser: json['show_ads_to_first_user'] as bool? ?? true,
      showAdsToReturningUser: json['show_ads_to_returning_user'] as bool? ?? true,
      timerCount: (json['timer_count'] as num?)?.toInt() ?? 30,
      clickCount: (json['click_count'] as num?)?.toInt() ?? 5,
      adsData: AdsDataModel.fromJson(
        Map<String, dynamic>.from(json['ads_data'] as Map? ?? {}),
      ),
      adsConfig: AdsConfigFlowModel.fromJson(
        Map<String, dynamic>.from(json['ads_config'] as Map? ?? {}),
      ),
    );
  }
}

class AdsDataModel {
  final List<String> splashInterstitialList;
  final List<String> splashNativeList;
  final List<String> splashAppOpenList;
  final List<String> onboardingNativeList;
  final List<String> onboardingInterstitialList;
  final List<String> bottomBannerList;
  final List<String> clickInterstitialList;
  final List<String> timerInterstitialList;

  AdsDataModel({
    required this.splashInterstitialList,
    required this.splashNativeList,
    required this.splashAppOpenList,
    required this.onboardingNativeList,
    required this.onboardingInterstitialList,
    required this.bottomBannerList,
    required this.clickInterstitialList,
    required this.timerInterstitialList,
  });

  factory AdsDataModel.fromJson(Map<String, dynamic> json) {
    List<String> toList(dynamic val) {
      if (val is List) {
        return val.map((e) => e.toString()).toList();
      }
      return [];
    }

    return AdsDataModel(
      splashInterstitialList: toList(json['splash_interstitial_list']),
      splashNativeList: toList(json['splash_native_list']),
      splashAppOpenList: toList(json['splash_app_open_list']),
      onboardingNativeList: toList(json['onboarding_native_list']),
      onboardingInterstitialList: toList(json['onboarding_interstitial_list']),
      bottomBannerList: toList(json['bottom_banner_list']),
      clickInterstitialList: toList(json['click_interstitial_list']),
      timerInterstitialList: toList(json['timer_interstitial_list']),
    );
  }
}

class OnboardingFlowConfig {
  final bool showPrevInterstitial;
  final bool showNextInterstitial;
  final int nextTimeout;
  final int prevTimeout;

  OnboardingFlowConfig({
    required this.showPrevInterstitial,
    required this.showNextInterstitial,
    required this.nextTimeout,
    required this.prevTimeout,
  });

  factory OnboardingFlowConfig.fromJson(Map<String, dynamic> json) {
    return OnboardingFlowConfig(
      showPrevInterstitial: json['show_prev_interstitial'] as bool? ?? false,
      showNextInterstitial: json['show_next_interstitial'] as bool? ?? false,
      nextTimeout: (json['next_timeout'] as num?)?.toInt() ?? 15,
      prevTimeout: (json['prev_timeout'] as num?)?.toInt() ?? 10,
    );
  }
}

class PlacementConfig {
  final bool enabled;
  final int timeout;
  final String adName;
  final String adsType; // e.g. 'interstitial', 'full_native', 'small_native', 'banner'
  final String adId;

  PlacementConfig({
    required this.enabled,
    required this.timeout,
    required this.adName,
    required this.adsType,
    required this.adId,
  });

  factory PlacementConfig.fromJson(Map<String, dynamic> json) {
    return PlacementConfig(
      enabled: json['enabled'] as bool? ?? true,
      timeout: (json['timeout'] as num?)?.toInt() ?? 10,
      adName: json['ad_name']?.toString() ?? '',
      adsType: json['ads_type']?.toString() ?? '',
      adId: json['ad_id']?.toString() ?? '',
    );
  }
}

class AdsConfigFlowModel {
  final List<String> splashFlow; // e.g. ["native", "app_open", "interstitial"]
  final OnboardingFlowConfig onboardingFlow;
  final Map<String, PlacementConfig> placements;

  AdsConfigFlowModel({
    required this.splashFlow,
    required this.onboardingFlow,
    required this.placements,
  });

  factory AdsConfigFlowModel.fromJson(Map<String, dynamic> json) {
    final rawSplashFlow = json['splash_flow'] as List? ?? [];
    final List<String> splashSteps = [];

    for (final item in rawSplashFlow) {
      if (item is String) {
        splashSteps.add(item);
      } else if (item is Map) {
        for (final entry in item.entries) {
          splashSteps.add(entry.key.toString());
        }
      }
    }

    final onboardingFlow = OnboardingFlowConfig.fromJson(
      Map<String, dynamic>.from(json['onboarding_flow'] as Map? ?? {}),
    );

    final Map<String, PlacementConfig> placements = {};
    json.forEach((k, v) {
      if (k != 'splash_flow' && k != 'onboarding_flow' && v is Map) {
        placements[k] = PlacementConfig.fromJson(Map<String, dynamic>.from(v));
      }
    });

    return AdsConfigFlowModel(
      splashFlow: splashSteps,
      onboardingFlow: onboardingFlow,
      placements: placements,
    );
  }
}
