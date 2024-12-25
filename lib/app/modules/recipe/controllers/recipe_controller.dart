import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:connectivity_plus/connectivity_plus.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:image_picker/image_picker.dart';

class RecipeController extends GetxController {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? image;
  final picker = ImagePicker();
  final GetStorage storage = GetStorage();
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');

  Future<bool> isInternetAvailable() async {
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

  Future<void> uploadOfflineRecipes() async {
    if (!(await isInternetAvailable())) return;

    List<dynamic> offlineRecipes = storage.read('offlineRecipes') ?? [];

    for (var recipeData in List.from(offlineRecipes)) {
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

        await recipes.add({
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
      storage.write('offlineRecipes', offlineRecipes);
    } else {
      storage.remove('offlineRecipes');
    }
  }

  Future<void> deleteRecipe(String id, String? imageUrl) async {
    try {
      if (imageUrl != null) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }
      await recipes.doc(id).delete();
    } catch (e) {
      print('Error deleting recipe: $e');
    }
  }

  Future<void> pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile != null) {
      image = File(pickedFile.path);
    }
  }

  Future<void> uploadRecipe(Function onSuccess, Function onError) async {
    if (nameController.text.isEmpty || descriptionController.text.isEmpty) {
      return;
    }

    bool internetAvailable = await isInternetAvailable();
    String? imageUrl;

    if (internetAvailable) {
      try {
        if (image != null) {
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('recipes/${DateTime.now().toString()}');
          await storageRef.putFile(image!);
          imageUrl = await storageRef.getDownloadURL();
        }

        await FirebaseFirestore.instance.collection('recipes').add({
          'name': nameController.text,
          'description': descriptionController.text,
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        onSuccess();
      } catch (e) {
        saveToLocal(imageUrl);
        onError('Saved locally due to network issues.');
      }
    } else {
      saveToLocal(null);
      onError('No internet connection. Data saved locally.');
    }
  }

  void saveToLocal(String? imageUrl) {
    List<dynamic> recipes = storage.read('offlineRecipes') ?? [];
    recipes.add({
      'name': nameController.text,
      'description': descriptionController.text,
      'imagePath': image?.path,
      'imageUrl': imageUrl,
      'createdAt': DateTime.now().toIso8601String(),
    });
    storage.write('offlineRecipes', recipes);
  }

  Future<void> deleteItem(String docId, String imageUrl) async {
    try {
      // Hapus dokumen dari Firestore
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(docId)
          .delete();

      // Jika ada file di Firebase Storage (contoh penghapusan image)
      if (imageUrl.isNotEmpty) {
        // Tambahkan logika penghapusan file jika perlu
        // await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      // Tampilkan Snackbar untuk konfirmasi
      Get.snackbar(
        'Berhasil',
        'Resep berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Tangani exception
      Get.snackbar(
        'Error',
        'Gagal menghapus resep: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
