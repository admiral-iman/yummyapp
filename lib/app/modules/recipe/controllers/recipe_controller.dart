import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class RecipeController extends GetxController {
  Future<void> deleteItem(String docId, String imageUrl) async {
    try {
      // Hapus dokumen dari Firestore
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(docId)
          .delete();

      // Jika ada file di Firebase Storage (contoh penghapusan image)
      if (imageUrl.isNotEmpty) {
        // Tambahkan logika penghapusan file jika perlu
        // await FirebaseStorage.instance.refFromURL(imageUrl).delete();
      }

      // Tampilkan Snackbar untuk konfirmasi
      Get.snackbar(
        'Berhasil',
        'Resep berhasil dihapus',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.green,
        colorText: Colors.white,
      );
    } catch (e) {
      // Tangani exception
      Get.snackbar(
        'Error',
        'Gagal menghapus resep: $e',
        snackPosition: SnackPosition.BOTTOM,
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }
}
