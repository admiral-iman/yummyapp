import 'package:demo_yummy/app/modules/video/video_story.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'dart:io';

class VideoPage extends StatefulWidget {
  @override
  _VideoPageState createState() => _VideoPageState();
}

class _VideoPageState extends State<VideoPage> {
  VideoPlayerController? _controller;
  final ImagePicker _picker = ImagePicker();
  final TextEditingController _textController = TextEditingController();

  // Fungsi untuk merekam video
  Future<void> _pickVideo() async {
    final XFile? video = await _picker.pickVideo(source: ImageSource.camera);

    if (video != null) {
      _controller = VideoPlayerController.file(File(video.path))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });

      _controller!.addListener(() {
        if (_controller!.value.position == _controller!.value.duration) {
          _controller!.seekTo(Duration.zero);
          _controller!.play();
        }
      });
    }
  }

  @override
  void dispose() {
    if (_controller != null) {
      _controller!.dispose();
    }
    _textController.dispose(); // Dispose text controller
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Post your cooking today'),
        actions: [
          IconButton(
            icon: Icon(Icons.camera_alt, size: 30),
            onPressed: _pickVideo,
          ),
        ],
      ),
      body: Stack(
        children: [
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment:
                  CrossAxisAlignment.start, // TextField align ke kiri
              children: <Widget>[
                _controller == null
                    ? Container()
                    : _controller!.value.isInitialized
                        ? GestureDetector(
                            onTap: () {
                              // Arahkan ke halaman Story
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) =>
                                      VideoStoryPage(controller: _controller!),
                                ),
                              );
                            },
                            child: Card(
                              elevation: 5,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(50),
                              ),
                              child: ClipOval(
                                child: Container(
                                  width: 100,
                                  height: 100,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.5),
                                      width: 3,
                                    ),
                                  ),
                                  child: ClipOval(
                                    // Apply ClipOval again
                                    child: AspectRatio(
                                      aspectRatio:
                                          _controller!.value.aspectRatio,
                                      child: VideoPlayer(_controller!),
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                        : CircularProgressIndicator(),
                SizedBox(height: 20),
                Text('Enter your caption:', style: TextStyle(fontSize: 16)),
                SizedBox(height: 8),
                TextField(
                  controller: _textController,
                  decoration: InputDecoration(
                    labelText: 'Write something...',
                    border: OutlineInputBorder(),
                  ),
                ),
              ],
            ),
          ),
          Positioned(
            top: 20,
            left: 20,
            child: ClipOval(
              child: Material(
                color: Colors.transparent, // Remove background color
              ),
            ),
          ),
        ],
      ),
    );
  }
}
