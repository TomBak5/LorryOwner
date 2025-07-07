import 'dart:convert';
import 'dart:developer';

import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

class ForgotPasswordController extends GetxController implements GetxService {
  bool isLoading = false;

  setIsLoading({required bool value}) {
    isLoading = value;
    update();
  }

  setTempDataIn({required String mobile, required String ccode}) async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    Map data = {
      "mobileNumber": mobile,
      "ccode": ccode,
    };

    log("Locale-----------------$data");
    prefs.setString("tempForgotpassData", jsonEncode(data));
  }
}
