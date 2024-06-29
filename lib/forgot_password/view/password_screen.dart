import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../login/view_model/login_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../service/forgot_password_api.dart';

class ChangePasswordScreen extends StatefulWidget {
  const ChangePasswordScreen({super.key});

  @override
  State<ChangePasswordScreen> createState() => _ChangePasswordScreenState();
}

class _ChangePasswordScreenState extends State<ChangePasswordScreen> {
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  TextEditingController otpControllerForgotPasswd = TextEditingController();
  @override
  void initState() {
    super.initState();
    // Set the status bar color to white
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.white,
        statusBarIconBrightness: Brightness.dark,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final passwordVisibilityProvider = Provider.of<LoginProvider>(context);
    return Scaffold(
      backgroundColor: Colors.white,
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.only(top: 50.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(
                        Icons.arrow_back_ios,
                        size: 25,
                      )),
                  Padding(
                    padding: const EdgeInsets.only(top: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: const [
                        Text(
                          'Verify your otp',
                          style: TextStyle(
                              fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        SizedBox(
                          height: 5,
                        ),
                        Text(
                          'And Change Your Password here',
                          style: TextStyle(
                              fontSize: 15,
                              color: Colors.blueGrey,
                              fontWeight: FontWeight.w500),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              Padding(
                padding: const EdgeInsets.only(top: 30.0, left: 20, right: 20),
                child: Column(
                  children: [
                    SizedBox(
                      height: size.height * 0.35,
                      child: Image.asset(
                        'assets/images/otp.png',
                        fit: BoxFit.cover,
                      ),
                    ),
                    Container(
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(5)),
                      child: TextField(
                        controller: otpControllerForgotPasswd,
                        style: const TextStyle(fontSize: 14),
                        decoration: const InputDecoration(
                          hintText: 'OTP',
                          hintStyle: TextStyle(fontSize: 12),
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(bottom: 10, left: 5),
                        ),
                        autofillHints: const [
                          AutofillHints.oneTimeCode
                        ], // Enable autofill with OTP
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(5)),
                      child: TextField(
                        controller: newPasswordController,
                        style: const TextStyle(fontSize: 14),
                        obscureText: passwordVisibilityProvider.passwordVisible
                            ? false
                            : true,
                        decoration: InputDecoration(
                          hintText: 'New Password',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.only(bottom: 8, left: 5, top: 5),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              passwordVisibilityProvider
                                  .togglePasswordVisibility(); //visibility of password set by this method.
                            },
                            child: Icon(
                              size: 22,
                              passwordVisibilityProvider.passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        autofillHints: const [
                          AutofillHints.oneTimeCode
                        ], // Enable autofill with OTP
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    Container(
                      height: size.height * 0.05,
                      decoration: BoxDecoration(
                          border: Border.all(color: Colors.black, width: 0.5),
                          borderRadius: BorderRadius.circular(5)),
                      child: TextField(
                        controller: confirmPasswordController,
                        style: const TextStyle(fontSize: 14),
                        obscureText: passwordVisibilityProvider.passwordVisible
                            ? false
                            : true,
                        decoration: InputDecoration(
                          hintText: 'Confirm Password',
                          hintStyle: const TextStyle(fontSize: 12),
                          border: InputBorder.none,
                          contentPadding:
                              const EdgeInsets.only(bottom: 8, left: 5, top: 5),
                          suffixIcon: GestureDetector(
                            onTap: () {
                              passwordVisibilityProvider
                                  .togglePasswordVisibility(); //visibility of password set by this method.
                            },
                            child: Icon(
                              size: 22,
                              passwordVisibilityProvider.passwordVisible
                                  ? Icons.visibility
                                  : Icons.visibility_off,
                              color: Colors.grey,
                            ),
                          ),
                        ),
                        autofillHints: const [
                          AutofillHints.oneTimeCode
                        ], // Enable autofill with OTP
                      ),
                    ),
                    const SizedBox(
                      height: 30,
                    ),
                    Container(
                      width: double.infinity,
                      height: size.height * 0.06,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        gradient: const LinearGradient(
                          colors: [Appcolor.themeColor, Appcolor.themeColor],
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                        ),
                      ),
                      child: TextButton(
                        onPressed: () async {
                          final pref = await SharedPreferences.getInstance();
                          final mobNumber = pref.getString('otpMobNo');
                          final schoolCode = pref.getString('schoolCode');
                          // ignore: use_build_context_synchronously
                          await ForgotPasswordService()
                              .schoolDetailApi(schoolCode.toString(), context);
                          if (newPasswordController.text.isEmpty ||
                              confirmPasswordController.text.isEmpty) {
                            // ignore: use_build_context_synchronously
                            CommonMethods().showSnackBar(
                                context, 'All fields are mandatory');
                          } else if (newPasswordController.text !=
                              confirmPasswordController.text) {
                            // ignore: use_build_context_synchronously
                            CommonMethods().showSnackBar(
                                context, 'Password fields do not match');
                          } else {
                            // ignore: use_build_context_synchronously
                            ForgotPasswordService().changePasswd(
                                mobNumber.toString(),
                                confirmPasswordController.text,
                                otpControllerForgotPasswd.text,
                                context);
                          }
                          setState(() {
                            otpControllerForgotPasswd.clear();
                            confirmPasswordController.clear();
                            newPasswordController.clear();
                          });
                        },
                        child: const Text(
                          'Verify Otp',
                          style: TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    )
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
