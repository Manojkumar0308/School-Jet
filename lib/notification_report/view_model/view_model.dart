import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../../host_service/host_services.dart';
import '../model/model.dart';

class NotificationReportProvider with ChangeNotifier {
  List<NotificationReport> _notificationReports = [];
  bool _isLoading = false;
  String _errorMessage = '';

  List<NotificationReport> get notificationReports => _notificationReports;
  bool get isLoading => _isLoading;
  String get errorMessage => _errorMessage;

  Future<void> fetchNotificationReports(int page) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    _isLoading = true;

    String url = '$baseurl${HostService().teacherNotificationReport}$page';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);

        final List<dynamic> data = jsonData;
        _notificationReports =
            data.map((item) => NotificationReport.fromJson(item)).toList();
      } else {
        _errorMessage =
            'API call failed with status code: ${response.statusCode}';
      }
    } catch (e) {
      _errorMessage = 'API call failed with error: $e';
    }

    _isLoading = false;
    notifyListeners();
  }
}
