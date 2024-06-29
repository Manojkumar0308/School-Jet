import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../utils/appcolors.dart';

import '../walkthrough/walkthrough_screen.dart';

class ErrorScreen extends StatefulWidget {
  const ErrorScreen({super.key});

  @override
  State<ErrorScreen> createState() => _ErrorScreenState();
}

class _ErrorScreenState extends State<ErrorScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 10.0),
            child: TextButton(
              onPressed: () async {
                final pref = await SharedPreferences.getInstance();
                // on logout button pressed clearing all the saved data in shared preference.
                pref.clear();
                // navigation to the screen after successful logout.
                // ignore: use_build_context_synchronously
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const WalkthroughScreen()));
              },
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: const [
                  Icon(
                    Icons.logout,
                    color: Appcolor.themeColor,
                  ),
                  SizedBox(width: 8),
                  Text(
                    'Logout',
                    style: TextStyle(color: Appcolor.themeColor),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
      body: Center(
        child: Image.asset('assets/images/server_error.png'),
      ),
    );
  }
}
