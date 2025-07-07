// To parse this JSON data, do
//
//     final subdriverlistModel = subdriverlistModelFromJson(jsonString);

import 'dart:convert';

SubdriverlistModel subdriverlistModelFromJson(String str) => SubdriverlistModel.fromJson(json.decode(str));

String subdriverlistModelToJson(SubdriverlistModel data) => json.encode(data.toJson());

class SubdriverlistModel {
  List<SubDriverList>? subDriverList;
  String? responseCode;
  String? result;
  String? responseMsg;

  SubdriverlistModel({
    this.subDriverList,
    this.responseCode,
    this.result,
    this.responseMsg,
  });

  factory SubdriverlistModel.fromJson(Map<String, dynamic> json) => SubdriverlistModel(
    subDriverList: json["SubDriverList"] == null ? [] : List<SubDriverList>.from(json["SubDriverList"]!.map((x) => SubDriverList.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "SubDriverList": subDriverList == null ? [] : List<dynamic>.from(subDriverList!.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class SubDriverList {
  String? id;
  String? ownerId;
  String? lorryId;
  String? name;
  String? email;
  String? password;
  String? phone;
  String? ccode;
  String? lorryNo;

  SubDriverList({
    this.id,
    this.ownerId,
    this.lorryId,
    this.name,
    this.email,
    this.password,
    this.phone,
    this.ccode,
    this.lorryNo,
  });

  factory SubDriverList.fromJson(Map<String, dynamic> json) => SubDriverList(
    id: json["id"],
    ownerId: json["owner_id"],
    lorryId: json["lorry_id"],
    name: json["name"],
    email: json["email"],
    password: json["password"],
    phone: json["phone"],
    ccode: json["ccode"],
    lorryNo: json["lorry_no"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "owner_id": ownerId,
    "lorry_id": lorryId,
    "name": name,
    "email": email,
    "password": password,
    "phone": phone,
    "ccode": ccode,
    "lorry_no": lorryNo,
  };
}
