// To parse this JSON data, do
//
//     final userModel = userModelFromJson(jsonString);

import 'dart:convert';

UserModel userModelFromJson(String str) => UserModel.fromJson(json.decode(str));

String userModelToJson(UserModel data) => json.encode(data.toJson());

class UserModel {
  UserLogin userLogin;
  String responseCode;
  String result;
  String responseMsg;

  UserModel({
    required this.userLogin,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory UserModel.fromJson(Map<String, dynamic> json) => UserModel(
        userLogin: UserLogin.fromJson(json["UserLogin"]),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "UserLogin": userLogin.toJson(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class UserLogin {
  String id;
  String name;
  String email;
  String mobile;
  String password;
  DateTime rdate;
  String status;
  String ccode;
  dynamic proPic;
  dynamic identityDocument;
  dynamic selfie;
  String isVerify;
  dynamic rejectComment;
  String commission;

  UserLogin({
    required this.id,
    required this.name,
    required this.email,
    required this.mobile,
    required this.password,
    required this.rdate,
    required this.status,
    required this.ccode,
    required this.proPic,
    required this.identityDocument,
    required this.selfie,
    required this.isVerify,
    required this.rejectComment,
    required this.commission,
  });

  factory UserLogin.fromJson(Map<String, dynamic> json) => UserLogin(
        id: json["id"],
        name: json["name"],
        email: json["email"],
        mobile: json["mobile"],
        password: json["password"],
        rdate: DateTime.parse(json["rdate"]),
        status: json["status"],
        ccode: json["ccode"],
        proPic: json["pro_pic"],
        identityDocument: json["identity_document"],
        selfie: json["selfie"],
        isVerify: json["is_verify"],
        rejectComment: json["reject_comment"],
        commission: json["commission"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "name": name,
        "email": email,
        "mobile": mobile,
        "password": password,
        "rdate": rdate.toIso8601String(),
        "status": status,
        "ccode": ccode,
        "pro_pic": proPic,
        "identity_document": identityDocument,
        "selfie": selfie,
        "is_verify": isVerify,
        "reject_comment": rejectComment,
        "commission": commission,
      };
}
