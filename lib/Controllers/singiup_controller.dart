
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
import '../Screens/congratulations_screen.dart';

class SingUpController extends GetxController implements GetxService {
  bool isPasswordShow = true;
  bool isLoading = false;
  bool istreamAndCondition = false;
  String response = '';
  String countryCode = '+91';
  String selectedRole = 'driver'; // Add selected role with default value
  String? selectedBrand; // Store selected truck brand
  String? selectedTrailerType; // Store selected trailer type

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
      required String userRole,
      String? company,
      String? emergencyContact,
      String? selectedBrand,
      String? selectedTrailerType}) {
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
            userRole: userRole,
            company: company,
            emergencyContact: emergencyContact,
            selectedBrand: selectedBrand,
            selectedTrailerType: selectedTrailerType)
        .then((value) async {
      print('Registration API response:  [36m$value [0m');
      var dataaa = value;
      if (dataaa["Result"] == "true") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String decodeData = jsonEncode(dataaa["UserLogin"]);
        await prefs.setString("userData", decodeData);
        // OneSignal.shared.sendTag("owner_id", dataaa["UserLogin"]["id"]);
        OneSignal.User.addTagWithKey("user_id", dataaa["UserLogin"]["id"]);
        // Navigation removed from here. Let the caller handle navigation after registration.
        setIsLoading(false);
      } else {
        setIsLoading(false);
        print("LOADAER $isLoading");
      }
    });
  }

  // New method that returns a Future<bool> to indicate success/failure
  Future<bool> setUserDataWithResult(context,
      {required String name,
      required String mobile,
      required String ccode,
      required String email,
      required String pass,
      required String reff,
      required String userRole,
      String? company,
      String? emergencyContact,
      String? selectedBrand,
      String? selectedTrailerType}) async {
    try {
      // Generate a unique numeric phone number if blank
      String phoneToSend = mobile.isEmpty
          ? (DateTime.now().millisecondsSinceEpoch.toString() + Random().nextInt(999).toString())
          : mobile;
      print('Attempting registration with: email= [32m$email [0m, userRole= [32m$userRole [0m');
      
      var value = await ApiProvider().registerUser(
              password: pass,
              cCode: ccode,
              email: email,
              mobile: phoneToSend,
              name: name,
              referCode: reff,
              userRole: userRole,
              company: company,
              emergencyContact: emergencyContact,
              selectedBrand: selectedBrand,
              selectedTrailerType: selectedTrailerType);
              
      print('Registration API response:  [36m$value [0m');
      var dataaa = value;
      if (dataaa["Result"] == "true") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String decodeData = jsonEncode(dataaa["UserLogin"]);
        await prefs.setString("userData", decodeData);
        // OneSignal.shared.sendTag("owner_id", dataaa["UserLogin"]["id"]);
        OneSignal.User.addTagWithKey("user_id", dataaa["UserLogin"]["id"]);
        setIsLoading(false);
        return true; // Registration successful
      } else {
        setIsLoading(false);
        print("Registration failed: ${dataaa["ResponseMsg"] ?? 'Unknown error'}");
        return false; // Registration failed
      }
    } catch (e) {
      setIsLoading(false);
      print("Registration error: $e");
      return false; // Registration failed due to exception
    }
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

  // Removed getDataFromApi method to prevent duplicate registrations

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