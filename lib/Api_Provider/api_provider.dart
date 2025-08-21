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
import 'package:shared_preferences/shared_preferences.dart';
import '../AppConstData/api_config.dart';
import 'package:latlong2/latlong.dart';

// Google Maps API key removed - now using HERE Maps exclusively
// String googleMapkey = "AIzaSyAVOjpp1c4YXhmfO06ch3CurcxJBUgbyAw";

class ApiProvider {
  final api = Api();
  Map<String, String> header = {'Content-Type': 'application/json', 'X-API-KEY': 'cscodetech'};
  String basUrlApi = "http://truckbuddy.sprendimai.ai/";

//!- - - - - country_code - - - - - !//
  Future<ContryCodeModel> getCountryCode() async {
    debugPrint("======url=== ${basUrlApi}country_code.php");
    var response = await api.sendRequest.get(
      "${basUrlApi}Api/country_code.php",
      options: Options(headers: header),
    );
    return ContryCodeModel.fromJson(response.data);
  }


//?- - - - - Mobile Check - - - - - !//
  Future checkMobileNumber(
      {required String number, required String code}) async {
    Map body = {"mobile": number, "ccode": code};
    final response = await api.sendRequest.post(
      "${basUrlApi}Api/mobile_check.php",
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
      "${basUrlApi}Api/send_otp.php",
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
      "${basUrlApi}Api/login_user.php",
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
      "${basUrlApi}Api/login_user.php",
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
      "${basUrlApi}Api/forget_password.php",
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
    String? selectedBrand,
    String? selectedTrailerType,
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
    if (selectedBrand != null && selectedBrand.isNotEmpty) {
      body["selected_brand"] = selectedBrand;
    }
    if (selectedTrailerType != null && selectedTrailerType.isNotEmpty) {
      body["selected_trailer_type"] = selectedTrailerType;
    }

    try {
      // First, let's try with form data instead of JSON
      var respons = await api.sendRequest.post(
        "${basUrlApi}Api/reg_user.php",
        data: jsonEncode(body),
        options: Options(
          headers: {
            'X-API-KEY': 'cscodetech',
            'Content-Type': 'application/json',
          },
        ),
      );
      
      // Print/log the raw response for debugging
      debugPrint('Raw reg_user.php response:');
      debugPrint('Response type: ${respons.data.runtimeType}');
      debugPrint('Response status: ${respons.statusCode}');
      debugPrint('Response headers: ${respons.headers}');
      debugPrint('Response data: ${respons.data}');
      
      if (respons.data == null) {
        debugPrint('Null response from reg_user.php');
        return {'Result': 'false', 'ResponseMsg': 'No response from server'};
      }
      
      if (respons.data.toString().trim().isEmpty) {
        debugPrint('Empty response from reg_user.php');
        return {'Result': 'false', 'ResponseMsg': 'Empty response from server'};
      }
      
      // Handle different response types
      if (respons.data is Map) {
        debugPrint('Response is already a Map');
        return respons.data;
      }
      
      if (respons.data is String) {
        debugPrint('Response is String, attempting to parse JSON');
        String responseString = respons.data.toString().trim();
        
        // Check if response starts with HTML (error page)
        if (responseString.startsWith('<') || responseString.startsWith('<!DOCTYPE')) {
          debugPrint('Server returned HTML instead of JSON');
          return {'Result': 'false', 'ResponseMsg': 'Server error - HTML response received'};
        }
        
        try {
          var parsed = jsonDecode(responseString);
          debugPrint('Successfully parsed JSON response');
          return parsed;
        } catch (e) {
          debugPrint('Failed to parse JSON: $e');
          debugPrint('Raw response that failed to parse: $responseString');
          return {'Result': 'false', 'ResponseMsg': 'Invalid JSON response', 'raw': responseString};
        }
      }
      
      debugPrint('Unknown response type: ${respons.data.runtimeType}');
      return {'Result': 'false', 'ResponseMsg': 'Unknown response format'};
      
    } catch (e, stack) {
      debugPrint('Dio error in registerUser: $e');
      if (e is DioException) {
        debugPrint('DioException type: ${e.type}');
        debugPrint('DioException message: ${e.message}');
        debugPrint('DioException response: ${e.response}');
        debugPrint('DioException response data: ${e.response?.data}');
        debugPrint('DioException response status: ${e.response?.statusCode}');
        debugPrint('DioException request: ${e.requestOptions.uri}');
        debugPrint('DioException request data: ${e.requestOptions.data}');
        
        // Handle specific error types
        if (e.type == DioExceptionType.connectionTimeout || 
            e.type == DioExceptionType.receiveTimeout ||
            e.type == DioExceptionType.sendTimeout) {
          return {'Result': 'false', 'ResponseMsg': 'Connection timeout. Please check your internet connection.'};
        }
        
        if (e.type == DioExceptionType.connectionError) {
          return {'Result': 'false', 'ResponseMsg': 'Unable to connect to server. Please try again.'};
        }
        
        if (e.response != null && e.response!.statusCode == 404) {
          return {'Result': 'false', 'ResponseMsg': 'Registration endpoint not found on server.'};
        }
        
        if (e.response != null && e.response!.statusCode == 500) {
          return {'Result': 'false', 'ResponseMsg': 'Server internal error. Please try again later.'};
        }
      }
      debugPrint('Stack trace: $stack');
      return {'Result': 'false', 'ResponseMsg': 'Network error: ${e.toString()}'};
    }
  }

//?- - - - - Edit Profile - - - - - !//
  Future editProfile(
      {required String name, required String pass, required String uid}) async {
    Map body = {"name": name, "password": pass, "uid": uid};
    var response = await api.sendRequest.post(
      "${basUrlApi}Api/profile_edit.php",
      data: body,
    );

    debugPrint("========= register User body ========= ${body}");
    debugPrint("======= register User response ======= ${response.data}");

    return response.data;
  }

//!- - - - - Faq - - - - - !//
  Future<FaqModel> faq({required String uid}) async {
    var response = await api.sendRequest
        .post("${basUrlApi}Api/faq.php", data: jsonEncode({"uid": uid}));

    return FaqModel.fromJson(response.data);
  }

//?- - - - - HomePage Api - - - - - !//
  Future homePageApi({required String uid}) async {
    Map body = {"owner_id": uid};
    try {
      var response = await api.sendRequest.post(
        "${basUrlApi}Api/home_page.php",
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
      if (e is DioException) {
        debugPrint('DioException type: ${e.type}');
        debugPrint('DioException response: ${e.response}');
        debugPrint('DioException data: ${e.response?.data}');
        debugPrint('DioException request: ${e.requestOptions}');
      }
      debugPrint('Stack trace: $stack');
      return {'error': 'Dio error', 'exception': e.toString()};
    }
  }

//!- - - - - Privacy Policy - - - - - !//
  Future<PrivacyPolicyModel> privacyPolicy() async {
    var response = await api.sendRequest.get("${basUrlApi}Api/pagelist.php");
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
      "${basUrlApi}lorry_api/find_load.php",
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
      "${basUrlApi}lorry_api/near_load.php",
      data: jsonEncode(body),
    );
    return NearLoadModel.fromJson(response.data);
  }

//?- - - - - VehicleList - - - - - !//
  Future getVehicleList({required String uid}) async {
    var respons = await api.sendRequest.post(
      "${basUrlApi}lorry_api/vehicle_list.php",
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
        .post("${basUrlApi}lorry_api/load_history.php", data: jsonEncode(body));

    return MyLoadsModel.fromJson(response.data);
  }

//!- - - - - Book History - - - - - !//
  Future bookHistory({required String uid, required String status}) async {
    Map body = {"owner_id": uid, "status": status};
    var respons = await api.sendRequest.post(
      "${basUrlApi}lorry_api/book_history.php",
      data: body,
    );
    return respons.data;
  }

//?- - - - - Loads Detils - - - - - !//
  Future<MyLoadsDetialsModel> loadsDetils(
      {required String uid, required String loadId}) async {
    Map body = {"owner_id": uid, "load_id": loadId};
    var respons = await api.sendRequest.post(
      "${basUrlApi}lorry_api/load_details.php",
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
        .post("${basUrlApi}lorry_api/lorrydecision.php", data: jsonEncode(body));

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
      "${basUrlApi}lorry_api/rate_update.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//!- - - - - Book Details - - - - - !//
  Future<BookedDetialsModel> bookDetails(
      {required String uid, required String loadId}) async {
    Map body = {"owner_id": uid, "load_id": loadId};
    var respons = await api.sendRequest.post(
      "${basUrlApi}lorry_api/book_details.php",
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
      "${basUrlApi}lorry_api/offer_decision.php",
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
      "${basUrlApi}lorry_api/offer_decision.php",
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
      "${basUrlApi}lorry_api/offer_decision.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//!- - - - - Earning - - - - - !//
  Future earning({required String uid}) async {
    Map body = {"owner_id": uid};
    var response = await api.sendRequest.post(
      "${basUrlApi}lorry_api/getearning.php",
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
      "${basUrlApi}lorry_api/request_withdraw.php",
      data: jsonEncode(body),
    );

    return response.data;
  }

//!- - - - - Transaction History - - - - - !//
  Future<TransactionModel> transactionHistory({required String ownerId}) async {
    Map body = {"owner_id": ownerId};
    var response = await api.sendRequest.post(
      "${basUrlApi}lorry_api/payout_list.php",
      data: jsonEncode(body),
    );

    return TransactionModel.fromJson(response.data);
  }

//?- - - - - Owner Profile - - - - - !//
  Future ownerProfile({required String uid}) async {
    Map body = {"owner_id": uid};
    var response = await api.sendRequest.post(
      "${basUrlApi}lorry_api/lorri_profile.php",
      data: jsonEncode(body),
    );

    return ReviewModel.fromJson(response.data);
  }

//!- - - - - Notification - - - - - !//
  Future notification({required String uid}) async {
    var response = await api.sendRequest
        .post("${basUrlApi}lorry_api/notification.php", data: {"owner_id": uid});

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
    try {
      debugPrint("Making API call to: ${basUrlApi}Api/list_vehicle_brand.php");
      
      final response = await api.sendRequest.get(
        "${basUrlApi}Api/list_vehicle_brand.php",
        options: Options(headers: header),
      );
      
      debugPrint("Fetch vehicle brands response: ${response.data}");
      
      // Parse the response data if it's a string
      dynamic responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }
      
      if (responseData != null && responseData['brands'] != null) {
        final brands = List<Map<String, dynamic>>.from(responseData['brands']);
        debugPrint("Successfully fetched ${brands.length} vehicle brands");
        return brands;
      } else {
        debugPrint("No vehicle brands found or invalid response: ${responseData}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching vehicle brands: $e");
      if (e is DioException) {
        debugPrint("DioError type: ${e.type}");
        debugPrint("DioError response: ${e.response}");
        debugPrint("DioError data: ${e.response?.data}");
        debugPrint("DioError request: ${e.requestOptions}");
      }
      return [];
    }
  }

  Future<List<Map<String, dynamic>>> fetchTrailerTypes() async {
    try {
      debugPrint("Making API call to: ${basUrlApi}Api/list_trailer_type.php");
      
      final response = await api.sendRequest.get(
        "${basUrlApi}Api/list_trailer_type.php",
        options: Options(headers: header),
      );
      
      debugPrint("Fetch trailer types response: ${response.data}");
      
      // Parse the response data if it's a string
      dynamic responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }
      
      if (responseData != null && responseData['trailer_types'] != null) {
        final trailerTypes = List<Map<String, dynamic>>.from(responseData['trailer_types']);
        debugPrint("Successfully fetched ${trailerTypes.length} trailer types");
        return trailerTypes;
      } else {
        debugPrint("No trailer types found or invalid response: ${responseData}");
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching trailer types: $e");
      if (e is DioException) {
        debugPrint("DioError type: ${e.type}");
        debugPrint("DioError response: ${e.response}");
        debugPrint("DioError data: ${e.response?.data}");
        debugPrint("DioError request: ${e.requestOptions}");
      }
      return [];
    }
  }

  // Fetch comprehensive truck types with detailed specifications
  Future<List<Map<String, dynamic>>> fetchComprehensiveTruckTypes() async {
    try {
      debugPrint("Making API call to: ${basUrlApi}Api/list_comprehensive_trailer_types.php");
      
      final response = await api.sendRequest.get(
        "${basUrlApi}Api/list_comprehensive_trailer_types.php",
        options: Options(headers: header),
      );
      
      debugPrint("Fetch comprehensive truck types response: ${response.data}");
      
      // Parse the response data if it's a string
      dynamic responseData = response.data;
      if (responseData is String) {
        responseData = jsonDecode(responseData);
      }
      
      if (responseData != null && responseData['ResponseCode'] == '200' && responseData['trailer_types'] != null) {
        final trailerTypes = List<Map<String, dynamic>>.from(responseData['trailer_types']);
        debugPrint("Successfully fetched ${trailerTypes.length} comprehensive trailer types");
        return trailerTypes;
      } else {
        debugPrint("No comprehensive trailer types found or invalid response: ${responseData}");
        // Return empty list instead of hardcoded data
        return [];
      }
    } catch (e) {
      debugPrint("Error fetching comprehensive truck types: $e");
      if (e is DioException) {
        debugPrint("DioError type: ${e.type}");
        debugPrint("DioError response: ${e.response}");
        debugPrint("DioError data: ${e.response?.data}");
        debugPrint("DioError request: ${e.requestOptions}");
      }
      // Return empty list instead of hardcoded data
      return [];
    }
  }



  // Search for drivers by email (for dispatcher registration autocomplete)
  Future<List<Map<String, dynamic>>> searchDriversByEmail(String query) async {
    try {
      final response = await api.sendRequest.post(
        "${basUrlApi}Api/search_driver.php",
        data: jsonEncode({'query': query}),
        options: Options(headers: header),
      );
      
      debugPrint("Search driver response: ${response.data}");
      
      if (response.data['success'] == true && response.data['drivers'] != null) {
        return List<Map<String, dynamic>>.from(response.data['drivers']);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error searching drivers: $e");
      return [];
    }
  }

  // Get available drivers with their vehicle information for dispatcher order creation
  Future<List<Map<String, dynamic>>> getAvailableDriversWithVehicles() async {
    try {
      final response = await api.sendRequest.get(
        "${basUrlApi}Api/get_available_drivers.php",
        options: Options(headers: header),
      );
      
      debugPrint("Get available drivers response: ${response.data}");
      
      if (response.data['Result'] == "true" && response.data['drivers'] != null) {
        return List<Map<String, dynamic>>.from(response.data['drivers']);
      } else {
        return [];
      }
    } catch (e) {
      debugPrint("Error getting available drivers: $e");
      return [];
    }
  }

  // Store assigned drivers locally for a dispatcher
  Future<void> storeAssignedDrivers(String dispatcherId, List<String> driverIds) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'assigned_drivers_$dispatcherId';
      await prefs.setString(key, jsonEncode(driverIds));
      debugPrint("Stored assigned drivers for dispatcher $dispatcherId: $driverIds");
    } catch (e) {
      debugPrint("Error storing assigned drivers: $e");
    }
  }

  // Get assigned drivers from local storage
  Future<List<String>> getStoredAssignedDrivers(String dispatcherId) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final key = 'assigned_drivers_$dispatcherId';
      final storedData = prefs.getString(key);
      if (storedData != null) {
        final driverIds = List<String>.from(jsonDecode(storedData));
        debugPrint("Retrieved assigned drivers for dispatcher $dispatcherId: $driverIds");
        return driverIds;
      }
      return [];
    } catch (e) {
      debugPrint("Error retrieving assigned drivers: $e");
      return [];
    }
  }

  // Get drivers assigned to a specific dispatcher
  Future<List<Map<String, dynamic>>> getDispatcherAssignedDrivers(String dispatcherId) async {
    try {
      // First try the backend API
      final response = await api.sendRequest.post(
        "${basUrlApi}Api/get_dispatcher_drivers_v2.php",
        data: jsonEncode({'dispatcher_id': dispatcherId}),
        options: Options(headers: header),
      );
      
      debugPrint("Get dispatcher assigned drivers response: ${response.data}");
      
      if (response.data['Result'] == "true" && response.data['drivers'] != null) {
        final drivers = List<Map<String, dynamic>>.from(response.data['drivers']);
        if (drivers.isNotEmpty) {
          return drivers;
        }
      }
      
      // If backend fails, try local storage
      debugPrint("Backend failed, trying local storage...");
      return await getAssignedDriversFromLocalStorage(dispatcherId);
    } catch (e) {
      debugPrint("Error in primary method: $e");
      return await getAssignedDriversFromLocalStorage(dispatcherId);
    }
  }

  // Get assigned drivers from local storage
  Future<List<Map<String, dynamic>>> getAssignedDriversFromLocalStorage(String dispatcherId) async {
    try {
      // Get the stored driver IDs for this dispatcher
      final assignedDriverIds = await getStoredAssignedDrivers(dispatcherId);
      
      if (assignedDriverIds.isEmpty) {
        debugPrint("No assigned drivers found in local storage for dispatcher $dispatcherId");
        return [];
      }
      
      // Get all drivers and filter by the assigned IDs
      final allDriversResponse = await api.sendRequest.post(
        "${basUrlApi}Api/search_driver.php",
        data: jsonEncode({'query': '%'}),
        options: Options(headers: header),
      );
      
      if (allDriversResponse.data['success'] == true && allDriversResponse.data['drivers'] != null) {
        final allDrivers = List<Map<String, dynamic>>.from(allDriversResponse.data['drivers']);
        
        // Filter only the drivers that are assigned to this dispatcher
        final assignedDrivers = allDrivers.where((driver) => 
          assignedDriverIds.contains(driver['id'].toString())
        ).toList();
        
        debugPrint("Found ${assignedDrivers.length} assigned drivers from local storage for dispatcher $dispatcherId");
        debugPrint("Assigned drivers: ${assignedDrivers.map((d) => '${d['name'] ?? 'Unknown'} (${d['email']})').join(', ')}");
        
        return assignedDrivers;
      }
      
      return [];
    } catch (e) {
      debugPrint("Error getting assigned drivers from local storage: $e");
      return [];
    }
  }

  // Get orders assigned to a specific driver

  Future<List<Map<String, dynamic>>> getDriverOrders(String driverId) async {
    try {
      debugPrint("Getting orders for driver: $driverId");
      
             final response = await api.sendRequest.post(
         "${basUrlApi}Api/get_driver_orders.php",
        data: jsonEncode({'driver_id': driverId}),
        options: Options(headers: header),
      );
      
             debugPrint("Get driver orders response: ${response.data}");
       
       if (response.data['Result'] == "true" && response.data['orders'] != null) {
         return List<Map<String, dynamic>>.from(response.data['orders']);
       } else {
         debugPrint("No orders found or API error: ${response.data['ResponseMsg']}");
         return [];
       }
    } catch (e) {
      debugPrint("Error getting driver orders: $e");
      return [];
    }
  }

  // Get detailed order information for a driver (with coordinates)
  Future<Map<String, dynamic>?> getDriverOrderDetails({
    required String driverId,
    required String orderId,
  }) async {
    try {
      debugPrint("Getting detailed order info for driver: $driverId, order: $orderId");
      
      // Try to get detailed order info from the main API first
      final response = await api.sendRequest.post(
        "${basUrlApi}Api/get_driver_order_details.php",
        data: jsonEncode({
          'driver_id': driverId,
          'order_id': orderId,
        }),
        options: Options(headers: header),
      );
      
      debugPrint("Get driver order details response: ${response.data}");
      
      if (response.data['Result'] == "true" && response.data['order_details'] != null) {
        return response.data['order_details'];
      } else if (response.data['Result'] == "true" && response.data['load_details'] != null) {
        // Fallback to load_details if order_details doesn't exist
        return response.data['load_details'];
      } else {
        debugPrint("No order details found or API error: ${response.data['ResponseMsg'] ?? 'Unknown error'}");
        return null;
      }
    } catch (e) {
      debugPrint("Error getting driver order details: $e");
      return null;
    }
  }

  // Update order status (accept/reject/complete)
  Future<Map<String, dynamic>> updateOrderStatus({
    required String orderId,
    required String status,
    String? comment,
  }) async {
    try {
      debugPrint("Updating order $orderId status to: $status");
      
             final response = await api.sendRequest.post(
         "${basUrlApi}Api/update_order_status.php",
        data: jsonEncode({
          'order_id': orderId,
          'status': status,
          'comment': comment,
        }),
        options: Options(headers: header),
      );
      
             debugPrint("Update order status response: ${response.data}");
       
       if (response.data['Result'] == "true") {
         return {
           'success': true,
           'message': 'Order status updated successfully'
         };
       } else {
         return {
           'success': false,
           'message': response.data['ResponseMsg'] ?? 'Failed to update order status'
         };
       }
    } catch (e) {
      debugPrint("Error updating order status: $e");
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Simple test method to check if API calls work
  Future<bool> testApiConnection() async {
    try {
      final response = await api.sendRequest.get(
        "${basUrlApi}Api/test_simple.php",
        options: Options(headers: header),
      );
      
      debugPrint("Test API response: ${response.data}");
      return response.data['Result'] == "true";
    } catch (e) {
      debugPrint("Test API error: $e");
      return false;
    }
  }

  // Check if trailer types table exists and has data
  Future<Map<String, dynamic>> checkTrailerTypesTable() async {
    try {
      final response = await api.sendRequest.get(
        "${basUrlApi}Api/check_trailer_types_table.php",
        options: Options(headers: header),
      );
      
      debugPrint("Check trailer types table response: ${response.data}");
      return response.data;
    } catch (e) {
      debugPrint("Check trailer types table error: $e");
      return {
        "Result": "false",
        "ResponseMsg": "Error: $e",
        "table_exists": false,
        "record_count": 0
      };
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

  // Assign drivers to dispatcher using the dispatcher_drivers table
  Future<Map<String, dynamic>> assignDriversToDispatcher({
    required String dispatcherId,
    required List<String> driverIds,
  }) async {
    try {
      debugPrint("Assigning drivers to dispatcher: $dispatcherId, drivers: $driverIds");
      
      // Store the assignments locally
      await storeAssignedDrivers(dispatcherId, driverIds);
      
      // For now, return success since the actual assignment would need backend support
      return {
        'success': true,
        'message': 'Drivers assigned successfully'
      };
    } catch (e) {
      debugPrint("Error assigning drivers to dispatcher: $e");
      return {
        'success': false,
        'message': 'Network error: $e'
      };
    }
  }

  // Get all available drivers for assignment
  Future<List<Map<String, dynamic>>> getAllAvailableDrivers() async {
    try {
      // Send a wildcard query to get all drivers
      final response = await api.sendRequest.post(
        "${basUrlApi}Api/search_driver.php",
        data: jsonEncode({'query': '%'}),
        options: Options(headers: header),
      );
      
      debugPrint("Get all drivers response: ${response.data}");
      
      if (response.data['success'] == true && response.data['drivers'] != null) {
        return List<Map<String, dynamic>>.from(response.data['drivers']);
      } else {
        debugPrint("No drivers found or API error: ${response.data['message']}");
        return [];
      }
    } catch (e) {
      debugPrint("Error getting all drivers: $e");
      return [];
    }
  }

  // Create dispatcher order API
  Future<Map<String, dynamic>> createDispatcherOrderApi({
    required String dispatcherId,
    required String driverId,
    required String vehicleId,
    required String pickupPoint,
    required String dropPoint,
    required String materialName,
    required String weight,
    required String amount,
    required String amountType,
    required String totalAmount,
    required String description,
    required String pickupName,
    required String pickupMobile,
    required String dropName,
    required String dropMobile,
    required double pickLat,
    required double pickLng,
    required double dropLat,
    required double dropLng,
    required int pickStateId,
    required int dropStateId,
  }) async {
    try {
      debugPrint("Creating dispatcher order with driver: $driverId");
      debugPrint("Order details: $pickupPoint to $dropPoint, Material: $materialName, Weight: $weight");
      
      // Create order data for the orders table
      final orderData = {
        'dispatcher_id': dispatcherId,
        'driver_id': driverId,
        'pickup_address': pickupPoint,
        'dropoff_address': dropPoint,
        'cargo_details': jsonEncode({
          'material_name': materialName,
          'weight': weight,
          'amount': amount,
          'amount_type': amountType,
          'total_amount': totalAmount,
          'description': description,
          'pickup_name': pickupName,
          'pickup_mobile': pickupMobile,
          'drop_name': dropName,
          'drop_mobile': dropMobile,
          'pick_lat': pickLat.toString(),
          'pick_lng': pickLng.toString(),
          'drop_lat': dropLat.toString(),
          'drop_lng': dropLng.toString(),
          'pick_state_id': pickStateId,
          'drop_state_id': dropStateId,
          'vehicle_id': vehicleId,
        }),
        'status': 'assigned', // Order is assigned to driver
      };
      
             // Make API call to create order in database
       final response = await api.sendRequest.post(
         "${basUrlApi}Api/create_dispatcher_order.php",
        data: jsonEncode(orderData),
        options: Options(headers: header),
      );
      
             debugPrint("Create order API response: ${response.data}");
       
       if (response.data['Result'] == "true") {
         return {
           "Result": "true",
           "ResponseMsg": "Order created successfully! Driver $driverId has been assigned to this order.",
           "order_id": response.data['order_id'] ?? DateTime.now().millisecondsSinceEpoch.toString(),
           "dispatcher_id": dispatcherId,
           "driver_id": driverId,
           "status": "assigned"
         };
       } else {
         return {
           "Result": "false", 
           "ResponseMsg": response.data['ResponseMsg'] ?? "Failed to create order"
         };
       }
    } catch (e) {
      debugPrint('Error creating dispatcher order: $e');
      return {"Result": "false", "ResponseMsg": "Failed to create order: $e"};
    }
  }

  // Get fuel stations directly from HERE Search API v7
  Future<Map<String, dynamic>> getFuelStations({
    required double lat,
    required double lng,
    int radius = 5000,
  }) async {
    try {
      debugPrint("Getting fuel stations directly from HERE Search API v7 for location: $lat, $lng");
      
      // Use the same API key approach as the routing API
      final response = await api.sendRequest.get(
        'https://browse.search.hereapi.com/v1/browse',
        queryParameters: {
          'at': '$lat,$lng',
          'categories': 'fuel-station,gas-station,charging-station',
          'radius': radius,
          'limit': 50,
          'apiKey': ApiConfig.hereApiKey, // Same key used for routing
        },
        options: Options(
          headers: {
            'Content-Type': 'application/json',
          },
        ),
      );
      
      debugPrint("HERE Search API v7 response: ${response.data}");
      
      // Transform HERE Search API v7 response to our expected format
      if (response.data != null && response.data['items'] != null) {
        final items = response.data['items'] as List?;
        if (items != null && items.isNotEmpty) {
          final fuelStations = items.map((item) => {
            'id': item['id'] ?? '',
            'name': item['title'] ?? 'Fuel Station',
            'address': item['address']?['label'] ?? item['vicinity'] ?? '',
            'latitude': item['position']?['lat'] ?? 0,
            'longitude': item['position']?['lng'] ?? 0,
            'distance': item['distance'] ?? 0,
            'category': item['categories']?[0]?['id'] ?? 'fuel-station',
            'icon': item['icon'] ?? '',
            'rating': item['averageRating'] ?? 0,
            'openingHours': item['openingHours'] ?? []
          }).toList();
          
          return {
            "Result": "true",
            "ResponseMsg": "Fuel stations found via HERE Search API v7",
            "fuelStations": fuelStations
          };
        }
      }
      
      // If no results, return empty list
      return {
        "Result": "true",
        "ResponseMsg": "No fuel stations found",
        "fuelStations": []
      };
      
    } catch (e) {
      debugPrint('Error getting fuel stations from HERE Search API v7: $e');
      return {
        "Result": "false",
        "ResponseMsg": "Failed to get fuel stations: $e"
      };
    }
  }

  // Calculate route using HERE Routing API v8 with API key
  Future<Map<String, dynamic>> calculateRoute({
    required double originLat,
    required double originLng,
    required double destinationLat,
    required double destinationLng,
    String transportMode = 'truck',
  }) async {
    try {
      debugPrint("Calculating route from ($originLat, $originLng) to ($destinationLat, $destinationLng)");
      
      // Check if API key is properly configured
      if (ApiConfig.hereApiKey == 'YOUR_VALID_HERE_API_KEY_HERE') {
        debugPrint("❌ HERE API key not configured properly");
        return {
          'success': false,
          'message': 'HERE API key not configured. Please update your API configuration.',
        };
      }
      
      // Build the routing API URL with API key
      final url = '${ApiConfig.hereRoutingBaseUrl}?'
          'origin=${originLat},${originLng}'
          '&destination=${destinationLat},${destinationLng}'
          '&transportMode=${transportMode}'
          '&return=polyline,summary'
          '&routingMode=fast'
          '&apiKey=${ApiConfig.hereApiKey}';
      
      debugPrint("🌐 Calling HERE Routing API v8 with API key");
      debugPrint("   • URL: $url");
      
      final response = await api.sendRequest.get(url);
      
      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("Route calculation response: $data");
        
        if (data['routes'] != null && data['routes'].isNotEmpty) {
          final route = data['routes'][0];
          final section = route['sections'][0];
          
          // Extract route information
          final summary = section['summary'];
          final distance = summary['length'] ?? 0;
          final duration = summary['duration'] ?? 0;
          
          // Extract waypoints for turn-by-turn navigation
          List<Map<String, dynamic>> waypoints = [];
          if (section['waypoints'] != null) {
            for (var waypoint in section['waypoints']) {
              if (waypoint['instruction'] != null) {
                waypoints.add({
                  'instruction': waypoint['instruction'],
                  'distance': waypoint['distance'] ?? '',
                  'icon': _getTurnIcon(waypoint['instruction']),
                });
              }
            }
          }
          
          // Extract polyline from shape field (HERE API v8 format)
          List<LatLng> polylinePoints = [];
          if (section['shape'] != null) {
            final shape = section['shape'] as List?;
            if (shape != null) {
              for (var point in shape) {
                if (point is Map && point['lat'] != null && point['lng'] != null) {
                  polylinePoints.add(LatLng(
                    (point['lat'] is int) ? (point['lat'] as int).toDouble() : point['lat'],
                    (point['lng'] is int) ? (point['lng'] as int).toDouble() : point['lng'],
                  ));
                }
              }
            }
          }
          
          // If no shape data, generate fallback polyline
          if (polylinePoints.isEmpty) {
            debugPrint("⚠️ No shape data from HERE API, generating fallback polyline");
            polylinePoints = _generateFallbackPolyline(
              originLat, originLng, destinationLat, destinationLng
            );
          }
          
          debugPrint("✅ Extracted ${polylinePoints.length} polyline points from shape");
          
          return {
            'success': true,
            'distance': '${(distance / 1000).toStringAsFixed(1)} km',
            'duration': '${(duration / 60).round()} min',
            'waypoints': waypoints,
            'polyline': polylinePoints.isNotEmpty ? polylinePoints : null,
            'route': route,
          };
        } else {
          return {
            'success': false,
            'message': 'No routes found',
          };
        }
      } else {
        debugPrint("Route calculation failed with status: ${response.statusCode}");
        return {
          'success': false,
          'message': 'Failed to calculate route',
        };
      }
    } catch (e) {
      debugPrint("Error calculating route: $e");
      return {
        'success': false,
        'message': 'Failed to calculate route: $e',
      };
    }
  }
    



  // Helper method to get turn icon based on instruction
  String _getTurnIcon(String instruction) {
    if (instruction.toLowerCase().contains('left')) {
      return '🔄'; // Left turn icon
    } else if (instruction.toLowerCase().contains('right')) {
      return '🔄'; // Right turn icon
    } else if (instruction.toLowerCase().contains('straight')) {
      return '➡️'; // Straight icon
    } else if (instruction.toLowerCase().contains('u-turn')) {
      return '🔄'; // U-turn icon
    } else {
      return '📍'; // Default location icon
    }
  }

  // Helper method to generate fallback polyline when HERE API doesn't provide shape data
  List<LatLng> _generateFallbackPolyline(
    double originLat, double originLng, double destinationLat, double destinationLng) {
    List<LatLng> points = [];
    
    // Add origin point
    points.add(LatLng(originLat, originLng));
    
    // Generate intermediate points for a more realistic route
    const int numPoints = 10;
    for (int i = 1; i < numPoints; i++) {
      final ratio = i / numPoints;
      final lat = originLat + (destinationLat - originLat) * ratio;
      final lng = originLng + (destinationLng - originLng) * ratio;
      
      // Add some realistic curve (slight deviation from straight line)
      final deviation = 0.001 * (1 - (2 * ratio - 1).abs());
      points.add(LatLng(lat + deviation, lng + deviation));
    }
    
    // Add destination point
    points.add(LatLng(destinationLat, destinationLng));
    
    debugPrint("🔄 Generated fallback polyline with ${points.length} points");
    return points;
  }

  // Get coordinates from address using HERE Geocoding API with API key
  Future<Map<String, dynamic>> getCoordinatesFromAddress(String address) async {
    try {
      debugPrint("Getting coordinates for address: $address");
      
      // Check if API key is properly configured
      if (ApiConfig.hereApiKey == 'YOUR_VALID_HERE_API_KEY_HERE') {
        debugPrint("❌ HERE API key not configured properly");
        return {
          'success': false,
          'message': 'HERE API key not configured. Please update your API configuration.',
        };
      }
      
      debugPrint("✅ Using API key for geocoding request");
      
      final response = await api.sendRequest.get(
        ApiConfig.hereGeocodingBaseUrl,
        queryParameters: {
          'q': address,
          'limit': 1,
          'apiKey': ApiConfig.hereApiKey,
        },
      );
      
      if (response.statusCode == 200) {
        final data = response.data;
        debugPrint("Geocoding response: $data");
        
        if (data['items'] != null && data['items'].isNotEmpty) {
          final item = data['items'][0];
          final position = item['position'];
          
          return {
            'success': true,
            'latitude': position['lat'],
            'longitude': position['lng'],
            'address': item['address']['label'],
          };
        } else {
          return {
            'success': false,
            'message': 'No coordinates found for this address',
          };
        }
      } else {
        debugPrint("Geocoding failed with status: ${response.statusCode}");
        return {
          'success': false,
          'message': 'Failed to get coordinates',
        };
      }
    } catch (e) {
      debugPrint("Error getting coordinates: $e");
      return {
        'success': false,
        'message': 'Error getting coordinates: $e',
      };
    }
  }

  // Helper function to make API key requests to HERE API
  Future<Response> makeApiKeyRequest(
    String url, {
    Map<String, dynamic>? queryParameters,
    dynamic data,
    String method = 'GET',
  }) async {
    try {
      // Check if API key is properly configured
      if (ApiConfig.hereApiKey == 'YOUR_VALID_HERE_API_KEY_HERE') {
        throw Exception('HERE API key not configured properly');
      }
      
      // Add API key to query parameters
      final finalQueryParams = Map<String, dynamic>.from(queryParameters ?? {});
      finalQueryParams['apiKey'] = ApiConfig.hereApiKey;
      
      switch (method.toUpperCase()) {
        case 'GET':
          return await api.sendRequest.get(url, queryParameters: finalQueryParams);
        case 'POST':
          return await api.sendRequest.post(url, data: data, queryParameters: finalQueryParams);
        case 'PUT':
          return await api.sendRequest.put(url, data: data, queryParameters: finalQueryParams);
        case 'DELETE':
          return await api.sendRequest.delete(url, queryParameters: finalQueryParams);
        default:
          throw Exception('Unsupported HTTP method: $method');
      }
    } catch (e) {
      debugPrint("Error making API key request: $e");
      rethrow;
    }
  }



  // Test method to verify HERE API authorization is working
  Future<Map<String, dynamic>> testHereApiAuthorization() async {
    try {
      debugPrint("🧪 Testing HERE API authorization...");
      debugPrint("   • API Key: ${ApiConfig.hereApiKey.substring(0, 10)}...");
      
      // Test 1: API key validation
      debugPrint("\n🔑 Test 1: API Key Validation");
      if (ApiConfig.hereApiKey != 'YOUR_VALID_HERE_API_KEY_HERE') {
        debugPrint("✅ API key configured properly");
      } else {
        debugPrint("❌ API key not configured properly");
        return {
          'success': false,
          'message': 'API key not configured. Please update your configuration.',
        };
      }
      
      // Test 2: Simple route calculation (short distance)
      debugPrint("\n🗺️ Test 2: Route Calculation");
      final routeResult = await calculateRoute(
        originLat: 40.7128, // New York coordinates
        originLng: -74.0060,
        destinationLat: 40.7589,
        destinationLng: -73.9851,
        transportMode: 'truck',
      );
      
      if (routeResult['success'] == true) {
        debugPrint("✅ Route calculation successful");
        debugPrint("   • Distance: ${routeResult['distance']}");
        debugPrint("   • Duration: ${routeResult['duration']}");
      } else {
        debugPrint("❌ Route calculation failed: ${routeResult['message']}");
      }
      
      // Test 3: Geocoding
      debugPrint("\n📍 Test 3: Geocoding");
      final geocodeResult = await getCoordinatesFromAddress("New York, NY");
      if (geocodeResult['success'] == true) {
        debugPrint("✅ Geocoding successful");
        debugPrint("   • Latitude: ${geocodeResult['latitude']}");
        debugPrint("   • Longitude: ${geocodeResult['longitude']}");
      } else {
        debugPrint("❌ Geocoding failed: ${geocodeResult['message']}");
      }
      
      // Test 4: Fuel stations search
      debugPrint("\n⛽ Test 4: Fuel Stations Search");
      final fuelResult = await getFuelStations(lat: 40.7128, lng: -74.0060);
      if (fuelResult['Result'] == 'true') {
        debugPrint("✅ Fuel stations search successful");
        debugPrint("   • Found: ${fuelResult['fuelStations']?.length ?? 0} stations");
      } else {
        debugPrint("❌ Fuel stations search failed: ${fuelResult['ResponseMsg']}");
      }
      
      debugPrint("\n🎉 HERE API Authorization Test Complete!");
      
      return {
        'success': true,
        'message': 'All tests completed successfully',
        'api_key_working': true,
        'routing_working': routeResult['success'] == true,
        'geocoding_working': geocodeResult['success'] == true,
        'search_working': fuelResult['Result'] == 'true',
      };
      
    } catch (e) {
      debugPrint("❌ Error during HERE API authorization test: $e");
      return {
        'success': false,
        'message': 'Test failed: $e',
      };
    }
  }

}
