import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final String title;
  final String imagePath; // URL gambar

  FoodCard({
    required this.title,
    required this.imagePath,
  });

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: EdgeInsets.all(8.0),
      color: Colors.white,
      child: InkWell(
        onTap: () {
          // Action when the card is tapped
        },
        child: SingleChildScrollView(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                height: 120,
                decoration: BoxDecoration(
                  image: DecorationImage(
                    image: imagePath.isNotEmpty
                        ? NetworkImage(imagePath) // Menggunakan NetworkImage
                        : AssetImage('assets/default_image.png')
                            as ImageProvider, // Gambar default
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      title,
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 16.0,
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
