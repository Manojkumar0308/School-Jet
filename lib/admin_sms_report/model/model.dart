class SmsMessage {
  final DateTime sentDate;
  final String requestId;
  final String mobileNumber;
  final String smsStr;
  final String status;
  final String deliveredDateTime;
  String? statusCode;
  final String senderId;

  SmsMessage({
    required this.sentDate,
    required this.requestId,
    required this.mobileNumber,
    required this.smsStr,
    required this.status,
    required this.deliveredDateTime,
    this.statusCode,
    required this.senderId,
  });

  factory SmsMessage.fromJson(Map<String, dynamic> json) {
    return SmsMessage(
      sentDate: DateTime.parse(json['sentDate']),
      requestId: json['requestId'],
      mobileNumber: json['mobileNumber'],
      smsStr: json['smsstr'],
      status: json['status'],
      deliveredDateTime: json['deliveredDateTime'],
      statusCode: json['statusCode'],
      senderId: json['senderId'],
    );
  }
}
