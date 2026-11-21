import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/image_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/pref_service.dart';

class OnboardingController extends GetxController {
  final PageController pageController = PageController();

  final RxInt currentPage = 0.obs;
  bool get isLastPage => currentPage.value == onboardingImages.length - 1;

  final List<String> onboardingImages = [
    ImageConst.onboarding1,
    ImageConst.onboarding2,
    ImageConst.onboarding3,
  ];

  final List<String> onboardingTitles1 = [
    StringConst.onboarding1Title1,
    StringConst.onboarding2Title1,
    StringConst.onboarding3Title1,
  ];

  final List<String> onboardingTitles2 = [
    StringConst.onboarding1Title2,
    StringConst.onboarding2Title2,
    StringConst.onboarding3Title2,
  ];

  final List<String> onboardingDescriptions = [
    StringConst.onboarding1Description,
    StringConst.onboarding2Description,
    StringConst.onboarding3Description,
  ];

  String getOnboardingImage(int index) => onboardingImages[index];
  String getOnboardingTitle1(int index) => onboardingTitles1[index];
  String getOnboardingTitle2(int index) => onboardingTitles2[index];
  String getOnboardingDescription(int index) => onboardingDescriptions[index];

  void onPageChanged(int index) {
    currentPage.value = index;
  }

  void nextPage() {
    if (isLastPage) {
      PrefService.to.setOnboardingDone();
      Get.offAllNamed(AppRoutes.home);
    } else if (pageController.hasClients) {
      pageController.nextPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void previousPage() {
    if (pageController.hasClients && currentPage.value > 0) {
      pageController.previousPage(
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  void goToPage(int index) {
    if (pageController.hasClients &&
        index >= 0 &&
        index < onboardingImages.length) {
      pageController.animateToPage(
        index,
        duration: const Duration(milliseconds: 350),
        curve: Curves.easeInOutCubic,
      );
    }
  }

  @override
  void onClose() {
    pageController.dispose();
    super.onClose();
  }
}
