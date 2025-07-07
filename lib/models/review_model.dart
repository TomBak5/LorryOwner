// To parse this JSON data, do
//
//     final reviewModel = reviewModelFromJson(jsonString);

import 'dart:convert';

ReviewModel reviewModelFromJson(String str) =>
    ReviewModel.fromJson(json.decode(str));

String reviewModelToJson(ReviewModel data) => json.encode(data.toJson());

class ReviewModel {
  Lorrizprofile lorrizprofile;
  String responseCode;
  String result;
  String responseMsg;

  ReviewModel({
    required this.lorrizprofile,
    required this.responseCode,
    required this.result,
    required this.responseMsg,
  });

  factory ReviewModel.fromJson(Map<String, dynamic> json) => ReviewModel(
        lorrizprofile: Lorrizprofile.fromJson(json["lorrizprofile"]),
        responseCode: json["ResponseCode"],
        result: json["Result"],
        responseMsg: json["ResponseMsg"],
      );

  Map<String, dynamic> toJson() => {
        "lorrizprofile": lorrizprofile.toJson(),
        "ResponseCode": responseCode,
        "Result": result,
        "ResponseMsg": responseMsg,
      };
}

class Lorrizprofile {
  String name;
  String proPic;
  DateTime rdate;
  String review;
  int totalReview;
  int totalLorry;
  List<TotalReviewUserWise> totalReviewUserWise;

  Lorrizprofile({
    required this.name,
    required this.proPic,
    required this.rdate,
    required this.review,
    required this.totalReview,
    required this.totalLorry,
    required this.totalReviewUserWise,
  });

  factory Lorrizprofile.fromJson(Map<String, dynamic> json) => Lorrizprofile(
        name: json["name"],
        proPic: json["pro_pic"],
        rdate: DateTime.parse(json["rdate"]),
        review: json["review"],
        totalReview: json["total_review"],
        totalLorry: json["total_lorry"],
        totalReviewUserWise: List<TotalReviewUserWise>.from(
            json["total_review_user_wise"]
                .map((x) => TotalReviewUserWise.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "name": name,
        "pro_pic": proPic,
        "rdate": rdate.toIso8601String(),
        "review": review,
        "total_review": totalReview,
        "total_lorry": totalLorry,
        "total_review_user_wise":
            List<dynamic>.from(totalReviewUserWise.map((x) => x.toJson())),
      };
}

class TotalReviewUserWise {
  String userImg;
  String customername;
  String rateNumber;
  String rateText;

  TotalReviewUserWise({
    required this.userImg,
    required this.customername,
    required this.rateNumber,
    required this.rateText,
  });

  factory TotalReviewUserWise.fromJson(Map<String, dynamic> json) =>
      TotalReviewUserWise(
        userImg: json["user_img"],
        customername: json["customername"],
        rateNumber: json["rate_number"],
        rateText: json["rate_text"],
      );

  Map<String, dynamic> toJson() => {
        "user_img": userImg,
        "customername": customername,
        "rate_number": rateNumber,
        "rate_text": rateText,
      };
}
