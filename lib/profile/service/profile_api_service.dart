import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:school_jet/utils/common_methods.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../host_service/host_services.dart';
import 'package:http/http.dart' as http;

class ProfileApi {
  //An instance of the HostService.
  final HostService hostService = HostService();
  bool isLoading = false;
  String? baseurl;
  bool nullBaseurl = false;

  Future<Map<String, dynamic>> studentProfile(
      String mobno, String schid, String sessid, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    baseurl = pref.getString('apiurl');

    isLoading = true;
    final String apiUrl = '$mobno&schoolid=$schid&sessionid=$sessid';

    final url = Uri.parse(
        baseurl.toString() + hostService.getStudentByMobileNo + apiUrl);
    print(url);

    try {
      //get method of http to get data from the generated url.
      if (baseurl != null) {
        final response = await http.get(url);

        if (response.statusCode == 200) {
          // parses the JSON response body using jsonDecode.
          final jsonData = jsonDecode(response.body);

//checks if the parsed data is a map (Map<String, dynamic>).

// If the parsed data is a map, it returns the map,
//which likely contains the student's profile information.
          // ignore: unnecessary_type_check
          if (jsonData is Map<String, dynamic>) {
            return jsonData;
          }
          //isLoading flag is set to false after the request is complete.
          isLoading = false;
        }
      } else {
        nullBaseurl = true;
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, "Wrong school code");
      }
    } catch (e) {
      nullBaseurl = true;
      isLoading = false;
      if (kDebugMode) {
        print('Error occurred while making the POST request: $e');
      }
    }
    return {};
  }
}
