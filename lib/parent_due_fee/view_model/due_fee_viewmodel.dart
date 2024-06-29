import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../host_service/host_services.dart';
import '../model/model.dart';

class DueFeeViewModel with ChangeNotifier {
  int? sessionId;

  String? mobno;
  bool isLoading = false;

  List<StudentDataDueFee> studentDueFeeList = [];

  void requiredData() async {
    final pref = await SharedPreferences.getInstance();

    sessionId = pref.getInt('sessionid');

    mobno = pref.getString('mobno');
  }

  Future<void> fetchStudentDueFee(String regNo) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final sessionId = pref.getInt('sessionid');

    final mobno = pref.getString('mobno');
    try {
      isLoading = true;
      notifyListeners();
      HostService hostService = HostService();

      final url = Uri.parse(baseurl.toString() + hostService.dueFeeUrl);
      print('duefee url :$url');
      final headers = {
        "Content-Type": "application/json",
        'Charset': 'utf-8',
      };
      final body =
          jsonEncode({"regno": regNo, "userid": mobno, "sessionid": sessionId});
      print(body);
      final response = await http.post(url, headers: headers, body: body);

      if (response.statusCode == 200) {
        isLoading = false;
        final List<dynamic> apiResponse = json.decode(response.body);

        studentDueFeeList = apiResponse.map((data) {
          return StudentDataDueFee.fromJson(data);
        }).toList();
        notifyListeners();

        print(studentDueFeeList);
      } else {
        isLoading = false;
        notifyListeners();
        throw Exception('Failed to load student data of due fee');
      }
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Exception is :$e');
    }
  }
}
