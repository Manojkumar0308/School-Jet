import 'dart:io';

import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

import '../model/delivery_summary_model.dart';
import '../model/model.dart';

class AdminSmsReport with ChangeNotifier {
  bool isLoading = false;
  List<MapEntry<DateTime, List<SmsMessage>>> sortedGroups = [];
  List<MapEntry<DateTime, List<SmsMessage>>> filteredGroups = [];
  SmsDeliverySummary? _summary;

  SmsDeliverySummary? get summary => _summary;
  Map<DateTime, List<SmsMessage>> groupedMessages = {};
  Map<String, double> summaryChart = {};
  double? smsDeliveredPercentage;
  double? smsNotDeliveredPercentage;
  double? smssentPercentage;
  double? smsExpired;
  List<SmsMessage> smsMessages = [];
  List<SmsMessage> deliveredMessages = [];
  List<SmsMessage> sentMessages = [];
  List<SmsMessage> undeliveredMessages = [];
  Future<void> fetchSmsMessagesReport(String fdate, String tdate) async {
    groupedMessages.clear();
    sortedGroups.clear();
    deliveredMessages.clear();
    sentMessages.clear();
    undeliveredMessages.clear();
    isLoading = true;

    final pref = await SharedPreferences.getInstance();
    // using getString method of sharedPreference to store saved value.

    final schoolId = pref.getInt('schoolid');

    final url =
        'http://app.online-sms.in/api/Delivery/DeliveryReport?fd=$fdate&td=$tdate&schoolid=$schoolId';
    print(url);
    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      isLoading = false;
      notifyListeners();
      try {
        final decodedData = GZipCodec().decode(response.bodyBytes);
        final data = utf8.decode(decodedData);
        final jsonList = json.decode(data);
        notifyListeners();
        if (jsonList is List) {
          smsMessages =
              jsonList.map((data) => SmsMessage.fromJson(data)).toList();
          notifyListeners();
          if (smsMessages.isNotEmpty) {
            for (var message in smsMessages) {
              if (message.status == 'Delivered') {
                deliveredMessages.add(message);
                // print(deliveredMessages.length);
              } else if (message.status == 'SENT') {
                sentMessages.add(message);
                // print(sentMessages.length);
              } else if (message.status == 'Undelivered') {
                undeliveredMessages.add(message);
                // print(undeliveredMessages.length);
              }
            }
            // print('Delivered Messages: $deliveredMessages');
            // print('SENT Messages: $sentMessages');
            // print('Undelivered Messages: $undeliveredMessages');
          } else {
            print('No SMS messages available');
          }
          if (smsMessages.isNotEmpty) {
            for (var message in smsMessages) {
              if (groupedMessages.containsKey(message.sentDate)) {
                groupedMessages[message.sentDate]!.add(message);
                notifyListeners();
              } else {
                groupedMessages[message.sentDate] = [message];
                notifyListeners();
              }
            }
            notifyListeners();

            sortedGroups = groupedMessages.entries.toList()
              ..sort((a, b) => b.key.compareTo(a.key));
            notifyListeners();
            // print('sorted group is :$sortedGroups');
          } else {
            print('No SMS messages available');
          }
        } else {
          print('Response is not a List of SMS messages');
        }
      } catch (e) {
        isLoading = false;
        notifyListeners();
        print('Error decoding JSON: $e');
      }
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
  }

  Future<void> fetchSmsDeliverySummary(String fdate, String tdate) async {
    summaryChart.clear();
    final pref = await SharedPreferences.getInstance();
    // using getString method of sharedPreference to store saved value.

    final schoolId = pref.getInt('schoolid');
    final url = Uri.parse(
        'http://app.online-sms.in/api/Delivery/DeliverySummary?fd=$fdate&td=$tdate&schoolid=$schoolId');
    final response = await http.get(url);
    print('sms report url:$url');

    if (response.statusCode == 200) {
      try {
        final jsonList = json.decode(response.body);
        _summary = SmsDeliverySummary.fromJson(jsonList);
        if (_summary?.nsmsdelivered != null &&
            _summary?.nsmssent != null &&
            _summary?.nsmsnotdelivered != null) {
          smsDeliveredPercentage = (_summary?.nsmsdelivered?.toDouble() ?? 0) /
              (_summary?.nsmssent?.toDouble() ?? 1) *
              100;
          //Delivered %
          print(_summary?.nsmsdelivered);
          print(smsDeliveredPercentage);
          smsNotDeliveredPercentage =
              (_summary?.nsmsnotdelivered?.toDouble() ?? 0) /
                  (_summary?.nsmssent?.toDouble() ?? 1) *
                  100;
          smsExpired = (_summary?.nsmsexpired?.toDouble() ?? 0) /
              (_summary?.nsmssent?.toDouble() ?? 1) *
              100;
          //Expired %
          print(_summary?.nsmsexpired);
          final smsInvalidNo = (_summary?.nsmsinvalidno?.toDouble() ?? 0) /
              (_summary?.nsmssent?.toDouble() ?? 1) *
              100;
          //Invalid no
          print(_summary?.nsmsinvalidno);
          final other = (_summary?.nsmsother?.toDouble() ?? 0) /
              (_summary?.nsmssent?.toDouble() ?? 1) *
              100;
          // other
          print(_summary?.nsmsother);
          final dlrnotFound = (_summary?.ndlrnotfound?.toDouble() ?? 0) /
              (_summary?.nsmssent?.toDouble() ?? 1) *
              100;
          //dlrnotfound
          print(_summary?.ndlrnotfound);
          smssentPercentage = (0 / 0) * 100;
          print(_summary?.nsmssent);
          summaryChart = {
            "Delivered": smsDeliveredPercentage?.toDouble() ?? 0.0,
            // "UnDelivered": smsNotDeliveredPercentage!,
            "Expired": smsExpired ?? 0.0,
            "InvalidNo": smsInvalidNo,
            "Other": other,
            "DlrNotFound": dlrnotFound
          };
          notifyListeners();
        } else {
          print('piechart data is null');
        }

        notifyListeners();
      } catch (e) {
        print('Error decoding JSON: $e');
      }
    } else {
      Fluttertoast.showToast(
          msg: 'Failed to Load Data',
          backgroundColor: Colors.black,
          textColor: Colors.white,
          timeInSecForIosWeb: 2,
          gravity: ToastGravity.BOTTOM,
          toastLength: Toast.LENGTH_SHORT);
    }
  }
}
