class Homework {
  final String date;
  final String classValue;
  final String section;
  final String work;
  String? filepath;

  Homework({
    required this.date,
    required this.classValue,
    required this.section,
    required this.work,
    required this.filepath,
  });

  factory Homework.fromJson(Map<String, dynamic> json) {
    return Homework(
      date: json['Date'],
      classValue: json['Class'],
      section: json['Section'],
      work: json['Work'],
      filepath: json['Filepath'],
    );
  }
}
