// To parse this JSON data, do
//
//     final student = studentFromJson(jsonString);

import 'dart:convert';

Student studentFromJson(String str) => Student.fromJson(json.decode(str));

String studentToJson(Student data) => json.encode(data.toJson());

class Student {
  String? regno;
  int? sessionid;
  Sp? sp;
  List<Sfp>? sfp;
  String? sduefee;
  List<dynamic>? resultdet;
  dynamic message;

  Student({
    this.regno,
    this.sessionid,
    this.sp,
    this.sfp,
    this.sduefee,
    this.resultdet,
    this.message,
  });

  factory Student.fromJson(Map<String, dynamic> json) => Student(
        regno: json["regno"],
        sessionid: json["sessionid"],
        sp: json["sp"] == null ? null : Sp.fromJson(json["sp"]),
        sfp: json["sfp"] == null
            ? []
            : List<Sfp>.from(json["sfp"]!.map((x) => Sfp.fromJson(x))),
        sduefee: json["sduefee"],
        resultdet: json["resultdet"] == null
            ? []
            : List<dynamic>.from(json["resultdet"]!.map((x) => x)),
        message: json["message"],
      );

  Map<String, dynamic> toJson() => {
        "regno": regno,
        "sessionid": sessionid,
        "sp": sp?.toJson(),
        "sfp":
            sfp == null ? [] : List<dynamic>.from(sfp!.map((x) => x.toJson())),
        "sduefee": sduefee,
        "resultdet": resultdet == null
            ? []
            : List<dynamic>.from(resultdet!.map((x) => x)),
        "message": message,
      };
}

class Sfp {
  String? dt;
  String? interval;
  double? amount;

  Sfp({
    this.dt,
    this.interval,
    this.amount,
  });

  factory Sfp.fromJson(Map<String, dynamic> json) => Sfp(
        dt: json["dt"],
        interval: json["interval"],
        amount: json["amount"],
      );

  Map<String, dynamic> toJson() => {
        "dt": dt,
        "interval": interval,
        "amount": amount,
      };
}

class Sp {
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
  dynamic photo;
  String? mothername;
  String? religion;
  String? postaladdress;
  String? altcontact;
  String? adharno;
  String? foccupation;
  String? moccupation;
  String? fqualification;
  String? mqualification;
  String? house;
  String? firstadmissiondate;
  String? firstadmissionclass;

  Sp(
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
      this.photo,
      this.mothername,
      this.religion,
      this.postaladdress,
      this.altcontact,
      this.adharno,
      this.foccupation,
      this.moccupation,
      this.fqualification,
      this.mqualification,
      this.house,
      this.firstadmissiondate,
      this.firstadmissionclass});

  factory Sp.fromJson(Map<String, dynamic> json) => Sp(
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
      photo: json["photo"],
      mothername: json["mothername"],
      religion: json["religion"],
      postaladdress: json["postaladdress"],
      altcontact: json["altcontact"],
      adharno: json["adharno"],
      foccupation: json["foccupation"],
      moccupation: json["moccupation"],
      fqualification: json["fqualification"],
      mqualification: json["mqualification"],
      house: json["house"],
      firstadmissiondate: json["firstadmissiondate"],
      firstadmissionclass: json["firstadmissionclass"]);

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
        "photo": photo,
        "mothername": mothername,
        "religion": religion,
        "postaladdress": postaladdress,
        "altcontact": altcontact,
        "adharno": adharno,
        "foccupation": foccupation,
        "moccupation": moccupation,
        "fqualification": fqualification,
        "mqualification": mqualification,
        "house": house,
        "firstadmissiondate": firstadmissiondate,
        "firstadmissionclass": firstadmissionclass
      };
}
