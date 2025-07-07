// ignore_for_file: deprecated_member_use

import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';

import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';

import '../../AppConstData/typographyy.dart';
import '../../models/privacy_policy_model.dart';

import 'package:flutter_html/flutter_html.dart';

class ContactUs extends StatefulWidget {
  const ContactUs({super.key});

  @override
  State<ContactUs> createState() => _ContactUsState();
}

class _ContactUsState extends State<ContactUs> {
  late PrivacyPolicyModel data;
  bool isLoading = true;
  @override
  void initState() {
    super.initState();
    ApiProvider().privacyPolicy().then((value) {
      setState(() {
        data = value;
        isLoading = false;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return isLoading
        ? const Scaffold(
            body: Center(child: CircularProgressIndicator()),
          )
        : Scaffold(
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
                data.pagelist[2].title.tr,
                style: TextStyle(
                  fontSize: 18,
                  fontFamily: fontFamilyBold,
                  fontWeight: FontWeight.w500,
                  color: textBlackColor,
                ),
              ),
            ),
            body: SingleChildScrollView(
              child: Column(
                children: [
                  Html(
                    data: data.pagelist[2].description,
                    style: {
                      // tables will have the below background color
                      "body": Style(
                        lineHeight: const LineHeight(0),
                        margin: Margins.all(15),
                        padding: HtmlPaddings.all(0),
                      ),

                      // text that renders h1 elements will be red
                      "p": Style(
                        padding: HtmlPaddings.all(0),
                        lineHeight: LineHeight.percent(0.0),
                        margin: Margins.all(0),
                      ),
                      "br": Style(
                        padding: HtmlPaddings.all(0),
                        lineHeight: LineHeight.percent(0.0),
                        margin: Margins.all(0),
                      ),
                    },
                  ),
                ],
              ),
            ),
          );
  }
}
