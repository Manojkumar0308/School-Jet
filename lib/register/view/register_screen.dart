import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_jet/forgot_password/service/forgot_password_api.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:flutter/services.dart';
import '../../login/view_model/login_view_model.dart';
import '../../utils/appcolors.dart';
import '../service/register_api.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  TextEditingController userNameController = TextEditingController();
  TextEditingController mobileNumberController = TextEditingController();

  TextEditingController emailController = TextEditingController();

  TextEditingController schoolusernameController = TextEditingController();
  TextEditingController newPasswordController = TextEditingController();
  TextEditingController confirmPasswordController = TextEditingController();
  String dropdownValue = 'Parent';
  bool isVisible = false;
  bool tap = true;
  final List<String> dropdownOptions = [
    'Admin',
    'Parent',
    'Principal',
    'Teacher',
  ];
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
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              SizedBox(
                height: size.height * 0.08,
              ),
              const Text(
                'User Registration',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                ),
              ),
              const Text(
                'Please fill the form for the registration',
                style: TextStyle(
                  fontSize: 10,
                ),
              ),
              Center(
                child: Image.asset(
                  'assets/images/register.png',
                  height: size.height * 0.25,
                  width: size.width * 0.6,
                ),
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Container(
                  height: size.height * 0.05,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: TextField(
                    cursorColor: Colors.black,
                    cursorWidth: 1,
                    style: const TextStyle(fontSize: 14),
                    controller: userNameController,
                    decoration: const InputDecoration(
                      hintText: 'Username',
                      hintStyle: TextStyle(fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 10, left: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                child: Container(
                  height: size.height * 0.05,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: TextField(
                    controller: mobileNumberController,
                    style: const TextStyle(fontSize: 14),
                    keyboardType: TextInputType.phone,
                    decoration: const InputDecoration(
                      hintText: 'Mobile Number',
                      hintStyle: TextStyle(fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 10, left: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                child: Container(
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
                      hintText: 'Password',
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
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                child: Container(
                  height: size.height * 0.05,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: TextField(
                    controller: emailController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'Email',
                      hintStyle: TextStyle(fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 10, left: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                child: Container(
                  height: size.height * 0.05,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: TextField(
                    controller: schoolusernameController,
                    style: const TextStyle(fontSize: 14),
                    decoration: const InputDecoration(
                      hintText: 'School code',
                      hintStyle: TextStyle(fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 10, left: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                margin: EdgeInsets.zero,
                child: Container(
                  height: size.height * 0.05,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: ButtonTheme(
                    layoutBehavior: ButtonBarLayoutBehavior.constrained,
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    alignedDropdown: true,
                    child: DropdownButtonFormField<String>(
                      value: dropdownValue,
                      menuMaxHeight: size.height * 0.2,
                      borderRadius: BorderRadius.circular(5),
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      isDense: true,
                      // padding: const EdgeInsets.only(bottom: 2, left: 5),
                      decoration: const InputDecoration(
                          hintText: 'User Type',
                          border: InputBorder.none,
                          contentPadding: EdgeInsets.only(left: 5, bottom: 10)),
                      onChanged: (newValue) {
                        setState(() {
                          dropdownValue = newValue!;
                        });
                      },
                      selectedItemBuilder: (context) {
                        return dropdownOptions.map((String value) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              dropdownValue,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList();
                      },
                      items: dropdownOptions
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Container(
                            decoration: BoxDecoration(
                                border:
                                    Border.all(color: Colors.black, width: 3)),
                            child: Padding(
                              padding: const EdgeInsets.only(
                                  left: 15.0,
                                  top: 12.0,
                                  bottom: 12.0,
                                  right: 12.0),
                              child: Row(
                                children: [
                                  Text(
                                    value,
                                    style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.black,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
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
                    tap = false;
                    // ignore: use_build_context_synchronously
                    await ForgotPasswordService().schoolDetailApi(
                        schoolusernameController.text, context);

                    if (_areFieldsNotEmpty()) {
                      // ignore: use_build_context_synchronously
                      RegisterApi().userRegister(
                          userNameController.text,
                          mobileNumberController.text,
                          confirmPasswordController.text,
                          emailController.text,
                          schoolusernameController.text,
                          dropdownValue,
                          context);
                      pref.setString('userName', userNameController.text);
                      pref.setString('mobNumber', mobileNumberController.text);
                      pref.setString('email', emailController.text);
                      pref.setString(
                          'schoolCode', schoolusernameController.text);
                      pref.setString(
                          'password', confirmPasswordController.text);
                      pref.setString('usertype', dropdownValue);
                    } else {
                      _showSnackbar('All fields are mandatory');
                    }
                    userNameController.clear();
                    mobileNumberController.clear();
                    emailController.clear();
                  },
                  child: const Text(
                    'Register',
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
      ),
    );
  }

  bool _areFieldsNotEmpty() {
    return userNameController.text.isNotEmpty &&
        mobileNumberController.text.isNotEmpty &&
        emailController.text.isNotEmpty &&
        schoolusernameController.text.isNotEmpty &&
        confirmPasswordController.text.isNotEmpty;
  }

  void _showSnackbar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
      ),
    );
  }
}
