import 'package:flutter/material.dart';
import 'package:get/get.dart';

import '../AppConstData/app_colors.dart';
import '../AppConstData/routes.dart';
import '../AppConstData/typographyy.dart';
import '../Controllers/onboarding_screen_controller.dart';
import '../widgets/widgets.dart';

class OnBoardingScreens extends StatefulWidget {
  const OnBoardingScreens({super.key});

  @override
  State<OnBoardingScreens> createState() => _OnBoardingScreensState();
}

class _OnBoardingScreensState extends State<OnBoardingScreens> {
  OnBoardingScreensController onBoardingScreensController =
      Get.put(OnBoardingScreensController());
  PageController controller = PageController(initialPage: 0);

  @override
  Widget build(BuildContext context) {
    return SafeArea(
      child: Scaffold(
        backgroundColor: Colors.white,
        bottomNavigationBar: Padding(
          padding: const EdgeInsets.all(20.0),
          child: Row(
            children: [
              Expanded(
                child: commonButton(
                  title: onBoardingScreensController.pageSelecter == 2
                      ? "Get Started"
                      : "Next",
                  onTapp: () {
                    if (onBoardingScreensController.pageSelecter == 0) {
                      controller.jumpToPage(1);
                    } else if (onBoardingScreensController.pageSelecter == 1) {
                      controller.jumpToPage(2);
                    } else {
                      Get.offAllNamed(Routes.loginScreen);
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        body: SingleChildScrollView(
          physics: const NeverScrollableScrollPhysics(),
          child: GetBuilder<OnBoardingScreensController>(
            builder: (onBoardingScreensController) {
              return Stack(
                alignment: Alignment.bottomCenter,
                children: [
                  Column(
                    children: [
                      Stack(
                        alignment: Alignment.topCenter,
                        children: [
                          SizedBox(height: Get.height),
                          Stack(
                            alignment: Alignment.bottomCenter,
                            children: [
                              SizedBox(
                                height: Get.height * 0.72,
                                width: Get.width,
                                child: PageView.builder(
                                  controller: controller,
                                  onPageChanged: (value) {
                                    onBoardingScreensController.setPageSelecter(value);
                                  },
                                  scrollDirection: Axis.horizontal,
                                  itemCount: 3,
                                  itemBuilder: (context, index) {
                                    return Container(
                                      height: 583,
                                      width: Get.width,
                                      padding: const EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        image: DecorationImage(
                                          image: AssetImage(
                                            onBoardingScreensController.images[index],
                                          ),
                                          fit: BoxFit.cover,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ),
                              onBoardingScreensController.pageSelecter == 2
                                  ? const SizedBox()
                                  : Positioned(
                                      top: 15,
                                      right: 15,
                                      child: Row(
                                        mainAxisAlignment: MainAxisAlignment.end,
                                        children: [
                                          InkWell(
                                            onTap: () {
                                              Get.offAllNamed(Routes.loginScreen);
                                            },
                                            child: Container(
                                              padding: EdgeInsets.symmetric(horizontal: 16,vertical: 6),
                                              decoration: BoxDecoration(
                                                color: priMaryColor,
                                                borderRadius: BorderRadius.circular(100),
                                              ),
                                              child: Center(
                                                child: Text(
                                                  "Skip",
                                                  style: TextStyle(
                                                    color: whiteColor,
                                                    fontWeight: FontWeight.w500,
                                                    fontSize: 12,
                                                    fontFamily: "urbani_extrabold",
                                                  ),
                                                ),
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ),
                              Positioned(
                                bottom: 65,
                                child: SizedBox(
                                  height: 15,
                                  width: Get.width * 0.2,
                                  child: ListView.builder(
                                    shrinkWrap: true,
                                    scrollDirection: Axis.horizontal,
                                    itemCount: 3,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          controller.jumpToPage(index);
                                        },
                                        child: Container(
                                          margin: const EdgeInsets.symmetric(horizontal: 5),
                                          height: 10,
                                          width: 10,
                                          decoration: BoxDecoration(
                                            color: onBoardingScreensController.pageSelecter == index
                                                ? priMaryColor
                                                : Colors.white,
                                            shape: BoxShape.circle,
                                          ),
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                  Container(
                    height: Get.height * 0.34,
                    padding: const EdgeInsets.all(24),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      color: whiteColor,
                    ),
                    width: Get.width,
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Text(
                          "${onBoardingScreensController.onBoardingTitle[onBoardingScreensController.pageSelecter]}".tr,
                          style: Typographyy.headLine,
                          textAlign: TextAlign.center,
                          maxLines: 2,
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "${onBoardingScreensController.subTitle[onBoardingScreensController.pageSelecter]}".tr,
                          style: Typographyy.titleText,
                          textAlign: TextAlign.center,
                          maxLines: 3,
                        ),
                        SizedBox(height: Get.height * (onBoardingScreensController.pageSelecter == 0 ? 0.05: 0.03)),
                      ],
                    ),
                  ),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}
