import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Controllers/addsubdriver_cont.dart';
import 'package:movers_lorry_owner/Controllers/homepage_controller.dart';

import '../../Api_Provider/api_provider.dart';
import '../../AppConstData/app_colors.dart';
import '../../AppConstData/typographyy.dart';
import '../../models/contry_code_model.dart';
import '../../widgets/widgets.dart';

class Addsubdriver extends StatefulWidget {
  final bool isEdit;
  const Addsubdriver({super.key, required this.isEdit});

  @override
  State<Addsubdriver> createState() => _AddsubdriverState();
}

class _AddsubdriverState extends State<Addsubdriver> {

  AddSubdriverController addSubdriverCont = Get.put(AddSubdriverController());
  HomePageController homePageCont = Get.put(HomePageController());

  late ContryCodeModel countryCodeList;

  String countryCode = '+91';

  @override
  void initState() {
    // TODO: implement initState
    super.initState();
    setState(() {
      isEdit = widget.isEdit;
    addSubdriverCont.setSdriverLoad = false;
    });
    addSubdriverCont.getLorrylist(uid: homePageCont.userData?.id ?? '', isEdit: isEdit);
    ApiProvider().getCountryCode().then((value) {
      setState(() {
        countryCodeList = value;
        isloading = false;
      });
    });
  }

  bool isEdit = false;
  String selectedLorry = "";

  bool isloading = true;

  final _formKey = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return isloading
        ? Scaffold(body: Center(child: CircularProgressIndicator()))
        : WillPopScope(
      onWillPop: (() async => true),
          child: Scaffold(
           backgroundColor: Colors.white,
           appBar: AppBar(
           elevation: 0,
           backgroundColor: priMaryColor,
           centerTitle: true,
           title: Text(
            addSubdriverCont.editeTitle ?? "Add Subdriver".tr,
            style: TextStyle(
              fontSize: 18,
              fontFamily: fontFamilyBold,
              fontWeight: FontWeight.w500,
            ),
          ),
                ),
                body: Form(
          key: _formKey,
          child: GetBuilder<AddSubdriverController>(
            builder: (addSubdriverCont) {
              return addSubdriverCont.isLorryloading ? Center(child: CircularProgressIndicator()) : Stack(
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
                      )
                    ],
                  ),
                  Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: SingleChildScrollView(
                      child: Column(
                        children: [
                          const SizedBox(height: 12),
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
                            child: addSubdriverCont.lorryData!.bidLorryData!.isEmpty ? Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                SizedBox(height: 150,),
                                SvgPicture.asset("assets/image/54.svg"),
                                SizedBox(height: 8),
                                Text(
                                  "No lorry added yet! Currently You Don't Have Any lorry please add your lorry first!".tr,
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
                            ) : Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  "Select your lorry".tr,
                                  style: TextStyle(
                                      color: textBlackColor,
                                      fontFamily: "fontFamilyRegular",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField(
                                        menuMaxHeight: 300,
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please enter Lorry!";
                                          }
                                          return null;
                                        },
                                        decoration: InputDecoration(
                                          hintText: isEdit ? addSubdriverCont.lorryNo : 'Select Lorry',
                                          contentPadding: EdgeInsets.all(12),
                                          hintStyle: TextStyle(fontSize: 14),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                        dropdownColor: Colors.white,
                                        onChanged: (newValue) {

                                        },
                                        value: addSubdriverCont.lorryNo,
                                        items: addSubdriverCont.lorryData!.bidLorryData!.map<DropdownMenuItem>((m) {
                                          return DropdownMenuItem(
                                            onTap: () {
                                              setState(() {
                                                addSubdriverCont.lorryId = m.lorryId!;
                                              });
                                            },
                                            value: "${m.lorryNo}",
                                            child: Text("${m.lorryTitle}(${m.lorryNo})"),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(height: 20,),
                                Text(
                                  "Name".tr,
                                   style: TextStyle(
                                   color: textBlackColor,
                                   fontFamily: "fontFamilyRegular",
                                   fontSize: 14,
                                   fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter mobile name!";
                                    }
                                    return null;
                                  },
                                  controller: addSubdriverCont.name,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: fontFamilyRegular,
                                    color: textBlackColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter Name".tr,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    hintStyle: TextStyle(
                                      fontSize: 17,
                                      fontFamily: fontFamilyRegular,
                                      color: textGreyColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Email".tr,
                                  style: TextStyle(
                                      color: textBlackColor,
                                      fontFamily: "fontFamilyRegular",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter mobile email!";
                                    }
                                    return null;
                                  },
                                  controller: addSubdriverCont.email,
                                  style: TextStyle(
                                    fontSize: 17,
                                    fontFamily: fontFamilyRegular,
                                    color: textBlackColor,
                                  ),
                                  decoration: InputDecoration(
                                    hintText: "Enter Email".tr,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    hintStyle: TextStyle(
                                      fontSize: 17,
                                      fontFamily: fontFamilyRegular,
                                      color: textGreyColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Mobile number".tr,
                                  style: TextStyle(
                                    color: textBlackColor,
                                    fontFamily: "fontFamilyRegular",
                                    fontSize: 14,
                                    fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Row(
                                  children: [
                                    Expanded(
                                      child: DropdownButtonFormField(
                                        menuMaxHeight: 300,
                                        decoration: InputDecoration(
                                          hintText: 'Code',
                                          contentPadding: EdgeInsets.all(12),
                                          hintStyle: TextStyle(fontSize: 14),
                                          border: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: textGreyColor),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: textGreyColor),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide(color: textGreyColor),
                                          ),
                                          focusedBorder: OutlineInputBorder(
                                            borderRadius: BorderRadius.circular(12),
                                            borderSide: BorderSide( color: textGreyColor),
                                          ),
                                        ),
                                        dropdownColor: Colors.white,
                                        onChanged: (newValue) {
                                          setState(() {
                                            countryCode = newValue!;
                                          });
                                        },
                                        value: countryCodeList.countryCode.any((m) => m.ccode == countryCode) ? countryCode : null,
                                        items: countryCodeList.countryCode.map<DropdownMenuItem>((m) {
                                          return DropdownMenuItem(
                                            value: m.ccode,
                                            child: Text(m.ccode),
                                          );
                                        }).toList(),
                                      ),
                                    ),
                                    const SizedBox(width: 8),
                                    Expanded(
                                      flex: 2,
                                      child: TextFormField(
                                        validator: (value) {
                                          if (value == null || value.isEmpty) {
                                            return "Please enter mobile number!";
                                          }
                                          return null;
                                        },
                                        controller: addSubdriverCont.phone,
                                        style: TextStyle(
                                          fontSize: 17,
                                          fontFamily: fontFamilyRegular,
                                          color: textBlackColor,
                                        ),
                                        decoration: InputDecoration(
                                          hintText: "Enter Mobile Number".tr,
                                          contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                          hintStyle: TextStyle(
                                            fontSize: 17,
                                            fontFamily: fontFamilyRegular,
                                            color: textGreyColor,
                                          ),
                                          border: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          disabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                          enabledBorder: OutlineInputBorder(
                                            borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                            borderRadius: BorderRadius.circular(10),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 20),
                                Text(
                                  "Password".tr,
                                  style: TextStyle(
                                      color: textBlackColor,
                                      fontFamily: "fontFamilyRegular",
                                      fontSize: 14,
                                      fontWeight: FontWeight.w500
                                  ),
                                ),
                                const SizedBox(height: 8),
                                TextFormField(
                                  obscureText: addSubdriverCont.isShowPassword,
                                  controller: addSubdriverCont.password,
                                  validator: (value) {
                                    if (value == null || value.isEmpty) {
                                      return "Please enter password!";
                                    }
                                    return null;
                                  },
                                  decoration: InputDecoration(
                                    suffixIcon: SizedBox(
                                      width: 20,
                                      height: 20,
                                      child: Center(
                                        child: InkWell(
                                          onTap: () {
                                            addSubdriverCont.setShowPassword();
                                          },
                                          child: SvgPicture.asset(
                                            addSubdriverCont
                                                .isShowPassword
                                                ? "assets/icons/eye-off.svg"
                                                : "assets/icons/eye-2.svg",
                                            height: 20,
                                            width: 20,
                                            color: textGreyColor,
                                          ),
                                        ),
                                      ),
                                    ),
                                    hintText: "Enter Password".tr,
                                    contentPadding: EdgeInsets.symmetric(vertical: 16, horizontal: 16),
                                    hintStyle: TextStyle(
                                      fontSize: 17,
                                      fontFamily: fontFamilyRegular,
                                      color: textGreyColor,
                                    ),
                                    border: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    disabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    enabledBorder: OutlineInputBorder(
                                      borderSide: BorderSide(color: Colors.grey.withOpacity(0.3)),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 20),
                                Row(
                                  children: [
                                    Expanded(
                                      child: commonButton(
                                        title: "Next".tr,
                                        onTapp: () {
                                          if (_formKey.currentState!.validate()) {
                                            isEdit ? addSubdriverCont.editSubdriver(ownerId: homePageCont.userData?.id ?? '').then((value) {
                                              addSubdriverCont.getSubdriverlist(uid: homePageCont.userData?.id ?? '');
                                            },) : addSubdriverCont.addSubdriver(ownerId: homePageCont.userData?.id ?? '').then((value) {
                                              addSubdriverCont.getSubdriverlist(uid: homePageCont.userData?.id ?? '');
                                            },);
                                          }
                                        },
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  addSubdriverCont.setSdriverLoad ? Center(child: CircularProgressIndicator()) : SizedBox()
                ],
              );
            }
          ),
                ),
              ),
        );
  }
}
