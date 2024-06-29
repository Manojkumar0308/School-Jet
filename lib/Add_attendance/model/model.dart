class GetStudentByFilter {
  int? stuId;
  int? schoolId;
  String? regNo;
  String? rollNo;
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
    final Map<String, dynamic> data = <String, dynamic>{};
    data['StuId'] = stuId;
    data['SchoolId'] = schoolId;
    data['RegNo'] = regNo;
    data['RollNo'] = rollNo;
    data['StuName'] = stuName;
    data['gender'] = gender;
    data['FatherName'] = fatherName;
    data['DOB'] = dOB;
    data['Category'] = category;
    data['Address'] = address;
    data['ContactNo'] = contactNo;
    data['ClassId'] = classId;
    data['ClassName'] = className;
    data['SectionId'] = sectionId;
    data['SectionName'] = sectionName;
    data['SessionId'] = sessionId;
    data['IsActive'] = isActive;
    data['conveyance'] = conveyance;
    data['Stop'] = stop;
    data['photo'] = photo;
    return data;
  }
}
