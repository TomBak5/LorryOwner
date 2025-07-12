import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';

import 'package:movers_lorry_owner/widgets/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api_Provider/api_provider.dart';
import '../AppConstData/routes.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginScreenController extends GetxController implements GetxService {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isEmail = false;
  bool isPassword = true; // Always show password field
  bool isShowPassword = true;
  bool isPassValid = false;

  void setIsEmail(bool value) {
    isEmail = value;
    update();
  }

  void setIsPassValid(bool value) {
    isPassValid = value;
    update();
  }

  void setShowPassword() {
    isShowPassword = !isShowPassword;
    update();
  }

  bool isLoading = false;
  setIsLoading(value) {
    isLoading = value;
    update();
  }

  // New email/password login logic
  checkController({required String email, required String password, context}) {
    setIsLoading(true);
    if (emailController.text.isEmpty) {
      setIsEmail(true);
      setIsLoading(false);
      return;
    }
    if (passwordController.text.isEmpty) {
      setIsPassValid(true);
      setIsLoading(false);
      return;
    }
    ApiProvider().loginUserWithEmail(
      email: email,
      password: password,
              ).then((value) async {
              var data = value;
              if (data["Result"] == "true") {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                String decodeData = jsonEncode(data["UserLogin"]);
                await prefs.setString("userData", decodeData);
                OneSignal.User.addTagWithKey("user_id", data["UserLogin"]["id"]);
                Get.offAllNamed(Routes.landingPage);
              } else {
                showCommonToast(data["ResponseMsg"]);
        }
        setIsLoading(false);
      });
  }
}





// onesignal_flutter: ^3.5.1
