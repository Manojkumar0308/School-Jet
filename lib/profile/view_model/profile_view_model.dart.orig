import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../model/profile_model.dart';
import '../service/profile_api_service.dart';

class StudentProvider extends ChangeNotifier {
  //A private property representing a Profile object that holds student profile information.
  Profile? _profile;
  // A private property representing the currently selected index (often used for UI purposes).
  int _selectedIndex = 0;
//  A getter method to access the _profile object.
  Profile? get profile => _profile;
  //A getter method to access the _selectedIndex value.
  int get selectedIndex => _selectedIndex;
  // boolean flag to track whether a network request or data loading is in progress.
  bool isLoading = false;
  //to represent the user type Admin,Parent,Teacher.
  String userType = '';
  int? schoolId;
  int? sessionId;
  String? mobno;
// fetch student data based on the provided
//parameters: mobno (mobile number), schid (school ID), and sessid (session ID).
  Future<void> fetchStudentData(
      String mobno, String schid, String sessid, BuildContext context) async {
    //It initializes an apiService using the ProfileApi class.

    final apiService = ProfileApi();
    isLoading = true;
    notifyListeners();
    //Sends a request to fetch student profile data using apiService.studentProfile.

    final jsonData =
        await apiService.studentProfile(mobno, schid, sessid, context);

    final pref = await SharedPreferences.getInstance();
    /*If data is received (jsonData is not empty), 
    it processes the data to extract class and session information
    and stores them in shared preferences. */
    if (jsonData.isNotEmpty) {
      final studentData = jsonData['stm'][0];

      // Get the first element of the list

      if (studentData.containsKey('ClassId') &&
          studentData.containsKey('SessionId')) {
        final classId = studentData['ClassId'];
        final sectionId = studentData['SectionId'];

        pref.setInt('classID', classId);
        pref.setInt('sessionID', sectionId);

        pref.getInt('classID');
        pref.getInt('sessionID');
      }
    }

    isLoading = false;
    notifyListeners();
//Parses the JSON data into a Profile object and assigns it to the _profile property.
    _profile = Profile.fromJson(jsonData);

    notifyListeners();
  }

// This method is used to update the _selectedIndex property with a new index.
  void selectStudent(int index) {
    _selectedIndex = index;
    notifyListeners();
  }

  void resetSelectedStudentIndex() {
    _selectedIndex = 0;
    notifyListeners();
  }
}
