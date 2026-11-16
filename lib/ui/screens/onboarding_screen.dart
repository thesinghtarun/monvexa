import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';
import 'package:monvexa/controller/screens/onboarding_controller.dart';

class OnboardingScreen extends GetView<OnboardingController> {
  const OnboardingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Obx(() {
        final index = controller.currentPage.value;

        return GestureDetector(
          onHorizontalDragEnd: (details) {
            if (details.primaryVelocity == null) return;

            if (details.primaryVelocity! < 0) {
              controller.nextPage();
            } else if (details.primaryVelocity! > 0) {
              controller.previousPage();
            }
          },
          child: Stack(
            fit: StackFit.expand,
            children: [
              // Background Image
              AnimatedSwitcher(
                duration: const Duration(milliseconds: 400),
                child: Image.asset(
                  controller.getOnboardingImage(index),
                  key: ValueKey(index),
                  fit: BoxFit.cover,
                  width: double.infinity,
                  height: double.infinity,
                ),
              ),

              // Dark Gradient
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

              // Fixed Content Layout
              SafeArea(
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 24,
                    vertical: 12,
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Spacer(),

                      // First Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          controller.getOnboardingTitle1(index),
                          key: ValueKey('title1_$index'),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: Colors.white,
                            height: 1.15,
                          ),
                        ),
                      ),

                      // Second Title
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          controller.getOnboardingTitle2(index),
                          key: ValueKey('title2_$index'),
                          style: const TextStyle(
                            fontSize: 30,
                            fontWeight: FontWeight.w800,
                            color: AppColors.primary,
                            height: 1.15,
                          ),
                        ),
                      ),

                      const SizedBox(height: 12),

                      // Description
                      AnimatedSwitcher(
                        duration: const Duration(milliseconds: 250),
                        child: Text(
                          controller.getOnboardingDescription(index),
                          key: ValueKey('description_$index'),
                          style: const TextStyle(
                            fontSize: 16,
                            fontWeight: FontWeight.w500,
                            color: Colors.white,
                            height: 1.4,
                          ),
                        ),
                      ),

                      const SizedBox(height: 24),

                      // Three Functional Dots
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: List.generate(
                          controller.onboardingImages.length,
                          (dotIndex) {
                            final isActive = index == dotIndex;

                            return GestureDetector(
                              onTap: () => controller.goToPage(dotIndex),
                              child: AnimatedContainer(
                                duration: const Duration(milliseconds: 250),
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 8,
                                ),
                                width: 13,
                                height: 13,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: isActive
                                      ? AppColors.primary
                                      : AppColors.primary.withOpacity(0.45),
                                ),
                              ),
                            );
                          },
                        ),
                      ),

                      const SizedBox(height: 20),

                      // Fixed Button
                      SizedBox(
                        width: double.infinity,
                        height: 54,
                        child: ElevatedButton(
                          onPressed: controller.nextPage,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: controller.isLastPage
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
                                controller.isLastPage ? 'Get Started' : 'Next',
                                style: const TextStyle(
                                  fontSize: 16,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(width: 10),
                              const Icon(Icons.arrow_forward_rounded, size: 20),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      }),
    );
  }
}
