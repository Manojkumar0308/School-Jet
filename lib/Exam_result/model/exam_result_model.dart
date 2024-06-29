// To parse this JSON data, do
//
//     final examResult = examResultFromJson(jsonString);

import 'dart:convert';

ExamResult examResultFromJson(String str) =>
    ExamResult.fromJson(json.decode(str));

String examResultToJson(ExamResult data) => json.encode(data.toJson());

class ExamResult {
  String? regno;
  int? sessionid;
  int? examid;
  List<Result>? result;

  ExamResult({
    this.regno,
    this.sessionid,
    this.examid,
    this.result,
  });

  factory ExamResult.fromJson(Map<String, dynamic> json) => ExamResult(
        regno: json["regno"],
        sessionid: json["sessionid"],
        examid: json["examid"],
        result: json["Result"] == null
            ? []
            : List<Result>.from(json["Result"]!.map((x) => Result.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "regno": regno,
        "sessionid": sessionid,
        "examid": examid,
        "Result": result == null
            ? []
            : List<dynamic>.from(result!.map((x) => x.toJson())),
      };
}

class Result {
  int? id;
  int? examid;
  int? stuid;
  String? sub1;
  String? sub2;
  String? sub3;
  String? sub4;
  String? sub5;
  dynamic sub6;
  dynamic sub7;
  dynamic sub8;
  dynamic sub9;
  dynamic sub10;
  dynamic sub11;
  dynamic sub12;
  dynamic sub13;
  dynamic sub14;
  dynamic sub15;
  dynamic sub16;
  dynamic sub17;
  dynamic sub18;
  dynamic sub19;
  dynamic sub20;
  String? total;
  dynamic sub21;
  dynamic sub22;
  dynamic sub23;
  dynamic sub24;
  dynamic sub25;
  int? mmsub1;
  int? mmsub2;
  int? mmsub3;
  int? mmsub4;
  int? mmsub5;
  int? mmsub6;
  int? mmsub7;
  int? mmsub8;
  int? mmsub9;
  int? mmsub10;
  int? mmsub11;
  int? mmsub12;
  int? mmsub13;
  int? mmsub14;
  int? mmsub15;
  int? mmsub16;
  int? mmsub17;
  int? mmsub18;
  int? mmsub19;
  int? mmsub20;
  int? mmsub21;
  int? mmsub22;
  int? mmsub23;
  int? mmsub24;
  int? mmsub25;
  String? subjectsub1;
  String? subjectsub2;
  String? subjectsub3;
  String? subjectsub4;
  String? subjectsub5;
  String? subjectsub6;
  String? subjectsub7;
  String? subjectsub8;
  String? subjectsub9;
  String? subjectsub10;
  String? subjectsub11;
  String? subjectsub12;
  String? subjectsub13;
  String? subjectsub14;
  String? subjectsub15;
  String? subjectsub16;
  String? subjectsub17;
  String? subjectsub18;
  String? subjectsub19;
  String? subjectsub20;
  String? subjectsub21;
  String? subjectsub22;
  String? subjectsub23;
  String? subjectsub24;
  String? subjectsub25;

  Result({
    this.id,
    this.examid,
    this.stuid,
    this.sub1,
    this.sub2,
    this.sub3,
    this.sub4,
    this.sub5,
    this.sub6,
    this.sub7,
    this.sub8,
    this.sub9,
    this.sub10,
    this.sub11,
    this.sub12,
    this.sub13,
    this.sub14,
    this.sub15,
    this.sub16,
    this.sub17,
    this.sub18,
    this.sub19,
    this.sub20,
    this.total,
    this.sub21,
    this.sub22,
    this.sub23,
    this.sub24,
    this.sub25,
    this.mmsub1,
    this.mmsub2,
    this.mmsub3,
    this.mmsub4,
    this.mmsub5,
    this.mmsub6,
    this.mmsub7,
    this.mmsub8,
    this.mmsub9,
    this.mmsub10,
    this.mmsub11,
    this.mmsub12,
    this.mmsub13,
    this.mmsub14,
    this.mmsub15,
    this.mmsub16,
    this.mmsub17,
    this.mmsub18,
    this.mmsub19,
    this.mmsub20,
    this.mmsub21,
    this.mmsub22,
    this.mmsub23,
    this.mmsub24,
    this.mmsub25,
    this.subjectsub1,
    this.subjectsub2,
    this.subjectsub3,
    this.subjectsub4,
    this.subjectsub5,
    this.subjectsub6,
    this.subjectsub7,
    this.subjectsub8,
    this.subjectsub9,
    this.subjectsub10,
    this.subjectsub11,
    this.subjectsub12,
    this.subjectsub13,
    this.subjectsub14,
    this.subjectsub15,
    this.subjectsub16,
    this.subjectsub17,
    this.subjectsub18,
    this.subjectsub19,
    this.subjectsub20,
    this.subjectsub21,
    this.subjectsub22,
    this.subjectsub23,
    this.subjectsub24,
    this.subjectsub25,
  });

  factory Result.fromJson(Map<String, dynamic> json) => Result(
        id: json["id"],
        examid: json["examid"],
        stuid: json["stuid"],
        sub1: json["sub1"],
        sub2: json["sub2"],
        sub3: json["sub3"],
        sub4: json["sub4"],
        sub5: json["sub5"],
        sub6: json["sub6"],
        sub7: json["sub7"],
        sub8: json["sub8"],
        sub9: json["sub9"],
        sub10: json["sub10"],
        sub11: json["sub11"],
        sub12: json["sub12"],
        sub13: json["sub13"],
        sub14: json["sub14"],
        sub15: json["sub15"],
        sub16: json["sub16"],
        sub17: json["sub17"],
        sub18: json["sub18"],
        sub19: json["sub19"],
        sub20: json["sub20"],
        total: json["total"],
        sub21: json["sub21"],
        sub22: json["sub22"],
        sub23: json["sub23"],
        sub24: json["sub24"],
        sub25: json["sub25"],
        mmsub1: json["mmsub1"],
        mmsub2: json["mmsub2"],
        mmsub3: json["mmsub3"],
        mmsub4: json["mmsub4"],
        mmsub5: json["mmsub5"],
        mmsub6: json["mmsub6"],
        mmsub7: json["mmsub7"],
        mmsub8: json["mmsub8"],
        mmsub9: json["mmsub9"],
        mmsub10: json["mmsub10"],
        mmsub11: json["mmsub11"],
        mmsub12: json["mmsub12"],
        mmsub13: json["mmsub13"],
        mmsub14: json["mmsub14"],
        mmsub15: json["mmsub15"],
        mmsub16: json["mmsub16"],
        mmsub17: json["mmsub17"],
        mmsub18: json["mmsub18"],
        mmsub19: json["mmsub19"],
        mmsub20: json["mmsub20"],
        mmsub21: json["mmsub21"],
        mmsub22: json["mmsub22"],
        mmsub23: json["mmsub23"],
        mmsub24: json["mmsub24"],
        mmsub25: json["mmsub25"],
        subjectsub1: json["subjectsub1"],
        subjectsub2: json["subjectsub2"],
        subjectsub3: json["subjectsub3"],
        subjectsub4: json["subjectsub4"],
        subjectsub5: json["subjectsub5"],
        subjectsub6: json["subjectsub6"],
        subjectsub7: json["subjectsub7"],
        subjectsub8: json["subjectsub8"],
        subjectsub9: json["subjectsub9"],
        subjectsub10: json["subjectsub10"],
        subjectsub11: json["subjectsub11"],
        subjectsub12: json["subjectsub12"],
        subjectsub13: json["subjectsub13"],
        subjectsub14: json["subjectsub14"],
        subjectsub15: json["subjectsub15"],
        subjectsub16: json["subjectsub16"],
        subjectsub17: json["subjectsub17"],
        subjectsub18: json["subjectsub18"],
        subjectsub19: json["subjectsub19"],
        subjectsub20: json["subjectsub20"],
        subjectsub21: json["subjectsub21"],
        subjectsub22: json["subjectsub22"],
        subjectsub23: json["subjectsub23"],
        subjectsub24: json["subjectsub24"],
        subjectsub25: json["subjectsub25"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "examid": examid,
        "stuid": stuid,
        "sub1": sub1,
        "sub2": sub2,
        "sub3": sub3,
        "sub4": sub4,
        "sub5": sub5,
        "sub6": sub6,
        "sub7": sub7,
        "sub8": sub8,
        "sub9": sub9,
        "sub10": sub10,
        "sub11": sub11,
        "sub12": sub12,
        "sub13": sub13,
        "sub14": sub14,
        "sub15": sub15,
        "sub16": sub16,
        "sub17": sub17,
        "sub18": sub18,
        "sub19": sub19,
        "sub20": sub20,
        "total": total,
        "sub21": sub21,
        "sub22": sub22,
        "sub23": sub23,
        "sub24": sub24,
        "sub25": sub25,
        "mmsub1": mmsub1,
        "mmsub2": mmsub2,
        "mmsub3": mmsub3,
        "mmsub4": mmsub4,
        "mmsub5": mmsub5,
        "mmsub6": mmsub6,
        "mmsub7": mmsub7,
        "mmsub8": mmsub8,
        "mmsub9": mmsub9,
        "mmsub10": mmsub10,
        "mmsub11": mmsub11,
        "mmsub12": mmsub12,
        "mmsub13": mmsub13,
        "mmsub14": mmsub14,
        "mmsub15": mmsub15,
        "mmsub16": mmsub16,
        "mmsub17": mmsub17,
        "mmsub18": mmsub18,
        "mmsub19": mmsub19,
        "mmsub20": mmsub20,
        "mmsub21": mmsub21,
        "mmsub22": mmsub22,
        "mmsub23": mmsub23,
        "mmsub24": mmsub24,
        "mmsub25": mmsub25,
        "subjectsub1": subjectsub1,
        "subjectsub2": subjectsub2,
        "subjectsub3": subjectsub3,
        "subjectsub4": subjectsub4,
        "subjectsub5": subjectsub5,
        "subjectsub6": subjectsub6,
        "subjectsub7": subjectsub7,
        "subjectsub8": subjectsub8,
        "subjectsub9": subjectsub9,
        "subjectsub10": subjectsub10,
        "subjectsub11": subjectsub11,
        "subjectsub12": subjectsub12,
        "subjectsub13": subjectsub13,
        "subjectsub14": subjectsub14,
        "subjectsub15": subjectsub15,
        "subjectsub16": subjectsub16,
        "subjectsub17": subjectsub17,
        "subjectsub18": subjectsub18,
        "subjectsub19": subjectsub19,
        "subjectsub20": subjectsub20,
        "subjectsub21": subjectsub21,
        "subjectsub22": subjectsub22,
        "subjectsub23": subjectsub23,
        "subjectsub24": subjectsub24,
        "subjectsub25": subjectsub25,
      };
}
