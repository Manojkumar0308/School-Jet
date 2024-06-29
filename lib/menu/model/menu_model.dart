//model class for gridview acc. to userType.
class Item {
  final String text;
  final String imageUrl;

  Item({required this.text, required this.imageUrl});
}

//model class for teacher iformationn data.
class TeacherInfo {
  int? tid;
  String? tname;
  String? contactno;
  String? photo;
  String? email;

  TeacherInfo({
    this.tid,
    this.tname,
    this.contactno,
    this.photo,
    this.email,
  });

  // Add a factory method to convert JSON data to TeacherInfo object
  factory TeacherInfo.fromJson(Map<String, dynamic> json) {
    return TeacherInfo(
      tid: json["tid"],
      tname: json["tname"],
      contactno: json["contactno"],
      photo: json["photo"],
      email: json["email"],
      // Map other properties from JSON here
    );
  }
}
