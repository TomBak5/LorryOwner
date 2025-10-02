import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: 20.w),
          child: Column(
            children: [
              SizedBox(height: 40.h),
              
              // Header
              Text(
                "Select Your Role",
                style: TextStyle(
                  fontSize: 28.sp,
                  fontWeight: FontWeight.bold,
                  color: textBlackColor,
                ),
              ),
              
              SizedBox(height: 10.h),
              
              Text(
                "Choose how you want to use the app",
                style: TextStyle(
                  fontSize: 16.sp,
                  color: textGreyColor,
                ),
                textAlign: TextAlign.center,
              ),
              
              SizedBox(height: 60.h),
              
              // Role Selection Cards
              GetBuilder<RoleSelectionController>(
                builder: (controller) {
                  return Column(
                    children: [
                      // Dispatcher Card
                      GestureDetector(
                        onTap: () => controller.setSelectedRole('dispatcher'),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: controller.selectedRole == 'dispatcher' ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color: controller.selectedRole == 'dispatcher' ? secondaryColor : textGreyColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: controller.selectedRole == 'dispatcher' ? [
                              BoxShadow(
                                color: secondaryColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: controller.selectedRole == 'dispatcher' 
                                      ? secondaryColor.withOpacity(0.1) 
                                      : textGreyColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.account_circle_outlined,
                                  color: controller.selectedRole == 'dispatcher' ? secondaryColor : textGreyColor,
                                  size: 32.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Dispatcher',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: controller.selectedRole == 'dispatcher' ? secondaryColor : textGreyColor,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Manage loads and assign drivers',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: controller.selectedRole == 'dispatcher' ? secondaryColor : textGreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.selectedRole == 'dispatcher')
                                Icon(
                                  Icons.check_circle,
                                  color: secondaryColor,
                                  size: 24.sp,
                                ),
                            ],
                          ),
                        ),
                      ),
                      
                      SizedBox(height: 20.h),
                      
                      // Driver Card
                      GestureDetector(
                        onTap: () => controller.setSelectedRole('driver'),
                        child: Container(
                          width: double.infinity,
                          padding: EdgeInsets.symmetric(vertical: 20.h, horizontal: 20.w),
                          decoration: BoxDecoration(
                            color: controller.selectedRole == 'driver' ? Colors.white : Colors.transparent,
                            border: Border.all(
                              color: controller.selectedRole == 'driver' ? secondaryColor : textGreyColor,
                              width: 2,
                            ),
                            borderRadius: BorderRadius.circular(16.r),
                            boxShadow: controller.selectedRole == 'driver' ? [
                              BoxShadow(
                                color: secondaryColor.withOpacity(0.1),
                                blurRadius: 10,
                                offset: const Offset(0, 4),
                              ),
                            ] : null,
                          ),
                          child: Row(
                            children: [
                              Container(
                                padding: EdgeInsets.all(12.w),
                                decoration: BoxDecoration(
                                  color: controller.selectedRole == 'driver' 
                                      ? secondaryColor.withOpacity(0.1) 
                                      : textGreyColor.withOpacity(0.1),
                                  borderRadius: BorderRadius.circular(12.r),
                                ),
                                child: Icon(
                                  Icons.local_shipping_outlined,
                                  color: controller.selectedRole == 'driver' ? secondaryColor : textGreyColor,
                                  size: 32.sp,
                                ),
                              ),
                              SizedBox(width: 16.w),
                              Expanded(
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Driver',
                                      style: TextStyle(
                                        fontSize: 18.sp,
                                        fontWeight: FontWeight.w600,
                                        color: controller.selectedRole == 'driver' ? secondaryColor : textGreyColor,
                                      ),
                                    ),
                                    SizedBox(height: 4.h),
                                    Text(
                                      'Find loads and transport goods',
                                      style: TextStyle(
                                        fontSize: 14.sp,
                                        color: controller.selectedRole == 'driver' ? secondaryColor : textGreyColor,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              if (controller.selectedRole == 'driver')
                                Icon(
                                  Icons.check_circle,
                                  color: secondaryColor,
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
              
              SizedBox(height: 60.h),
              
              // Continue Button
              GetBuilder<RoleSelectionController>(
                builder: (controller) {
                  return SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                        fixedSize: const Size.fromHeight(48),
                        backgroundColor: priMaryColor,
                      ),
                      onPressed: controller.isLoading ? null : () => controller.continueWithRole(),
                      child: controller.isLoading
                          ? SizedBox(
                              height: 20,
                              width: 20,
                              child: CircularProgressIndicator(
                                strokeWidth: 2,
                                valueColor: AlwaysStoppedAnimation<Color>(whiteColor),
                              ),
                            )
                          : Text(
                              "Continue",
                              style: TextStyle(
                                color: whiteColor,
                                fontSize: 16,
                                fontFamily: "urbani_extrabold",
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                    ),
                  );
                },
              ),
              
              SizedBox(height: 20.h),
              
              // Back Button
              TextButton(
                onPressed: () => Get.back(),
                child: Text(
                  "Back to Login",
                  style: TextStyle(
                    fontSize: 16.sp,
                    color: textGreyColor,
                    decoration: TextDecoration.underline,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
