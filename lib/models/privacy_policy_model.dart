// To parse this JSON data, do
//
//     final privacyPolicyModel = privacyPolicyModelFromJson(jsonString);

import 'dart:convert';

PrivacyPolicyModel privacyPolicyModelFromJson(String str) =>
    PrivacyPolicyModel.fromJson(json.decode(str));

String privacyPolicyModelToJson(PrivacyPolicyModel data) =>
    json.encode(data.toJson());

class PrivacyPolicyModel {
  List<Pagelist> pagelist;
  String responseCode;
  String result;
  String responseMsg;

  PrivacyPolicyModel({
    required this.pagelist,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory PrivacyPolicyModel.fromJson(Map<String, dynamic> json) =>
      PrivacyPolicyModel(
        pagelist: List<Pagelist>.from(
            json["pagelist"].map((x) => Pagelist.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "pagelist": List<dynamic>.from(pagelist.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Pagelist {
  String title;
  String description;

  Pagelist({
    required this.title,
    required this.description,
  });

  factory Pagelist.fromJson(Map<String, dynamic> json) => Pagelist(
        title: json["title"],
        description: json["description"],
      );

  Map<String, dynamic> toJson() => {
        "title": title,
        "description": description,
      };
}
