import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/audio_controller.dart';

class AudioPlayerView extends StatelessWidget {
  final AudioPlayerController audioController =
      Get.put(AudioPlayerController());

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> audioList = [
      {
        'title': 'Audio 1',
        'url':
            'https://drive.google.com/uc?export=download&id=1Lsb00oj6NcH3oYzeZHNBBTRfFot7flSq',
      },
      {
        'title': 'Audio 2',
        'url':
            'https://drive.google.com/uc?export=download&id=1t4VdWhGeELLHqYFBGNy5hNKxHuo8ndyz',
      },
      {
        'title': 'Audio 3',
        'url': 'https://www.soundhelix.com/examples/mp3/SoundHelix-Song-7.mp3',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text("Online Audio Player"),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Obx(() => Text(
                  audioController.isPlaying.value
                      ? "Now Playing: ${audioController.currentAudioUrl.value}"
                      : "No Audio Playing",
                  style: const TextStyle(fontSize: 16),
                  textAlign: TextAlign.center,
                )),
            const SizedBox(height: 20),
            Expanded(
              child: ListView.builder(
                itemCount: audioList.length,
                itemBuilder: (context, index) {
                  final audio = audioList[index];
                  return Card(
                    elevation: 3,
                    margin: const EdgeInsets.symmetric(vertical: 8.0),
                    child: ListTile(
                      leading: Icon(Icons.music_note, color: Colors.blue),
                      title: Text(
                        audio['title']!,
                        style: const TextStyle(fontSize: 16),
                      ),
                      trailing: IconButton(
                        icon: const Icon(Icons.play_arrow),
                        onPressed: () {
                          audioController.playAudio(audio['url']!);
                        },
                      ),
                    ),
                  );
                },
              ),
            ),
            Obx(() => audioController.isPlaying.value
                ? ElevatedButton(
                    onPressed: audioController.stopAudio,
                    child: const Text("Stop Audio"),
                  )
                : ElevatedButton(
                    onPressed: null,
                    child: const Text("Stop Audio"),
                  )),
          ],
        ),
      ),
    );
  }
}
