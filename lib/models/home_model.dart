// To parse this JSON data, do
//
//     final homeModel = homeModelFromJson(jsonString);

import 'dart:convert';

HomeModel homeModelFromJson(String str) => HomeModel.fromJson(json.decode(str));

String homeModelToJson(HomeModel data) => json.encode(data.toJson());

class HomeModel {
  String? responseCode;
  String? result;
  String? responseMsg;
  HomeData? homeData;

  HomeModel({
    this.responseCode,
    this.result,
    this.responseMsg,
    this.homeData,
  });

  factory HomeModel.fromJson(Map<String, dynamic> json) => HomeModel(
    responseCode: json["ResponseCode"],
    result: json["Result"],
    responseMsg: json["ResponseMsg"],
    homeData: json["HomeData"] == null ? null : HomeData.fromJson(json["HomeData"]),
  );

  Map<String, dynamic> toJson() => {
    "ResponseCode": responseCode,
    "Result": result,
    "ResponseMsg": responseMsg,
    "HomeData": homeData?.toJson(),
  };
}

class HomeData {
  List<Banner>? banner;
  List<Statelist>? statelist;
  String? currency;
  List<Mylorrylist>? mylorrylist;
  String? isVerify;
  String? topMsg;
  String? gKey;

  HomeData({
    this.banner,
    this.statelist,
    this.currency,
    this.mylorrylist,
    this.isVerify,
    this.topMsg,
    this.gKey,
  });

  factory HomeData.fromJson(Map<String, dynamic> json) => HomeData(
    banner: json["Banner"] == null ? [] : List<Banner>.from(json["Banner"]!.map((x) => Banner.fromJson(x))),
    statelist: json["Statelist"] == null ? [] : List<Statelist>.from(json["Statelist"]!.map((x) => Statelist.fromJson(x))),
    currency: json["currency"],
    mylorrylist: json["mylorrylist"] == null ? [] : List<Mylorrylist>.from(json["mylorrylist"]!.map((x) => Mylorrylist.fromJson(x))),
    isVerify: json["is_verify"],
    topMsg: json["top_msg"],
    gKey: json["g_key"],
  );

  Map<String, dynamic> toJson() => {
    "Banner": banner == null ? [] : List<dynamic>.from(banner!.map((x) => x.toJson())),
    "Statelist": statelist == null ? [] : List<dynamic>.from(statelist!.map((x) => x.toJson())),
    "currency": currency,
    "mylorrylist": mylorrylist == null ? [] : List<dynamic>.from(mylorrylist!.map((x) => x.toJson())),
    "is_verify": isVerify,
    "top_msg": topMsg,
    "g_key": gKey,
  };
}

class Banner {
  String? id;
  String? img;

  Banner({
    this.id,
    this.img,
  });

  factory Banner.fromJson(Map<String, dynamic> json) => Banner(
    id: json["id"],
    img: json["img"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "img": img,
  };
}

class Mylorrylist {
  String? id;
  String? lorryImg;
  String? lorryTitle;
  String? weight;
  String? rcVerify;
  String? lorryNo;
  int? routes;
  List<String>? totalRoutes;
  String? description;

  Mylorrylist({
    this.id,
    this.lorryImg,
    this.lorryTitle,
    this.weight,
    this.rcVerify,
    this.lorryNo,
    this.routes,
    this.totalRoutes,
    this.description,
  });

  factory Mylorrylist.fromJson(Map<String, dynamic> json) => Mylorrylist(
    id: json["id"],
    lorryImg: json["lorry_img"],
    lorryTitle: json["lorry_title"],
    weight: json["weight"],
    rcVerify: json["rc_verify"],
    lorryNo: json["lorry_no"],
    routes: json["routes"],
    totalRoutes: json["total_routes"] == null ? [] : List<String>.from(json["total_routes"]!.map((x) => x)),
    description: json["description"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "lorry_img": lorryImg,
    "lorry_title": lorryTitle,
    "weight": weight,
    "rc_verify": rcVerify,
    "lorry_no": lorryNo,
    "routes": routes,
    "total_routes": totalRoutes == null ? [] : List<dynamic>.from(totalRoutes!.map((x) => x)),
    "description": description,
  };
}

class Statelist {
  String? id;
  String? title;
  String? img;
  int? totalLoad;
  int? totalLorry;

  Statelist({
    this.id,
    this.title,
    this.img,
    this.totalLoad,
    this.totalLorry,
  });

  factory Statelist.fromJson(Map<String, dynamic> json) => Statelist(
    id: json["id"],
    title: json["title"],
    img: json["img"],
    totalLoad: json["total_load"],
    totalLorry: json["total_lorry"],
  );

  Map<String, dynamic> toJson() => {
    "id": id,
    "title": title,
    "img": img,
    "total_load": totalLoad,
    "total_lorry": totalLorry,
  };
}
