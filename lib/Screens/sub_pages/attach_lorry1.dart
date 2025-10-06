// ignore_for_file: deprecated_member_use

import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:truckbuddy/Api_Provider/imageupload_api.dart';
import 'package:truckbuddy/Controllers/attach_lorry_controller.dart';
import 'package:truckbuddy/Screens/sub_pages/attach_lorry2.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../models/statelist_model.dart';
import '../../widgets/widgets.dart';

class AttachLorry1 extends StatefulWidget {
  const AttachLorry1({
    super.key,
    required this.lorryNumber,
    required this.numberOfTonnes,
    required this.vehicleId,
  });
  final String lorryNumber;
  final String numberOfTonnes;
  final String vehicleId;

  @override
  State<AttachLorry1> createState() => _AttachLorry1State();
}

class _AttachLorry1State extends State<AttachLorry1> {
  AttachLorryController attachLorryController =
      Get.put(AttachLorryController());
  late StateListModel states;
  bool isLoading = true;

  @override
  void dispose() {
    super.dispose();
    attachLorryController.selectStateIdList.clear();
    attachLorryController.selectStateList.clear();
  }

  @override
  void initState() {
    super.initState();
    getDatafromApi();
    debugPrint("======= init selectStateIDList ======= ${attachLorryController.selectStateIdList}");
    debugPrint("========== init lorryNumber ========== ${widget.lorryNumber}");
    debugPrint("======== init numberOfTonnes ========= ${widget.numberOfTonnes}");
    debugPrint("=========== init vehicleId =========== ${widget.vehicleId}");
  }

  getdatafromlocle() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    String decoderes = preferences.getString("EditLorryData")!;
    if (decoderes.isNotEmpty) {
      Map decode = jsonDecode(decoderes);

      setState(() {
        attachLorryController.selectStateList = decode["statelist"];
      });
      for (var i = 0; i < decode["statelist"].length; i++) {
        ApiProvider().stateid(state: decode["statelist"][i]).then((value) {
          print("STATE  LIST $value");
          var decode = value;
          setState(() {
          attachLorryController.selectStateIdList.add(decode["curr_state_id"]);
          });
        });
      }
      if (attachLorryController.selectStateIdList.isNotEmpty) {
        setState(() {
          isLoading = false;
        });
      }
      debugPrint("======= init selectStateIDList ======= ${attachLorryController.selectStateIdList}");
    }
  }

  Future getDatafromApi() async {
    SharedPreferences preferences = await SharedPreferences.getInstance();
    var uid = preferences.getString("uid")!;
    ApiProvider().getstatList(ownerId: uid).then((value) {
      setState(() {
        states = value;
        isLoading = false;
      });
      getdatafromlocle();
    });
  }

  @override
  Widget build(BuildContext context) {
    return GetBuilder<AttachLorryController>(
      builder: (attachLorryController) {
        return Scaffold(
          backgroundColor: Colors.white,
          resizeToAvoidBottomInset: false,
          bottomSheet: PreferredSize(
            preferredSize: const Size.fromHeight(42),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: isLoading
                  ? Center(child: CircularProgressIndicator())
                  : Row(
                      children: [
                        Expanded(
                          child: commonButton(
                            title: "Next".tr,
                            onTapp: () {
                              debugPrint("======= selectStateIDList ======= ${attachLorryController.selectStateIdList}");
                              debugPrint("========== lorryNumber ========== ${widget.lorryNumber}");
                              debugPrint("======== numberOfTonnes ========= ${widget.numberOfTonnes}");
                              debugPrint("========== vehicleId ============ ${widget.vehicleId}");
                              debugPrint("========== vehicleId ============ ${attachLorryController.selectStateList}");
                              if (attachLorryController.selectStateIdList.isNotEmpty && attachLorryController.selectStateList.isNotEmpty) {
                                Get.to(AttachLorry2(listOfStateId: attachLorryController.selectStateIdList,lorryNumber: widget.lorryNumber,numberOfTones: widget.numberOfTonnes,vehicleId: widget.vehicleId));
                              } else {
                                showCommonToast("select 1 state");
                              }
                            },
                          ),
                        ),
                      ],
                    ),
            ),
          ),
          appBar: AppBar(
            elevation: 0,
            backgroundColor: priMaryColor,
            centerTitle: true,
            title: Text(
              attachLorryController.editeTitle ?? "Add Lorry".tr,
              style: TextStyle(
                fontSize: 18,
                fontFamily: fontFamilyBold,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
          body: Stack(
            children: [
              Column(
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
                ],
              ),
              Padding(
                padding: const EdgeInsets.all(15.0),
                child: isLoading
                    ? const Center(child: CircularProgressIndicator())
                    : SingleChildScrollView(
                        child: Column(
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white70),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "1",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: fontFamilyRegular,
                                        color: textBlackColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 3,
                                  child: Text(
                                    "Load Details".tr,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: fontFamilyBold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: SizedBox(
                                    width: Get.width * 0.07,
                                    child: const Divider(
                                      color: Colors.white,
                                      thickness: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.white,
                                    border: Border.all(color: Colors.white70),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "2",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: fontFamilyRegular,
                                        color: textBlackColor,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  flex: 3,
                                  child: Text(
                                    "Vehicle Type".tr,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: fontFamilyBold,
                                      fontSize: 12,
                                      color: Colors.white,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Flexible(
                                  child: SizedBox(
                                    width: Get.width * 0.07,
                                    child: const Divider(
                                      color: Colors.white70,
                                      thickness: 1.5,
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 5),
                                Container(
                                  height: 16,
                                  width: 16,
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    border: Border.all(color: Colors.white70),
                                    shape: BoxShape.circle,
                                  ),
                                  child: Center(
                                    child: Text(
                                      "3",
                                      style: TextStyle(
                                        fontSize: 12,
                                        fontFamily: fontFamilyRegular,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ),
                                ),
                                const SizedBox(width: 8),
                                Flexible(
                                  child: Text(
                                    "Post".tr,
                                    style: TextStyle(
                                      overflow: TextOverflow.ellipsis,
                                      fontFamily: fontFamilyBold,
                                      fontSize: 12,
                                      color: Colors.white70,
                                    ),
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 12),
                            Container(
                              height: Get.height * 0.72,
                              width: Get.width,
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
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    Row(
                                      children: [
                                        Text(
                                          "Select Routes".tr,
                                          style: Typographyy.headLine.copyWith(fontSize: 15),
                                        ),
                                        const Spacer(),
                                        InkWell(
                                          onTap: () {
                                            for (int a = 0; a < states.stateData.length; a++) {
                                              setState(() {
                                                if (attachLorryController.selectStateList.contains(states.stateData[a].title)) {
                                                } else {
                                                  attachLorryController.selectStateIdList.add(states.stateData[a].id);
                                                  attachLorryController.selectStateList.add(states.stateData[a].title);
                                                }
                                              });
                                            }
                                          },
                                          child: Text(
                                            "Select All".tr,
                                            style: Typographyy.headLine.copyWith(
                                              fontSize: 13,
                                              color: priMaryColor,
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                    SizedBox(height: 15),
                                    isLoading
                                        ? GridView.builder(
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisExtent: 100,
                                            ),
                                            shrinkWrap: true,
                                            itemCount: 12,
                                            itemBuilder: (context, index) {
                                              return Padding(
                                                padding: EdgeInsets.all(10),
                                                child: commonSimmer(height: 50, width: 50),
                                              );
                                            },
                                          )
                                        : GridView.builder(
                                            physics: NeverScrollableScrollPhysics(),
                                            shrinkWrap: true,
                                            itemCount: states.stateData.length,
                                            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                                              crossAxisCount: 2,
                                              mainAxisExtent: 100,
                                            ),
                                            itemBuilder: (context, index) {
                                              return InkWell(
                                                onTap: () {
                                                  if (attachLorryController.selectStateList.contains(states.stateData[index].title)) {
                                                    setState(() {
                                                      attachLorryController.selectStateIdList.remove(states.stateData[index].id);
                                                      attachLorryController.selectStateList.remove(states.stateData[index].title);
                                                    });
                                                  } else {
                                                    setState(() {
                                                      attachLorryController.selectStateIdList.add(states.stateData[index].id);
                                                      attachLorryController.selectStateList.add(states.stateData[index].title);
                                                    });
                                                  }
                                                },
                                                child: Container(
                                                  height: 80,
                                                  width: 80,
                                                  margin:
                                                      const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            12),
                                                    color: attachLorryController.selectStateList.contains(states.stateData[index].title)
                                                        ? priMaryColor.withOpacity(0.05)
                                                        : Colors.transparent,
                                                    border: Border.all(
                                                      color: attachLorryController.selectStateList.contains(states.stateData[index].title)
                                                          ? priMaryColor
                                                          : Colors.grey.withOpacity(0.3),
                                                    ),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Image.network(
                                                        "$basUrl${states.stateData[index].img}",
                                                        width: 68,
                                                        height: 68,
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
                                                        child: Text(
                                                          states.stateData[index].title,
                                                          style: Typographyy.headLine.copyWith(
                                                            fontSize: 13,
                                                            overflow: TextOverflow.ellipsis,
                                                          ),
                                                          maxLines: 2,
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              );
                                            },
                                          ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
              ),
            ],
          ),
        );
      },
    );
  }
}
