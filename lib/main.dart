import 'package:demo_yummy/app/modules/home/controllers/home_controller.dart';
import 'package:demo_yummy/app/modules/notification/notification_service.dart';
import 'package:demo_yummy/app/modules/profile/views/login_page.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'app/modules/profile/controllers/profile_controller.dart';
import 'app/modules/profile/views/create_profile_page.dart';
import 'app/modules/home/views/home_page.dart';
import 'app/modules/profile/views/account_page.dart';
import 'app/modules/onboarding/onboarding_page.dart';

void main() async {
  Get.put(HomeController());
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp();
  await GetStorage.init();
  await Firebase.initializeApp();
  await FirebaseMessaging.instance.requestPermission();

  FirebaseMessaging.onBackgroundMessage(_firebaseMessagingBackgroundHandler);

  await NotificationService.instance.initialize();

  if (WebView.platform == null) {
    WebView.platform = SurfaceAndroidWebView();
  }

  Get.put(ProfileController());
  runApp(YummyApp());
}

Future<void> _firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  // Tangani pesan latar belakang
  print("Menangani pesan latar belakang: ${message.messageId}");
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
        GetPage(name: '/upload-profile', page: () => CreateProfilePage()),
        GetPage(name: '/home', page: () => HomeView()),
        GetPage(name: '/account', page: () => AccountPage()),
        GetPage(name: '/login', page: () => LoginPage()),
      ],
    );
  }
}
