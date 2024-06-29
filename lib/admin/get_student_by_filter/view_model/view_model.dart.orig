import 'dart:convert';

import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../host_service/host_services.dart';
import '../model/model.dart';
import 'package:http/http.dart' as http;

class GetStudentByRegNoAdmin extends ChangeNotifier {
  Student? _student;
  HostService hostService = HostService();
  bool isStudentDataLoading = false;

  Student? get student => _student;

  Future<void> fetchStudentDetail(String regNo) async {
    final pref = await SharedPreferences.getInstance();
    final sessionId = pref.getInt('sessionid');
    final baseurl = pref.getString('apiurl');
    // Clear the student data at the beginning
    _student = null;

    try {
      isStudentDataLoading = true;
      notifyListeners();
      final url = Uri.parse(
          baseurl.toString() + hostService.adminGetStudentProfileByRegno);
      print('GetStudent by filter admin :$url');
      final body = jsonEncode({"regno": regNo, "sessionid": sessionId});
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      };
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        isStudentDataLoading = false;
        final jsonResponse = json.decode(response.body);
        _student = Student.fromJson(jsonResponse);

        notifyListeners();
      } else {
        isStudentDataLoading = false;
        notifyListeners();
        throw Exception('Failed to load data');
      }
    } catch (e) {
      isStudentDataLoading = false;
      notifyListeners();
      print('Exception is:$e');
    }
  }
}
