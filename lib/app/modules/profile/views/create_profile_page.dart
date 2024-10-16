import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import '../controllers/profile_controller.dart';
import '../../../data/models/profile_model.dart'; // Import model Recipe

class CreateProfilePage extends StatefulWidget {
  @override
  _CreateProfilePageState createState() => _CreateProfilePageState();
}

class _CreateProfilePageState extends State<CreateProfilePage> {
  File? _image;
  final picker = ImagePicker();
  final nameController = TextEditingController();
  final emailController = TextEditingController();
  final birthDateController = TextEditingController();
  String? selectedGender;

  late ProfileController profileController;

  @override
  void initState() {
    super.initState();
    profileController = Get.find<ProfileController>();
  }

  Future<void> _pickImage() async {
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    setState(() {
      if (pickedFile != null) {
        _image = File(pickedFile.path);
      }
    });
  }

  // Widget untuk memilih tanggal
  Future<void> _selectDate(BuildContext context) async {
    DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime(1900),
      lastDate: DateTime(2101),
    );
    if (picked != null) {
      setState(() {
        birthDateController.text =
            "${picked.day}/${picked.month}/${picked.year}";
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Create Profile')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          // Tambahkan SingleChildScrollView agar bisa di-scroll
          child: Column(
            children: [
              GestureDetector(
                onTap: _pickImage,
                child: Container(
                  height: 200, // Sesuaikan dengan tinggi yang diinginkan
                  width: 200, // Sesuaikan dengan lebar yang diinginkan
                  decoration: BoxDecoration(
                    color: Colors.grey[300], // Warna latar belakang
                    borderRadius: BorderRadius.circular(100), // Sudut melingkar
                    border: Border.all(color: Colors.orange), // Garis tepi
                  ),
                  child: _image == null
                      ? Center(
                          child: Text(
                            'Add Image',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : ClipOval(
                          child: Image.file(
                            _image!,
                            fit: BoxFit.cover,
                          ),
                        ),
                ),
              ),
              SizedBox(height: 16),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: emailController,
                decoration: InputDecoration(labelText: 'Email'),
              ),
              TextField(
                controller: birthDateController,
                decoration: InputDecoration(labelText: 'Birth Date'),
                readOnly: true,
                onTap: () => _selectDate(context),
              ),
              DropdownButtonFormField<String>(
                decoration: InputDecoration(labelText: 'Gender'),
                value: selectedGender,
                items: ['Male', 'Female', 'Other'].map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(value),
                  );
                }).toList(),
                onChanged: (String? newValue) {
                  setState(() {
                    selectedGender = newValue;
                  });
                },
              ),
              ElevatedButton(
                onPressed: () {
                  // Validasi input
                  if (_image == null) {
                    Get.snackbar("Error", "Please select an image.",
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }
                  if (nameController.text.isEmpty ||
                      emailController.text.isEmpty ||
                      birthDateController.text.isEmpty ||
                      selectedGender == null) {
                    Get.snackbar("Error", "All fields are required.",
                        snackPosition: SnackPosition.BOTTOM);
                    return;
                  }

                  Profile newProfile = Profile(
                    nama: nameController.text,
                    email: emailController.text,
                    birthDate: birthDateController.text,
                    gender: selectedGender!,
                    imagePath: _image!,
                  );

                  profileController.addProfile(newProfile);

                  Get.offNamed('/home');
                },
                child: Text('Submit Profile'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
