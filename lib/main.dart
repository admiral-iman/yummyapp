import 'package:flutter/material.dart';
import 'package:get/get.dart';

import 'app/modules/home/controllers/recipe_controller.dart';
import 'app/modules/home/views/home_page.dart';
import 'app/modules/home/views/menu_recipe.dart';
import 'app/modules/home/views/onboarding_page.dart';
import 'app/modules/home/views/upload_recipe_page.dart';

void main() {
  Get.put(RecipeController());
  runApp(YummyApp());
}

class YummyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Yummy Recipes',
      initialRoute: '/onboarding',
      getPages: [
        GetPage(name: '/onboarding', page: () => OnboardingPage()),
        GetPage(name: '/home', page: () => HomePage()),
        GetPage(name: '/menu-recipe', page: () => MenuRecipePage()),
        GetPage(name: '/upload-recipe', page: () => UploadRecipePage()),
      ],
    );
  }
}
