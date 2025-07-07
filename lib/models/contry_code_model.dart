// To parse this JSON data, do
//
//     final contryCodeModel = contryCodeModelFromJson(jsonString);

import 'dart:convert';

ContryCodeModel contryCodeModelFromJson(String str) =>
    ContryCodeModel.fromJson(json.decode(str));

String contryCodeModelToJson(ContryCodeModel data) =>
    json.encode(data.toJson());

class ContryCodeModel {
  List<CountryCode> countryCode;
  String responseCode;
  String result;
  String responseMsg;

  ContryCodeModel({
    required this.countryCode,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory ContryCodeModel.fromJson(Map<String, dynamic> json) =>
      ContryCodeModel(
        countryCode: List<CountryCode>.from(
            json["CountryCode"].map((x) => CountryCode.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "CountryCode": List<dynamic>.from(countryCode.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class CountryCode {
  String id;
  String ccode;
  String status;

  CountryCode({
    required this.id,
    required this.ccode,
    required this.status,
  });

  factory CountryCode.fromJson(Map<String, dynamic> json) => CountryCode(
        id: json["id"],
        ccode: json["ccode"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "ccode": ccode,
        "status": status,
      };
}
