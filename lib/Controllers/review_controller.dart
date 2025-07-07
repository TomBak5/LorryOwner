import 'package:get/get.dart';

import '../models/review_model.dart';

class ReviewController extends GetxController implements GetxService {
  String? uid;
  String? ownerId;
  String? lorryId;

  ReviewModel? profileData;
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
