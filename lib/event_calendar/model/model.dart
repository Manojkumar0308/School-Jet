class EventData {
  String? edate;
  String? ename;
  String? edesc;

  EventData({this.edate, this.ename, this.edesc});

  EventData.fromJson(Map<String, dynamic> json) {
    edate = json['edate'];
    ename = json['ename'];
    edesc = json['edesc'];
  }

  Map<String, dynamic> toJson() {
    final Map<String, dynamic> data = new Map<String, dynamic>();
    data['edate'] = this.edate;
    data['ename'] = this.ename;
    data['edesc'] = this.edesc;
    return data;
  }
}
