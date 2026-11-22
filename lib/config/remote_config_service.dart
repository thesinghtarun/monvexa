import 'dart:convert';
import 'package:firebase_remote_config/firebase_remote_config.dart';
import 'package:flutter/foundation.dart';
import 'package:get/get.dart';
import 'package:monvexa/models/ads_config_model.dart';

enum AppEnvironment { debug, marketing, organic }

class RemoteConfigService extends GetxService {
  static RemoteConfigService get to => Get.find<RemoteConfigService>();

  /// Easily switch environment in code for testing (debug, marketing, organic)
  final Rx<AppEnvironment> environment = AppEnvironment.debug.obs;

  final Rx<AdsConfigModel?> adsConfig = Rx<AdsConfigModel?>(null);

  String get _environmentKey {
    switch (environment.value) {
      case AppEnvironment.debug:
        return 'debug_ads_config';
      case AppEnvironment.marketing:
        return 'marketing_ads_config';
      case AppEnvironment.organic:
        return 'organic_ads_config';
    }
  }

  Future<void> init() async {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;

      await remoteConfig.setConfigSettings(
        RemoteConfigSettings(
          fetchTimeout: const Duration(seconds: 20),
          minimumFetchInterval: Duration.zero,
        ),
      );

      // Default fallback JSON matching your exact schema
      const defaultJson = '''
      {
        "show_ads": true,
        "show_ads_to_first_user": true,
        "show_ads_to_returning_user": true,
        "timer_count": 30,
        "click_count": 5,
        "ads_data": {
          "splash_interstitial_list": [
            "ca-app-pub-3940256099942544/1033173712",
            "ca-app-pub-3940256099942544/1033173712"
          ],
          "splash_native_list": [
            "ca-app-pub-3940256099942544/2247696110",
            "ca-app-pub-3940256099942544/2247696110"
          ],
          "splash_app_open_list": [
            "ca-app-pub-3940256099942544/9257395921",
            "ca-app-pub-3940256099942544/9257395921"
          ],
          "onboarding_native_list": [
            "ca-app-pub-3940256099942544/2247696110",
            "ca-app-pub-3940256099942544/2247696110"
          ],
          "onboarding_interstitial_list": [
            "ca-app-pub-3940256099942544/1033173712",
            "ca-app-pub-3940256099942544/1033173712"
          ],
          "bottom_banner_list": [
            "ca-app-pub-3940256099942544/6300978111",
            "ca-app-pub-3940256099942544/6300978111"
          ],
          "click_interstitial_list": [
            "ca-app-pub-3940256099942544/1033173712",
            "ca-app-pub-3940256099942544/1033173712"
          ],
          "timer_interstitial_list": [
            "ca-app-pub-3940256099942544/1033173712",
            "ca-app-pub-3940256099942544/1033173712"
          ]
        },
        "ads_config": {
          "splash_flow": [
            "native",
            "app_open",
            "interstitial"
          ],
          "onboarding_flow": {
            "show_prev_interstitial": false,
            "show_next_interstitial": true,
            "next_timeout": 15,
            "prev_timeout": 10
          },
          "splash_interstitial": {
            "enabled": true,
            "timeout": 10,
            "ad_name": "splash_interstitial",
            "ads_type": "interstitial",
            "ad_id": "ad_unit"
          },
          "splash_native": {
            "enabled": false,
            "timeout": 15,
            "ad_name": "splash_native",
            "ads_type": "full_native",
            "ad_id": "ad_unit"
          },
          "splash_app_open": {
            "enabled": true,
            "timeout": 15,
            "ad_name": "splash_app_open",
            "ads_type": "interstitial",
            "ad_id": "ad_unit"
          },
          "onboarding_native": {
            "enabled": true,
            "timeout": 10,
            "ad_name": "onboarding_native",
            "ads_type": "small_native",
            "ad_id": "ad_unit"
          },
          "click_interstitial": {
            "enabled": true,
            "timeout": 10,
            "ad_name": "click_interstitial",
            "ads_type": "interstitial",
            "ad_id": "ad_unit"
          },
          "timer_interstitial": {
            "enabled": false,
            "timeout": 10,
            "ad_name": "timer_interstitial",
            "ads_type": "interstitial",
            "ad_id": "ad_unit"
          },
          "bottom_banner": {
            "enabled": true,
            "timeout": 10,
            "ad_name": "bottom_banner",
            "ads_type": "banner",
            "ad_id": "ad_unit"
          }
        }
      }
      ''';

      await remoteConfig.setDefaults({
        'debug_ads_config': defaultJson,
        'marketing_ads_config': defaultJson,
        'organic_ads_config': defaultJson,
      });

      await remoteConfig.fetchAndActivate();

      _parseConfigFromRemote();
    } catch (e) {
      debugPrint('[RemoteConfig] Error fetching remote config: $e');
    }
  }

  void setEnvironment(AppEnvironment env) {
    environment.value = env;
    _parseConfigFromRemote();
  }

  void _parseConfigFromRemote() {
    try {
      final remoteConfig = FirebaseRemoteConfig.instance;
      final rawString = remoteConfig.getString(_environmentKey);

      if (rawString.isNotEmpty) {
        final Map<String, dynamic> decoded = jsonDecode(rawString);
        adsConfig.value = AdsConfigModel.fromJson(decoded);
        debugPrint(
            '[RemoteConfig] Successfully parsed $_environmentKey: show_ads=${adsConfig.value?.showAds}');
      }
    } catch (e) {
      debugPrint('[RemoteConfig] JSON parse error: $e');
    }
  }
}
