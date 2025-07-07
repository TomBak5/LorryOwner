// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../Api_Provider/api_provider.dart';
import '../AppConstData/app_colors.dart';
import '../AppConstData/typographyy.dart';
import '../Controllers/singiup_controller.dart';
import '../models/contry_code_model.dart';
import '../widgets/widgets.dart';

class SingUp extends StatefulWidget {
  const SingUp({super.key});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  SingUpController singUpController = Get.put(SingUpController());
  late ContryCodeModel countryCodeList;
  bool isloading = true;

  bool baa = false;

  @override
  void initState() {
    super.initState();

    ApiProvider().getCountryCode().then((value) {
      setState(() {
        countryCodeList = value;
        isloading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    singUpController.isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<SingUpController>(
      builder: (singUpController) {
        return isloading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : SafeArea(
                child: Scaffold(
                  body: Stack(
                    alignment: Alignment.bottomCenter,
                    children: [
                      commonBg(),
                      Container(
                          padding: const EdgeInsets.all(24),
                          height: Get.height * 0.68,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            color: whiteColor,
                          ),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              SingleChildScrollView(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      "Getting Started!".tr,
                                      style: Typographyy.headLine.copyWith(fontSize: 20),
                                    ),
                                    const SizedBox(height: 10),
                                    Text(
                                      "Seems you are new here, Let’s set up your profile.".tr,
                                      style: Typographyy.titleText,
                                      textAlign: TextAlign.center,
                                    ),
                                    SizedBox(height: Get.height * 0.03),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: DropdownButtonFormField(
                                            menuMaxHeight: 300,
                                            decoration: InputDecoration(
                                              hintText: 'Code',
                                              contentPadding: EdgeInsets.all(12),
                                              hintStyle: TextStyle(fontSize: 14),
                                              border: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: textGreyColor),
                                              ),
                                              enabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide( color: textGreyColor),
                                              ),
                                              disabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: textGreyColor),
                                              ),
                                              focusedBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(color: textGreyColor),
                                              ),
                                            ),
                                            dropdownColor: Colors.white,
                                            onChanged: (newValue) {
                                              singUpController.countryData(newValue);
                                            },
                                            value: singUpController.countryCode,
                                            items: countryCodeList.countryCode.map<DropdownMenuItem>((m) {
                                              return DropdownMenuItem(
                                                value: m.ccode,
                                                child: Text(m.ccode),
                                              );
                                            }).toList(),
                                          ),
                                        ),
                                        const SizedBox(width: 8),
                                        Expanded(
                                          flex: 2,
                                          child: commonTextField(
                                            controller: singUpController.mobileController,
                                            hintText: "Mobile Number",
                                            keyBordType: TextInputType.number,
                                            isValide: singUpController.isMobileNumber,
                                            onTap: (value) {
                                              if (value.isEmpty) {
                                                singUpController.setIsMobileNumber(false);
                                              } else {
                                                singUpController.setIsMobileNumber(singUpController.mobileController.text.isEmpty);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 12),
                                    commonTextField(
                                      controller: singUpController.fullNameController,
                                      hintText: "Full Name",
                                      keyBordType: TextInputType.text,
                                      isValide: singUpController.isFullName,
                                      onTap: (value) {
                                        if (value.isEmpty) {
                                          singUpController.setIsFullName(false);
                                        } else {
                                          singUpController.setIsFullName(singUpController.fullNameController.text.isEmpty);
                                        }
                                      },
                                    ),
                                    SizedBox(height: 12),
                                    commonTextField(
                                      controller: singUpController.emailController,
                                      hintText: "Email Address",
                                      keyBordType: TextInputType.text,
                                      isValide: singUpController.emailAddress,
                                      onTap: (value) {
                                        if (value.isEmpty) {
                                          singUpController.setEmailAddress(false);
                                        } else {
                                          singUpController.setEmailAddress(singUpController.emailController.text.isEmpty);
                                        }
                                      },
                                    ),
                                    const SizedBox(height: 12),
                                    TextField(
                                      onChanged: (value) {
                                        if (value.isEmpty) {
                                          singUpController.setPassWord(false);
                                        } else {
                                          singUpController.setPassWord(singUpController.passwordController.text.isEmpty);
                                        }
                                      },
                                      controller: singUpController.passwordController,
                                      obscureText: singUpController.isPasswordShow,
                                      style: TextStyle(
                                        color: textBlackColor,
                                        fontFamily: "urbani_regular",
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            singUpController.setIsPasswordShow();
                                          },
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              singUpController.passWord
                                                  ? SizedBox(
                                                width: 22,
                                                height: 22,
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    "assets/icons/alert-circle.svg",
                                                    color: Colors.red,
                                                    height: 22,
                                                    width: 22,
                                                  ),
                                                ),
                                              )
                                                  : SizedBox(),
                                              SizedBox(width: 8),
                                              SizedBox(
                                                height: 20,
                                                width: 20,
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    singUpController.isPasswordShow
                                                        ? "assets/icons/eye-off.svg"
                                                        : "assets/icons/eye-2.svg",
                                                    color: textGreyColor,
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 8),
                                            ],
                                          ),
                                        ),
                                        hintText: "Password".tr,
                                        contentPadding: EdgeInsets.all(15),
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
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        SizedBox(
                                          height: 20,
                                          width: 30,
                                          child: Checkbox(
                                            activeColor: secondaryColor,
                                            shape: RoundedRectangleBorder(
                                              borderRadius: BorderRadius.circular(3),
                                            ),
                                            value: singUpController.istreamAndCondition,
                                            onChanged: (value) {
                                              singUpController.setIstreamAndCondition();
                                            },
                                          ),
                                        ),
                                        SizedBox(width: 8),
                                        Flexible(
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "By creating an account, you agree to our ",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: "urbani_regular",
                                                    fontWeight: FontWeight.w400,
                                                    color: textGreyColor,
                                                    height: 1.7,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: "Term and Conditions",
                                                  style: TextStyle(
                                                    fontSize: 13,
                                                    fontFamily: "urbani_regular",
                                                    fontWeight: FontWeight.w700,
                                                    color: secondaryColor,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: Get.height * 0.05),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: commonButton(
                                            title: "Sign up",
                                            onTapp: () {
                                              initPlatformState();
                                              if (singUpController.fullNameController.text.isNotEmpty && singUpController.emailController.text.isNotEmpty && singUpController.mobileController.text.isNotEmpty && singUpController.passwordController.text.isNotEmpty) {
                                                singUpController.setIsLoading(true);
                                                singUpController.getDataFromApi(context);
                                              }
                                              if (singUpController.emailController.text.isEmpty) {
                                                singUpController.setEmailAddress(true);
                                              }
                                              if (singUpController.mobileController.text.isEmpty) {
                                                singUpController.setIsMobileNumber(true);
                                              }
                                              if (singUpController.fullNameController.text.isEmpty) {
                                                singUpController.setIsFullName(true);
                                              }
                                              if (singUpController.passwordController.text.isEmpty) {
                                                singUpController.setPassWord(true);
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        RichText(
                                          text: TextSpan(children: [
                                            TextSpan(
                                              text: "Already have an account?  ".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "urbani_regular",
                                                color: textGreyColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "Login".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "urbani_regular",
                                                color: secondaryColor,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  Get.back();
                                                },
                                            ),
                                          ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                              singUpController.isLoading
                                  ? CircularProgressIndicator()
                                  : SizedBox(),
                            ],
                          ),
                        ),
                      Positioned(
                        top: 0,
                        left: 0,
                        child: InkWell(
                          onTap: () {
                            Get.back();
                          },
                          child: Padding(
                            padding: EdgeInsets.all(15.0),
                            child: SvgPicture.asset(
                              "assets/icons/angle-left-circle.svg",
                              color: Colors.white,
                              width: 28,
                              height: 28,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              );
      },
    );
  }
}
