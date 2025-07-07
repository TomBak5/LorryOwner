// To parse this JSON data, do
//
//     final stateListModel = stateListModelFromJson(jsonString);

import 'dart:convert';

StateListModel stateListModelFromJson(String str) =>
    StateListModel.fromJson(json.decode(str));

String stateListModelToJson(StateListModel data) => json.encode(data.toJson());

class StateListModel {
  List<StateDatum> stateData;
  String responseCode;
  String result;
  String responseMsg;

  StateListModel({
    required this.stateData,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory StateListModel.fromJson(Map<String, dynamic> json) => StateListModel(
        stateData: List<StateDatum>.from(
            json["StateData"].map((x) => StateDatum.fromJson(x))),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "StateData": List<dynamic>.from(stateData.map((x) => x.toJson())),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class StateDatum {
  String id;
  String title;
  String img;
  String status;

  StateDatum({
    required this.id,
    required this.title,
    required this.img,
    required this.status,
  });

  factory StateDatum.fromJson(Map<String, dynamic> json) => StateDatum(
        id: json["id"],
        title: json["title"],
        img: json["img"],
        status: json["status"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "title": title,
        "img": img,
        "status": status,
      };
}
