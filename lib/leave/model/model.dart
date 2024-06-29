// To parse this JSON data, do
//
//     final getLeaveList = getLeaveListFromJson(jsonString);

import 'dart:convert';

List<GetLeaveList> getLeaveListFromJson(String str) => List<GetLeaveList>.from(
    json.decode(str).map((x) => GetLeaveList.fromJson(x)));

String getLeaveListToJson(List<GetLeaveList> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class GetLeaveList {
  int? id;
  String? regnno;
  DateTime? fdate;
  DateTime? tdate;
  String? reason;

  GetLeaveList({
    this.id,
    this.regnno,
    this.fdate,
    this.tdate,
    this.reason,
  });

  factory GetLeaveList.fromJson(Map<String, dynamic> json) => GetLeaveList(
        id: json["id"],
        regnno: json["regnno"],
        fdate: json["fdate"] == null ? null : DateTime.parse(json["fdate"]),
        tdate: json["tdate"] == null ? null : DateTime.parse(json["tdate"]),
        reason: json["Reason"],
      );

  Map<String, dynamic> toJson() => {
        "id": id,
        "regnno": regnno,
        "fdate": fdate?.toIso8601String(),
        "tdate": tdate?.toIso8601String(),
        "Reason": reason,
      };
}
