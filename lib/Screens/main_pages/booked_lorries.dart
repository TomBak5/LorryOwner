// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:truckbuddy/models/bookedLoads_model.dart';

import 'package:shared_preferences/shared_preferences.dart';
import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';

import '../../AppConstData/typographyy.dart';
import '../../Controllers/bookedlorry_controller.dart';
import '../../widgets/widgets.dart';
import '../sub_pages/booked_detils.dart';
import '../sub_pages/trans_profile.dart';

class BookedLorries extends StatefulWidget {
  const BookedLorries({super.key});

  @override
  State<BookedLorries> createState() => _BookedLorriesState();
}

class _BookedLorriesState extends State<BookedLorries> {
  String uid = "";

  BookedLorriesController bookedLorriesController = Get.put(BookedLorriesController());

  @override
  void dispose() {
    super.dispose();
    bookedLorriesController.isLoading = true;
  }

  @override
  void initState() {
    super.initState();
    fetchDataFromApi();
  }

  fetchDataFromApi() async {
    final SharedPreferences prefs = await SharedPreferences.getInstance();
    uid = prefs.getString("uid")!;
    ApiProvider().bookHistory(uid: uid, status: "Current").then((value) {
      bookedLorriesController.setDataCurrentLoads(BookedLorryModel12.fromJson(value));
      ApiProvider().bookHistory(uid: uid, status: "complete").then((value) {
        bookedLorriesController.setDataCompletedLoads(BookedLorryModel12.fromJson(value));
        bookedLorriesController.isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<BookedLorriesController>(
        builder: (bookedLorriesController) {
      return DefaultTabController(
        length: 2,
        initialIndex: 0,
        child: Scaffold(
          appBar: PreferredSize(
              preferredSize: const Size.fromHeight(90),
              child: Container(
                color: priMaryColor,
                child: SafeArea(
                  child: Column(
                    children: [
                      const SizedBox(height: 15),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 20),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              "Booked Loads".tr,
                              style: TextStyle(
                                fontSize: 18,
                                fontFamily: fontFamilyBold,
                                fontWeight: FontWeight.w500,
                                color: Colors.white,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Spacer(),
                      Container(
                        color: priMaryColor,
                        child: Column(
                          children: [
                            TabBar(
                              indicatorWeight: 3,
                              indicatorPadding: const EdgeInsets.only(top: 15),
                              indicatorColor: Colors.amberAccent,
                              tabs: [
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "MY CURRENT LOADS".tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "urbani_regular",
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsets.only(bottom: 10),
                                  child: Text(
                                    "COMPLETED".tr,
                                    style: const TextStyle(
                                      fontWeight: FontWeight.w500,
                                      fontFamily: "urbani_regular",
                                      fontSize: 15,
                                    ),
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          backgroundColor: Colors.white,
          body: Column(
            children: [
              Expanded(
                child: TabBarView(children: [
                  bookedLorriesController.isLoading
                      ? ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return commonSimmer(height: 200, width: 60);
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 15);
                          },
                          itemCount: 10,
                        )
                      : bookedLorriesController.currentLoads.bookHistory.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/image/54.svg"),
                                const SizedBox(height: 8),
                                Text(
                                  "No Load Placed! Currently You Don't Have Any Loads".tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: textGreyColor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "urbani_regular",
                                  ),
                                  textAlign: TextAlign.center,
                                )
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.network(
                                            "$basUrl${bookedLorriesController.currentLoads.bookHistory[index].lorryImg}",
                                            height: 100,
                                            width: 100,
                                            errorBuilder: (context, error, stackTrace) {
                                              return commonSimmer(height: 100, width: 100);
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              return (loadingProgress == null)
                                                  ? child
                                                  : commonSimmer(height: 100, width: 100);
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bookedLorriesController.currentLoads.bookHistory[index].lorryTitle,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: textBlackColor,
                                                    fontFamily: fontFamilyBold,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 4,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_pickup_map.svg",
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        bookedLorriesController.currentLoads.bookHistory[index].pickupPoint,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: textBlackColor,
                                                          fontFamily: fontFamilyRegular,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_pickup_map.svg",
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        bookedLorriesController.currentLoads.bookHistory[index].dropPoint,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: textBlackColor,
                                                          fontFamily: fontFamilyRegular,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  bookedLorriesController.currentLoads.bookHistory[index].lorryNo,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: textBlackColor,
                                                    fontFamily: fontFamilyBold,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 4,
                                                ),
                                              ],
                                            ),
                                          )
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/delivery-cart-arrow-up.svg",
                                            height: 24,
                                            width: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${bookedLorriesController.currentLoads.bookHistory[index].weight} ${"Tonnes".tr}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textGreyColor,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: fontFamilyRegular,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const Spacer(),
                                          SvgPicture.asset(
                                            "assets/icons/route.svg",
                                            height: 24,
                                            width: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${bookedLorriesController.currentLoads.bookHistory[index].routesCount} ${"Routes".tr}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textGreyColor,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: fontFamilyRegular,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const Spacer(),
                                          SvgPicture.asset(
                                            rcVerifide(bookedLorriesController.currentLoads.bookHistory[index].rcVerify),
                                            height: 24,
                                            width: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Rc Verified".tr,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textGreyColor,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: fontFamilyRegular,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        child: ListTile(
                                          onTap: () {
                                            Get.to(TransProfile(uid: bookedLorriesController.currentLoads.bookHistory[index].lorryOwnerId));
                                          },
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: NetworkImage(
                                              "$basUrl${bookedLorriesController.currentLoads.bookHistory[index].lorryOwnerImg}",
                                            ),
                                          ),
                                          title: Transform.translate(
                                            offset: const Offset(0, -2),
                                            child: Text(
                                              bookedLorriesController.currentLoads.bookHistory[index].lorryOwnerTitle,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          trailing: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              backgroundColor: priMaryColor,
                                            ),
                                            onPressed: () {
                                              Get.to(
                                                BookedDetails(
                                                  uid: uid,
                                                  loadId: bookedLorriesController.currentLoads.bookHistory[index].lorryId,
                                                ),
                                              );
                                            },
                                            child: Text(
                                              "Info".tr,
                                              style: TextStyle(
                                                color: whiteColor,
                                                fontSize: 14,
                                                fontFamily: "urbani_extrabold",
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          subtitle: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/ic_star_profile.svg",
                                                width: 16,
                                                height: 16,
                                                color: priMaryColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Transform.translate(
                                                offset: const Offset(0, 1),
                                                child: Text(
                                                  bookedLorriesController.currentLoads.bookHistory[index].review,
                                                  style: TextStyle(
                                                    color: priMaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 20);
                              },
                              itemCount: bookedLorriesController.currentLoads.bookHistory.length,
                            ),
                  bookedLorriesController.isLoading
                      ? ListView.separated(
                          physics: const AlwaysScrollableScrollPhysics(),
                          padding: const EdgeInsets.all(10),
                          shrinkWrap: true,
                          itemBuilder: (context, index) {
                            return commonSimmer(height: 200, width: 60);
                          },
                          separatorBuilder: (context, index) {
                            return const SizedBox(height: 15);
                          },
                          itemCount: 10,
                        )
                      : bookedLorriesController.completedLoads.bookHistory.isEmpty
                          ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SvgPicture.asset("assets/image/54.svg"),
                                const SizedBox(height: 8),
                                Text(
                                  "No Load Placed! Currently You Don't Have Any Loads".tr,
                                  style: TextStyle(
                                    fontSize: 18,
                                    color: textGreyColor,
                                    fontWeight: FontWeight.w500,
                                    fontFamily: "urbani_regular",
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ],
                            )
                          : ListView.separated(
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shrinkWrap: true,
                              itemBuilder: (context, index) {
                                return Container(
                                  margin: const EdgeInsets.symmetric(horizontal: 15),
                                  padding: const EdgeInsets.all(15),
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(12),
                                    border: Border.all(
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                  ),
                                  child: Column(
                                    children: [
                                      Row(
                                        children: [
                                          Image.network(
                                            "$basUrl${bookedLorriesController.completedLoads.bookHistory[index].lorryImg}",
                                            height: 100,
                                            width: 100,
                                            errorBuilder: (context, error, stackTrace) {
                                              return commonSimmer(height: 100, width: 100);
                                            },
                                            loadingBuilder: (context, child, loadingProgress) {
                                              return (loadingProgress == null)
                                                  ? child
                                                  : commonSimmer(height: 100, width: 100);
                                            },
                                          ),
                                          const SizedBox(width: 8),
                                          Flexible(
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.start,
                                              children: [
                                                Text(
                                                  bookedLorriesController.completedLoads.bookHistory[index].lorryTitle,
                                                  style: TextStyle(
                                                    fontSize: 18,
                                                    color: textBlackColor,
                                                    fontFamily: fontFamilyBold,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 4,
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_pickup_map.svg",
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        bookedLorriesController.completedLoads.bookHistory[index].pickupPoint,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: textBlackColor,
                                                          fontFamily: fontFamilyRegular,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Row(
                                                  crossAxisAlignment: CrossAxisAlignment.center,
                                                  mainAxisSize: MainAxisSize.min,
                                                  children: [
                                                    SvgPicture.asset(
                                                      "assets/icons/ic_pickup_map.svg",
                                                      width: 20,
                                                      height: 20,
                                                    ),
                                                    const SizedBox(width: 4),
                                                    Flexible(
                                                      child: Text(
                                                        bookedLorriesController.completedLoads.bookHistory[index].dropPoint,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: textBlackColor,
                                                          fontFamily: fontFamilyRegular,
                                                          fontWeight: FontWeight.w500,
                                                        ),
                                                        overflow: TextOverflow.ellipsis,
                                                        maxLines: 4,
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                                const SizedBox(height: 8),
                                                Text(
                                                  bookedLorriesController.completedLoads.bookHistory[index].lorryNo,
                                                  style: TextStyle(
                                                    fontSize: 16,
                                                    color: textBlackColor,
                                                    fontFamily: fontFamilyBold,
                                                    fontWeight: FontWeight.w500,
                                                  ),
                                                  overflow: TextOverflow.ellipsis,
                                                  maxLines: 4,
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Row(
                                        children: [
                                          SvgPicture.asset(
                                            "assets/icons/delivery-cart-arrow-up.svg",
                                            height: 24,
                                            width: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${bookedLorriesController.completedLoads.bookHistory[index].weight} ${"Tonnes".tr}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textGreyColor,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: fontFamilyRegular,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const Spacer(),
                                          SvgPicture.asset(
                                            "assets/icons/route.svg",
                                            height: 24,
                                            width: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "${bookedLorriesController.completedLoads.bookHistory[index].routesCount} ${"Routes".tr}",
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textGreyColor,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: fontFamilyRegular,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                          const Spacer(),
                                          SvgPicture.asset(
                                            rcVerifide(bookedLorriesController.completedLoads.bookHistory[index].rcVerify),
                                            height: 24,
                                            width: 24,
                                          ),
                                          const SizedBox(width: 8),
                                          Text(
                                            "Rc Verified".tr,
                                            style: TextStyle(
                                              fontSize: 14,
                                              color: textGreyColor,
                                              overflow: TextOverflow.ellipsis,
                                              fontFamily: fontFamilyRegular,
                                            ),
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                          ),
                                        ],
                                      ),
                                      const SizedBox(height: 18),
                                      Container(
                                        decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(12),
                                          border: Border.all(
                                            color: Colors.grey.withOpacity(0.3),
                                          ),
                                        ),
                                        child: ListTile(
                                          onTap: () {
                                            Get.to(
                                              TransProfile(
                                                uid: bookedLorriesController.completedLoads.bookHistory[index].lorryOwnerId,
                                              ),
                                            );
                                          },
                                          leading: CircleAvatar(
                                            backgroundColor: Colors.transparent,
                                            backgroundImage: NetworkImage(
                                              "$basUrl${bookedLorriesController.completedLoads.bookHistory[index].lorryOwnerImg}",
                                            ),
                                          ),
                                          title: Transform.translate(
                                            offset: const Offset(0, -2),
                                            child: Text(
                                              bookedLorriesController.completedLoads.bookHistory[index].lorryOwnerTitle,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ),
                                          trailing: ElevatedButton(
                                            style: ElevatedButton.styleFrom(
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(12),
                                              ),
                                              backgroundColor: priMaryColor,
                                            ),
                                            onPressed: () {
                                              Get.to(BookedDetails(uid: uid, loadId: bookedLorriesController.completedLoads.bookHistory[index].lorryId));
                                            },
                                            child: Text(
                                              "Info".tr,
                                              style: TextStyle(
                                                color: whiteColor,
                                                fontSize: 14,
                                                fontFamily: "urbani_extrabold",
                                                fontWeight: FontWeight.w700,
                                              ),
                                            ),
                                          ),
                                          subtitle: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            children: [
                                              SvgPicture.asset(
                                                "assets/icons/ic_star_profile.svg",
                                                width: 16,
                                                height: 16,
                                                color: priMaryColor,
                                              ),
                                              const SizedBox(width: 8),
                                              Transform.translate(
                                                offset: const Offset(0, 1),
                                                child: Text(
                                                  bookedLorriesController.completedLoads.bookHistory[index].review,
                                                  style: TextStyle(
                                                    color: priMaryColor,
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder: (context, index) {
                                return const SizedBox(height: 20);
                              },
                              itemCount: bookedLorriesController.completedLoads.bookHistory.length,
                            ),
                ]),
              ),
            ],
          ),
        ),
      );
    });
  }

  rcVerifide(String id) {
    switch (id) {
      case "1":
        return "assets/icons/badge-check.svg";
      case "2":
        return "assets/icons/ic_unverified.svg";
    }
  }
}
