import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';

class EditRecipePage extends StatefulWidget {
  final String docId;
  final String name;
  final String description;
  final String imageUrl;

  EditRecipePage({
    required this.docId,
    required this.name,
    required this.description,
    required this.imageUrl,
  });

  @override
  _EditRecipePageState createState() => _EditRecipePageState();
}

class _EditRecipePageState extends State<EditRecipePage> {
  final TextEditingController nameController = TextEditingController();
  final TextEditingController descriptionController = TextEditingController();
  File? _image; // Untuk menyimpan gambar yang dipilih

  @override
  void initState() {
    super.initState();
    nameController.text = widget.name;
    descriptionController.text = widget.description;
  }

  // Mengubah fungsi untuk memilih gambar dari galeri atau kamera
  Future<void> _pickImage() async {
    final picker = ImagePicker();
    final pickedFile = await showDialog<XFile>(
      context: context,
      builder: (BuildContext context) => AlertDialog(
        title: Text('Select Image'),
        actions: [
          TextButton(
            onPressed: () async {
              final file = await picker.pickImage(source: ImageSource.camera);
              Navigator.pop(context, file);
            },
            child: Text('Take Photo'),
          ),
          TextButton(
            onPressed: () async {
              final file = await picker.pickImage(source: ImageSource.gallery);
              Navigator.pop(context, file);
            },
            child: Text('Choose from Gallery'),
          ),
        ],
      ),
    );

    if (pickedFile != null) {
      setState(() {
        _image = File(pickedFile.path);
      });
    }
  }

  Future<void> _updateRecipe() async {
    String? imageUrl;
    if (_image != null) {
      // Upload gambar ke Firebase Storage
      final ref = FirebaseStorage.instance
          .ref()
          .child('recipes/${DateTime.now().millisecondsSinceEpoch}.jpg');
      await ref.putFile(_image!);
      imageUrl = await ref.getDownloadURL(); // Dapatkan URL gambar
    }

    // Update dokumen di Firestore
    await FirebaseFirestore.instance
        .collection('recipes')
        .doc(widget.docId)
        .update({
      'name': nameController.text,
      'description': descriptionController.text,
      if (imageUrl != null)
        'imageUrl': imageUrl, // Update imageUrl jika ada gambar baru
    });

    Navigator.pop(context); // Kembali setelah update
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Edit Recipe'),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            children: [
              if (_image == null && widget.imageUrl.isNotEmpty)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(100), // Menambahkan border radius
                  child: Image.network(
                    widget.imageUrl,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              if (_image != null)
                ClipRRect(
                  borderRadius:
                      BorderRadius.circular(100), // Menambahkan border radius
                  child: Image.file(
                    _image!,
                    height: 200,
                    fit: BoxFit.cover,
                  ),
                ),
              SizedBox(height: 10),
              ElevatedButton(
                onPressed: _pickImage,
                child: Text('Pilih Gambar Baru'),
              ),
              SizedBox(height: 10),
              TextField(
                controller: nameController,
                decoration: InputDecoration(labelText: 'Recipe Name'),
              ),
              TextField(
                controller: descriptionController,
                decoration: InputDecoration(labelText: 'Description'),
              ),
              SizedBox(height: 20),
              ElevatedButton(
                onPressed: _updateRecipe,
                child: Text('Update Recipe'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
