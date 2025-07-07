import 'package:get/get.dart';
import 'package:movers_lorry_owner/models/transport_profile_model.dart';

class ProfileDetilsController extends GetxController implements GetxService {
  String? uid;
  String? ownerId;
  String? lorryId;

  TransProfileModel? profileData;
  bool isLoading = true;

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  setDataInReview(
      {required String lorryId1,
      required String ownerId1,
      required String uid1}) {
    uid = uid1;
    ownerId = ownerId1;
    lorryId = lorryId1;
    update();
  }

  setProfileData(value) {
    profileData = value;
    update();
  }
}
