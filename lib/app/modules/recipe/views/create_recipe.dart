import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:get_storage/get_storage.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class CreateRecipePage extends StatefulWidget {
  @override
  _CreateRecipePageState createState() => _CreateRecipePageState();
}

class _CreateRecipePageState extends State<CreateRecipePage> {
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _descriptionController = TextEditingController();
  File? _image;
  final picker = ImagePicker();
  final GetStorage _storage = GetStorage();

  // Fungsi untuk memeriksa koneksi internet menggunakan Connectivity Plus
  Future<bool> _isInternetAvailable() async {
    var connectivityResult = await Connectivity().checkConnectivity();
    if (connectivityResult == ConnectivityResult.none) {
      return false;
    }
    try {
      final result = await InternetAddress.lookup('google.com');
      return result.isNotEmpty && result[0].rawAddress.isNotEmpty;
    } catch (_) {
      return false;
    }
  }

  Future<void> _uploadOfflineRecipes() async {
    bool internetAvailable = await _isInternetAvailable();
    if (internetAvailable) {
      List<dynamic> offlineRecipes = _storage.read('offlineRecipes') ?? [];

      for (var recipeData in offlineRecipes) {
        try {
          String? imageUrl;

          if (recipeData['imagePath'] != null) {
            File imageFile = File(recipeData['imagePath']);
            final storageRef = FirebaseStorage.instance
                .ref()
                .child('recipes/${DateTime.now().toString()}');
            await storageRef.putFile(imageFile);
            imageUrl = await storageRef.getDownloadURL();
          }

          await FirebaseFirestore.instance.collection('recipes').add({
            'name': recipeData['name'],
            'description': recipeData['description'],
            'imageUrl': imageUrl,
            'createdAt': FieldValue.serverTimestamp(),
          });

          offlineRecipes.remove(recipeData);
        } catch (e) {
          print('Error uploading offline recipe: $e');
        }
      }

      if (offlineRecipes.isNotEmpty) {
        _storage.write('offlineRecipes', offlineRecipes);
      } else {
        _storage.remove('offlineRecipes');
      }
    }
  }

  Future<void> _pickImage() async {
    final pickedFile = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Select Image'),
        actions: [
          TextButton(
            onPressed: () async {
              final file = await picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, file);
            },
            child: Text('Take Photo'),
          ),
          TextButton(
            onPressed: () async {
              final file = await picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, file);
            },
            child: Text('Choose from Gallery'),
          ),
        ],
      ),
    );

    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  Future<void> _uploadRecipe() async {
    if (_nameController.text.isEmpty || _descriptionController.text.isEmpty) {
      return;
    }

    bool internetAvailable = await _isInternetAvailable();
    String? imageUrl;

    if (internetAvailable) {
      try {
        if (_image != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('recipes/${DateTime.now().toString()}');
          await storageRef.putFile(_image!);
          imageUrl = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('recipes').add({
          'name': _nameController.text,
          'description': _descriptionController.text,
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        Navigator.pop(context);
      } catch (e) {
        print('Error uploading recipe: $e');
        _saveToLocal(imageUrl);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Saved locally due to network issues.')),
        );
      }
    } else {
      _saveToLocal(null);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('No internet connection. Data saved locally.')),
      );
      Navigator.pop(context);
    }
  }

  void _saveToLocal(String? imageUrl) {
    List<dynamic> recipes = _storage.read('offlineRecipes') ?? [];
    recipes.add({
      'name': _nameController.text,
      'description': _descriptionController.text,
      'imagePath': _image?.path,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
    });
    _storage.write('offlineRecipes', recipes);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Recipe')),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: _image != null
                    ? ClipRRect(
                        borderRadius: BorderRadius.circular(100),
                        child: Image.file(
                          _image!,
                          height: 200,
                          width: 200,
                        ),
                      )
                    : Container(
                        height: 200,
                        width: 200,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.circular(100),
                        ),
                        child: Icon(Icons.camera_alt, color: Colors.grey[700]),
                      ),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              SizedBox(height: 20),
              TextField(
                controller: _descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
                maxLines: 3,
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _uploadRecipe,
                child: Text('Save Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
