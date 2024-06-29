class Exam {
  final int examid;
  final String examname;
  final String examtype;
  final int sessionid;
  final int seqNo;
  final int classNumFrom;
  final int classNumTill;
  final double? percentage; // Use double for nullable percentages

  Exam({
    required this.examid,
    required this.examname,
    required this.examtype,
    required this.sessionid,
    required this.seqNo,
    required this.classNumFrom,
    required this.classNumTill,
    this.percentage,
  });

  factory Exam.fromJson(Map<String, dynamic> json) {
    return Exam(
      examid: json['examid'],
      examname: json['examname'],
      examtype: json['examtype'],
      sessionid: json['sessionid'],
      seqNo: json['SeqNo'],
      classNumFrom: json['classNum_From'],
      classNumTill: json['classNum_till'],
      percentage: json['percentage']?.toDouble(),
    );
  }
}
