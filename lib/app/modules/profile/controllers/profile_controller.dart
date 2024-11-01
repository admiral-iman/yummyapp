import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../data/models/profile_model.dart';

class ProfileController extends GetxController {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final GoogleSignIn _googleSignIn = GoogleSignIn();
  RxBool isLoading = false.obs;
  final profileName = ''.obs;
  var profiles = <Profile>[].obs;

  @override
  void onInit() {
    super.onInit();
    fetchProfile(); // Call to fetch the profile data
    fetchProfileName(); // Call to fetch the profile name
  }

  Future<void> fetchProfile() async {
    User? user = _auth.currentUser; // Mendapatkan pengguna saat ini
    if (user != null) {
      try {
        DocumentSnapshot snapshot = await _firestore
            .collection('profiles')
            .doc(user.uid)
            .get(); // Use UID instead of email

        if (snapshot.exists) {
          profiles.add(
              Profile.fromFirestore(snapshot.data() as Map<String, dynamic>));
        } else {
          print("Profile does not exist for user: ${user.uid}");
        }
      } catch (e) {
        print('Error fetching profile: $e');
      }
    }
  }

  Future<void> fetchProfileName() async {
    try {
      final userId = FirebaseAuth.instance.currentUser?.uid;
      if (userId == null) {
        profileName.value =
            'No Profile'; // Tampilkan pesan jika tidak ada ID pengguna
        return;
      }

      DocumentSnapshot snapshot =
          await _firestore.collection('profiles').doc(userId).get();

      if (snapshot.exists) {
        final data = snapshot.data() as Map<String, dynamic>;
        profileName.value = data['name'] ?? '';
      } else {
        profileName.value = 'No Profile';
      }
    } catch (e) {
      print('Error fetching profile name: $e');
      profileName.value = 'Error fetching name';
    }
  }

  void addProfile(Profile profile) {
    profiles.add(profile);
  }

  Future<void> registerUser(
      String email, String password, Profile profile) async {
    if (email.isEmpty || password.isEmpty) {
      Get.snackbar('Error', 'Email and password cannot be empty.',
          backgroundColor: Colors.red);
      return;
    }

    try {
      isLoading.value = true;

      UserCredential userCredential =
          await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      String uid = userCredential.user!.uid;

      await _firestore.collection('profiles').doc(uid).set({
        'name': profile.nama,
        'email': profile.email,
        'birthDate': profile.birthDate,
        'gender': profile.gender,
        'imagePath': profile.imagePath.path, // Menggunakan path dari File
      }, SetOptions(merge: true));

      Get.snackbar('Success', 'Profile successfully created',
          backgroundColor: Colors.green);
      Get.toNamed('/login');
    } on FirebaseAuthException catch (e) {
      if (e.code == 'weak-password') {
        Get.snackbar('Error', 'The password provided is too weak.',
            backgroundColor: Colors.red);
      } else if (e.code == 'email-already-in-use') {
        Get.snackbar('Error', 'The account already exists for that email.',
            backgroundColor: Colors.red);
      } else {
        Get.snackbar('Error', 'An error occurred: ${e.message}',
            backgroundColor: Colors.red);
      }
    } catch (error) {
      Get.snackbar('Error', 'Profile creation failed: $error',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }

  Future<void> googleSignIn() async {
    try {
      isLoading.value = true;
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();

      if (googleUser == null) {
        Get.snackbar('Error', 'Google sign-in was canceled.',
            backgroundColor: Colors.red);
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;
      final AuthCredential credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      UserCredential userCredential =
          await _auth.signInWithCredential(credential);

      if (userCredential.additionalUserInfo?.isNewUser ?? false) {
        await _firestore
            .collection('profiles')
            .doc(userCredential.user!.uid)
            .set({
          'name': userCredential.user!.displayName ?? 'Anonymous',
          'email': userCredential.user!.email,
          'birthDate': '',
          'gender': '',
          'imagePath': '',
        });
      }

      Get.snackbar('Success', 'Logged in successfully',
          backgroundColor: Colors.green);
      Get.offNamed('/home');
    } on FirebaseAuthException catch (e) {
      Get.snackbar('Error', 'Google sign-in failed: ${e.message}',
          backgroundColor: Colors.red);
    } catch (e) {
      Get.snackbar('Error', 'An unexpected error occurred: $e',
          backgroundColor: Colors.red);
    } finally {
      isLoading.value = false;
    }
  }
}
