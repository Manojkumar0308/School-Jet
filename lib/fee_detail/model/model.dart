// To parse this JSON data, do
//
//     final parentFeeDetail = parentFeeDetailFromJson(jsonString);

import 'dart:convert';

List<ParentFeeDetail> parentFeeDetailFromJson(String str) =>
    List<ParentFeeDetail>.from(
        json.decode(str).map((x) => ParentFeeDetail.fromJson(x)));

String parentFeeDetailToJson(List<ParentFeeDetail> data) =>
    json.encode(List<dynamic>.from(data.map((x) => x.toJson())));

class ParentFeeDetail {
  int? stuid;
  String? stuname;
  int? receiptNo;
  double? amount;
  String? intervals;
  String? payMode;
  DateTime? transactionDate;
  String? className;
  String? sectionName;

  ParentFeeDetail({
    this.stuid,
    this.stuname,
    this.receiptNo,
    this.amount,
    this.intervals,
    this.payMode,
    this.transactionDate,
    this.className,
    this.sectionName,
  });

  factory ParentFeeDetail.fromJson(Map<String, dynamic> json) =>
      ParentFeeDetail(
        stuid: json["stuid"],
        stuname: json["stuname"],
        receiptNo: json["Receipt_no"],
        amount: json["amount"],
        intervals: json["Intervals"],
        payMode: json["PayMode"],
        transactionDate: json["Transaction_date"] == null
            ? null
            : DateTime.parse(json["Transaction_date"]),
        className: json["ClassName"],
        sectionName: json["SectionName"],
      );

  Map<String, dynamic> toJson() => {
        "stuid": stuid,
        "stuname": stuname,
        "Receipt_no": receiptNo,
        "amount": amount,
        "Intervals": intervals,
        "PayMode": payMode,
        "Transaction_date": transactionDate?.toIso8601String(),
        "ClassName": className,
        "SectionName": sectionName,
      };
}
