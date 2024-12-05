import 'package:audioplayers/audioplayers.dart';
import 'package:get/get.dart';

class AudioPlayerController extends GetxController {
  final AudioPlayer _audioPlayer = AudioPlayer();
  var isPlaying = false.obs; // Status apakah audio sedang dimainkan
  var currentAudioUrl = ''.obs; // URL audio yang sedang dimainkan

  @override
  void onClose() {
    _audioPlayer.dispose();
    super.onClose();
  }

  // Memutar audio dari URL
  Future<void> playAudio(String url) async {
    try {
      // Jika audio baru, set source dan mulai memutar
      if (currentAudioUrl.value != url) {
        await _audioPlayer.setSource(UrlSource(url)); // Menggunakan UrlSource
        currentAudioUrl.value = url;
      }

      // Memulai pemutaran audio dengan PlayerMode
      await _audioPlayer.play(UrlSource(url)); // Menambahkan UrlSource
      isPlaying.value = true;
    } catch (e) {
      Get.snackbar('Error', 'Failed to play audio: $e');
    }
  }

  // Menghentikan audio
  Future<void> stopAudio() async {
    try {
      await _audioPlayer.stop();
      isPlaying.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to stop audio: $e');
    }
  }

  // Pause audio
  Future<void> pauseAudio() async {
    try {
      await _audioPlayer.pause();
      isPlaying.value = false;
    } catch (e) {
      Get.snackbar('Error', 'Failed to pause audio: $e');
    }
  }
}
