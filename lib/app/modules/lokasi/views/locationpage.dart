import 'package:demo_yummy/app/modules/lokasi/controller/location_controller.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';

class LocationPage extends StatelessWidget {
  final LocationController locationController = Get.put(LocationController());

  // List lokasi lokal dengan nama resto, gambar, dan koordinat
  final List<Map<String, dynamic>> localRestaurants = [
    {
      "name": "Superindo Tlogomas",
      "image": "assets/super.jpg", // Path ke gambar asset
      "latitude": -7.934606673493748,
      "longitude": 112.60477084002429,
    },
    {
      "name": "Pasar Dinoyo",
      "image": "assets/dinoyo.jpg",
      "latitude": -7.938690616341308,
      "longitude": 112.60748878955866,
    },
    {
      "name": "Pasar Landungsari",
      "image": "assets/landung.jpg",
      "latitude": -7.929297798255025,
      "longitude": 112.59581579907285,
    },
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Lokasi Saya - Yummy Recipe'),
        backgroundColor: Colors.orange,
        actions: [
          // Tombol Refresh
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: locationController.getCurrentLocation,
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(8.0),
        child: Obx(() {
          final position = locationController.currentPosition.value;

          if (position == null) {
            return Center(
              child: CircularProgressIndicator(),
            );
          } else {
            return ListView(
              children: [
                // Informasi Lokasi
                Card(
                  margin: const EdgeInsets.symmetric(vertical: 10),
                  child: ListTile(
                    title: const Text('Lokasi Anda'),
                    subtitle: Text(locationController.locationMessage.value),
                    leading:
                        const Icon(Icons.location_on, color: Colors.orange),
                    onTap: locationController.openGoogleMaps,
                  ),
                ),
                const SizedBox(height: 20),

                // Daftar Resto Lokal
                ...localRestaurants.map((restaurant) {
                  return Card(
                    margin: const EdgeInsets.symmetric(vertical: 5),
                    child: ListTile(
                      leading: Image.asset(
                        restaurant['image'],
                        width: 50,
                        height: 50,
                        fit: BoxFit.cover,
                      ),
                      title: Text(restaurant['name']),
                      subtitle: const Text('Masakan khas daerah sekitar'),
                      onTap: () {
                        locationController.openGoogleMapsWithCoordinates(
                          restaurant['latitude'],
                          restaurant['longitude'],
                        );
                      },
                    ),
                  );
                }).toList(),
              ],
            );
          }
        }),
      ),
    );
  }
}
