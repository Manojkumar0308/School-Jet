class ViewHomeworkModel {
  String? date;
  String? clas;
  String? section;
  String? work;
  String? filepath;
  int? classid;
  int? sectionid;
  int? id;
  int? teacherid;

  ViewHomeworkModel(
      {this.date,
      this.clas,
      this.section,
      this.work,
      this.filepath,
      this.classid,
      this.sectionid,
      this.id,
      this.teacherid});

  ViewHomeworkModel.fromJson(Map<String, dynamic> json) {
    date = json['Date'];
    clas = json['Class'];
    section = json['Section'];
    work = json['Work'];
    filepath = json['Filepath'];
    classid = json['classid'];
    sectionid = json['sectionid'];
    id = json['id'];
    teacherid = json['teacherid'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['Date'] = this.date;
    data['Class'] = this.clas;
    data['Section'] = this.section;
    data['Work'] = this.work;
    data['Filepath'] = this.filepath;
    data['classid'] = this.classid;
    data['sectionid'] = this.sectionid;
    data['id'] = this.id;
    data['teacherid'] = this.teacherid;
    return data;
  }
}
