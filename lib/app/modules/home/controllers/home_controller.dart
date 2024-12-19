import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:get/get.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:connectivity_plus/connectivity_plus.dart';

class HomeController extends GetxController {
  // Initialize SpeechToText instance
  final stt.SpeechToText _speech = stt.SpeechToText();
  var isConnected = true.obs;

  // Reactive variables
  final count = 0.obs;
  var isListening = false.obs;
  var text = "".obs;
  bool isPermissionRequestInProgress = false;
  var query = ''.obs;

  // For Firebase permission request
  Future<void> requestFirebasePermission() async {
    // Check if another request is already in progress
    if (isPermissionRequestInProgress) {
      print('Permission request is already in progress. Please wait.');
      return;
    }

    try {
      isPermissionRequestInProgress = true;
      // Request permission
      await FirebaseMessaging.instance.requestPermission();
      print('Permission granted');
    } catch (e) {
      print('Error requesting permission: $e');
    } finally {
      isPermissionRequestInProgress = false;
    }
  }

  // For changing icon
  var iconPath = 'assets/icons/favicon.png'.obs;

  @override
  void onInit() {
    super.onInit();
    _initSpeech();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  // Initialize SpeechToText
  void _initSpeech() async {
    try {
      bool available = await _speech.initialize();
      if (!available) {
        print('Speech recognition is not available.');
      }
    } catch (e) {
      print('Error initializing speech: $e');
    }
  }

  // Check and request microphone permission
  Future<void> checkMicrophonePermission() async {
    var status = await Permission.microphone.status;
    if (!status.isGranted) {
      // If not granted, request permission
      await Permission.microphone.request();
    }
  }

  // Start listening
  void startListening() async {
    // Start listening and get the result
    isListening.value = true;
    bool available = await _speech.initialize();

    if (available) {
      _speech.listen(onResult: (result) {
        // Update query with the recognized speech
        query.value = result.recognizedWords; // Update search query
      });
    } else {
      print("Speech recognition is not available.");
    }
  }

  // Stop listening
  void stopListening() async {
    isListening.value = false;
    await _speech.stop();
  }

  // Increment counter
  void increment() => count.value++;

  // Change icon
  void changeIcon(String newIconPath) {
    iconPath.value = newIconPath;
  }
}
