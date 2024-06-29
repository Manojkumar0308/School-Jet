import 'dart:io';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

import 'package:http/http.dart' as http;

import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../../host_service/host_services.dart';
import '../model/get_attendance_model.dart';

class AttendanceProvider extends ChangeNotifier {
  final List<Map<String, dynamic>> _attendanceList = [];

  List<Map<String, dynamic>> get attendanceList => _attendanceList;
  DateTime _currentMonth = DateTime.now();
  DateTime get currentMonth => _currentMonth;
  HostService hostService = HostService();

  bool isLoading = false;
  // ignore: prefer_typing_uninitialized_variables
  var data;
  double percentageP = 0.0;
  double percentageA = 0.0;
  Map<String, int> dataMap = {};

  List<dynamic> attendanceData = [];

  void rebuildCalendar(DateTime rebuildMonth) {
    _currentMonth = rebuildMonth;
    notifyListeners();
  }

  Map<String, int> calculateTotals() {
    int totalP = 0;
    int totalA = 0;
    int totalL = 0;

    for (var entry in _attendanceList) {
      final attendance = entry['attendance'];

      if (attendance == 'P') {
        totalP++;
      } else if (attendance == 'A') {
        totalA++;
      } else if (attendance == 'L') {
        totalL++;
      }
    }

    return {'totalP': totalP, 'totalA': totalA, 'totalL': totalL};
  }

  Future<void> fetchAttendance(int schoolid, int sessionid, String regno,
      String fdate, String tdate) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      _attendanceList.clear();

      isLoading = true;
      notifyListeners();
      final url = Uri.parse(baseurl.toString() + hostService.viewAttendance);
      print('attendance url:$url');
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
        'Accept-Encoding': 'gzip'
      };
      final body = jsonEncode({
        "schoolid": schoolid,
        "sessionid": sessionid,
        "regno": regno,
        "fdate": fdate,
        "tdate": tdate,
      });
      print("body for fetch attendance is: $body");
      final response = await http.post(url, headers: headers, body: body);
      print(response);

      if (response.statusCode == 200) {
        final jsonData = GZipCodec().decode(response.bodyBytes);
        data = utf8.decode(jsonData);

        if (kDebugMode) {
          print("Response Body: $data");
        }

        final result = jsonDecode(data);
        print('result is $result');

        final attendanceModel =
            AttendanceModel.fromJson(result); // Updated here
        for (final attList in attendanceModel.attlists ?? []) {
          _attendanceList.add(
            {
              "attdate": attList.attdate!.split(' ')[0],
              "attendance": attList.attendance,
            },
          );
        }

        // final currentDate = DateTime.now();
        dataMap = calculateTotals();

        notifyListeners();

        print('attendance list is $_attendanceList');
        print('attendance length is${_attendanceList.length}');

        isLoading = false;
        notifyListeners();
      } else {
        if (kDebugMode) {
          print(
              "HTTP Error: ${response.statusCode} - ${response.reasonPhrase}");
        }
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      if (kDebugMode) {
        print("Exception: $e");
      }
    }
  }

  void onPageChanged(DateTime focusedDay) {
    dataMap = calculateTotals();

    notifyListeners();
  }

  Map<String, dynamic>? getAttendanceData(String formattedDate) {
    try {
      if (_attendanceList.isNotEmpty) {
        final entry = _attendanceList.firstWhere(
          (entry) => entry['attdate'] == formattedDate,
          orElse: () => <String, dynamic>{},
        );
        return entry;
      } else {
        return null;
      }
    } catch (_) {
      return null;
    }
  }

  Color getAttendanceColor(String attendance) {
    if (attendance == "P") {
      return Colors.green;
    } else if (attendance == "A") {
      return Colors.red;
    } else if (attendance == "L") {
      return Colors.blue;
    }
    return Colors.grey;
  }
}
