class GetStudentByFilter {
  int? stuId;
  int? schoolId;
  String? regNo;
  int? rollNo;
  String? stuName;
  String? gender;
  String? fatherName;
  String? dOB;
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

  GetStudentByFilter(
      {this.stuId,
        this.schoolId,
        this.regNo,
        this.rollNo,
        this.stuName,
        this.gender,
        this.fatherName,
        this.dOB,
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

    GetStudentByFilter.fromJson(Map<String, dynamic> json) {
    stuId = json['StuId'];
    schoolId = json['SchoolId'];
    regNo = json['RegNo'];
    rollNo = json['RollNo'];
    stuName = json['StuName'];
    gender = json['gender'];
    fatherName = json['FatherName'];
    dOB = json['DOB'];
    category = json['Category'];
    address = json['Address'];
    contactNo = json['ContactNo'];
    classId = json['ClassId'];
    className = json['ClassName'];
    sectionId = json['SectionId'];
    sectionName = json['SectionName'];
    sessionId = json['SessionId'];
    isActive = json['IsActive'];
    conveyance = json['conveyance'];
    stop = json['Stop'];
    photo = json['photo'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['StuId'] = this.stuId;
    data['SchoolId'] = this.schoolId;
    data['RegNo'] = this.regNo;
    data['RollNo'] = this.rollNo;
    data['StuName'] = this.stuName;
    data['gender'] = this.gender;
    data['FatherName'] = this.fatherName;
    data['DOB'] = this.dOB;
    data['Category'] = this.category;
    data['Address'] = this.address;
    data['ContactNo'] = this.contactNo;
    data['ClassId'] = this.classId;
    data['ClassName'] = this.className;
    data['SectionId'] = this.sectionId;
    data['SectionName'] = this.sectionName;
    data['SessionId'] = this.sessionId;
    data['IsActive'] = this.isActive;
    data['conveyance'] = this.conveyance;
    data['Stop'] = this.stop;
    data['photo'] = this.photo;
    return data;
  }
}
