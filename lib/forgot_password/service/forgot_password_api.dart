import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../../login/view/login_screen.dart';
import '../../utils/common_methods.dart';

class ForgotPasswordService {
  //instance of HostService class
  final HostService hostService = HostService();
  // ignore: prefer_typing_uninitialized_variables
  var responseData;
  bool isLoading = false;

  Future<void> schoolDetailApi(String schoolname, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final url = Uri.parse(hostService.schoolNameApiUrl + schoolname);
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        print(jsonData);
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

        // Process the jsonData here
        print(jsonData);
      } else {
        print('Request failed with status: ${response.statusCode}');
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, 'Wrong School code entered');
      }
    } catch (e) {
      print('Exception is : $e');
    }
  }

/*It sends the request and otp to the user, handles the response, 
and displays appropriate messages based on the response data.*/
  Future<void> forgotPasswd(String mob, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final schoolCode = pref.getString('schoolCode');
    final url = Uri.parse('$baseurl${hostService.forgtpasswdUrl}');
    print(url);
    try {
      // request body as a JSON map containing the required information.
      final Map<String, dynamic> requestBody = {
        "NameOfUser": "",
        "mobno": mob,
        "password": "",
        "imei": "",
        "email": "",
        "otp": "",
        "schoolusername": schoolCode,
        "usertype": ""
      };
      print(requestBody);

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
 it into a Dart object or data structure.*/
        responseData = jsonDecode(response.body);
        print(responseData);

        if (responseData == "0") {
          isLoading = true;

          // ignore: use_build_context_synchronously
          Navigator.of(context).pushNamed('/password_screen');
        } else {
          // ignore: use_build_context_synchronously
          CommonMethods()
              .showSnackBar(context, 'No user found with this mobile number');
          // Handle error response
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred while making the POST request: $e');
      }
    }
  }

//method to verify the otp for changing the password.
  Future<void> changePasswd(
      String mob, String passwd, String otp, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final schoolCode = pref.getString('schoolCode');
    try {
      final Map<String, dynamic> requestBody = {
        "NameOfUser": "",
        "mobno": mob,
        "password": passwd,
        "imei": "",
        "email": "",
        "otp": otp,
        "schoolusername": schoolCode,
        "usertype": ""
      };

      final response = await http.post(
        Uri.parse('$baseurl${hostService.changePasswdUrl}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        // Handle successful response
        responseData = jsonDecode(response.body);

        if (responseData == "0") {
          isLoading = true;

          // snackbar is used to notify the user for event happens.
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Password changed');
          // pushAndRemoveUntil method remove all the routes from the stack
          // ignore: use_build_context_synchronously
          Navigator.of(context).pushAndRemoveUntil(
              MaterialPageRoute(builder: (context) => const LoginScreen()),
              (Route<dynamic> route) => false);
        } else {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, "Otp error");
          // Handle error response
        }
      }
    } catch (e) {
      if (kDebugMode) {
        print('Error occurred while making the POST request: $e');
      }
    }
  }
}
