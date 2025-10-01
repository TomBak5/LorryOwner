import 'dart:convert';

import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'package:movers_lorry_owner/widgets/widgets.dart';
import 'package:onesignal_flutter/onesignal_flutter.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../Api_Provider/api_provider.dart';
import '../AppConstData/routes.dart';
// import 'package:onesignal_flutter/onesignal_flutter.dart';

class LoginScreenController extends GetxController implements GetxService {
  TextEditingController emailController = TextEditingController();
  TextEditingController passwordController = TextEditingController();

  bool isEmail = false;
  bool isPassword = true; // Always show password field
  bool isShowPassword = true;
  bool isPassValid = false;

  void setIsEmail(bool value) {
    isEmail = value;
    update();
  }

  void setIsPassValid(bool value) {
    isPassValid = value;
    update();
  }

  void setShowPassword() {
    isShowPassword = !isShowPassword;
    update();
  }

  bool isLoading = false;
  setIsLoading(value) {
    isLoading = value;
    update();
  }

  // New email/password login logic
  checkController({required String email, required String password, context}) {
    setIsLoading(true);
    if (emailController.text.isEmpty) {
      setIsEmail(true);
      setIsLoading(false);
      return;
    }
    if (passwordController.text.isEmpty) {
      setIsPassValid(true);
      setIsLoading(false);
      return;
    }
    ApiProvider().loginUserWithEmail(
      email: email,
      password: password,
              ).then((value) async {
              var data = value;
              if (data["Result"] == "true") {
                final SharedPreferences prefs = await SharedPreferences.getInstance();
                String decodeData = jsonEncode(data["UserLogin"]);
                await prefs.setString("userData", decodeData);
                OneSignal.User.addTagWithKey("user_id", data["UserLogin"]["id"]);
                Get.offAllNamed(Routes.landingPage);
              } else {
                // Removed: if ((data["ResponseMsg"] ?? "").trim().isNotEmpty) { showCommonToast(data["ResponseMsg"]); }
              }
              setIsLoading(false);
      });
  }

  // Google Sign-In functionality
  final FirebaseAuth _auth = FirebaseAuth.instance;

  Future<void> signInWithGoogle(context) async {
    try {
      setIsLoading(true);
      
      // Try with minimal configuration first
      final GoogleSignIn googleSignIn = GoogleSignIn();
      
      // Trigger the authentication flow
      final GoogleSignInAccount? googleUser = await googleSignIn.signIn();
      
      if (googleUser == null) {
        // User cancelled the sign-in
        setIsLoading(false);
        return;
      }

      // Obtain the auth details from the request
      final GoogleSignInAuthentication googleAuth = await googleUser.authentication;

      // Create a new credential
      final credential = GoogleAuthProvider.credential(
        accessToken: googleAuth.accessToken,
        idToken: googleAuth.idToken,
      );

      // Sign in to Firebase with the Google credential
      final UserCredential userCredential = await _auth.signInWithCredential(credential);
      final User? user = userCredential.user;

      if (user != null) {
        // Successfully signed in with Google and Firebase
        print("Google Sign-In successful: ${user.email}");
        
        // Navigate to the landing page
        Get.offAllNamed(Routes.landingPage);
        
        showCommonToast("Successfully signed in with Google!");
      }
      
      setIsLoading(false);
    } catch (error) {
      setIsLoading(false);
      showCommonToast("Google Sign-In failed: ${error.toString()}");
      print("Google Sign-In Error: $error");
    }
  }

  // Sign out from Google
  Future<void> signOutGoogle() async {
    final GoogleSignIn googleSignIn = GoogleSignIn();
    await googleSignIn.disconnect();
    await _auth.signOut();
  }
}





// onesignal_flutter: ^3.5.1
