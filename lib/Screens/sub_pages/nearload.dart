// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Controllers/bid_bottomsheet_controller.dart';
import 'package:movers_lorry_owner/Controllers/near_load_controller.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/trans_profile.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../models/lorry_list_model.dart';
import '../../models/near_load_model.dart';

class NearLoad extends StatefulWidget {
  const NearLoad({super.key});

  @override
  State<NearLoad> createState() => _NearLoadState();
}

class _NearLoadState extends State<NearLoad> {
  bool isLoading = true;
  String currency = '';
  String uid = '';

  double locationLatitude = 0.00;
  double locationLongtitude = 0.00;

  @override
  void initState() {
    super.initState();
    if (lat == 0.0 && long == 0.0) {
      locationPermission().then((value) {
        setState(() {
          locationLatitude = lat;
          locationLongtitude = long;
        });
        getDataFromApi(lats: locationLatitude, longs: locationLongtitude);
      });
    } else {
      setState(() {
        locationLatitude = lat;
        locationLongtitude = long;
      });
      getDataFromApi(lats: locationLatitude, longs: locationLongtitude);
    }
  }

  getDataFromApi({required double lats, required double longs}) async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      uid = preferences.getString("uid")!;
      currency = preferences.getString("currencyIcon")!;
    });
    dataApi(lats: lats, longs: longs);
  }

  dataApi({required double lats, required double longs, int? inde}) {
    ApiProvider()
        .nearLoad(ownerid: uid, lats: lats, longs: longs)
        .then((value) {
      debugPrint("========= result ======= ${value}");
      if (value.result == "true") {
        setState(() {
          isLoading = false;
          nearLoadController.loaddata = value;
        });
        nearLoadController.isbidLoder = List.filled(nearLoadController.loaddata.loaddata.length, false);
        setState(() {});
        debugPrint("========== isbidLoder ========= ${nearLoadController.isbidLoder.length}");
        nearLoadController.setIsBidLoder(index: inde ?? 0, value: false);
      }
    });
  }

  NearLoadController nearLoadController = Get.put(NearLoadController());
  BidBottomsheetController bidBottomsheetController = Get.put(BidBottomsheetController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<NearLoadController>(
      builder: (nearLoadController) {
        return Scaffold(
          appBar: AppBar(
            elevation: 0,
            backgroundColor: priMaryColor,
            centerTitle: true,
            title: Text(
              "Near Load".tr,
              style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyBold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
                  onRefresh: () {
                    return Future.delayed(
                      Duration(seconds: 1),
                      () {
                        dataApi(
                          lats: locationLatitude,
                          longs: locationLongtitude,
                        );
                      },
                    );
                  },
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            "${nearLoadController.loaddata.loaddata.length} ${"Available".tr}",
                            style: TextStyle(
                              fontSize: 18,
                              fontFamily: fontFamilyBold,
                              fontWeight: FontWeight.w700,
                              color: textBlackColor,
                            ),
                          ),
                          const SizedBox(height: 10),
                          ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              Loaddatum loads = nearLoadController.loaddata.loaddata[index];
                              return Container(
                                // height: 280,
                                padding: const EdgeInsets.all(15),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(12),
                                  boxShadow: [
                                    BoxShadow(
                                      color: Colors.grey.withOpacity(0.7),
                                      offset: const Offset(0, 10),
                                      blurRadius: 2,
                                      blurStyle: BlurStyle.outer,
                                    ),
                                  ],
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Image.network(
                                          "$basUrl${loads.vehicleImg}",
                                          height: 50,
                                          width: 50,
                                        ),
                                        const SizedBox(width: 8),
                                        Text(loads.vehicleTitle),
                                        const Spacer(),
                                        RichText(
                                          text: TextSpan(
                                            children: [
                                              TextSpan(
                                                text: "$currency${loads.amount}",
                                                style: TextStyle(
                                                  fontSize: 18,
                                                  color: textBlackColor,
                                                  fontFamily: fontFamilyBold,
                                                  fontWeight: FontWeight.w600,
                                                ),
                                              ),
                                              TextSpan(
                                                text: " /${loads.amtType}",
                                                style: TextStyle(
                                                  color: textGreyColor,
                                                  fontFamily: fontFamilyRegular,
                                                  fontSize: 12,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
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
                                                  loads.pickupState,
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
                                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
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
                                        Column(
                                          children: [
                                            Row(
                                              crossAxisAlignment: CrossAxisAlignment.center,
                                              children: [
                                                Tooltip(
                                                  triggerMode: TooltipTriggerMode.tap,
                                                  message: loads.pickupPoint,
                                                  child: SvgPicture.asset(
                                                    "assets/image/ic_info_location.svg",
                                                    height: 20,
                                                    width: 20,
                                                  ),
                                                ),
                                                const SizedBox(width: 2),
                                                SvgPicture.asset(
                                                  "assets/image/ic_route_truck.svg",
                                                  color: Color(0xffD1D5DB),
                                                ),
                                                const SizedBox(width: 2),
                                                Tooltip(
                                                  triggerMode: TooltipTriggerMode.tap,
                                                  message: loads.dropPoint,
                                                  child: SvgPicture.asset(
                                                    "assets/image/ic_info_location.svg",
                                                    height: 20,
                                                    width: 20,
                                                  ),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(height: 5),
                                            Text(
                                              loads.loadDistance,
                                              style: TextStyle(
                                                fontSize: 10,
                                                color: textGreyColor,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Flexible(
                                          flex: 3,
                                          child: SizedBox(
                                            width: 100,
                                            child: Column(
                                              crossAxisAlignment: CrossAxisAlignment.end,
                                              children: [
                                                Text(
                                                  loads.dropState,
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
                                                  padding: EdgeInsets.symmetric(vertical: 5,horizontal: 8),
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
                                    Divider(
                                      height: 30,
                                      color: Colors.grey.withOpacity(0.3),
                                    ),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                      children: [
                                        Column(
                                          children: [
                                            Text(
                                              "Date".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textGreyColor,
                                                fontFamily: fontFamilyRegular,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              "${loads.postDate.toString().split(" ").first}".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textBlackColor,
                                                fontFamily: fontFamilyRegular,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Tonnes".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textGreyColor,
                                                fontFamily: fontFamilyRegular,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              loads.weight,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textBlackColor,
                                                fontFamily: fontFamilyRegular,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
                                        ),
                                        Column(
                                          children: [
                                            Text(
                                              "Material".tr,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textGreyColor,
                                                fontFamily: fontFamilyRegular,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            Text(
                                              loads.materialName,
                                              style: TextStyle(
                                                fontSize: 14,
                                                color: textBlackColor,
                                                fontFamily: fontFamilyRegular,
                                                fontWeight: FontWeight.w900,
                                              ),
                                            ),
                                          ],
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
                                          Get.to(TransProfile(uid: loads.uid));
                                        },
                                        leading: CircleAvatar(
                                          backgroundColor: Colors.transparent,
                                          backgroundImage: NetworkImage(
                                            "$basUrl${loads.ownerImg}",
                                          ),
                                        ),
                                        title: Text(
                                          loads.ownerName,
                                          overflow: TextOverflow.ellipsis,
                                          maxLines: 1,
                                        ),
                                        trailing: (loads.isBid == 1 || loads.isBid == 3)
                                            ? nearLoadController.isbidLoder[index]
                                                ? Container(
                                                    width: 100,
                                                    child: Center(
                                                      child: SpinKitThreeBounce(
                                                        color: priMaryColor,
                                                        size: 15.0,
                                                      ),
                                                    ),
                                                  )
                                                : InkWell(
                                                    onTap: () {
                                                      if (nearLoadController.isbidLoder[index] == false) {
                                                        nearLoadController.setIsBidLoder(index: index,value: true);
                                                        ApiProvider().deleteBid(
                                                          ownerId: uid,
                                                          loadId: loads.id,
                                                        ).then((value) {
                                                          var decode = value;
                                                          if (decode["Result"] == "true") {
                                                            dataApi(
                                                              lats: locationLatitude,
                                                              longs: locationLongtitude,
                                                              inde: index,
                                                            );
                                                            if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                                              showCommonToast(decode["ResponseMsg"]);
                                                            }
                                                          } else {
                                                            dataApi(
                                                              lats: locationLatitude,
                                                              longs: locationLongtitude,
                                                              inde: index,
                                                            );
                                                            if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                                              showCommonToast(decode["ResponseMsg"]);
                                                            }
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Container(
                                                      height: 40,
                                                      width: 50,
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),
                                                        gradient: LinearGradient(
                                                          colors: [
                                                            Color(0xffFF69B6),
                                                            Color(0xffED047C),
                                                          ],
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: SvgPicture.asset(
                                                          "assets/icons/trash.svg",
                                                          color: Colors.white,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                            : nearLoadController.isbidLoder[index]
                                                ? Container(
                                                    width: 100,
                                                    child: Center(
                                                      child: SpinKitThreeBounce(
                                                        color: priMaryColor,
                                                        size: 15.0,
                                                      ),
                                                    ),
                                                  )
                                                : ElevatedButton(
                                                    style: ElevatedButton.styleFrom(
                                                      shape: RoundedRectangleBorder(
                                                        borderRadius: BorderRadius.circular(12),
                                                      ),
                                                      backgroundColor: priMaryColor,
                                                    ),
                                                    onPressed: () {
                                                      if (nearLoadController.isbidLoder[index] == false) {
                                                        nearLoadController.setIsBidLoder(index: index, value: true);
                                                        ApiProvider().getLorryList(
                                                          ownerId: uid,
                                                          loadId: loads.id,
                                                        ).then((value) {
                                                          nearLoadController.setIsBidLoder(index: index, value: false);

                                                          if (value["Result"] == "true") {
                                                            bidBottomsheetController
                                                                .bidNowBottombar(
                                                              lorrydata: LorryListModel.fromJson(value),
                                                              loadId: loads.id,
                                                              ownerId: uid,
                                                              tonns: loads.weight,
                                                              totalLoad: loads.weight,
                                                              inde: index,
                                                            ).then((value) {
                                                              dataApi(
                                                                lats: locationLatitude,
                                                                longs: locationLongtitude,
                                                                inde: index,
                                                              );
                                                            });
                                                          }
                                                        });
                                                      }
                                                    },
                                                    child: Text(
                                                      "Bid Now".tr,
                                                      style: TextStyle(
                                                        color: whiteColor,
                                                        fontSize: 14,
                                                        fontFamily: "urbani_extrabold",
                                                        fontWeight: FontWeight.w700,
                                                      ),
                                                    ),
                                                  ),
                                        subtitle: Column(
                                          mainAxisSize: MainAxisSize.min,
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Row(
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
                                                    loads.ownerRating,
                                                    style: TextStyle(
                                                      color: priMaryColor,
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            loads.isBid == 3
                                                ? Column(
                                                    mainAxisSize: MainAxisSize.min,
                                                    crossAxisAlignment: CrossAxisAlignment.start,
                                                    children: [
                                                      SizedBox(height: 5),
                                                      Text(
                                                        "Rejected".tr,
                                                        style: TextStyle(
                                                          fontSize: 14,
                                                          color: textGreyColor,
                                                          fontFamily: fontFamilyRegular,
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : loads.isBid == 1
                                                    ? Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          const SizedBox(height: 5),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: "$currency${loads.bidAmount}",
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: textBlackColor,
                                                                    fontFamily: fontFamilyRegular,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: "/${loads.bidAmountType}",
                                                                  style: TextStyle(
                                                                    fontSize: 10,
                                                                    color: textGreyColor,
                                                                    fontFamily: fontFamilyRegular,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      )
                                                    : const SizedBox(),
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
                            itemCount: nearLoadController.loaddata.loaddata.length,
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
        );
      },
    );
  }
}
