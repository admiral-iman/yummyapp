import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoStoryPage extends StatelessWidget {
  final VideoPlayerController controller;

  VideoStoryPage({required this.controller});

  @override
  Widget build(BuildContext context) {
    // Mendapatkan ukuran layar
    final size = MediaQuery.of(context).size;

    // Menghitung tinggi berdasarkan rasio 9:16
    final height = size.width * 16 / 9;

    return Scaffold(
      appBar: AppBar(
        title: Text('Video Story'),
      ),
      body: Center(
        child: Column(
          children: <Widget>[
            SizedBox(height: 20),
            Container(
              width: size.width, // Mengisi lebar layar
              height: height, // Menghitung tinggi berdasarkan rasio 9:16
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(20),
                border:
                    Border.all(color: Colors.grey.withOpacity(0.5), width: 3),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: VideoPlayer(controller),
              ),
            ),
            SizedBox(height: 20),
            ElevatedButton(
              onPressed: () {
                // Tombol untuk kembali ke halaman sebelumnya
                Navigator.pop(context);
              },
              child: Text('Back to Video Page'),
            ),
          ],
        ),
      ),
    );
  }
}
