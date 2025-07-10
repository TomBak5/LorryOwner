import 'dart:convert';

import 'package:get/get.dart';
import 'package:movers_lorry_owner/models/home_model.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Provider/api_provider.dart';
import '../models/login_model.dart';
import 'package:flutter/foundation.dart';

class HomePageController extends GetxController implements GetxService {
  UserLogin? userData;
  HomeModel? homePageData;

  List menuList = [
    "Find Loads",
    "Near Load",
    "Attach Lorry",
    "Add Subdriver"
  ];

  updateUserProfile(context) {
    ApiProvider().loginUser(
            code: userData?.ccode ?? '',
            number: userData?.mobile ?? '',
            password: userData?.password ?? '')
        .then((value) async {
      var data = value;
      if (data["Result"] == "true") {
        final SharedPreferences prefs = await SharedPreferences.getInstance();
        String decodeData = jsonEncode(data["UserLogin"]);
        await prefs.setString("userData", decodeData);
        getDataFromLocalData().then((value) {
          if (value.toString().isNotEmpty) {
            setIcon(verification12(userData?.isVerify ?? ''));
            getHomePageData(uid: userData?.id ?? '');
          }
        });
      } else {
        showCommonToast(data["ResponseMsg"]);
      }
    });
  }

  verification12(String id) {
    switch (id) {
      case "0":
        return "assets/icons/alert-circle.svg";
      case "1":
        return "assets/icons/ic_document_process.svg";
      case "2":
        return "assets/icons/badge-check.svg";
      default:
        return "assets/icons/alert-circle.svg";
    }
  }

  String? verification;

  bool isLoading = true;

  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  setIcon(String value) {
    verification = value;
    update();
  }

  Future getDataFromLocalData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    String? encodedMap = prefs.getString('userData');

    if (encodedMap!.isNotEmpty) {
      var decodedata = jsonDecode(encodedMap);
      userData = UserLogin.fromJson(decodedata);

      prefs.setString("uid", userData?.id ?? '');

      update();
    }

  }

  Future<void> getHomePageData({required String uid}) async {
    setIsLoading(true); // Start loading
    var response = await ApiProvider().homePageApi(uid: uid);
    debugPrint('homePageApi response:');
    debugPrint(response.toString());
    if (response == null || response is! Map || response['error'] != null) {
      showCommonToast('Failed to load home page data.');
      setIsLoading(false); // Always stop loading on error
      return;
    }
    if (response['Result'] == 'true' && response['HomeData'] != null) {
      homePageData = HomeModel.fromJson(Map<String, dynamic>.from(response));
      update();
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      prefs.setString("wallet", homePageData?.homeData?.currency ?? "");
      prefs.setString("currencyIcon", homePageData?.homeData?.currency ?? "");
      prefs.setString("gkey", homePageData?.homeData?.gKey ?? "");
      update();
      setIsLoading(false); // Stop loading on success
    } else {
      showCommonToast(response['ResponseMsg']?.toString() ?? 'Unknown error');
      setIsLoading(false); // Stop loading on backend error
    }
  }

  removeData() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    prefs.setString("userData", "");
    prefs.setString("currencyIcon", "");
    prefs.setString("uid", "");
  }
}
