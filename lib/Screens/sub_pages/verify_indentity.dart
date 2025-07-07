// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/homepage_controller.dart';
import '../../Controllers/verify_identity_controller.dart';

class VerifyIdentity extends StatefulWidget {
  const VerifyIdentity({super.key});

  @override
  State<VerifyIdentity> createState() => _VerifyIdentityState();
}

class _VerifyIdentityState extends State<VerifyIdentity> {
  VerifyIdentityController verifyIdentityController = Get.put(VerifyIdentityController());
  HomePageController homePageController = Get.put(HomePageController());

  @override
  void dispose() {
    super.dispose();
    verifyIdentityController.isLoading = false;
    verifyIdentityController.camera = false;
    verifyIdentityController.passport = false;
    verifyIdentityController.listOfImages = [
      {
        "gallery": [],
        "camera": [],
      }
    ];
  }

  @override
  void initState() {
    super.initState();
    verifyIdentityController.statsCode = homePageController.userData.isVerify;
    verifyIdentityController.setStatus(
      setStatus(homePageController.userData.isVerify),
    );
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<VerifyIdentityController>(
      builder: (verifyIdentityController) {
        return Scaffold(
          appBar: AppBar(
            backgroundColor: Colors.white,
            elevation: 0,
            leading: InkWell(
              onTap: () {
                Get.back();
              },
              child: SizedBox(
                width: 22,
                height: 22,
                child: Center(
                  child: SvgPicture.asset(
                    "assets/icons/backicon.svg",
                    height: 22,
                    width: 22,
                    color: textBlackColor,
                  ),
                ),
              ),
            ),
          ),
          bottomNavigationBar: Builder(
            builder: (context) {
              if (verifyIdentityController.statsCode == "4") {
                if (verifyIdentityController.passport == true) {
                  return _buildSubmitButton();
                } else {
                  return const SizedBox();
                }
              } else if (verifyIdentityController.statsCode == "5") {
                if (verifyIdentityController.camera == true) {
                  return _buildSubmitButton();
                } else {
                  return const SizedBox();
                }
              } else {
                if (verifyIdentityController.camera == true &&
                    verifyIdentityController.passport == true) {
                  return _buildSubmitButton();
                } else {
                  return const SizedBox();
                }
              }
            },
          ),
          backgroundColor: Colors.white,
          body: Stack(
            alignment: Alignment.center,
            children: [
              SingleChildScrollView(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          RichText(
                            text: TextSpan(
                              children: [
                                TextSpan(
                                  text: "Verify".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: fontFamilyBold,
                                    fontWeight: FontWeight.w700,
                                    color: priMaryColor,
                                  ),
                                ),
                                TextSpan(text: " "),
                                TextSpan(
                                  text: "Indentity".tr,
                                  style: TextStyle(
                                    fontSize: 24,
                                    fontFamily: fontFamilyBold,
                                    fontWeight: FontWeight.w700,
                                    color: textBlackColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 10),
                          Text(
                            "Now we need to verify your identity".tr,
                            style: TextStyle(
                              fontSize: 16,
                              fontWeight: FontWeight.w400,
                              color: textGreyColor,
                              fontFamily: fontFamilyRegular,
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 18),
                    if (verifyIdentityController.statsCode == "4")
                      Column(children: [
                        _buildIdentity(),
                        gallerySelectImage(),
                        const SizedBox(height: 10),
                      ])
                    else if (verifyIdentityController.statsCode == "5")
                      Column(children: [_buildSelfie()])
                    else
                      Column(
                        children: [
                          _buildIdentity(),
                          gallerySelectImage(),
                          const SizedBox(height: 10),
                          _buildSelfie(),
                        ],
                      ),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15),
                      child: Wrap(
                        children: [
                          verifyIdentityController.listOfImages[0]["camera"].isEmpty
                              ? const SizedBox()
                              : SizedBox(
                                  width: 165,
                                  height: 165,
                                  child: ListView.builder(
                                    itemCount: verifyIdentityController.listOfImages[0]["camera"].length,
                                    shrinkWrap: true,
                                    physics: NeverScrollableScrollPhysics(),
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        clipBehavior: Clip.none,
                                        alignment: Alignment.topRight,
                                        children: [
                                          Container(
                                            height: 150,
                                            margin: const EdgeInsets.all(8),
                                            width: 150,
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              image: DecorationImage(
                                                image: FileImage(
                                                  File(
                                                    "${verifyIdentityController.listOfImages[0]["camera"][index]!.path}",
                                                  ),
                                                ),
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
                                                verifyIdentityController.setRemoveCamera(index);
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
                                ),
                        ],
                      ),
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: Container(
                            height: 90,
                            margin: const EdgeInsets.symmetric(horizontal: 15),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: textGreyColor.withOpacity(0.5),
                              ),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Center(
                              child: ListTile(
                                dense: true,
                                title: Text(
                                  "Note".tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    fontFamily: fontFamilyBold,
                                    fontWeight: FontWeight.w700,
                                    color: textBlackColor,
                                  ),
                                ),
                                subtitle: Text(
                                  "You are required to must upload both documents after the submit button appeared".tr,
                                  style: TextStyle(
                                    color: textGreyColor,
                                    fontFamily: fontFamilyRegular,
                                    fontSize: 12,
                                    fontWeight: FontWeight.w400,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                  maxLines: 3,
                                ),
                                leading: SvgPicture.asset(
                                  "assets/icons/security.svg",
                                ),
                                trailing: SizedBox(
                                  height: 20,
                                  width: 20,
                                  child: SvgPicture.asset(
                                    "assets/icons/arrow-right.svg",
                                    width: 20,
                                    height: 20,
                                    color: textGreyColor,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                  ],
                ),
              ),
              verifyIdentityController.isLoading
                  ? const CircularProgressIndicator()
                  : const SizedBox(),
            ],
          ),
        );
      },
    );
  }

  final ImagePicker _picker = ImagePicker();

  takePhoto(ImageSource source) async {
    if ((verifyIdentityController.listOfImages[0]["camera"].length +
            verifyIdentityController.listOfImages[0]["gallery"].length) <
        3) {
      if (source == ImageSource.camera) {
        if (verifyIdentityController.listOfImages[0]["camera"].length < 1) {
          final XFile? image = await _picker.pickImage(source: source);
          verifyIdentityController.setAddCamera(image);
          if (verifyIdentityController.listOfImages[0]["camera"].length == 1) {
            verifyIdentityController.setCamera(true);
          }
        } else {
          showCommonToast("Document Max 1 Picture Selected From Camera".tr);
        }
      } else {
        if (verifyIdentityController.listOfImages[0]["gallery"].length < 2) {
          final XFile? image = await _picker.pickImage(source: source);
          print("IMGAAA A ${image}");
          verifyIdentityController.setAddGallery(image);
          if (verifyIdentityController.listOfImages[0]["gallery"].length == 2) {
            verifyIdentityController.setPassport(true);
          }
        } else {
          showCommonToast("Document Max 2 Picture Selected From Gallery".tr);
        }
      }
    } else {
      showCommonToast("Document Max 3 Picture Selected".tr);
    }
  }

  onlyIdentity(ImageSource source) async {
    if (verifyIdentityController.listOfImages[0]["gallery"].length < 2) {
      final XFile? image = await _picker.pickImage(source: source);
      verifyIdentityController.setAddGallery(image);
      if (verifyIdentityController.listOfImages[0]["gallery"].length == 2) {
        verifyIdentityController.setPassport(true);
      }
    } else {
      showCommonToast("Document Max 2 Picture Selected From Gallery");
    }
  }

  onlySelfie(ImageSource source) async {
    if (verifyIdentityController.listOfImages[0]["camera"].length < 1) {
      final XFile? image = await _picker.pickImage(source: source);
      verifyIdentityController.setAddCamera(image);
      if (verifyIdentityController.listOfImages[0]["camera"].length == 1) {
        verifyIdentityController.setCamera(true);
      }
    } else {
      showCommonToast("Document Max 1 Picture Selected From Camera");
    }
  }

  setStatus(String isVerry) {
    switch (isVerry) {
      case "0":
        return "First";
      case "3":
        return "Both";
      case "4":
        return "Identity";
      case "5":
        return "Selfie";
      default:
        return "";
    }
  }

  Widget _buildIdentity() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icons/verify1.svg"),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Take a Passport or ID to Check Your Information(Upload at Least 2 document)".tr,
                            style: TextStyle(
                              fontFamily: fontFamilyRegular,
                              fontSize: 16,
                              color: textBlackColor,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20, color: textGreyColor.withOpacity(0.5)),
                    ListTile(
                      onTap: () {
                        if (verifyIdentityController.statsCode == "4") {
                          onlyIdentity(ImageSource.gallery);
                        } else {
                          takePhoto(ImageSource.gallery);
                        }
                      },
                      contentPadding: EdgeInsets.zero,
                      dense: true,
                      trailing: verifyIdentityController.passport
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
                          "Passport Scan".tr,
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
            )
          ],
        ),
        const SizedBox(height: 10),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Row(
        children: [
          Expanded(
            child: commonButton(
              title: "Submit All".tr,
              onTapp: () {
                verifyIdentityController.setIsLoading(true);
                if (verifyIdentityController.statsCode == "4") {
                  ImageUploadApi().upLoadDox(
                    image: verifyIdentityController.listOfImages[0]["gallery"][0],
                    uid: homePageController.userData.id,
                    image1: verifyIdentityController.listOfImages[0]["gallery"][1],
                    imageSelfie: null,
                    status: verifyIdentityController.status,
                  ).then((value) {
                    decodeResponse(value);
                  });
                } else if (verifyIdentityController.statsCode == "5") {
                  ImageUploadApi()
                      .upLoadDox(
                    uid: homePageController.userData.id,
                    imageSelfie: verifyIdentityController.listOfImages[0]["camera"][0],
                    status: verifyIdentityController.status,
                  ).then((value) {
                    decodeResponse(value);
                  });
                } else {
                  print("IMAGE ${verifyIdentityController.listOfImages[0]["gallery"][0]}");
                  ImageUploadApi().upLoadDox(
                    image: verifyIdentityController.listOfImages[0]["gallery"][0],
                    uid: homePageController.userData.id,
                    image1: verifyIdentityController.listOfImages[0]["gallery"][1],
                    imageSelfie: verifyIdentityController.listOfImages[0]["camera"][0],
                    status: verifyIdentityController.status,
                  ).then((value) {
                    decodeResponse(value);
                  });
                }
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSelfie() {
    return Column(
      children: [
        Row(
          children: [
            Expanded(
              child: Container(
                padding: const EdgeInsets.all(15),
                margin: const EdgeInsets.symmetric(horizontal: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  color: Colors.white,
                  boxShadow: [
                    BoxShadow(
                      color: Colors.grey.withOpacity(0.5),
                      blurRadius: 5,
                      blurStyle: BlurStyle.outer,
                    ),
                  ],
                ),
                child: Column(
                  children: [
                    Row(
                      children: [
                        SvgPicture.asset("assets/icons/verify2.svg"),
                        const SizedBox(width: 8),
                        Flexible(
                          child: Text(
                            "Selfie with your front camera to verify your identity".tr,
                            style: TextStyle(
                              fontFamily: fontFamilyRegular,
                              fontSize: 16,
                              color: textBlackColor,
                              fontWeight: FontWeight.w400,
                              overflow: TextOverflow.ellipsis,
                            ),
                            maxLines: 3,
                          ),
                        ),
                      ],
                    ),
                    Divider(height: 20, color: textGreyColor.withOpacity(0.5)),
                    ListTile(
                      onTap: () {
                        if (verifyIdentityController.statsCode == "5") {
                          onlySelfie(ImageSource.camera);
                        } else {
                          takePhoto(ImageSource.camera);
                        }
                      },
                      contentPadding: const EdgeInsets.all(0),
                      dense: true,
                      trailing: verifyIdentityController.camera
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
                          "Selfie".tr,
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
        SizedBox(height: 10),
      ],
    );
  }

  decodeResponse(value) {
    var decode = jsonDecode(value);
    if (decode["Result"] == "true") {
      Get.close(1);
      print("response >>>> >${decode["ResponseMsg"]}");
      print("STTUS LOADING >>>>> >${verifyIdentityController.isLoading}");
      homePageController.updateUserProfile(context);
      verifyIdentityController.setIsLoading(false);
      showCommonToast(decode["ResponseMsg"]);
    } else {
      print(">>>>>>response ${decode["ResponseMsg"]}");
      print(">>>>>>STTUS LOADING ${verifyIdentityController.isLoading}");
      verifyIdentityController.setIsLoading(false);
      showCommonToast(decode["ResponseMsg"]);
    }
  }

  gallerySelectImage() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15),
      child: Wrap(
        children: [
          verifyIdentityController.listOfImages[0]["gallery"].isEmpty
              ? const SizedBox()
              : GridView.builder(
                  itemCount: verifyIdentityController
                      .listOfImages[0]["gallery"].length,
                  shrinkWrap: true,
                  padding: EdgeInsets.zero,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 2,
                  ),
                  itemBuilder: (context, index) {
                    return Stack(
                      clipBehavior: Clip.none,
                      alignment: Alignment.topRight,
                      children: [
                        Container(
                          height: 150,
                          margin: const EdgeInsets.all(8),
                          width: 150,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(12),
                            image: DecorationImage(
                              image: FileImage(
                                File(
                                    "${verifyIdentityController.listOfImages[0]["gallery"][index]!.path}"),
                              ),
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
                              verifyIdentityController.setRemoveImage(index);
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
        ],
      ),
    );
  }
}
