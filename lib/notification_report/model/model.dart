class NotificationReport {
  int? id;
  String? msgGroup;
  String? msgGroupDetail;
  String? msgType;
  String? msgContent;
  DateTime? msgDate;
  int? schoolID;
  int? userID;

  NotificationReport({
    this.id,
    this.msgGroup,
    this.msgGroupDetail,
    this.msgType,
    this.msgContent,
    this.msgDate,
    this.schoolID,
    this.userID,
  });

  factory NotificationReport.fromJson(Map<String, dynamic> json) {
    return NotificationReport(
      id: json['ID'],
      msgGroup: json['MsgGroup'],
      msgGroupDetail: json['MsgGroupDetail'],
      msgType: json['MsgType'],
      msgContent: json['MsgContent'],
      msgDate: DateTime.parse(json['MsgDate']),
      schoolID: json['SchoolID'],
      userID: json['UserID'],
    );
  }
}
