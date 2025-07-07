import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Api_Provider/imageupload_api.dart';
import 'package:movers_lorry_owner/Controllers/addsubdriver_cont.dart';
import 'package:movers_lorry_owner/Controllers/homepage_controller.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/addsubdriver.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';

class Subdrivers extends StatefulWidget {
  const Subdrivers({super.key});

  @override
  State<Subdrivers> createState() => _SubdriversState();
}

class _SubdriversState extends State<Subdrivers> {

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    addSubdriverCont.getSubdriverlist(uid: homePageCont.userData.id);
  }

  bool isLoading = true;
  List lorryList = [];
  List lorryImage = [];
  AddSubdriverController addSubdriverCont = Get.put(AddSubdriverController());
  HomePageController homePageCont = Get.put(HomePageController());

  Future getRemove() async {
    addSubdriverCont.ccode = "+91";
    addSubdriverCont.subdId = "";
    addSubdriverCont.lorryNo = "";
    addSubdriverCont.lorryId = "";
    addSubdriverCont.name.text = "";
    addSubdriverCont.phone.text = "";
    addSubdriverCont.password.text = "";
    addSubdriverCont.email.text = "";
  }
  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: (() async => true),
      child: Scaffold(
        appBar: AppBar(
          elevation: 0,
          backgroundColor: priMaryColor,
          centerTitle: true,
          title: Text(
            "Subdriver".tr,
            style: TextStyle(
              fontSize: 18,
              fontFamily: fontFamilyBold,
              fontWeight: FontWeight.w500,
            ),
          ),
          actions: [
            InkWell(
              onTap: () {
               getRemove().then((value) {
                Get.to(Addsubdriver(isEdit: false,));
               },);
              },
                child: Container(
                  decoration: BoxDecoration(
                    border: Border.all(color: Colors.white),
                    shape: BoxShape.circle
                  ),
                    child: Icon(Icons.add, color: Colors.white, size: 30,))),
            SizedBox(width: 12,),
          ],
        ),
        body: RefreshIndicator(
          onRefresh: () {
            return Future.delayed(
              Duration(seconds: 1),
                  () {
                addSubdriverCont.getSubdriverlist(uid: homePageCont.userData.id);
              },
            );
          },
          child: GetBuilder<AddSubdriverController>(
            builder: (addSubdriverCont) {
              return  addSubdriverCont.isSubdriverLoad ? Center(child: CircularProgressIndicator()) : SingleChildScrollView(
                child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
                          addSubdriverCont.subdriverlistData!.subDriverList!.isEmpty ? Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              SizedBox(height: 150,),
                              SvgPicture.asset("assets/image/54.svg"),
                              SizedBox(height: 8),
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
                              SizedBox(height: 150,),
                            ],
                          ) : ListView.separated(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemCount: addSubdriverCont.subdriverlistData!.subDriverList!.length,
                            separatorBuilder: (context, index) {
                              return SizedBox(height: 10,);
                            },
                            itemBuilder: (context, index) {
                              return Container(
                                padding: const EdgeInsets.all(12),
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(12),
                                  border: Border.all(color: Colors.grey.withOpacity(0.3)),
                                ),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(addSubdriverCont.subdriverlistData!.subDriverList![index].name ?? "", style: TextStyle(fontSize: 18, fontFamily: fontFamilyBold), overflow: TextOverflow.ellipsis, maxLines: 1,),
                                        SizedBox(height: 2,),
                                        Row(
                                          children: [
                                            Image.asset(
                                              "assets/icons/phone.png",
                                              width: 20,
                                              height: 20,
                                              color: secondaryColor,
                                            ),
                                            Text(
                                              "${addSubdriverCont.subdriverlistData!.subDriverList![index].ccode}${addSubdriverCont.subdriverlistData!.subDriverList![index].phone}",
                                              style: TextStyle(fontSize: 14, fontFamily: fontFamilyRegular),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                            ),
                                          ],
                                        ),
                                        SizedBox(height: 2,),
                                        Row(
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            SvgPicture.asset(
                                              "assets/icons/ic_bookedlorries_bottom.svg",
                                              width: 20,
                                              height: 20,
                                              color: secondaryColor,
                                            ),
                                            SizedBox(width: 5,),
                                            Text(
                                              addSubdriverCont.subdriverlistData!.subDriverList![index].lorryNo ?? "",
                                              style: TextStyle(fontSize: 14, fontFamily: fontFamilyRegular),
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              textAlign: TextAlign.end,
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                    InkWell(
                                      onTap: () {

                                        addSubdriverCont.ccode = addSubdriverCont.subdriverlistData!.subDriverList![index].ccode ?? "";
                                        addSubdriverCont.subdId = addSubdriverCont.subdriverlistData!.subDriverList![index].id ?? "";
                                        addSubdriverCont.lorryNo = addSubdriverCont.subdriverlistData!.subDriverList![index].lorryNo ?? "";
                                        addSubdriverCont.lorryId = addSubdriverCont.subdriverlistData!.subDriverList![index].lorryId ?? "";
                                        addSubdriverCont.name.text = addSubdriverCont.subdriverlistData!.subDriverList![index].name ?? "";
                                        addSubdriverCont.phone.text = addSubdriverCont.subdriverlistData!.subDriverList![index].phone ?? "";
                                        addSubdriverCont.password.text = addSubdriverCont.subdriverlistData!.subDriverList![index].password ?? "";
                                        addSubdriverCont.email.text = addSubdriverCont.subdriverlistData!.subDriverList![index].email ?? "";

                                        Get.to(Addsubdriver(isEdit: true,));
                                      },
                                      child: CircleAvatar(
                                        backgroundColor: priMaryColor,
                                        radius: 20,
                                        child: Center(
                                          child: SvgPicture.asset(
                                            "assets/icons/edit-2.svg",
                                            color: Colors.white,
                                            height: 22,
                                            width: 22,
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              );
                            },),
                        ],
                      ),
                    ),
              );
          },),
        ),
      ),
    );
  }
}
