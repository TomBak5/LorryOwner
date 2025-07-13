// ignore_for_file: deprecated_member_use

import 'dart:convert';
import 'dart:developer';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../Api_Provider/dio_api.dart';
import '../models/bookdetiles_model.dart';
import '../models/contry_code_model.dart';
import '../models/earning_model.dart';
import '../models/faq_model.dart';
import '../models/lorry_list_model.dart';
import '../models/myloads_detils_model.dart';
import '../models/myloads_model.dart';
import '../models/near_load_model.dart';
import '../models/notification_model.dart';
import '../models/review_model.dart';
import '../models/statelist_model.dart';
import '../models/transaction_model.dart';
import '../models/transport_profile_model.dart';
import '../models/privacy_policy_model.dart';
import '../widgets/widgets.dart';
import 'package:http/http.dart' as http;

String googleMapkey = "AIzaSyAVOjpp1c4YXhmfO06ch3CurcxJBUgbyAw";

class ApiProvider {
  final api = Api();
  Map<String, String> header = {'Content-Type': 'application/json', 'X-API-KEY': 'cscodetech'};
  String basUrlApi = "http://truckbuddy.sprendimai.ai/Api/";

//!- - - - - country_code - - - - - !//
  Future<ContryCodeModel> getCountryCode() async {
    debugPrint("======url=== ${basUrlApi}country_code.php");
    var response = await api.sendRequest.get(
      "${basUrlApi}country_code.php",
      options: Options(headers: header),
    );
    return ContryCodeModel.fromJson(response.data);
  }


//?- - - - - Mobile Check - - - - - !//
  Future checkMobileNumber(
      {required String number, required String code}) async {
    Map body = {"mobile": number, "ccode": code};
    final response = await api.sendRequest.post(
      "${basUrlApi}mobile_check.php",
      data: body,
    );
    debugPrint("============ mobile check url ========== ${basUrlApi}mobile_check.php");
    debugPrint("============ mobile check body ========= ${body}");
    debugPrint("========== mobile check response ======= ${response.data}");
    var datas = response.data;
    return datas;
  }

//?- - - - - send otp - - - - - !//
  Future send_otp({required String number/*, required String code*/}) async {
    Map body = {"mobile": number};
    final response = await api.sendRequest.post(
      "${basUrlApi}send_otp.php",
      data: body,
    );

    debugPrint("========= sendOtp body ========= ${body}");
    debugPrint("======= sendOtp response ======= ${response.data}");
    var datas = response.data;
    return datas;
  }

//!- - - - - Login User - - - - - !//90
  Future loginUser(
      {required String number,
      required String code,
      required String password}) async {
    Map body = {"mobile": number, "ccode": code, "password": password};

    var response = await api.sendRequest.post(
      "${basUrlApi}login_user.php",
      data: body,
    );
    debugPrint("============ Login body ========= ${body}");
    debugPrint("========== Login response ======= ${response.data}");
    return response.data;
  }

  // Email/password login for new UI
  Future loginUserWithEmail({required String email, required String password}) async {
    Map body = {"mobile": email, "password": password};
    var response = await api.sendRequest.post(
      "${basUrlApi}login_user.php",
      data: body,
    );
    debugPrint("============ Login (email) body ========= $body");
    debugPrint("========== Login (email) response ======= ${response.data}");
    return response.data;
  }

//?- - - - - Forget Password - - - - - !//
  Future forgetPassword(
      {required String mobile,
      required String password,
      required String ccode}) async {
    Map body = {"mobile": mobile, "password": password, "ccode": ccode};
    log("Api-------$body");
    var response = await api.sendRequest.post(
      "${basUrlApi}forget_password.php",
      data: body,
    );

    log(response.data);
    return response.data;
  }

//!- - - - - Register User - - - - - !//
  Future registerUser({
    required String name,
    required String mobile,
    required String cCode,
    required String email,
    required String password,
    required String referCode,
    required String userRole,
    String? company,
    String? emergencyContact,
    List<Map<String, dynamic>>? linkedDrivers,
  }) async {
    Map body = {
      "name": name,
      "mobile": mobile,
      "ccode": cCode,
      "email": email,
      "password": password,
      "refercode": referCode,
      "user_role": userRole,
    };
    if (company != null && company.isNotEmpty) {
      body["company"] = company;
    }
    if (emergencyContact != null && emergencyContact.isNotEmpty) {
      body["emergency_contact"] = emergencyContact;
    }
    if (linkedDrivers != null && linkedDrivers.isNotEmpty) {
      body["linked_drivers"] = linkedDrivers.map((d) => d['id']).toList();
    }

    try {
      var respons = await api.sendRequest.post(
        "${basUrlApi}reg_user.php",
        data: body,
        options: Options(headers: header),
      );
      // Print/log the raw response for debugging
      debugPrint('Raw reg_user.php response:');
      debugPrint(respons.data.toString());
      if (respons.data == null || respons.data.toString().trim().isEmpty) {
        debugPrint('Empty response from reg_user.php');
        return {'error': 'Empty response from server'};
      }
      try {
        if (respons.data is Map) return respons.data;
        return jsonDecode(respons.data);
      } catch (e) {
        debugPrint('Failed to parse JSON from reg_user.php: $e');
        return {'error': 'Invalid JSON from server', 'raw': respons.data};
      }
    } catch (e, stack) {
      debugPrint('Dio error in registerUser: $e');
      if (e is DioError) {
        debugPrint('DioError type: \\${e.type}');
        debugPrint('DioError response: \\${e.response}');
        debugPrint('DioError data: \\${e.response?.data}');
        debugPrint('DioError request: \\${e.requestOptions}');
      }
      debugPrint('Stack trace: $stack');
      return {'error': 'Dio error', 'exception': e.toString()};
    }
  }

//?- - - - - Edit Profile - - - - - !//
  Future editProfile(
      {required String name, required String pass, required String uid}) async {
    Map body = {"name": name, "password": pass, "uid": uid};
    var response = await api.sendRequest.post(
      "${basUrlApi}profile_edit.php",
      data: body,
    );

    debugPrint("========= register User body ========= ${body}");
    debugPrint("======= register User response ======= ${response.data}");

    return response.data;
  }

//!- - - - - Faq - - - - - !//
  Future<FaqModel> faq({required String uid}) async {
    var response = await api.sendRequest
        .post("${basUrlApi}faq.php", data: jsonEncode({"uid": uid}));

    return FaqModel.fromJson(response.data);
  }

//?- - - - - HomePage Api - - - - - !//
  Future homePageApi({required String uid}) async {
    Map body = {"owner_id": uid};
    try {
      var response = await api.sendRequest.post(
        "${basUrlApi}home_page.php",
        data: jsonEncode(body),
      );
      debugPrint('Raw home_page.php response:');
      debugPrint(response.data.toString());
      if (response.data == null || response.data.toString().trim().isEmpty) {
        debugPrint('Empty response from home_page.php');
        return {'error': 'Empty response from server'};
      }
      try {
        if (response.data is Map) return response.data;
        return jsonDecode(response.data);
      } catch (e) {
        debugPrint('Failed to parse JSON from home_page.php: $e');
        return {'error': 'Invalid JSON from server', 'raw': response.data};
      }
    } catch (e, stack) {
      debugPrint('Dio error in homePageApi: $e');
      if (e is DioError) {
        debugPrint('DioError type: \\${e.type}');
        debugPrint('DioError response: \\${e.response}');
        debugPrint('DioError data: \\${e.response?.data}');
        debugPrint('DioError request: \\${e.requestOptions}');
      }
      debugPrint('Stack trace: $stack');
      return {'error': 'Dio error', 'exception': e.toString()};
    }
  }

//!- - - - - Privacy Policy - - - - - !//
  Future<PrivacyPolicyModel> privacyPolicy() async {
    var response = await api.sendRequest.get("${basUrlApi}pagelist.php");
    return PrivacyPolicyModel.fromJson(response.data);
  }

//?- - - - - Lorry List - - - - - !//
  bool? isVerfied;
  Future getLorryList(
      {required String ownerId, required String loadId}) async {
    Map body = {"owner_id": ownerId, "load_id": loadId};

    print("BID LORYY ${body}");
    var response = await api.sendRequest.post(
      "${basUrlApi}lorry_list.php",
      data: jsonEncode(body),
    );
    var data = response.data;
    if(data["Result"] == "false"){
      if ((data["ResponseMsg"] ?? "").trim().isNotEmpty) {
        showCommonToast(data["ResponseMsg"]);
      }
      return data;
    } else {
      print("RESPONSE DATA  ${response.data}");
     return data;
    }
  }

//!- - - - - Edit Image - - - - - !//
  Future editImage({required XFile image, required String uid}) async {
    String fileName = image.path.split('/').last;

    FormData data = FormData.fromMap({
      "image0": await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
      "size": "1",
      "owner_id": uid,
    });

    final response =
        await api.sendRequest.post("${basUrlApi}pro_image.php", data: data);
    return response.data;
  }

//?- - - - - Check State - - - - - !//
  Future checkStat(
      {required String pickUpName, required String dropStateName}) async {
    Map body = {
      "pick_state_name": pickUpName,
      "drop_state_name": dropStateName
    };

    var respons = await api.sendRequest.post(
      "${basUrlApi}getstateid.php",
      data: jsonEncode(body),
    );

    return respons.data;
  }

//!- - - - - Find Lorry - - - - - !//
  Future findLorry(
      {required String uid,
      required String pickStateId,
      required String dropStateId}) async {
    Map body = {
      "owner_id": uid,
      "pick_state_id": pickStateId,
      "drop_state_id": dropStateId
    };

    var respons = await api.sendRequest.post(
      "${basUrlApi}find_load.php",
      data: jsonEncode(body),
    );

    return respons.data;
  }

//?- - - - - BidNow Api - - - - - !//
  Future bidNowApi({
    required String ownerId,
    required String loadId,
    required String lorryId,
    required String amount,
    required String amtType,
    required String totalAmt,
    required String isImmediate,
    required String totalLoad,
    required String description,
  }) async {
    Map body = {
      "owner_id": ownerId,
      "load_id": loadId,
      "lorry_id": lorryId,
      "amount": amount,
      "amt_type": amtType,
      "total_amt": totalAmt,
      "is_immediate": isImmediate,
      "total_load": totalLoad,
      "description": description,
    };
    log("+-+-+-+-+ body +-+-+-+-+ $body");
    var response = await api.sendRequest.post(
      "${basUrlApi}bid_load.php",
      data: jsonEncode(body),
    );
    return response.data;
  }

//!- - - - - Delete Bid - - - - - !//
  Future deleteBid({required String ownerId, required String loadId}) async {
    Map body = {"owner_id": ownerId, "load_id": loadId};
    var response = await api.sendRequest.post(
      "${basUrlApi}delete_bid.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//?- - - - - TransProfile - - - - - !//
  Future transProfile({required String uid}) async {
    Map body = {"uid": uid};
    var response = await api.sendRequest.post(
      "${basUrlApi}trans_profile.php",
      data: jsonEncode(body),
    );

    return TransProfileModel.fromJson(response.data);
  }

//!- - - - - NearLoad - - - - - !//
  Future<NearLoadModel> nearLoad(
      {required String ownerid,
      required double lats,
      required double longs}) async {
    Map body = {"owner_id": ownerid, "lats": lats, "longs": longs};

    var response = await api.sendRequest.post(
      "${basUrlApi}near_load.php",
      data: jsonEncode(body),
    );
    return NearLoadModel.fromJson(response.data);
  }

//?- - - - - VehicleList - - - - - !//
  Future getVehicleList({required String uid}) async {
    var respons = await api.sendRequest.post(
      "${basUrlApi}vehicle_list.php",
      data: jsonEncode({
        "uid": uid,
      }),
    );

    return respons.data;
  }

//!- - - - - State List - - - - - !//
  Future<StateListModel> getstatList({required String ownerId}) async {
    Map body = {"owner_id": ownerId};
    var response = await api.sendRequest.post(
      // Use the correct path for statelist.php
      "http://truckbuddy.sprendimai.ai/lorry_api/statelist.php",
      data: jsonEncode(body),
    );
    return StateListModel.fromJson(response.data);
  }

//?- - - - - Add Lorry  - - - - - !//
  Future addLorry({
    required XFile image,
    required XFile image1,
    required String ownerId,
    required String lorryNo,
    required String widght,
    required String des,
    required String vehicleId,
    required String currentlocation,
    required String routes,
  }) async {
    String fileName = image.path.split('/').last;
    String file1Name = image1.path.split('/').last;

    FormData data = FormData.fromMap({
      "owner_id": ownerId,
      "lorry_no": lorryNo,
      "weight": widght,
      "description": des,
      "vehicle_id": vehicleId,
      "status": "1",
      "curr_location": currentlocation,
      "curr_state_id": "1",
      "routes": routes,
      "size": "2",
      "image0": await MultipartFile.fromFile(
        image.path,
        filename: fileName,
      ),
      "image1": await MultipartFile.fromFile(
        image1.path,
        filename: file1Name,
      )
    });

    print("JSON BOIDY $data");
    var respons = await api.sendRequest.post("${basUrlApi}add_lorry.php",
      data: data,
    );

    return respons.data;
  }

//!- - - - - State Id - - - - - !//
  Future stateid({required String state}) async {
    Map body = {"curr_state_name": state};
    var response = await api.sendRequest.post(
      "${basUrlApi}currstateid.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//?- - - - - MyLoads Api - - - - - !//
  Future<MyLoadsModel> myLoadsApi(
      {required String ownerId, required String status}) async {
    Map body = {"owner_id": ownerId, "status": status};
    var response = await api.sendRequest
        .post("${basUrlApi}load_history.php", data: jsonEncode(body));

    return MyLoadsModel.fromJson(response.data);
  }

//!- - - - - Book History - - - - - !//
  Future bookHistory({required String uid, required String status}) async {
    Map body = {"owner_id": uid, "status": status};
    var respons = await api.sendRequest.post(
      "${basUrlApi}book_history.php",
      data: body,
    );
    return respons.data;
  }

//?- - - - - Loads Detils - - - - - !//
  Future<MyLoadsDetialsModel> loadsDetils(
      {required String uid, required String loadId}) async {
    Map body = {"owner_id": uid, "load_id": loadId};
    var respons = await api.sendRequest.post(
      "${basUrlApi}load_details.php",
      data: body,
    );

    return MyLoadsDetialsModel.fromJson(respons.data);
  }

//!- - - - - PickUp Drop Api - - - - - !//
  Future pickUpAndDropApi(
      {required String ownerId,
      required String loadId,
      required String status,
      required String loadTyp}) async {
    Map body = {
      "owner_id": ownerId,
      "load_id": loadId,
      "status": status,
      "load_type": loadTyp
    };
    //FIND_LORRY
    //POST_LOAD

    var response = await api.sendRequest
        .post("${basUrlApi}lorrydecision.php", data: jsonEncode(body));

    return response.data;
  }

//?- - - - - Rating - - - - - !//
  Future rating(
      {required String uid,
      required String totalRate,
      required String rateText,
      required String loadId}) async {
    Map body = {
      "uid": uid,
      "total_lrate": totalRate,
      "rate_ltext": rateText,
      "load_id": loadId
    };

    log("++++++++++++++$body");

    var response = await api.sendRequest.post(
      "${basUrlApi}rate_update.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//!- - - - - Book Details - - - - - !//
  Future<BookedDetialsModel> bookDetails(
      {required String uid, required String loadId}) async {
    Map body = {"owner_id": uid, "load_id": loadId};
    var respons = await api.sendRequest.post(
      "${basUrlApi}book_details.php",
      data: jsonEncode(body),
    );

    return BookedDetialsModel.fromJson(respons.data);
  }

//?- - - - - Reject Load - - - - - !//
  Future rejectLoad(
      {required String ownerId,
      required String loadId,
      required String commentReject}) async {
    Map body = {
      "owner_id": ownerId,
      "status": "2",
      "load_id": loadId,
      "comment_reject": commentReject
    };
    var response = await api.sendRequest.post(
      "${basUrlApi}offer_decision.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//!- - - - - Accept Load - - - - - !//
  Future acceptLoad(
      {required String ownerId,
      required String loadId,
      required String commentReject}) async {
    Map body = {
      "owner_id": ownerId,
      "status": "1",
      "load_id": loadId,
      "comment_reject": commentReject
    };
    var response = await api.sendRequest.post(
      "${basUrlApi}offer_decision.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//?- - - - - Offer Load - - - - - !//
  Future offerLoad(
      {required String ownerId,
      required String loadId,
      required String offerDes,
      required String offerPrice,
      required String offertype,
      required String offertotal}) async {
    Map body = {
      "owner_id": ownerId,
      "status": "3",
      "load_id": loadId,
      "offer_description": offerDes,
      "offer_price": offerPrice,
      "offer_type": offertype,
      "offer_total": offertotal
    };

    var response = await api.sendRequest.post(
      "${basUrlApi}offer_decision.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//!- - - - - Earning - - - - - !//
  Future earning({required String uid}) async {
    Map body = {"owner_id": uid};
    var response = await api.sendRequest.post(
      "${basUrlApi}getearning.php",
      data: jsonEncode(body),
    );

    return EarningModel.fromJson(response.data);
  }

//?- - - - - Payout Request - - - - - !//
  Future payoutRequest(
      {required String ownerId,
      required String amt,
      required String rType,
      String? bankName,
      String? accNumber,
      String? accName,
      String? ifscCode,
      String? upiId,
      String? paypal}) async {
    Map body = {
      "owner_id": ownerId,
      "amt": amt,
      "r_type": rType,
      "bank_name": bankName,
      "acc_number": accNumber,
      "acc_name": accName,
      "ifsc_code": ifscCode,
      "upi_id": upiId,
      "paypal_id": paypal
    };

    var response = await api.sendRequest.post(
      "${basUrlApi}request_withdraw.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//!- - - - - Transaction History - - - - - !//
  Future<TransactionModel> transactionHistory({required String ownerId}) async {
    Map body = {"owner_id": ownerId};
    var response = await api.sendRequest.post(
      "${basUrlApi}payout_list.php",
      data: jsonEncode(body),
    );

    return TransactionModel.fromJson(response.data);
  }

//?- - - - - Owner Profile - - - - - !//
  Future ownerProfile({required String uid}) async {
    Map body = {"owner_id": uid};
    var response = await api.sendRequest.post(
      "${basUrlApi}lorri_profile.php",
      data: jsonEncode(body),
    );

    return ReviewModel.fromJson(response.data);
  }

//!- - - - - Notification - - - - - !//
  Future notification({required String uid}) async {
    var response = await api.sendRequest
        .post("${basUrlApi}notification.php", data: {"owner_id": uid});

    return NotificationModel.fromJson(jsonDecode(response.data));
  }

  Future getLorrylist({required String uid}) async {
    
    var response = await api.sendRequest.post("${basUrlApi}lorrylist.php",
        data: {"owner_id": uid}
    );

    return response.data;
  }

  Future getSubdriverlist({required String uid}) async {

    var response = await api.sendRequest.post("${basUrlApi}subdriverlist.php",
        data: {"owner_id": uid}
    );

    return response.data;
  }

  Future getAddsubdriver({required Map body, url}) async {

    var response = await api.sendRequest.post("${basUrlApi}$url",
        data: body
    );

    return response.data;
  }

  Future<List<Map<String, dynamic>>> fetchVehicleBrands() async {
    final response = await http.get(Uri.parse("${basUrlApi}list_vehicle_brand.php"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == true) {
        return List<Map<String, dynamic>>.from(data["brands"]);
      }
    }
    return [];
  }

  Future<List<Map<String, dynamic>>> fetchTrailerTypes() async {
    final response = await http.get(Uri.parse("${basUrlApi}list_trailer_type.php"));
    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data["status"] == true) {
        return List<Map<String, dynamic>>.from(data["trailer_types"]);
      }
    }
    return [];
  }

  // Search for drivers by email (for dispatcher registration autocomplete)
  Future<List<Map<String, dynamic>>> searchDriversByEmail(String query) async {
    final response = await api.sendRequest.post(
      "http://localhost/AdminPanel/Api/search_driver.php",
      data: jsonEncode({'query': query}),
      options: Options(headers: header),
    );
    if (response.data['success'] == true) {
      return List<Map<String, dynamic>>.from(response.data['drivers']);
    } else {
      return [];
    }
  }

//?- - - - - Assign Order API - - - - - !//
  Future assignOrderApi({
    required String dispatcherId,
    required String driverId,
    required String details,
  }) async {
    Map body = {
      "dispatcher_id": dispatcherId,
      "driver_id": driverId,
      "details": details,
    };
    log("+-+-+-+-+ assign order body +-+-+-+-+ $body");
    var response = await api.sendRequest.post(
      "${basUrlApi}assign_order.php",
      data: jsonEncode(body),
    );
    return response.data;
  }

//?- - - - - Get Assigned Orders API - - - - - !//
  Future getAssignedOrdersApi({required String driverId}) async {
    Map body = {"driver_id": driverId};
    var response = await api.sendRequest.post(
      "${basUrlApi}get_assigned_orders.php",
      data: jsonEncode(body),
    );
    return response.data;
  }

//?- - - - - Update Order Status API - - - - - !//
  Future updateOrderStatusApi({
    required String orderId,
    required String status,
  }) async {
    Map body = {
      "order_id": orderId,
      "status": status,
    };
    log("+-+-+-+-+ update order status body +-+-+-+-+ $body");
    var response = await api.sendRequest.post(
      "${basUrlApi}update_order_status.php",
      data: jsonEncode(body),
    );
    return response.data;
  }

}
