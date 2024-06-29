import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../menu/view_model/menu_view_model.dart';
import 'appcolors.dart';

class CommonMethods {
  String userType = '';
  int? schoolId;
  int? sessionId;
  String? mobno;
  void showSnackBar(BuildContext context, String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        backgroundColor: Colors.black54,
        content: Text('$message '),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  //student Profile date format Jan 3 2023
  String formatDate(String dateStr) {
    try {
      RegExp timePattern = RegExp(r'\d{1,2}:\d{2}[APap][Mm]');

      // Use the replaceAll method to replace the matched time pattern with an empty string
      String result = dateStr.replaceAll(timePattern, '');

      return result.trim(); // Trim to remove any leading/trailing spaces
    } catch (e) {
      return 'N/A';
    }
  }

  void sharedPreferenceData() async {
    final pref = await SharedPreferences.getInstance();
    // using getString method of sharedPreference to store saved value.
    userType = pref.getString('userType').toString();
    schoolId = pref.getInt('schoolid');

    sessionId = pref.getInt('sessionid');
    mobno = pref.getString('mobno');
  }

  String formatTime24Hr(String dateTime) {
    if (dateTime.length < 12) {
      return 'Invalid DateTime'; // Handle this case as needed
    }

    String hours = dateTime.substring(8, 10);
    String minutes = dateTime.substring(10, 12);

    int hourValue = int.parse(hours);

    // Convert 04 to 16 format
    if (hourValue < 10) {
      hourValue += 12;
      hours = hourValue.toString().padLeft(2, '0');
    }
    String ampm = (hourValue < 12) ? 'AM' : 'PM';

    print('$hours:$minutes');
    return '$hours:$minutes $ampm';
  }

  String notificationReportTime(String timestamp) {
    DateTime dateTime = DateTime.parse(timestamp);
    int hours = dateTime.hour;
    int minutes = dateTime.minute;
    String amPm = hours < 12 ? 'AM' : 'PM';

    print('$hours:$minutes $amPm');
    return '$hours:$minutes $amPm';
  }

  //function to exit the app.....
  Future<bool> onwillPop(BuildContext context) async {
    return (await showDialog(
          context: context,
          builder: (BuildContext context) {
            return AlertDialog(
              title: const Text('Exit App'),
              content: const Text('Are you sure you want to exit?'),
              actions: <Widget>[
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                  },
                  child: const Text(
                    'CANCEL',
                    style: TextStyle(
                        color: Appcolor.themeColor,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop(); // Close the dialog
                    SystemNavigator.pop(); // Exit the app
                  },
                  child: const Text(
                    'EXIT',
                    style: TextStyle(
                        color: Colors.red,
                        fontSize: 16,
                        fontWeight: FontWeight.bold),
                  ),
                ),
              ],
            );
          },
        )) ??
        false;
  }

  String teachersHomeworkreportDate(String inputDateString) {
    // Parse the input string into a DateTime object
    DateTime inputDate = DateTime.parse(inputDateString);

    // Format the DateTime object as a string in the desired format
    String formattedDate = DateFormat('dd/MM/yyyy').format(inputDate);

    return formattedDate;
  }

  void initCall(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();

    mobno = pref.getString('mobno');
    print(mobno);

    //method called for to fetch teacher information present in MenuViewModel provider class.

    // ignore: use_build_context_synchronously
    final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
    await menuProvider.fetchTeacherInfo(mobno.toString());
    if (menuProvider.teacherInfo?.photo != null) {
      menuProvider
          .checkFileExistence(menuProvider.teacherInfo!.photo.toString());
    }
  }
}
