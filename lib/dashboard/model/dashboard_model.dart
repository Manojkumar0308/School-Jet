// To parse this JSON data, do
//
//     final adminDashBoardModel = adminDashBoardModelFromJson(jsonString);

import 'dart:convert';

AdminDashBoardModel adminDashBoardModelFromJson(String str) =>
    AdminDashBoardModel.fromJson(json.decode(str));

String adminDashBoardModelToJson(AdminDashBoardModel data) =>
    json.encode(data.toJson());

class AdminDashBoardModel {
  int? totalStudent;
  String? feesubmission;
  String? duefee;
  List<Paymodefee> paymodefee;
  AttendanceClass attendance;

  AdminDashBoardModel({
    this.totalStudent,
    this.feesubmission,
    this.duefee,
    required this.paymodefee,
    required this.attendance,
  });

  factory AdminDashBoardModel.fromJson(Map<String, dynamic> json) =>
      AdminDashBoardModel(
        totalStudent: json["TotalStudent"],
        feesubmission: json["feesubmission"],
        duefee: json["duefee"],
        paymodefee: List<Paymodefee>.from(
            json["paymodefee"].map((x) => Paymodefee.fromJson(x))),
        attendance: AttendanceClass.fromJson(json["attendance"]),
      );

  Map<String, dynamic> toJson() => {
        "TotalStudent": totalStudent,
        "feesubmission": feesubmission,
        "duefee": duefee,
        "paymodefee": List<dynamic>.from(paymodefee.map((x) => x.toJson())),
        "attendance": attendance.toJson(),
      };
}

class AttendanceClass {
  int schoolid;
  int sessionid;
  String? regno;
  String? classname;
  String? sectionname;
  String? stuname;
  List<Attlist> attlists;

  AttendanceClass({
    required this.schoolid,
    required this.sessionid,
    this.regno,
    this.classname,
    this.sectionname,
    this.stuname,
    required this.attlists,
  });

  factory AttendanceClass.fromJson(Map<String, dynamic> json) =>
      AttendanceClass(
        schoolid: json["schoolid"],
        sessionid: json["sessionid"],
        regno: json["regno"],
        classname: json["classname"],
        sectionname: json["sectionname"],
        stuname: json["stuname"],
        attlists: List<Attlist>.from(
            json["attlists"].map((x) => Attlist.fromJson(x))),
      );

  Map<String, dynamic> toJson() => {
        "schoolid": schoolid,
        "sessionid": sessionid,
        "regno": regno,
        "classname": classname,
        "sectionname": sectionname,
        "stuname": stuname,
        "attlists": List<dynamic>.from(attlists.map((x) => x.toJson())),
      };
}

class Attlist {
  Attdate attdate;
  AttendanceEnum attendance;

  Attlist({
    required this.attdate,
    required this.attendance,
  });

  factory Attlist.fromJson(Map<String, dynamic> json) => Attlist(
        attdate: attdateValues.map[json["attdate"]]!,
        attendance: attendanceEnumValues.map[json["attendance"]]!,
      );

  Map<String, dynamic> toJson() => {
        "attdate": attdateValues.reverse[attdate],
        "attendance": attendanceEnumValues.reverse[attendance],
      };
}

enum Attdate { THE_9272023112710_AM }

final attdateValues =
    EnumValues({"9/27/2023 11:27:10 AM": Attdate.THE_9272023112710_AM});

enum AttendanceEnum { A, L, P }

final attendanceEnumValues = EnumValues(
    {"A": AttendanceEnum.A, "L": AttendanceEnum.L, "P": AttendanceEnum.P});

class Paymodefee {
  String paymode;
  double amount;

  Paymodefee({
    required this.paymode,
    required this.amount,
  });

  factory Paymodefee.fromJson(Map<String, dynamic> json) => Paymodefee(
        paymode: json["paymode"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "paymode": paymode,
        "amount": amount,
      };
}

class EnumValues<T> {
  Map<String, T> map;
  late Map<T, String> reverseMap;

  EnumValues(this.map);

  Map<T, String> get reverse {
    reverseMap = map.map((k, v) => MapEntry(v, k));
    return reverseMap;
  }
}
