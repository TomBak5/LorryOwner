// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/review_controller.dart';

class ReviewScreen extends StatefulWidget {
  const ReviewScreen({
    super.key,
  });

  @override
  State<ReviewScreen> createState() => _ReviewScreenState();
}

class _ReviewScreenState extends State<ReviewScreen> {
  ReviewController reviewController = Get.put(ReviewController());

  @override
  void initState() {
    super.initState();
    getDataFromLocale();
  }

  getDataFromLocale() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("uid");
    ApiProvider().ownerProfile(uid: uid!).then((value) {
      reviewController.setProfileData(value);
      reviewController.setIsLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();
    reviewController.isLoading = true;
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<ReviewController>(
      builder: (reviewController) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: priMaryColor,
            centerTitle: true,
            title: Text(
              "Review".tr,
              style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyBold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: reviewController.isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
                  child: Column(
                    children: [
                      Stack(
                        clipBehavior: Clip.none,
                        alignment: Alignment.bottomCenter,
                        children: [
                          Transform.translate(
                            offset: const Offset(0, -15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: SvgPicture.asset(
                                    "assets/image/Ellipse 80.svg",
                                    fit: BoxFit.fitWidth,
                                    color: priMaryColor,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          Positioned(
                            bottom: -25,
                            child: Stack(
                              clipBehavior: Clip.none,
                              alignment: Alignment.bottomRight,
                              children: [
                                Container(
                                  decoration: BoxDecoration(
                                    border: Border.all(color: Colors.white, width: 2),
                                    shape: BoxShape.circle,
                                  ),
                                  child: CircleAvatar(
                                    backgroundColor: Colors.transparent,
                                    radius: 50,
                                    backgroundImage: NetworkImage(
                                      "$basUrl${reviewController.profileData!.lorrizprofile.proPic}",
                                    ),
                                  ),
                                ),
                                Positioned(
                                  bottom: 2,
                                  right: 15,
                                  child: CircleAvatar(
                                    radius: 10,
                                    backgroundColor: Colors.white,
                                    child: Center(
                                      child: SvgPicture.asset(
                                        "assets/icons/badge-check.svg",
                                        width: 16,
                                        height: 16,
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      SizedBox(height: 30),
                      Text(
                        reviewController.profileData!.lorrizprofile.name,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          fontFamily: fontFamilyBold,
                          fontSize: 18,
                          color: textBlackColor,
                        ),
                      ),
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            "assets/icons/ic_star_profile.svg",
                            height: 20,
                            width: 20,
                            color: priMaryColor,
                          ),
                          const SizedBox(width: 8),
                          Transform.translate(
                            offset: const Offset(0, 2),
                            child: Text(
                              reviewController.profileData!.lorrizprofile.review,
                              style: TextStyle(
                                fontSize: 16,
                                fontFamily: fontFamilyBold,
                                color: priMaryColor,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15),
                        child: Row(
                          children: [
                            Expanded(
                              child: Container(
                                height: 75,
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(16),
                                  border: Border.all(
                                    color: textGreyColor.withOpacity(0.5),
                                  ),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Date of Joining".tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: fontFamilyRegular,
                                            color: textGreyColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          reviewController.profileData!.lorrizprofile.rdate.toString().split(" ").first,
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: fontFamilyRegular,
                                            color: textBlackColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Load".tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: fontFamilyRegular,
                                            color: textGreyColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "${reviewController.profileData!.lorrizprofile.totalLorry}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: fontFamilyRegular,
                                            color: textBlackColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                    Column(
                                      mainAxisAlignment: MainAxisAlignment.center,
                                      children: [
                                        Text(
                                          "Total Review".tr,
                                          style: TextStyle(
                                            fontSize: 14,
                                            fontFamily: fontFamilyRegular,
                                            color: textGreyColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                        const SizedBox(height: 5),
                                        Text(
                                          "${reviewController.profileData!.lorrizprofile.totalReview}",
                                          style: TextStyle(
                                            fontSize: 15,
                                            fontFamily: fontFamilyRegular,
                                            color: textBlackColor,
                                            fontWeight: FontWeight.w400,
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 15.0),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            SvgPicture.asset(
                              "assets/icons/ic_star_profile.svg",
                              height: 20,
                              width: 20,
                              color: priMaryColor,
                            ),
                            const SizedBox(width: 8),
                            Transform.translate(
                              offset: const Offset(0, 2),
                              child: Text(
                                reviewController.profileData!.lorrizprofile.review,
                                style: TextStyle(
                                  fontSize: 16,
                                  fontFamily: fontFamilyBold,
                                  color: textBlackColor,
                                ),
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.translate(
                              offset: const Offset(0, 2),
                              child: const CircleAvatar(
                                backgroundColor: Colors.black,
                                radius: 5,
                              ),
                            ),
                            const SizedBox(width: 8),
                            Transform.translate(
                              offset: const Offset(0, 2),
                              child: Text(
                                "${reviewController.profileData!.lorrizprofile.totalReview} ${"Review".tr}",
                                style: TextStyle(
                                  fontWeight: FontWeight.w500,
                                  fontFamily: fontFamilyBold,
                                  fontSize: 16,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 10),
                      reviewController.profileData!.lorrizprofile.totalReviewUserWise.isNull
                          ? const SizedBox()
                          : ListView.separated(
                              physics: const NeverScrollableScrollPhysics(),
                              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 10),
                              shrinkWrap: true,
                              scrollDirection: Axis.vertical,
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: EdgeInsets.symmetric(horizontal: 10),
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    borderRadius: BorderRadius.circular(12),
                                  ),
                                  child: ListTile(
                                    dense: true,
                                    contentPadding: const EdgeInsets.all(0),
                                    title: Text(
                                      reviewController.profileData!.lorrizprofile.totalReviewUserWise[index].customername,
                                      style: TextStyle(
                                        color: textBlackColor,
                                        fontSize: 16,
                                        fontFamily: fontFamilyBold,
                                      ),
                                    ),
                                    subtitle: Text(
                                      reviewController.profileData!.lorrizprofile.totalReviewUserWise[index].rateText,
                                      style: TextStyle(
                                        color: textGreyColor,
                                        fontSize: 14,
                                        fontFamily: fontFamilyRegular,
                                      ),
                                    ),
                                    trailing: Row(
                                      mainAxisSize: MainAxisSize.min,
                                      children: [
                                        SvgPicture.asset(
                                          "assets/icons/ic_star_profile.svg",
                                          width: 20,
                                          height: 20,
                                          color: priMaryColor,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(reviewController.profileData!.lorrizprofile.totalReviewUserWise[index].rateNumber),
                                      ],
                                    ),
                                    leading: CircleAvatar(
                                      backgroundColor: Colors.transparent,
                                      backgroundImage: NetworkImage(
                                        "$basUrl${reviewController.profileData!.lorrizprofile.totalReviewUserWise[index].userImg}",
                                      ),
                                    ),
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 10);
                              },
                              itemCount: reviewController.profileData!.lorrizprofile.totalReviewUserWise.length,
                            ),
                    ],
                  ),
                ),
        );
      },
    );
  }
}
