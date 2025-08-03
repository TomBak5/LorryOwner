// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
// import 'package:flutter_address_from_latlng/flutter_address_from_latlng.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';

import 'package:movers_lorry_owner/AppConstData/routes.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/attach_lorry_controller.dart';

class AttachLorry2 extends StatefulWidget {
  const AttachLorry2({
    super.key,
    required this.listOfStateId,
    required this.lorryNumber,
    required this.numberOfTones,
    required this.vehicleId,
  });

  final String lorryNumber;
  final String numberOfTones;
  final String vehicleId;
  final List listOfStateId;

  @override
  State<AttachLorry2> createState() => _AttachLorry2State();
}

class _AttachLorry2State extends State<AttachLorry2> {
  @override
  void initState() {
    attachLorryController.galleryListOfImages.clear();
    attachLorryController.passport = false;
    debugPrint("========== init lat ========== ${locationLatitude}");
    debugPrint("========= init long ========== ${locationLongtitude}");
    debugPrint("======= init reCodeId ======== ${reCodeId}");
    debugPrint("========== init uid ========== ${uid}");
    debugPrint("====== init lorryNumber ====== ${widget.lorryNumber}");
    debugPrint("===== init numberOfTones ===== ${widget.numberOfTones}");
    debugPrint("====== init description ====== ${description.text}");
    debugPrint("======= init vehicleId ======= ${widget.vehicleId}");
    debugPrint("======== init address ======== ${address}");
    debugPrint("======== init gallery ======== ${attachLorryController.galleryListOfImages}");
    super.initState();
    getGkey();
    getUidFromLocle();
  }

  String reCodeId = "";
  bool isloading = false;
  AttachLorryController attachLorryController = Get.put(AttachLorryController());
  final ImagePicker _picker = ImagePicker();
  String uid = "";
  bool isEdite = false;
  TextEditingController description = TextEditingController();

  double locationLatitude = 0.00;
  double locationLongtitude = 0.00;

  String gkey = "";
  getGkey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gkey = prefs.getString("gkey") ?? googleMapkey;
    });
  }

  getUidFromLocle() async {
    locationPermission().then((value) {
      debugPrint("======= value ======= $value");
      _getAddressFromLatLng();
    });
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      uid = preferences.getString("uid")!;
      String decoderes = preferences.getString("EditLorryData")!;
      if (decoderes.isNotEmpty) {
        Map decode = jsonDecode(decoderes);
        description.text = decode["description"];
        reCodeId = decode["record_id"];
        isEdite = decode["isedite"];
      }
    });
  }

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
                      ),
                    ],
                  ),
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
                              border: Border.all(color: Colors.white70),
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
                                color: Colors.white,
                                thickness: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white70),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "2",
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
                              "Vehicle Type".tr,
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
                                color: Colors.white,
                                thickness: 1.5,
                              ),
                            ),
                          ),
                          const SizedBox(width: 5),
                          Container(
                            height: 16,
                            width: 16,
                            decoration: BoxDecoration(
                              color: Colors.white,
                              border: Border.all(color: Colors.white70),
                              shape: BoxShape.circle,
                            ),
                            child: Center(
                              child: Text(
                                "3",
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
                            child: Text(
                              "Post".tr,
                              style: TextStyle(
                                overflow: TextOverflow.ellipsis,
                                fontFamily: fontFamilyBold,
                                fontSize: 12,
                                color: Colors.white,
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
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              "Description".tr,
                              style: TextStyle(
                                fontSize: 16,
                                color: textBlackColor,
                                fontFamily: fontFamilyBold,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                            SizedBox(height: 10),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      border: Border.all(
                                        color: Colors.grey.withOpacity(0.3),
                                      ),
                                    ),
                                    child: TextField(
                                      controller: description,
                                      decoration: const InputDecoration(
                                        border: InputBorder.none,
                                        contentPadding: EdgeInsets.zero,
                                        isDense: true,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(12),
                                      color: Colors.white,
                                      boxShadow: [
                                        BoxShadow(
                                          color: Colors.grey.withOpacity(0.5),
                                          blurRadius: 5,
                                          blurStyle: BlurStyle.outer,
                                        )
                                      ],
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/verify1.svg",
                                            ),
                                            const SizedBox(width: 8),
                                            Flexible(
                                              child: Text(
                                                "Upload lorry document (Required at least 2 document)".tr,
                                                style: TextStyle(
                                                  fontFamily: fontFamilyRegular,
                                                  fontSize: 16,
                                                  color: textBlackColor,
                                                  fontWeight: FontWeight.w400,
                                                  overflow: TextOverflow.ellipsis,
                                                ),
                                                maxLines: 3,
                                              ),
                                            )
                                          ],
                                        ),
                                        Divider(height: 20, color: textGreyColor.withOpacity(0.5)),
                                        ListTile(
                                          onTap: () {
                                            onlyIdentity(ImageSource.gallery);
                                          },
                                          contentPadding:
                                              const EdgeInsets.all(0),
                                          dense: true,
                                          trailing: attachLorryController.passport
                                              ? Checkbox(
                                                  activeColor: priMaryColor,
                                                  shape: const CircleBorder(),
                                                  value: true,
                                                  onChanged: (value) {},
                                                )
                                              : const SizedBox(),
                                          title: Transform.translate(
                                            offset: const Offset(-20, 0),
                                            child: Text(
                                              "Lorry Document".tr, 
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: fontFamilyRegular,
                                                color: textBlackColor,
                                              ),
                                            ),
                                          ),
                                          subtitle: Transform.translate(
                                            offset: const Offset(-20, 0),
                                            child: Text(
                                              "Haven't uploaded yet".tr,
                                              style: TextStyle(
                                                fontSize: 16,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: fontFamilyRegular,
                                                color: textGreyColor,
                                              ),
                                            ),
                                          ),
                                          leading: Transform.translate(
                                            offset: const Offset(0, 5),
                                            child: SizedBox(
                                              height: 24,
                                              width: 24,
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  "assets/icons/paperclip-2.svg",
                                                  width: 24,
                                                  height: 24,
                                                  color: textBlackColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 20),
                            attachLorryController.galleryListOfImages.isEmpty
                                ? const SizedBox()
                                : GridView.builder(
                                    itemCount: attachLorryController.galleryListOfImages.length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 2),
                                    itemBuilder: (context, index) {
                                      return attachLorryController.galleryListOfImages.isEmpty
                                          ? const SizedBox()
                                          : Stack(
                                              clipBehavior: Clip.none,
                                              alignment: Alignment.topRight,
                                              children: [
                                                Container(
                                                  height: 150,
                                                  margin: EdgeInsets.all(8),
                                                  width: 150,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    image: DecorationImage(
                                                      image: FileImage(File(attachLorryController.galleryListOfImages[index]!.path.toString())),
                                                      fit: BoxFit.cover,
                                                    ),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.5),
                                                        blurRadius: 5,
                                                        blurStyle: BlurStyle.outer,
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                                Positioned(
                                                  top: 5,
                                                  right: 5,
                                                  child: InkWell(
                                                    onTap: () {
                                                      attachLorryController.setRemoveImage(index);
                                                    },
                                                    child: CircleAvatar(
                                                      backgroundColor: priMaryColor,
                                                      radius: 10,
                                                      child: Center(
                                                        child: SvgPicture.asset(
                                                          "assets/icons/Union 3.svg",
                                                          color: Colors.white,
                                                          height: 10,
                                                          width: 10,
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            );
                                    },
                                  ),
                            const SizedBox(height: 20),
                            Row(
                              children: [
                                Expanded(
                                  child: commonButton(
                                    title: "Next",
                                    onTapp: () {
                                      debugPrint("========== lat ========== ${locationLatitude}");
                                      debugPrint("========= long ========== ${locationLongtitude}");
                                      debugPrint("======= reCodeId ======== ${reCodeId}");
                                      debugPrint("========== uid ========== ${uid}");
                                      debugPrint("====== lorryNumber ====== ${widget.lorryNumber}");
                                      debugPrint("===== numberOfTones ===== ${widget.numberOfTones}");
                                      debugPrint("====== description ====== ${description.text}");
                                      debugPrint("======= vehicleId ======= ${widget.vehicleId}");
                                      debugPrint("======== address ======== ${address}");
                                      _getAddressFromLatLng();
                                      setState(() {
                                        address = "Surat, Gujarat";
                                        // administrativeArea1!.formattedAddress!;
                                      });
                                      if (isEdite) {
                                        setState(() {
                                          isloading = true;
                                        });
                                        if (attachLorryController.galleryListOfImages.length == 2) {
                                          debugPrint("===== galleryListOfImages length ===== ${attachLorryController.galleryListOfImages.length}");
                                          debugPrint("======== galleryListOfImages ========= ${attachLorryController.galleryListOfImages}");
                                          ImageUploadApi().editeLorry(
                                            recodeId: reCodeId,
                                            ownerId: uid,
                                            lorryNo: widget.lorryNumber,
                                            widght: widget.numberOfTones,
                                            des: description.text,
                                            vehicleId: widget.vehicleId,
                                            currentlocation: address,
                                            image: attachLorryController.galleryListOfImages[0],
                                            image1: attachLorryController.galleryListOfImages[1],
                                            routes: widget.listOfStateId.join(","),
                                          ).then((value) async {
                                            decodeResponse(value);
                                            setState(() {
                                              isloading = false;
                                            });
                                          });
                                        } else {
                                          ImageUploadApi().editeLorry(
                                            recodeId: reCodeId,
                                            ownerId: uid,
                                            lorryNo: widget.lorryNumber,
                                            widght: widget.numberOfTones,
                                            des: description.text,
                                            vehicleId: widget.vehicleId,
                                            currentlocation: address,
                                            routes: widget.listOfStateId.join(","),
                                          ).then((value) async {
                                            decodeResponse(value);
                                            setState(() {
                                              isloading = false;
                                            });
                                          });
                                        }
                                      } else {
                                        if (attachLorryController.galleryListOfImages.length == 2) {
                                          setState(() {
                                            isloading = true;
                                          });
                                          ApiProvider().addLorry(
                                            image: attachLorryController.galleryListOfImages[0],
                                            image1: attachLorryController.galleryListOfImages[1],
                                            ownerId: uid,
                                            lorryNo: widget.lorryNumber,
                                            widght: widget.numberOfTones,
                                            des: description.text,
                                            vehicleId: widget.vehicleId,
                                            currentlocation: address,
                                            routes: widget.listOfStateId.join(","),
                                          ).then((value) {
                                            var decode = value;
                                            if (decode["Result"] == "true") {
                                              setState(() {
                                                isloading = false;
                                              });
                                              Get.offAllNamed(Routes.landingPage);
                                              if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                                showCommonToast(decode["ResponseMsg"]);
                                              }
                                            } else {
                                              setState(() {
                                                isloading = false;
                                              });
                                              if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                                showCommonToast(decode["ResponseMsg"]);
                                              }
                                            }
                                          });
                                        } else {
                                          showCommonToast("Enter Required lorry Document".tr);
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
              isloading
                  ? const Center(child: CircularProgressIndicator())
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  decodeResponse(value) async {
    debugPrint("========= value ========= $value");
    if (value["Result"] == "true") {
      setState(() {
        isloading = false;
      });
      SharedPreferences preferences = await SharedPreferences.getInstance();
      preferences.setString("EditLorryData", "");
      Get.offAllNamed(Routes.landingPage);
      if ((value["ResponseMsg"] ?? "").trim().isNotEmpty) {
        showCommonToast(value["ResponseMsg"]);
      }
    } else {
      setState(() {
        isloading = false;
      });
      if ((value["ResponseMsg"] ?? "").trim().isNotEmpty) {
        showCommonToast(value["ResponseMsg"]);
      }
    }
  }

  String address = "";
  Future<void> _getAddressFromLatLng() async {
    // TODO: Implement address lookup using geocoding package
    setState(() {
      address = "Surat, Gujarat";
    });
  }

  onlyIdentity(ImageSource source) async {
    if (attachLorryController.galleryListOfImages.length < 2) {
      final XFile? image = await _picker.pickImage(source: source);
      attachLorryController.setAddGallery(image);
      print("======== image xFile ======= ${image}");
      if (attachLorryController.galleryListOfImages.length == 2) {
        attachLorryController.setPassport(true);
      }
    } else {
      showCommonToast("Document Max 2 Picture Selected From Gallery".tr);
    }
  }
}
