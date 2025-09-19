// ignore_for_file: deprecated_member_use

import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:geocoding/geocoding.dart';
import 'package:geolocator/geolocator.dart';
import 'package:get/get.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shimmer/shimmer.dart';

import '../Api_Provider/imageupload_api.dart';
import '../AppConstData/app_colors.dart';
import '../AppConstData/typographyy.dart';

commonButton({required String title, required void Function() onTapp}) {
  return ElevatedButton(
    style: ElevatedButton.styleFrom(
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      fixedSize: const Size.fromHeight(48),
      backgroundColor: priMaryColor,
    ),
    onPressed: onTapp,
    child: Text(
      title.tr,
      style: TextStyle(
        color: whiteColor,
        fontSize: 16,
        fontFamily: "urbani_extrabold",
        fontWeight: FontWeight.w700,
      ),
    ),
  );
}

commonSimmer({required double height, required double width}) {
  return Shimmer.fromColors(
    baseColor: Colors.black45,
    highlightColor: Colors.grey.shade100,
    enabled: true,
    child: Container(
      height: height,
      width: width,
      decoration: BoxDecoration(
        color: Colors.grey.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [],
      ),
    ),
  );
}

commonTextField({
  required TextEditingController controller,
  required String hintText,
  required TextInputType keyBordType,
  bool? isValide,
  void Function(String)? onTap,
}) {
  return TextField(
    controller: controller,
    keyboardType: keyBordType,
    textInputAction: TextInputAction.next, // Force regular text input
    onChanged: onTap,
    style: TextStyle(color: textBlackColor, fontFamily: "urbani_regular", fontSize: 16),
    decoration: InputDecoration(
      hintStyle: TextStyle(color: textGreyColor, fontFamily: "urbani_regular", fontSize: 14),
      hintText: hintText.tr,
      suffixIcon: isValide == true
          ? const Icon(Icons.error, color: Colors.red)
          : null,
      contentPadding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textGreyColor),
      ),
      enabledBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: textGreyColor),
      ),
      focusedBorder: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide(color: const Color(0xff194BFB)),
      ),
    ),
  );
}



showCommonToast(String msg) {
  Fluttertoast.showToast(msg: msg, toastLength: Toast.LENGTH_SHORT);
}

commonBg() {
  return SingleChildScrollView(
    physics: const NeverScrollableScrollPhysics(),
    child: Column(
      children: [
        Stack(
          alignment: Alignment.topCenter,
          children: [
            Container(
              height: Get.height / 1.1,
              width: Get.width,
              color: priMaryColor,
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Stack(
                    children: [
                      SizedBox(width: Get.width),
                      Image.asset(
                        "assets/image/Rectangle 39456.png",
                        height: 650,
                        width: 220,
                      ),
                      Positioned(
                        top: 10,
                        right: 020,
                        child: Image.asset(
                          "assets/image/Rectangle 39457.png",
                          height: 650,
                          width: 220,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ],
    ),
  );
}

commonDetils({
  required String vehicleImg,
  required String vehicleTitle,
  required String currency,
  required String amount,
  required String amtType,
  required String totalAmt,
  required String pickupState,
  required String pickupPoint,
  required String dropState,
  required String dropPoint,
  required String postDate,
  required String weight,
  required String materialName,
}) {
  return Container(
    padding: const EdgeInsets.all(15),
    decoration: BoxDecoration(
      borderRadius: BorderRadius.circular(12),
      border: Border.all(
        color: Colors.grey.withOpacity(0.3),
      ),
    ),
    child: Column(
      children: [
        Row(
          children: [
            Image.network("$basUrl$vehicleImg", height: 55, width: 55),
            SizedBox(width: 8),
            Text(vehicleTitle,
              style: TextStyle(
                fontSize: 14,
                fontFamily: fontFamilyRegular,
                fontWeight: FontWeight.w400,
              ),
            ),
            const Spacer(),
            Column(
              children: [
                RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "$currency$amount",
                        style: TextStyle(
                          color: textBlackColor,
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamilyBold,
                        ),
                      ),
                      TextSpan(
                        text: " /$amtType",
                        style: TextStyle(
                          color: textGreyColor,
                          fontSize: 10,
                          fontFamily: fontFamilyRegular,
                        ),
                      ),
                    ],
                  ),
                ),
                amtType.compareTo("Fixed") == 0
                    ? const SizedBox()
                    : Text("$currency$totalAmt"),
              ],
            ),
          ],
        ),
        Divider(
          color: Colors.grey.withOpacity(0.3),
          height: 40,
        ),
        Row(
          children: [
            SvgPicture.asset("assets/icons/ic_current_long.svg",height: 30, width: 30),
            const SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    pickupState,
                    style: TextStyle(
                      fontSize: 18,
                      color: textBlackColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: fontFamilyBold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    pickupPoint,
                    style: TextStyle(
                      color: textGreyColor,
                      fontFamily: fontFamilyRegular,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            )
          ],
        ),
        SizedBox(height: 20),
        Row(
          children: [
            SvgPicture.asset("assets/icons/ic_destination_long.svg",height: 30, width: 30),
            const SizedBox(width: 15),
            Flexible(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    dropState,
                    style: TextStyle(
                      fontSize: 18,
                      color: textBlackColor,
                      fontWeight: FontWeight.w500,
                      fontFamily: fontFamilyBold,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                  Text(
                    dropPoint,
                    style: TextStyle(color: textGreyColor, fontFamily: fontFamilyRegular),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 2,
                  ),
                ],
              ),
            ),
          ],
        ),
        const SizedBox(height: 15),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            Column(
              children: [
                Text(
                  "Date".tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: fontFamilyRegular,
                    color: textGreyColor,
                  ),
                ),
                const SizedBox(height: 3),
                Text(
                  postDate.toString().split(" ").first,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: fontFamilyBold,
                    color: textBlackColor,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Tonnes".tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: fontFamilyRegular,
                    color: textGreyColor,
                  ),
                ),
                SizedBox(height: 3),
                Text(
                  weight,
                  style: TextStyle(
                    fontSize: 14,
                    fontFamily: fontFamilyBold,
                    color: textBlackColor,
                  ),
                ),
              ],
            ),
            Column(
              children: [
                Text(
                  "Material".tr,
                  style: TextStyle(
                    fontSize: 12,
                    fontFamily: fontFamilyRegular,
                    color: textGreyColor,
                  ),
                ),
                const SizedBox(
                  height: 3,
                ),
                Text(
                  materialName,
                  style: TextStyle(
                      fontSize: 14,
                      fontFamily: fontFamilyBold,
                      color: textBlackColor),
                ),
              ],
            )
          ],
        ),
      ],
    ),
  );
}

// Future<void> initPlatformState() async {
//   OneSignal.shared.setAppId("09427f99-6140-45d3-90cd-ac566c4fb3ca");
//   OneSignal.shared
//       .promptUserForPushNotificationPermission()
//       .then((accepted) {});
//   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//     log("Accepted OSPermissionStateChanges : $changes");
//   });
// }

// Future<void> initPlatformState() async {
//   OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
//   OneSignal.initialize("09427f99-6140-45d3-90cd-ac566c4fb3ca");
//   OneSignal.Notifications.requestPermission(true).then(
//         (value) {
//       print("Signal value:- $value");
//     },
//   );
// }

Future<void> initPlatformState() async {
  OneSignal.Debug.setLogLevel(OSLogLevel.verbose);
  OneSignal.initialize("db50fe58-a881-4f75-adb1-fbaba67413c6");
  OneSignal.Notifications.requestPermission(true).then(
        (value) {
      print("Signal value:- $value");
    },
  );
}

double lat = 0.00;
double long = 0.00;
String addresshome = "";

Future<Position> locateUser() async {
    return Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
  }

  Future locationPermission() async {
    LocationPermission permission;

    permission = await Geolocator.checkPermission();
    permission = await Geolocator.requestPermission();
    
    if (permission == LocationPermission.denied) {
      if (Platform.isAndroid) {
        SystemNavigator.pop();
      } else if (Platform.isIOS) {
        exit(0);
      }
    }
   
    var currentLocation = await locateUser();
    debugPrint('location: ${currentLocation.latitude}');


    getCurrentLatAndLong(
      currentLocation.latitude,
      currentLocation.longitude,
    );
  }

  getCurrentLatAndLong(double latitude, double longitude) async {
    lat = latitude;
    long = longitude;

    await placemarkFromCoordinates(lat, long)
        .then((List<Placemark> placemarks) {
      addresshome = '${placemarks.first.name}, ${placemarks.first.locality}, ${placemarks.first.country}';

      debugPrint("----- FIRST USER CURRENT LOCATION :---- $addresshome");
      debugPrint("----- FIRST USER CURRENT LOCATION :---- $lat");
      debugPrint("----- FIRST USER CURRENT LOCATION :---- $long");
    });
  }
