import 'package:cached_network_image/cached_network_image.dart';
import 'package:demo_yummy/app/modules/recipe/controllers/recipe_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'create_recipe.dart';

class RecipePage extends StatefulWidget {
  @override
  _RecipePageState createState() => _RecipePageState();
}

class _RecipePageState extends State<RecipePage> {
  final RecipeController recipeController = Get.put(RecipeController());
  final GetStorage _storage = GetStorage();
  bool isConnected = true;

  @override
  void initState() {
    super.initState();

    recipeController.isInternetAvailable().then((connected) {
      setState(() {
        isConnected = connected;
      });

      if (connected) {
        recipeController.uploadOfflineRecipes();
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
        future: recipeController.isInternetAvailable(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError || !(snapshot.data ?? true)) {
            WidgetsBinding.instance.addPostFrameCallback((_) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('No internet connection.',
                      style: TextStyle(color: Colors.white)),
                  backgroundColor: Colors.redAccent,
                  duration: Duration(seconds: 3),
                ),
              );
            });

            List<dynamic> offlineRecipes =
                _storage.read('offlineRecipes') ?? [];

            if (offlineRecipes.isEmpty) {
              return Center(child: Text('No recipes available.'));
            }

            return _buildRecipeGrid(offlineRecipes, []);
          }

          return StreamBuilder<QuerySnapshot>(
            stream: recipeController.recipes.snapshots(),
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
              List<dynamic> offlineRecipes =
                  _storage.read('offlineRecipes') ?? [];
              return _buildRecipeGrid(offlineRecipes, firestoreData);
            },
          );
        },
      ),
    );
  }

  Widget _buildRecipeGrid(
      List<dynamic> offlineRecipes, List<QueryDocumentSnapshot> firestoreData) {
    final combinedRecipes = [
      ...offlineRecipes.map((recipe) => {
            'name': recipe['name'],
            'description': recipe['description'],
            'imageUrl': recipe['imageUrl'],
          }),
      ...firestoreData.map((recipe) => {
            'name': recipe['name'],
            'description': recipe['description'],
            'imageUrl': recipe['imageUrl'],
          }),
    ];

    return GridView.builder(
      padding: EdgeInsets.all(8.0),
      gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 3, // Number of columns in the grid
        crossAxisSpacing: 8.0,
        mainAxisSpacing: 8.0,
      ),
      itemCount: combinedRecipes.length,
      itemBuilder: (context, index) {
        var recipe = combinedRecipes[index];
        return GestureDetector(
          onTap: () => _showRecipeDetails(context, recipe),
          child: CachedNetworkImage(
            imageUrl: recipe['imageUrl'],
            fit: BoxFit.cover,
            placeholder: (context, url) => CircularProgressIndicator(),
            errorWidget: (context, url, error) => Icon(Icons.error),
          ),
        );
      },
    );
  }

  void _showRecipeDetails(BuildContext context, Map<String, dynamic> recipe) {
    // Ganti Dialog dengan halaman baru (full screen)
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => RecipeDetailPage(recipe: recipe),
      ),
    );
  }
}

class RecipeDetailPage extends StatelessWidget {
  final Map<String, dynamic> recipe;
  RecipeDetailPage({required this.recipe}) {
    print('RecipeDetailPage received recipe: $recipe'); // Debug print
  }
  final RecipeController recipeController = Get.put(RecipeController());

  void _deleteRecipe(BuildContext context, Map<String, dynamic> recipe) {
    final String? id = recipe['id']; // Ambil ID dari resep
    final String? imageUrl = recipe['imageUrl']; // Ambil imageUrl dari resep

    if (id == null || imageUrl == null) {
      // Menampilkan pesan kesalahan jika ID atau imageUrl tidak ada
      Get.snackbar(
        'Error',
        'Recipe ID or image URL is missing!',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return; // Return early if either ID or imageUrl is null
    }

    // Panggil fungsi deleteRecipe
    recipeController.deleteRecipe(id, imageUrl);

    // Menampilkan snack bar setelah menghapus resep
    Get.snackbar(
      'Success',
      'Recipe deleted successfully',
      backgroundColor: Colors.green,
      colorText: Colors.white,
    );

    // Kembali ke halaman sebelumnya setelah penghapusan
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(recipe['name']),
        actions: [
          PopupMenuButton<int>(
            icon: Icon(Icons.more_vert), // Ikon titik tiga
            itemBuilder: (context) => [
              PopupMenuItem<int>(value: 1, child: Text('Edit')),
              PopupMenuItem<int>(value: 2, child: Text('Delete')),
            ],
            onSelected: (value) async {
              if (value == 1) {
                // Aksi untuk Edit
                //_editRecipe(recipe);
              } else if (value == 2) {
                // Get the recipe ID and image URL with null safety
                final String? id = recipe['id'];
                final String? imageUrl = recipe['imageUrl'];

                // Check if ID exists
                if (id == null) {
                  Get.snackbar(
                    'Error',
                    'Cannot delete recipe: ID is missing',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                // Show confirmation dialog
                bool confirm = await Get.dialog(
                      AlertDialog(
                        title: Text('Delete Recipe'),
                        content: Text(
                            'Are you sure you want to delete this recipe?'),
                        actions: [
                          TextButton(
                            child: Text('Cancel'),
                            onPressed: () => Get.back(result: false),
                          ),
                          TextButton(
                            child: Text('Delete'),
                            onPressed: () => Get.back(result: true),
                          ),
                        ],
                      ),
                    ) ??
                    false;

                if (confirm) {
                  await recipeController.deleteRecipe(id, imageUrl);
                  Get.back(); // Return to previous screen
                }
              }
            },
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Column(
          children: [
            // Image at the top
            CachedNetworkImage(
              imageUrl: recipe['imageUrl'],
              fit: BoxFit.cover,
              width: double.infinity,
              height: MediaQuery.of(context).size.height * 0.5,
              placeholder: (context, url) => AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.grey[300],
                  child: Center(child: CircularProgressIndicator()),
                ),
              ),
              errorWidget: (context, url, error) => AspectRatio(
                aspectRatio: 1,
                child: Container(
                  color: Colors.grey[300],
                  child: Icon(Icons.error),
                ),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Action buttons for like, comment, etc.
                  Row(
                    children: [
                      IconButton(
                        icon: Icon(Icons.favorite_border),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.chat_bubble_outline),
                        onPressed: () {},
                      ),
                      IconButton(
                        icon: Icon(Icons.send),
                        onPressed: () {},
                      ),
                      Spacer(),
                      IconButton(
                        icon: Icon(Icons.bookmark_border),
                        onPressed: () {},
                      ),
                    ],
                  ),
                  // Likes count
                  Text(
                    '120 likes',
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                  SizedBox(height: 8),
                  // Recipe name and description
                  RichText(
                    text: TextSpan(
                      style: TextStyle(color: Colors.black),
                      children: [
                        TextSpan(
                          text: recipe['name'],
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        TextSpan(text: '  '),
                        TextSpan(
                          text: recipe['description'],
                        ),
                      ],
                    ),
                  ),
                  SizedBox(height: 16),
                  // Comments section
                  Text(
                    'View all 50 comments',
                    style: TextStyle(color: Colors.grey[600]),
                  ),
                  SizedBox(height: 16),
                  // Time ago
                  Text(
                    '2 HOURS AGO',
                    style: TextStyle(
                      color: Colors.grey[500],
                      fontSize: 12,
                    ),
                  ),
                  SizedBox(height: 16),
                  // Comment input section
                  Container(
                    padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      border: Border(
                        top: BorderSide(color: Colors.grey[300]!),
                      ),
                    ),
                    child: Row(
                      children: [
                        CircleAvatar(
                          radius: 16,
                          backgroundColor: Colors.grey[300],
                          child: Icon(
                            Icons.person,
                            color: Colors.grey[600],
                            size: 20,
                          ),
                        ),
                        SizedBox(width: 8),
                        Expanded(
                          child: TextField(
                            decoration: InputDecoration(
                              hintText: 'Add a comment...',
                              border: InputBorder.none,
                              hintStyle: TextStyle(color: Colors.grey[500]),
                            ),
                          ),
                        ),
                        TextButton(
                          onPressed: () {},
                          child: Text(
                            'Post',
                            style: TextStyle(
                              color: Colors.blue[300],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
