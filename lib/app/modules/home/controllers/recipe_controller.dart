import 'package:get/get.dart';
import '../models/recipe_model.dart';

class RecipeController extends GetxController {
  var recipes = <Recipe>[].obs;

  void addRecipe(Recipe recipe) {
    recipes.add(recipe);
  }

  List<Recipe> get allRecipes => recipes;
}
