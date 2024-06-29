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

  Future<void> schoolDetailApi(String schoolname) async {
    final pref = await SharedPreferences.getInstance();
    final url = Uri.parse(hostService.schoolNameApiUrl + schoolname);
    print(url);
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final jsonData = json.decode(response.body);
        pref.setInt("schoolid", jsonData['schoolid']);
        pref.setString('schoolname', jsonData['schoolname']);

        pref.setString('schoolwebsite', jsonData['schoolwebsite']);
        pref.setString('apiurl', jsonData['apiurl']);
        pref.setString('Validity', jsonData['Validity']);
        pref.setInt("smsbalance", jsonData['smsbalance']);

        final schoolwebsite = pref.getString('schoolwebsite');

        final baseurl = pref.getString('apiurl');

        // Process the jsonData here
        print(jsonData);
      } else {
        print('Request failed with status: ${response.statusCode}');
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
        "schoolusername": hostService.schoolname,
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
    try {
      final Map<String, dynamic> requestBody = {
        "NameOfUser": "",
        "mobno": mob,
        "password": passwd,
        "imei": "",
        "email": "",
        "otp": otp,
        "schoolusername": hostService.schoolname,
        "usertype": ""
      };

      final response = await http.post(
        Uri.parse('$baseurl${hostService.changePasswdUrl}'),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode(requestBody),
      );
      if (response.statusCode == 200) {
        // Handle successful response
        if (kDebugMode) {}
        if (kDebugMode) {}

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
