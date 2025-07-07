// To parse this JSON data, do
//
//     final bookedLorryModel12 = bookedLorryModel12FromJson(jsonString);

import 'dart:convert';

BookedLorryModel12 bookedLorryModel12FromJson(String str) => BookedLorryModel12.fromJson(json.decode(str));

String bookedLorryModel12ToJson(BookedLorryModel12 data) => json.encode(data.toJson());

class BookedLorryModel12 {
  List<BookHistory> bookHistory;
  String responseCode;
  String result;
  String responseMsg;

  BookedLorryModel12({
    required this.bookHistory,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory BookedLorryModel12.fromJson(Map<String, dynamic> json) => BookedLorryModel12(
    bookHistory: List<BookHistory>.from(json["BookHistory"].map((x) => BookHistory.fromJson(x))),
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
  );

  Map<String, dynamic> toJson() => {
    "BookHistory": List<dynamic>.from(bookHistory.map((x) => x.toJson())),
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
  };
}

class BookHistory {
  String lorryId;
  String vehicleId;
  String lorryOwnerId;
  String lorryOwnerTitle;
  String lorryOwnerImg;
  String lorryImg;
  String lorryTitle;
  String weight;
  String currLocation;
  String pickupPoint;
  String dropPoint;
  int routesCount;
  String rcVerify;
  String lorryNo;
  String review;
  String loadDistance;

  BookHistory({
    required this.lorryId,
    required this.vehicleId,
    required this.lorryOwnerId,
    required this.lorryOwnerTitle,
    required this.lorryOwnerImg,
    required this.lorryImg,
    required this.lorryTitle,
    required this.weight,
    required this.currLocation,
    required this.pickupPoint,
    required this.dropPoint,
    required this.routesCount,
    required this.rcVerify,
    required this.lorryNo,
    required this.review,
    required this.loadDistance,
  });

  factory BookHistory.fromJson(Map<String, dynamic> json) => BookHistory(
    lorryId: json["lorry_id"],
    vehicleId: json["vehicle_id"],
    lorryOwnerId: json["lorry_owner_id"],
    lorryOwnerTitle: json["lorry_owner_title"],
    lorryOwnerImg: json["lorry_owner_img"],
    lorryImg: json["lorry_img"],
    lorryTitle: json["lorry_title"],
    weight: json["weight"],
    currLocation: json["curr_location"],
    pickupPoint: json["pickup_point"],
    dropPoint: json["drop_point"],
    routesCount: json["routes_count"],
    rcVerify: json["rc_verify"],
    lorryNo: json["lorry_no"],
    review: json["review"],
    loadDistance: json["load_distance"],
  );

  Map<String, dynamic> toJson() => {
    "lorry_id": lorryId,
    "vehicle_id": vehicleId,
    "lorry_owner_id": lorryOwnerId,
    "lorry_owner_title": lorryOwnerTitle,
    "lorry_owner_img": lorryOwnerImg,
    "lorry_img": lorryImg,
    "lorry_title": lorryTitle,
    "weight": weight,
    "curr_location": currLocation,
    "pickup_point": pickupPoint,
    "drop_point": dropPoint,
    "routes_count": routesCount,
    "rc_verify": rcVerify,
    "lorry_no": lorryNo,
    "review": review,
    "load_distance": loadDistance,
  };
}
