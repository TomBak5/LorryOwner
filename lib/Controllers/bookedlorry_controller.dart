import 'package:get/get.dart';

import '../models/bookedLoads_model.dart';

class BookedLorriesController extends GetxController implements GetxService {

  late BookedLorryModel12 currentLoads;
  late BookedLorryModel12 completedLoads;
  bool isLoading = true;

  setDataCurrentLoads(value) {
    currentLoads = value;
    update();
  }

  setDataCompletedLoads(value) {
    completedLoads = value;
    update();
  }
}
