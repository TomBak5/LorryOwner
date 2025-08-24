// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';

import '../../AppConstData/app_colors.dart';
import '../../Controllers/landingpage_controller.dart';

class LandingPage extends StatefulWidget {
  const LandingPage({super.key});

  @override
  State<LandingPage> createState() => _LandingPageState();
}

class _LandingPageState extends State<LandingPage> {
  LandingPageController landingPageController = Get.put(LandingPageController());

  @override
  Widget build(BuildContext context) {
    return GetBuilder<LandingPageController>(
      builder: (landingPageController) {
        return WillPopScope(
          onWillPop: () async{
            return await landingPageController.popScopeBack();
          },
          child: LayoutBuilder(
            builder: (context, constraints) {
              return Scaffold(
                backgroundColor: Colors.white,
                bottomNavigationBar: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SizedBox(
                      height: 60,
                      width: constraints.maxWidth,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Flexible(
                            child: ListView.builder(
                              itemCount: landingPageController.bottomItemsIcons.length,
                              shrinkWrap: true,
                              scrollDirection: Axis.horizontal,
                              itemBuilder: (context, index) {
                                return InkWell(
                                  onTap: () {
                                    landingPageController.setSelectPage(index);
                                  },
                                  child: SizedBox(
                                    width: constraints.maxWidth * 0.25,
                                    child: Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        _buildIcon(
                                          landingPageController.bottomItemsIcons[index],
                                          landingPageController.selectPageIndex == index
                                              ? secondaryColor
                                              : textGreyColor,
                                        ),
                                        const SizedBox(height: 3),
                                        Flexible(
                                          child: Text(
                                            landingPageController.bottomItems[index].toString().tr,
                                            style: TextStyle(
                                              fontSize: 12,
                                              color: landingPageController.selectPageIndex == index
                                                  ? secondaryColor
                                                  : textGreyColor,
                                              fontWeight: FontWeight.w400,
                                              fontFamily: "urbani_regular",
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                );
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                body: landingPageController.pages[landingPageController.selectPageIndex],
              );
            },
          ),
        );
      },
    );
  }

  Widget _buildIcon(String iconPath, Color color) {
    if (iconPath.endsWith('.svg')) {
      return SvgPicture.asset(
        iconPath,
        width: 22,
        height: 22,
        color: color,
      );
    } else if (iconPath.endsWith('.png')) {
      return Image.asset(
        iconPath,
        width: 22,
        height: 22,
        color: color,
      );
    } else {
      // Fallback for other file types
      return Icon(
        Icons.error,
        size: 22,
        color: color,
      );
    }
  }
}
