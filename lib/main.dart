import 'package:flutter/services.dart';
import 'package:material_ui/material_ui.dart';
import 'package:get/get.dart';
import 'package:monvexa/routes/app_pages.dart';
import 'package:monvexa/routes/app_routes.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  await SystemChrome.setPreferredOrientations([DeviceOrientation.portraitUp]);
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
