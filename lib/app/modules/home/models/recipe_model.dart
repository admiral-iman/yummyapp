import 'dart:io';

class Recipe {
  String title;
  String ingredients;
  String steps;
  File imagePath;

  Recipe({
    required this.title,
    required this.ingredients,
    required this.steps,
    required this.imagePath,
  });
}
