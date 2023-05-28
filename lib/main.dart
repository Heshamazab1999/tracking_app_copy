import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tracking_app/screen/splash/splash_screen.dart';
import 'helper/get_di.dart' as di;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  Map<String, Map<String, String>> languages = await di.init();

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      locale: Locale("ar"),
      fallbackLocale: Locale("ar"),
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}
