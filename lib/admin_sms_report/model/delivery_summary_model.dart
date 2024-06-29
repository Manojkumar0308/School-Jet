// To parse this JSON data, do
//
//     final smsDeliverySummary = smsDeliverySummaryFromJson(jsonString);

import 'dart:convert';

SmsDeliverySummary smsDeliverySummaryFromJson(String str) =>
    SmsDeliverySummary.fromJson(json.decode(str));

String smsDeliverySummaryToJson(SmsDeliverySummary data) =>
    json.encode(data.toJson());

class SmsDeliverySummary {
  DateTime? fdate;
  DateTime? tdate;
  int? nsmssent;
  int? nsmsdelivered;
  int? nsmsnotdelivered;
  int? nsmsexpired;
  int? nsmsinvalidno;
  int? nsmsother;
  int? ndlrnotfound;
  String? rstr;
  String? balance_sms;

  SmsDeliverySummary(
      {this.fdate,
      this.tdate,
      this.nsmssent,
      this.nsmsdelivered,
      this.nsmsnotdelivered,
      this.nsmsexpired,
      this.nsmsinvalidno,
      this.nsmsother,
      this.ndlrnotfound,
      this.rstr,
      this.balance_sms});

  factory SmsDeliverySummary.fromJson(Map<String, dynamic> json) =>
      SmsDeliverySummary(
          fdate: json["fdate"] == null ? null : DateTime.parse(json["fdate"]),
          tdate: json["tdate"] == null ? null : DateTime.parse(json["tdate"]),
          nsmssent: json["nsmssent"],
          nsmsdelivered: json["nsmsdelivered"],
          nsmsnotdelivered: json["nsmsnotdelivered"],
          nsmsexpired: json["nsmsexpired"],
          nsmsinvalidno: json["nsmsinvalidno"],
          nsmsother: json["nsmsother"],
          ndlrnotfound: json["ndlrnotfound"],
          rstr: json["rstr"],
          balance_sms: json["balance_sms"]);

  Map<String, dynamic> toJson() => {
        "fdate": fdate?.toIso8601String(),
        "tdate": tdate?.toIso8601String(),
        "nsmssent": nsmssent,
        "nsmsdelivered": nsmsdelivered,
        "nsmsnotdelivered": nsmsnotdelivered,
        "nsmsexpired": nsmsexpired,
        "nsmsinvalidno": nsmsinvalidno,
        "nsmsother": nsmsother,
        "ndlrnotfound": ndlrnotfound,
        "rstr": rstr,
        "balance_sms": balance_sms
      };
}
