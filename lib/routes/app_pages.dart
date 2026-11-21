import 'package:get/get_navigation/src/routes/get_route.dart';
import 'package:monvexa/bindings/account_detection_binding.dart';
import 'package:monvexa/bindings/home_binding.dart';
import 'package:monvexa/bindings/onboading_binding.dart';
import 'package:monvexa/bindings/splash_binding.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/ui/screens/account_detection_screen.dart';
import 'package:monvexa/ui/screens/home_screen.dart';
import 'package:monvexa/ui/screens/onboarding_screen.dart';
import 'package:monvexa/ui/screens/splash_screen.dart';

class AppPages {
  static final pages = [
    GetPage(
      name: AppRoutes.splash,
      page: () => const SplashScreen(),
      binding: SplashBinding(),
    ),
    GetPage(
      name: AppRoutes.onboarding,
      page: () => const OnboardingScreen(),
      binding: OnboardingBinding(),
    ),
    GetPage(
      name: AppRoutes.home,
      page: () => const HomeScreen(),
      binding: HomeBinding(),
    ),
    GetPage(
      name: AppRoutes.accountDetection,
      page: () => const AccountDetectionScreen(),
      binding: AccountDetectionBinding(),
    ),
  ];
}
