import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:school_jet/utils/common_methods.dart';

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
      print(url);
      print('GetStudent by filter admin :$url');
      final body = jsonEncode({"regno": regNo, "sessionid": sessionId});
      print(body);
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      };
      final response = await http.post(url, headers: headers, body: body);
      print(response);
      if (response.statusCode == 200) {
        isStudentDataLoading = false;
        final jsonResponse = json.decode(response.body);
        print('jsonResponse is:$jsonResponse');
        if (jsonResponse != null &&
            jsonResponse is Map<String, dynamic> &&
            jsonResponse['message'] != "Data Not Found") {
          _student = Student.fromJson(jsonResponse);
        } else {
          // Handle the case where jsonResponse is null or not a Map<String, dynamic>
        }

        notifyListeners();
      } else {
        isStudentDataLoading = false;
        notifyListeners();
        print('error occured');
      }
    } catch (e) {
      isStudentDataLoading = false;
      notifyListeners();
      print('Exception is:$e');
    }
  }
}
