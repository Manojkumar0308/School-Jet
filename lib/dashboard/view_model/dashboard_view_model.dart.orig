import 'dart:convert';
import 'dart:math';

import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';

import '../../profile/model/profile_model.dart';
import 'package:http/http.dart' as http;

import '../model/dashboard_model.dart';
import '../view/admin_piechart.dart';

class DashBoardViewModel with ChangeNotifier {
  List<Color> predefinedColors = [
    Colors.blue,
    Colors.green,
    Colors.red,
    Colors.orange,
    Colors.purple,
    Colors.indigo
  ];
  HostService hostService = HostService();
  AdminDashBoardModel? adminDashBoardModel;
  Map<String, dynamic> data = {};
  Map<String, double> attendanceDashboard = {};
  Map<String, double> paymentModeData = {};
  List<dynamic> attlists = [];
  List<dynamic> paymentMode = [];

  int statusCode = 0;
  bool adminLoading = false;
  double totalP = 0;
  double totalA = 0;
  double totalL = 0;
  double percentageA = 0.0;
  double percentageP = 0.0;
  double percentageL = 0.0;
  String? baseurl;

  int selectedModeIndex = 1;
  var result;
  //instance of a Stm class.
  Stm? _stm;
//getter to save data to Stm class.
  Stm? get stm => _stm;
  //method to get data of selected student and store it into Stm class instance;
  void selectStudent(Stm student) {
    _stm = student;
    notifyListeners();
  }

//method for saving data for selected student.
  Future<void> selectedStudentData(Stm student) async {
    final pref = await SharedPreferences.getInstance();
    pref.setString('attendanceRegNo', student.regNo.toString());
    pref.setString('attendanceStudentName', student.stuName.toString());
    pref.setString('attendanceStudentClass', student.className.toString());
    pref.setString('attendanceStudentRoll', student.rollNo.toString());
    pref.setString('attendanceStudentPhoto', student.photo.toString());
    pref.setInt('classID', student.classId!);
    pref.setInt('sectionID', student.sectionId!);
  }

  Future<void> adminDashBoard(
      String userId, int sessionId, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    baseurl = pref.getString('apiurl');
    totalP = 0;
    totalA = 0;
    totalL = 0;
    double percentageA = 0.0;
    double percentageP = 0.0;
    double percentageL = 0.0;
    attendanceDashboard.clear;
    paymentModeData.clear;
    notifyListeners();
    try {
      adminLoading = true;
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      };
      final body = jsonEncode(
        {
          "userid": userId,
          "sessionid": sessionId,
        },
      );
      final url = Uri.parse(baseurl.toString() + hostService.adminDashboardApi);
      print(url);
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        data = json.decode(response.body);
        if (data.isNotEmpty) {
          print('manoj');
          print(data['TotalStudent']);
          attlists = data['attendance']['attlists'];
          paymentMode = data['paymodefee'];
          print(attlists.length);
          for (final attendance in attlists) {
            final attendanceType = attendance['attendance'];

            if (attendanceType == 'P') {
              totalP++;
            } else if (attendanceType == 'A') {
              totalA++;
            } else if (attendanceType == 'L') {
              totalL++;
            }
          }
          print('Total P: $totalP');
          print('Total A: $totalA');
          print('Total L: $totalL');
          adminLoading = false;
          percentageP = (totalP / attlists.length) * 100;
          percentageA = (totalA / attlists.length) * 100;
          percentageL = (totalL / attlists.length) * 100;
          if (attlists.isNotEmpty) {
            attendanceDashboard = {
              'Present': percentageP,
              'Absent': percentageA,
              'Leave': percentageL
            };
          }

          print(attendanceDashboard);
          if (paymentMode.isNotEmpty) {
            for (var entry in paymentMode) {
              String paymode = entry["paymode"];
              double amount = entry["amount"];
              paymentModeData[paymode] = amount;
            }
          }

          print('payment mode data is :${paymentModeData}');

          notifyListeners();
        }
      } else if (response.statusCode == 500) {
        adminLoading = false;

        print(response.statusCode);
        statusCode = response.statusCode;
        notifyListeners();
      } else {
        adminLoading = false;

        print('Something went wrong');
        notifyListeners();
      }
    } catch (e) {
      adminLoading = false;

      print('Exception is a :$e');
      notifyListeners();
    }
  }

  double getTappedAngle(Offset localOffset, Size size) {
    final dx = localOffset.dx - size.width / 2;
    final dy = localOffset.dy - size.height / 2;
    final angle = atan2(dy, dx) + pi;
    notifyListeners();
    return angle < 0 ? angle + 2 * pi : angle;
  }

  List<PieChartSectionData> buildSections(int touchedIndex) {
    return List.generate(paymentModeData.length, (i) {
      final isTouched = i == touchedIndex;
      final fontSize = isTouched ? 20.0 : 12.0;
      final radius = isTouched ? 60.0 : 50.0;

      final amount = paymentModeData.values.toList()[i];

      const shadows = [Shadow(color: Colors.black, blurRadius: 2)];

      // You can define your colors based on payment mode or use a random color like before
      final color = predefinedColors[i % predefinedColors.length];

      return PieChartSectionData(
        color: color,
        title: '\u{20B9}$amount',
        radius: radius,
        titleStyle: TextStyle(
          fontSize: fontSize,
          fontWeight: FontWeight.bold,
          color: AppColors.mainTextColor1,
          shadows: shadows,
        ),
      );
    });
  }
}
