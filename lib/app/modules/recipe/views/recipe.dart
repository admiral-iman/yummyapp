import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_yummy/app/modules/recipe/controllers/recipe_controller.dart';
import 'package:demo_yummy/app/modules/recipe/views/edit_recipe.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'create_recipe.dart';

class RecipePage extends StatelessWidget {
  final RecipeController recipeController = Get.put(RecipeController());
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');

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
      body: StreamBuilder<QuerySnapshot>(
        stream: recipes.snapshots(),
        builder: (context, snapshot) {
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          }

          final data = snapshot.data!.docs;

          return ListView.builder(
            itemCount: data.length,
            itemBuilder: (context, index) {
              var recipe = data[index];
              var imageUrl = recipe['imageUrl'];

              return Card(
                child: ListTile(
                  leading: recipe['imageUrl'] != null
                      ? Image.network(recipe['imageUrl'],
                          width: 50, height: 50, fit: BoxFit.cover)
                      : Icon(Icons.image),
                  title: Text(recipe['name']),
                  subtitle: Text(recipe['description']),
                  trailing: IconButton(
                    icon: Icon(Icons.delete),
                    onPressed: () async {
                      await recipeController.deleteItem(recipe.id, imageUrl);
                    },
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => EditRecipePage(
                          docId: recipe.id,
                          name: recipe['name'],
                          description: recipe['description'],
                          imageUrl: recipe['imageUrl'], // Jika perlu
                        ),
                      ),
                    );
                    // Navigasi ke halaman detail jika diperlukan
                  },
                ),
              );
            },
          );
        },
      ),
    );
  }
}
