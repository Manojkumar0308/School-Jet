// To parse this JSON data, do
//
//     final profile = profileFromJson(jsonString);

import 'dart:convert';

Profile profileFromJson(String str) => Profile.fromJson(json.decode(str));

String profileToJson(Profile data) => json.encode(data.toJson());

class Profile {
  List<Stm> stm;

  Profile({
    required this.stm,
  });

  factory Profile.fromJson(Map<String, dynamic> json) => Profile(
        stm: json["stm"] != null
            ? List<Stm>.from(json["stm"].map((x) => Stm.fromJson(x)))
            : [],
      );

  Map<String, dynamic> toJson() => {
        "stm": List<dynamic>.from(stm.map((x) => x.toJson())),
      };
}

class Stm {
  int? stuId;
  int? schoolId;
  String? regNo;
  dynamic rollNo;
  String? stuName;
  String? gender;
  String? fatherName;
  String? dob;
  String? category;
  String? address;
  String? contactNo;
  int? classId;
  String? className;
  int? sectionId;
  String? sectionName;
  int? sessionId;
  bool? isActive;
  String? conveyance;
  String? stop;
  String? photo;

  Stm(
      {this.stuId,
      this.schoolId,
      this.regNo,
      this.rollNo,
      this.stuName,
      this.gender,
      this.fatherName,
      this.dob,
      this.category,
      this.address,
      this.contactNo,
      this.classId,
      this.className,
      this.sectionId,
      this.sectionName,
      this.sessionId,
      this.isActive,
      this.conveyance,
      this.stop,
      this.photo});

  factory Stm.fromJson(Map<String, dynamic> json) => Stm(
      stuId: json["StuId"],
      schoolId: json["SchoolId"],
      regNo: json["RegNo"],
      rollNo: json["RollNo"],
      stuName: json["StuName"],
      gender: json["gender"],
      fatherName: json["FatherName"],
      dob: json["DOB"],
      category: json["Category"],
      address: json["Address"],
      contactNo: json["ContactNo"],
      classId: json["ClassId"],
      className: json["ClassName"],
      sectionId: json["SectionId"],
      sectionName: json["SectionName"],
      sessionId: json["SessionId"],
      isActive: json["IsActive"],
      conveyance: json["conveyance"],
      stop: json["Stop"],
      photo: json["photo"]);

  Map<String, dynamic> toJson() => {
        "StuId": stuId,
        "SchoolId": schoolId,
        "RegNo": regNo,
        "RollNo": rollNo,
        "StuName": stuName,
        "gender": gender,
        "FatherName": fatherName,
        "DOB": dob,
        "Category": category,
        "Address": address,
        "ContactNo": contactNo,
        "ClassId": classId,
        "ClassName": className,
        "SectionId": sectionId,
        "SectionName": sectionName,
        "SessionId": sessionId,
        "IsActive": isActive,
        "conveyance": conveyance,
        "Stop": stop,
        "photo": photo
      };
}
