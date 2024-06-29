import 'dart:convert';
import 'package:intl/intl.dart';
import 'package:flutter/material.dart';

import 'package:shared_preferences/shared_preferences.dart';
import 'package:http/http.dart' as http;
import '../../host_service/host_services.dart';
import '../../utils/common_methods.dart';
import '../model/model.dart';

class LeaveViewModel with ChangeNotifier {
  bool isLoading = false;
  List<GetLeaveList>? _getLeaveList;
  List<GetLeaveList>? get getLeavelist => _getLeaveList;
  String? userType;
  String? formattedToDate;
  String? formattedFromDate;
  String? parentformattedToDate;
  String? parentformattedFromDate;
  DateTime? picked;
  String? fDate;
  String? tDate;
  String? parentinitialtoDate;
  String? parentintitialFromDate;
  TextEditingController fromDateController = TextEditingController();
  TextEditingController parentFromDateController = TextEditingController();
  TextEditingController parentToDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  DateTime fromDate = DateTime.now();

  DateTime toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  DateTime parentFromDate = DateTime.now();
  DateTime parentToDate = DateTime.now();

  HostService hostService = HostService();
  Future<void> getLeaveList(String fdate, String tdate) async {
    _getLeaveList = [];
    try {
      isLoading = true;

      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      userType = pref.getString('userType');
      print(userType);

      final url = Uri.parse('$baseurl${hostService.getLeaveListUrl}');
      print('getLeave list url is : $url');
      final body = jsonEncode(
          {"fdate": fdate, "tdate": tdate, "regnno": "", "reason": ""});
      print(body);
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      };
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        isLoading = false;
        final List<dynamic> results = jsonDecode(response.body);
        _getLeaveList = getLeaveListFromJson(results);
        notifyListeners();
      } else {
        print('Something went wrong');
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      print(e.toString());
      notifyListeners();
    }
  }

  List<GetLeaveList> getLeaveListFromJson(List<dynamic> data) {
    return data.map((item) => GetLeaveList.fromJson(item)).toList();
  }

  // Future<void> selectFromDate(BuildContext context) async {
  //   picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     // firstDate: DateTime(fromDate.year, fromDate.month, 1),
  //     firstDate: DateTime(2000, 1, 1),
  //     lastDate: DateTime(2100, 12, 31),
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.dark(),
  //         child: child!,
  //       );
  //     },
  //   );
  //   if (picked != null && picked != fromDate || picked != parentFromDate) {
  //     fromDate = picked!;
  //     parentFromDate = picked!;
  //     formattedFromDate = DateFormat('yyyyMMdd000000').format(fromDate);
  //     parentformattedFromDate =
  //         DateFormat('yyyyMMdd000000').format(parentFromDate);
  //     fromDateController.text = 'From: ${DateFormat.yMMMMd().format(fromDate)}';
  //     parentFromDateController.text =
  //         'From:${DateFormat.yMMMMd().format(parentFromDate)}';

  //     notifyListeners();
  //   }
  // }

  // Future<void> selectToDate(BuildContext context) async {
  //   picked = await showDatePicker(
  //     context: context,
  //     initialDate: DateTime.now(),
  //     // firstDate: DateTime(fromDate.year, fromDate.month, 1),
  //     firstDate: DateTime(2000, 1, 1),
  //     lastDate: DateTime(2100, 12, 31),
  //     builder: (context, child) {
  //       return Theme(
  //         data: ThemeData.dark(),
  //         child: child!,
  //       );
  //     },
  //   );

  //   if (picked != null && picked != toDate || picked != parentToDate) {
  //     toDate = picked!;
  //     parentToDate = picked!;
  //     formattedToDate = DateFormat('yyyyMMdd000000').format(toDate);
  //     parentformattedToDate = DateFormat('yyyyMMdd000000').format(parentToDate);
  //     print(parentformattedToDate);

  //     print(formattedToDate);

  //     toDateController.text = 'To: ${DateFormat.yMMMMd().format(toDate)}';
  //     // parentToDateController.text =
  //     //     'To:${DateFormat.yMMMMd().format(parentToDate)}';
  //     getLeaveList(formattedFromDate.toString(), formattedToDate.toString());
  //     notifyListeners();
  //     // ignore: use_build_context_synchronously
  //   }
  // }

  Future<void> addLeave(String fdate, String tdate, String regno, String reason,
      BuildContext context) async {
    try {
      isLoading = true;

      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      userType = pref.getString('userType');
      print(userType);

      final url = Uri.parse('$baseurl${hostService.addLeaveUrl}');
      print('getLeave list url is : $url');
      final body = jsonEncode(
          {"fdate": fdate, "tdate": tdate, "regnno": regno, "reason": reason});
      print(body);
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      };
      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        isLoading = false;
        final results = jsonDecode(response.body);
        if (results['resultcode'] == 0) {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Leave added successfully');
        } else {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Something went wrong');
        }

        notifyListeners();
      } else {
        print('Something went wrong');
        isLoading = false;
        notifyListeners();
      }
    } catch (e) {
      isLoading = false;
      print(e.toString());
      notifyListeners();
    }
  }

  bool isVisible = false;
  Future<void> selectFromDate(BuildContext context) async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // firstDate: DateTime(fromDate.year, fromDate.month, 1),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != fromDate) {
      fromDate = picked!;
      formattedFromDate = DateFormat('yyyyMMdd000000').format(fromDate);

      print('if from date selected only:$formattedToDate');
      print('if from date selected only:$formattedFromDate');
      fromDateController.text = 'From: ${DateFormat.yMMMMd().format(fromDate)}';
      getLeaveList(formattedFromDate.toString(), formattedToDate.toString());
      notifyListeners();
    }
  }

  Future<void> selectToDate(BuildContext context) async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // firstDate: DateTime(fromDate.year, fromDate.month, 1),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null && picked != toDate) {
      toDate = picked!;
      formattedToDate = DateFormat('yyyyMMdd000000').format(toDate);

      print(formattedToDate);

      toDateController.text = 'To: ${DateFormat.yMMMMd().format(toDate)}';
      getLeaveList(formattedFromDate.toString(), formattedToDate.toString());
      notifyListeners();

      // ignore: use_build_context_synchronously
    }
  }
}
