// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../Api_Provider/api_provider.dart';
import '../AppConstData/app_colors.dart';
import '../Controllers/creatnew_pass_controller.dart';
import '../widgets/widgets.dart';
import 'login_screen.dart';

class CreateNewPassword extends StatefulWidget {
  const CreateNewPassword({super.key});

  @override
  State<CreateNewPassword> createState() => _CreateNewPasswordState();
}

class _CreateNewPasswordState extends State<CreateNewPassword> {
  CreateNewPasswordController createNewPasswordController = Get.put(CreateNewPasswordController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<CreateNewPasswordController>(
      builder: (createNewPasswordController) {
        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              Padding(
                padding: const EdgeInsets.all(24),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Image.asset(
                      "assets/logo/truckbuddy_logo.png",
                      width: 150,
                      height: 80,
                      color: priMaryColor,
                    ),
                    SizedBox(height: Get.height * 0.18),
                    Text(
                      "Enter new Password".tr,
                      style: TextStyle(
                        fontSize: 21,
                        color: secondaryColor,
                        fontWeight: FontWeight.w500,
                        fontFamily: "urbani_regular",
                      ),
                    ),
                    const SizedBox(height: 25),
                    TextField(
                      controller: createNewPasswordController.password,
                      obscureText: createNewPasswordController.isPasswordShow,
                      style: TextStyle(
                        color: textBlackColor,
                        fontFamily: "urbani_regular",
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            createNewPasswordController.setIsPasswordShow();
                          },
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: SvgPicture.asset(
                                createNewPasswordController.isPasswordShow
                                    ? "assets/icons/eye-off.svg"
                                    : "assets/icons/eye-2.svg",
                                color: textGreyColor,
                              ),
                            ),
                          ),
                        ),
                        hintText: "Password".tr,
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
                    const SizedBox(height: 15),
                    TextField(
                      controller: createNewPasswordController.cpassword,
                      obscureText: createNewPasswordController.isNewPasswordShow,
                      style: TextStyle(
                        color: textBlackColor,
                        fontFamily: "urbani_regular",
                        fontSize: 16,
                      ),
                      decoration: InputDecoration(
                        suffixIcon: InkWell(
                          onTap: () {
                            createNewPasswordController.setIsNewPasswordShow();
                          },
                          child: SizedBox(
                            height: 20,
                            width: 20,
                            child: Center(
                              child: SvgPicture.asset(
                                createNewPasswordController.isNewPasswordShow
                                    ? "assets/icons/eye-off.svg"
                                    : "assets/icons/eye-2.svg",
                                color: textGreyColor,
                              ),
                            ),
                          ),
                        ),
                        hintText: "Confirm".tr,
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
                    const SizedBox(height: 25),
                    Row(
                      children: [
                        Expanded(
                          child: commonButton(
                            title: "Submit",
                            onTapp: () {
                              if (createNewPasswordController.password.text.toString().compareTo(createNewPasswordController.cpassword.text.toString()) == 0) {
                                ApiProvider().forgetPassword(
                                    mobile: createNewPasswordController.mobileNumber1!,
                                    password: createNewPasswordController.cpassword.text,
                                    ccode: createNewPasswordController.ccode1!,
                                  ).then((value) {
                                  var decode = value;
                                  if (decode["Result"] == "true") {
                                    Get.offAll(const LoginScreen());
                                    if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                      showCommonToast(decode["ResponseMsg"]);
                                    }
                                  } else {
                                    if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                      showCommonToast(decode["ResponseMsg"]);
                                    }
                                  }
                                });
                              } else {
                                showCommonToast("Enter Valid password");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              Positioned(
                top: 40,
                left: 0,
                child: InkWell(
                  onTap: () {
                    Get.back();
                  },
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SvgPicture.asset(
                      "assets/icons/angle-left-circle.svg",
                      color: priMaryColor,
                      width: 28,
                      height: 28,
                    ),
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
