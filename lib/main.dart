import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/config/remote_config_service.dart';
import 'package:monvexa/firebase_options.dart';
import 'package:monvexa/routes/app_pages.dart';
import 'package:monvexa/routes/app_routes.dart';
import 'package:monvexa/services/ad_service.dart';
import 'package:monvexa/services/pref_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);

   await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  final prefs = PrefService();
  await prefs.init();
  Get.put(prefs, permanent: true);

  final remoteConfig = RemoteConfigService();
  await remoteConfig.init();
  Get.put(remoteConfig, permanent: true);

  final adService = AdService();
  Get.put(adService, permanent: true);

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      initialRoute: AppRoutes.splash,
      getPages: AppPages.pages,
      debugShowCheckedModeBanner: false,
    );
  }
}
