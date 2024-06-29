import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../model/model.dart';

class CalendarProvider extends ChangeNotifier {
  EventData? _eventData;
  EventData? get eventData => _eventData;
  List<EventData> events = [];

  List<String> formattedDates = [];

  Future<void> fetchData() async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final url = Uri.parse('$baseurl${HostService().eventCalender}');
    try {
      final response = await http.get(url);

      final data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        events = data.map<EventData>((event) {
          return EventData.fromJson(event);
        }).toList();
        // List to store event dates
        // List to store event dates
        List<dynamic> eventDates = [];

// Extract event dates
        events.forEach((element) {
          eventDates.add(element.edate ?? '');
        });

// Convert event dates to desired format
        formattedDates = eventDates.map((date) {
          DateTime dateTime = DateTime.parse(date);
          return DateFormat("yyyy-MM-dd").format(dateTime);
        }).toList();

        // Print the formatted dates
        print(formattedDates);
        // streamController.add(events); // Update stream with EventData list
        notifyListeners();
      } else {
        print('fail');
        notifyListeners();
      }
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }
}
