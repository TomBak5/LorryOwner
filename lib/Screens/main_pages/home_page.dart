// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:carousel_slider/carousel_slider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/AppConstData/typographyy.dart';
import 'package:movers_lorry_owner/Controllers/homepage_controller.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/addsubdriver.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/subdrivers.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:shimmer/shimmer.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/managepage.dart';
import '../../AppConstData/routes.dart';
import '../../models/home_model.dart';
import '../../widgets/widgets.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  HomePageController homePageController = Get.put(HomePageController());
  @override
  void initState() {
    super.initState();
    homePageController.getDataFromLocalData().then((value) {
      if (value.toString().isNotEmpty) {
        // OneSignal.User.addTags({"userid": homePageController.userData.id,});
        homePageController.getHomePageData(uid: homePageController.userData.id ?? '');
      }
      homePageController.setIcon(homePageController.verification12(homePageController.userData.isVerify ?? ''));
      ManagePageCalling().setLogin(false);
    });
    ManagePageCalling().setLogin(false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: GetBuilder<HomePageController>(
        builder: (homePageController) {
          if (homePageController.isLoading) {
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          } else {
            return RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    homePageController.updateUserProfile(context);
                  },
                );
              },
              child: Scaffold(
                backgroundColor: Colors.white,
                appBar: PreferredSize(
                  preferredSize: const Size.fromHeight(80),
                  child: AppBar(
                      toolbarHeight: 80,
                      backgroundColor: priMaryColor,
                      elevation: 0,
                      titleSpacing: 0,
                      title: Column(
                        children: [
                          ListTile(
                            dense: true,
                            leading: homePageController.userData.proPic.toString() == "null"
                                ? const CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: AssetImage(
                                      "assets/image/05.png",
                                    ),
                                    radius: 25,
                                  )
                                : CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    backgroundImage: NetworkImage(
                                      "$basUrl${homePageController.userData.proPic}",
                                    ),
                                    radius: 25,
                                    child: Image.network(
                                      "$basUrl${homePageController.userData.proPic}",
                                      color: Colors.transparent,
                                      fit: BoxFit.cover,
                                      errorBuilder: (context, error, stackTrace) {
                                        return commonSimmer(height: 50, width: 50);
                                      },
                                      loadingBuilder: (context, child, loadingProgress) {
                                        return (loadingProgress == null)
                                            ? child
                                            : commonSimmer(height: 50, width: 50);
                                      },
                                    ),
                                  ),
                            trailing: InkWell(
                              onTap: () {
                                Get.toNamed(Routes.notification);
                              },
                              child: CircleAvatar(
                                backgroundColor: Colors.white.withOpacity(0.1),
                                radius: 20,
                                child: SvgPicture.asset(
                                  "assets/icons/notification.svg",
                                  height: 20,
                                  width: 20,
                                ),
                              ),
                            ),
                            title: Transform.translate(
                              offset: const Offset(0, -5),
                              child: Text(
                                "Hello..".tr,
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w400,
                                  color: Colors.white,
                                  fontFamily: "urbani_regular",
                                ),
                              ),
                            ),
                            subtitle: Text(
                              homePageController.userData.name.toString(),
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.w400,
                                color: Colors.white,
                                fontFamily: "urbani_extrabold",
                              ),
                            ),
                          ),
                        ],
                      )),
                ),
                body: SingleChildScrollView(
                  child: Column(
                    children: [
                      Row(
                        children: [
                          Expanded(
                            child: Container(
                              padding: const EdgeInsets.all(24),
                              color: priMaryColor,
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    "Post your truck and get loads".tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontSize: 32,
                                      color: Color(0xff18FF13),
                                      fontFamily: "urbani_extrabold",
                                    ),
                                  ),
                                  const SizedBox(height: 15),
                                  Row(
                                    children: [
                                      Flexible(
                                        child: Text(
                                          homePageController.homePageData.homeData!.topMsg!.tr,
                                          style: const TextStyle(
                                            fontFamily: "urbani_extrabold",
                                            color: Colors.white,
                                            fontSize: 15,
                                            fontWeight: FontWeight.w500,
                                          ),
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Transform.translate(
                                        offset: const Offset(0, -1),
                                        child: SvgPicture.asset(
                                          homePageController.verification!,
                                          height: 18,
                                          width: 18,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 24),
                                  SingleChildScrollView(
                                    scrollDirection: Axis.horizontal,
                                    child: Row(
                                      children: [
                                        for (int a = 0; a < 4; a++)
                                          Row(
                                            children: [
                                              InkWell(
                                                onTap: () {
                                                  if (homePageController.userData.isVerify == "2") {
                                                    switch (a) {
                                                      case 0:
                                                        Get.toNamed(Routes.findLorry);
                                                        break;
                                                      case 1:
                                                        Get.toNamed(Routes.nearLoad);
                                                        break;
                                                      case 2:
                                                        Get.toNamed(Routes.attachLorry);
                                                      case 3:
                                                        Get.to(Subdrivers());
                                                    }
                                                  } else if (homePageController.userData.isVerify == "1") {
                                                    showCommonToast("verification Under Process");
                                                  } else {
                                                    Get.toNamed(Routes.verifyIdentity);
                                                  }
                                                },
                                                child: Container(
                                                  height: 40,
                                                  width: 110,
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.all(
                                                      Radius.circular(12),
                                                    ),
                                                    border: Border.all(
                                                      color: Colors.white.withOpacity(0.8),
                                                      width: 1.5,
                                                    ),
                                                  ),
                                                  child: Row(
                                                    crossAxisAlignment: CrossAxisAlignment.center,
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Flexible(
                                                        child: Text(
                                                          homePageController.menuList[a].toString().tr,
                                                          style: TextStyle(
                                                            color: Colors.white,
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: "urbani_extrabold",
                                                            fontSize: 14,
                                                          ),
                                                          overflow: TextOverflow.ellipsis,
                                                          maxLines: 1,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10)
                                            ],
                                          ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      Padding(
                        padding: const EdgeInsets.all(12),
                        child: CarouselSlider(
                          options: CarouselOptions(
                            aspectRatio: 2.0,
                            height: 200,
                            enlargeCenterPage: true,
                            scrollDirection: Axis.horizontal,
                            viewportFraction: 1,
                            autoPlay: true,
                          ),
                          items: [
                            for (int a = 0; a < homePageController.homePageData.homeData!.banner!.length; a++)
                              homePageController.homePageData.homeData!.banner![a].img!.isEmpty
                                  ? Shimmer.fromColors(
                                      baseColor: Colors.grey.shade300,
                                      highlightColor: Colors.grey.shade100,
                                      enabled: true,
                                      child: Container(
                                        height: 200,
                                        width: Get.width,
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          color: Colors.grey.shade200,
                                        ),
                                      ),
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(12),
                                      child: Image.network(
                                        "$basUrl${homePageController.homePageData.homeData!.banner![a].img}",
                                        fit: BoxFit.cover,
                                        width: Get.width,
                                        errorBuilder: (context, error, stackTrace) {
                                          return commonSimmer(height: 200, width: Get.width);
                                        },
                                        loadingBuilder: (context, child, loadingProgress) {
                                          return (loadingProgress == null)
                                              ? child
                                              : commonSimmer(height: 200,width: Get.width);
                                        },
                                      ),
                                    ),
                          ],
                        ),
                      ),
                      homePageController.homePageData.homeData!.mylorrylist!.isNotEmpty
                          ? Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Padding(
                                  padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Text(
                                        "My Lorry's".tr,
                                        style: const TextStyle(
                                          fontWeight: FontWeight.w500,
                                          fontFamily: "urbani_extrabold",
                                          fontSize: 20,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                SizedBox(
                                  height: 125,
                                  width: Get.width,
                                  child: ListView.separated(
                                    clipBehavior: Clip.none,
                                    padding: const EdgeInsets.symmetric(horizontal: 15),
                                    scrollDirection: Axis.horizontal,
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return Stack(
                                        alignment: Alignment.topRight,
                                        clipBehavior: Clip.none,
                                        children: [
                                          Container(
                                            padding: const EdgeInsets.symmetric(horizontal: 15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.circular(12),
                                              border: Border.all(
                                                color: Colors.grey.withOpacity(0.3),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Image.network(
                                                      "$basUrl${homePageController.homePageData.homeData!.mylorrylist![index].lorryImg}",
                                                      height: 70,
                                                      width: 90,
                                                      errorBuilder: (context, error, stackTrace) {
                                                        return commonSimmer(height: 58, width: 58);
                                                      },
                                                      loadingBuilder: (context, child, loadingProgress) {
                                                        return (loadingProgress == null)
                                                            ? child
                                                            : commonSimmer(height: 58, width: 58);
                                                      },
                                                    ),
                                                    Text(
                                                      "${homePageController.homePageData.homeData!.mylorrylist![index].lorryNo}",
                                                      style: TextStyle(
                                                        fontSize: 14,
                                                        color: textBlackColor,
                                                        fontFamily: fontFamilyBold,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(width: 8),
                                                Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                  children: [
                                                    Text(
                                                      "${homePageController.homePageData.homeData!.mylorrylist![index].lorryTitle}",
                                                      style: TextStyle(
                                                        fontSize: 18,
                                                        color: textBlackColor,
                                                        fontFamily: fontFamilyBold,
                                                        fontWeight: FontWeight.w500,
                                                      ),
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/route.svg",
                                                          height: 22,
                                                          width: 22,
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          "${homePageController.homePageData.homeData!.mylorrylist![index].routes.toString()} + Routs",
                                                          style: TextStyle(
                                                            color: textGreyColor,
                                                            fontSize: 15,
                                                          ),
                                                        ),
                                                        const SizedBox(height: 10),
                                                      ],
                                                    ),
                                                    Row(
                                                      children: [
                                                        SvgPicture.asset(
                                                          homePageController.homePageData.homeData!.mylorrylist![index].rcVerify == "2"
                                                              ? "assets/icons/ic_unverified.svg"
                                                              : "assets/icons/badge-check.svg",
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Text(
                                                          homePageController.homePageData.homeData!.mylorrylist![index].rcVerify == '2'
                                                              ? "Document Reupload"
                                                              : "RC Verified",
                                                        ),
                                                      ],
                                                    ),
                                                  ],
                                                ),
                                              ],
                                            ),
                                          ),
                                          Positioned(
                                            right: -5,
                                            top: -5,
                                            child: InkWell(
                                              onTap: () async {
                                                SharedPreferences preferences = await SharedPreferences.getInstance();
                                                Mylorrylist data = homePageController.homePageData.homeData!.mylorrylist![index];

                                                Map editData = {
                                                  "lorryNo": data.lorryNo,
                                                  "numberOfTones": data.weight,
                                                  "vehicle": data.lorryTitle,
                                                  "description": data.description,
                                                  "isedite": true,
                                                  "statelist": data.totalRoutes,
                                                  "record_id": data.id
                                                };
                                                debugPrint("========== data ========= $data");
                                                debugPrint("======== editData ======= $editData");
                                                preferences.setString("EditLorryData",jsonEncode(editData));
                                                Get.toNamed(Routes.attachLorry);
                                              },
                                              child: CircleAvatar(
                                                backgroundColor: priMaryColor,
                                                radius: 13,
                                                child: Center(
                                                  child: SvgPicture.asset(
                                                    "assets/icons/edit-2.svg",
                                                    color: Colors.white,
                                                    height: 14,
                                                    width: 14,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          ),
                                        ],
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(width: 10);
                                    },
                                    itemCount: homePageController.homePageData.homeData!.mylorrylist!.length,
                                  ),
                                ),
                              ],
                            )
                          : const SizedBox(),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              "Operating Routes".tr,
                              style: const TextStyle(
                                fontWeight: FontWeight.w500,
                                fontFamily: "urbani_extrabold",
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10),
                        child: GridView.builder(
                          itemCount: homePageController.homePageData.homeData!.statelist!.length,
                          shrinkWrap: true,
                          physics: const NeverScrollableScrollPhysics(),
                          gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: 3,
                            mainAxisExtent: 150,
                          ),
                          itemBuilder: (context, index) {
                            return Container(
                              margin: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(12),
                                border: Border.all(
                                  color: Colors.grey.withOpacity(0.3),
                                ),
                              ),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Image.network(
                                    "$basUrl${homePageController.homePageData.homeData!.statelist![index].img}",
                                    width: 72,
                                    height: 72,
                                    color: secondaryColor.withOpacity(0.4),
                                    errorBuilder: (context, error, stackTrace) {
                                      return commonSimmer(height: 65, width: 65);
                                    },
                                    loadingBuilder: (context, child, loadingProgress) {
                                      return (loadingProgress == null)
                                          ? child
                                          : commonSimmer(height: 65, width: 65);
                                    },
                                  ),
                                  Flexible(
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(horizontal: 8),
                                      child: Text(
                                        "${homePageController.homePageData.homeData!.statelist![index].title}",
                                        style: TextStyle(
                                          fontSize: 17,
                                          color: textBlackColor,
                                          fontFamily: "urbani_extrabold",
                                          fontWeight: FontWeight.w700,
                                        ),
                                        overflow: TextOverflow.ellipsis,
                                        maxLines: 1,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 8),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/Group.svg",
                                        height: 14,
                                        width: 14,
                                        color: textGreyColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Transform.translate(
                                          offset: const Offset(0, 1),
                                          child: Text(
                                            "${homePageController.homePageData.homeData!.statelist![index].totalLoad} Load",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: textGreyColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 5),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment: CrossAxisAlignment.center,
                                    children: [
                                      SvgPicture.asset(
                                        "assets/icons/ic_find_lorryf.svg",
                                        height: 14,
                                        width: 14,
                                        color: textGreyColor,
                                      ),
                                      const SizedBox(width: 5),
                                      Flexible(
                                        child: Transform.translate(
                                          offset: const Offset(0, 1),
                                          child: Text(
                                            "${homePageController.homePageData.homeData!.statelist![index].totalLorry} Lorry",
                                            style: TextStyle(
                                              fontWeight: FontWeight.w500,
                                              fontSize: 12,
                                              color: textGreyColor,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            );
          }
        },
      ),
    );
  }
}
