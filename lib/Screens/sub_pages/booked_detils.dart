// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:truckbuddy/Screens/sub_pages/trans_profile.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:url_launcher/url_launcher.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/bookedlorrydetiels_controller.dart';
import '../../widgets/widgets.dart';

class BookedDetails extends StatefulWidget {
  final String uid;
  final String loadId;

  const BookedDetails({super.key, required this.uid, required this.loadId});

  @override
  State<BookedDetails> createState() => _BookedDetailsState();
}

class _BookedDetailsState extends State<BookedDetails> {
  String currency = "\$";
  bool isloading = false;

  bool bidLoder = false;

  BookedHistoryController bookedHistoryController = Get.put(BookedHistoryController());
  @override
  void initState() {
    super.initState();
    bidLoder = false;
    fetchDataFromApi();
  }

  @override
  void dispose() {
    super.dispose();
    bookedHistoryController.isLoading = true;
  }

  fetchDataFromApi() {
    ApiProvider()
        .bookDetails(uid: widget.uid, loadId: widget.loadId)
        .then((value) async {
      final SharedPreferences prefs = await SharedPreferences.getInstance();
      currency = prefs.getString("currencyIcon")!;
      bookedHistoryController.setBookedData(value);
      bookedHistoryController.setIsLoading(false);
    });
  }

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          const Duration(seconds: 1),
          () {
            fetchDataFromApi();
          },
        );
      },
      child: GetBuilder<BookedHistoryController>(
        builder: (bookedHistoryController) {
          return Scaffold(
            backgroundColor: Colors.white,
            bottomNavigationBar: bookedHistoryController.isLoading
                ? const SizedBox()
                : (bookedHistoryController.historyData.loadDetails.flowId == "4" || bookedHistoryController.historyData.loadDetails.flowId == "7")
                    ? Padding(
                        padding: const EdgeInsets.all(10),
                        child: Row(
                          children: [
                            Expanded(
                              child: commonButton(
                                title: bookedHistoryController.historyData.loadDetails.flowId == "7"
                                    ? "Drop".tr
                                    : "PickUp".tr,
                                onTapp: () {
                                  ApiProvider()
                                      .pickUpAndDropApi(
                                          ownerId: widget.uid,
                                          loadId: widget.loadId,
                                          status: bookedHistoryController.historyData.loadDetails.flowId == "7" ? "2" : "1",
                                          loadTyp: "FIND_LORRY")
                                      .then((value) {
                                    var decode = value;
                                    if (decode["Result"] == "true") {
                                      setState(() {
                                        isloading = false;
                                      });
                                      Get.back();
                                      if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                        showCommonToast(decode["ResponseMsg"]);
                                      }
                                    } else {
                                      setState(() {
                                        isloading = false;
                                      });
                                      if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                        showCommonToast(decode["ResponseMsg"]);
                                      }
                                    }
                                  });
                                },
                              ),
                            ),
                          ],
                        ),
                      )
                    : (bookedHistoryController.historyData.loadDetails.flowId == "8" && bookedHistoryController.historyData.loadDetails.isRate == "0")
                        ? Container(
                            color: Colors.white,
                            padding: const EdgeInsets.only(top: 5, right: 15, bottom: 10, left: 15),
                            child: Row(
                              children: [
                                Expanded(
                                  child: commonButton(
                                    title: "${"Rate to".tr} ${bookedHistoryController.historyData.loadDetails.loaderName}",
                                    onTapp: () {
                                      TextEditingController feedback = TextEditingController();
                                      Get.bottomSheet(
                                        StatefulBuilder(
                                          builder: (context, setState12) {
                                            return Container(
                                              height: Get.height * 0.47,
                                              padding: const EdgeInsets.all(15),
                                              decoration: const BoxDecoration(
                                                borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                                color: Colors.white,
                                              ),
                                              child: SingleChildScrollView(
                                                child: Column(
                                                  children: [
                                                    CircleAvatar(
                                                      radius: 25,
                                                      backgroundColor: Colors.transparent,
                                                      backgroundImage: NetworkImage(
                                                        "$basUrl${bookedHistoryController.historyData.loadDetails.loaderImg}",
                                                      ),
                                                    ),
                                                    const SizedBox(height: 8),
                                                    Text(
                                                      bookedHistoryController.historyData.loadDetails.loaderName,
                                                      style: TextStyle(
                                                        color: textBlackColor,
                                                        fontSize: 20,
                                                        fontFamily: fontFamilyBold,
                                                      ),
                                                    ),
                                                    Text(
                                                      bookedHistoryController.historyData.loadDetails.lorryNumber,
                                                      style: TextStyle(
                                                        color: textBlackColor,
                                                        fontSize: 16,
                                                        fontFamily: fontFamilyRegular,
                                                      ),
                                                    ),
                                                    const SizedBox(height: 15),
                                                    RatingBar.builder(
                                                      initialRating: 0,
                                                      minRating: 0,
                                                      itemSize: 35,
                                                      direction: Axis.horizontal,
                                                      allowHalfRating: true,
                                                      itemCount: 5,
                                                      glow: false,
                                                      unratedColor: priMaryColor.withOpacity(0.3),
                                                      itemPadding: EdgeInsets.symmetric(horizontal: 4.0),
                                                      itemBuilder: (context, _) => Icon(
                                                        Icons.star,
                                                        color: priMaryColor,
                                                      ),
                                                      onRatingUpdate: (rating) {
                                                        bookedHistoryController.setRating(rating);
                                                      },
                                                    ),
                                                    const SizedBox(height: 10),
                                                    Container(
                                                      decoration: BoxDecoration(
                                                        borderRadius: BorderRadius.circular(12),
                                                        border: Border.all(
                                                          color: Colors.grey.withOpacity(0.3),
                                                        ),
                                                      ),
                                                      height: 100,
                                                      child: TextField(
                                                        controller: feedback,
                                                        decoration: InputDecoration(
                                                          contentPadding: EdgeInsets.symmetric(horizontal: 10,vertical: 10),
                                                          isDense: true,
                                                          border: InputBorder.none,
                                                          hintText: "Enter your Feedback".tr,
                                                          hintStyle: TextStyle(
                                                            fontSize: 16,
                                                            color: textGreyColor,
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                    const SizedBox(height: 20),
                                                    Row(
                                                      children: [
                                                        Expanded(
                                                          child: commonButton(
                                                            title: "${"Rate to".tr} ${bookedHistoryController.historyData.loadDetails.loaderName}",
                                                            onTapp: () {
                                                              if (feedback.text.isNotEmpty && bookedHistoryController.rating != 0.0) {
                                                                ApiProvider().rating(
                                                                  loadId: widget.loadId,
                                                                  uid: widget.uid,
                                                                  rateText: feedback.text,
                                                                  totalRate: "${bookedHistoryController.rating}",
                                                                ).then((value) async{
                                                                  var decode = jsonDecode(value);
                                                                  if (decode["Result"] == "true") {
                                                                    showCommonToast(decode["ResponseMsg"]);
                                                                    Get.back();
                                                                    Get.back();
                                                                  } else {
                                                                    showCommonToast(decode["ResponseMsg"]);
                                                                    Get.back();
                                                                  }
                                                                });
                                                              }
                                                            },
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(height: 20),
                                                  ],
                                                ),
                                              ),
                                            );
                                          },
                                        ),
                                      );
                                    },
                                  ),
                                ),
                              ],
                            ),
                          )
                        : null,
            appBar: AppBar(
              centerTitle: true,
              elevation: 0,
              leading: InkWell(
                onTap: () async {
                  Get.back();
                },
                child: SizedBox(
                  height: 20,
                  width: 20,
                  child: Center(
                    child: SvgPicture.asset(
                      "assets/icons/backicon.svg",
                      height: 22,
                      width: 22,
                      color: textBlackColor,
                    ),
                  ),
                ),
              ),
              backgroundColor: Colors.white,
              title: Text(
                "${"Loads".tr} #${widget.loadId}".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: fontFamilyBold,
                  fontWeight: FontWeight.w500,
                  color: textBlackColor,
                ),
              ),
            ),
            body: bidLoder == false
                ? bookedHistoryController.isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : Stack(
                        children: [
                          SingleChildScrollView(
                            physics: const AlwaysScrollableScrollPhysics(),
                            child: Padding(
                              padding: const EdgeInsets.all(15.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Row(
                                    children: [
                                      Expanded(
                                        child: commonDetils(
                                          vehicleImg: bookedHistoryController.historyData.loadDetails.vehicleImg,
                                          vehicleTitle: bookedHistoryController.historyData.loadDetails.vehicleTitle,
                                          currency: currency,
                                          amount: bookedHistoryController.historyData.loadDetails.amount,
                                          amtType: bookedHistoryController.historyData.loadDetails.amtType,
                                          totalAmt: bookedHistoryController.historyData.loadDetails.totalAmt,
                                          pickupState: bookedHistoryController.historyData.loadDetails.pickupState,
                                          pickupPoint: bookedHistoryController.historyData.loadDetails.pickupPoint,
                                          dropState: bookedHistoryController.historyData.loadDetails.dropState,
                                          dropPoint: bookedHistoryController.historyData.loadDetails.dropPoint,
                                          postDate: bookedHistoryController.historyData.loadDetails.postDate.toString(),
                                          weight: bookedHistoryController.historyData.loadDetails.weight,
                                          materialName: bookedHistoryController.historyData.loadDetails.materialName,
                                        ),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 30),
                                  Text(
                                    "Load Owner Response".tr,
                                    style: TextStyle(
                                      color: textBlackColor,
                                      fontSize: 16,
                                      fontFamily: fontFamilyBold,
                                      fontWeight: FontWeight.w500,
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                  Stack(
                                    clipBehavior: Clip.none,
                                    alignment: Alignment.topRight,
                                    children: [
                                      Row(
                                        children: [
                                          Expanded(
                                            child: Container(
                                              padding: const EdgeInsets.all(15),
                                              decoration: BoxDecoration(
                                                borderRadius: BorderRadius.circular(12),
                                                border: Border.all(
                                                  color: Colors.grey.withOpacity(0.3),
                                                ),
                                              ),
                                              child: Column(
                                                mainAxisAlignment: MainAxisAlignment.center,
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  ListTile(
                                                    onTap: () {
                                                      Get.to(TransProfile(uid: bookedHistoryController.historyData.loadDetails.uid));
                                                    },
                                                    contentPadding: EdgeInsets.zero,
                                                    dense: true,
                                                    trailing: Row(
                                                      mainAxisSize: MainAxisSize.min,
                                                      children: [
                                                        SvgPicture.asset(
                                                          "assets/icons/ic_star_profile.svg",
                                                          width: 16,
                                                          height: 16,
                                                          color: priMaryColor,
                                                        ),
                                                        const SizedBox(width: 5),
                                                        Transform.translate(
                                                          offset: const Offset(0, 1),
                                                          child: Text(
                                                            bookedHistoryController.historyData.loadDetails.loaderRate,
                                                            style: TextStyle(
                                                              color: priMaryColor,
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    ),
                                                    subtitle: Transform.translate(
                                                      offset: Offset(-8, 0),
                                                      child: Column(
                                                        mainAxisSize: MainAxisSize.min,
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: "$currency${bookedHistoryController.historyData.loadDetails.offerPrice.isNotEmpty ? bookedHistoryController.historyData.loadDetails.offerPrice : bookedHistoryController.historyData.loadDetails.amount}",
                                                                  style: TextStyle(
                                                                    color: textBlackColor,
                                                                    fontSize: 13,
                                                                    fontFamily: fontFamilyBold,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: " /${bookedHistoryController.historyData.loadDetails.offerType.isNotEmpty ? bookedHistoryController.historyData.loadDetails.offerType : bookedHistoryController.historyData.loadDetails.amtType}",
                                                                  style: TextStyle(
                                                                    color: textGreyColor,
                                                                    fontSize: 10,
                                                                    fontFamily: fontFamilyRegular,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                          SizedBox(height: 2),
                                                          RichText(
                                                            text: TextSpan(
                                                              children: [
                                                                TextSpan(
                                                                  text: "$currency${bookedHistoryController.historyData.loadDetails.offerTotal.isNotEmpty ? bookedHistoryController.historyData.loadDetails.offerTotal : bookedHistoryController.historyData.loadDetails.totalAmt}",
                                                                  style: TextStyle(
                                                                    color: textBlackColor,
                                                                    fontSize: 13,
                                                                    fontFamily: fontFamilyBold,
                                                                  ),
                                                                ),
                                                                TextSpan(
                                                                  text: " /${"Payable Amount".tr}",
                                                                  style: TextStyle(
                                                                    color: textGreyColor,
                                                                    fontSize: 10,
                                                                    fontFamily: fontFamilyRegular,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                    ),
                                                    title: Transform.translate(
                                                      offset: Offset(-8, 0),
                                                      child: Text(
                                                        bookedHistoryController.historyData.loadDetails.loaderName,
                                                        style: TextStyle(
                                                          fontSize: 18,
                                                          fontWeight: FontWeight.w500,
                                                          fontFamily: fontFamilyBold,
                                                          color: textBlackColor,
                                                        ),
                                                      ),
                                                    ),
                                                    leading: CircleAvatar(
                                                      backgroundColor: Colors.transparent,
                                                      radius: 25,
                                                      backgroundImage: NetworkImage("$basUrl${bookedHistoryController.historyData.loadDetails.loaderImg}"),
                                                    ),
                                                  ),
                                                  if (bookedHistoryController.historyData.loadDetails.flowId == "0" || bookedHistoryController.historyData.loadDetails.flowId == "6")
                                                    Column(
                                                      children: [
                                                        const SizedBox(height: 10),
                                                        Row(
                                                          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                                                          children: [
                                                            OutlinedButton(
                                                              style: OutlinedButton.styleFrom(
                                                                elevation: 0,
                                                                fixedSize: Size.fromHeight(40),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                side: BorderSide(
                                                                  color: Color(0xffFF9F9F),
                                                                ),
                                                              ),
                                                              onPressed: () {
                                                                ApiProvider().rejectLoad(
                                                                  ownerId: widget.uid,
                                                                  loadId: widget.loadId,
                                                                  commentReject: "",
                                                                ).then((value) {
                                                                  var decode = value;
                                                                  if (decode["Result"] == "true") {
                                                                    Get.back();
                                                                    showCommonToast(decode["ResponseMsg"]);
                                                                  } else {
                                                                    showCommonToast(decode["ResponseMsg"]);
                                                                    Get.back();
                                                                  }
                                                                });
                                                              },
                                                              child: Text(
                                                                "Reject".tr,
                                                                style: TextStyle(
                                                                  color: Color(0xffFF9F9F),
                                                                  fontSize: 15,
                                                                  fontFamily:  "urbani_extrabold",
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                elevation: 0,
                                                                fixedSize: Size.fromHeight(40),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                backgroundColor: priMaryColor,
                                                              ),
                                                              onPressed: () {
                                                              
                                                              },
                                                              child: Text(
                                                                "Accept".tr,
                                                                style: TextStyle(
                                                                  color: whiteColor,
                                                                  fontSize: 15,
                                                                  fontFamily: "urbani_extrabold",
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ),
                                                            ElevatedButton(
                                                              style: ElevatedButton.styleFrom(
                                                                elevation: 0,
                                                                fixedSize: Size.fromHeight(40),
                                                                shape: RoundedRectangleBorder(
                                                                  borderRadius: BorderRadius.circular(12),
                                                                ),
                                                                backgroundColor: Color(0xffFF69B6),
                                                              ),
                                                              onPressed: () {
                                                                TextEditingController description = TextEditingController();

                                                                Get.bottomSheet(
                                                                  isScrollControlled: true,
                                                                  GetBuilder<BookedHistoryController>(
                                                                    builder: (bookedHistoryController) {
                                                                      return Container(
                                                                        padding: EdgeInsets.all(15),
                                                                        decoration: BoxDecoration(
                                                                          color: Colors.white,
                                                                          borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                                                                        ),
                                                                        child: SingleChildScrollView(
                                                                          child: Column(
                                                                            crossAxisAlignment: CrossAxisAlignment.start,
                                                                            children: [
                                                                              Text(
                                                                                "Bid Now".tr,
                                                                                style: TextStyle(
                                                                                  fontSize: 20,
                                                                                  color: textBlackColor,
                                                                                  fontFamily: fontFamilyBold,
                                                                                ),
                                                                              ),
                                                                              Divider(
                                                                                height: 30,
                                                                                color: Colors.grey.withOpacity(0.3),
                                                                              ),
                                                                              Text(
                                                                                "Enter your Price".tr,
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  color: textBlackColor,
                                                                                  fontFamily: fontFamilyBold,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 10),
                                                                              TextField(
                                                                                keyboardType: TextInputType.number,
                                                                                controller: bookedHistoryController.amount,
                                                                                onChanged: (value) {
                                                                                  if (value.isEmpty) {
                                                                                    bookedHistoryController.setIsAmount(false);
                                                                                  } else {
                                                                                    bookedHistoryController.setIsAmount(bookedHistoryController.amount.text.isEmpty);
                                                                                  }
                                                                                },
                                                                                style: TextStyle(
                                                                                  color: textBlackColor,
                                                                                  fontSize: 14,
                                                                                  fontFamily: fontFamilyRegular,
                                                                                ),
                                                                                decoration: InputDecoration(
                                                                                  suffixIcon: Row(
                                                                                    mainAxisSize: MainAxisSize.min,
                                                                                    children: [
                                                                                      bookedHistoryController.isAmount
                                                                                          ? SizedBox(
                                                                                              width: 20,
                                                                                              height: 20,
                                                                                              child: Center(
                                                                                                child: SvgPicture.asset(
                                                                                                  "assets/icons/exclamation-circle.svg",
                                                                                                  color: Colors.red,
                                                                                                ),
                                                                                              ),
                                                                                            )
                                                                                          : const SizedBox(),
                                                                                      bookedHistoryController.isAmount ? const SizedBox(width: 8) : const SizedBox(),
                                                                                      Text(bookedHistoryController.isPriceFix ? "Per Tonnes".tr : "Fix".tr),
                                                                                      Switch(
                                                                                        activeColor: priMaryColor,
                                                                                        value: bookedHistoryController.isPriceFix,
                                                                                        onChanged: (value) {
                                                                                          bookedHistoryController.setIsPriceFix(value);
                                                                                        },
                                                                                      ),
                                                                                    ],
                                                                                  ),
                                                                                  hintText: "Amount".tr,
                                                                                  hintStyle: TextStyle(color: textGreyColor, fontSize: 13, fontFamily: fontFamilyRegular),
                                                                                  prefixIcon: SizedBox(width: 20, height: 20, child: Center(child: SvgPicture.asset("assets/icons/sack-dollar.svg"))),
                                                                                  border: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                                                                                  disabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                                                                                  enabledBorder: OutlineInputBorder(borderRadius: BorderRadius.circular(12), borderSide: BorderSide(color: Colors.grey.withOpacity(0.3))),
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 15),
                                                                              Text(
                                                                                "Description".tr,
                                                                                style: TextStyle(
                                                                                  fontSize: 16,
                                                                                  color: textBlackColor,
                                                                                  fontFamily: fontFamilyBold,
                                                                                ),
                                                                              ),
                                                                              const SizedBox(height: 10),
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: Container(
                                                                                      height: 120,
                                                                                      decoration: BoxDecoration(borderRadius: const BorderRadius.all(Radius.circular(12)), border: Border.all(color: Colors.grey.withOpacity(0.3))),
                                                                                      child: TextField(
                                                                                        controller: description,
                                                                                        decoration: const InputDecoration(contentPadding: EdgeInsets.all(8), isDense: true, border: InputBorder.none),
                                                                                        style: TextStyle(color: textBlackColor, fontSize: 16, fontFamily: fontFamilyRegular),
                                                                                      ),
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              ),
                                                                              const SizedBox(height: 20),
                                                                              Row(
                                                                                children: [
                                                                                  Expanded(
                                                                                    child: commonButton(
                                                                                      title: "Send offer".tr,
                                                                                      onTapp: () async {
                                                                                        if (bookedHistoryController.amount.text.isNotEmpty) {
                                                                                          setState(() {
                                                                                            bidLoder = true;
                                                                                          });
                                                                                          Get.back();
                                                                                          await ApiProvider().offerLoad(
                                                                                            ownerId: widget.uid,
                                                                                            loadId: widget.loadId,
                                                                                            offertotal: bookedHistoryController.isPriceFix
                                                                                            ? (int.parse(bookedHistoryController.amount.text.toString()) * int.parse(bookedHistoryController.historyData.loadDetails.weight)).toString()
                                                                                            : bookedHistoryController.amount.text,
                                                                                            offertype: bookedHistoryController.isPriceFix ? "Tonne" : "Fixed",
                                                                                            offerDes: description.text,
                                                                                            offerPrice: bookedHistoryController.amount.text).then((value) {
                                                                                           var decode = value;
                                                                                            if (decode["Result"] == "true") {
                                                                                              Get.back();
                                                                                              setState(() {
                                                                                                bidLoder = false;
                                                                                              });
                                                                                              showCommonToast(decode["ResponseMsg"]);
                                                                                              bookedHistoryController.amount.text = "";
                                                                                            } else {
                                                                                              showCommonToast(decode["ResponseMsg"]);
                                                                                              Get.back();
                                                                                              setState(() {
                                                                                                bidLoder = false;
                                                                                              });
                                                                                            }
                                                                                          });
                                                                                        }
                                                                                      },
                                                                                    ),
                                                                                  ),
                                                                                ],
                                                                              )
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      );
                                                                    },
                                                                  ),
                                                                );
                                                              },
                                                              child: Text(
                                                                "Offer".tr,
                                                                style: TextStyle(
                                                                  color: whiteColor,
                                                                  fontSize: 15,
                                                                  fontFamily: "urbani_extrabold",
                                                                  fontWeight: FontWeight.w700,
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        )
                                                      ],
                                                    )
                                                  else if (bookedHistoryController.historyData.loadDetails.flowId == "3")
                                                    Column(
                                                      children: [
                                                        const SizedBox(height: 10),
                                                        Text(
                                                          "Waiting for offer Response".tr,
                                                          style: TextStyle(
                                                            color: priMaryColor,
                                                            fontSize: 14,
                                                            fontFamily: fontFamilyRegular,
                                                            fontWeight: FontWeight.w700,
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  else
                                                    const SizedBox(height: 0),
                                                ],
                                              ),
                                            ),
                                          )
                                        ],
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  (bookedHistoryController.historyData.loadDetails.flowId == "4" || bookedHistoryController.historyData.loadDetails.flowId == "7")
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Contact Details".tr,
                                              style: TextStyle(
                                                color: textBlackColor,
                                                fontSize: 16,
                                                fontFamily: fontFamilyBold,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(15),
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(
                                                        color: Colors.grey.withOpacity(0.3),
                                                      ),
                                                    ),
                                                    child: Column(
                                                      crossAxisAlignment: CrossAxisAlignment.start,
                                                      children: [
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "Pickup".tr,
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: textGreyColor,
                                                                    fontFamily: fontFamilyRegular,
                                                                    fontWeight: FontWeight.w200,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 2),
                                                                Text(
                                                                  bookedHistoryController.historyData.loadDetails.pickName,
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: fontFamilyRegular,
                                                                    color: textBlackColor,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                                SizedBox(height: 2),
                                                                Text(
                                                                  bookedHistoryController.historyData.loadDetails.pickMobile,
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontFamily: fontFamilyRegular,
                                                                    color: textGreyColor,
                                                                    fontWeight: FontWeight.w200,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                makingPhoneCall(phoneNumber: bookedHistoryController.historyData.loadDetails.pickMobile);
                                                              },
                                                              child:
                                                                  CircleAvatar(
                                                                radius: 15,
                                                                backgroundColor: priMaryColor,
                                                                child: Center(
                                                                  child: SvgPicture.asset(
                                                                    "assets/icons/phone-call.svg",
                                                                    height: 20,
                                                                    width: 20,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 10),
                                                        Row(
                                                          crossAxisAlignment: CrossAxisAlignment.center,
                                                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                                          children: [
                                                            Column(
                                                              crossAxisAlignment: CrossAxisAlignment.start,
                                                              children: [
                                                                Text(
                                                                  "Drop".tr,
                                                                  style: TextStyle(
                                                                    fontSize: 12,
                                                                    color: textGreyColor,
                                                                    fontFamily: fontFamilyRegular,
                                                                    fontWeight: FontWeight.w200,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 2),
                                                                Text(
                                                                  bookedHistoryController.historyData.loadDetails.dropName,
                                                                  style: TextStyle(
                                                                    fontSize: 14,
                                                                    fontFamily: fontFamilyRegular,
                                                                    color: textBlackColor,
                                                                    fontWeight: FontWeight.w700,
                                                                  ),
                                                                ),
                                                                const SizedBox(height: 2),
                                                                Text(
                                                                  bookedHistoryController.historyData.loadDetails.dropMobile,
                                                                  style: TextStyle(
                                                                    fontSize: 16,
                                                                    fontFamily: fontFamilyRegular,
                                                                    color: textGreyColor,
                                                                    fontWeight: FontWeight.w200,
                                                                  ),
                                                                ),
                                                              ],
                                                            ),
                                                            InkWell(
                                                              onTap: () {
                                                                makingPhoneCall(phoneNumber: bookedHistoryController.historyData.loadDetails.dropMobile);
                                                              },
                                                              child: CircleAvatar(
                                                                radius: 15,
                                                                backgroundColor: priMaryColor,
                                                                child: Center(
                                                                  child: SvgPicture.asset(
                                                                    "assets/icons/phone-call.svg",
                                                                    height: 20,
                                                                    width: 20,
                                                                    color: Colors.white,
                                                                  ),
                                                                ),
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
                                            const SizedBox(height: 20),
                                          ],
                                        )
                                      : const SizedBox(),
                                  Row(
                                    children: [
                                      Expanded(
                                        child: Container(
                                          height: 80,
                                          padding: const EdgeInsets.all(15),
                                          decoration: BoxDecoration(
                                            borderRadius: BorderRadius.circular(12),
                                            border: Border.all(
                                              color:  Colors.grey.withOpacity(0.3),
                                            ),
                                          ),
                                          child: ListTile(
                                            contentPadding: EdgeInsets.zero,
                                            dense: true,
                                            leading: SvgPicture.asset("assets/icons/security.svg"),
                                            title: Transform.translate(
                                              offset: const Offset(0, -2),
                                              child: Text(
                                                "Cancellation Policy".tr,
                                                style: TextStyle(
                                                  color: textBlackColor,
                                                  fontSize: 16,
                                                  fontFamily: fontFamilyBold,
                                                  fontWeight: FontWeight.w500,
                                                ),
                                              ),
                                            ),
                                            subtitle: Text(
                                              "You required to contact the lorry owner for further communication".tr,
                                              style: TextStyle(
                                                color: textGreyColor,
                                                fontSize: 12,
                                              ),
                                            ),
                                            trailing: SizedBox(
                                              height: 20,
                                              width: 20,
                                              child: Center(
                                                child: SvgPicture.asset(
                                                  "assets/icons/arrow-right.svg",
                                                  color: textBlackColor,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      )
                                    ],
                                  ),
                                  const SizedBox(height: 20),
                                  (bookedHistoryController.historyData.loadDetails.flowId == "4" || bookedHistoryController.historyData.loadDetails.flowId == "7" || bookedHistoryController.historyData.loadDetails.flowId == "8")
                                      ? Column(
                                          crossAxisAlignment: CrossAxisAlignment.start,
                                          children: [
                                            Text(
                                              "Payment Information".tr,
                                              style: TextStyle(
                                                color: textBlackColor,
                                                fontSize: 16,
                                                fontFamily: fontFamilyBold,
                                                fontWeight: FontWeight.w500,
                                              ),
                                            ),
                                            const SizedBox(height: 10),
                                            Row(
                                              children: [
                                                Expanded(
                                                  child: Container(
                                                    padding: EdgeInsets.all(15),
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
                                                            Text(
                                                              "Payment Gateway".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                color: textGreyColor,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              bookedHistoryController.historyData.loadDetails.pMethodName,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyBold,
                                                                color: textBlackColor,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 15),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Transaction ID".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                color: textGreyColor,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              "${bookedHistoryController.historyData.loadDetails.orderTransactionId}",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyBold,
                                                                color: textBlackColor,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        const SizedBox(height: 15),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Sub Total".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                color: textGreyColor,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            const Spacer(),
                                                            Text(
                                                              "$currency${bookedHistoryController.historyData.loadDetails.totalAmt}",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyBold,
                                                                color: textBlackColor,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                        bookedHistoryController.historyData.loadDetails.walAmt.compareTo("0") == 0
                                                            ? const SizedBox()
                                                            : Column(
                                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                                children: [
                                                                  const SizedBox(height: 15),
                                                                  Row(
                                                                    children: [
                                                                      Text(
                                                                        "Wallet".tr,
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          fontFamily: fontFamilyRegular,
                                                                          color: textGreyColor,
                                                                        ),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                      const Spacer(),
                                                                      Text(
                                                                        "$currency${bookedHistoryController.historyData.loadDetails.walAmt}",
                                                                        style: TextStyle(
                                                                          fontSize: 14,
                                                                          fontFamily: fontFamilyRegular,
                                                                          color: Colors.green,
                                                                          fontWeight: FontWeight.w500,
                                                                        ),
                                                                        maxLines: 1,
                                                                        overflow: TextOverflow.ellipsis,
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ],
                                                              ),
                                                        Divider(height: 30,color: Colors.grey.withOpacity(0.3)),
                                                        Row(
                                                          children: [
                                                            Text(
                                                              "Total Payment".tr,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                color: textGreyColor,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                            Spacer(),
                                                            Text(
                                                              "$currency${bookedHistoryController.historyData.loadDetails.payAmt}",
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyBold,
                                                                color: textBlackColor,
                                                                fontWeight: FontWeight.w500,
                                                              ),
                                                              maxLines: 1,
                                                              overflow: TextOverflow.ellipsis,
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ],
                                        )
                                      : SizedBox(),
                                ],
                              ),
                            ),
                          ),
                          isloading
                              ? const Center(child: CircularProgressIndicator())
                              : const SizedBox(),
                        ],
                      )
                : Center(child: CircularProgressIndicator()),
          );
        },
      ),
    );
  }
}
//flow id =1 and is_accept = 1     accept and pay button

// flow_id = 0
//
// accept  = status =1 , load_id,uid
//
// flow_id = 0 waiting for partner decision
// flow_id = 1  show accept & pay ,reject , offer
// flow_id = 2  order cancellled
// flow_id = 3 show accpet & pay , reject ,offer
// flow_id = 4 acepted
// flow_id = 5 cancelled
// flow_id = 6 offer send to partner waiting for decision
// flow_id = 7 load pick up done
// flow_id = 8 load completed

//0,1,2,3,5,8

// 0 => accept,offer,reject
// 1 => accept
// 2 => cancelled
// 3=> Offer
// 4=> Pick up button show
// 5=> cancelled
// 6=> offer
// 7=> complete button show
// 8=> completed rate us valu

makingPhoneCall({required String phoneNumber}) async {
  var url = Uri.parse("tel:$phoneNumber");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
