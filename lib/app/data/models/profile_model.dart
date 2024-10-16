// recipe_model.dart
import 'dart:io';

class Profile {
  String nama;
  String email;
  String birthDate; // Tambahkan ini
  String gender; // Tambahkan ini
  final File imagePath;

  Profile({
    required this.nama,
    required this.email,
    required this.birthDate, // Tambahkan ini
    required this.gender, // Tambahkan ini
    required this.imagePath,
  });
}
