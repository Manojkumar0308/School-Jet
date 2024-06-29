import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../model/model.dart';
import 'package:http/http.dart' as http;

class ViewHomeworkProvider extends ChangeNotifier {
  bool isLoading = false;
  List<ViewHomeworkModel> _homeworkData = [];

  List<ViewHomeworkModel> get homeworkData => _homeworkData;
  HostService hostService = HostService();

  Future<void> fetchHomeworkData(int teacherId) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    try {
      isLoading = true;
      final url =
          Uri.parse(baseurl.toString() + hostService.teacherHomeworkReport);
      print('teacher homework report is:$url');
      final headers = {
        "Content-Type": "application/json",
        'Charset': 'utf-8',
      };
      final body = {
        "classid": null,
        "sectionid": null,
        "teacherid": teacherId,
        "date": "",
        "work": "",
        "msgtype": "",
        "content": "",
      };
      print(body);

      final response =
          await http.post(url, headers: headers, body: json.encode(body));

      if (response.statusCode == 200) {
        final List<dynamic> jsonData = json.decode(response.body);
        isLoading = false;

        print(jsonData);
        _homeworkData =
            jsonData.map((data) => ViewHomeworkModel.fromJson(data)).toList();
        notifyListeners();
      } else {
        isLoading = false;
        Fluttertoast.showToast(
            msg: 'Failed to Load Data',
            backgroundColor: Colors.black,
            textColor: Colors.white,
            timeInSecForIosWeb: 2,
            gravity: ToastGravity.BOTTOM,
            toastLength: Toast.LENGTH_SHORT);
      }
    } catch (e) {
      isLoading = false;
      print('Error fetching homework: $e');
    }
  }
}
