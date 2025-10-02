import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../Api_Provider/api_provider.dart';
import '../AppConstData/routes.dart';
import '../widgets/widgets.dart';

class RoleSelectionController extends GetxController implements GetxService {
  String selectedRole = 'driver'; // Default to driver
  bool isLoading = false;

  // Set selected role
  setSelectedRole(String role) {
    selectedRole = role;
    update();
  }

  // Set loading state
  setIsLoading(bool value) {
    isLoading = value;
    update();
  }

  // Get role selection status
  bool get isRoleSelected => selectedRole.isNotEmpty;

  // Continue with selected role
  void continueWithRole() async {
    if (selectedRole.isEmpty) {
      Get.snackbar('Error', 'Please select a role');
      return;
    }
    
    setIsLoading(true);
    
    try {
      // Check if this is a Google user registration
      final prefs = await SharedPreferences.getInstance();
      final tempGoogleUser = prefs.getString('tempGoogleUser');
      
      if (tempGoogleUser != null) {
        // This is a Google user registration
        await _registerGoogleUser();
      } else {
        // Regular signup flow - navigate based on role
        _navigateBasedOnRole();
      }
    } catch (e) {
      setIsLoading(false);
      showCommonToast("Error: $e");
    }
  }
  
  // Handle Google user role selection - navigate to appropriate screen
  Future<void> _registerGoogleUser() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempGoogleUser = jsonDecode(prefs.getString('tempGoogleUser')!);
      
      // Check if this is an existing user
      if (tempGoogleUser['existingUser'] == true) {
        // Update existing user's role
        await _updateExistingUserRole(tempGoogleUser);
      } else {
        // New user registration flow
        await _registerNewGoogleUser(tempGoogleUser);
      }
    } catch (e) {
      setIsLoading(false);
      showCommonToast("Error: $e");
    }
  }
  
  // Update existing user's role
  Future<void> _updateExistingUserRole(Map<String, dynamic> tempGoogleUser) async {
    try {
      // For existing users, we'll update their role directly
      // This is a simplified approach - you might want to call an API to update the user's role
      
      final googleUserData = {
        'email': tempGoogleUser['email'],
        'displayName': tempGoogleUser['displayName'],
        'uid': tempGoogleUser['uid'],
        'userRole': selectedRole,
        'existingUser': true,
        'existingUserData': tempGoogleUser['existingUserData'],
      };
      
      // Update temp data with selected role
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tempGoogleUser', jsonEncode(googleUserData));
      
      setIsLoading(false);
      
      // For existing users, we can skip the full onboarding and just update their role
      // Navigate based on selected role
      if (selectedRole == 'dispatcher') {
        // For dispatchers, go to account info screen
        Get.toNamed('/accountInfo', arguments: {'userRole': 'dispatcher', 'isGoogleUser': true, 'isExistingUser': true});
      } else {
        // For drivers, go to truck info screen
        Get.toNamed('/truckInfo');
      }
    } catch (e) {
      setIsLoading(false);
      showCommonToast("Error updating user role: $e");
    }
  }
  
  // Register new Google user
  Future<void> _registerNewGoogleUser(Map<String, dynamic> tempGoogleUser) async {
    try {
      // Store the selected role with Google user data
      final googleUserData = {
        'email': tempGoogleUser['email'],
        'displayName': tempGoogleUser['displayName'],
        'uid': tempGoogleUser['uid'],
        'userRole': selectedRole,
      };
      
      // Update temp data with selected role
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString('tempGoogleUser', jsonEncode(googleUserData));
      
      setIsLoading(false);
      
      // Navigate based on selected role (same as regular signup)
      if (selectedRole == 'dispatcher') {
        // For dispatchers, go to account info screen
        Get.toNamed('/accountInfo', arguments: {'userRole': 'dispatcher', 'isGoogleUser': true});
      } else {
        // For drivers, go to truck info screen
        Get.toNamed('/truckInfo');
      }
    } catch (e) {
      setIsLoading(false);
      showCommonToast("Error: $e");
    }
  }
  
  // Navigate based on role for regular signup flow
  void _navigateBasedOnRole() {
    if (selectedRole == 'dispatcher') {
      // For dispatchers, go to account info screen
      Get.toNamed('/accountInfo', arguments: {'userRole': 'dispatcher'});
    } else {
      // For drivers, go to truck info screen
      Get.toNamed('/truckInfo');
    }
    setIsLoading(false);
  }
  
}
