import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/controller/screens/onboarding_controller.dart';
import 'package:monvexa/widgets/ads/native/dynamic_native_ad_widget.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        fit: StackFit.expand,
        children: [
          // 1. Background Image Layer with smooth crossfade
          Obx(() {
            final index = controller.currentPage.value;
            return AnimatedSwitcher(
              duration: const Duration(milliseconds: 400),
              child: Image.asset(
                controller.getOnboardingImage(index),
                key: ValueKey(index),
                fit: BoxFit.cover,
                width: double.infinity,
                height: double.infinity,
              ),
            );
          }),

          // 2. Dark Gradient Overlay for high text contrast
          Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                begin: Alignment.topCenter,
                end: Alignment.bottomCenter,
                colors: [
                  Colors.transparent,
                  Colors.transparent,
                  Colors.black.withAlpha(38),
                  const Color(0xFF002B29).withAlpha(191),
                  const Color(0xFF001F1E).withAlpha(250),
                ],
                stops: const [0.0, 0.40, 0.55, 0.75, 1.0],
              ),
            ),
          ),

          // 3. Swipeable PageView with physical gesture tracking
          PageView.builder(
            controller: controller.pageController,
            onPageChanged: controller.onPageChanged,
            itemCount: controller.onboardingImages.length,
            itemBuilder: (context, index) {
              return SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),

                      // Title 1
                      Text(
                        controller.getOnboardingTitle1(index),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: Colors.white,
                          height: 1.15,
                        ),
                      ),

                      // Title 2
                      Text(
                        controller.getOnboardingTitle2(index),
                        style: const TextStyle(
                          fontSize: 30,
                          fontWeight: FontWeight.w800,
                          color: AppColors.primary,
                          height: 1.15,
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description
                      Text(
                        controller.getOnboardingDescription(index),
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Colors.white,
                          height: 1.4,
                        ),
                      ),

                      // Dynamic clearance space for bottom controls (dots + button + native ad)
                      Obx(() {
                        final adHeight = controller.nativeAdHeight.value;
                        final dynamicClearance = 130.0 + (adHeight > 0 ? adHeight + 14.0 : 0.0);
                        return AnimatedContainer(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                          height: dynamicClearance,
                        );
                      }),
                    ],
                  ),
                ),
              );
            },
          ),

          // 4. Fixed Bottom Controls (Dots & Action Button & Dynamic Native Ad)
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(
                horizontal: 24,
                vertical: 12,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  // Smooth Indicator Dots
                  Obx(() {
                    final activeIndex = controller.currentPage.value;

                    return Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: List.generate(
                        controller.onboardingImages.length,
                        (dotIndex) {
                          final isActive = activeIndex == dotIndex;

                          return GestureDetector(
                            onTap: () => controller.goToPage(dotIndex),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                              margin: const EdgeInsets.symmetric(
                                horizontal: 4,
                              ),
                              width: isActive ? 26 : 10,
                              height: 10,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(5),
                                color: isActive
                                    ? AppColors.primary
                                    : AppColors.primary.withOpacity(0.35),
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  }),

                  const SizedBox(height: 20),

                  // Fixed Button
                  Obx(() {
                    final isLast = controller.isLastPage;

                    return SizedBox(
                      width: double.infinity,
                      height: 54,
                      child: ElevatedButton(
                        onPressed: controller.nextPage,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: isLast
                              ? AppColors.accent
                              : AppColors.primary,
                          foregroundColor: Colors.white,
                          elevation: 0,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(30),
                          ),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              isLast ? 'Get Started' : 'Next',
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                            const SizedBox(width: 10),
                            const Icon(
                              Icons.arrow_forward_rounded,
                              size: 20,
                            ),
                          ],
                        ),
                      ),
                    );
                  }),

                  // Dynamic Native Ad below button (configured via remote config)
                  Obx(() {
                    final hasAd = controller.nativeAdHeight.value > 0;
                    return SizedBox(height: hasAd ? 14 : 0);
                  }),
                  DynamicNativeAdWidget(
                    placementKey: 'onboarding_native',
                    onHeightChanged: controller.updateNativeAdHeight,
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }
}
