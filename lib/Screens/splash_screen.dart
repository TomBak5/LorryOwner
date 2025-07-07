import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppConstData/routes.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  bool? isOnBoring;
  bool? isLogin;
  @override
  void initState() {
    super.initState();

    getDataFromLocal();
    Future.delayed(
      const Duration(seconds: 3),
      () async {
        if (isOnBoring!) {
          Get.offAllNamed(Routes.onBoardingScreens);
        } else if (isLogin!) {
          Get.offAllNamed(Routes.loginScreen);
        } else if (isOnBoring! == false && isLogin! == false) {
          Get.offAllNamed(Routes.landingPage);
        }
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Center(
              child: SvgPicture.asset(
                "assets/logo/Group 427320347.svg",
                height: 60,
                width: 60,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Future getDataFromLocal() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      isOnBoring = prefs.getBool("IsOnBoaring") ?? true;
      isLogin = prefs.getBool("isLogin") ?? true;
    });
  }
}
