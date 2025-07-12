// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Api_Provider/imageupload_api.dart';
import 'package:movers_lorry_owner/Controllers/earning_controller.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';

import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';

class EarningScreen extends StatefulWidget {
  const EarningScreen({super.key});

  @override
  State<EarningScreen> createState() => _EarningScreenState();
}

class _EarningScreenState extends State<EarningScreen> {
  EarningScreenController walletScreenController = Get.put(EarningScreenController());
  String currency = "\$";

  TextEditingController amt = TextEditingController();
  TextEditingController upicontroller = TextEditingController();
  TextEditingController paypalcontroller = TextEditingController();
  TextEditingController bankName = TextEditingController();
  TextEditingController accName = TextEditingController();
  TextEditingController accNumber = TextEditingController();
  TextEditingController ifsc = TextEditingController();

  @override
  void dispose() {
    super.dispose();
    walletScreenController.istrue = false;
    amt.dispose();
    upicontroller.dispose();
    paypalcontroller.dispose();
    bankName.dispose();
    accName.dispose();
    accNumber.dispose();
    ifsc.dispose();
  }

  @override
  void initState() {
    super.initState();
    walletScreenController.getDataFromLocal().then((value) {
      walletScreenController.fetChDataFromApi();
    });
  }

  SingingCharacter? payMentMethode = SingingCharacter.emty;
  @override
  Widget build(BuildContext context) {
    return GetBuilder<EarningScreenController>(
      builder: (earningScreenController) {
        return RefreshIndicator(
          onRefresh: () {
            return Future.delayed(const Duration(seconds: 1), () {
              walletScreenController.fetChDataFromApi();
            });
          },
          child: Scaffold(
            backgroundColor: Colors.white,
            appBar: AppBar(
              elevation: 0,
              backgroundColor: priMaryColor,
              centerTitle: true,
              actions: [
                Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Flexible(
                      child: Center(
                        child: InkWell(
                          onTap: () {
                            Get.bottomSheet(
                              isScrollControlled: true,
                              StatefulBuilder(
                                builder: (BuildContext context, StateSetter setState) {
                                  return Container(
                                    padding: const EdgeInsets.all(15),
                                    decoration: const BoxDecoration(
                                      borderRadius: BorderRadius.vertical(
                                        top: Radius.circular(12),
                                      ),
                                      color: Colors.white,
                                    ),
                                    child: SingleChildScrollView(
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          Text(
                                            "Payout Request".tr,
                                            style: TextStyle(
                                              fontSize: 20,
                                              color: textBlackColor,
                                              fontFamily: fontFamilyBold,
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          Row(
                                            mainAxisAlignment: MainAxisAlignment.start,
                                            children: [
                                              Text(
                                                "Enter your amount".tr,
                                                style: TextStyle(
                                                  fontSize: 14,
                                                  fontFamily: fontFamilyRegular,
                                                  color: textGreyColor,
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 8),
                                          TextField(
                                            controller: amt,
                                            decoration: InputDecoration(
                                              contentPadding: EdgeInsets.all(15),
                                              border: OutlineInputBorder(
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
                                              disabledBorder: OutlineInputBorder(
                                                borderRadius: BorderRadius.circular(12),
                                                borderSide: BorderSide(
                                                  color: Colors.grey.withOpacity(0.3),
                                                ),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 20),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                payMentMethode = SingingCharacter.upi;
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child: Radio<SingingCharacter>(
                                                    value: SingingCharacter.upi,
                                                    groupValue: payMentMethode,
                                                    activeColor: priMaryColor,
                                                    onChanged: (SingingCharacter? value) {
                                                      setState(() {
                                                        payMentMethode = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "Uip".tr,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: textGreyColor,
                                                    fontFamily: fontFamilyRegular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          SizedBox(height: 15),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                payMentMethode = SingingCharacter.bankTransfer;
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child: Radio<SingingCharacter>(
                                                    value: SingingCharacter.bankTransfer,
                                                    groupValue: payMentMethode,
                                                    activeColor: priMaryColor,
                                                    onChanged: (SingingCharacter? value) {
                                                      setState(() {
                                                        payMentMethode = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "bank transfer".tr,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: textGreyColor,
                                                    fontFamily: fontFamilyRegular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          InkWell(
                                            onTap: () {
                                              setState(() {
                                                payMentMethode = SingingCharacter.paypal;
                                              });
                                            },
                                            child: Row(
                                              children: [
                                                SizedBox(
                                                  height: 15,
                                                  width: 15,
                                                  child: Radio<SingingCharacter>(
                                                    value: SingingCharacter.paypal,
                                                    groupValue: payMentMethode,
                                                    activeColor: priMaryColor,
                                                    onChanged: (SingingCharacter? value) {
                                                      setState(() {
                                                        payMentMethode = value;
                                                      });
                                                    },
                                                  ),
                                                ),
                                                const SizedBox(width: 8),
                                                Text(
                                                  "paypal".tr,
                                                  style: TextStyle(
                                                    fontSize: 15,
                                                    color: textGreyColor,
                                                    fontFamily: fontFamilyRegular,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                          const SizedBox(height: 12),
                                          const SizedBox(height: 10),
                                          if (payMentMethode == SingingCharacter.upi)
                                            upi()
                                          else if (payMentMethode == SingingCharacter.bankTransfer)
                                            bank()
                                          else if (payMentMethode ==  SingingCharacter.paypal)
                                            paypal()
                                          else
                                            SizedBox(),
                                          const SizedBox(height: 10),
                                          Row(
                                            children: [
                                              Expanded(
                                                child: OutlinedButton(
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
                                                    Get.back();
                                                  },
                                                  child: Text(
                                                    "Cancle".tr,
                                                    style: const TextStyle(
                                                      color: Color(0xffFF9F9F),
                                                      fontSize: 15,
                                                      fontFamily: "urbani_extrabold",
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(width: 10),
                                              Expanded(
                                                child: ElevatedButton(
                                                  style: ElevatedButton.styleFrom(
                                                    elevation: 0,
                                                    fixedSize: Size.fromHeight(40),
                                                    shape: RoundedRectangleBorder(
                                                      borderRadius: BorderRadius.circular(12),
                                                    ),
                                                    backgroundColor: priMaryColor,
                                                  ),
                                                  onPressed: () {
                                                    if (payMentMethode == SingingCharacter.upi) {
                                                      ApiProvider().payoutRequest(
                                                              ownerId: walletScreenController.uid,
                                                              amt: amt.text,
                                                              rType: "upi".tr,
                                                              upiId: upicontroller.text)
                                                          .then((value) {
                                                        deocderesponse(value);
                                                      });
                                                    } else if (payMentMethode == SingingCharacter.bankTransfer) {
                                                      ApiProvider().payoutRequest(
                                                        ownerId: walletScreenController.uid,
                                                        amt: amt.text,
                                                        rType: "bank transfer".tr,
                                                        accName: accName.text,
                                                        accNumber:accNumber.text,
                                                        bankName: bankName.text,
                                                        ifscCode: ifsc.text,
                                                      ).then((value) {
                                                        deocderesponse(value);
                                                      });
                                                    } else if (payMentMethode == SingingCharacter.paypal) {
                                                      ApiProvider().payoutRequest(
                                                          ownerId: walletScreenController.uid,
                                                          amt: amt.text,
                                                          rType: "paypal",
                                                          paypal: paypalcontroller.text,
                                                        ).then((value) {
                                                        deocderesponse(value);
                                                      });
                                                    } else {
                                                      const SizedBox();
                                                    }
                                                  },
                                                  child: Text(
                                                    "Proceed".tr,
                                                    style: TextStyle(
                                                      color: whiteColor,
                                                      fontSize: 15,
                                                      fontFamily: "urbani_extrabold",
                                                      fontWeight: FontWeight.w700,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ],
                                      ),
                                    ),
                                  );
                                },
                              ),
                            );
                          },
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 5),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Row(
                              mainAxisSize: MainAxisSize.min,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Flexible(
                                  child: Text(
                                    "Request".tr,
                                    style: TextStyle(
                                      fontSize: 16,
                                      color: textBlackColor,
                                      fontFamily: fontFamilyBold,
                                      fontWeight: FontWeight.w500,
                                    ),
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: 8),
              ],
              title: Text(
                "Wallet".tr,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: fontFamilyBold,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ),
            body: walletScreenController.istrue
                ? const Center(child: CircularProgressIndicator())
                : SingleChildScrollView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Stack(
                          alignment: Alignment.center,
                          children: [
                            Stack(
                              children: [
                                Column(
                                  children: [
                                    Container(
                                      width: MediaQuery.of(context).size.width,
                                      height: 220,
                                      color: priMaryColor,
                                    )
                                  ],
                                ),
                                Padding(
                                  padding: const EdgeInsets.all(15.0),
                                  child: Container(
                                    height: Get.height * 0.82,
                                    width: MediaQuery.of(context).size.width,
                                    padding: const EdgeInsets.all(10),
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
                                      physics: AlwaysScrollableScrollPhysics(),
                                      child: Column(
                                        mainAxisSize: MainAxisSize.min,
                                        crossAxisAlignment: CrossAxisAlignment.start,
                                        children: [
                                          Row(
                                            children: [
                                              Expanded(
                                                child: Container(
                                                  height: 195,
                                                  padding: EdgeInsets.all(15),
                                                  decoration: BoxDecoration(
                                                    color: secondaryColor,
                                                    borderRadius: BorderRadius.circular(16),
                                                  ),
                                                  child: Row(
                                                    children: [
                                                      Column(
                                                        crossAxisAlignment: CrossAxisAlignment.start,
                                                        children: [
                                                          Text(
                                                            'Total Earning'.tr,
                                                            style: TextStyle(
                                                              fontSize: 16,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w500,
                                                              fontFamily: fontFamilyBold,
                                                            ),
                                                          ),
                                                          const SizedBox(height: 8),
                                                          Text(
                                                            "${walletScreenController.currency}${walletScreenController.walletModel.earning.earning}".tr,
                                                            style: TextStyle(
                                                              fontSize: 24,
                                                              color:Colors.white,
                                                              fontWeight: FontWeight.w700,
                                                              fontFamily: fontFamilyBold,
                                                            ),
                                                          ),
                                                          const Spacer(),
                                                          Text(
                                                            "E-Wallet".tr,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w400,
                                                              fontFamily: fontFamilyRegular,
                                                            ),
                                                          ),
                                                          SizedBox(height: 5),
                                                          Text(
                                                            '${"Withdraw Limit".tr} ${walletScreenController.currency}${walletScreenController.walletModel.earning.withdrawLimit}'.tr,
                                                            style: TextStyle(
                                                              fontSize: 14,
                                                              color: Colors.white,
                                                              fontWeight: FontWeight.w400,
                                                              fontFamily: fontFamilyRegular,
                                                            ),
                                                          ),
                                                        ],
                                                      ),
                                                      Expanded(
                                                        child: Column(
                                                          crossAxisAlignment: CrossAxisAlignment.end,
                                                          mainAxisAlignment: MainAxisAlignment.end,
                                                          children: [
                                                            CircleAvatar(
                                                              radius: 32,
                                                              backgroundColor: Colors.white,
                                                              child: Transform.translate(
                                                                offset: Offset(1, 3),
                                                                child: Center(
                                                                  child: SvgPicture.asset(
                                                                    "assets/icons/walleticon.svg",
                                                                    width: 30,
                                                                    height: 30,
                                                                  ),
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                          const SizedBox(height: 15),
                                          Text(
                                            "Transaction History".tr,
                                            style: Typographyy.headLine.copyWith(
                                              color: textBlackColor,
                                              fontSize: 20,
                                            ),
                                          ),
                                          const SizedBox(height: 15),
                                          walletScreenController.historyData.payoutlist.isNotEmpty
                                              ? ListView.separated(
                                                  separatorBuilder: (context, index) {
                                                    return SizedBox(height: 15);
                                                  },
                                                  physics: NeverScrollableScrollPhysics(),
                                                  shrinkWrap: true,
                                                  itemBuilder: (context, index) {
                                                    return Stack(
                                                      clipBehavior: Clip.none,
                                                      alignment: Alignment.topLeft,
                                                      children: [
                                                        Container(
                                                          padding: EdgeInsets.all(12),
                                                          decoration: BoxDecoration(
                                                            borderRadius: BorderRadius.circular(12),
                                                            border: Border.all(
                                                              color: priMaryColor,
                                                            ),
                                                          ),
                                                          child: Column(
                                                            children: [
                                                              SizedBox(height: 20),
                                                              Table(
                                                                columnWidths: {
                                                                  0: FlexColumnWidth(0.6)
                                                                },
                                                                children: [
                                                                  TableRow(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical:2.0),
                                                                        child: Text(
                                                                          "Payout Id".tr,
                                                                          style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: textGreyColor,
                                                                            fontFamily: fontFamilyRegular,
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: RichText(
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                          text: TextSpan(
                                                                            children: [
                                                                              TextSpan(text: ": ", style: TextStyle(color: textGreyColor)),
                                                                              TextSpan(text: walletScreenController.historyData.payoutlist[index].payoutId, style: TextStyle(color: textBlackColor)),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  TableRow(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: Text(
                                                                          "Amount".tr,
                                                                          style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: textGreyColor,
                                                                            fontFamily: fontFamilyRegular,
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: RichText(
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                          text: TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: ": ",
                                                                                style: TextStyle(color: textGreyColor),
                                                                              ),
                                                                              TextSpan(
                                                                                text: "${walletScreenController.currency}${walletScreenController.historyData.payoutlist[index].amt}",
                                                                                style: TextStyle(color: textBlackColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  TableRow(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: Text(
                                                                          "Pay by".tr,
                                                                          style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: textGreyColor,
                                                                            fontFamily: fontFamilyRegular,
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: RichText(
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                          text: TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: ": ",
                                                                                style: TextStyle(color: textGreyColor),
                                                                              ),
                                                                              TextSpan(
                                                                                text: walletScreenController.historyData.payoutlist[index].rType,
                                                                                style: TextStyle(color: textBlackColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  TableRow(
                                                                    children: [
                                                                      Padding(
                                                                        padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: Text(
                                                                          "Request Date".tr,
                                                                          style: TextStyle(
                                                                            fontSize: 14,
                                                                            color: textGreyColor,
                                                                            fontFamily: fontFamilyRegular,
                                                                            fontWeight: FontWeight.w500,
                                                                          ),
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                        ),
                                                                      ),
                                                                      Padding(
                                                                        padding: EdgeInsets.symmetric(vertical: 2.0),
                                                                        child: RichText(
                                                                          overflow: TextOverflow.ellipsis,
                                                                          maxLines: 1,
                                                                          text: TextSpan(
                                                                            children: [
                                                                              TextSpan(
                                                                                text: ": ",
                                                                                style: TextStyle(color: textGreyColor),
                                                                              ),
                                                                              TextSpan(
                                                                                text: walletScreenController.historyData.payoutlist[index].rDate.toString().split(".").first,
                                                                                style: TextStyle(color: textBlackColor),
                                                                              ),
                                                                            ],
                                                                          ),
                                                                        ),
                                                                      ),
                                                                    ],
                                                                  ),
                                                                  walletScreenController.historyData.payoutlist[index].proof.isEmpty
                                                                      ? const TableRow(
                                                                          children: [
                                                                            SizedBox(),
                                                                            SizedBox(),
                                                                          ],
                                                                        )
                                                                      : TableRow(
                                                                          children: [
                                                                            Padding(
                                                                              padding: const EdgeInsets.symmetric(vertical: 2.0),
                                                                              child: Text("Proof".tr, style: TextStyle(fontSize: 14, color: textGreyColor, fontFamily: fontFamilyRegular, fontWeight: FontWeight.w500), overflow: TextOverflow.ellipsis, maxLines: 1),
                                                                            ),
                                                                            Image.network(
                                                                              "$basUrl${walletScreenController.historyData.payoutlist[index].proof}",
                                                                              height: 80,
                                                                              width: 80,
                                                                            )
                                                                          ],
                                                                        ),
                                                                ],
                                                              )
                                                            ],
                                                          ),
                                                        ),
                                                        Container(
                                                          height: 20,
                                                          width: 120,
                                                          decoration: BoxDecoration(
                                                            color: priMaryColor,
                                                            borderRadius: BorderRadius.only(
                                                              topLeft: Radius.circular(12),
                                                              bottomRight: Radius.circular(12),
                                                            ),
                                                          ),
                                                          child: Center(
                                                            child: Text(
                                                              walletScreenController.historyData.payoutlist[index].status,
                                                              style: TextStyle(
                                                                color: Colors.white,
                                                              ),
                                                            ),
                                                          ),
                                                        ),
                                                      ],
                                                    );
                                                  },
                                                  itemCount: walletScreenController.historyData.payoutlist.length,
                                                )
                                              : Column(
                                                  mainAxisAlignment: MainAxisAlignment.center,
                                                  children: [
                                                    SizedBox(height: 20),
                                                    SvgPicture.asset("assets/image/54.svg"),
                                                    SizedBox(height: 8),
                                                    Text(
                                                      "You haven't made any transaction using wallet yet".tr,
                                                      style: TextStyle(
                                                        fontSize: 16,
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
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            walletScreenController.isLoading
                                ? const CircularProgressIndicator()
                                : const SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
          ),
        );
      },
    );
  }

  Widget upi() {
    return TextField(
      controller: upicontroller,
      style: TextStyle(
        fontSize: 14,
        color: textBlackColor,
        fontFamily: fontFamilyRegular,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "UPI".tr,
        hintStyle: TextStyle(
          fontSize: 14,
          color: textGreyColor,
          fontFamily: fontFamilyRegular,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.all(15),
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
      ),
    );
  }

  Widget bank() {
    return Column(
      children: [
        TextField(
          controller: bankName,
          style: TextStyle(
            fontSize: 14,
            color: textBlackColor,
            fontFamily: fontFamilyRegular,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Bank name".tr,
            hintStyle: TextStyle(
              fontSize: 14,
              color: textGreyColor,
              fontFamily: fontFamilyRegular,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.all(15),
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
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: accNumber,
          style: TextStyle(
            fontSize: 14,
            color: textBlackColor,
            fontFamily: fontFamilyRegular,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Account number".tr,
            hintStyle: TextStyle(
              fontSize: 14,
              color: textGreyColor,
              fontFamily: fontFamilyRegular,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.all(15),
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
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: accName,
          style: TextStyle(
            fontSize: 14,
            color: textBlackColor,
            fontFamily: fontFamilyRegular,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Account holder name".tr,
            hintStyle: TextStyle(
              fontSize: 14,
              color: textGreyColor,
              fontFamily: fontFamilyRegular,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.all(15),
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
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: ifsc,
          style: TextStyle(
            fontSize: 14,
            color: textBlackColor,
            fontFamily: fontFamilyRegular,
            fontWeight: FontWeight.w500,
          ),
          decoration: InputDecoration(
            hintText: "Account IFSC".tr,
            hintStyle: TextStyle(
              fontSize: 14,
              color: textGreyColor,
              fontFamily: fontFamilyRegular,
              fontWeight: FontWeight.w500,
            ),
            contentPadding: const EdgeInsets.all(15),
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
          ),
        ),
      ],
    );
  }

  deocderesponse(value) {
    var decode = value;

    if (decode["Result"] == "true") {
      Get.back();
      walletScreenController.fetChDataFromApi();
      if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
        showCommonToast(decode["ResponseMsg"]);
      }
    } else {
      Get.back();
      if ((decode["ResponseMsg"] ?? "").trim().isNotEmpty) {
        showCommonToast(decode["ResponseMsg"]);
      }
    }
  }

  Widget paypal() {
    return TextField(
      controller: paypalcontroller,
      style: TextStyle(
        fontSize: 14,
        color: textBlackColor,
        fontFamily: fontFamilyRegular,
        fontWeight: FontWeight.w500,
      ),
      decoration: InputDecoration(
        hintText: "Paypal".tr,
        hintStyle: TextStyle(
          fontSize: 14,
          color: textGreyColor,
          fontFamily: fontFamilyRegular,
          fontWeight: FontWeight.w500,
        ),
        contentPadding: const EdgeInsets.all(15),
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
      ),
    );
  }
}

enum SingingCharacter { upi, bankTransfer, paypal, emty }
