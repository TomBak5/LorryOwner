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
    _routeBasedOnUser();
  }

  Future<void> _routeBasedOnUser() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    await Future.delayed(const Duration(seconds: 2));
    String? userData = prefs.getString('userData');
    if (userData != null && userData.isNotEmpty) {
      try {
        final decoded = userData.isNotEmpty ? userData : null;
        if (decoded != null && decoded.contains('id') && !decoded.contains('"id":""')) {
          Get.offAllNamed(Routes.landingPage); // or Routes.homePage if you have a dedicated home route
          return;
        }
      } catch (e) {}
    }
    Get.offAllNamed(Routes.welcomeScreen); // Changed to new welcome screen
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
              child: Image.asset(
                "assets/logo/truckbuddy_logo.png",
                width: double.infinity,
                height: 140,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 32),
            const CircularProgressIndicator(),
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
