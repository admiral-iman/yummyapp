import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';

class RecipeWebView extends StatelessWidget {
  final String url; // URL yang akan ditampilkan di WebView

  const RecipeWebView({Key? key, required this.url}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text("Recipe Details"),
      ),
      body: WebView(
        initialUrl: 'https://www.yummy.co.id/resep', // Memuat URL resep
        javascriptMode: JavascriptMode.unrestricted, // Mengizinkan Javascript
      ),
    );
  }
}
