// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/managepage.dart';
import '../../AppConstData/routes.dart';
import '../../AppConstData/setlanguage.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/homepage_controller.dart';
import '../../Controllers/profile_controller.dart';
import '../../widgets/widgets.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  ProfileController profileController = Get.put(ProfileController());
  HomePageController homePageController = Get.put(HomePageController());

  late LocaleModel localeModel;
  String uid = "";
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    homePageController.getDataFromLocalData().then((value) async {
      final prefs = await SharedPreferences.getInstance();
      uid = prefs.getString("uid")!;
      localeModel = LocaleModel(prefs);
      if (value.toString().isNotEmpty) {
        isLoading = false;
      }
    });
  }

  @override
  void dispose() {
    super.dispose();
    isLoading = true;
  }

  final ImagePicker _picker = ImagePicker();
  XFile? image;

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ProfileController>(
      builder: (profileController) {
        return GetBuilder<HomePageController>(
          builder: (homePageController) {
            return SafeArea(
              child: isLoading
                  ? const Scaffold(body: Center(child: CircularProgressIndicator()))
                  : Scaffold(
                      backgroundColor: Colors.white,
                      appBar: PreferredSize(
                        preferredSize: const Size.fromHeight(170),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Container(
                              height: 50,
                              color: Colors.white,
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    "Profile".tr,
                                    style: TextStyle(
                                      fontFamily: fontFamilyBold,
                                      fontWeight: FontWeight.w500,
                                      fontSize: 20,
                                      color: textBlackColor,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Flexible(
                              child: ListTile(
                                contentPadding: const EdgeInsets.symmetric(vertical: 25, horizontal: 15),
                                tileColor: priMaryColor,
                                title: Text(
                                  homePageController.userData?.name ?? '',
                                  style: TextStyle(
                                    fontSize: 20,
                                    color: Colors.white,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: fontFamilyBold,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                ),
                                subtitle: Transform.translate(
                                  offset: const Offset(0, 5),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      Text(
                                        homePageController.userData?.email ?? '',
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: fontFamilyRegular,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                      const SizedBox(height: 2),
                                      Text(
                                        "${homePageController.userData?.ccode ?? ''}  ${homePageController.userData?.mobile ?? ''}",
                                        style: TextStyle(
                                          color: Colors.white.withOpacity(0.8),
                                          fontFamily: fontFamilyRegular,
                                          fontSize: 12,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ],
                                  ),
                                ),
                                trailing: InkWell(
                                  onTap: () {
                                    _buildBottomSheet(
                                      number: "${homePageController.userData?.ccode ?? ''}  ${homePageController.userData?.mobile ?? ''}",
                                      password: homePageController.userData?.password ?? '',
                                      name: homePageController.userData?.name ?? '',
                                      email: homePageController.userData?.email ?? '',
                                      uid: homePageController.userData?.id ?? '',
                                    );
                                  },
                                  child: SizedBox(
                                    height: 18,
                                    width: 18,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/edit-2.svg",
                                        width: 18,
                                        height: 18,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                                ),
                                leading: Transform.translate(
                                  offset: const Offset(0, -8),
                                  child: InkWell(
                                    onTap: () async {
                                      image = await _picker.pickImage(
                                        source: ImageSource.gallery,
                                      ).then((value) {
                                        ApiProvider().editImage(
                                          uid: homePageController.userData?.id ?? '',
                                          image: value!,
                                        ).then((value) async {
                                          var dataaa = value;
                                          if (dataaa["Result"] == "true") {
                                            if ((dataaa["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                              showCommonToast(dataaa["ResponseMsg"]);
                                            }
                                            final SharedPreferences prefs = await SharedPreferences.getInstance();
                                            String decodeData = jsonEncode(dataaa["UserLogin"]);
                                            await prefs.setString("userData", decodeData);
                                            homePageController.getDataFromLocalData().then((value) {
                                              if (value.toString().isNotEmpty) {
                                                // homePageController.getHomePageData(uid:homePageController.userData.id ?? '');
                                              }
                                            });
                                          } else {
                                            if ((dataaa["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                              showCommonToast(dataaa["ResponseMsg"]);
                                            }
                                          }
                                        });
                                        return null;
                                      });
                                    },
                                    child: Stack(
                                      clipBehavior: Clip.none,
                                      alignment: Alignment.topRight,
                                      children: [
                                        Container(
                                          decoration: BoxDecoration(
                                            border:Border.all(color: Colors.white),
                                            shape: BoxShape.circle,
                                          ),
                                          child: homePageController.userData?.proPic.toString().isNotEmpty ?? false
                                              ? CircleAvatar(
                                                  backgroundColor:Colors.transparent,
                                                  radius: 30,
                                                  backgroundImage: NetworkImage(
                                                    "$basUrl${homePageController.userData?.proPic}",
                                                  ),
                                                )
                                              : const CircleAvatar(
                                                  backgroundColor:Colors.transparent,
                                                  backgroundImage: AssetImage(
                                                    "assets/image/05.png",
                                                  ),
                                                  radius: 25,
                                                ),
                                        ),
                                        CircleAvatar(
                                          radius: 10,
                                          backgroundColor: Colors.white,
                                          child: Center(
                                            child: SvgPicture.asset(
                                              "assets/icons/edit-2.svg",
                                              width: 12,
                                              height: 12,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      body: SingleChildScrollView(
                        child: Column(
                          children: [
                            Padding(
                              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 8),
                              child: ListView.separated(
                                physics: const NeverScrollableScrollPhysics(),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return ListTile(
                                    onTap: () {
                                      if (index == 2) {
                                        Get.bottomSheet(
                                          isScrollControlled: true,
                                          Container(
                                            padding: const EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              color: Colors.white,
                                            ),
                                            child: ListView.separated(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                return InkWell(
                                                  onTap: () {
                                                    switch (index) {
                                                      case 0:
                                                        Get.updateLocale(Locale('en', 'US'));
                                                        localeModel.set(Locale('en', 'US'));
                                                        Get.back();
                                                        break;
                                                      case 1:
                                                        Get.updateLocale(Locale('sp', 'GE'));
                                                        localeModel.set(Locale('sp', 'GE'));
                                                        Get.back();
                                                        break;
                                                      case 2:
                                                        Get.updateLocale(Locale('ur', 'ar'));
                                                        localeModel.set(Locale('ur', 'ar'));
                                                        Get.back();
                                                        break;
                                                      case 3:
                                                        Get.updateLocale(Locale('hi', 'IN'));
                                                        localeModel.set(Locale('hi', 'IN'));
                                                        Get.back();
                                                        break;
                                                      case 4:
                                                        Get.updateLocale(Locale('ge', 'In'));
                                                        localeModel.set(Locale('ge', 'In'));
                                                        Get.back();
                                                        break;
                                                      case 5:
                                                        Get.updateLocale(Locale('af', 'ge'));
                                                        localeModel.set(Locale('af', 'ge'));
                                                        Get.back();
                                                        break;
                                                      case 6:
                                                        Get.updateLocale(Locale('be', 'ge'));
                                                        localeModel.set(Locale('be', 'ge'));
                                                        Get.back();
                                                        break;
                                                      case 7:
                                                        Get.updateLocale(Locale('Id', 'Ge'));
                                                        localeModel.set(Locale('Id', 'Ge'));
                                                        Get.back();
                                                    }
                                                  },
                                                  child: Row(
                                                    mainAxisAlignment: MainAxisAlignment.start,
                                                    children: [
                                                      SizedBox(
                                                        height: 30,
                                                        width: 30,
                                                        child: CircleAvatar(
                                                          backgroundImage: AssetImage(
                                                            profileController.countryLogo[index],
                                                          ),
                                                          backgroundColor: Colors.transparent,
                                                        ),
                                                      ),
                                                      const SizedBox(width: 8),
                                                      Text(
                                                        profileController.nameOfCountry[index].toString(),
                                                        style: TextStyle(
                                                          color: textBlackColor,
                                                          fontSize: 15,
                                                          fontFamily: fontFamilyRegular,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                );
                                              },
                                              separatorBuilder: (context, index) {
                                                return Divider(color: Colors.grey.withOpacity(0.3),height: 20);
                                              },
                                              itemCount: profileController.nameOfCountry.length,
                                            ),
                                          ),
                                        );
                                      } else if (index == profileController.pagesPath.length - 1) {
                                        homePageController.removeData();
                                        ManagePageCalling().setLogin(true);
                                        Get.offAllNamed(Routes.loginScreen);
                                      } else {
                                        Get.toNamed(profileController.pagesPath[index]);
                                      }
                                    },
                                    trailing: SizedBox(
                                      height: 20,
                                      width: 20,
                                      child: Center(
                                        child: SvgPicture.asset(
                                          "assets/icons/arrow-right.svg",
                                          color: textBlackColor,
                                        ),
                                      ),
                                    ),
                                    contentPadding: EdgeInsets.zero,
                                    dense: true,
                                    leading: SizedBox(
                                      height: 24,
                                      width: 24,
                                      child: Center(
                                        child: SvgPicture.asset(
                                          profileController.itemIcons[index],
                                          width: 24,
                                          height: 24,
                                        ),
                                      ),
                                    ),
                                    title: Text(
                                      profileController.items[index].toString().tr,
                                      style: TextStyle(
                                        color: textBlackColor,
                                        fontWeight: FontWeight.w500,
                                        fontSize: 16,
                                        fontFamily: fontFamilyBold,
                                      ),
                                    ),
                                  );
                                },
                                separatorBuilder: (context, index) {
                                  return Divider(height: 18,color: textGreyColor);
                                },
                                itemCount: profileController.items.length,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
            );
          },
        );
      },
    );
  }

  Future _buildBottomSheet({
    required String number,
    required String email,
    required String name,
    required String password,
    required String uid,
  }) {
    profileController.nameController.text = name;
    profileController.passController.text = password;
    return Get.bottomSheet(
      isScrollControlled: true,
      backgroundColor: Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(
          top: Radius.circular(16),
        ),
      ),
      GetBuilder<ProfileController>(
        builder: (profileController) {
          return Padding(
            padding: const EdgeInsets.all(24.0),
            child: SingleChildScrollView(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Edit Profile",
                    style: TextStyle(
                      fontFamily: fontFamilyBold,
                      fontSize: 20,
                      fontWeight: FontWeight.w500,
                      color: textBlackColor,
                    ),
                  ),
                  Divider(height: 40, color: textGreyColor),
                  TextField(
                    decoration: InputDecoration(
                      hintText: number,
                      enabled: false,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontFamily: fontFamilyRegular,
                        color: textBlackColor,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: textGreyColor.withOpacity(0.5),
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: textGreyColor.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: textGreyColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(
                    height: 12,
                  ),
                  TextField(
                    decoration: InputDecoration(
                      hintText: email,
                      enabled: false,
                      hintStyle: TextStyle(
                        fontSize: 15,
                        fontWeight: FontWeight.w400,
                        fontFamily: fontFamilyRegular,
                        color: textBlackColor,
                      ),
                      contentPadding: const EdgeInsets.all(15),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: textGreyColor.withOpacity(0.5),
                        ),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: textGreyColor.withOpacity(0.5),
                        ),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(12),
                        borderSide: BorderSide(
                          color: textGreyColor.withOpacity(0.5),
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  commonTextField(
                    controller: profileController.nameController,
                    hintText: "Name",
                    keyBordType: TextInputType.text,
                  ),
                  const SizedBox(height: 12),
                  TextField(
                    obscureText: profileController.isPasswordShow,
                    style: TextStyle(
                      color: textBlackColor,
                      fontFamily: "urbani_regular",
                      fontSize: 16,
                    ),
                    controller: profileController.passController,
                    decoration: InputDecoration(
                      suffixIcon: InkWell(
                        onTap: () {
                          profileController.setIsPasswordShow();
                        },
                        child: SizedBox(
                          height: 20,
                          width: 20,
                          child: Center(
                            child: SvgPicture.asset(
                              profileController.isPasswordShow
                                  ? "assets/icons/eye-off.svg"
                                  : "assets/icons/eye-2.svg",
                              color: textGreyColor,
                            ),
                          ),
                        ),
                      ),
                      hintText: "password".tr,
                      contentPadding: const EdgeInsets.all(15),
                      hintStyle: TextStyle(
                        color: textGreyColor,
                        fontFamily: "urbani_regular",
                        fontSize: 16,
                      ),
                      border: OutlineInputBorder(
                        borderSide: BorderSide(color: textGreyColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textGreyColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      disabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: textGreyColor),
                        borderRadius: BorderRadius.circular(12),
                      ),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      Expanded(
                        child: commonButton(
                          title: "Update",
                          onTapp: () {
                            ApiProvider().editProfile(
                              name: profileController.nameController.text,
                              pass: profileController.passController.text,
                              uid: uid).then(
                              (value) async {
                                var decodeString = value;
                                if (decodeString["Result"] == "true") {
                                  if ((decodeString["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                    showCommonToast(decodeString["ResponseMsg"]);
                                  }
                                  final SharedPreferences prefs = await SharedPreferences.getInstance();
                                  String decodeData = jsonEncode(decodeString["UserLogin"]);
                                  await prefs.setString("userData", decodeData);
                                  Get.back();
                                  homePageController.getDataFromLocalData().then((value) {
                                    if (value.toString().isNotEmpty) {
                                      // homePageController.getHomePageData(uid: homePageController.userData.id ?? '');
                                    }
                                  });
                                } else {
                                  if ((decodeString["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                    showCommonToast(decodeString["ResponseMsg"]);
                                  }
                                }
                              },
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
