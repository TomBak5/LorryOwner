// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/myloads_controller.dart';
import '../../widgets/widgets.dart';
import '../sub_pages/myloads_detils.dart';
import '../sub_pages/live_navigation_screen.dart';

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
    print("=== BUILDING MY LOADS SCREEN ===");
    print("Current data length: ${myLoadsController.currentData.loadHistoryData.length}");
    print("Assigned orders length: ${myLoadsController.assignedOrders.length}");
    print("Is loading: ${myLoadsController.isLoading}");
    print("Is loading orders: ${myLoadsController.isLoadingOrders}");
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
                                  return const SizedBox(height: 15);
                                },
                                itemCount: 10,
                              )
                            : _buildCurrentLoadsContent(),
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
                                          width: double.infinity,
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
                                                      return commonSimmer(height: 58, width: 58);
                                                    },
                                                    loadingBuilder: (context, child, loadingProgress) {
                                                      return (loadingProgress == null)
                                                          ? child
                                                          : commonSimmer(height: 58, width: 58);
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
                                                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
                                                          padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
                                                ],
                                              ),
                                              Divider(height: 30, color: Colors.grey.withOpacity(0.3)),
                                              Row(
                                                children: [
                                                  Text(myLoadsController.complete.loadHistoryData[index].postDate.toString().split(" ").first),
                                                  const Spacer(),
                                                  Text(myLoadsController.complete.loadHistoryData[index].loadStatus),
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

  Widget _buildCurrentLoadsContent() {
    print("=== BUILDING CURRENT LOADS CONTENT ===");
    print("Assigned orders count: ${myLoadsController.assignedOrders.length}");
    return SingleChildScrollView(
      physics: const AlwaysScrollableScrollPhysics(),
      child: Column(
        children: [
          // Regular loads section
          if (myLoadsController.currentData.loadHistoryData.isNotEmpty) ...[
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Regular Loads".tr,
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: textBlackColor,
                ),
              ),
            ),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
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
                    width: double.infinity,
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
                                return commonSimmer(height: 58, width: 58);
                              },
                              loadingBuilder: (context, child, loadingProgress) {
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
                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
                                      padding: EdgeInsets.symmetric(vertical: 5, horizontal: 8),
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
          ],

          // Assigned orders section
          if (myLoadsController.assignedOrders.isNotEmpty) ...[
            if (myLoadsController.currentData.loadHistoryData.isNotEmpty)
              const SizedBox(height: 20),
            ListView.separated(
              physics: const NeverScrollableScrollPhysics(),
              padding: const EdgeInsets.all(10),
              shrinkWrap: true,
              itemBuilder: (context, index) {
                final order = myLoadsController.assignedOrders[index];
                return Container(
                  width: double.infinity,
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
                          Container(
                            width: 58,
                            height: 58,
                            decoration: BoxDecoration(
                              color: priMaryColor.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.assignment,
                              color: priMaryColor,
                              size: 30,
                            ),
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              "Assigned Order #${order['id']}",
                              style: TextStyle(
                                fontSize: 14,
                                fontFamily: fontFamilyRegular,
                                color: textBlackColor,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                            decoration: BoxDecoration(
                              color: _getStatusColor(order['status']),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Text(
                              order['status'].toString().toUpperCase(),
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
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
                                    order['pickup_address'] ?? 'N/A',
                                    style: TextStyle(
                                      color: textBlackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: fontFamilyBold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.blue.withOpacity(0.2),
                                    ),
                                    child: Text(
                                      "Pickup".tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: fontFamilyRegular,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.blue,
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
                              SvgPicture.asset(
                                "assets/image/ic_route_truck.svg",
                                color: const Color(0xffD1D5DB),
                              ),
                              const SizedBox(height: 5),
                              const Text(
                                "→",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.grey,
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
                                    order['dropoff_address'] ?? 'N/A',
                                    style: TextStyle(
                                      color: textBlackColor,
                                      fontSize: 16,
                                      fontWeight: FontWeight.w500,
                                      fontFamily: fontFamilyBold,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 2,
                                  ),
                                  const SizedBox(height: 8),
                                  Container(
                                    padding: const EdgeInsets.symmetric(vertical: 5, horizontal: 8),
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(8),
                                      color: Colors.red.withOpacity(0.2),
                                    ),
                                    child: Text(
                                      "Delivery".tr,
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: fontFamilyRegular,
                                        fontWeight: FontWeight.w400,
                                        color: Colors.red,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                      if (order['route_info'] != null) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: Colors.blue.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: Colors.blue.withOpacity(0.3)),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Icon(Icons.route, size: 16, color: Colors.blue[600]),
                                  const SizedBox(width: 8),
                                  Text(
                                    "Route Information",
                                    style: TextStyle(
                                      fontSize: 14,
                                      fontWeight: FontWeight.bold,
                                      color: Colors.blue[600],
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Row(
                                          children: [
                                            Icon(Icons.straighten, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              order['route_info']['distance'] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Icon(Icons.access_time, size: 14, color: Colors.grey[600]),
                                            const SizedBox(width: 4),
                                            Text(
                                              order['route_info']['duration'] ?? 'N/A',
                                              style: TextStyle(
                                                fontSize: 12,
                                                fontWeight: FontWeight.w500,
                                                color: Colors.grey[700],
                                              ),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  Container(
                                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                                    decoration: BoxDecoration(
                                      color: Colors.green.withOpacity(0.1),
                                      borderRadius: BorderRadius.circular(4),
                                    ),
                                    child: Text(
                                      "Truck Route",
                                      style: TextStyle(
                                        fontSize: 10,
                                        color: Colors.green[700],
                                        fontWeight: FontWeight.w500,
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              if (order['route_info']['route_summary'] != null) ...[
                                const SizedBox(height: 8),
                                Container(
                                  padding: const EdgeInsets.all(8),
                                  decoration: BoxDecoration(
                                    color: Colors.grey.withOpacity(0.1),
                                    borderRadius: BorderRadius.circular(4),
                                  ),
                                  child: Row(
                                    children: [
                                      Icon(Icons.info_outline, size: 12, color: Colors.grey[600]),
                                      const SizedBox(width: 4),
                                      Expanded(
                                        child: Text(
                                          order['route_info']['route_summary'],
                                          style: TextStyle(
                                            fontSize: 11,
                                            color: Colors.grey[600],
                                          ),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ],
                            ],
                          ),
                        ),
                      ] else if (order['cargo_details'] != null && order['cargo_details'].toString().isNotEmpty) ...[
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.grey.withOpacity(0.1),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Row(
                            children: [
                              Icon(Icons.inventory, size: 16, color: Colors.grey[600]),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  "Cargo: ${order['cargo_details']}",
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.grey[600],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                      Divider(height: 30, color: Colors.grey.withOpacity(0.3)),
                      Row(
                        children: [
                          Text(
                            "Created: ${order['created_at']?.toString().split(' ')[0] ?? 'N/A'}",
                            style: TextStyle(
                              fontSize: 12,
                              color: Colors.grey[600],
                            ),
                          ),
                          const Spacer(),
                          // Always show Accept/Cancel buttons for testing purposes
                          Row(
                            children: [
                              TextButton(
                                onPressed: () => _acceptOrderAndNavigate(order),
                                child: Text(
                                  "Accept",
                                  style: TextStyle(color: Colors.green),
                                ),
                              ),
                              TextButton(
                                onPressed: () => _updateOrderStatus(order['id'].toString(), 'rejected'),
                                child: Text(
                                  "Reject",
                                  style: TextStyle(color: Colors.red),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                    ],
                  ),
                );
              },
              separatorBuilder: (context, index) {
                return const SizedBox(height: 15);
              },
              itemCount: myLoadsController.assignedOrders.length,
            ),
          ],

          // No content message
          if (myLoadsController.currentData.loadHistoryData.isEmpty && myLoadsController.assignedOrders.isEmpty)
            Column(
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
            ),
        ],
      ),
    );
  }

  Color _getStatusColor(String status) {
    switch (status.toLowerCase()) {
      case 'pending':
        return Colors.orange;
      case 'assigned':
        return Colors.blue;
      case 'accepted':
        return Colors.green;
      case 'rejected':
        return Colors.red;
      case 'completed':
        return Colors.green;
      default:
        return Colors.grey;
    }
  }

  void _updateOrderStatus(String orderId, String status) async {
    try {
      final apiProvider = ApiProvider();
      final result = await apiProvider.updateOrderStatus(
        orderId: orderId,
        status: status,
      );
      
      if (result['success'] == true) {
        Get.snackbar(
          'Success',
          'Order status updated successfully',
          backgroundColor: Colors.green,
          colorText: Colors.white,
        );
        // Refresh the data
        myLoadsController.fetchDataFromApi();
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to update order status',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      Get.snackbar(
        'Error',
        'Failed to update order status: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _acceptOrderAndNavigate(Map<String, dynamic> order) async {
    try {
      print("=== ACCEPT ORDER DEBUG ===");
      print("Order data: $order");
      
      // First update the order status to accepted
      final apiProvider = ApiProvider();
      final result = await apiProvider.updateOrderStatus(
        orderId: order['id'].toString(),
        status: 'accepted',
      );
      
      if (result['success'] == true) {
        print("✅ Order status updated successfully, now starting navigation...");
        
        // Start navigation
        _startNavigation(order);
        
      } else {
        Get.snackbar(
          'Error',
          result['message'] ?? 'Failed to accept order',
          backgroundColor: Colors.red,
          colorText: Colors.white,
        );
      }
    } catch (e) {
      print("Error in _acceptOrderAndNavigate: $e");
      Get.snackbar(
        'Error',
        'Failed to accept order: $e',
        backgroundColor: Colors.red,
        colorText: Colors.white,
      );
    }
  }

  void _startNavigation(Map<String, dynamic> order) async {
    try {
      print("=== NAVIGATION DEBUG ===");
      print("Order data received:");
      print("Order ID: ${order['id']}");
      
      // Check if coordinates are available
      if (order['pick_lat'] != null && order['pick_lng'] != null && 
          order['drop_lat'] != null && order['drop_lng'] != null) {
        
        try {
          final pickupLat = double.parse(order['pick_lat'].toString());
          final pickupLng = double.parse(order['pick_lng'].toString());
          final dropoffLat = double.parse(order['drop_lat'].toString());
          final dropoffLng = double.parse(order['drop_lng'].toString());
          
          print("✅ Valid coordinates found:");
          print("Pickup: $pickupLat, $pickupLng");
          print("Dropoff: $dropoffLat, $dropoffLng");
          
          // Navigate to live navigation screen
          Get.to(() => LiveNavigationScreen(
            orderData: order,
            pickupLat: pickupLat,
            pickupLng: pickupLng,
            dropoffLat: dropoffLat,
            dropoffLng: dropoffLng,
          ));
          
          // Refresh the data
          myLoadsController.fetchDataFromApi();
          
        } catch (e) {
          print("❌ Error parsing coordinates: $e");
          _tryFetchOrderDetails(order);
        }
        
      } else {
        print("⚠️ No coordinates available, fetching detailed order information");
        _tryFetchOrderDetails(order);
      }
      
    } catch (e) {
      print('Error starting navigation: $e');
      Get.snackbar('Navigation Error', 'Failed to start navigation: $e');
    }
  }

  Future<void> _tryFetchOrderDetails(Map<String, dynamic> order) async {
    try {
      print("=== FETCHING ORDER DETAILS ===");
      
      // No loading dialog needed
      
      // Get user ID from SharedPreferences
      final prefs = await SharedPreferences.getInstance();
      final userDataString = prefs.getString("userData");
      if (userDataString != null) {
        final userData = jsonDecode(userDataString);
        final userId = userData["id"].toString();
        
        // Call API to get detailed order information
        final apiProvider = ApiProvider();
        final orderDetails = await apiProvider.getDriverOrderDetails(
          driverId: userId,
          orderId: order['id'].toString(),
        );
        
                 // Loading dialog removed
        
        if (orderDetails != null && 
            orderDetails['pick_lat'] != null && 
            orderDetails['pick_lng'] != null &&
            orderDetails['drop_lat'] != null && 
            orderDetails['drop_lng'] != null) {
          
          try {
            final pickupLat = double.parse(orderDetails['pick_lat'].toString());
            final pickupLng = double.parse(orderDetails['pick_lng'].toString());
            final dropoffLat = double.parse(orderDetails['drop_lat'].toString());
            final dropoffLng = double.parse(orderDetails['drop_lng'].toString());
            
            print("✅ Got coordinates from API:");
            print("Pickup: $pickupLat, $pickupLng");
            print("Dropoff: $dropoffLat, $dropoffLng");
            
            // Navigate to live navigation screen
            Get.to(() => LiveNavigationScreen(
              orderData: order,
              pickupLat: pickupLat,
              pickupLng: pickupLng,
              dropoffLat: dropoffLat,
              dropoffLng: dropoffLng,
            ));
            
            return;
            
          } catch (e) {
            print("❌ Error parsing coordinates: $e");
            Get.snackbar('Error', 'Failed to parse coordinates');
          }
          
        } else {
          print("❌ No coordinates in API response");
          Get.snackbar(
            'Navigation Not Available', 
            'This order does not have map coordinates. Please contact the dispatcher.',
            duration: const Duration(seconds: 5),
          );
        }
        
             } else {
         // Loading dialog removed
         Get.snackbar('Error', 'User not logged in');
       }
      
         } catch (e) {
       print("❌ Error fetching order details: $e");
       // Loading dialog removed
       Get.snackbar('Error', 'Failed to fetch order details: $e');
     }
  }
} 