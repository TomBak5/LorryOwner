// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/trans_profile.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../Api_Provider/imageupload_api.dart';
import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';

import '../../AppConstData/typographyy.dart';
import '../../Controllers/loadsdeatils_controller.dart';

import '../../widgets/widgets.dart';

class LoadsDetails extends StatefulWidget {
  final String uid;
  final String loadId;
  final String currency;
  LoadsDetails({
    super.key,
    required this.uid,
    required this.loadId,
    required this.currency,
  });

  @override
  State<LoadsDetails> createState() => _LoadsDetailsState();
}

class _LoadsDetailsState extends State<LoadsDetails> {
  LoadsDetailsController loadsDetailsController =
      Get.put(LoadsDetailsController());

  @override
  void initState() {
    super.initState();
    getDataFromApi();
  }

  bool isloading = false;

  getDataFromApi() {
    ApiProvider().loadsDetils(uid: widget.uid, loadId: widget.loadId).then((value) async {
      loadsDetailsController.setDetilsValue(value, value.loadDetails.svisibleHours);
      loadsDetailsController.setIsLoading(false);
    });
  }

  @override
  void dispose() {
    super.dispose();

    loadsDetailsController.isLoading = true;
  }

  TextEditingController feedback = TextEditingController();
  double rating = 0.0;

  @override
  Widget build(BuildContext context) {
    return RefreshIndicator(
      onRefresh: () {
        return Future.delayed(
          Duration(seconds: 1),
          () {
            getDataFromApi();
          },
        );
      },
      child: GetBuilder<LoadsDetailsController>(
        builder: (loadsDetailsController) {
          return loadsDetailsController.isLoading
              ? Scaffold(
                  body: Center(child: CircularProgressIndicator()),
                )
              : Scaffold(
                  bottomSheet: Padding(
                    padding: EdgeInsets.all(10),
                    child: Row(
                      children: [
                        Expanded(
                          child: Builder(
                            builder: (context) {
                              if (loadsDetailsController.detailsData.loadDetails.flowId ==  "3" && loadsDetailsController.detailsData.loadDetails.isRate == '0') {
                                return commonButton(
                                  title: "${"Rate to".tr} ${loadsDetailsController.detailsData.loadDetails.loaderName}",
                                  onTapp: () {
                                    Get.bottomSheet(
                                      StatefulBuilder(
                                        builder: (context, setState12) {
                                          return Container(
                                            height: Get.height * 0.47,
                                            padding: EdgeInsets.all(15),
                                            decoration: BoxDecoration(
                                              borderRadius: BorderRadius.vertical(
                                                top: Radius.circular(12),
                                              ),
                                              color: Colors.white,
                                            ),
                                            child: SingleChildScrollView(
                                              child: Column(
                                                children: [
                                                  CircleAvatar(
                                                    radius: 25,
                                                    backgroundColor: Colors.transparent,
                                                    backgroundImage: NetworkImage(
                                                      "$basUrl${loadsDetailsController.detailsData.loadDetails.loaderImg}",
                                                    ),
                                                  ),
                                                  SizedBox(height: 8),
                                                  Text(
                                                    loadsDetailsController.detailsData.loadDetails.loaderName,
                                                    style: TextStyle(
                                                      color: textBlackColor,
                                                      fontSize: 20,
                                                      fontFamily: fontFamilyBold,
                                                    ),
                                                  ),
                                                  Text(
                                                    loadsDetailsController.detailsData.loadDetails.loaderMobile,
                                                    style: TextStyle(
                                                      color: textBlackColor,
                                                      fontSize: 16,
                                                      fontFamily: fontFamilyRegular,
                                                    ),
                                                  ),
                                                  SizedBox(height: 15),
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
                                                      loadsDetailsController.setRating(rating);
                                                    },
                                                  ),
                                                  SizedBox(height: 10),
                                                  Container(
                                                    decoration: BoxDecoration(
                                                      borderRadius: BorderRadius.circular(12),
                                                      border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
                                                  SizedBox(height: 20),
                                                  Row(
                                                    children: [
                                                      Expanded(
                                                        child: commonButton(
                                                          title: "${"Rate to".tr} ${loadsDetailsController.detailsData.loadDetails.loaderName}",
                                                          onTapp: () {
                                                            if (feedback.text.isNotEmpty && loadsDetailsController.rating != 0.0) {
                                                              ApiProvider()
                                                                  .rating(
                                                                      loadId: widget.loadId,
                                                                      uid: widget.uid,
                                                                      rateText: feedback.text,
                                                                      totalRate: "${loadsDetailsController.rating}")
                                                                  .then((value) {
                                                                var decode = jsonDecode(value);

                                                                if (decode["Result"] == "true") {
                                                                  showCommonToast(decode["ResponseMsg"]);
                                                                  Get.close(2);
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
                                                  SizedBox(height: 20),
                                                ],
                                              ),
                                            ),
                                          );
                                        },
                                      ),
                                    );
                                  },
                                );
                              } else if (loadsDetailsController.detailsData.loadDetails.flowId == "1" || loadsDetailsController.detailsData.loadDetails.flowId == '2') {
                                return commonButton(
                                  title: "Assigned to Driver",
                                  onTapp: () {

                                  },
                                );
                              } else {
                                return SizedBox();
                              }
                            },
                          ),
                        )
                      ],
                    ),
                  ),
                  backgroundColor: Colors.white,
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
                  body: Padding(
                    padding: EdgeInsets.all(15.0),
                    child: Stack(
                      children: [
                        SingleChildScrollView(
                          physics: AlwaysScrollableScrollPhysics(),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: commonDetils(
                                      vehicleImg: loadsDetailsController.detailsData.loadDetails.vehicleImg,
                                      vehicleTitle: loadsDetailsController.detailsData.loadDetails.vehicleTitle,
                                      currency: widget.currency,
                                      amount: loadsDetailsController.detailsData.loadDetails.amount,
                                      amtType: loadsDetailsController.detailsData.loadDetails.amtType,
                                      totalAmt: loadsDetailsController.detailsData.loadDetails.totalAmt,
                                      pickupState: loadsDetailsController.detailsData.loadDetails.pickupState,
                                      pickupPoint: loadsDetailsController.detailsData.loadDetails.pickupPoint,
                                      dropState: loadsDetailsController.detailsData.loadDetails.dropState,
                                      dropPoint: loadsDetailsController.detailsData.loadDetails.dropPoint,
                                      postDate: loadsDetailsController.detailsData.loadDetails.postDate.toString(),
                                      weight: loadsDetailsController.detailsData.loadDetails.weight,
                                      materialName: loadsDetailsController.detailsData.loadDetails.materialName,
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 20),
                              Row(
                                children: [
                                  Expanded(
                                    child: Container(
                                      padding: EdgeInsets.all(10),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(12),
                                        border: Border.all(
                                          color: Colors.grey.withOpacity(0.3),
                                        ),
                                      ),
                                      child: ListTile(
                                        onTap: () {
                                          Get.to(TransProfile(uid: loadsDetailsController.detailsData.loadDetails.uid));
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
                                            SizedBox(width: 5),
                                            Transform.translate(
                                              offset: Offset(0, 1),
                                              child: Text(
                                                loadsDetailsController.detailsData.loadDetails.loaderRate,
                                                style: TextStyle(
                                                  color: priMaryColor,
                                                ),
                                              ),
                                            ),
                                          ],
                                        ),
                                        subtitle: Transform.translate(
                                          offset: Offset(-8, 0),
                                          child: RichText(
                                            text: TextSpan(
                                              children: [
                                                TextSpan(
                                                  text: "${widget.currency}${loadsDetailsController.detailsData.loadDetails.amount}",
                                                  style: TextStyle(
                                                    color: textBlackColor,
                                                    fontSize: 13,
                                                    fontWeight: FontWeight.w500,
                                                    fontFamily: fontFamilyBold,
                                                  ),
                                                ),
                                                TextSpan(
                                                  text: " /${loadsDetailsController.detailsData.loadDetails.amtType}",
                                                  style: TextStyle(
                                                    color: textGreyColor,
                                                    fontSize: 10,
                                                    fontFamily: fontFamilyRegular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        title: Transform.translate(
                                          offset: Offset(-8, 0),
                                          child: Text(
                                            loadsDetailsController.detailsData.loadDetails.loaderName,
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
                                          backgroundImage: NetworkImage("$basUrl${loadsDetailsController.detailsData.loadDetails.loaderImg}"),
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: 20,
                              ),
                              loadsDetailsController.detailsData.loadDetails.flowId == "3"
                                  ? SizedBox()
                                  : Column(
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
                                        SizedBox(height: 10),
                                        Row(
                                          children: [
                                            Expanded(
                                              child: Container(
                                                padding: EdgeInsets.all(15),
                                                decoration: BoxDecoration(
                                                  borderRadius: BorderRadius.circular(12),
                                                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
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
                                                            SizedBox(height: 2),
                                                            Text(
                                                              loadsDetailsController.detailsData.loadDetails.pickName,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                color: textBlackColor,
                                                                fontWeight:FontWeight.w700,
                                                              ),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              loadsDetailsController.detailsData.loadDetails.pickMobile,
                                                              style: TextStyle(
                                                                fontSize: 16,
                                                                fontFamily: fontFamilyRegular,
                                                                color: textGreyColor,
                                                                fontWeight:FontWeight.w200,
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                        InkWell(
                                                          onTap: () {
                                                            makingPhoneCall(phoneNumber: loadsDetailsController.detailsData.loadDetails.pickMobile);
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
                                                    SizedBox(height: 10),
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
                                                            SizedBox(height: 2),
                                                            Text(
                                                              loadsDetailsController.detailsData.loadDetails.dropName,
                                                              style: TextStyle(
                                                                fontSize: 14,
                                                                fontFamily: fontFamilyRegular,
                                                                color: textBlackColor,
                                                                fontWeight: FontWeight.w700,
                                                              ),
                                                            ),
                                                            SizedBox(height: 2),
                                                            Text(
                                                              loadsDetailsController.detailsData.loadDetails.dropMobile,
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
                                                            makingPhoneCall(phoneNumber: loadsDetailsController.detailsData.loadDetails.dropMobile);
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
                                        SizedBox(height: 20),
                                      ],
                                    ),
                              Text(
                                "Payment Information".tr,
                                style: TextStyle(
                                  color: textBlackColor,
                                  fontSize: 16,
                                  fontFamily: fontFamilyBold,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                              SizedBox(height: 10),
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
                                              Spacer(),
                                              Text(
                                                loadsDetailsController.detailsData.loadDetails.pMethodName,
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
                                          SizedBox(height: 15),
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
                                              Spacer(),
                                              Text(
                                                loadsDetailsController.detailsData.loadDetails.orderTransactionId,
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
                                          SizedBox(height: 15),
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
                                              Spacer(),
                                              Text(
                                                "${widget.currency}${loadsDetailsController.detailsData.loadDetails.amount}",
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
                                          loadsDetailsController.detailsData.loadDetails.walAmt.compareTo("0") == 0
                                              ? SizedBox()
                                              : Column(
                                                  crossAxisAlignment: CrossAxisAlignment.start,
                                                  children: [
                                                    SizedBox(height: 15),
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
                                                        Spacer(),
                                                        Text(
                                                          "${widget.currency}${loadsDetailsController.detailsData.loadDetails.walAmt}",
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
                                                "${widget.currency}${loadsDetailsController.detailsData.loadDetails.totalAmt}",
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: fontFamilyBold,
                                                  color: textBlackColor,
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
                              SizedBox(height: Get.height / 13)
                            ],
                          ),
                        ),
                        isloading
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox(),
                      ],
                    ),
                  ),
                );
        },
      ),
    );
  }
}

makingPhoneCall({required String phoneNumber}) async {
  var url = Uri.parse("tel:$phoneNumber");
  if (await canLaunchUrl(url)) {
    await launchUrl(url);
  } else {
    throw 'Could not launch $url';
  }
}
