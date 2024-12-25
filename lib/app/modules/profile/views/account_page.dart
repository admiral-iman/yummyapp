import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:demo_yummy/app/data/models/profile_model.dart';
import 'package:demo_yummy/app/modules/recipe/controllers/recipe_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';
import '../controllers/profile_controller.dart';
import 'package:image_picker/image_picker.dart';
import 'package:video_player/video_player.dart';
import 'package:audioplayers/audioplayers.dart';
import 'dart:io';
import 'dart:async';

class StoryItem {
  final File media;
  final bool isVideo;
  final String? audioPath;
  final DateTime timestamp;
  bool isValidImage = true;

  StoryItem({
    required this.media,
    this.isVideo = false,
    this.audioPath,
    DateTime? timestamp,
  }) : timestamp = timestamp ?? DateTime.now() {
    if (!isVideo) {
      _validateImage();
    }
  }

  Future<void> _validateImage() async {
    try {
      final bytes = await media.readAsBytes();
      final decodedImage = await decodeImageFromList(bytes);
      isValidImage = decodedImage != null;
    } catch (e) {
      print('Error validating image: $e');
      isValidImage = false;
    }
  }
}

class AccountPage extends StatefulWidget {
  @override
  _AccountPage createState() => _AccountPage();
}

class _AccountPage extends State<AccountPage> {
  final ProfileController profileController = Get.put(ProfileController());
  final RecipeController recipeController = Get.put(RecipeController());
  final CollectionReference recipes =
      FirebaseFirestore.instance.collection('recipes');
  final GetStorage _storage = GetStorage();
  final ImagePicker _picker = ImagePicker();
  bool isConnected = true;
  List<StoryItem> stories = [];

  @override
  void initState() {
    super.initState();
    recipeController.isInternetAvailable().then((connected) {
      setState(() {
        isConnected = connected;
      });
      if (connected) {
        recipeController.uploadOfflineRecipes();
      }
    });
  }

  Future<void> _addStory() async {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 250,
        child: Column(
          children: [
            ListTile(
              leading: Icon(Icons.camera_alt),
              title: Text('Take Photo'),
              onTap: () => _pickMedia(ImageSource.camera, false),
            ),
            ListTile(
              leading: Icon(Icons.videocam),
              title: Text('Record Video'),
              onTap: () => _pickMedia(ImageSource.camera, true),
            ),
            ListTile(
              leading: Icon(Icons.photo_library),
              title: Text('Choose from Gallery'),
              onTap: () => _pickMedia(ImageSource.gallery, false),
            ),
            ListTile(
              leading: Icon(Icons.video_library),
              title: Text('Video from Gallery'),
              onTap: () => _pickMedia(ImageSource.gallery, true),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickMedia(ImageSource source, bool isVideo) async {
    Navigator.pop(context);
    try {
      final XFile? media = isVideo
          ? await _picker.pickVideo(source: source)
          : await _picker.pickImage(
              source: source,
              maxWidth: 1920, // Add reasonable max dimensions
              maxHeight: 1920,
              imageQuality: 85, // Add image quality compression
            );

      if (media != null) {
        if (!isVideo) {
          // Validate image before preview
          try {
            final bytes = await File(media.path).readAsBytes();
            await decodeImageFromList(bytes);
          } catch (e) {
            print('Error validating picked image: $e');
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                  content:
                      Text('Invalid image format. Please try another image.')),
            );
            return;
          }
        }

        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => StoryPreview(
              media: File(media.path),
              isVideo: isVideo,
              onSave: (media, isVideo, audioPath) {
                setState(() {
                  stories.add(StoryItem(
                    media: media,
                    isVideo: isVideo,
                    audioPath: audioPath,
                  ));
                });
                Navigator.pop(context);
              },
            ),
          ),
        );
      }
    } catch (e) {
      print('Error picking media: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error selecting media. Please try again.')),
      );
    }
  }

  Widget _buildProfileImage(Profile profile) {
    return GestureDetector(
      onTap: () {
        if (stories.isNotEmpty) {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => StoryViewer(
                stories: stories,
                onClose: () => Navigator.pop(context),
              ),
            ),
          );
        }
      },
      child: Stack(
        children: [
          CircularProfileAvatar(
            '',
            radius: 40,
            backgroundColor: Colors.blue[100]!,
            borderWidth: 3,
            borderColor: stories.isNotEmpty ? Colors.orange : Colors.grey[300]!,
            elevation: 5.0,
            child: profile.imagePath.path.isNotEmpty
                ? ClipOval(
                    child: Image.file(
                      profile.imagePath,
                      fit: BoxFit.cover,
                      width: 500,
                      height: 500,
                      errorBuilder: (context, error, stackTrace) {
                        return Icon(Icons.error,
                            size: 40, color: Colors.red[300]);
                      },
                    ),
                  )
                : Icon(Icons.person, size: 40, color: Colors.blue[600]),
          ),
          Positioned(
            right: 0,
            bottom: 0,
            child: GestureDetector(
              onTap: _addStory,
              child: Container(
                padding: EdgeInsets.all(4),
                decoration: BoxDecoration(
                  color: Colors.blue,
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 2),
                ),
                child: Icon(Icons.add, size: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatColumn(String label, String value) {
    return Column(
      children: [
        Text(
          value,
          style: TextStyle(
            fontSize: 20,
            fontWeight: FontWeight.bold,
            color: Colors.orange,
          ),
        ),
        Text(
          label,
          style: TextStyle(
            color: Colors.grey[600],
            fontSize: 12,
          ),
        ),
      ],
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 20, color: Colors.blue[400]),
        SizedBox(width: 8),
        Text(
          '$label: ',
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: Colors.grey[600],
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            color: Colors.grey[800],
          ),
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title:
            Text('Your Profile', style: TextStyle(fontWeight: FontWeight.w600)),
        elevation: 0,
        backgroundColor: Colors.orange,
        actions: [
          IconButton(
            icon: Icon(Icons.logout),
            onPressed: () => Get.offNamed('/login'),
            tooltip: 'Logout',
          )
        ],
      ),
      body: Container(
        color: Colors.grey[100],
        child: Obx(() {
          if (profileController.profiles.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.person_off, size: 64, color: Colors.grey),
                  SizedBox(height: 16),
                  Text(
                    "No profiles available.",
                    style: TextStyle(fontSize: 18, color: Colors.grey[600]),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: EdgeInsets.all(16),
            itemCount: profileController.profiles.length,
            itemBuilder: (context, index) {
              final profile = profileController.profiles[index];
              return Card(
                elevation: 3,
                margin: EdgeInsets.only(bottom: 16),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Column(
                  children: [
                    Padding(
                      padding: EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Row(
                            children: [
                              _buildProfileImage(profile),
                              SizedBox(width: 20),
                              Expanded(
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  children: [
                                    _buildStatColumn('Posts', '0'),
                                    _buildStatColumn('Followers', '0'),
                                    _buildStatColumn('Following', '0'),
                                  ],
                                ),
                              ),
                            ],
                          ),
                          SizedBox(height: 16),
                          Text(
                            profile.nama,
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.blue[900],
                            ),
                          ),
                          Text(
                            profile.email,
                            style: TextStyle(
                              fontSize: 14,
                              color: Colors.grey[600],
                            ),
                          ),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              Get.toNamed('/editProfile', arguments: profile);
                            },
                            style: ElevatedButton.styleFrom(
                              primary: Colors.white,
                              onPrimary: Colors.black87,
                              minimumSize: Size(double.infinity, 36),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(4),
                                side: BorderSide(color: Colors.grey[300]!),
                              ),
                            ),
                            child: Text('Edit Profile'),
                          ),
                          Divider(height: 24),
                          _buildInfoRow(Icons.cake, 'Birth Date',
                              profile.birthDate.toString()),
                          SizedBox(height: 8),
                          _buildInfoRow(
                              Icons.person_outline, 'Gender', profile.gender),
                        ],
                      ),
                    ),
                    Container(
                      height: 50,
                      decoration: BoxDecoration(
                        border:
                            Border(top: BorderSide(color: Colors.grey[200]!)),
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                        children: [
                          InkWell(
                            onTap: () {
                              Get.toNamed('/postsPage');
                            },
                            child: Icon(Icons.grid_on, color: Colors.orange),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        }),
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.toNamed('/create-recipe');
        },
        backgroundColor: Colors.orange,
        child: Icon(Icons.add, color: Colors.white),
        tooltip: 'Add Post',
      ),
    );
  }
}

class StoryViewer extends StatefulWidget {
  final List<StoryItem> stories;
  final VoidCallback onClose;

  StoryViewer({required this.stories, required this.onClose});

  @override
  _StoryViewerState createState() => _StoryViewerState();
}

class _StoryViewerState extends State<StoryViewer> {
  int currentIndex = 0;
  VideoPlayerController? _videoController;
  AudioPlayer? _audioPlayer;
  Timer? _timer;
  double progress = 0.0;
  bool isPaused = false;
  bool isAudioInitialized = false;
  bool _isDisposed = false;

  @override
  void initState() {
    super.initState();
    if (widget.stories.isNotEmpty) {
      _loadStory(currentIndex);
    }
  }

  void _loadStory(int index) async {
    if (_isDisposed) return;

    if (index >= widget.stories.length) {
      if (!_isDisposed) {
        widget.onClose();
      }
      return;
    }

    // Reset state
    if (!_isDisposed) {
      setState(() {
        progress = 0.0;
        isPaused = false;
        isAudioInitialized = false;
      });
    }

    final story = widget.stories[index];

    // Handle video content first
    if (story.isVideo) {
      await _initializeVideo(story);
      // Initialize audio after video if available
      if (story.audioPath != null) {
        await _initializeAudioForVideo(story.audioPath!);
      }
    } else {
      // For images
      await _videoController?.dispose();
      _videoController = null;

      if (story.audioPath != null) {
        await _initializeAudio(story.audioPath!);
      }

      if (!_isDisposed) {
        _startTimer(5000);
        // Start audio playback for images
        if (_audioPlayer != null) {
          _audioPlayer!.play(DeviceFileSource(story.audioPath!));
        }
      }
    }
  }

  Future<void> _initializeVideo(StoryItem story) async {
    if (_isDisposed) return;

    try {
      await _videoController?.dispose();
      _videoController = VideoPlayerController.file(story.media);
      await _videoController!.initialize();

      final videoDuration = _videoController!.value.duration;
      final actualDuration = videoDuration.inMilliseconds > 30000
          ? 30000
          : videoDuration.inMilliseconds;

      if (!_isDisposed) {
        setState(() {});
        _startTimer(actualDuration);
      }
    } catch (e) {
      print('Error initializing video: $e');
      _nextStory();
    }
  }

  Future<void> _initializeAudio(String audioPath) async {
    if (_isDisposed) return;

    try {
      await _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setSourceUrl(audioPath);

      if (!_isDisposed) {
        setState(() {
          isAudioInitialized = true;
        });
      }
    } catch (e) {
      print('Error initializing audio: $e');
      _audioPlayer = null;
    }
  }

  Future<void> _initializeAudioForVideo(String audioPath) async {
    if (_isDisposed) return;

    try {
      await _audioPlayer?.dispose();
      _audioPlayer = AudioPlayer();
      await _audioPlayer!.setSourceUrl(audioPath);

      if (!_isDisposed) {
        setState(() {
          isAudioInitialized = true;
        });

        // Start both video and audio together
        _videoController?.play();
        _audioPlayer!.play(DeviceFileSource(audioPath));
      }
    } catch (e) {
      print('Error initializing audio: $e');
      // Continue playing video even if audio fails
      _videoController?.play();
    }
  }

  void _startTimer(int duration) {
    _timer?.cancel();
    if (!_isDisposed) {
      setState(() => progress = 0.0);

      const updateInterval = Duration(milliseconds: 50);
      final increment = 50.0 / duration;

      _timer = Timer.periodic(updateInterval, (timer) {
        if (_isDisposed) {
          timer.cancel();
          return;
        }

        if (!isPaused) {
          setState(() {
            progress += increment;
            if (progress >= 1.0) {
              _nextStory();
            }
          });
        }
      });
    }
  }

  void _togglePlayPause() {
    if (!_isDisposed) {
      setState(() {
        isPaused = !isPaused;
        if (isPaused) {
          _videoController?.pause();
          _audioPlayer?.pause();
        } else {
          _videoController?.play();
          _audioPlayer?.resume();
        }
      });
    }
  }

  void _nextStory() {
    _timer?.cancel();
    if (!_isDisposed && currentIndex < widget.stories.length - 1) {
      setState(() {
        currentIndex++;
        _loadStory(currentIndex);
      });
    } else if (!_isDisposed) {
      widget.onClose();
    }
  }

  void _previousStory() {
    _timer?.cancel();
    if (!_isDisposed && currentIndex > 0) {
      setState(() {
        currentIndex--;
        _loadStory(currentIndex);
      });
    }
  }

  @override
  void dispose() {
    _isDisposed = true;
    _timer?.cancel();
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (widget.stories.isEmpty) {
      return const SizedBox.shrink();
    }

    return Scaffold(
      backgroundColor: Colors.black,
      body: GestureDetector(
        onTapDown: (details) {
          final screenWidth = MediaQuery.of(context).size.width;
          if (details.globalPosition.dx < screenWidth / 3) {
            _previousStory();
          } else if (details.globalPosition.dx > screenWidth * 2 / 3) {
            _nextStory();
          } else {
            _togglePlayPause();
          }
        },
        child: Stack(
          children: [
            Center(
              child: widget.stories[currentIndex].isVideo &&
                      _videoController != null
                  ? AspectRatio(
                      aspectRatio: _videoController!.value.aspectRatio,
                      child: VideoPlayer(_videoController!),
                    )
                  : Image.file(
                      widget.stories[currentIndex].media,
                      fit: BoxFit.contain,
                      errorBuilder: (context, error, stackTrace) {
                        print('Error loading image: $error');
                        return Container(
                          color: Colors.grey[900],
                          child: const Center(
                            child: Icon(
                              Icons.broken_image,
                              color: Colors.white54,
                              size: 64,
                            ),
                          ),
                        );
                      },
                    ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 10,
              left: 10,
              right: 10,
              child: Row(
                children: List.generate(
                  widget.stories.length,
                  (index) => Expanded(
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      decoration: BoxDecoration(
                        color: Colors.grey.withOpacity(0.5),
                      ),
                      child: FractionallySizedBox(
                        alignment: Alignment.centerLeft,
                        widthFactor: index == currentIndex
                            ? progress
                            : index < currentIndex
                                ? 1.0
                                : 0.0,
                        child: Container(color: Colors.white),
                      ),
                    ),
                  ),
                ),
              ),
            ),
            Positioned(
              top: MediaQuery.of(context).padding.top + 20,
              left: 10,
              right: 10,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  if (widget.stories[currentIndex].audioPath != null)
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.5),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Row(
                        children: const [
                          Icon(Icons.music_note, color: Colors.white, size: 16),
                          SizedBox(width: 4),
                          Text(
                            'Playing music',
                            style: TextStyle(color: Colors.white, fontSize: 12),
                          ),
                        ],
                      ),
                    ),
                  IconButton(
                    icon: const Icon(Icons.close, color: Colors.white),
                    onPressed: widget.onClose,
                  ),
                ],
              ),
            ),
            if (isPaused)
              Center(
                child: Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.5),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.pause, color: Colors.white, size: 32),
                ),
              ),
          ],
        ),
      ),
    );
  }
}

class StoryPreview extends StatefulWidget {
  final File media;
  final bool isVideo;
  final Function(File media, bool isVideo, String? audioPath) onSave;

  StoryPreview({
    required this.media,
    required this.isVideo,
    required this.onSave,
  });

  @override
  _StoryPreviewState createState() => _StoryPreviewState();
}

class _StoryPreviewState extends State<StoryPreview> {
  VideoPlayerController? _videoController;
  String? selectedAudioPath;
  AudioPlayer? _audioPlayer;
  bool isPlaying = false;
  Duration videoDuration = Duration.zero;

  final List<Map<String, String>> localAudios = [
    {
      'title': 'Happy Music',
      'path':
          'https://drive.google.com/uc?export=download&id=1Lsb00oj6NcH3oYzeZHNBBTRFot7flSq'
    },
    {
      'title': 'Energetic Beat',
      'path':
          'https://drive.google.com/uc?export=download&id=1t4VdWhGeELLHqYFBGNy5hNKxHuo8ndyz'
    },
    {
      'title': 'Calm Melody',
      'path': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3'
    },
  ];

  @override
  void initState() {
    super.initState();
    if (widget.isVideo) {
      _initializeVideo();
    }
  }

  Future<void> _initializeVideo() async {
    _videoController = VideoPlayerController.file(widget.media);
    await _videoController!.initialize();

    // Check video duration
    videoDuration = _videoController!.value.duration;
    if (videoDuration.inSeconds > 30) {
      // Show warning dialog
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: Text('Video Too Long'),
          content: Text('Please select a video that is 30 seconds or shorter.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.pop(context); // Close dialog
                Navigator.pop(context); // Return to previous screen
              },
              child: Text('OK'),
            ),
          ],
        ),
      );
    } else {
      setState(() {
        _videoController!.play();
      });
    }
  }

  void _playAudio(String audioPath) async {
    _audioPlayer?.dispose();
    _audioPlayer = AudioPlayer();

    try {
      await _audioPlayer!.setSourceUrl(audioPath);
      Duration? audioDuration = await _audioPlayer!.getDuration();

      if (audioDuration != null && audioDuration.inSeconds > 30) {
        // Limit audio playback to 30 seconds
        _audioPlayer!.setReleaseMode(ReleaseMode.stop);
        Future.delayed(Duration(seconds: 30), () {
          _audioPlayer?.stop();
        });
      }

      setState(() {
        selectedAudioPath = audioPath;
        isPlaying = true;
      });

      await _audioPlayer!.play(UrlSource(audioPath));

      _audioPlayer!.onPlayerComplete.listen((_) {
        setState(() {
          isPlaying = false;
        });
      });
    } catch (e) {
      print('Error playing audio: $e');
    }
  }

  void _stopAudio() {
    _audioPlayer?.stop();
    setState(() {
      isPlaying = false;
    });
  }

  void _showAudioSelector() {
    showModalBottomSheet(
      context: context,
      builder: (context) => Container(
        height: 300,
        padding: EdgeInsets.all(16),
        child: Column(
          children: [
            Text(
              'Select Audio (Max 30 seconds)',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            SizedBox(height: 16),
            Expanded(
              child: ListView.builder(
                itemCount: localAudios.length,
                itemBuilder: (context, index) {
                  final audio = localAudios[index];
                  final bool isSelected = audio['path'] == selectedAudioPath;
                  return ListTile(
                    leading: Icon(Icons.music_note),
                    title: Text(audio['title']!),
                    trailing: IconButton(
                      icon: Icon(
                        isSelected && isPlaying ? Icons.stop : Icons.play_arrow,
                      ),
                      onPressed: () {
                        if (isSelected && isPlaying) {
                          _stopAudio();
                        } else {
                          _playAudio(audio['path']!);
                        }
                      },
                    ),
                    selected: isSelected,
                    onTap: () {
                      setState(() {
                        selectedAudioPath = audio['path'];
                      });
                      Navigator.pop(context);
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.close),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: Icon(selectedAudioPath != null
                ? Icons.music_note
                : Icons.music_note_outlined),
            onPressed: _showAudioSelector,
          ),
          if (!widget.isVideo || (videoDuration.inSeconds <= 30))
            IconButton(
              icon: Icon(Icons.check),
              onPressed: () => widget.onSave(
                  widget.media, widget.isVideo, selectedAudioPath),
            ),
        ],
      ),
      body: Center(
        child: widget.isVideo && _videoController != null
            ? AspectRatio(
                aspectRatio: _videoController!.value.aspectRatio,
                child: VideoPlayer(_videoController!),
              )
            : Image.file(widget.media),
      ),
    );
  }

  @override
  void dispose() {
    _videoController?.dispose();
    _audioPlayer?.dispose();
    super.dispose();
  }
}
