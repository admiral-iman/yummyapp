import 'package:circular_profile_avatar/circular_profile_avatar.dart';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/profile_controller.dart';

class AccountPage extends StatelessWidget {
  final ProfileController profileController = Get.put(ProfileController());

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text('Your Profile')),
      body: Obx(() {
        if (profileController.profiles.isEmpty) {
          return Center(child: Text("No profiles available."));
        }
        return ListView.builder(
          itemCount: profileController.profiles.length,
          itemBuilder: (context, index) {
            final profile = profileController.profiles[index];
            return ListTile(
              leading: profile.imagePath.path.isNotEmpty
                  ? CircularProfileAvatar(
                      '',
                      radius: 30,
                      backgroundColor: Colors.white,
                      borderWidth: 2,
                      borderColor: Colors.white,
                      elevation: 5.0,
                      child: ClipOval(
                        child: Image.file(
                          profile.imagePath,
                          fit: BoxFit.cover,
                          width: 500,
                          height: 500,
                          errorBuilder: (context, error, stackTrace) {
                            return Icon(Icons.error, size: 100);
                          },
                        ),
                      ),
                    )
                  : Icon(Icons.boy, size: 100),
              title: Text(
                profile.nama,
                style: TextStyle(fontSize: 25, fontWeight: FontWeight.bold),
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(profile.email,
                      style: TextStyle(fontSize: 18, color: Colors.grey)),
                  SizedBox(height: 5),
                  Text('Date: ${profile.birthDate}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                  Text('Gender: ${profile.gender}',
                      style: TextStyle(fontSize: 14, color: Colors.grey[600])),
                ],
              ),
            );
          },
        );
      }),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Get.offNamed('/login');
        },
        child: Icon(Icons.logout),
        tooltip: 'Logout',
      ),
    );
  }
}
