// ignore_for_file: deprecated_member_use

import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';

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
        if (isloading) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          );
        }

        return Scaffold(
          backgroundColor: Colors.white,
          body: Stack(
            children: [
              // Main content
              SafeArea(
                child: Padding(
                  padding: EdgeInsets.symmetric(horizontal: 20.w),
                  child: Column(
                    children: [
                      // Logo at top - Group 17 (1)
                      SizedBox(height: 88.h), // 88px from top as per Figma
                      Center(
                        child: Image.asset(
                          'assets/logo/Group 17 (1).png',
                          width: 246.46.w,
                          height: 34.h,
                          fit: BoxFit.contain,
                        ),
                      ),
                      
                      SizedBox(height: 83.h), // Space to reach 205px from top
                      
                      // Main form container - Frame 427320694
                      Container(
                        width: 335.w,
                        height: 462.h,
                        child: Column(
                          children: [
                            // Form fields - Frame 427320663
                            Container(
                              width: 335.w,
                              height: 288.h,
                              child: Column(
                                children: [
                                  // Input fields - Frame 427320665
                                  Container(
                                    width: 335.w,
                                    height: 203.h,
                                    child: Column(
                                      children: [
                                        // Email field - Frame 427320660
                                        Container(
                                          width: 335.w,
                                          height: 75.h,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Email label
                                              Text(
                                                "Email",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.sp,
                                                  height: 1.5, // 21px line height
                                                  color: const Color(0xFF5E7389),
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              // Email input field
                                              Container(
                                                width: 335.w,
                                                height: 50.h,
                                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F6FB),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Center(
                                                  child: TextField(
                                                    controller: loginScreenController.emailController,
                                                    keyboardType: TextInputType.emailAddress,
                                                    textAlignVertical: TextAlignVertical.center,
                                                    decoration: InputDecoration(
                                                      hintText: "Enter your email",
                                                      hintStyle: TextStyle(
                                                        fontFamily: 'Poppins',
                                                        fontWeight: FontWeight.w400,
                                                        fontSize: 16.sp,
                                                        height: 1.5, // 24px line height
                                                        letterSpacing: 0.3,
                                                        color: const Color(0xFF5E7389),
                                                      ),
                                                      border: InputBorder.none,
                                                      enabledBorder: InputBorder.none,
                                                      focusedBorder: InputBorder.none,
                                                      errorBorder: InputBorder.none,
                                                      focusedErrorBorder: InputBorder.none,
                                                      disabledBorder: InputBorder.none,
                                                      contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                      isDense: true,
                                                    ),
                                                    onChanged: (value) {
                                                      if (value.isEmpty) {
                                                        loginScreenController.setIsEmail(false);
                                                      } else {
                                                        loginScreenController.setIsEmail(
                                                          loginScreenController.emailController.text.isEmpty,
                                                        );
                                                      }
                                                    },
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        SizedBox(height: 16.h),
                                        
                                        // Password field - Frame 427320661
                                        Container(
                                          width: 335.w,
                                          height: 75.h,
                                          child: Column(
                                            crossAxisAlignment: CrossAxisAlignment.start,
                                            children: [
                                              // Password label
                                              Text(
                                                "Password",
                                                style: TextStyle(
                                                  fontFamily: 'Poppins',
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 14.sp,
                                                  height: 1.5, // 21px line height
                                                  color: const Color(0xFF5E7389),
                                                ),
                                              ),
                                              SizedBox(height: 4.h),
                                              // Password input field
                                              Container(
                                                width: 335.w,
                                                height: 50.h,
                                                padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                                                decoration: BoxDecoration(
                                                  color: const Color(0xFFF1F6FB),
                                                  borderRadius: BorderRadius.circular(8.r),
                                                ),
                                                child: Row(
                                                  children: [
                                                    Expanded(
                                                      child: Center(
                                                        child: TextField(
                                                          controller: loginScreenController.passwordController,
                                                          obscureText: loginScreenController.isShowPassword,
                                                          textAlignVertical: TextAlignVertical.center,
                                                          decoration: InputDecoration(
                                                            hintText: "Enter your password",
                                                            hintStyle: TextStyle(
                                                              fontFamily: 'Poppins',
                                                              fontWeight: FontWeight.w400,
                                                              fontSize: 16.sp,
                                                              height: 1.5, // 24px line height
                                                              letterSpacing: 0.3,
                                                              color: const Color(0xFF5E7389),
                                                            ),
                                                            border: InputBorder.none,
                                                            enabledBorder: InputBorder.none,
                                                            focusedBorder: InputBorder.none,
                                                            errorBorder: InputBorder.none,
                                                            focusedErrorBorder: InputBorder.none,
                                                            disabledBorder: InputBorder.none,
                                                            contentPadding: EdgeInsets.symmetric(vertical: 0, horizontal: 0),
                                                            isDense: true,
                                                          ),
                                                        onChanged: (value) {
                                                          if (value.isEmpty) {
                                                            loginScreenController.setIsPassValid(false);
                                                          } else {
                                                            loginScreenController.setIsPassValid(
                                                              loginScreenController.passwordController.text.isEmpty,
                                                            );
                                                          }
                                                        },
                                                      ),
                                                    ),
                                                  ),
                                                    // Eye icon
                                                    GestureDetector(
                                                      onTap: () {
                                                        loginScreenController.setShowPassword();
                                                      },
                                                      child: Container(
                                                        width: 24.w,
                                                        height: 24.h,
                                                        child: Icon(
                                                          loginScreenController.isShowPassword
                                                              ? Icons.visibility_off
                                                              : Icons.visibility,
                                                          size: 20.sp,
                                                          color: const Color(0xFF5E7389),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        
                                        SizedBox(height: 16.h),
                                        
                                        // Forgot password
                                        Align(
                                          alignment: Alignment.centerRight,
                                          child: GestureDetector(
                                            onTap: () {
                                              Get.toNamed(Routes.forgotPassword);
                                            },
                                            child: Text(
                                              "Forget password?",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp,
                                                height: 1.5, // 21px line height
                                                color: const Color(0xFF1C3957),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  
                                  SizedBox(height: 32.h),
                                  
                                  // Login button - Frame 15
                                  GestureDetector(
                                    onTap: () {
                                      if (loginScreenController.emailController.text.isEmpty) {
                                        loginScreenController.setIsEmail(true);
                                      } else {
                                        initPlatformState();
                                        loginScreenController.checkController(
                                          email: loginScreenController.emailController.text,
                                          password: loginScreenController.passwordController.text,
                                          context: context,
                                        );
                                      }
                                    },
                                    child: Container(
                                      width: 335.w,
                                      height: 53.h,
                                      decoration: BoxDecoration(
                                        color: const Color(0xFF4964D8),
                                        borderRadius: BorderRadius.circular(8.r),
                                      ),
                                      child: Center(
                                        child: Text(
                                          "Login",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 14.sp,
                                            height: 1.5, // 21px line height
                                            color: Colors.white,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            
                            SizedBox(height: 24.h),
                            
                            // Social login section - Frame 6530
                            Container(
                              width: 335.w,
                              height: 150.h,
                              child: Column(
                                children: [
                                  // Divider with "or" text
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 1.h,
                                          color: const Color(0xFFD9D9D9),
                                        ),
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(horizontal: 16.w),
                                        child: Text(
                                          "or",
                                          style: TextStyle(
                                            fontFamily: 'Poppins',
                                            fontWeight: FontWeight.w400,
                                            fontSize: 12.sp,
                                            height: 1.33, // 16px line height
                                            color: const Color(0xFF929292),
                                          ),
                                        ),
                                      ),
                                      Expanded(
                                        child: Container(
                                          height: 1.h,
                                          color: const Color(0xFFD9D9D9),
                                        ),
                                      ),
                                    ],
                                  ),
                                  
                                  SizedBox(height: 16.h),
                                  
                                  // Social buttons
                                  Column(
                                    children: [
                                      // Google button
                                      Container(
                                        width: 335.w,
                                        height: 53.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFF0F0F0)),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/logo/image 24.png',
                                              width: 22.w,
                                              height: 22.h,
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              "Sign in with Google",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp,
                                                height: 1.5, // 21px line height
                                                color: const Color(0xFF151515),
                                              ),
                                            ),
                                          ],
                                        ),
                                      ),
                                      
                                      SizedBox(height: 12.h),
                                      
                                      // Facebook button
                                      Container(
                                        width: 335.w,
                                        height: 53.h,
                                        decoration: BoxDecoration(
                                          border: Border.all(color: const Color(0xFFF0F0F0)),
                                          borderRadius: BorderRadius.circular(8.r),
                                        ),
                                        child: Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            Image.asset(
                                              'assets/logo/Facebook - Original.png',
                                              width: 22.w,
                                              height: 22.h,
                                            ),
                                            SizedBox(width: 10.w),
                                            Text(
                                              "Sign in with Facebook",
                                              style: TextStyle(
                                                fontFamily: 'Poppins',
                                                fontWeight: FontWeight.w400,
                                                fontSize: 14.sp,
                                                height: 1.5, // 21px line height
                                                color: const Color(0xFF151515),
                                              ),
                                            ),
                                          ],
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
                    ],
                  ),
                ),
              ),
              
              // Bottom text - "Don't have an account"
              Positioned(
                left: 72.w,
                bottom: 32.h,
                child: RichText(
                  text: TextSpan(
                    children: [
                      TextSpan(
                        text: "Don't have an account? ",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          height: 1.57, // 22px line height
                          color: const Color(0xFF5E7389),
                        ),
                      ),
                      TextSpan(
                        text: "Sign up",
                        style: TextStyle(
                          fontFamily: 'Poppins',
                          fontWeight: FontWeight.w400,
                          fontSize: 14.sp,
                          height: 1.57, // 22px line height
                          color: const Color(0xFF1C3957),
                        ),
                        recognizer: TapGestureRecognizer()
                          ..onTap = () {
                            Get.toNamed(Routes.singUp);
                          },
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

// Future<void> initPlatformState() async {
//   OneSignal.shared.setAppId("1c8f864c-950b-4c9e-8ca1-59285bf78f0a");
//   OneSignal.shared.promptUserForPushNotificationPermission().then((accepted) {});
//   OneSignal.shared.setPermissionObserver((OSPermissionStateChanges changes) {
//     log("Accepted OSPermissionStateChanges : $changes");
//   });
// }