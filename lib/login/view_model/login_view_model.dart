import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

import '../../bottomnavigation/bottomnavigation_screen.dart';
import '../../host_service/host_services.dart';
import '../../notification_services/notification_services.dart';
import '../../utils/common_methods.dart';

class LoginProvider extends ChangeNotifier {
  bool _passwordVisible = false;
  String? baseurl;
  String? schoolname;
  final HostService hostService = HostService();
  var responseData;
  bool isLoading = false;

  /* a getter method that returns the value of the _passwordVisible variable.
   Getters are used to access the value of private class variables 
   from outside the class.*/

  bool get passwordVisible => _passwordVisible;
//method to show hide password characters.
  void togglePasswordVisibility() {
    _passwordVisible = !_passwordVisible;
    notifyListeners();
  }

  Future<void> schoolDetailApi(String schoolname) async {
    final pref = await SharedPreferences.getInstance();
    final url = Uri.parse(hostService.schoolNameApiUrl + schoolname);
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        if (jsonData['schoolid'] != null) {
          pref.setInt("schoolid", jsonData['schoolid']);
        }
        if (jsonData['schoolname'] != null) {
          pref.setString('schoolname', jsonData['schoolname']);
        }
        if (jsonData['schoolwebsite'] != null) {
          pref.setString('schoolwebsite', jsonData['schoolwebsite']);
        }
        if (jsonData['apiurl'] != null) {
          pref.setString('apiurl', jsonData['apiurl']);
        }
        if (jsonData['Validity'] != null) {
          pref.setString('Validity', jsonData['Validity']);
        }
        if (jsonData['smsbalance'] != null) {
          pref.setInt("smsbalance", jsonData['smsbalance']);
        }

        baseurl = pref.getString('apiurl');
        // Process the jsonData here
        print(jsonData);
      } else {
        print('Request failed with status: ${response.statusCode}');
      }
    } catch (e) {
      print('Exception is : $e');
    }
  }

  Future<void> login(String mobno, String passwd, String userType,
      BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    schoolname = pref.getString('schoolname').toString();
    try {
      isLoading = true;
      final Map<String, dynamic> requestBody = {
        "NameOfUser": "",
        "mobno": mobno,
        "password": passwd,
        "imei": "",
        "email": "",
        "otp": "",
        "schoolusername": schoolname,
        "usertype": userType
      };
      print(requestBody);
      final pref = await SharedPreferences.getInstance();

      final url = Uri.parse(baseurl.toString() + hostService.loginApiUrl);
      print('Manoj:$url');
      if (baseurl != null) {
        final response = await http.post(
          url,
          /*  header indicates the type of data being sent in the request body.
        'application/json' signifies that the request body will contain JSON-encoded data.*/
          headers: {'Content-Type': 'application/json'},
          //  function is used to convert the requestBody map into a JSON-formatted string.
          body: jsonEncode(requestBody),
        );
        if (response.statusCode == 200) {
          // Handle successful response

          /*
        It is used to parse a JSON-formatted string and convert 
        it into a Dart object or data structure. */
          responseData = jsonDecode(response.body);
          print('Login data :$responseData');

          // ignore: duplicate_ignore
          if (responseData['resultcode'] == 0) {
            pref.setString('userToken', responseData['token'].toString());

            // pref.setInt('schoolid', responseData['schoolid']);
            pref.setInt('sessionid', responseData['sessionid']);
            pref.setInt('userid', responseData['userid']);

            Navigator.of(context).pushAndRemoveUntil(
                MaterialPageRoute(
                    builder: (context) => const BottomNavigationScreen()),
                (Route<dynamic> route) => false);

            // ignore: use_build_context_synchronously
            CommonMethods().showSnackBar(context, 'Login Successfully');

            // NotificationServices().updateUserToken();
            NotificationServices().getDeviceToken();

            // ignore: use_build_context_synchronously
          } else {
            // ignore: use_build_context_synchronously
            CommonMethods().showSnackBar(context, responseData['resultstring']);
          }
        } else {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Something went wrong');
          // Handle error response
          if (kDebugMode) {
            print(
                'POST request failed with status code: ${response.statusCode}');
          }
        }
        isLoading = false;
      } else {
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, "Wrong school code");
      }
    } catch (e) {
      isLoading = false;
      if (kDebugMode) {
        print('Error occurred while making the POST request: $e');
      }
    }
  }
}
