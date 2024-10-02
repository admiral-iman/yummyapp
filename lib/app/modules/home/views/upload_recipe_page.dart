import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/recipe_controller.dart';
import '../models/recipe_model.dart';

class UploadRecipePage extends StatefulWidget {
  @override
  _UploadRecipePageState createState() => _UploadRecipePageState();
}

class _UploadRecipePageState extends State<UploadRecipePage> {
  File? _image;
  final picker = ImagePicker();
  final titleController = TextEditingController();
  final ingredientsController = TextEditingController();
  final stepsController = TextEditingController();

  late RecipeController recipeController;

  @override
  void initState() {
    super.initState();
    recipeController = Get.find(); // Inisialisasi controller di sini
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Upload Recipe')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            _image == null
                ? Text('No Image Selected')
                : Image.file(_image!, height: 200, width: 200),
            ElevatedButton(
              onPressed: _pickImage,
              child: Text('Pick Image from Gallery'),
            ),
            TextField(
              controller: titleController,
              decoration: InputDecoration(labelText: 'Title'),
            ),
            TextField(
              controller: ingredientsController,
              decoration: InputDecoration(labelText: 'Ingredients'),
            ),
            TextField(
              controller: stepsController,
              decoration: InputDecoration(labelText: 'Steps'),
            ),
            ElevatedButton(
              onPressed: () {
                // Validasi input
                if (_image == null) {
                  Get.snackbar("Error", "Please select an image.",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }
                if (titleController.text.isEmpty ||
                    ingredientsController.text.isEmpty ||
                    stepsController.text.isEmpty) {
                  Get.snackbar("Error", "All fields are required.",
                      snackPosition: SnackPosition.BOTTOM);
                  return;
                }

                Recipe newRecipe = Recipe(
                  title: titleController.text,
                  ingredients: ingredientsController.text,
                  steps: stepsController.text,
                  imagePath: _image!,
                );
                recipeController.addRecipe(newRecipe);
                Get.back();
              },
              child: Text('Submit Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
