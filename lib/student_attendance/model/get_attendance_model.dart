// To parse this JSON data, do
//
//     final attendanceModel = attendanceModelFromJson(jsonString);

class AttendanceModel {
  int? schoolid;
  int? sessionid;
  String? regno;
  String? classname;
  String? sectionname;
  String? stuname;
  List<Attlists>? attlists;

  AttendanceModel(
      {this.schoolid,
      this.sessionid,
      this.regno,
      this.classname,
      this.sectionname,
      this.stuname,
      this.attlists});

  AttendanceModel.fromJson(Map<String, dynamic> json) {
    schoolid = json['schoolid'];
    sessionid = json['sessionid'];
    regno = json['regno'];
    classname = json['classname'];
    sectionname = json['sectionname'];
    stuname = json['stuname'];
    if (json['attlists'] != null) {
      attlists = <Attlists>[];
      json['attlists'].forEach((v) {
        attlists!.add(Attlists.fromJson(v));
      });
    }
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['schoolid'] = this.schoolid;
    data['sessionid'] = this.sessionid;
    data['regno'] = this.regno;
    data['classname'] = this.classname;
    data['sectionname'] = this.sectionname;
    data['stuname'] = this.stuname;
    if (this.attlists != null) {
      data['attlists'] = this.attlists!.map((v) => v.toJson()).toList();
    }
    return data;
  }
}

class Attlists {
  String? attdate;
  String? attendance;

  Attlists({this.attdate, this.attendance});

  Attlists.fromJson(Map<String, dynamic> json) {
    attdate = json['attdate'];
    attendance = json['attendance'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['attdate'] = this.attdate;
    data['attendance'] = this.attendance;
    return data;
  }
}
