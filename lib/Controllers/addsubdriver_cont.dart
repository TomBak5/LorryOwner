import 'package:flutter/cupertino.dart';
import 'package:get/get.dart';
import 'package:movers_lorry_owner/Api_Provider/api_provider.dart';
import 'package:movers_lorry_owner/Screens/sub_pages/subdrivers.dart';
import 'package:movers_lorry_owner/firebase/auth_services.dart';
import 'package:movers_lorry_owner/models/lorrylistmodel.dart';
import 'package:movers_lorry_owner/models/subdriverlist_model.dart';
import 'package:movers_lorry_owner/widgets/widgets.dart';

class AddSubdriverController extends GetxController implements GetxService {

  String? editeTitle;
  TextEditingController name = TextEditingController();
  TextEditingController email = TextEditingController();
  TextEditingController password = TextEditingController();
  TextEditingController phone = TextEditingController();
  String ccode = "+91";
  String lorryId = "Select Lorry";
  String lorryNo = "Select Lorry";
  String subdId = "";

  bool isShowPassword = true;

  setShowPassword() {
    isShowPassword = !isShowPassword;
    update();
  }

  AuthServices authServices = AuthServices();

  bool setSdriverLoad = false;
  Future addSubdriver({ownerId}) async {
    Map body = {
      "owner_id": ownerId,
      "lorry_id": lorryId,
      "name": name.text,
      "email": email.text,
      "password": password.text,
      "phone": phone.text,
      "ccode": ccode
    };
    print("SUBDRIVER BODY $body");
    setSdriverLoad = true;
    update();
    try {
      ApiProvider().getAddsubdriver(body: body, url: "add_sub_driver.php").then((value) {
        if(value["Result"] == "true"){
          authServices.setSubdriverData(ownerId: ownerId, lat: "0", long: "0", lorryId: lorryId, subdriverId: value["sub_driver_id"].toString());
          if ((value["ResponseMsg"] ?? "").trim().isNotEmpty) {
            showCommonToast(value["ResponseMsg"]);
          }
          setSdriverLoad = false;
          update();
          Get.back();
        } else {
          setSdriverLoad = false;
          update();
          if ((value["ResponseMsg"] ?? "").trim().isNotEmpty) {
            showCommonToast(value["ResponseMsg"]);
          }
        }
      },);
    } catch (e) {
      setSdriverLoad = false;
      update();
    }
  }

  Future editSubdriver({ownerId}) async {
    Map body = {
      "owner_id": ownerId,
      "lorry_id": lorryId,
      "name": name.text,
      "email": email.text,
      "password": password.text,
      "phone": phone.text,
      "ccode": ccode,
      "id": subdId
    };

    print("SUBDRIVER BODY $body");
    setSdriverLoad = true;
    update();
    try {
      ApiProvider().getAddsubdriver(body: body, url: "edit_sub_driver.php").then((value) {
        if(value["Result"] == "true"){
          authServices.setSubdriverData(ownerId: ownerId, lat: "0", long: "0", lorryId: lorryId, subdriverId: value["UserProfile"]["id"]);
          if ((value["ResponseMsg"] ?? "").trim().isNotEmpty) {
            showCommonToast(value["ResponseMsg"]);
          }
          setSdriverLoad = false;
          update();
          Get.back();
        } else {
          setSdriverLoad = false;
          update();
          if ((value["ResponseMsg"] ?? "").trim().isNotEmpty) {
            showCommonToast(value["ResponseMsg"]);
          }
        }
      },);
    } catch (e) {
      setSdriverLoad = false;
      update();
    }
  }

  bool isLorryloading = true;
  LorrylistModel? lorryData;
  Future getLorrylist({uid, isEdit}) async {
    try {
          print("LOOOAOAOAOAOAOAO $uid");
      ApiProvider().getLorrylist(uid: uid).then((value) {
        if(value["Result"] == "true"){
          lorryData = LorrylistModel.fromJson(value);
          if (!isEdit) {
          if (lorryData!.bidLorryData!.isNotEmpty) {
            lorryNo = lorryData!.bidLorryData![0].lorryNo ?? "";
            lorryId = lorryData!.bidLorryData![0].lorryId ?? "";
          }
          isLorryloading = false;
          } else {
           isLorryloading = false;
          }
          update();
        } else {
          isLorryloading = false;
          update();
        }
      },);
    } catch (e) {
      isLorryloading = false;
      update();
    }
  }

  SubdriverlistModel? subdriverlistData;
  bool isSubdriverLoad = false;

  Future getSubdriverlist({uid}) async {
    isSubdriverLoad = true;
    update();
    print("USER ID $uid");
    try {
      ApiProvider().getSubdriverlist(uid: uid).then((value) {
        if(value["Result"] == "true"){
          subdriverlistData = SubdriverlistModel.fromJson(value);
          isSubdriverLoad = false;
          update();
        } else {
          isSubdriverLoad = false;
          update();
        }
      },);
    } catch (e) {
      isSubdriverLoad = false;
      update();
    }
  }
}