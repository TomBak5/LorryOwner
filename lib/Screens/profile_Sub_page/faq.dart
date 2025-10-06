// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:truckbuddy/models/faq_model.dart';

import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../Controllers/homepage_controller.dart';

class Faq extends StatefulWidget {
  const Faq({super.key});

  @override
  State<Faq> createState() => _FaqState();
}

class _FaqState extends State<Faq> {
  late FaqModel data;
  bool isLoading = true;

  HomePageController homePageController = Get.put(HomePageController());
  @override
  void initState() {
    super.initState();
    ApiProvider().faq(uid: homePageController.userData?.id ?? '').then((value) {
      setState(() {
        data = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
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
          "Faq".tr,
          style: TextStyle(
            fontSize: 18,
            fontFamily: fontFamilyBold,
            fontWeight: FontWeight.w500,
            color: textBlackColor,
          ),
        ),
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ListView.separated(
                    physics: const NeverScrollableScrollPhysics(),
                    shrinkWrap: true,
                    itemBuilder: (context, index) {
                      return ExpansionTile(
                        title: Text(data.faqData[index].question),
                        children: [
                          Padding(
                            padding: EdgeInsets.symmetric(horizontal: 15),
                            child: Text(data.faqData[index].answer),
                          ),
                        ],
                      );
                    },
                    separatorBuilder: (context, index) {
                      return const SizedBox(height: 10);
                    },
                    itemCount: data.faqData.length,
                  )
                ],
              ),
            ),
    );
  }
}
