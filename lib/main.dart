import 'dart:io';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:workers/login/Login.dart';

import 'Pages/firstpage.dart';
import 'Splashscreen/splashscreen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  if (Platform.isAndroid) {
    await Firebase.initializeApp(
      options: const FirebaseOptions(
        apiKey: 'AIzaSyBEwHmL7vCRvFhT0E4PgRuljZz8WeEc64Q',
        appId: '1:582445629498:android:816d99eecc14d96f2e3503',
        messagingSenderId: '582445629498',
        projectId: 'phoneauthfire-34a07',
      ),
    );
  } else {
    await Firebase.initializeApp();
  }

  runApp(const MyApp());
  _checkLoginStatus();
}
Future<void> _checkLoginStatus() async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;
  bool isLandingPageFirstTime = prefs.getBool('isLandingPageFirstTime') ?? true;


    if (isLoggedIn) {

      Get.to(ProductFormScreen());
    }

    else {
      Get.to(LoginScreen());
    }
  }

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      home: const SplashScreen(),
    );
  }
}
