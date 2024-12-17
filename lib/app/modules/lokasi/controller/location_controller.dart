import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:url_launcher/url_launcher.dart';

class LocationController extends GetxController {
  var currentPosition = Rx<Position?>(null); // State posisi perangkat
  var locationMessage = "Mencari koordinat...".obs; // Pesan lokasi
  var isLoading = false.obs; // Status loading

  @override
  void onInit() {
    super.onInit();
    getCurrentLocation();
  }

  // Mendapatkan lokasi perangkat
  Future<void> getCurrentLocation() async {
    bool serviceEnabled;
    LocationPermission permission;

    isLoading.value = true;
    try {
      serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        await Geolocator.openLocationSettings();
        throw Exception('Layanan lokasi tidak aktif');
      }

      permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          throw Exception('Izin lokasi ditolak');
        }
      }
      if (permission == LocationPermission.deniedForever) {
        throw Exception('Izin lokasi ditolak secara permanen');
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      currentPosition.value = position;
      locationMessage.value =
          "Latitude: ${position.latitude}, Longitude: ${position.longitude}";
    } catch (e) {
      locationMessage.value = 'Gagal mendapatkan lokasi: $e';
    } finally {
      isLoading.value = false;
    }
  }

  // Membuka Google Maps menggunakan koordinat perangkat
  Future<void> openGoogleMaps() async {
    if (currentPosition.value != null) {
      final Uri url = Uri.parse(
          'https://www.google.com/maps?q=${currentPosition.value!.latitude},${currentPosition.value!.longitude}');

      if (await canLaunchUrl(url)) {
        await launchUrl(url, mode: LaunchMode.externalApplication);
      } else {
        throw 'Tidak dapat membuka URL: $url';
      }
    }
  }

  // Membuka Google Maps menggunakan koordinat tertentu
  Future<void> openGoogleMapsWithCoordinates(
      double latitude, double longitude) async {
    final Uri url =
        Uri.parse('https://www.google.com/maps?q=$latitude,$longitude');

    if (await canLaunchUrl(url)) {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } else {
      throw 'Tidak dapat membuka URL: $url';
    }
  }
}
