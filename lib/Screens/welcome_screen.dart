import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:get/get.dart';

import '../AppConstData/routes.dart';

class WelcomeScreen extends StatelessWidget {
  const WelcomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            // Background image with Figma positioning
            Positioned(
              left: (MediaQuery.of(context).size.width - 432.81.w) / 2, // Centered horizontally
              top: -28.h, // -28px from top as specified
              child: Container(
                width: 432.81.w, // Exact width as specified
                height: 613.h, // Exact height as specified
                decoration: const BoxDecoration(
                  image: DecorationImage(
                    image: AssetImage('assets/image/blank-cargo-truck-road 1.png'),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            
            // Gradient overlay
            Container(
              width: double.infinity,
              height: double.infinity,
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topCenter,
                  end: Alignment.bottomCenter,
                  colors: [
                    Colors.black.withOpacity(0.2),
                    Colors.black.withOpacity(0.7),
                  ],
                ),
              ),
            ),
            
            // Rectangle 13 - White bottom container
            Positioned(
              left: 0,
              top: 544.h, // 544px from top as specified
              child: Container(
                width: 375.w, // 375px width as specified
                height: 268.h, // 268px height as specified
                decoration: BoxDecoration(
                  color: Colors.white, // #FFFFFF background
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(32.r), // 32px top-left radius
                    topRight: Radius.circular(32.r), // 32px top-right radius
                    bottomLeft: Radius.circular(0), // 0px bottom-left radius
                    bottomRight: Radius.circular(0), // 0px bottom-right radius
                  ),
                ),
                child: Padding(
                  padding: EdgeInsets.only(left: 20.w, top: 32.h), // 20px left, 32px top as per Figma
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: 335.w, // 335px width as specified
                        height: 39.h, // 39px height as specified
                        child: Text(
                          "Let's Hit the Road!",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w500,
                            fontSize: 26.sp, // 26px font size
                            height: 1.5, // 39px line height (39/26 = 1.5)
                            color: const Color(0xFF202020), // #202020 color
                          ),
                        ),
                      ),
                      SizedBox(height: 8.h), // 8px gap as per Figma
                      Container(
                        width: 335.w, // 335px width as specified
                        height: 44.h, // 44px height as specified
                        child: Text(
                          "Everything you need to keep rolling — routes, updates, and tools that work for you.",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: 'Poppins',
                            fontWeight: FontWeight.w400,
                            fontSize: 14.sp, // 14px font size
                            height: 1.57, // 22px line height (22/14 = 1.57)
                            color: const Color(0xFF929292), // #929292 color
                          ),
                        ),
                      ),
                      SizedBox(height: 24.h), // 24px gap as per Figma
                      // Progress indicators - Rectangle 15, 16, 17
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Rectangle 15
                          Container(
                            width: 40.w, // 40px width
                            height: 4.h, // 4px height
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9), // #D9D9D9 background
                              borderRadius: BorderRadius.circular(99.r), // 99px border radius
                            ),
                          ),
                          SizedBox(width: 4.w), // 4px gap between rectangles
                          // Rectangle 16
                          Container(
                            width: 40.w, // 40px width
                            height: 4.h, // 4px height
                            decoration: BoxDecoration(
                              color: const Color(0xFFD9D9D9), // #D9D9D9 background
                              borderRadius: BorderRadius.circular(99.r), // 99px border radius
                            ),
                          ),
                          SizedBox(width: 4.w), // 4px gap between rectangles
                          // Rectangle 17 (active indicator)
                          Container(
                            width: 60.w, // 60px width
                            height: 4.h, // 4px height
                            decoration: BoxDecoration(
                              color: const Color(0xFF4964D8), // #4964D8 background
                              borderRadius: BorderRadius.circular(99.r), // 99px border radius
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 24.h), // 24px gap as per Figma
                      // Frame 15 button
                      GestureDetector(
                        onTap: () {
                          Get.toNamed(Routes.loginScreen);
                        },
                        child: Container(
                          width: 335.w, // 335px width as per Figma
                          height: 53.h, // 53px height as per Figma
                          decoration: BoxDecoration(
                            color: const Color(0xFF4964D8), // #4964D8 background
                            borderRadius: BorderRadius.circular(8.r), // 8px border radius
                          ),
                          child: Center(
                            child: Text(
                              "Get Started",
                              style: TextStyle(
                                fontFamily: 'Poppins',
                                fontWeight: FontWeight.w400,
                                fontSize: 14.sp, // 14px font size
                                height: 1.5, // 21px line height (21/14 = 1.5)
                                color: Colors.white, // #FFFFFF color
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            
            // Content
            SafeArea(
              child: Padding(
              padding: EdgeInsets.all(20.w),
              child: Column(
                children: [
                  // Top section with logo positioned at top
                  SizedBox(
                    height: 88.h, // 88px from top as specified
                    child: Center(
                      child: Image.asset(
                        "assets/logo/Group 17.png",
                        width: 246.46.w, // Exact width as specified
                        height: 34.h, // Exact height as specified
                        fit: BoxFit.contain,
                      ),
                    ),
                  ),
                  
                  
                ],
              ),
            ),
            ),
          ],
        ),
      ),
    );
  }
}
