import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/constants/app_colors.dart';

import 'package:monvexa/constants/image_const.dart';
import 'package:monvexa/constants/string_const.dart';
import 'package:monvexa/controller/screens/splash_controller.dart';

class SplashScreen extends GetView<SplashController> {
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Spacer(),
            // LOGO ANIMATION
            FadeTransition(
              opacity: controller.logoFade,
              child: ScaleTransition(
                scale: controller.logoScale,
                child: Image.asset(ImageConst.logo, width: 200, height: 200),
              ),
            ),

            const SizedBox(height: 20),

            // APP NAME ANIMATION
            FadeTransition(
              opacity: controller.nameFade,
              child: SlideTransition(
                position: controller.nameSlide,
                child: Text(
                  StringConst.appName,
                  style: const TextStyle(
                    fontSize: 30,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),

            const SizedBox(height: 12),

            // DESCRIPTION ANIMATION
            FadeTransition(
              opacity: controller.descriptionFade,
              child: SlideTransition(
                position: controller.descriptionSlide,
                child: Text(
                  StringConst.appDescription,
                  textAlign: TextAlign.center,
                  style: const TextStyle(fontSize: 15, color: Colors.grey),
                ),
              ),
            ),

            Spacer(),

            // LOADER ANIMATION
            Padding(
              padding: .only(
                left: 20,
                right: 20,
                bottom: MediaQuery.of(context).padding.bottom + 20,
              ),
              child: SizedBox(
                width: double.infinity,
                child: AnimatedBuilder(
                  animation: controller.progressController,
                  builder: (context, child) {
                    final progress = controller.progressController.value;

                    return Column(
                      children: [
                        ClipRRect(
                          borderRadius: BorderRadius.circular(20),
                          child: LinearProgressIndicator(
                            value: progress,
                            minHeight: 6,
                            backgroundColor: Colors.grey.shade300,
                            valueColor: AlwaysStoppedAnimation<Color>(
                              AppColors.primary,
                            ),
                          ),
                        ),

                        const SizedBox(height: 10),

                        Text(
                          '${(progress * 100).toInt()}%',
                          style: TextStyle(
                            fontSize: 12,
                            fontWeight: FontWeight.w600,
                            color: AppColors.primary,
                          ),
                        ),
                      ],
                    );
                  },
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
