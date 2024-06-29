import 'dart:convert';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../model/model.dart';

class ParentFeeDetailViewModel with ChangeNotifier {
  int? sessionId;

  String? mobno;
  bool isLoading = false;

  List<ParentFeeDetail> studentFeeDetailList = [];

  void requiredData() async {
    final pref = await SharedPreferences.getInstance();

    sessionId = pref.getInt('sessionid');

    mobno = pref.getString('mobno');
  }

  Future<void> fetchStudentFeeDetail(String regNo) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final sessionId = pref.getInt('sessionid');

    final mobno = pref.getString('mobno');
    try {
      isLoading = true;
      notifyListeners();
      HostService hostService = HostService();

      final url = Uri.parse(baseurl.toString() + hostService.feeDetailUrl);
      print('fee detail url :$url');
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

        studentFeeDetailList = apiResponse.map((data) {
          return ParentFeeDetail.fromJson(data);
        }).toList();
        notifyListeners();

        print(studentFeeDetailList);
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
    } catch (e) {
      isLoading = false;
      notifyListeners();
      print('Exception is :$e');
    }
  }
}
