import 'package:curved_navigation_bar/curved_navigation_bar.dart';
import 'package:demo_yummy/app/modules/profile/views/account_page.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/home_controller.dart';
import '../../profile/controllers/profile_controller.dart'; // Import ProfileController
import 'food_cart_page.dart';
import 'package:flutter_svg/flutter_svg.dart';

class HomeView extends GetView<HomeController> {
  const HomeView({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final ProfileController profileController =
        Get.find<ProfileController>(); // Dapatkan ProfileController
    final items = <Widget>[
      SvgPicture.asset('assets/home.svg', width: 40, height: 40),
      SvgPicture.asset('assets/search.svg', width: 40, height: 40),
      SvgPicture.asset('assets/Chef.svg', width: 40, height: 40),
      SvgPicture.asset('assets/notification.svg', width: 40, height: 40),
      GestureDetector(
        onTap: () {
          Get.to(AccountPage()); // Navigasi ke AccountPage
        },
        child: SvgPicture.asset('assets/user.svg', width: 40, height: 40),
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        centerTitle: true,
        title: Text("Food Recipes"), // Add a title for clarity
      ),
      body: SingleChildScrollView(
        child: SafeArea(
          child: Padding(
            padding: const EdgeInsets.all(15),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Bagian header
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
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
                        // Gunakan Obx untuk memantau perubahan pada profil
                        Obx(() {
                          if (profileController.profiles.isNotEmpty) {
                            return Text(
                              profileController.profiles[0]
                                  .nama, // Tampilkan nama profil pertama
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          } else {
                            return Text(
                              "No Profile", // Jika tidak ada profil
                              style: TextStyle(
                                fontSize: 30,
                                fontWeight: FontWeight.bold,
                              ),
                            );
                          }
                        }),
                        SizedBox(height: 25),
                        Text(
                          "Recipes",
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
                SizedBox(height: 15), // Spacing after header
                // GridView untuk menampilkan FoodCard
                GridView.count(
                  crossAxisCount: 2,
                  childAspectRatio: 0.8,
                  shrinkWrap: true, // Memungkinkan GridView untuk menyesuaikan
                  physics: NeverScrollableScrollPhysics(), // Non-scrollable
                  children: [
                    FoodCard(
                      title: "Sunny Egg &\nToast Avocado",
                      imagePath: "assets/dish1.png",
                      author: "Alice Fala",
                      profileImagePath: "assets/profile1.jpg",
                    ),
                    FoodCard(
                      title: "Bowl of noodle\nwith beef",
                      imagePath: "assets/dish2.png",
                      profileImagePath: "assets/profile2.jpg",
                      author: "James Spader",
                    ),
                    FoodCard(
                      title: "Easy homemade\nbeef burger",
                      imagePath: "assets/dish3.png",
                      profileImagePath: "assets/profile3.jpg",
                      author: "Agnes",
                    ),
                    FoodCard(
                      title: "Half boiled egg\nsandwich",
                      imagePath: "assets/dish4.png",
                      profileImagePath: "assets/profile4.jpg",
                      author: "Natalia Luca",
                    ),
                  ],
                ),
                SizedBox(height: 15),
              ],
            ),
          ),
        ),
      ),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1), // Shadow color
              spreadRadius: 3,
              blurRadius: 50,
              offset: Offset(0, 10), // Shadow position
            ),
          ],
        ),
        child: CurvedNavigationBar(
          items: items,
          buttonBackgroundColor: Color(0xFF042628),
          backgroundColor: Colors.transparent, // Transparent background
        ),
      ),
    );
  }
}
