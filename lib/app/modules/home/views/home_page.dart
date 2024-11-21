import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:demo_yummy/app/modules/home/views/food_cart_page.dart';
import 'package:demo_yummy/app/modules/profile/views/account_page.dart';
import 'package:demo_yummy/app/modules/recipe/views/recipe.dart';
import 'package:demo_yummy/app/modules/video/video_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:demo_yummy/app/data/services/api_services.dart';
import 'package:demo_yummy/app/data/models/recipe_model.dart';
import 'package:demo_yummy/app/modules/webview/views/recipe_webview.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController = Get.find<ProfileController>();

    final items = <Widget>[
      SvgPicture.asset('assets/home.svg', width: 40, height: 40),
      GestureDetector(
        onTap: () {
          Get.to(() => RecipeWebView(
                url: 'https://www.spoonacular.com',
              ));
        },
        child: SvgPicture.asset('assets/web.svg', width: 40, height: 40),
      ),
      GestureDetector(
        onTap: () {
          Get.to(RecipePage());
        },
        child: SvgPicture.asset('assets/Chef.svg', width: 40, height: 40),
      ),
      GestureDetector(
        onTap: () {
          Get.to(VideoPage());
        },
        child:
            SvgPicture.asset('assets/notification.svg', width: 40, height: 40),
      ),
      GestureDetector(
        onTap: () {
          Get.to(AccountPage());
        },
        child: SvgPicture.asset('assets/user.svg', width: 40, height: 40),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Food Recipes"),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: RecipeSearchDelegate(),
              );
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildGreetingSection(profileController),
              SizedBox(height: 25),
              Text(
                "Recipes",
                style: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                ),
              ),
              Expanded(
                child: FutureBuilder<List<Recipe>>(
                  future: fetchRecipes(),
                  builder: (context, snapshot) {
                    if (snapshot.connectionState == ConnectionState.waiting) {
                      return Center(child: CircularProgressIndicator());
                    } else if (snapshot.hasError) {
                      return Center(child: Text('Error: ${snapshot.error}'));
                    } else if (snapshot.hasData && snapshot.data!.isNotEmpty) {
                      return GridView.builder(
                        gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 0.8,
                        ),
                        itemCount: snapshot.data!.length,
                        shrinkWrap: true,
                        physics: NeverScrollableScrollPhysics(),
                        itemBuilder: (context, index) {
                          final recipe = snapshot.data![index];
                          return GestureDetector(
                            onTap: () {
                              if (recipe.spoonacularSourceUrl != null) {
                                Get.toNamed('/recipe-webview',
                                    arguments: recipe.spoonacularSourceUrl);
                              } else {
                                Get.snackbar('Error',
                                    'No URL available for this recipe');
                              }
                            },
                            child: FoodCard(
                              title: recipe.title ?? 'No Title',
                              imagePath:
                                  recipe.imageUrl ?? 'assets/default_image.png',
                            ),
                          );
                        },
                      );
                    } else {
                      return Center(child: Text('No data found'));
                    }
                  },
                ),
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              spreadRadius: 3,
              blurRadius: 50,
              offset: Offset(0, 10),
            ),
          ],
        ),
        child: CurvedNavigationBar(
          items: items,
          buttonBackgroundColor: Color(0xFF042628),
          backgroundColor: Colors.transparent,
        ),
      ),
    );
  }

  Widget _buildGreetingSection(ProfileController profileController) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              alignment: Alignment.center,
              height: 25,
              width: 25,
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/Sun.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            SizedBox(width: 10),
            Text(
              "Good Morning !",
              style: TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
              ),
            ),
          ],
        ),
        SizedBox(height: 5),
        Obx(() {
          return Text(
            profileController.profileName.value.isNotEmpty
                ? profileController.profileName.value
                : "No Profile",
            style: TextStyle(
              fontSize: 30,
              fontWeight: FontWeight.bold,
            ),
          );
        }),
      ],
    );
  }

  Future<List<Recipe>> fetchRecipes() async {
    try {
      return await ApiService.instance.fetchAllRecipes();
    } catch (e) {
      print('Error fetching recipes: $e');
      return [];
    }
  }
}

class RecipeSearchDelegate extends SearchDelegate {
  final HomeController homeController = Get.find<HomeController>();
  var isListening = false.obs;
  final stt.SpeechToText _speechToText = stt.SpeechToText();

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      Obx(() {
        return IconButton(
          icon: Icon(Icons.mic),
          color: isListening.value ? Colors.red : null,
          onPressed: () async {
            if (!isListening.value) {
              bool available = await _speechToText.initialize(
                onStatus: (status) => print('Status: $status'),
                onError: (error) => print('Error: $error'),
              );
              if (available) {
                isListening.value = true;
                _speechToText.listen(
                  onResult: (result) {
                    query =
                        result.recognizedWords; // Masukkan teks ke search bar
                  },
                );
              }
            } else {
              isListening.value = false;
              _speechToText.stop();
            }
          },
        );
      }),
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget? buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        close(context, null);
      },
    );
  }

  @override
  Widget buildResults(BuildContext context) {
    return FutureBuilder<List<Recipe>>(
      future: ApiService.instance.fetchAllRecipes(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return Center(child: CircularProgressIndicator());
        } else if (snapshot.hasError) {
          return Center(child: Text('Error: ${snapshot.error}'));
        } else if (snapshot.hasData) {
          final filteredRecipes = snapshot.data!
              .where((recipe) =>
                  recipe.title!.toLowerCase().contains(query.toLowerCase()))
              .toList();

          if (filteredRecipes.isEmpty) {
            return Center(child: Text('No recipes found.'));
          }

          return ListView.builder(
            itemCount: filteredRecipes.length,
            itemBuilder: (context, index) {
              final recipe = filteredRecipes[index];
              return ListTile(
                title: Text(recipe.title ?? 'No Title'),
                onTap: () {
                  if (recipe.spoonacularSourceUrl != null) {
                    Get.toNamed('/recipe-webview',
                        arguments: recipe.spoonacularSourceUrl);
                  } else {
                    Get.snackbar('Error', 'No URL available for this recipe');
                  }
                },
              );
            },
          );
        } else {
          return Center(child: Text('No recipes found.'));
        }
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    return Center(child: Text('Search for recipes'));
  }
}
