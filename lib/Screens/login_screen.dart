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
                    SingleChildScrollView(
                      padding: EdgeInsets.symmetric(horizontal: 24.0, vertical: 48.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.stretch,
                        children: [
                          // Add the logo image at the top, centered
                          Center(
                            child: Image.asset(
                              'assets/logo/truckbuddy_logo.png',
                              height: 80, // Adjust as needed
                              fit: BoxFit.contain,
                            ),
                          ),
                          const SizedBox(height: 24),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                "Email",
                                style: TextStyle(
                                  color: textBlackColor,
                                  fontFamily: "urbani_extrabold",
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                ),
                              ),
                              const SizedBox(height: 8),
                              commonTextField(
                                controller: loginScreenController.emailController,
                                hintText: "Email",
                                keyBordType: TextInputType.emailAddress,
                                isValide: loginScreenController.isEmail,
                                onTap: (value) {
                                  if (value.isEmpty) {
                                    loginScreenController.setIsEmail(false);
                                  } else {
                                    loginScreenController.setIsEmail(
                                      loginScreenController.emailController.text.isEmpty,
                                    );
                                  }
                                },
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
                              // After the main Login button, add social sign-in buttons
                              const SizedBox(height: 24),
                              Row(
                                children: [
                                  Expanded(child: Divider(thickness: 1.2, color: Colors.grey)),
                                  Padding(
                                    padding: EdgeInsets.symmetric(horizontal: 12.0),
                                    child: Text('Or', style: TextStyle(fontSize: 16, color: Colors.grey, fontWeight: FontWeight.w500)),
                                  ),
                                  Expanded(child: Divider(thickness: 1.2, color: Colors.grey)),
                                ],
                              ),
                              const SizedBox(height: 16),
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      side: BorderSide(color: Colors.grey.shade300),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: Image.asset(
                                      'assets/icons/google.png',
                                      height: 24,
                                      width: 24,
                                    ),
                                    label: Text('Google'),
                                    onPressed: () {
                                      // TODO: Implement Google sign-in
                                    },
                                  ),
                                  const SizedBox(height: 12),
                                  ElevatedButton.icon(
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.white,
                                      foregroundColor: Colors.black,
                                      side: BorderSide(color: Colors.grey.shade300),
                                      padding: EdgeInsets.symmetric(vertical: 12),
                                    ),
                                    icon: Icon(Icons.facebook, size: 24, color: Color(0xFF1877F3)), // Facebook blue icon
                                    label: Text('Facebook'),
                                    onPressed: () {
                                      // TODO: Implement Facebook sign-in
                                    },
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ],
                      ),
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