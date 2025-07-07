// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import 'package:movers_lorry_owner/AppConstData/app_colors.dart';
import 'package:movers_lorry_owner/models/contry_code_model.dart';

import '../Api_Provider/api_provider.dart';
import '../AppConstData/managepage.dart';
import '../AppConstData/routes.dart';
import '../AppConstData/typographyy.dart';
import '../Controllers/login_screen_controller.dart';
import '../widgets/widgets.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  LoginScreenController loginScreenController = Get.put(LoginScreenController());

  late ContryCodeModel countryCodeList;
  String countryCode = '+91';
  bool isloading = true;

  @override
  void dispose() {
    super.dispose();
    isloading = true;
  }

  @override
  void initState() {
    super.initState();
    ManagePageCalling().setOnBoarding(false);
    ApiProvider().getCountryCode().then((value) {
      setState(() {
        countryCodeList = value;
        isloading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LoginScreenController>(
      builder: (loginScreenController) {
        return isloading
            ? Scaffold(body: Center(child: CircularProgressIndicator()))
            : Scaffold(
                body: Stack(
                  children: [
                    Stack(
                      alignment: Alignment.bottomCenter,
                      children: [
                        SingleChildScrollView(
                          child: Column(
                            children: [
                              Stack(
                                children: [
                                  Container(height: Get.height),
                                  Container(
                                    height: Get.height * 0.50,
                                    width: Get.width,
                                    decoration: const BoxDecoration(
                                      image: DecorationImage(
                                        image: AssetImage(
                                          "assets/image/Image (14).png",
                                        ),
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                        Container(
                          padding: const EdgeInsets.all(24),
                          height: Get.height * 0.55,
                          decoration: BoxDecoration(
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(16),
                            ),
                            color: whiteColor,
                          ),
                          child: Column(
                            children: [
                              Text(
                                "Welcome Back!".tr,
                                style: Typographyy.headLine,
                              ),
                              const SizedBox(height: 10),
                              Text(
                                "Let’s login for explore continues".tr,
                                style: Typographyy.titleText,
                              ),
                              SizedBox(height: Get.height * 0.03),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Mobile Number".tr,
                                    style: TextStyle(
                                      color: textBlackColor,
                                      fontFamily: "urbani_extrabold",
                                      fontSize: 18,
                                      fontWeight: FontWeight.w700,
                                    ),
                                  ),
                                  const SizedBox(height: 8),
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
                                              borderSide: BorderSide(color: textGreyColor),
                                            ),
                                            disabledBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide(color: textGreyColor),
                                            ),
                                            focusedBorder: OutlineInputBorder(
                                              borderRadius: BorderRadius.circular(12),
                                              borderSide: BorderSide( color: textGreyColor),
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
                                          controller: loginScreenController.mobileController,
                                          hintText: "Mobile Number",
                                          keyBordType: TextInputType.number,
                                          isValide: loginScreenController.isMobile,
                                          onTap: (value) {
                                            if (value.isEmpty) {
                                              loginScreenController.setIsMobile(false);
                                            } else {
                                              loginScreenController.setIsMobile(
                                                loginScreenController.mobileController.text.isEmpty,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  loginScreenController.isPassword
                                      ? const SizedBox(height: 15)
                                      : const SizedBox(),
                                  loginScreenController.isPassword
                                      ? Row(
                                          children: [
                                            Expanded(
                                              child: TextField(
                                                onChanged: (value) {
                                                  if (value.isEmpty) {
                                                    loginScreenController.setIsPassValid(false);
                                                  } else {
                                                    loginScreenController.setIsPassValid(
                                                      loginScreenController.passwordController.text.isEmpty,
                                                    );
                                                  }
                                                },
                                                obscureText: loginScreenController.isShowPassword,
                                                controller: loginScreenController.passwordController,
                                                decoration: InputDecoration(
                                                  suffixIcon: SizedBox(
                                                    width: 20,
                                                    height: 20,
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () {
                                                          loginScreenController.setShowPassword();
                                                        },
                                                        child: Row(
                                                          mainAxisSize: MainAxisSize.min,
                                                          children: [
                                                            loginScreenController.isPassValid
                                                                ? SvgPicture
                                                                    .asset(
                                                                    "assets/icons/alert-circle.svg",
                                                                    height: 20,
                                                                    width: 20,
                                                                    color: Colors.red,
                                                                  )
                                                                : const SizedBox(),
                                                            SvgPicture.asset(
                                                              loginScreenController
                                                                      .isShowPassword
                                                                  ? "assets/icons/eye-off.svg"
                                                                  : "assets/icons/eye-2.svg",
                                                              height: 20,
                                                              width: 20,
                                                              color: textGreyColor,
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                  hintStyle: TextStyle(fontSize: 14),
                                                  hintText: "Password".tr,
                                                  contentPadding: EdgeInsets.symmetric(
                                                    vertical: 15,
                                                    horizontal: 15,
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
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      : const SizedBox(),
                                  const SizedBox(height: 12),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.end,
                                    children: [
                                      InkWell(
                                        onTap: () {
                                          Get.toNamed(Routes.forgotPassword);
                                        },
                                        child: Text(
                                          "Forgot Password?".tr,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                            fontFamily: "urbani_extrabold",
                                            color: secondaryColor,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 14),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: commonButton(
                                          title: "Login",
                                          onTapp: () {
                                            if (loginScreenController.mobileController.text.isEmpty) {
                                              loginScreenController.setIsMobile(true);
                                            } else {
                                              initPlatformState();
                                              loginScreenController.checkController(
                                                code: countryCode,
                                                context: context,
                                              );
                                            }
                                          },
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 16),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      RichText(
                                        text: TextSpan(
                                          children: [
                                            TextSpan(
                                              text: "Don’t have an account?  ".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400,
                                                fontFamily: "urbani_regular",
                                                color: textGreyColor,
                                              ),
                                            ),
                                            TextSpan(
                                              text: "Sign up".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w600,
                                                fontFamily: "urbani_regular",
                                                color: secondaryColor,
                                              ),
                                              recognizer: TapGestureRecognizer()
                                                ..onTap = () {
                                                  Get.toNamed(Routes.singUp);
                                                },
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ],
                          ),
                        )
                      ],
                    ),
                    loginScreenController.isLoading
                        ? const Center(child: CircularProgressIndicator())
                        : const SizedBox(),
                  ],
                ),
              );
      },
    );
  }
}

// Future<void> initPlatformState() async {
//   OneSignal.shared.setAppId("1c8f864c-950b-4c9e-8ca1-59285bf78f0a");
//   OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {});
//   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//     log("Accepted OSPermissionStateChanges : $changes");
//   });
// }

//9998464304


// 9284798223
// 1234

//9377336366

//9638166340

//1c8f864c-950b-4c9e-8ca1-59285bf78f0a