import 'package:get/get.dart';

class HomeController extends GetxController {
  //TODO: Implement HomeController

  final count = 0.obs;
  @override
  void onInit() {
    super.onInit();
  }

  @override
  void onReady() {
    super.onReady();
  }

  @override
  void onClose() {
    super.onClose();
  }

  void increment() => count.value++;

  // Buat variabel Rx untuk memantau perubahan ikon
  var iconPath = 'assets/icons/favicon.png'.obs;

  // Fungsi untuk mengubah ikon jika diperlukan
  void changeIcon(String newIconPath) {
    iconPath.value = newIconPath;
  }
}
