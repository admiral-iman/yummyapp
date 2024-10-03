import 'package:get/get.dart';
import '../models/profile_model.dart';

class ProfileController extends GetxController {
  var profiles = <Profile>[].obs;

  void addProfile(Profile profile) {
    profiles.add(profile);
  }
}
