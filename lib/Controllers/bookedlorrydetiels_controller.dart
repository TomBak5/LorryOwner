import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import '../models/bookdetiles_model.dart';

class BookedHistoryController extends GetxController implements GetxService {
  late BookedDetialsModel historyData;

  TextEditingController amount = TextEditingController();

  bool isPriceFix = false;

  setIsPriceFix(bool value) {
    isPriceFix = value;
    update();
  }

  bool isAmount = false;

  setIsAmount(bool value) {
    isAmount = value;
    update();
  }

  double rating = 0.0;

  setRating(value) {
    rating = value;
    update();
  }

  bool isLoading = true;

  setIsLoading(value) {
    isLoading = value;
    update();
  }

  setBookedData(value) {
    historyData = value;
    update();
  }
}
