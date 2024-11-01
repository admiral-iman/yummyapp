// recipe_model.dart
import 'dart:io';

class Profile {
  String nama;
  String email;
  String birthDate;
  String gender;
  final File imagePath;

  Profile({
    required this.nama,
    required this.email,
    required this.birthDate,
    required this.gender,
    required this.imagePath,
  });

  factory Profile.fromFirestore(Map<String, dynamic> data) {
    return Profile(
      nama: data['name'] ?? '',
      email: data['email'] ?? '',
      birthDate: data['birthDate'] ?? '',
      gender: data['gender'] ?? '',
      imagePath: File(data['imagePath'] ?? ''),
    );
  }
}
