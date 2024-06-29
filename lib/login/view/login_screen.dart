import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';

import '../../utils/common_methods.dart';

import '../../forgot_password/view/forgot_password.dart';
import '../../utils/appcolors.dart';
import '../service/login_api.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../view_model/login_view_model.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({
    super.key,
  });

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  TextEditingController mobilenoController = TextEditingController();
  TextEditingController passwordController = TextEditingController();
  TextEditingController schoolCodeController = TextEditingController();
  String defaultUserType = 'Parent';
  bool isVisible = true;
  final LoginApi loginApi = LoginApi(); //instance of Loginapi created
// List of UserType are below.
  final List<String> userTypeOptions = [
    'Admin',
    'Parent',
    'Principal',
    'Teacher',
  ];
  int mobnumberlength = 0;
  onChanged(String value) {
    setState(() {
      mobnumberlength = value.length;
    });
  }

  //init method calls first when this screen launches
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
    final Size size =
        MediaQuery.of(context).size; //used for making Responsive UI.
    final passwordVisibilityProvider =
        Provider.of<LoginProvider>(context); //Login Provider initialization.

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              SizedBox(
                height: size.height * 0.12,
              ),
              const Text(
                "Login with",
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700),
              ),
              const Text(
                "Your existing account",
                style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
              ),
              Image.asset('assets/images/Login.png'),
              Card(
                child: Container(
                  height: size.height * 0.055,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: TextField(
                    cursorColor: Appcolor.themeColor,
                    keyboardType: TextInputType.phone,
                    cursorWidth: 1,
                    onChanged: onChanged,
                    style: const TextStyle(fontSize: 14),
                    controller: mobilenoController,
                    decoration: const InputDecoration(
                      hintText: 'Mobile no',
                      hintStyle: TextStyle(fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: EdgeInsets.only(bottom: 6, left: 5),
                    ),
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                child: Container(
                  height: size.height * 0.055,
                  decoration: BoxDecoration(
                      border: Border.all(color: Colors.black, width: 0.5),
                      borderRadius: BorderRadius.circular(5)),
                  child: TextField(
                    cursorColor: Appcolor.themeColor,
                    cursorWidth: 1,
                    controller: passwordController,
                    style: const TextStyle(fontSize: 14),
                    obscureText: passwordVisibilityProvider.passwordVisible
                        ? false
                        : true,
                    decoration: InputDecoration(
                      hintText: 'Password',
                      hintStyle: const TextStyle(fontSize: 12),
                      border: InputBorder.none,
                      contentPadding: const EdgeInsets.only(
                          left: 5, top: 10, bottom: 0, right: 5),
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
                  ),
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              Card(
                child: Container(
                  height: size.height * 0.055,
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
                      // dropdownColor: Colors.transparent,

                      menuMaxHeight: size.height * 0.2,
                      style: const TextStyle(fontSize: 12, color: Colors.black),
                      borderRadius: BorderRadius.circular(5),
                      value: defaultUserType,
                      isDense: true,
                      decoration: const InputDecoration(
                        hintText: 'User Type',
                        border: InputBorder.none,
                        contentPadding: EdgeInsets.only(left: 0, bottom: 6),
                      ),
                      onChanged: (newValue) {
                        setState(() {
                          defaultUserType = newValue!;
                        });
                      },
                      selectedItemBuilder: (context) {
                        return userTypeOptions.map((String value) {
                          return Align(
                            alignment: Alignment.centerLeft,
                            child: Text(
                              defaultUserType,
                              style: const TextStyle(
                                  color: Colors.green,
                                  fontWeight: FontWeight.bold),
                            ),
                          );
                        }).toList();
                      },
                      items: userTypeOptions
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
              isVisible
                  ? const SizedBox(
                      height: 10,
                    )
                  : const SizedBox.shrink(),
              isVisible
                  ? Card(
                      child: Container(
                        height: size.height * 0.055,
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.black, width: 0.5),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextField(
                          cursorColor: Appcolor.themeColor,

                          // enabled: false,
                          cursorWidth: 1,
                          style: const TextStyle(fontSize: 14),
                          controller: schoolCodeController,
                          decoration: const InputDecoration(
                            hintText: 'School code',
                            hintStyle: TextStyle(fontSize: 12),
                            border: InputBorder.none,
                            contentPadding: EdgeInsets.only(bottom: 6, left: 5),
                          ),
                        ),
                      ),
                    )
                  : const SizedBox.shrink(),
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

                    pref.setString('mobno', mobilenoController.text);

                    pref.setString('userType', defaultUserType);
                    pref.setString('schoolCode', schoolCodeController.text);

                    if (mobilenoController.text.isEmpty ||
                        passwordController.text.isEmpty) {
                      // ignore: use_build_context_synchronously
                      CommonMethods().showSnackBar(
                          context, 'All fields are mandatory to fill');
                      return;
                    }
                    if (mobnumberlength == 10 || mobnumberlength == 12) {
                      // ignore: use_build_context_synchronously
                      await passwordVisibilityProvider
                          .schoolDetailApi(schoolCodeController.text);
                      // ignore: use_build_context_synchronously
                      await passwordVisibilityProvider.login(
                        mobilenoController.text,
                        passwordController.text,
                        defaultUserType,
                        context,
                      );
                    } else {
                      // ignore: use_build_context_synchronously
                      CommonMethods()
                          .showSnackBar(context, 'Invalid mobile number');
                    }
                  },
                  child: const Text(
                    'Login',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 14,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  SizedBox(
                      height: size.height * 0.05,
                      child: TextButton(
                          onPressed: () async {
                            final pref = await SharedPreferences.getInstance();

                            pref.setString(
                                'schoolCode', schoolCodeController.text);
                            if (schoolCodeController.text.isNotEmpty) {
                              // ignore: use_build_context_synchronously
                              Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                      builder: (_) =>
                                          const ForgotPasswordScreen()));
                            } else {
                              // ignore: use_build_context_synchronously
                              CommonMethods().showSnackBar(
                                  context, "School code field is mandatory");
                            }
                          },
                          child: const Text(
                            'Forgot Password?',
                            style: TextStyle(fontSize: 12),
                          )))
                ],
              ),
              if (loginApi.isLoading)
                Container(
                  color: Colors.white,
                  child: const Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}
