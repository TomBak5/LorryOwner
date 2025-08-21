import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AppConstData/routes.dart';
// import 'package:movers/AppConstData/routes.dart';

class ProfileController extends GetxController implements GetxService {
  TextEditingController nameController = TextEditingController();
  TextEditingController passController = TextEditingController();

  bool isPasswordShow = true;

  setIsPasswordShow() {
    isPasswordShow = !isPasswordShow;
    update();
  }

  List pagesPath = [
    Routes.walletScreen,
    Routes.reviewScreen,
    Routes.reviewScreen,
    Routes.privacyPolicy,
    Routes.termsConditions,
    Routes.contactus,
    Routes.faq,
    Routes.faq,
    '', // Empty route for test button
  ];

  List itemIcons = [
    "assets/icons/ic_profile_wallet.svg",
    "assets/icons/ic_star_profile.svg",
    "assets/icons/ic_multi_lang.svg",
    "assets/icons/ic_profile_pages.svg",
    "assets/icons/ic_profile_pages.svg",
    "assets/icons/ic_profile_pages.svg",
    "assets/icons/ic_faq.svg",
    "assets/icons/ic_logout.svg",
    "assets/icons/ic_profile_pages.svg", // Icon for test button
  ];

  List nameOfCountry = [
    "English",
    "Spanish",
    "Arabic",
    "Hindi",
    "Gujarati",
    "Afrikaans",
    "Bengali",
    "Indonesian",
  ];

  List countryLogo = [
    "assets/logo/043-liberia.png",
    "assets/logo/230-spain.png",
    "assets/logo/195-united arab emirates.png",
    "assets/logo/055-india.png",
    "assets/logo/055-india.png",
    "assets/logo/188-south africa.png",
    "assets/logo/134-bangladesh.png",
    "assets/logo/185-indonesia.png",
  ];

  List items = [
    "Earning",
    "Review",
    "Language",
    "Privacy Policy",
    "Terms & Conditions",
    "Contact Us",
    "FAQ",
    "LogOut",
    "Test HERE API", // New test menu item
  ];
}

// image.value = await picker.pickImage(
// source: ImageSource.gallery,
// );
//
// // Make a form data body
// final _body = {
// "image": MultipartFile(await image.value.readAsBytes(), filename: image.value.name),
// "notes": "testing",
// };
// FormData formData = FormData(_body);
//
// // Sending with GetConnect
// post("/target-endpoint", formData, contentType: "multipart/form-data");
