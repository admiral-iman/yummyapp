import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../controllers/profile_controller.dart';

class LoginPage extends StatefulWidget {
  @override
  _LoginPageState createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final FirebaseAuth _auth = FirebaseAuth.instance;
  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.find<ProfileController>();
  }

  Future<void> _login() async {
    final email = emailController.text.trim();
    final password = passwordController.text.trim();

    // Periksa apakah email dan password tidak kosong
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar(
        "Error",
        "Email and password cannot be empty",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
      return;
    }

    // Lakukan login
    try {
      final UserCredential userCredential =
          await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      if (userCredential.user != null) {
        // Login berhasil, arahkan ke halaman home
        Get.offNamed('/home');
      }
    } catch (e) {
      // Jika ada kesalahan saat login, tampilkan pesan kesalahan
      Get.snackbar(
        "Error",
        "Login failed. Please check your email and password.",
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            TextField(
              controller: emailController,
              decoration: InputDecoration(labelText: 'Email'),
            ),
            TextField(
              controller: passwordController,
              decoration: InputDecoration(labelText: 'Password'),
              obscureText: true,
            ),
            SizedBox(height: 16),
            ElevatedButton(
              onPressed: _login,
              child: Text('Login'),
            ),
            SizedBox(height: 16),
            TextButton(
              onPressed: () {
                Get.toNamed('/createProfile');
              },
              child: Text('Don\'t have an account? Create one'),
            ),
            SizedBox(height: 16),
            ElevatedButton.icon(
              onPressed: () async {
                await profileController
                    .googleSignIn(); // Integrasi login Google
              },
              icon: Image.asset(
                'assets/google.png',
                height: 24,
                width: 24,
              ),
              label: Text("Login with Google"),
              style: ElevatedButton.styleFrom(
                primary: Colors.white,
                onPrimary: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
