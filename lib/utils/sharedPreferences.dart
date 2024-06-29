import 'package:shared_preferences/shared_preferences.dart';

class SharedPreferenceItems {
  int? schoolId;
  int? sessionId;
  String? mobno;
  String? userType;
  void preference() async {
    final pref = await SharedPreferences.getInstance();
    schoolId = pref.getInt('schoolid');
    print(schoolId);
    sessionId = pref.getInt('sessionid');
    mobno = pref.getString('mobno');
    print(mobno);
    userType = pref.getString('userType').toString();
  }
}
