import 'dart:io';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_yummy/app/modules/recipe/controllers/recipe_controller.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'create_recipe.dart';
import 'package:connectivity_plus/connectivity_plus.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final RecipeController recipeController = Get.put(RecipeController());
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');
  final GetStorage _storage = GetStorage();
  bool isConnected = true;

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

  // Fungsi untuk mengunggah resep yang disimpan offline
  Future<void> _uploadOfflineRecipes() async {
    if (!isConnected) return; // Tidak mengupload jika tidak ada koneksi

    // Ambil data offline dari GetStorage
    List<dynamic> offlineRecipes = _storage.read('offlineRecipes') ?? [];

    for (var recipeData in List.from(offlineRecipes)) {
      try {
        // Ambil path gambar dari data lokal
        String? imageUrl;

        if (recipeData['imagePath'] != null) {
          File imageFile = File(recipeData['imagePath']);
          final storageRef = FirebaseStorage.instance
              .ref()
              .child('recipes/${DateTime.now().toString()}');
          await storageRef.putFile(imageFile);
          imageUrl = await storageRef.getDownloadURL();
        }

        // Unggah resep ke Firestore
        await FirebaseFirestore.instance.collection('recipes').add({
          'name': recipeData['name'],
          'description': recipeData['description'],
          'imageUrl': imageUrl,
          'createdAt': FieldValue.serverTimestamp(),
        });

        // Hapus resep yang sudah berhasil diunggah dari GetStorage
        offlineRecipes.remove(recipeData);
      } catch (e) {
        print('Error uploading offline recipe: $e');
      }
    }

    // Simpan kembali data offline setelah diunggah
    if (offlineRecipes.isNotEmpty) {
      _storage.write('offlineRecipes', offlineRecipes);
    } else {
      _storage.remove(
          'offlineRecipes'); // Hapus data offline jika sudah berhasil diunggah
    }
  }

  @override
  void initState() {
    super.initState();

    // Cek koneksi internet saat aplikasi pertama kali dimulai
    _isInternetAvailable().then((connected) {
      setState(() {
        isConnected = connected;
      });

      // Jika online, upload resep offline yang disimpan
      if (connected) {
        _uploadOfflineRecipes();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Recipes'),
        actions: [
          IconButton(
            icon: Icon(Icons.add),
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => CreateRecipePage()),
              );
            },
          ),
        ],
      ),
      body: FutureBuilder<bool>(
        future: _isInternetAvailable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !(snapshot.data ?? true)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No internet connection.'),
                  duration: Duration(seconds: 3),
                ),
              );
            });

            // Fetch offline recipes if no internet
            List<dynamic> offlineRecipes =
                _storage.read('offlineRecipes') ?? [];

            if (offlineRecipes.isEmpty) {
              return Center(child: Text('No recipes available.'));
            }

            // Display offline recipes
            return StreamBuilder<QuerySnapshot>(
              stream: recipes.snapshots(),
              builder: (context, firestoreSnapshot) {
                if (firestoreSnapshot.connectionState ==
                    ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                }

                if (firestoreSnapshot.hasError) {
                  return Center(
                    child: Text('Error loading recipes from Firestore.'),
                  );
                }

                final firestoreData = firestoreSnapshot.data!.docs;

                // Combine offline and online recipes
                final combinedRecipes = [
                  ...offlineRecipes.map((offlineRecipe) {
                    return {
                      'name': offlineRecipe['name'],
                      'description': offlineRecipe['description'],
                      'imageUrl': offlineRecipe['imageUrl'],
                    };
                  }),
                  ...firestoreData.map((firestoreRecipe) {
                    return {
                      'name': firestoreRecipe['name'],
                      'description': firestoreRecipe['description'],
                      'imageUrl': firestoreRecipe['imageUrl'],
                    };
                  }),
                ];

                return ListView.builder(
                  itemCount: combinedRecipes.length,
                  itemBuilder: (context, index) {
                    var recipe = combinedRecipes[index];
                    var imageUrl =
                        recipe['imageUrl'] ?? ''; // Handle missing imageUrl

                    return Card(
                      child: ListTile(
                        leading: imageUrl.isNotEmpty
                            ? CachedNetworkImage(
                                imageUrl: imageUrl,
                                width: 50,
                                height: 50,
                                fit: BoxFit.cover,
                                placeholder: (context, url) =>
                                    CircularProgressIndicator(),
                                errorWidget: (context, url, error) =>
                                    Icon(Icons.error),
                              )
                            : Icon(Icons.image),
                        title: Text(recipe['name']),
                        subtitle: Text(recipe['description']),
                        trailing: IconButton(
                          icon: Icon(Icons.delete),
                          onPressed: () async {
                            // Handle deleting recipe
                            if (index < offlineRecipes.length) {
                              // Delete from offline storage
                              offlineRecipes.removeAt(index);
                              _storage.write('offlineRecipes', offlineRecipes);
                            } else {
                              // Delete from Firestore
                              var firestoreRecipe =
                                  firestoreData[index - offlineRecipes.length];
                              await recipeController.deleteItem(
                                  firestoreRecipe.id, recipe['imageUrl']);
                            }
                            setState(() {});
                          },
                        ),
                        onTap: () {
                          // Navigate to edit page if needed
                        },
                      ),
                    );
                  },
                );
              },
            );
          }

          // If connected to the internet, fetch and display data from Firestore
          return StreamBuilder<QuerySnapshot>(
            stream: recipes.snapshots(),
            builder: (context, snapshot) {
              if (snapshot.connectionState == ConnectionState.waiting) {
                return Center(child: CircularProgressIndicator());
              }

              if (snapshot.hasError) {
                return Center(
                  child: Text('Error loading recipes from Firestore.'),
                );
              }

              final firestoreData = snapshot.data!.docs;

              // Fetch offline recipes from GetStorage
              List<dynamic> offlineRecipes =
                  _storage.read('offlineRecipes') ?? [];

              // Combine offline and online recipes
              final combinedRecipes = [
                ...offlineRecipes.map((offlineRecipe) {
                  return {
                    'name': offlineRecipe['name'],
                    'description': offlineRecipe['description'],
                    'imageUrl': offlineRecipe['imageUrl'],
                  };
                }),
                ...firestoreData.map((firestoreRecipe) {
                  return {
                    'name': firestoreRecipe['name'],
                    'description': firestoreRecipe['description'],
                    'imageUrl': firestoreRecipe['imageUrl'],
                  };
                }),
              ];

              return ListView.builder(
                itemCount: combinedRecipes.length,
                itemBuilder: (context, index) {
                  var recipe = combinedRecipes[index];
                  var imageUrl =
                      recipe['imageUrl'] ?? ''; // Handle missing imageUrl

                  return Card(
                    child: ListTile(
                      leading: imageUrl.isNotEmpty
                          ? CachedNetworkImage(
                              imageUrl: imageUrl,
                              width: 50,
                              height: 50,
                              fit: BoxFit.cover,
                              placeholder: (context, url) =>
                                  CircularProgressIndicator(),
                              errorWidget: (context, url, error) =>
                                  Icon(Icons.error),
                            )
                          : Icon(Icons.image),
                      title: Text(recipe['name']),
                      subtitle: Text(recipe['description']),
                      trailing: IconButton(
                        icon: Icon(Icons.delete),
                        onPressed: () async {
                          // Handle deleting recipe
                          if (index < offlineRecipes.length) {
                            // Delete from offline storage
                            offlineRecipes.removeAt(index);
                            _storage.write('offlineRecipes', offlineRecipes);
                          } else {
                            // Delete from Firestore
                            var firestoreRecipe =
                                firestoreData[index - offlineRecipes.length];
                            await recipeController.deleteItem(
                                firestoreRecipe.id, recipe['imageUrl']);
                          }
                          setState(() {});
                        },
                      ),
                      onTap: () {
                        // Navigate to edit page if needed
                      },
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
