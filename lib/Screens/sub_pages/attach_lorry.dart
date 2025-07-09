// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Controllers/attach_lorry_controller.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/attach_lorry1.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/homepage_controller.dart';
import '../../widgets/widgets.dart';

class AttachLorry extends StatefulWidget {
  const AttachLorry({super.key});

  @override
  State<AttachLorry> createState() => _AttachLorryState();
}

class _AttachLorryState extends State<AttachLorry> {
  HomePageController homePageController = Get.put(HomePageController());

  // Add state for brands and trailer types
  List<Map<String, dynamic>> brands = [];
  List<Map<String, dynamic>> trailerTypes = [];
  String? selectedBrand;
  String? selectedTrailerType;

  @override
  void dispose() {
    super.dispose();
    despose();
  }

  despose() async {
    attachLorryController.selectVehicle = -1;
    attachLorryController.lorrynumber.text = '';
    attachLorryController.numberTonnes.text = '';
    attachLorryController.editeTitle = null;
    SharedPreferences preferences = await SharedPreferences.getInstance();
    preferences.setString("EditLorryData", "");
  }

  getdatafromlocale() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();

    String decoderes = preferences.getString("EditLorryData")!;

    if (decoderes.isNotEmpty) {
      Map decode = jsonDecode(decoderes);
      if (decode.isNotEmpty) {
        if (decode["isedite"] == true) {
          attachLorryController.selectVehicle = setvehicleId(vehicle: decode["vehicle"]);
          attachLorryController.vehicleID = setvehicleId(vehicle: decode["vehicle"]).toString();
          attachLorryController.editeTitle = decode['vehicle'];
          debugPrint("========== selectVehicle ========= ${attachLorryController.selectVehicle}");
          debugPrint("============ vehicleID =========== ${attachLorryController.vehicleID}");
          setState(() {
            attachLorryController.lorrynumber.text = decode["lorryNo"];
            attachLorryController.numberTonnes.text = decode["numberOfTones"];
            debugPrint("========== lorrynumber ========= ${attachLorryController.lorrynumber.text}");
            debugPrint("========= numberTonnes ========= ${attachLorryController.numberTonnes.text}");
          });
        } else {
          setState(() {
            attachLorryController.selectVehicle = -1;
            attachLorryController.vehicleID = "-1";
            attachLorryController.lorrynumber.text = '';
            attachLorryController.numberTonnes.text = '';
            attachLorryController.editeTitle = '';
          });
        }
      }
    }
  }

  setvehicleId({required String vehicle}) {
    switch (vehicle) {
      case "LCV":
        return 1;
      case "Truck":
        return 2;
      case "Hyva":
        return 3;
      case "Container":
        return 4;
      case "Trailer":
        return 5;
    }
  }

  @override
  void initState() {
    super.initState();
    attachLorryController.vehicleID = "-1";
    setState(() {});
    getdatafromlocale();
    debugPrint("======= init lorrynumber ====== ${attachLorryController.lorrynumber.text}");
    debugPrint("====== init numberTonnes ====== ${attachLorryController.numberTonnes.text}");
    debugPrint("======= init vehicleID ======== ${attachLorryController.vehicleID}");
    debugPrint("======= init editeTitle ======== ${attachLorryController.editeTitle}");
    debugPrint("==========================================");
    ApiProvider()
        .getVehicleList(uid: homePageController.userData.id ?? '')
        .then((value) {
      attachLorryController.getDataFromApi(value: value);
    });
    // Fetch brands and trailer types
    ApiProvider().fetchVehicleBrands().then((data) {
      setState(() {
        brands = data;
      });
    });
    ApiProvider().fetchTrailerTypes().then((data) {
      setState(() {
        trailerTypes = data;
      });
    });
  }

  AttachLorryController attachLorryController = Get.put(AttachLorryController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttachLorryController>(
      builder: (attachLorryController) {
        return Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: priMaryColor,
            centerTitle: true,
            title: Text(
              attachLorryController.editeTitle ?? "Add Lorry".tr,
              style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyBold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(
                children: [
                  Row(
                    children: [
                      Expanded(
                        child: Container(
                          height: 220,
                          color: priMaryColor,
                        ),
                      )
                    ],
                  )
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.transparent),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "1",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: fontFamilyRegular,
                                  color: textBlackColor,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 3,
                            child: Text(
                              "Load Details".tr,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: fontFamilyBold,
                                fontSize: 12,
                                color: Colors.white,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: SizedBox(
                              width: Get.width * 0.07,
                              child: const Divider(
                                color: Colors.white70,
                                thickness: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white70),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "2",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: fontFamilyRegular,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            flex: 3,
                            child: Text(
                              "Vehicle Type".tr,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: fontFamilyBold,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                            ),
                          ),
                          const SizedBox(width: 5),
                          Flexible(
                            child: SizedBox(
                              width: Get.width * 0.07,
                              child: const Divider(
                                color: Colors.white70,
                                thickness: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                              border: Border.all(color: Colors.white70),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "3",
                                style: TextStyle(
                                  fontSize: 12,
                                  fontFamily: fontFamilyRegular,
                                  color: Colors.white70,
                                ),
                              ),
                            ),
                          ),
                          const SizedBox(width: 8),
                          Flexible(
                            child: Text(
                              "Post".tr,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: fontFamilyBold,
                                fontSize: 12,
                                color: Colors.white70,
                              ),
                              maxLines: 1,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      Container(
                        width: MediaQuery.of(context).size.width,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(16),
                          boxShadow: const [
                            BoxShadow(
                              color: Colors.grey,
                              blurRadius: 5,
                              blurStyle: BlurStyle.outer,
                            )
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            TextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  attachLorryController.setIsLorryNumber(false);
                                } else {
                                  attachLorryController.setIsLorryNumber(attachLorryController.lorrynumber.text.isEmpty);
                                }
                              },
                              controller: attachLorryController.lorrynumber,
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: fontFamilyRegular,
                                color: textBlackColor,
                              ),
                              decoration: InputDecoration(
                                hintText: "Enter Lorry Number".tr,
                                suffixIcon: attachLorryController.isLorryNumber
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/icons/exclamation-circle.svg",
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                  fontFamily: fontFamilyRegular,
                                  color: textGreyColor,
                                ),
                                prefixIcon: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/box-check.svg",
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            TextField(
                              onChanged: (value) {
                                if (value.isEmpty) {
                                  attachLorryController.setIsNumTonnes(false);
                                } else {
                                  attachLorryController.setIsNumTonnes(attachLorryController.numberTonnes.text.isEmpty);
                                }
                              },
                              controller: attachLorryController.numberTonnes,
                              keyboardType: TextInputType.number,
                              style: TextStyle(
                                fontSize: 17,
                                fontFamily: fontFamilyRegular,
                                color: textBlackColor,
                              ),
                              decoration: InputDecoration(
                                hintText: "Number of Tonnes".tr,
                                suffixIcon: attachLorryController.isNumTonnes
                                    ? SizedBox(
                                        height: 20,
                                        width: 20,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/icons/exclamation-circle.svg",
                                            color: Colors.red,
                                          ),
                                        ),
                                      )
                                    : const SizedBox(),
                                contentPadding: EdgeInsets.symmetric(vertical: 16),
                                hintStyle: TextStyle(
                                  fontSize: 17,
                                  fontFamily: fontFamilyRegular,
                                  color: textGreyColor,
                                ),
                                prefixIcon: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: Center(
                                    child: SvgPicture.asset(
                                      "assets/icons/delivery-cart-arrow-up.svg",
                                    ),
                                  ),
                                ),
                                border: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                  borderRadius: BorderRadius.circular(10),
                                ),
                              ),
                            ),
                            const SizedBox(height: 20),
                            Text(
                              "Select Vehicle".tr,
                              style: Typographyy.headLine.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 20),
                            // Brand Dropdown
                            Text(
                              "Select Brand",
                              style: Typographyy.headLine.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedBrand,
                              hint: Text('Select Brand'),
                              items: brands.map((brand) {
                                return DropdownMenuItem<String>(
                                  value: brand['id'].toString(),
                                  child: Text(brand['brand_name']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedBrand = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            // Trailer Type Dropdown
                            Text(
                              "Select Trailer Type",
                              style: Typographyy.headLine.copyWith(fontSize: 15),
                            ),
                            const SizedBox(height: 10),
                            DropdownButtonFormField<String>(
                              value: selectedTrailerType,
                              hint: Text('Select Trailer Type'),
                              items: trailerTypes.map((type) {
                                return DropdownMenuItem<String>(
                                  value: type['id'].toString(),
                                  child: Text(type['trailer_type']),
                                );
                              }).toList(),
                              onChanged: (value) {
                                setState(() {
                                  selectedTrailerType = value;
                                });
                              },
                            ),
                            const SizedBox(height: 20),
                            // The vehicle grid/list and its loading shimmer are removed.
                            // Only the new dropdowns for brand and trailer type remain for selection.
                            Row(
                              children: [
                                Expanded(
                                  child: commonButton(
                                    title: "Next".tr,
                                    onTapp: () {
                                      debugPrint("======= lorrynumber ====== ${attachLorryController.lorrynumber.text}");
                                      debugPrint("====== numberTonnes ====== ${attachLorryController.numberTonnes.text}");
                                      debugPrint("======= selectedBrand ====== $selectedBrand");
                                      debugPrint("======= selectedTrailerType ====== $selectedTrailerType");
                                      if (attachLorryController.lorrynumber.text.isNotEmpty && attachLorryController.numberTonnes.text.isNotEmpty) {
                                        if (selectedBrand != null && selectedTrailerType != null) {
                                          // Pass selectedBrand and selectedTrailerType to the next screen or save as needed
                                          Get.to(
                                            AttachLorry1(
                                              lorryNumber: attachLorryController.lorrynumber.text,
                                              numberOfTonnes: attachLorryController.numberTonnes.text,
                                              vehicleId: selectedBrand!, // non-nullable, safe due to null check
                                            ),
                                          );
                                        } else {
                                          showCommonToast("Select Brand and Trailer Type".tr);
                                        }
                                      } else {
                                        if (attachLorryController.lorrynumber.text.isEmpty) {
                                          attachLorryController.setIsLorryNumber(true);
                                        }
                                        if (attachLorryController.numberTonnes.text.isEmpty) {
                                          attachLorryController.setIsNumTonnes(true);
                                        }
                                      }
                                    },
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
