// ignore_for_file: use_key_in_widget_constructors
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'app/modules/profile/controllers/profile_controller.dart';
import 'app/modules/profile/views/create_profile_page.dart';
import 'app/modules/home/views/home_page.dart';
import 'app/modules/profile/views/account_page.dart';
import 'app/modules/onboarding/onboarding_page.dart';

void main() {
  Get.put(ProfileController()); // Memastikan RecipeController terinisialisasi
  runApp(YummyApp());
}

class YummyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yummy App',
      initialRoute: '/onboarding',
      getPages: [
        GetPage(name: '/onboarding', page: () => OnboardingPage()),
        GetPage(
            name: '/upload-profile',
            page: () => CreateProfilePage()), // Update nama route
        GetPage(name: '/home', page: () => HomeView()),
        GetPage(name: '/account', page: () => AccountPage()),
      ],
    );
  }
}
