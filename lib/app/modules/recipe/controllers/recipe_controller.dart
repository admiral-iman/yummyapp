import 'package:get/get.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';

class RecipeController extends GetxController {
  // Fungsi untuk menghapus item
  Future<void> deleteItem(String docId, String? imageUrl) async {
    try {
      // Hapus dokumen dari Firestore
      await FirebaseFirestore.instance
          .collection('recipes')
          .doc(docId)
          .delete();
      print('Dokumen berhasil dihapus dari Firestore');

      // Hapus gambar dari Storage jika imageUrl tidak null dan tidak kosong
      if (imageUrl != null && imageUrl.isNotEmpty) {
        await FirebaseStorage.instance.refFromURL(imageUrl).delete();
        print('Gambar berhasil dihapus dari Storage');
      } else {
        print('imageUrl is null or empty, skipping deletion from Storage');
      }
    } catch (e) {
      print('Gagal menghapus item: $e');
    }
  }
}
