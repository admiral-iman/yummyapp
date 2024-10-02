import 'package:flutter/material.dart';
import 'package:get/get.dart';

class HomePage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Home')),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/menu-recipe');
              },
              child: Text('View Recipes'),
            ),
            ElevatedButton(
              onPressed: () {
                Get.toNamed('/upload-recipe');
              },
              child: Text('Upload Recipe'),
            ),
          ],
        ),
      ),
    );
  }
}
