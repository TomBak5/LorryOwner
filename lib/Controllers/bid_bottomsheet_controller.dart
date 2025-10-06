// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_spinkit/flutter_spinkit.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:truckbuddy/Api_Provider/api_provider.dart';
import 'package:truckbuddy/AppConstData/app_colors.dart';
import 'package:truckbuddy/AppConstData/typographyy.dart';
import 'package:truckbuddy/models/lorry_list_model.dart';
import 'package:truckbuddy/widgets/widgets.dart';

class BidBottomsheetController extends GetxController implements GetxService {
  TextEditingController amount = TextEditingController();
  TextEditingController description = TextEditingController();

  bool isAmount = false;

  setIsAmount(bool value) {
    isAmount = value;
    update();
  }

  bool isPriceFix = false;

  setIsPriceFix(bool value) {
    isPriceFix = value;
    update();
  }

  bool isAvailable = false;

  setIsAvailable(bool value) {
    isAvailable = value;
    update();
  }

  bool isBidLoder = false;

  setIsBidLoder(bool value) {
    isBidLoder = value;
    update();
  }

  Future bidNowBottombar({
    required LorryListModel lorrydata,
    required String ownerId,
    required String loadId,
    required String totalLoad,
    required String tonns,
    int? inde,
  }) {
    String countryCode = "";
    print("BID NOW DETAILs ${lorrydata.bidLorryData}");
    countryCode = "${lorrydata.bidLorryData[0].lorryTitle}(${lorrydata.bidLorryData[0].lorryNo})";
    String lorryid = lorrydata.bidLorryData[0].id;
    return Get.bottomSheet(
      isScrollControlled: true,
      GetBuilder<BidBottomsheetController>(
        builder: (bidBottomsheetController) {
          return StatefulBuilder(
            builder: (context, setState) {
              return Container(
                padding: const EdgeInsets.all(15),
                decoration: BoxDecoration(
                  color: whiteColor,
                  borderRadius: BorderRadius.vertical(top: Radius.circular(12)),
                ),
                child: SingleChildScrollView(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Bid Now".tr,
                        style: TextStyle(
                          color: textBlackColor,
                          fontSize: 20,
                          fontFamily: fontFamilyBold,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      Divider(color: Colors.grey.withOpacity(0.3)),
                      Text(
                        "What's your expected price?".tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: textBlackColor,
                          fontFamily: fontFamilyBold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      TextField(
                        keyboardType: TextInputType.number,
                        controller: amount,
                        onChanged: (value) {
                          if (value.isEmpty) {
                            setIsAmount(false);
                          } else {
                            setIsAmount(amount.text.isEmpty);
                          }
                        },
                        style: TextStyle(
                          fontSize: 17,
                          fontFamily: fontFamilyRegular,
                          color: textBlackColor,
                        ),
                        decoration: InputDecoration(
                          suffixIcon: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              isAmount
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
                              isAmount
                                  ? const SizedBox(width: 8)
                                  : const SizedBox(),
                              Text(
                                isPriceFix ? "Per Tonnes".tr : "Fix".tr,
                              ),
                              SizedBox(
                                height: 20,
                                child: Switch(
                                  activeColor: priMaryColor,
                                  value: isPriceFix,
                                  onChanged: (value) {
                                    setIsPriceFix(value);
                                  },
                                ),
                              ),
                            ],
                          ),
                          hintText: "Amount".tr,
                          contentPadding: EdgeInsets.symmetric(vertical: 16),
                          hintStyle: TextStyle(
                            fontSize: 17,
                            fontFamily: fontFamilyRegular,
                            color: textGreyColor,
                          ),
                          prefixIcon: SizedBox(
                            width: 20,
                            height: 20,
                            child: Center(
                              child: SvgPicture.asset(
                                "assets/icons/sack-dollar.svg",
                              ),
                            ),
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          disabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                          enabledBorder: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(12),
                            borderSide: BorderSide(
                              color: Colors.grey.withOpacity(0.3),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Select your lorry".tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: textBlackColor,
                          fontFamily: fontFamilyBold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Expanded(
                            child: DropdownButtonFormField(
                              menuMaxHeight: 300,
                              decoration: InputDecoration(
                                hintText: 'Lorry',
                                contentPadding: const EdgeInsets.all(12),
                                hintStyle: const TextStyle(fontSize: 14),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                ),
                                enabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                ),
                                disabledBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                ),
                                focusedBorder: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(12),
                                  borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                ),
                              ),
                              dropdownColor: Colors.white,
                              onChanged: (newValue) {
                                setState(() {
                                  countryCode = newValue!;
                                });
                              },
                              value: countryCode,
                              items: lorrydata.bidLorryData.map<DropdownMenuItem>((m) {
                                return DropdownMenuItem(
                                  onTap: () {
                                    setState(() {
                                      lorryid = m.id;
                                    });
                                  },
                                  value: "${m.lorryTitle}(${m.lorryNo})",
                                  child: Text("${m.lorryTitle}(${m.lorryNo})"),
                                );
                              }).toList(),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        "Description".tr,
                        style: TextStyle(
                          fontSize: 14,
                          color: textBlackColor,
                          fontFamily: fontFamilyBold,
                          fontWeight: FontWeight.w500,
                        ),
                      ),
                      const SizedBox(height: 16),
                      Container(
                        height: 100,
                        padding: const EdgeInsets.all(15),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: Colors.grey.withOpacity(0.3)),
                        ),
                        child: TextField(
                          controller: description,
                          style: TextStyle(
                            fontSize: 14,
                            fontFamily: fontFamilyRegular,
                            color: textBlackColor,
                          ),
                          decoration: InputDecoration(
                            border: InputBorder.none,
                            isDense: true,
                            hintText: "Description".tr,
                            hintStyle: TextStyle(
                              fontSize: 14,
                              fontFamily: fontFamilyRegular,
                              color: textGreyColor,
                            ),
                            contentPadding: EdgeInsets.zero,
                          ),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          isBidLoder
                              ? SpinKitThreeBounce(color: priMaryColor, size: 15.0)
                              : Expanded(
                                  child: commonButton(
                                    title: "Bid".tr,
                                    onTapp: () {
                                      if (amount.text.isNotEmpty) {
                                        if (isBidLoder == false) {
                                          setIsBidLoder(true);
                                          ApiProvider().bidNowApi(
                                            ownerId: ownerId,
                                            loadId: loadId,
                                            lorryId: lorryid,
                                            amount: amount.text,
                                            amtType: isPriceFix
                                                ? "Tonne"
                                                : "Fixed",
                                            totalAmt: isPriceFix
                                                ? (int.parse(amount.text.toString()) * int.parse(tonns)).toString()
                                                : amount.text,
                                            isImmediate: isAvailable ? "1" : "0",
                                            totalLoad: totalLoad,
                                            description: description.text
                                          ).then((value) {
                                            var decode = value;
                                            if (decode["Result"] == "true") {
                                              if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                                showCommonToast(decode["ResponseMsg"]);
                                              }
                                              Get.back();
                                              amount.text = "";
                                              setIsPriceFix(false);
                                              setIsAvailable(false);
                                              setIsBidLoder(false);
                                              amount.clear();
                                              description.clear();
                                            } else {
                                              if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
                                                showCommonToast(decode["ResponseMsg"]);
                                              }
                                              Get.back();
                                              amount.text = "";
                                              setIsPriceFix(false);
                                              setIsAvailable(false);
                                              setIsBidLoder(false);
                                              amount.clear();
                                              description.clear();
                                            }
                                          });
                                        }
                                      } else {
                                        showCommonToast("Enter Bid Amount".tr);
                                      }
                                    },
                                  ),
                                )
                        ],
                      )
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
