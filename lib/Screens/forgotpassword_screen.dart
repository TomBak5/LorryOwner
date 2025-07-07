// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/AppConstData/routes.dart';
import 'package:movers_lorry_owner/Controllers/creatnew_pass_controller.dart';
import 'package:movers_lorry_owner/Screens/otp_screen.dart';
import 'package:movers_lorry_owner/models/contry_code_model.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api_Provider/api_provider.dart';
import '../AppConstData/app_colors.dart';
import '../AppConstData/typographyy.dart';
import '../Controllers/forgotpassword_controller.dart';
import '../widgets/widgets.dart';

class ForgotPassword extends StatefulWidget {
  const ForgotPassword({super.key});

  @override
  State<ForgotPassword> createState() => _ForgotPasswordState();
}

class _ForgotPasswordState extends State<ForgotPassword> {
  TextEditingController mobileController = TextEditingController();

  late ContryCodeModel countryCodeList;
  String countryCode = '+91';
  bool isloading = true;
  ForgotPasswordController forgotPasswordController = Get.put(ForgotPasswordController());
  CreateNewPasswordController createNewPasswordController = Get.put(CreateNewPasswordController());

  @override
  void initState() {
    super.initState();
    ApiProvider().getCountryCode().then((value) async {
      setState(() {
        countryCodeList = value;
        isloading = false;
      });
    });
  }

  @override
  void dispose() {
    super.dispose();
    forgotPasswordController.isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ForgotPasswordController>(
      builder: (forgotPasswordController) {
        return isloading
            ? const Scaffold(body: Center(child: CircularProgressIndicator()))
            : SafeArea(
                child: Scaffold(
                  body: SingleChildScrollView(
                    physics: const NeverScrollableScrollPhysics(),
                    child: Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        commonBg(),
                        Stack(
                          alignment: Alignment.center,
                          children: [
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
                                  Column(
                                    children: [
                                      Text(
                                        "Forgot Password".tr,
                                        style: Typographyy.headLine.copyWith(fontSize: 20),
                                      ),
                                      const SizedBox(height: 10),
                                      Text(
                                        "If A Match is Found, The System Sends An Mobile To The User's Registered Mobile Number With Instructions For Resetting Their Password.".tr,
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
                                                hintText: 'Code'.tr,
                                                contentPadding: EdgeInsets.all(12),
                                                hintStyle: const TextStyle(
                                                  fontSize: 14,
                                                ),
                                                border: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: textGreyColor),
                                                ),
                                                enabledBorder: OutlineInputBorder(
                                                  borderRadius: BorderRadius.circular(12),
                                                  borderSide: BorderSide(color: textGreyColor),
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
                                                setState(() {
                                                  countryCode = newValue!;
                                                });
                                              },
                                              value: countryCode,
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
                                              controller: mobileController,
                                              hintText: "Mobile Number",
                                              keyBordType: TextInputType.number,
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 54),
                                      Row(
                                        children: [
                                          Expanded(
                                            child: commonButton(
                                              title: "Continue",
                                              onTapp: () async {
                                                final SharedPreferences prefs = await SharedPreferences.getInstance();
                                                  forgotPasswordController.setIsLoading(value: true);
                                                  forgotPasswordController.setTempDataIn(
                                                    mobile: mobileController.text.trim(),
                                                    ccode: countryCode,
                                                  );
                                                  ApiProvider().checkMobileNumber(
                                                    number: mobileController.text,
                                                    code: countryCode,
                                                  ).then((value) {
                                                    if (value["Result"] == "true") {
                                                      showCommonToast("Number is not register");
                                                      forgotPasswordController.setIsLoading(value: false);
                                                    } else {
                                                      if (value["otp_auth"] == "No") {
                                                        String? encodeData = prefs.getString("tempForgotpassData");
                                                        var tempdatafromlocal = jsonDecode(encodeData!);
                                                        createNewPasswordController.mobileNumber1 = tempdatafromlocal["mobileNumber"];
                                                        createNewPasswordController.ccode1 = tempdatafromlocal["ccode"];
                                                        Get.offNamed(Routes.createNewPassword)?.then((value) {
                                                          prefs.setString("tempForgotpassData","");
                                                        });
                                                      } else {
                                                        Get.to(
                                                          OtpScreen(
                                                            mobileNumber: mobileController.text.trim(),
                                                            ccode: countryCode,
                                                            isSingup: false,
                                                          ),
                                                        );
                                                      }
                                                    }
                                                  });
                                              },
                                            ),
                                          ),
                                        ],
                                      ),
                                      SizedBox(height: 16),
                                      Row(
                                        mainAxisAlignment: MainAxisAlignment.center,
                                        children: [
                                          RichText(
                                            text: TextSpan(
                                              children: [
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
                                  const SizedBox(),
                                ],
                              ),
                            ),
                            forgotPasswordController.isLoading
                                ? Center(child: CircularProgressIndicator())
                                : const SizedBox()
                          ],
                        ),
                        Positioned(
                          top: 0,
                          left: 0,
                          child: InkWell(
                            onTap: () {
                              Get.back();
                            },
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
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
                ),
              );
      },
    );
  }
}
