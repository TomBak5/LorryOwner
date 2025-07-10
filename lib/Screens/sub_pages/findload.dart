// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_address_from_latlng/flutter_address_from_latlng.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';

import 'package:get/get.dart';
import 'package:google_places_flutter/google_places_flutter.dart';
import 'package:google_places_flutter/model/prediction.dart';
import 'package:movers_lorry_owner/Controllers/bid_bottomsheet_controller.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/trans_profile.dart';
import 'package:movers_lorry_owner/models/lorry_list_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/find_loads_controller.dart';
import '../../Controllers/homepage_controller.dart';
import '../../models/find_load_model.dart';
import '../../widgets/widgets.dart';

class FindLoad extends StatefulWidget {
  const FindLoad({super.key});

  @override
  State<FindLoad> createState() => _FindLoadState();
}

class _FindLoadState extends State<FindLoad> {
  String currency = "";
  String uid = "";
  bool isloading = true;

  BidBottomsheetController bidBottomsheetController = Get.put(BidBottomsheetController());

  @override
  void initState() {
    super.initState();
    getGkey();
    ApiProvider()
        .findLorry(uid: homePageController.userData?.id ?? '',pickStateId: "0",dropStateId: "0")
        .then((value) {
          if (value["Result"] == "true") {
            findLorryController.setDataInList(FindLoadModel.fromJson(value));
            findLorryController.setIsLoading(false);
            isloading = false;
            if (findLorryController.loadData.findLoadData.isNotEmpty) {
              findLorryController.isBidNowLoder = List.filled(findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length, false);
              findLorryController.isBidLoder = List.filled(findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length, false);
            }
            findLorryController.setIsShowData(true);
          }
      setState(() {});
    });
    getdatafromlocal();
  }

  getdatafromlocal() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    setState(() {
      currency = preferences.getString("currencyIcon")!;
      uid = preferences.getString("uid")!;
    });
  }

  getDataFromApii({required String pickupState, required String dropState, int? inde}) {
    findLorryController.setIsLoading(true);
    if (dropDownController.text.isNotEmpty && pickUpController.text.isNotEmpty) {
      ApiProvider()
        .checkStat(pickUpName: pickupState, dropStateName: dropState)
        .then((value) {
        var decode = value;
        if (decode["Result"] == "true") {
          findLorryController.setPickUpStatId(decode["pick_state_id"]);
          findLorryController.setDropUpStatId(decode["drop_state_id"]);
          findLorryController.setIsLoading(true);
          ApiProvider()
              .findLorry(
              uid: homePageController.userData?.id ?? '',
              pickStateId: decode["pick_state_id"],
              dropStateId: decode["drop_state_id"])
              .then((value) {
            findLorryController.setDataInList(FindLoadModel.fromJson(value));
            findLorryController.isBidNowLoder = List.filled(findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length, false);
            findLorryController.isBidLoder = List.filled(findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length, false);
            findLorryController.setIsLoading(false);
            findLorryController.setIsShowData(true);
            debugPrint("======= isbidnowLoder ======== ${findLorryController.isBidNowLoder.length}");
            debugPrint("========= isBidLoder ========= ${findLorryController.isBidLoder.length}");
          }).then(
            (value) {
              findLorryController.setIsBidNowLoder(index: inde ?? 0, value: false);
              findLorryController.setIsBidLoder(index: inde ?? 0, value: false);
            },
          );
        } else {
          if (decode["drop_state_id"] == "0") {
            setState(() {
              dropDownController.text = "";
            });
          }
          if (decode["pick_state_id"] == "0") {
            setState(() {
              pickUpController.text = "";
            });
          }
          findLorryController.setIsLoading(false);
          showCommonToast("${decode["ResponseMsg"]}");
        }
      });
    } else {
      ApiProvider()
        .findLorry(uid: homePageController.userData?.id ?? '',pickStateId: "0",dropStateId: "0")
        .then((value) {
          if (value["Result"] == "true") {
            findLorryController.setDataInList(FindLoadModel.fromJson(value));
            findLorryController.setIsLoading(false);
            isloading = false;
            if (findLorryController.loadData.findLoadData.isNotEmpty) {
              findLorryController.isBidNowLoder = List.filled(findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length, false);
              findLorryController.isBidLoder = List.filled(findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length, false);
            }
            debugPrint("======= isbidnowLoder ======== ${findLorryController.isBidNowLoder.length}");
            debugPrint("========= isBidLoder ========= ${findLorryController.isBidLoder.length}");
            findLorryController.setIsShowData(true);
          }
        setState(() {});
      });
    }
    
  }

  String gkey = "";
  getGkey() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      gkey = prefs.getString("gkey") ?? googleMapkey;
    });
  }

  @override
  void dispose() {
    super.dispose();
    if (findLorryController.loadData.findLoadData.isNotEmpty) {
      findLorryController.loadData.findLoadData.clear();
    }
    isloading = true;
    findLorryController.selectVehicle = 0;
    findLorryController.isShowData = false;
  }

  FindLoadController findLorryController = Get.put(FindLoadController());
  HomePageController homePageController = Get.put(HomePageController());
  @override
  Widget build(BuildContext context) {
    return GetBuilder<FindLoadController>(builder: (findLorryController) {
      return RefreshIndicator(
        onRefresh: () {
          return Future.delayed(
            const Duration(
              seconds: 1,
            ),
            () {
              getDataFromApii(
                dropState: findLorryController.dropPoint,
                pickupState: findLorryController.picUpState,
              );
            },
          );
        },
        child: Scaffold(
          backgroundColor: Colors.white,
          appBar: AppBar(
            elevation: 0,
            backgroundColor: priMaryColor,
            centerTitle: true,
            title: Text(
              "Find Loads".tr,
              style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyBold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: isloading
              ? const Center(
                  child: CircularProgressIndicator(),
                )
              : SingleChildScrollView(
                  child: Stack(
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(bottom: 15),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              children: [
                                Expanded(
                                  child: Container(
                                    height: 220,
                                    color: priMaryColor,
                                  ),
                                )
                              ],
                            ),
                            findLorryController.isShowData
                                ? findLorryController.loadData.findLoadData.isEmpty
                                    ? Center(
                                        child: Column(
                                        children: [
                                          SizedBox(
                                            height: Get.height * 0.1,
                                          ),
                                          SvgPicture.asset("assets/image/54.svg"),
                                          const SizedBox(height: 5),
                                          Text(
                                            "No Load Placed! Currently You Don't Have Any Loads".tr,
                                            style: TextStyle(
                                              fontSize: 18,
                                              color: textGreyColor,
                                              fontWeight: FontWeight.w500,
                                              fontFamily: "urbani_regular",
                                            ),
                                            textAlign: TextAlign.center,
                                            maxLines: 2,
                                          ),
                                        ],
                                                                              ))
                                    : Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            SizedBox(height: 15),
                                            Text(
                                              "Select Vehicle type for your load".tr,
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: fontFamilyBold,
                                                fontWeight: FontWeight.w700,
                                                color: textBlackColor,
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                            SizedBox(
                                              width: Get.width,
                                              height: 70,
                                              child: MediaQuery.removePadding(
                                                context: context,
                                                removeLeft: true,
                                                removeRight: true,
                                                child: ListView.separated(
                                                  separatorBuilder: (context, index) {
                                                    return SizedBox(width: 10);
                                                  },
                                                  shrinkWrap: true,
                                                  itemCount: findLorryController.loadData.findLoadData.length,
                                                  scrollDirection: Axis.horizontal,
                                                  itemBuilder: (context, index) {
                                                    return InkWell(
                                                      onTap: () {
                                                        findLorryController.setSelectVehicle(index);
                                                        findLorryController.isBidNowLoder = List.filled(findLorryController.loadData.findLoadData[index].loaddata.length, false);
                                                        findLorryController.isBidLoder = List.filled(findLorryController.loadData.findLoadData[index].loaddata.length, false);
                                                        debugPrint("========= isbidnowLoder ========= ${findLorryController.isBidNowLoder.length}");
                                                        debugPrint("========== isBidLoder =========== ${findLorryController.isBidLoder.length}");
                                                        setState(() {});
                                                      },
                                                      child: Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(12),
                                                          color: findLorryController.selectVehicle == index
                                                              ? priMaryColor.withOpacity(0.05)
                                                              : Colors.grey.withOpacity(0.1),
                                                          border: Border.all(
                                                            color: findLorryController.selectVehicle == index
                                                              ? priMaryColor
                                                              : Colors.grey.withOpacity(0.1),
                                                          ),
                                                        ),
                                                        height: 80,
                                                        padding: EdgeInsets.symmetric(
                                                          horizontal: 15,
                                                        ),
                                                        child: Column(
                                                          mainAxisAlignment: MainAxisAlignment.center,
                                                          children: [
                                                            Flexible(
                                                              child: Text(
                                                                findLorryController.loadData.findLoadData[index].title,
                                                                style: TextStyle(
                                                                  fontSize: 15,
                                                                  color: findLorryController.selectVehicle == index
                                                                  ? priMaryColor
                                                                  : textBlackColor,
                                                                  fontFamily: fontFamilyBold,
                                                                ),
                                                                overflow:TextOverflow.ellipsis,
                                                                maxLines: 1,
                                                              ),
                                                            ),
                                                            const SizedBox(height: 5),
                                                            Text(
                                                              "${findLorryController.loadData.findLoadData[index].minWeight} - ${findLorryController.loadData.findLoadData[index].maxWeight} ${"Tonnes".tr}",
                                                              style: TextStyle(
                                                                color: findLorryController.selectVehicle == index
                                                                  ? secondaryColor
                                                                  : textGreyColor,
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    );
                                                  },
                                                ),
                                              ),
                                            ),
                                            SizedBox(height: 20),
                                            Text(
                                              "${findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length} ${"Available".tr}",
                                              style: TextStyle(
                                                fontSize: 18,
                                                fontFamily: fontFamilyBold,
                                                fontWeight: FontWeight.w700,
                                                color: textBlackColor,
                                              ),
                                            ),
                                            SizedBox(height: 10),
                                            ListView.separated(
                                              shrinkWrap: true,
                                              physics: NeverScrollableScrollPhysics(),
                                              itemBuilder: (context, index) {
                                                FindLoadDatum loads = findLorryController.loadData.findLoadData[findLorryController.selectVehicle];
                                                return Container(
                                                  padding: EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    borderRadius: BorderRadius.circular(12),
                                                    boxShadow: [
                                                      BoxShadow(
                                                        color: Colors.grey.withOpacity(0.7),
                                                        offset: Offset(0, 10),
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
                                                            '$basUrl${loads.loaddata[index].vehicleImg}',
                                                            height: 50,
                                                            width: 50,
                                                          ),
                                                          const SizedBox(width: 8),
                                                          Text(loads.loaddata[index].vehicleTitle),
                                                          const Spacer(),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: "$currency${loads.loaddata[index].amount}",
                                                                  style:
                                                                      TextStyle(
                                                                    fontSize: 18,
                                                                    color: textBlackColor,
                                                                    fontFamily: fontFamilyBold,
                                                                    fontWeight:FontWeight.w600,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: " /${loads.loaddata[index].amtType}",
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
                                                                    loads.loaddata[index].pickupState,
                                                                    style: TextStyle(
                                                                      color: textBlackColor,
                                                                      fontSize: 18,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontFamily: fontFamilyBold,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
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
                                                                    message: loads.loaddata[index].pickupPoint,
                                                                    child: SvgPicture.asset(
                                                                      "assets/image/ic_info_location.svg",
                                                                      height: 20,
                                                                      width: 20,
                                                                    ),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  SvgPicture
                                                                      .asset(
                                                                    "assets/image/ic_route_truck.svg",
                                                                    color: const Color(
                                                                        0xffD1D5DB),
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 2,
                                                                  ),
                                                                  Tooltip(
                                                                    triggerMode: TooltipTriggerMode.tap,
                                                                    message: loads.loaddata[index].dropPoint,
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
                                                                loads.loaddata[index].loadDistance,
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
                                                                    loads.loaddata[index].dropState,
                                                                    style: TextStyle(
                                                                      color: textBlackColor,
                                                                      fontSize: 18,
                                                                      fontWeight: FontWeight.w500,
                                                                      fontFamily: fontFamilyBold,
                                                                    ),
                                                                    overflow: TextOverflow.ellipsis,
                                                                  ),
                                                                  const SizedBox(
                                                                    height: 8,
                                                                  ),
                                                                  Container(
                                                                    padding: const EdgeInsets.symmetric(vertical: 5,horizontal: 8),
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
                                                          )
                                                        ],
                                                      ),
                                                      Divider(height: 30, color: Colors.grey.withOpacity(0.3)),
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
                                                                loads.loaddata[index].postDate.toString().split(" ").first.tr,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: textBlackColor,
                                                                  fontFamily: fontFamilyRegular,
                                                                  fontWeight:FontWeight.w900,
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
                                                                loads.loaddata[index].weight,
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
                                                                loads.loaddata[index].materialName,
                                                                style: TextStyle(
                                                                  fontSize: 14,
                                                                  color: textBlackColor,
                                                                  fontFamily: fontFamilyRegular,
                                                                  fontWeight: FontWeight.w900,
                                                                ),
                                                              ),
                                                            ],
                                                          )
                                                        ],
                                                      ),
                                                      SizedBox(height: 18),
                                                      Container(
                                                        decoration: BoxDecoration(
                                                          borderRadius: BorderRadius.circular(12),
                                                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                                        ),
                                                        child: ListTile(
                                                          onTap: () {
                                                            Get.to(TransProfile(uid: loads.loaddata[index].uid));
                                                          },
                                                          leading: CircleAvatar(
                                                            backgroundColor:Colors .transparent,
                                                            backgroundImage: NetworkImage("$basUrl${loads.loaddata[index].ownerImg}"),
                                                          ),
                                                          title: Text(
                                                            loads.loaddata[index].ownerName,
                                                            overflow: TextOverflow.ellipsis,
                                                            maxLines: 1,
                                                          ),
                                                          trailing: (loads.loaddata[index].isBid == 1 || loads.loaddata[index].isBid == 3)
                                                              ? findLorryController.isBidNowLoder[index] || findLorryController.isBidLoder[index]
                                                                ? Container(
                                                                    width: 100,
                                                                    child: Center(child: SpinKitThreeBounce(color: priMaryColor, size: 15.0)),
                                                                  )
                                                                : InkWell(
                                                                  onTap: () {
                                                                    if (findLorryController.isBidLoder[index] == false) {
                                                                    findLorryController.setIsBidLoder(index: index, value: true);
                                                                    ApiProvider().deleteBid(ownerId: uid,loadId: loads.loaddata[index].id).then((value) {
                                                                      var decode = value;
                                                                        if (decode["Result"] == "true") {
                                                                          debugPrint("========== setIsBidLoder index ========= $index");
                                                                          getDataFromApii(
                                                                            dropState: loads.loaddata[index].dropState,
                                                                            pickupState: loads.loaddata[index].pickupState,
                                                                          );
                                                                          showCommonToast(decode["ResponseMsg"]);
                                                                        }
                                                                    });
                                                                    }
                                                                  },
                                                                  child: Container(
                                                                    height: 40,
                                                                    width: 50,
                                                                    decoration:
                                                                      BoxDecoration(
                                                                        borderRadius:  BorderRadius.circular(12),
                                                                        gradient: const LinearGradient(colors: [
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
                                                              : findLorryController.isBidNowLoder[index] || findLorryController.isBidLoder[index]
                                                                ? Container(
                                                                    width: 100,
                                                                    child: Center(child: SpinKitThreeBounce(color: priMaryColor, size: 15.0)),
                                                                  )
                                                                : ElevatedButton(
                                                                  style: ElevatedButton.styleFrom(
                                                                    shape: RoundedRectangleBorder(
                                                                      borderRadius: BorderRadius.circular(12),
                                                                    ),
                                                                    backgroundColor: priMaryColor,
                                                                  ),
                                                                  onPressed: () {
                                                                    if (findLorryController.isBidLoder[index] == false) {
                                                                      findLorryController.setIsBidLoder(index: index, value: true);
                                                                      debugPrint("========== setIsBidLoder index ========= $index");
                                                                      ApiProvider().getLorryList(
                                                                        ownerId: homePageController.userData?.id ?? '',
                                                                        loadId: loads.loaddata[index].id)
                                                                          .then((value) {
                                                                          bidBottomsheetController.bidNowBottombar(
                                                                            lorrydata: LorryListModel.fromJson(value),
                                                                            loadId: loads.loaddata[index].id,
                                                                            ownerId: uid,
                                                                            tonns: loads.loaddata[index].weight,
                                                                            totalLoad: loads.loaddata[index].weight,
                                                                          ).then((value) {
                                                                            findLorryController.setIsBidLoder(index: index, value: true);
                                                                            findLorryController.setIsBidNowLoder(index: index, value: true);
                                                                            getDataFromApii(
                                                                              dropState: findLorryController.dropPoint,
                                                                              pickupState: findLorryController.picUpState,
                                                                            );
                                                                            debugPrint("========== setIsBidLoder index value ========= $index");
                                                                          },
                                                                        );
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
                                                                mainAxisSize:MainAxisSize.min,
                                                                children: [
                                                                  SvgPicture.asset(
                                                                    "assets/icons/ic_star_profile.svg",
                                                                    width: 16,
                                                                    height: 16,
                                                                    color:priMaryColor,
                                                                  ),
                                                                  const SizedBox(
                                                                    width: 8,
                                                                  ),
                                                                  Transform.translate(
                                                                    offset: const Offset(0, 1),
                                                                    child: Text(
                                                                      loads.loaddata[index].ownerRating,
                                                                      style: TextStyle(
                                                                        color: priMaryColor,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                ],
                                                              ),
                                                              loads.loaddata[index].isBid == 4
                                                                  ? Column(
                                                                      mainAxisSize:MainAxisSize.min,
                                                                      crossAxisAlignment:CrossAxisAlignment.start,
                                                                      children: [
                                                                        const SizedBox(height: 5),
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
                                                                  : loads.loaddata[index].isBid == 1
                                                                      ? Column(
                                                                          mainAxisSize: MainAxisSize.min,
                                                                          crossAxisAlignment: CrossAxisAlignment.start,
                                                                          children: [
                                                                            SizedBox(height: 5),
                                                                            RichText(
                                                                              text: TextSpan(
                                                                                children: [
                                                                                  TextSpan(
                                                                                    text: "$currency${loads.loaddata[index].bidAmount}",
                                                                                    style: TextStyle(
                                                                                      fontSize: 12,
                                                                                      color: textBlackColor,
                                                                                      fontFamily: fontFamilyRegular,
                                                                                    ),
                                                                                  ),
                                                                                  TextSpan(
                                                                                    text: "/${loads.loaddata[index].amtType}",
                                                                                    style: TextStyle(
                                                                                      fontSize: 10,
                                                                                      color: textGreyColor,
                                                                                      fontFamily: fontFamilyRegular,
                                                                                    ),
                                                                                  ),
                                                                                ]
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
                                              itemCount: findLorryController.loadData.findLoadData[findLorryController.selectVehicle].loaddata.length,
                                            )
                                          ],
                                        ),
                                      )
                                : const SizedBox(),
                          ],
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.all(15.0),
                        child: Column(
                          children: [
                            const SizedBox(
                              height: 12,
                            ),
                            Container(
                              width: MediaQuery.of(context).size.width,
                              padding: const EdgeInsets.all(15),
                              decoration: BoxDecoration(
                                color: Colors.white,
                                borderRadius: BorderRadius.circular(16),
                                boxShadow: const [
                                  BoxShadow(
                                    color: Colors.grey,
                                    blurRadius: 5,
                                    blurStyle: BlurStyle.outer,
                                  )
                                ],
                              ),
                              child: Column(
                                children: [
                                  const SizedBox(
                                    height: 10,
                                  ),
                                  Container(
                                    width: Get.width,
                                    padding: const EdgeInsets.all(10),
                                    decoration: BoxDecoration(
                                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Column(
                                      children: [
                                        Row(
                                          mainAxisAlignment: MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/ic_pickup_map.svg",
                                              width: 24,
                                              height: 24,
                                            ),
                                            Expanded(
                                              child: pickUpPoint(),
                                            ),
                                            findLorryController.isPickUp
                                                ? SvgPicture.asset(
                                                    "assets/icons/exclamation-circle.svg",
                                                    width: 24,
                                                    height: 24,
                                                    color: Colors.red,
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                        Divider(color: Colors.grey.withOpacity(0.3),height: 20),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/ic_pickup_map.svg",
                                              width: 24,
                                              height: 24,
                                            ),
                                            Expanded(
                                              child: dropPoint(),
                                            ),
                                            findLorryController.isDropPoint
                                                ? SvgPicture.asset(
                                                    "assets/icons/exclamation-circle.svg",
                                                    width: 24,
                                                    height: 24,
                                                    color: Colors.red,
                                                  )
                                                : const SizedBox(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  const SizedBox(height: 20),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      findLorryController.isLoading
                                        ? SpinKitThreeBounce(color: priMaryColor, size: 25.0)
                                        : Expanded(
                                          child: commonButton(
                                        title: "Search".tr,
                                        onTapp: () {
                                          if (dropDownController.text.isNotEmpty && pickUpController.text.isNotEmpty) {
                                            getDataFromApii(
                                              dropState: findLorryController.dropPoint,
                                              pickupState: findLorryController.picUpState,
                                            );
                                          }
                                        },
                                      )),
                                    ],
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          ],
                        ),
                      )
                    ],
                  ),
                ),
        ),
      );
    });
  }

  rcVerified(String id) {
    switch (id) {
      case "1":
        return "assets/icons/badge-check.svg";
      case "2":
        return "assets/icons/ic_unverified.svg";
    }
  }

  TextEditingController pickUpController = TextEditingController();
  TextEditingController dropDownController = TextEditingController();

  dropPoint() {
    return GooglePlaceAutoCompleteTextField(
      textStyle: TextStyle(
        fontSize: 17,
        fontFamily: fontFamilyRegular,
        color: textBlackColor,
      ),
      boxDecoration: BoxDecoration(
        border: Border.all(color: Colors.transparent),
      ),
      textEditingController: dropDownController,
      googleAPIKey: gkey,
      inputDecoration: InputDecoration(
        hintText: "Drop Point".tr,
        hintStyle: TextStyle(
          fontSize: 17,
          fontFamily: fontFamilyRegular,
          color: textGreyColor,
        ),
        border: InputBorder.none,
        isDense: true,
        contentPadding: EdgeInsets.zero,
      ),
      debounceTime: 400,
      getPlaceDetailWithLatLng: (Prediction prediction) {
        getAddressFromLatLong(prediction.lat, prediction.lng).then((value) {
          setState(() {
            findLorryController.dropPoint = value;
          });
        });
        setState(() {
          findLorryController.dropUpLat = prediction.lat;
          findLorryController.dropUpLng = prediction.lng;
        });
        print("+++++++++++++++++++ placeDetails" + prediction.lat.toString());
        print("+++++++++++++++++++ placeDetails" + prediction.lng.toString());
      },
      itemClick: (Prediction prediction) {
        findLorryController.setIsDropPoint(false);
        dropDownController.text = prediction.description ?? "";
        dropDownController.selection = TextSelection.fromPosition(
          TextPosition(offset: prediction.description?.length ?? 0),
        );
      },
      itemBuilder: (context, index, Prediction prediction) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(
                width: 7,
              ),
              Expanded(child: Text(prediction.description ?? ""))
            ],
          ),
        );
      },
      isCrossBtnShown: false,
    );
  }

  pickUpPoint() {
    return GooglePlaceAutoCompleteTextField(
      textStyle: TextStyle(
          fontSize: 17, fontFamily: fontFamilyRegular, color: textBlackColor),
      boxDecoration: BoxDecoration(border: Border.all(color: Colors.transparent)),
      textEditingController: pickUpController,
      googleAPIKey: gkey,
      inputDecoration: InputDecoration(
          hintText: "Pickup Point".tr,
          hintStyle: TextStyle(
              fontSize: 17,
              fontFamily: fontFamilyRegular,
              color: textGreyColor),
          border: InputBorder.none,
          isDense: true,
          contentPadding: const EdgeInsets.all(0)),
      debounceTime: 400,
      getPlaceDetailWithLatLng: (Prediction prediction) {
        getAddressFromLatLong(prediction.lat, prediction.lng).then((value) {
          setState(() {
            findLorryController.picUpState = value;
          });
        });
        setState(() {
          findLorryController.picUpLat = prediction.lat;
          findLorryController.picUpLng = prediction.lng;
        });
      },

      itemClick: (Prediction prediction) {
        findLorryController.setIsPickUp(false);
        pickUpController.text = prediction.description ?? "";
        pickUpController.selection = TextSelection.fromPosition(
            TextPosition(offset: prediction.description?.length ?? 0));
      },

      itemBuilder: (context, index, Prediction prediction) {
        return Container(
          padding: const EdgeInsets.all(10),
          child: Row(
            children: [
              const Icon(Icons.location_on),
              const SizedBox(
                width: 7,
              ),
              Expanded(child: Text(prediction.description ?? ""))
            ],
          ),
        );
      },
      isCrossBtnShown: false,
    );
  }
}

Future<String> getAddressFromLatLong(String? lat, String? long) async {
  SharedPreferences prefs = await SharedPreferences.getInstance();
  Address? administrativeArea1 =
      await FlutterAddressFromLatLng().getAdministrativeAddress1(
    latitude: double.parse(lat!),
    longitude: double.parse(long!),
    googleApiKey: prefs.getString("gkey") ?? googleMapkey,
  );
  return administrativeArea1!.addressComponents[0].longName!;
}
