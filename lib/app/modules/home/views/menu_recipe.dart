import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/recipe_controller.dart';

class MenuRecipePage extends StatelessWidget {
  final RecipeController recipeController = Get.put(RecipeController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Menu Recipes')),
      body: Obx(() {
        return ListView.builder(
          itemCount: recipeController.recipes.length,
          itemBuilder: (context, index) {
            final recipe = recipeController.recipes[index];
            return ListTile(
              leading: recipe.imagePath != ''
                  ? Image.file(recipe.imagePath, width: 50, height: 50)
                  : Icon(Icons.fastfood),
              title: Text(recipe.title),
              subtitle: Text(recipe.ingredients),
            );
          },
        );
      }),
    );
  }
}
