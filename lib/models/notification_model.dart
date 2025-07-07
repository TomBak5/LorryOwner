// To parse this JSON data, do
//
//     final notificationModel = notificationModelFromJson(jsonString);

import 'dart:convert';

NotificationModel notificationModelFromJson(String str) =>
    NotificationModel.fromJson(json.decode(str));

String notificationModelToJson(NotificationModel data) =>
    json.encode(data.toJson());

class NotificationModel {
  List<NotificationDatum> notificationData;
  String responseCode;
  String result;
  String responseMsg;

  NotificationModel({
    required this.notificationData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      NotificationModel(
        notificationData: List<NotificationDatum>.from(
            json["NotificationData"].map((x) => NotificationDatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "NotificationData":
            List<dynamic>.from(notificationData.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class NotificationDatum {
  String id;
  String rid;
  String msg;
  DateTime date;

  NotificationDatum({
    required this.id,
    required this.rid,
    required this.msg,
    required this.date,
  });

  factory NotificationDatum.fromJson(Map<String, dynamic> json) =>
      NotificationDatum(
        id: json["id"],
        rid: json["rid"],
        msg: json["msg"],
        date: DateTime.parse(json["date"]),
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "rid": rid,
        "msg": msg,
        "date": date.toIso8601String(),
      };
}
