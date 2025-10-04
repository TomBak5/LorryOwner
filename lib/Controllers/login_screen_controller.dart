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
      
      // Check if user has completed full registration
      final prefs = await SharedPreferences.getInstance();
      final hasCompletedRegistration = prefs.getBool('hasCompletedGoogleRegistration') ?? false;
      
      // Force account selection by signing out first (only if not completed registration)
      final GoogleSignIn googleSignIn = GoogleSignIn();
      if (!hasCompletedRegistration) {
        await googleSignIn.signOut(); // Force account selection
      }
      
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
        
        // Now register/login with the backend API
        await _registerOrLoginGoogleUser(user);
      }
      
      setIsLoading(false);
    } catch (error) {
      setIsLoading(false);
      showCommonToast("Google Sign-In failed: ${error.toString()}");
      print("Google Sign-In Error: $error");
    }
  }

  // Register or login Google user with backend
  Future<void> _registerOrLoginGoogleUser(User firebaseUser) async {
    try {
      // Try to login first with email
      final loginResponse = await ApiProvider().loginUserWithEmail(
        email: firebaseUser.email ?? '',
        password: firebaseUser.uid, // Use Firebase UID as password
      );

      if (loginResponse["Result"] == "true") {
        // User exists, check if they have a valid role
        final userData = loginResponse["UserLogin"];
        final userRole = userData["userRole"];
        
        // Debug: Print the entire user data to see what we're working with
        print("🔍 Full user data: $userData");
        print("🔍 User role field: '$userRole' (type: ${userRole.runtimeType})");
        
        // Check if user has a valid role (not empty or null)
        final roleString = userRole?.toString().toLowerCase().trim() ?? '';
        print("🔍 Processed role string: '$roleString'");
        
        // FORCE LOGIN: If user exists in database, always proceed with login
        // This prevents existing users from being sent to role selection
        print("✅ User exists in database, forcing login regardless of role data");
        await _saveUserDataAndNavigate(userData);
      } else {
        // User doesn't exist, need to register - navigate to role selection first
        await _navigateToRoleSelection(firebaseUser);
      }
    } catch (e) {
      print("Error registering/logging in Google user: $e");
      showCommonToast("Failed to complete sign-in: $e");
    }
  }
  
  // Navigate to role selection for new Google users
  Future<void> _navigateToRoleSelection(User firebaseUser) async {
    try {
      // Store Firebase user data temporarily for registration
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("tempGoogleUser", jsonEncode({
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'uid': firebaseUser.uid,
      }));
      
      // Navigate to role selection
      Get.toNamed(Routes.roleSelection);
    } catch (e) {
      print("Error navigating to role selection: $e");
      showCommonToast("Failed to proceed with registration: $e");
    }
  }
  
  // Navigate to role selection for existing Google users who need to complete onboarding
  Future<void> _navigateToRoleSelectionForExistingUser(User firebaseUser, dynamic existingUserData) async {
    try {
      // Store Firebase user data temporarily for role selection
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setString("tempGoogleUser", jsonEncode({
        'email': firebaseUser.email,
        'displayName': firebaseUser.displayName,
        'uid': firebaseUser.uid,
        'existingUser': true, // Flag to indicate this is an existing user
        'existingUserData': existingUserData, // Store existing user data
      }));
      
      // Navigate to role selection
      Get.toNamed(Routes.roleSelection);
    } catch (e) {
      print("Error navigating to role selection for existing user: $e");
      showCommonToast("Failed to proceed with role selection: $e");
    }
  }

  // Save user data and navigate to main screen
  Future<void> _saveUserDataAndNavigate(dynamic userData) async {
    try {
      // Debug: Print what we're about to save
      print("💾 Saving user data: $userData");
      print("💾 User role in data: '${userData["userRole"]}'");
      
      // Save user data to SharedPreferences
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      String encodedData = jsonEncode(userData);
      await prefs.setString("userData", encodedData);
      
      // Verify what was saved
      String? savedData = prefs.getString("userData");
      print("💾 Data saved to SharedPreferences: $savedData");

      // Set OneSignal user tag
      if (userData["id"] != null) {
        OneSignal.User.addTagWithKey("user_id", userData["id"]);
      }

      // Navigate to the landing page (main screen)
      Get.offAllNamed(Routes.landingPage);
    } catch (e) {
      print("Error saving user data: $e");
      showCommonToast("Failed to save user data: $e");
    }
  }

  // Sign out from Google
  Future<void> signOutGoogle() async {
    try {
      final GoogleSignIn googleSignIn = GoogleSignIn();
      await googleSignIn.signOut(); // Sign out from Google
      await _auth.signOut(); // Sign out from Firebase
      print("Successfully signed out from Google and Firebase");
    } catch (e) {
      print("Error signing out from Google/Firebase: $e");
    }
  }
  
  // Check if user is currently signed in to Google/Firebase
  Future<bool> isGoogleUserSignedIn() async {
    try {
      final currentUser = _auth.currentUser;
      if (currentUser != null) {
        // Check if the user has Google provider
        for (var provider in currentUser.providerData) {
          if (provider.providerId == 'google.com') {
            return true;
          }
        }
      }
      return false;
    } catch (e) {
      print("Error checking Google sign-in status: $e");
      return false;
    }
  }
}





// onesignal_flutter: ^3.5.1
