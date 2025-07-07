// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/myloads_controller.dart';
import '../../widgets/widgets.dart';
import '../sub_pages/myloads_detils.dart';

class MyLoads extends StatefulWidget {
  const MyLoads({super.key});

  @override
  State<MyLoads> createState() => _MyLoadsState();
}

class _MyLoadsState extends State<MyLoads> {
  MyLoadsController myLoadsController = Get.put(MyLoadsController());

  @override
  void dispose() {
    super.dispose();

    myLoadsController.isLoading = true;
  }

  @override
  initState() {
    super.initState();
    myLoadsController.fetchDataFromApi();
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<MyLoadsController>(
      builder: (myLoadsController) {
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
                              "My Loads".tr,
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
              ),
            ),
            body: RefreshIndicator(
              onRefresh: () {
                return Future.delayed(
                  const Duration(seconds: 1),
                  () {
                    myLoadsController.fetchDataFromApi();
                  },
                );
              },
              child: Column(
                children: [
                  Expanded(
                    child: TabBarView(
                      children: [
                        myLoadsController.isLoading
                            ? ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(10),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return commonSimmer(height: 120, width: 60);
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(
                                    height: 15,
                                  );
                                },
                                itemCount: 10,
                              )
                            : myLoadsController
                                    .currentData.loadHistoryData.isEmpty
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
                                    physics: AlwaysScrollableScrollPhysics(),
                                    padding: const EdgeInsets.all(10),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Get.to(
                                            LoadsDetails(
                                              uid: myLoadsController.uid,
                                              loadId: myLoadsController.currentData.loadHistoryData[index].id,
                                              currency: myLoadsController.currency,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 120,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.4),
                                                blurRadius: 5,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Image.network(
                                                    "$basUrl${myLoadsController.currentData.loadHistoryData[index].vehicleImg}",
                                                    width: 58,
                                                    height: 58,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return commonSimmer(height: 58,width: 58);
                                                    },
                                                    loadingBuilder: (context,
                                                        child,
                                                        loadingProgress) {
                                                      return (loadingProgress == null)
                                                          ? child
                                                          : commonSimmer(height: 58, width: 58);
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    myLoadsController.currentData.loadHistoryData[index].vehicleTitle,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: fontFamilyRegular,
                                                      color: textBlackColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "${myLoadsController.currency}${myLoadsController.currentData.loadHistoryData[index].amount}",
                                                          style: TextStyle(
                                                            color: textBlackColor,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: fontFamilyBold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: " /${myLoadsController.currentData.loadHistoryData[index].amtType}",
                                                          style: TextStyle(
                                                            color: textGreyColor,
                                                            fontSize: 12,
                                                            fontFamily: fontFamilyRegular,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Flexible(
                                                    flex: 3,
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            myLoadsController.currentData.loadHistoryData[index].pickupState,
                                                            style: TextStyle(
                                                              color: textBlackColor,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: fontFamilyBold,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(vertical: 5,horizontal:8),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: Colors.grey.withOpacity(0.2),
                                                            ),
                                                            child: Text(
                                                              "Load".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(flex: 1),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/image/ic_route_truck.svg",
                                                            color: const Color(0xffD1D5DB),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        myLoadsController.currentData.loadHistoryData[index].loadDistance,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: textGreyColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(flex: 1),
                                                  Flexible(
                                                    flex: 3,
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            myLoadsController.currentData.loadHistoryData[index].dropState,
                                                            style: TextStyle(
                                                              color: textBlackColor,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: fontFamilyBold,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(vertical: 5, horizontal:8),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: Colors.grey.withOpacity(0.2),
                                                            ),
                                                            child: Text(
                                                              "UnLoad".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(height: 30, color: Colors.grey.withOpacity(0.3)),
                                              Row(
                                                children: [
                                                  Text(myLoadsController.currentData.loadHistoryData[index].postDate.toString().split(" ").first),
                                                  const Spacer(),
                                                  Text(myLoadsController.currentData.loadHistoryData[index].loadStatus),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return const SizedBox(height: 15);
                                    },
                                    itemCount: myLoadsController.currentData.loadHistoryData.length,
                                  ),
                        myLoadsController.isLoading
                            ? ListView.separated(
                                physics: const AlwaysScrollableScrollPhysics(),
                                padding: const EdgeInsets.all(10),
                                shrinkWrap: true,
                                itemBuilder: (context, index) {
                                  return commonSimmer(height: 120, width: 60);
                                },
                                separatorBuilder: (context, index) {
                                  return const SizedBox(height: 15);
                                },
                                itemCount: 10,
                              )
                            : myLoadsController.complete.loadHistoryData.isEmpty
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
                                    padding: const EdgeInsets.all(10),
                                    shrinkWrap: true,
                                    itemBuilder: (context, index) {
                                      return InkWell(
                                        onTap: () {
                                          Get.to(
                                            LoadsDetails(
                                              uid: myLoadsController.uid,
                                              loadId: myLoadsController.complete.loadHistoryData[index].id,
                                              currency: myLoadsController.currency,
                                            ),
                                          );
                                        },
                                        child: Container(
                                          width: 120,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            color: Colors.white,
                                            borderRadius: BorderRadius.circular(12),
                                            boxShadow: [
                                              BoxShadow(
                                                color: Colors.grey.withOpacity(0.4),
                                                blurRadius: 5,
                                                blurStyle: BlurStyle.outer,
                                              ),
                                            ],
                                          ),
                                          child: Column(
                                            children: [
                                              Row(
                                                children: [
                                                  Image.network(
                                                    "$basUrl${myLoadsController.complete.loadHistoryData[index].vehicleImg}",
                                                    width: 58,
                                                    height: 58,
                                                    errorBuilder: (context, error, stackTrace) {
                                                      return commonSimmer(height: 58,width: 58);
                                                    },
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      return (loadingProgress == null)
                                                          ? child
                                                          : commonSimmer(height: 58,width: 58);
                                                    },
                                                  ),
                                                  const SizedBox(width: 8),
                                                  Text(
                                                    myLoadsController.complete.loadHistoryData[index].vehicleTitle,
                                                    style: TextStyle(
                                                      fontSize: 14,
                                                      fontFamily: fontFamilyRegular,
                                                      color: textBlackColor,
                                                      fontWeight: FontWeight.w500,
                                                    ),
                                                  ),
                                                  const Spacer(),
                                                  RichText(
                                                    text: TextSpan(
                                                      children: [
                                                        TextSpan(
                                                          text: "${myLoadsController.currency}${myLoadsController.complete.loadHistoryData[index].amount}",
                                                          style: TextStyle(
                                                            color: textBlackColor,
                                                            fontSize: 18,
                                                            fontWeight: FontWeight.w500,
                                                            fontFamily: fontFamilyBold,
                                                          ),
                                                        ),
                                                        TextSpan(
                                                          text: " /${myLoadsController.complete.loadHistoryData[index].amtType}",
                                                          style: TextStyle(
                                                            color: textGreyColor,
                                                            fontSize: 12,
                                                            fontFamily: fontFamilyRegular,
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              const SizedBox(height: 12),
                                              Row(
                                                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                children: [
                                                  Flexible(
                                                    flex: 3,
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            myLoadsController.complete.loadHistoryData[index].pickupState,
                                                            style: TextStyle(
                                                              color: textBlackColor,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: fontFamilyBold,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(vertical: 5,horizontal:8),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: Colors.grey.withOpacity(0.2),
                                                            ),
                                                            child: Text(
                                                              "Load".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                  const Spacer(flex: 1),
                                                  Column(
                                                    children: [
                                                      Row(
                                                        crossAxisAlignment: CrossAxisAlignment.center,
                                                        children: [
                                                          SvgPicture.asset(
                                                            "assets/image/ic_route_truck.svg",
                                                            color: const Color(0xffD1D5DB),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(height: 5),
                                                      Text(
                                                        myLoadsController.complete.loadHistoryData[index].loadDistance,
                                                        style: TextStyle(
                                                          fontSize: 10,
                                                          color: textGreyColor,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                  const Spacer(flex: 1),
                                                  Flexible(
                                                    flex: 3,
                                                    child: SizedBox(
                                                      width: 100,
                                                      child: Column(
                                                        crossAxisAlignment: CrossAxisAlignment.end,
                                                        children: [
                                                          Text(
                                                            myLoadsController.complete.loadHistoryData[index].dropState,
                                                            style: TextStyle(
                                                              color: textBlackColor,
                                                              fontSize: 18,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: fontFamilyBold,
                                                            ),
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Container(
                                                            padding: EdgeInsets.symmetric(vertical: 5,horizontal:8),
                                                            decoration: BoxDecoration(
                                                              borderRadius: BorderRadius.circular(8),
                                                              color: Colors.grey.withOpacity(0.2),
                                                            ),
                                                            child: Text(
                                                              "UnLoad".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                fontWeight: FontWeight.w400,
                                                              ),
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                              Divider(height: 30, color: Colors.grey.withOpacity(0.3)),
                                              Row(
                                                children: [
                                                  Text(myLoadsController.complete.loadHistoryData[index].postDate.toString().split(" ").first),
                                                  Spacer(),
                                                  Text(myLoadsController.complete.loadHistoryData[index].loadStatus),
                                                ],
                                              )
                                            ],
                                          ),
                                        ),
                                      );
                                    },
                                    separatorBuilder: (context, index) {
                                      return SizedBox(height: 15);
                                    },
                                    itemCount: myLoadsController.complete.loadHistoryData.length,
                                  ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}
