import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/ad_service.dart';
import 'package:monvexa/services/database_service.dart';
import 'package:monvexa/services/pref_service.dart';
import 'package:monvexa/services/sms_service.dart';
import 'package:monvexa/widgets/ads/native/fullscreen_native_template.dart';

class SplashController extends GetxController with GetTickerProviderStateMixin {
  late AnimationController logoController;
  late AnimationController nameController;
  late AnimationController descriptionController;
  late AnimationController progressController;

  late Animation<double> logoScale;
  late Animation<double> logoFade;

  late Animation<Offset> nameSlide;
  late Animation<double> nameFade;

  late Animation<Offset> descriptionSlide;
  late Animation<double> descriptionFade;

  @override
  void onInit() {
    super.onInit();

    // Logo Animation
    logoController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 900),
    );

    logoScale = Tween<double>(
      begin: 0.5,
      end: 1.0,
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeIn));

    logoFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(CurvedAnimation(parent: logoController, curve: Curves.easeIn));

    // App Name Animation
    nameController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    nameSlide = Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero)
        .animate(
          CurvedAnimation(parent: nameController, curve: Curves.easeOutCubic),
        );

    nameFade = Tween<double>(begin: 0.0, end: 1.0).animate(nameController);

    // Description Animation
    descriptionController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 700),
    );

    descriptionSlide =
        Tween<Offset>(begin: const Offset(-1.0, 0.0), end: Offset.zero).animate(
          CurvedAnimation(
            parent: descriptionController,
            curve: Curves.easeOutCubic,
          ),
        );

    descriptionFade = Tween<double>(
      begin: 0.0,
      end: 1.0,
    ).animate(descriptionController);

    // Loading Animation
    progressController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2500),
    );
  }

  @override
  void onReady() {
    super.onReady();
    startSplashAnimation();
  }

  Future<void> startSplashAnimation() async {
    // 1. Logo animation
    await logoController.forward();

    // 2. App Name animation
    await nameController.forward();

    // 3. Description animation
    await descriptionController.forward();

    // 4. Concurrently run loader progress (0 to 100%) and background warm-up initialization
    await Future.wait([
      progressController.forward(),
      _warmupServicesAndData(),
    ]);

    // 5. Sequential Splash Ad Flow (splash -> ads -> onboarding/home)
    if (Get.isRegistered<AdService>()) {
      await AdService.to.runSplashAdFlow(
        onComplete: (fallbackNative) {
          if (fallbackNative != null) {
            // Fullscreen native fallback ad
            AdService.to.isFullScreenAdShowing = true;
            Get.to(() => FullscreenNativeTemplate(
                  nativeAd: fallbackNative,
                  onDismiss: () {
                    AdService.to.isFullScreenAdShowing = false;
                    AdService.to.resetHomeTimer();
                    fallbackNative.dispose();
                    _navigateToNextScreen();
                  },
                ));
          } else {
            _navigateToNextScreen();
          }
        },
      );
    } else {
      _navigateToNextScreen();
    }
  }

  void _navigateToNextScreen() {
    final bool done = PrefService.to.isOnboardingDone;
    Get.offNamed(done ? AppRoutes.home : AppRoutes.onboarding);
  }

  Future<void> _warmupServicesAndData() async {
    try {
      // Warm up SQLite database
      await DatabaseService.to.database;

      // Only check and load SMS if onboarding was already completed by the user
      final bool onboardingDone = PrefService.to.isOnboardingDone;
      if (!onboardingDone) return;

      if (Get.isRegistered<SmsService>()) {
        final smsService = Get.find<SmsService>();
        await smsService.checkPermissionSilently();
      }
    } catch (_) {
      // Graceful fallback — non-blocking
    }
  }

  @override
  void onClose() {
    logoController.dispose();
    nameController.dispose();
    descriptionController.dispose();
    progressController.dispose();

    super.onClose();
  }
}
