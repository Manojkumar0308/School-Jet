import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import 'package:http/http.dart' as http;

import '../model/get_exam_model.dart';

class ExamResultViewModel with ChangeNotifier {
  bool isLoading = true;
  // List<Exam> examList = [];
  List<Map<String, dynamic>> resultList = [];
  List<dynamic> results = [];
  List<Exam> _exams = [];
  int _selectedExamIndex = 0;

  List<Exam> get exams => _exams;
  int get selectedExamIndex => _selectedExamIndex;

  Future<void> examResult(
      String regNo, int examid, int classId, int sectionId) async {
    resultList.clear();
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final sessionId = pref.getInt('sessionid');

    try {
      isLoading = true;
      notifyListeners();
      HostService hostService = HostService();

      final url = Uri.parse(baseurl.toString() + hostService.examResultUrl);
      print('fee detail url :$url');
      final headers = {
        "Content-Type": "application/json",
        'Charset': 'utf-8',
      };
      final body = jsonEncode({
        "regno": regNo,
        "sessionid": sessionId,
        "examid": examid,
        "classid": classId,
        "sectionid": sectionId,
        "Result": null
      });
      print(body);
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        isLoading = false;
        final Map<String, dynamic> apiResponse = json.decode(response.body);

        results = apiResponse["Result"];

        if (results.isNotEmpty) {
          Map<String, dynamic> result = results[0];
          for (int i = 1; i <= 25; i++) {
            String subjectKey = "subjectsub$i";
            String mmKey = "mmsub$i";
            String subKey = "sub$i";

            if (result.containsKey(subjectKey) &&
                result.containsKey(mmKey) &&
                result.containsKey(subKey) &&
                result[subKey] != null &&
                result[mmKey] != 0.0 &&
                result[subKey] != '') {
              Map<String, dynamic> resultMap = {
                "subject": result[subjectKey],
                "Max.Marks": result[mmKey],
                "Obt.Marks": result[subKey],
              };
              resultList.add(resultMap);
            }
          }
        }

        notifyListeners();

        print(resultList);
      } else {
        isLoading = false;
        notifyListeners();
        Fluttertoast.showToast(
            msg: 'Failed to Load Data',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            timeInSecForIosWeb: 2,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
      }
    } catch (e, stacktrace) {
      isLoading = false;
      notifyListeners();
      print('Exception is :$e');
      print('Stacktrace: ' + stacktrace.toString());
    }
  }

  Future<void> getExam() async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final sessionId = pref.getInt('sessionid');

    try {
      isLoading = true;
      notifyListeners();
      HostService hostService = HostService();

      final url = Uri.parse(baseurl.toString() + hostService.getExamUrl);
      print('get Exam url :$url');
      final headers = {
        "Content-Type": "application/json",
        'Charset': 'utf-8',
      };
      final body =
          jsonEncode({"sessionid": sessionId, "examid": 0, "examname": ""});
      print(body);
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        isLoading = false;
        final List<dynamic> apiResponse = json.decode(response.body);

        _exams = apiResponse.map((item) => Exam.fromJson(item)).toList();

        notifyListeners();
      } else {
        isLoading = false;
        Container(
          child: const Center(child: Text('No Exam List is there')),
        );
        notifyListeners();
      }
    } catch (e, stacktrace) {
      isLoading = false;
      notifyListeners();
      print('Exception is :$e');
      print('Stacktrace: ' + stacktrace.toString());
    }
  }

  void setSelectedExamIndex(int index) {
    _selectedExamIndex = index;
    notifyListeners();
  }
}
