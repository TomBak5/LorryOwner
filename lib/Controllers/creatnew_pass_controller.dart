import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

class CreateNewPasswordController extends GetxController
    implements GetxService {
  bool isPasswordShow = true;

  String? mobileNumber1;
  String? ccode1;

  TextEditingController password = TextEditingController();
  TextEditingController cpassword = TextEditingController();

  setIsPasswordShow() {
    isPasswordShow = !isPasswordShow;
    update();
  }

  bool isNewPasswordShow = true;

  setIsNewPasswordShow() {
    isNewPasswordShow = !isNewPasswordShow;
    update();
  }
}
