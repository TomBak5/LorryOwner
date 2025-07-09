// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel? data) => json.encode(data?.toJson());

class UserModel {
  UserLogin? userLogin;
  String? responseCode;
  String? result;
  String? responseMsg;

  UserModel({
    this.userLogin,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userLogin: json["UserLogin"] != null ? UserLogin.fromJson(json["UserLogin"]) : null,
        responseCode: json["ResponseCode"]?.toString(),
        result: json["Result"]?.toString(),
        responseMsg: json["ResponseMsg"]?.toString(),
      );

  Map<String, dynamic> toJson() => {
        "UserLogin": userLogin?.toJson(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class UserLogin {
  String? id;
  String? name;
  String? email;
  String? mobile;
  String? password;
  DateTime? rdate;
  String? status;
  String? ccode;
  dynamic proPic;
  dynamic identityDocument;
  dynamic selfie;
  String? isVerify;
  dynamic rejectComment;
  String? commission;
  String? userRole; // Add user role field

  UserLogin({
    this.id,
    this.name,
    this.email,
    this.mobile,
    this.password,
    this.rdate,
    this.status,
    this.ccode,
    this.proPic,
    this.identityDocument,
    this.selfie,
    this.isVerify,
    this.rejectComment,
    this.commission,
    this.userRole, // Add to constructor
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
        id: json["id"]?.toString() ?? '',
        name: json["name"]?.toString() ?? '',
        email: json["email"]?.toString() ?? '',
        mobile: json["mobile"]?.toString() ?? '',
        password: json["password"]?.toString() ?? '',
        rdate: json["rdate"] != null && json["rdate"] != '' ? DateTime.tryParse(json["rdate"]) : null,
        status: json["status"]?.toString() ?? '',
        ccode: json["ccode"]?.toString() ?? '',
        proPic: json["pro_pic"],
        identityDocument: json["identity_document"],
        selfie: json["selfie"],
        isVerify: json["is_verify"]?.toString() ?? '',
        rejectComment: json["reject_comment"],
        commission: json["commission"]?.toString() ?? '',
        userRole: json["user_role"]?.toString() ?? "driver", // Default to driver if not provided
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "password": password,
        "rdate": rdate?.toIso8601String(),
        "status": status,
        "ccode": ccode,
        "pro_pic": proPic,
        "identity_document": identityDocument,
        "selfie": selfie,
        "is_verify": isVerify,
        "reject_comment": rejectComment,
        "commission": commission,
        "user_role": userRole, // Add to JSON
      };
}
