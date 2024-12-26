import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'dart:async'; // Untuk Future.delayed

class OnboardingPage extends StatefulWidget {
  @override
  _OnboardingPageState createState() => _OnboardingPageState();
}

class _OnboardingPageState extends State<OnboardingPage> {
  @override
  void initState() {
    super.initState();
    _navigateToLogin(); // Panggil fungsi untuk pindah ke halaman login setelah delay
  }

  _navigateToLogin() async {
    await Future.delayed(Duration(seconds: 3)); // Menunggu 3 detik
    Get.offNamed(
        '/login'); // Pindah ke halaman login setelah splash screen selesai
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          image: DecorationImage(
            image: AssetImage('assets/yummybg.png'),
            fit: BoxFit.cover, // Pastikan gambar memenuhi layar
          ),
        ),
        child: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ElevatedButton(
                onPressed: () {
                  Get.offNamed('/login'); // Menyambungkan ke halaman login
                },
                child: const Text('Get Started'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
