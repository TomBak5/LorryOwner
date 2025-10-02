import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../AppConstData/app_colors.dart';
import '../AppConstData/typographyy.dart';
import '../Controllers/role_selection_controller.dart';
import '../widgets/widgets.dart';

class RoleSelectionScreen extends StatefulWidget {
  const RoleSelectionScreen({super.key});

  @override
  State<RoleSelectionScreen> createState() => _RoleSelectionScreenState();
}

class _RoleSelectionScreenState extends State<RoleSelectionScreen> {
  RoleSelectionController roleController = Get.put(RoleSelectionController());
  String userEmail = 'hi@uigodesign.com'; // Default placeholder
  
  @override
  void initState() {
    super.initState();
    _getUserEmail();
  }
  
  Future<void> _getUserEmail() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final tempGoogleUser = prefs.getString('tempGoogleUser');
      
      if (tempGoogleUser != null) {
        final googleUserData = jsonDecode(tempGoogleUser);
        setState(() {
          userEmail = googleUserData['email'] ?? 'hi@uigodesign.com';
        });
      }
    } catch (e) {
      print("Error getting user email: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Stack(
          children: [
            // Main content
            Column(
              children: [
            // Status Bar Area
            SizedBox(height: 20.h),
            
            // Logo at top - Group 17 (1) - Same as login screen
            SizedBox(height: 88.h), // 88px from top as per Figma
            Center(
              child: Image.asset(
                'assets/logo/Group 17 (1).png',
                width: 246.46.w,
                height: 34.h,
                fit: BoxFit.contain,
              ),
            ),
            
            SizedBox(height: 83.h), // Space to reach top: 205px from Figma
            
            // Select account type text
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Align(
                alignment: Alignment.centerLeft,
                child: Text(
                  'Select account type',
                  style: TextStyle(
                    fontSize: 14.sp,
                    fontWeight: FontWeight.w400,
                    color: Color(0xFF5E7389),
                    fontFamily: 'Poppins',
                  ),
                ),
              ),
            ),
            
            SizedBox(height: 12.h),
            
            // Role Selection Cards
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: Column(
                children: [
              GetBuilder<RoleSelectionController>(
                builder: (controller) {
                  return Column(
                    children: [
                      // Dispatcher Card
                      GestureDetector(
                        onTap: () {
                          try {
                            controller.setSelectedRole('dispatcher');
                          } catch (e) {
                            print('Error selecting dispatcher: $e');
                          }
                        },
                        child: Container(
                          width: 335.w,
                          height: 50.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F6FB),
                            border: controller.selectedRole == 'dispatcher' 
                                ? Border.all(color: Color(0xFF4964D8), width: 1)
                                : null,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              // Phone calling icon
                              Container(
                                width: 24.w,
                                height: 24.h,
                                child: Image.asset(
                                  'assets/icons/phone-calling-svgrepo-com (1) 1.png',
                                  width: 24.w,
                                  height: 24.h,
                                  fit: BoxFit.contain,
                                  color: controller.selectedRole == 'dispatcher' 
                                      ? Color(0xFF4964D8) 
                                      : Color(0xFF5E7389),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Text
                              Expanded(
                                child: Text(
                                  'Dispatcher',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: controller.selectedRole == 'dispatcher' 
                                        ? Color(0xFF202020) 
                                        : Color(0xFF5E7389),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              // Check icon
                              Icon(
                                Icons.check_circle,
                                color: controller.selectedRole == 'dispatcher' 
                                    ? Color(0xFF4964D8) 
                                    : Color(0xFF5E7389),
                                size: 24.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 12.h),
                      
                      // Driver Card
                      GestureDetector(
                        onTap: () {
                          try {
                            controller.setSelectedRole('driver');
                          } catch (e) {
                            print('Error selecting driver: $e');
                          }
                        },
                        child: Container(
                          width: 335.w,
                          height: 50.h,
                          padding: EdgeInsets.symmetric(horizontal: 16.w, vertical: 13.h),
                          decoration: BoxDecoration(
                            color: Color(0xFFF1F6FB),
                            border: controller.selectedRole == 'driver' 
                                ? Border.all(color: Color(0xFF4964D8), width: 1)
                                : null,
                            borderRadius: BorderRadius.circular(8.r),
                          ),
                          child: Row(
                            children: [
                              // Truck icon
                              Container(
                                width: 24.w,
                                height: 24.h,
                                child: SvgPicture.asset(
                                  'assets/icons/truck_icon.svg',
                                  width: 24.w,
                                  height: 24.h,
                                  fit: BoxFit.contain,
                                  colorFilter: ColorFilter.mode(
                                    controller.selectedRole == 'driver' 
                                        ? Color(0xFF4964D8) 
                                        : Color(0xFF5E7389),
                                    BlendMode.srcIn,
                                  ),
                                ),
                              ),
                              SizedBox(width: 12.w),
                              // Text
                              Expanded(
                                child: Text(
                                  'Driver',
                                  style: TextStyle(
                                    fontSize: 16.sp,
                                    fontWeight: FontWeight.w400,
                                    color: controller.selectedRole == 'driver' 
                                        ? Color(0xFF202020) 
                                        : Color(0xFF5E7389),
                                    fontFamily: 'Poppins',
                                  ),
                                ),
                              ),
                              // Check icon
                              Icon(
                                Icons.check_circle,
                                color: controller.selectedRole == 'driver' 
                                    ? Color(0xFF4964D8) 
                                    : Color(0xFF5E7389),
                                size: 24.sp,
                              ),
                            ],
                          ),
                        ),
                      ),
                    ],
                  );
                },
              ),
                ],
              ),
            ),
            
            Spacer(),
            
            // Continue Button (Frame 15)
            Padding(
              padding: EdgeInsets.symmetric(horizontal: 20.w),
              child: GetBuilder<RoleSelectionController>(
                builder: (controller) {
                  return Container(
                    width: 335.w,
                    height: 53.h,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Color(0xFF4964D8),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8.r)),
                        padding: EdgeInsets.symmetric(vertical: 16.h),
                      ),
                      onPressed: controller.isLoading ? null : () {
                        try {
                          controller.continueWithRole();
                        } catch (e) {
                          print('Error continuing with role: $e');
                        }
                      },
                      child: controller.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                              ),
                            )
                          : Text(
                              "Confirm",
                              style: TextStyle(
                                color: Colors.white,
                                fontSize: 14.sp,
                                fontWeight: FontWeight.w400,
                                fontFamily: 'Poppins',
                              ),
                            ),
                    ),
                  );
                },
              ),
            ),
            
            SizedBox(height: 32.h),
              ],
            ),
            
            // Alarm icon - positioned exactly as per Figma
            Positioned(
              left: 20.w,
              top: 98.h, // 98px from top (moved 5px lower)
              child: GestureDetector(
                onTap: () => Get.back(),
                child: Container(
                  width: 24.w,
                  height: 24.h,
                  child: Image.asset(
                    'assets/icons/alarm.png',
                    width: 24.w,
                    height: 24.h,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
