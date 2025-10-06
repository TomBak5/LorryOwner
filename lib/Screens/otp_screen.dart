// ignore_for_file: deprecated_member_use, use_build_context_synchronously

import 'dart:async';
import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:truckbuddy/Api_Provider/api_provider.dart';
import 'package:truckbuddy/AppConstData/routes.dart';
import 'package:truckbuddy/Controllers/singiup_controller.dart';
import 'package:otp_text_field/otp_field.dart';
import 'package:otp_text_field/style.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../AppConstData/app_colors.dart';
import '../AppConstData/typographyy.dart';
import '../Controllers/creatnew_pass_controller.dart';
import '../widgets/widgets.dart';
import 'sub_pages/account_info_screen.dart';

class OtpScreen extends StatefulWidget {
  final String mobileNumber;
  final String ccode;
  final bool isSingup;
  const OtpScreen({
    super.key,
    required this.mobileNumber,
    required this.isSingup,
    required this.ccode,
  });

  @override
  State<OtpScreen> createState() => _OtpScreenState();
}

class _OtpScreenState extends State<OtpScreen> {
  OtpFieldController otpController = OtpFieldController();
  CreateNewPasswordController createNewPasswordController =
      Get.put(CreateNewPasswordController());

  @override
  void initState() {
    apiCallingFunction();
    super.initState();
  }

  Timer? timer;
  int start = 0;

  String apiOtp = "";

  apiCallingFunction() {
    ApiProvider().send_otp(number: "${widget.mobileNumber}").then(
      (value) {
        debugPrint("======= send value ======= $value");
        if (value["Result"] == "true") {
          apiOtp = value["otp"].toString();
        }
      },
    );
    start = 30;
    setState(() {});
    startTimer();
  }

  void startTimer() {
    const oneSec = const Duration(seconds: 1);
    timer = new Timer.periodic(
      oneSec,
      (Timer timer) {
        if (start == 0) {
          setState(() {
            timer.cancel();
          });
        } else {
          setState(() {
            start--;
          });
        }
      },
    );
  }

  String otpCode = '';
  bool isLoading = false;
  
  @override
  Widget build(BuildContext context) {
    return SafeArea(
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
                      borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
                      color: whiteColor,
                    ),
                    child: Column(
                      children: [
                        Text(
                          "OTP Verification".tr,
                          style: Typographyy.headLine.copyWith(fontSize: 20),
                        ),
                        const SizedBox(height: 10),
                        RichText(
                          textAlign: TextAlign.center,
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "Please, enter the verification code we send to your mobile ".tr,
                                style: Typographyy.titleText,
                              ),
                              TextSpan(
                                text: "${widget.ccode}${widget.mobileNumber}",
                                style: Typographyy.headLine.copyWith(fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                        SizedBox(height: Get.height * 0.03),
                        OTPTextField(
                          controller: otpController,
                          length: 6,
                          width: MediaQuery.of(context).size.width,
                          textFieldAlignment: MainAxisAlignment.spaceAround,
                          fieldWidth: 40,
                          fieldStyle: FieldStyle.box,
                          outlineBorderRadius: 15,
                          style: const TextStyle(
                            fontSize: 17,
                            fontWeight: FontWeight.w500,
                            fontFamily: "urbani_extrabold",
                          ),
                          onChanged: (pin) {},
                          onCompleted: (pin) {
                            setState(() {
                              otpCode = pin;
                              debugPrint("=========== otpcode ========= $otpCode");
                            });
                          },
                        ),
                        const SizedBox(height: 24),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            InkWell(
                              onTap: () {
                                if (start == 0) {
                                  apiCallingFunction();
                                }
                              },
                              child: Text(
                                "Resend code",
                                style: TextStyle(
                                  fontFamily: "urbani_extrabold",
                                  fontWeight: FontWeight.w700,
                                  fontSize: 16,
                                  color: start == 0
                                      ? secondaryColor
                                      : textGreyColor,
                                ),
                              ),
                            ),
                            start == 0
                                ? Container()
                                : Text(
                                    "${start} ${"Second Wait".tr}",
                                    style: TextStyle(
                                      fontFamily: "urbani_extrabold",
                                      fontSize: 15,
                                      color: secondaryColor,
                                    ),
                                  ),
                          ],
                        ),
                        const SizedBox(height: 24),
                        Row(
                          children: [
                            Expanded(
                              child: commonButton(
                                title: "Verify Account",
                                onTapp: () async {
                                  setState(() {
                                    isLoading = true;
                                  });
                                  if (apiOtp == otpCode) {
                                    try {
                                      final SharedPreferences prefs = await SharedPreferences.getInstance();
                                      if (widget.isSingup) {
                                        // Don't register here - just store temp data and proceed to account info
                                        // Registration will happen in account_info_screen.dart after collecting all data
                                        setState(() {
                                          isLoading = false;
                                        });
                                        
                                        // Get user role from stored data and navigate to account info screen
                                        String? encodeData = prefs.getString("tempUserData");
                                        if (encodeData != null) {
                                          var tempdatafromlocal = jsonDecode(encodeData);
                                          String userRole = tempdatafromlocal["userRole"] ?? "driver";
                                          Get.off(() => AccountInfoScreen(userRole: userRole));
                                        } else {
                                          // Fallback to driver role if no data stored
                                          Get.off(() => AccountInfoScreen(userRole: "driver"));
                                        }
                                      } else {
                                        String? encodeData = prefs.getString("tempForgotpassData");
                                        var tempdatafromlocal = jsonDecode(encodeData!);
                                        createNewPasswordController .mobileNumber1 = tempdatafromlocal["mobileNumber"];
                                        createNewPasswordController.ccode1 = tempdatafromlocal["ccode"];
                                        Get.offNamed(Routes.createNewPassword)?.then((value) {
                                          prefs.setString("tempForgotpassData", "");
                                        });
                                      }
                                    } catch (e) {
                                      setState(() {
                                        isLoading = false;
                                      });
                                      showCommonToast(e.toString());
                                    }
                                  } else {
                                    showCommonToast("Otp Not valid");
                                    setState(() {
                                      isLoading = false;
                                    });
                                  }
                                },
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  isLoading
                      ? Center(child: CircularProgressIndicator())
                      : SizedBox(),
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
  }
}
