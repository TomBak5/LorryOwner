
import 'dart:convert';
import 'dart:math';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Screens/otp_screen.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';

// import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:uuid/uuid.dart';

import '../Api_Provider/api_provider.dart';
import '../AppConstData/routes.dart';

class SingUpController extends GetxController implements GetxService {
  bool isPasswordShow = true;
  bool isLoading = false;
  bool istreamAndCondition = false;
  String response = '';
  String countryCode = '+91';
  String selectedRole = 'driver'; // Add selected role with default value

  bool isMobileNumber = false;
  bool isFullName = false;
  bool emailAddress = false;
  bool passWord = false;
  bool isRoleSelected = false; // Add role validation

  // Add role selection method
  setSelectedRole(String role) {
    selectedRole = role;
    isRoleSelected = true;
    update();
  }

  setIsMobileNumber(bool value) {
    isMobileNumber = value;
    update();
  }

  setIsFullName(bool value) {
    isFullName = value;
    update();
  }

  setEmailAddress(bool value) {
    emailAddress = value;
    update();
  }

  setPassWord(bool value) {
    passWord = value;
    update();
  }

  countryData(value) {
    countryCode = value;
    update();
  }

  setIsLoading(value) {
    isLoading = value;
    update();
  }

  setIsPasswordShow() {
    isPasswordShow = !isPasswordShow;
    update();
  }

  setIstreamAndCondition() {
    istreamAndCondition = !istreamAndCondition;
    update();
  }

  setUserData(context,
      {required String name,
      required String mobile,
      required String ccode,
      required String email,
      required String pass,
      required String reff,
      required String userRole}) {
    // Generate a unique numeric phone number if blank
    String phoneToSend = mobile.isEmpty
        ? (DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString())
        : mobile;
    print('Attempting registration with: email= [32m$email [0m, userRole= [32m$userRole [0m');
    ApiProvider().registerUser(
            password: pass,
            cCode: ccode,
            email: email,
            mobile: phoneToSend,
            name: name,
            referCode: reff,
            userRole: userRole)
        .then((value) async {
      print('Registration API response:  [36m$value [0m');
      var dataaa = value;
      if (dataaa["Result"] == "true") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String decodeData = jsonEncode(dataaa["UserLogin"]);
        await prefs.setString("userData", decodeData);
        // OneSignal.shared.sendTag("owner_id", dataaa["UserLogin"]["id"]);
        OneSignal.User.addTagWithKey("user_id", dataaa["UserLogin"]["id"]);
        if (userRole == 'driver') {
          Get.offAllNamed(Routes.truckInfo);
        } else {
          Get.offAllNamed(Routes.landingPage);
        }
        setIsLoading(false);
        showCommonToast(dataaa["ResponseMsg"]);
      } else {
        setIsLoading(false);
        print("LOADAER $isLoading");
        showCommonToast(dataaa["ResponseMsg"]);
      }
    });
  }

  setDataInLocal(
      {required String name,
      required String mobile,
      required String ccode,
      required String email,
      required String pass,
      required String reff}) async {
    Map userData = {
      "name": name,
      "mobile": mobile,
      "ccode": ccode,
      "email": email,
      "password": pass,
      "refercode": reff,
    };

    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String encodeData = jsonEncode(userData);

    prefs.setString("tempUserData", encodeData);
  }

  Future getDataFromApi(context) async {
    // Directly call setUserData with only the required fields
    setUserData(
      context,
      name: 'User', // Dummy value
      mobile: '', // Leave blank to trigger UUID logic
      email: emailController.text,
      ccode: '+370', // Dummy value
      pass: passwordController.text,
      reff: '', // No referral code
      userRole: selectedRole,
    );
  }

  TextEditingController mobileController = TextEditingController();
  TextEditingController fullNameController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  bool isConfirmPasswordShow = false;
  TextEditingController referralCodeController = TextEditingController();
  TextEditingController codeController = TextEditingController();
}

//63563889361