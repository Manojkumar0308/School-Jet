// ignore: file_names
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';

class StudentBYRegViewModel extends ChangeNotifier {
  List<dynamic> students = [];
  bool isLoading = false;
  var data;

  Future<void> getStudentsByFilter(String regno) async {
    try {
      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      final schoolid = pref.getInt('schoolid');
      final sessionid = pref.getInt('sessionid');
      String url = '$baseurl${HostService().getStudentByFilterUrl}';
      print('student_by_regNo: $url');
      isLoading = true;
      notifyListeners();
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
        'Accept-Encoding': 'gzip'
      };

      final body = jsonEncode({
        "RegNo": regno.toString(),
        "stuname": "",
        "fathername": "",
        "classname": "",
        "sectionname": "",
        "conveyance": "",
        "stopname": "",
        "dob": "20230721000000",
        "schoolid": schoolid,
        "sessionid": sessionid
      });

      print(body);
      final response =
          await http.post(Uri.parse(url), headers: headers, body: body);

      if (response.statusCode == 200) {
        final jsonData = GZipCodec().decode(response.bodyBytes);
        data = utf8.decode(jsonData);
        print('data is:$data');
        if (data != "null") {
          students = jsonDecode(data);
        } else {
          students = [];
          Fluttertoast.showToast(
              msg: 'No record found', fontSize: 12, textColor: Colors.white);
        }
      } else {
        // Handle the error scenario
        print('API call failed with status code: ${response.statusCode}');
      }
    } catch (e) {
      // Handle the error scenario
      print('API call failed with error: $e');
    } finally {
      isLoading = false;
      notifyListeners();
    }
  }
}
