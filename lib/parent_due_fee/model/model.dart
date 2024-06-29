class StudentDataDueFee {
  final int stuid;
  final String stuname;
  final double netAmt;
  final String intervals;
  final double currBal;

  StudentDataDueFee({
    required this.stuid,
    required this.stuname,
    required this.netAmt,
    required this.intervals,
    required this.currBal,
  });

  factory StudentDataDueFee.fromJson(Map<String, dynamic> json) {
    return StudentDataDueFee(
      stuid: json['stuid'],
      stuname: json['stuname'],
      netAmt: json['NetAmt'] != null
          ? (json['NetAmt'] is num ? json['NetAmt'].toDouble() : 0.0)
          : 0.0,
      intervals: json['Intervals'],
      currBal: json['curr_bal'] != null
          ? (json['curr_bal'] is num ? json['curr_bal'].toDouble() : 0.0)
          : 0.0,
    );
  }
}
