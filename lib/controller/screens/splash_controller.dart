import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/pref_service.dart';

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
    // 1. Logo
    await logoController.forward();

    // 2. App Name
    await nameController.forward();

    // 3. Description
    await descriptionController.forward();

    // 4. Loader 0-100%
    await progressController.forward();

    // 5. Navigate to Home
    final bool done = PrefService.to.isOnboardingDone;
    Get.offNamed(done ? AppRoutes.home : AppRoutes.onboarding);
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
