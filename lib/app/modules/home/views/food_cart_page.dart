import 'package:flutter/material.dart';

class FoodCard extends StatelessWidget {
  final String title;
  final String imagePath; // URL gambar
  final String author;
  final String profileImagePath;
  final bool showProfileImage;

  FoodCard({
    required this.title,
    required this.imagePath,
    required this.author,
    required this.profileImagePath,
    this.showProfileImage = true,
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
                    SizedBox(height: 8.0),
                    if (showProfileImage)
                      Row(
                        children: [
                          CircleAvatar(
                            radius: 12.0,
                            backgroundImage: AssetImage(profileImagePath),
                          ),
                          SizedBox(width: 8.0),
                          Text(
                            author,
                            style: TextStyle(fontSize: 12.0),
                          ),
                        ],
                      )
                    else
                      Text(
                        author,
                        style: TextStyle(fontSize: 12.0),
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
