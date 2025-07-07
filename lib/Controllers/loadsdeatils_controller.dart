import 'package:get/get.dart';

import '../models/myloads_detils_model.dart';

class LoadsDetailsController extends GetxController implements GetxService {
  double rating = 0.0;

  setRating(value) {
    rating = value;
    update();
  }

  late MyLoadsDetialsModel detailsData;
  int zod = 0;

  bool isLoading = true;
  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  setDetilsValue(value, value1) {
    detailsData = value;
    zod = value1;
    update();
  }
}
