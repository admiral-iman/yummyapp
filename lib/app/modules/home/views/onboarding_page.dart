import 'package:flutter/material.dart';
import 'package:get/get.dart';

class OnboardingPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Menggunakan BoxDecoration untuk menambahkan gambar sebagai latar belakang
        child: Stack(
          children: [
            Container(
              decoration: BoxDecoration(
                image: DecorationImage(
                  image: AssetImage('assets/yummybg.png'),
                  fit: BoxFit.cover,
                ),
              ),
            ),
            // Overlay semi-transparan

            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(height: 600),
                  ElevatedButton(
                    onPressed: () {
                      Get.offNamed('/home');
                    },
                    child: Text('Get Started'),
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
