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
import 'main_pages/home_page.dart';
import 'congratulations_screen.dart';
import 'sub_pages/truck_info_screen.dart';
import 'sub_pages/account_info_screen.dart';

class SingUp extends StatefulWidget {
  const SingUp({super.key});

  @override
  State<SingUp> createState() => _SingUpState();
}

class _SingUpState extends State<SingUp> {
  SingUpController singUpController = Get.put(SingUpController());
  late ContryCodeModel countryCodeList;
  bool isloading = true;
  bool hasError = false;
  String errorMessage = '';

  bool baa = false;

  @override
  void initState() {
    super.initState();
    ApiProvider().getCountryCode().then((value) {
      setState(() {
        countryCodeList = value;
        isloading = false;
        hasError = false;
      });
    }).catchError((e) {
      setState(() {
        isloading = false;
        hasError = true;
        errorMessage = 'Failed to load country codes. Please try again later.';
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
            : hasError
                ? Scaffold(
                    body: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(errorMessage, style: TextStyle(color: Colors.red)),
                          SizedBox(height: 16),
                          ElevatedButton(
                            onPressed: () {
                              setState(() {
                                isloading = true;
                                hasError = false;
                              });
                              ApiProvider().getCountryCode().then((value) {
                                setState(() {
                                  countryCodeList = value;
                                  isloading = false;
                                  hasError = false;
                                });
                              }).catchError((e) {
                                setState(() {
                                  isloading = false;
                                  hasError = true;
                                  errorMessage = 'Failed to load country codes. Please try again later.';
                                });
                              });
                            },
                            child: Text('Retry'),
                          ),
                        ],
                      ),
                    ),
                  )
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
                                      "Truck buddy",
                                      style: Typographyy.headLine.copyWith(fontSize: 20),
                                    ),
                                    const SizedBox(height: 10),
                                    SizedBox(height: Get.height * 0.03),
                                    // Email field
                                    TextField(
                                      controller: singUpController.emailController,
                                      keyboardType: TextInputType.emailAddress,
                                      onChanged: (value) { print('Email input: ' + value); },
                                            decoration: InputDecoration(
                                        hintText: "Email Address",
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
                                        hintStyle: TextStyle(color: textGreyColor, fontFamily: "urbani_regular", fontSize: 14),
                                        contentPadding: EdgeInsets.symmetric(vertical: 15, horizontal: 15),
                                      ),
                                    ),
                                    const SizedBox(height: 12),
                                    // Password field
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
                                    const SizedBox(height: 12),
                                    // Confirm Password field
                                    TextField(
                                      controller: singUpController.confirmPasswordController,
                                      obscureText: singUpController.isConfirmPasswordShow,
                                      style: TextStyle(
                                        color: textBlackColor,
                                        fontFamily: "urbani_regular",
                                        fontSize: 16,
                                      ),
                                      decoration: InputDecoration(
                                        suffixIcon: InkWell(
                                          onTap: () {
                                            setState(() {
                                              singUpController.isConfirmPasswordShow = !singUpController.isConfirmPasswordShow;
                                            });
                                          },
                                          child: SvgPicture.asset(
                                            singUpController.isConfirmPasswordShow
                                                ? "assets/icons/eye-off.svg"
                                                : "assets/icons/eye-2.svg",
                                            color: textGreyColor,
                                          ),
                                        ),
                                        hintText: "Confirm Password",
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
                                    const SizedBox(height: 12),
                                    // Role selector (Driver/Dispatcher)
                                    Align(
                                      alignment: Alignment.centerLeft,
                                      child: Text(
                                        'Select account type',
                                        style: TextStyle(
                                          fontSize: 15,
                                          fontWeight: FontWeight.w500,
                                          color: textGreyColor,
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10),
                                    Row(
                                      children: [
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => singUpController.setSelectedRole('dispatcher'),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: singUpController.selectedRole == 'dispatcher' ? Colors.white : Colors.transparent,
                                                border: Border.all(
                                                  color: singUpController.selectedRole == 'dispatcher' ? secondaryColor : textGreyColor,
                                                  width: 2,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.account_circle_outlined, color: singUpController.selectedRole == 'dispatcher' ? secondaryColor : textGreyColor),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Dispatcher',
                                                      style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: singUpController.selectedRole == 'dispatcher' ? secondaryColor : textGreyColor,
                                                      ),
                                                    ),
                                                  ),
                                                  if (singUpController.selectedRole == 'dispatcher')
                                                    Icon(Icons.check_circle, color: secondaryColor)
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: 12),
                                        Expanded(
                                          child: GestureDetector(
                                            onTap: () => singUpController.setSelectedRole('driver'),
                                            child: Container(
                                              padding: EdgeInsets.symmetric(vertical: 16, horizontal: 12),
                                              decoration: BoxDecoration(
                                                color: singUpController.selectedRole == 'driver' ? Colors.white : Colors.transparent,
                                                border: Border.all(
                                                  color: singUpController.selectedRole == 'driver' ? secondaryColor : textGreyColor,
                                                  width: 2,
                                                ),
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              child: Row(
                                                children: [
                                                  Icon(Icons.local_shipping_outlined, color: singUpController.selectedRole == 'driver' ? secondaryColor : textGreyColor),
                                                  SizedBox(width: 8),
                                                  Expanded(
                                                    child: Text(
                                                      'Driver',
                                                  style: TextStyle(
                                                        fontSize: 16,
                                                        fontWeight: FontWeight.w600,
                                                        color: singUpController.selectedRole == 'driver' ? secondaryColor : textGreyColor,
                                                      ),
                                                    ),
                                                  ),
                                                  if (singUpController.selectedRole == 'driver')
                                                    Icon(Icons.check_circle, color: secondaryColor)
                                                ],
                                              ),
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
                                              print("Sign Up button pressed");
                                              initPlatformState();
                                              // Only require email and password
                                              if (singUpController.emailController.text.isEmpty ||
                                                  singUpController.passwordController.text.isEmpty) {
                                                showCommonToast("Please enter email and password");
                                                return;
                                              }
                                              singUpController.setIsLoading(true);
                                              // In the onTapp for the Sign up button, branch based on selectedRole
                                              if (singUpController.selectedRole == 'dispatcher') {
                                                // Go to Account Info screen for dispatcher
                                                Get.to(() => AccountInfoScreen(userRole: 'dispatcher'));
                                              } else {
                                                // Existing driver flow
                                                singUpController.setUserData(
                                                  context,
                                                  email: singUpController.emailController.text,
                                                  pass: singUpController.passwordController.text,
                                                  ccode: '',
                                                  name: '',
                                                  mobile: '',
                                                  reff: '',
                                                  userRole: '',
                                                );
                                                // Add navigation to TruckInfoScreen after registration
                                                singUpController.setIsLoading(false);
                                                Get.toNamed('/truckInfo');
                                              }
                                            },
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 10),
                                    // Skip button
                                    TextButton(
                                      onPressed: () {
                                        Get.offAll(() => HomePage());
                                      },
                                      child: Text('Skip', style: TextStyle(color: secondaryColor, fontSize: 16)),
                                    ),
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
