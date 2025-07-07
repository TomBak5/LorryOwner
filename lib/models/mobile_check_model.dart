// To parse this JSON data, do
//
//     final mobileCheck = mobileCheckFromJson(jsonString);

import 'dart:convert';

MobileCheck mobileCheckFromJson(String str) => MobileCheck.fromJson(json.decode(str));

String mobileCheckToJson(MobileCheck data) => json.encode(data.toJson());

class MobileCheck {
    String responseCode;
    String result;
    String responseMsg;
    String otpAuth;

    MobileCheck({
        required this.responseCode,
        required this.result,
        required this.responseMsg,
        required this.otpAuth,
    });

    factory MobileCheck.fromJson(Map<String, dynamic> json) => MobileCheck(
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
        otpAuth: json["otp_auth"],
    );

    Map<String, dynamic> toJson() => {
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
        "otp_auth": otpAuth,
    };
}



// // To parse this JSON data, do
// //
// //     final mobileCheck = mobileCheckFromJson(jsonString);

// import 'dart:convert';

// MobileCheck mobileCheckFromJson(String str) =>
//     MobileCheck.fromJson(json.decode(str));

// String mobileCheckToJson(MobileCheck data) => json.encode(data.toJson());

// class MobileCheck {
//   String responseCode;
//   String result;
//   String responseMsg;

//   MobileCheck({
//     required this.responseCode,
//     required this.result,
//     required this.responseMsg,
//   });

//   factory MobileCheck.fromJson(Map<String, dynamic> json) => MobileCheck(
//         responseCode: json["ResponseCode"],
//         result: json["Result"],
//         responseMsg: json["ResponseMsg"],
//       );

//   Map<String, dynamic> toJson() => {
//         "ResponseCode": responseCode,
//         "Result": result,
//         "ResponseMsg": responseMsg,
//       };
// }
