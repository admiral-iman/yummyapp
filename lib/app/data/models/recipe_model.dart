class Recipe {
  final String? spoonacularSourceUrl;
  final String? title; // Tambahkan judul
  final String? imageUrl; // Tambahkan URL gambar

  Recipe({
    this.spoonacularSourceUrl,
    this.title,
    this.imageUrl,
  });

  factory Recipe.fromMap(Map<String, dynamic> map) {
    return Recipe(
      spoonacularSourceUrl: map['spoonacularSourceUrl'],
      title: map['title'], // Ambil judul dari map
      imageUrl: map['image'], // Ambil URL gambar dari map
    );
  }
}
