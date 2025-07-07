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
        .getVehicleList(uid: homePageController.userData.id)
        .then((value) {
      attachLorryController.getDataFromApi(value: value);
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
                            attachLorryController.isLoading
                                ? GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: 5,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisExtent: 100,
                                      crossAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      return Padding(
                                        padding: const EdgeInsets.all(8),
                                        child: commonSimmer(height: 100, width: 100),
                                      );
                                    },
                                  )
                                : GridView.builder(
                                    physics: NeverScrollableScrollPhysics(),
                                    shrinkWrap: true,
                                    itemCount: attachLorryController.vehicleList.vehicleData.length,
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                      crossAxisCount: 2,
                                      mainAxisExtent: 100,
                                      crossAxisSpacing: 10,
                                    ),
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          if (attachLorryController.numberTonnes.text.isNotEmpty) {
                                            if (int.parse(attachLorryController.vehicleList.vehicleData[index].maxWeight) >= int.parse(attachLorryController.numberTonnes.text.trim())) {
                                              attachLorryController.vehicleID = attachLorryController.vehicleList.vehicleData[index].id;
                                              debugPrint("=========== vehicleId ======= ${attachLorryController.vehicleID}");
                                              attachLorryController.setSelectVehicle(index);
                                            } else {
                                              showCommonToast("it is not possible to choose a larry with a your load capacity");
                                            }
                                          } else {
                                            showCommonToast("Frist Enter Number of Tonnes");
                                          }
                                        },
                                        child: Container(
                                          height: 120,
                                          width: 150,
                                          padding: EdgeInsets.all(8),
                                          decoration: BoxDecoration(
                                            color:(int.parse("${attachLorryController.vehicleID}") == index + 1
                                                    ? priMaryColor.withOpacity(0.05)
                                                    : Colors.transparent),
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color:(int.parse("${attachLorryController.vehicleID}") == index + 1
                                                    ? priMaryColor
                                                    : Colors.grey.withOpacity(0.3)),
                                            ),
                                          ),
                                          margin: const EdgeInsets.symmetric(vertical: 8),
                                          child: Row(
                                            children: [
                                              Image.network(
                                                "$basUrl${attachLorryController.vehicleList.vehicleData[index].img}",
                                                height: 65,
                                                width: 65,
                                                errorBuilder: (context, error, stackTrace) {
                                                  return commonSimmer(height: 58, width: 58);
                                                },
                                                loadingBuilder: (context, child, loadingProgress) {
                                                  return (loadingProgress == null)
                                                      ? child
                                                      : commonSimmer(height: 58, width: 58);
                                                },
                                              ),
                                              const SizedBox(width: 8),
                                              Flexible(
                                                child: Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    Text(
                                                      "${attachLorryController.vehicleList.vehicleData[index].title}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        fontFamily: fontFamilyBold,
                                                        color: textBlackColor,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                    const SizedBox(height: 5),
                                                    Text(
                                                      "${attachLorryController.vehicleList.vehicleData[index].minWeight} - ${attachLorryController.vehicleList.vehicleData[index].maxWeight} ${"Tonnes".tr}",
                                                      style: TextStyle(
                                                        color: textBlackColor,
                                                        fontSize: 11,
                                                        fontFamily: fontFamilyRegular,
                                                      ),
                                                      overflow: TextOverflow.ellipsis,
                                                      maxLines: 1,
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: commonButton(
                                    title: "Next".tr,
                                    onTapp: () {
                                      debugPrint("======= lorrynumber ====== ${attachLorryController.lorrynumber.text}");
                                      debugPrint("====== numberTonnes ====== ${attachLorryController.numberTonnes.text}");
                                      debugPrint("======= vehicleID ======== ${attachLorryController.vehicleID}");
                                      if (attachLorryController.lorrynumber.text.isNotEmpty && attachLorryController.numberTonnes.text.isNotEmpty) {
                                        if (attachLorryController.vehicleID.isNotEmpty && attachLorryController.selectVehicle != -1) {
                                          Get.to(
                                            AttachLorry1(
                                              lorryNumber: attachLorryController.lorrynumber.text,
                                              numberOfTonnes: attachLorryController.numberTonnes.text,
                                              vehicleId: attachLorryController.vehicleID,
                                            ),
                                          );
                                        } else {
                                          showCommonToast("Select Vehicle".tr);
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
