// import 'package:fl_chart/fl_chart.dart';

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import 'package:pie_chart/pie_chart.dart';
import 'package:url_launcher/url_launcher.dart';
import '../../utils/common_methods.dart';

import '../../admin/get_student_by_filter/view/get_student_by_filter.dart';

import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../notification_services/notification_services.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../../walkthrough/walkthrough_screen.dart';
import '../view_model/dashboard_view_model.dart';
import 'admin_piechart.dart';

class DashBoardScreen extends StatefulWidget {
  const DashBoardScreen({super.key});

  @override
  State<DashBoardScreen> createState() => _DashBoardScreenState();
}

class _DashBoardScreenState extends State<DashBoardScreen> {
  static NotificationServices notificationServices = NotificationServices();
  String userType = '';
  int? schoolId;
  int? sessionId;
  String? mobno;
  String? userId;
  int? totalStudent;
  String? schoolName;
  String? schoolwebsite;
  bool version = false;
  String versionNumber = '';

  @override
  void initState() {
    super.initState();

    savedData();
    CommonMethods().initCall(context);

    //to set the status bar and its icon color.
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

// method to call in init state having shared preference saved data with student data.
  void savedData() async {
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    versionNumber = packageInfo.version;
    print(versionNumber);
    //creating instance for SHaredPreference class;
    final pref = await SharedPreferences.getInstance();
    // using getString method of sharedPreference to store saved value.
    userType = pref.getString('userType').toString();
    schoolId = pref.getInt('schoolid');
    print('school id is $schoolId');
    userId = pref.getInt('userid').toString();
    schoolName = pref.getString('schoolname');
    schoolwebsite = pref.getString('schoolwebsite');
    sessionId = pref.getInt('sessionid');
    mobno = pref.getString('mobno');

//initialization of StudentProvider class to fetch student data.
    // ignore: use_build_context_synchronously
    final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
    menuProvider.fetchTeacherInfo(mobno.toString());

    if (menuProvider.teacherInfo?.photo != null) {
      menuProvider
          .checkFileExistence(menuProvider.teacherInfo!.photo.toString());
    }
    if (userType == "Parent") {
      final studentProviders =
          // ignore: use_build_context_synchronously
          Provider.of<StudentProvider>(context, listen: false);
      //fetching student data using studentProvider instance.
      // ignore: use_build_context_synchronously
      studentProviders.fetchStudentData(
          mobno.toString(), schoolId.toString(), sessionId.toString(), context);
      schoolName = pref.getString('schoolname');
      final student = studentProviders.profile;
      final students = student?.stm ?? [];
      // for (var student in students) {
      //   await menuProvider.checkFileExistence(student.photo.toString());
      // }
    } else if (userType == "Admin" ||
        userType == "Teacher" ||
        userType == "Parent" ||
        userType == "Principal") {
      // ignore: use_build_context_synchronously

      final dashboardProvider =
          // ignore: use_build_context_synchronously
          Provider.of<DashBoardViewModel>(context, listen: false);
      schoolName = pref.getString('schoolname');
      if (sessionId != null) {
        // ignore: use_build_context_synchronously
        dashboardProvider.adminDashBoard(
            userId.toString(), sessionId!, context);
        schoolName = pref.getString('schoolname');
      }
    }

    //after successful login allow notification permission method is called.
    notificationServices.requestNotificationPermission();
    // await requestPermissions();
    //firbase get initialized.
    // ignore: use_build_context_synchronously
    notificationServices.firebaseInit(context);
    //below method is for handling navigation on tap notification in terminate state.
    // ignore: use_build_context_synchronously
    notificationServices.setupInteractMessage(context);
    // ignore: use_build_context_synchronously
    notificationServices.backgroundNavigation(context);
    // //this function get the device token and updates the user token also.
    notificationServices.getDeviceToken();

    if (userType == "Admin" || userType == "Principal") {
      final dashboardProvider =
          // ignore: use_build_context_synchronously
          Provider.of<DashBoardViewModel>(context, listen: false);
      dashboardProvider.punchingData();
    }
  }

  // Future<void> requestPermissions() async {
  //   Map<Permission, PermissionStatus> statuses = await [
  //     Permission.camera,
  //     Permission.storage,
  //   ].request();

  //   if (statuses[Permission.camera] != PermissionStatus.granted ||
  //       statuses[Permission.storage] != PermissionStatus.granted) {
  //     // Permissions denied, show a dialog or navigate to settings
  //     await showPermissionDialog();
  //   }
  // }

  // Future<void> showPermissionDialog() async {
  //   // Ensure that navigatorKey.currentContext is not null
  //   final currentContext = navigatorKey.currentContext;
  //   if (currentContext == null) {
  //     // Handle the case when the context is null
  //     print("Error: navigatorKey.currentContext is null.");
  //     return;
  //   }
  //   // Show a dialog to inform the user and navigate to app settings
  //   // You can customize this dialog as needed
  //   await showDialog(
  //     context: currentContext,
  //     builder: (BuildContext context) {
  //       return AlertDialog(
  //         title: Text("Permissions Required"),
  //         content:
  //             Text("Please allow camera and storage permissions for this app."),
  //         actions: [
  //           TextButton(
  //             onPressed: () {
  //               Navigator.pop(context);
  //               openAppSettings();
  //             },
  //             child: Text("Open Settings"),
  //           ),
  //         ],
  //       );
  //     },
  //   );
  // }

  @override
  Widget build(BuildContext context) {
    //using mediaquery to make responsive UI.
    final Size size = MediaQuery.of(context).size;

    //initialization of providers to use and accessing its methods.
    final studentProvider = Provider.of<StudentProvider>(context);
    final dashBoardProvider = Provider.of<DashBoardViewModel>(context);
    totalStudent = dashBoardProvider.data['TotalStudent'];
    final submittedFee = dashBoardProvider.data['feesubmission'] ?? 'N/A';
    final dueFee = dashBoardProvider.data['duefee'] ?? 'N/A';
    final student = studentProvider.profile;
    final students = student?.stm ?? [];
    final menuProvider = Provider.of<MenuViewModel>(context);
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();

    return studentProvider
            .isLoading //while loading students data showing loader.
        ? SizedBox(
            height: size.height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(20),
                      color: Colors.black,
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10.0, vertical: 5.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Text(
                            'Loading....',
                            style: TextStyle(
                                color: Colors.white,
                                fontSize: size.width * 0.03),
                          ),
                          LoadingAnimationWidget.twistingDots(
                            leftDotColor: const Color(0xFFFAFAFA),
                            rightDotColor: const Color(0xFFEA3799),
                            size: size.width * 0.05,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor:
                  userType == "Parent" ? Colors.white : Appcolor.themeColor,
              elevation: 0,
              title: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  menuProvider.bytesImage != null
                      ? Image.memory(
                          menuProvider.bytesImage!,
                          height: size.height * 0.07,
                          width: size.width * 0.07,
                        )
                      : const SizedBox.shrink(),
                  const SizedBox(
                    width: 10,
                  ),
                  Expanded(
                    child: Text(
                      schoolName != null ? schoolName.toString() : '',
                      style: TextStyle(
                          overflow: TextOverflow.ellipsis,
                          color: userType == "Parent"
                              ? Colors.black
                              : Colors.white,
                          fontSize: 14,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () async {
                    final pref = await SharedPreferences.getInstance();
                    // on logout button pressed clearing all the saved data in shared preference.
                    pref.clear();
                    menuProvider.bytesImage = null;
                    // navigation to the screen after successful logout.
                    // ignore: use_build_context_synchronously
                    Navigator.push(
                        context,
                        MaterialPageRoute(
                            builder: (_) => const WalkthroughScreen()));
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.logout,
                        color:
                            userType == "Parent" ? Colors.black : Colors.white,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Logout',
                        style: TextStyle(
                            color: userType == "Parent"
                                ? Colors.black
                                : Colors.white,
                            fontSize: 14),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            body: Column(
              children: [
                userType == "Teacher" ||
                        userType == "Admin" ||
                        userType == "Principal"
                    ? Container(
                        height: size.height * 0.28,
                        width: size.width,
                        decoration: const BoxDecoration(
                          color: Appcolor.themeColor,
                          borderRadius: BorderRadius.only(
                            bottomLeft: Radius.circular(25),
                            bottomRight: Radius.circular(25),
                          ),
                        ),
                        child: Column(
                          children: [
                            userType == "Parent" && version == true
                                ? const SizedBox(
                                    height: 5,
                                  )
                                : const SizedBox.shrink(),
                            userType == "Parent" && version == true
                                ? Text(
                                    'Version:$versionNumber',
                                    style: const TextStyle(color: Colors.white),
                                  )
                                : const SizedBox.shrink(),
                            const SizedBox(
                              height: 5,
                            ),
                            userType == "Teacher" ||
                                    userType == "Admin" ||
                                    userType == "Principal"
                                ? teacherPhoto != null
                                    ? menuProvider.fileExists
                                        ? Container(
                                            width: 80,
                                            height: 80,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Appcolor.lightgrey),
                                            child: ClipOval(
                                              child: Image.network(
                                                teacherPhoto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
                                                  // Handle network image loading error here
                                                  return Image.asset(
                                                      'assets/images/user_profile.png'); // Replace with your error placeholder image
                                                },
                                                loadingBuilder: (context, child,
                                                    loadingProgress) {
                                                  if (loadingProgress == null) {
                                                    return child;
                                                  } else {
                                                    return const Center(
                                                        child:
                                                            CupertinoActivityIndicator(
                                                      color: Colors.blueGrey,
                                                    ));
                                                  }
                                                },
                                              ),
                                            ),
                                          )
                                        : Container(
                                            width: 80,
                                            height: 80,
                                            decoration: const BoxDecoration(
                                                shape: BoxShape.circle,
                                                color: Appcolor.lightgrey),
                                            child: ClipOval(
                                              child: Image.asset(
                                                'assets/images/user_profile.png',
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          )
                                    : Container(
                                        width: 80,
                                        height: 80,
                                        decoration: const BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: Appcolor.lightgrey),
                                        child: ClipOval(
                                          child: Image.asset(
                                            'assets/images/user_profile.png',
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      )
                                : menuProvider.bytesImage != null
                                    ? Image.memory(
                                        menuProvider.bytesImage!,
                                        height: size.height * 0.2,
                                        width: size.width * 0.2,
                                      )
                                    : const SizedBox.shrink(),
                            const SizedBox(
                              height: 5,
                            ),
                            userType == "Admin" ||
                                    userType == 'Teacher' ||
                                    userType == "Principal"
                                ? Text(
                                    'Name: $teacherName',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600,
                                        overflow: TextOverflow.ellipsis),
                                  )
                                : const SizedBox.shrink(),
                            userType == "Admin" ||
                                    userType == 'Teacher' ||
                                    userType == "Principal"
                                ? const SizedBox(
                                    height: 2,
                                  )
                                : Container(),
                            userType == "Admin" ||
                                    userType == 'Teacher' ||
                                    userType == "Principal"
                                ? Text(
                                    'Email: $teacherEmail',
                                    style: const TextStyle(
                                        color: Colors.white,
                                        fontSize: 12,
                                        fontWeight: FontWeight.w600),
                                  )
                                : Container(),
                            userType == "Admin" ||
                                    userType == 'Teacher' ||
                                    userType == "Principal"
                                ? const SizedBox(
                                    height: 2,
                                  )
                                : Container(),
                            userType == "Admin" ||
                                    userType == 'Teacher' ||
                                    userType == "Principal"
                                ? Expanded(
                                    child: Text(
                                      'Contact: $mobno',
                                      style: const TextStyle(
                                          color: Colors.white,
                                          fontSize: 12,
                                          fontWeight: FontWeight.w600),
                                    ),
                                  )
                                : Container(),
                          ],
                        ),
                      )
                    : userType == "Parent"
                        ? SizedBox(
                            height: size.height * 0.3,
                            child: Image.asset('assets/images/school_new.png'))
                        : Container(),
                userType == "Parent"
                    ? GestureDetector(
                        onTap: () async {
                          final url = schoolwebsite.toString();
                          if (await canLaunch(url)) {
                            await launch(url,
                                forceWebView: true, enableJavaScript: true);
                          } else {
                            // ignore: use_build_context_synchronously
                            CommonMethods()
                                .showSnackBar(context, 'Something went wrong');
                          }
                        },
                        child: Text(
                          'Visit:$schoolwebsite',
                          style: TextStyle(
                              color: Colors.blue,
                              overflow: TextOverflow.ellipsis,
                              fontWeight: FontWeight.bold,
                              fontSize: size.width * 0.03),
                        ))
                    : const SizedBox.shrink(),
                const SizedBox(
                  height: 10,
                ),
                userType == 'Parent'
                    ? Flexible(
                        child: ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: students.length,
                          itemBuilder: (BuildContext context, int index) {
                            final student = students[index];
                            return students.isNotEmpty
                                ? InkWell(
                                    onTap: () async {
                                      final pref =
                                          await SharedPreferences.getInstance();
                                      //on tap of any particular student these data are stored in the shared preferences.
                                      pref.setString('attendanceRegNo',
                                          student.regNo.toString());
                                      if (student.stuName != null) {
                                        pref.setString('attendanceStudentName',
                                            student.stuName.toString());
                                      } else {
                                        pref.setString(
                                            'attendanceStudentName', 'N/A');
                                      }

                                      if (student.className != null) {
                                        pref.setString('attendanceStudentClass',
                                            student.className.toString());
                                      } else {
                                        pref.setString(
                                            'attendanceStudentClass', 'N/A');
                                      }
                                      if (student.sectionName != null) {
                                        pref.setString(
                                            'attendanceStudentSection',
                                            student.sectionName.toString());
                                      } else {
                                        pref.setString(
                                            'attendanceStudentSection', 'N/A');
                                      }

                                      if (student.rollNo != null) {
                                        pref.setString('attendanceStudentRoll',
                                            student.rollNo.toString());
                                      } else {
                                        pref.setString(
                                            'attendanceStudentRoll', 'N/A');
                                      }
                                      if (student.stuId != null) {
                                        pref.setInt('StuId', student.stuId!);
                                      } else {
                                        pref.setInt('StuId', 0);
                                      }

                                      if (student.photo != null) {
                                        pref.setString('attendanceStudentPhoto',
                                            student.photo.toString());
                                      }
                                      // else {
                                      //   pref.setString('attendanceStudentPhoto',
                                      //       'https://source.unsplash.com/random/?city,night');
                                      // }

                                      pref.setInt('classId', student.classId!);
                                      pref.setInt(
                                          'sectionId', student.sectionId!);
                                      //method to get selected student profile.
                                      dashBoardProvider
                                          .selectStudent(students[index]);
                                      // ignore: use_build_context_synchronously
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (_) => const MenuScreen(),
                                        ),
                                      );
                                    },
                                    child: Padding(
                                      padding: const EdgeInsets.symmetric(
                                          horizontal: 15.0),
                                      child: Card(
                                        child: Container(
                                          height: size.height * 0.13,
                                          width: double.infinity,
                                          decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(10)),
                                          child: Row(
                                            mainAxisSize: MainAxisSize.min,
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              Container(
                                                width: 20,
                                                decoration: const BoxDecoration(
                                                  gradient:
                                                      Appcolor.blueGradient,
                                                  borderRadius:
                                                      BorderRadius.only(
                                                    topLeft:
                                                        Radius.circular(10),
                                                    bottomLeft:
                                                        Radius.circular(10),
                                                  ),
                                                ),
                                              ),
                                              Expanded(
                                                child: Container(
                                                  height: size.height * 0.13,
                                                  decoration:
                                                      const BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.only(
                                                      topRight:
                                                          Radius.circular(10),
                                                      bottomRight:
                                                          Radius.circular(10),
                                                    ),
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            10.0),
                                                    child: Row(
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        Container(
                                                            width: 50,
                                                            height: 50,
                                                            decoration: const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Appcolor
                                                                    .lightgrey),
                                                            child:
                                                                student.photo !=
                                                                        null
                                                                    ? ClipOval(
                                                                        child: Image
                                                                            .network(
                                                                          student
                                                                              .photo!,
                                                                          fit: BoxFit
                                                                              .cover,
                                                                          errorBuilder: (context,
                                                                              error,
                                                                              stackTrace) {
                                                                            // Handle network image loading error here
                                                                            return Image.asset('assets/images/user_profile.png'); // Replace with your error placeholder image
                                                                          },
                                                                          loadingBuilder: (context,
                                                                              child,
                                                                              loadingProgress) {
                                                                            if (loadingProgress ==
                                                                                null) {
                                                                              return child;
                                                                            } else {
                                                                              return const Center(
                                                                                child: CupertinoActivityIndicator(color: Appcolor.themeColor),
                                                                              );
                                                                            }
                                                                          },
                                                                        ),
                                                                      )
                                                                    : ClipOval(
                                                                        child: Image
                                                                            .asset(
                                                                          'assets/images/user_profile.png',
                                                                          fit: BoxFit
                                                                              .cover,
                                                                        ),
                                                                      )),
                                                        SizedBox(
                                                          width:
                                                              size.width * 0.05,
                                                        ),
                                                        Column(
                                                          mainAxisSize:
                                                              MainAxisSize.min,
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .start,
                                                          crossAxisAlignment:
                                                              CrossAxisAlignment
                                                                  .start,
                                                          children: [
                                                            Padding(
                                                              padding:
                                                                  const EdgeInsets
                                                                          .only(
                                                                      top: 2.0),
                                                              child: Row(
                                                                mainAxisSize:
                                                                    MainAxisSize
                                                                        .min,
                                                                children: [
                                                                  const Text(
                                                                    'Name: ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  Text(
                                                                    student.stuName ??
                                                                        '',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight
                                                                                .w500,
                                                                        overflow:
                                                                            TextOverflow.ellipsis),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Adm.no: ',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                Text(
                                                                  student.regNo ??
                                                                      '',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                              height: 2,
                                                            ),
                                                            Row(
                                                              children: [
                                                                const Text(
                                                                  'Gender: ',
                                                                  style: TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w600),
                                                                ),
                                                                Text(
                                                                  student.gender ??
                                                                      'N/A',
                                                                  style: const TextStyle(
                                                                      fontSize:
                                                                          12,
                                                                      color: Colors
                                                                          .black,
                                                                      fontWeight:
                                                                          FontWeight
                                                                              .w500),
                                                                ),
                                                              ],
                                                            ),
                                                            const SizedBox(
                                                                height: 2),
                                                            Flexible(
                                                              child: Row(
                                                                children: [
                                                                  const Text(
                                                                    'Class: ',
                                                                    style: TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w600),
                                                                  ),
                                                                  Text(
                                                                    student.className ??
                                                                        'N/A',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                  const SizedBox(
                                                                      width: 2),
                                                                  Text(
                                                                    student.sectionName ??
                                                                        '',
                                                                    style: const TextStyle(
                                                                        fontSize:
                                                                            12,
                                                                        color: Colors
                                                                            .black,
                                                                        fontWeight:
                                                                            FontWeight.w500),
                                                                  ),
                                                                ],
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                    ),
                                  )
                                : const Center(
                                    child: Text('No Students available'),
                                  );
                          },
                        ),
                      )
                    : userType == "Admin" || userType == "Principal"
                        ? Expanded(
                            flex: 1,
                            child: Padding(
                              padding: const EdgeInsets.all(20.0),
                              child: SingleChildScrollView(
                                child: Column(
                                  children: [
                                    dashBoardProvider.adminLoading
                                        ? SizedBox(
                                            height: size.height * 0.2,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                Container(
                                                  color: Colors.black,
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .center,
                                                      children: [
                                                        const Text(
                                                          'Loading....',
                                                          style: TextStyle(
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                        LoadingAnimationWidget
                                                            .twistingDots(
                                                          leftDotColor:
                                                              const Color(
                                                                  0xFFFAFAFA),
                                                          rightDotColor:
                                                              const Color(
                                                                  0xFFEA3799),
                                                          size: 30,
                                                        ),
                                                      ],
                                                    ),
                                                  ),
                                                )
                                              ],
                                            ),
                                          )
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.spaceBetween,
                                            children: [
                                              Card(
                                                color: Colors.amber,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: SizedBox(
                                                  height: size.height * 0.12,
                                                  width: size.width * 0.35,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          'Total Students',
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          totalStudent != null
                                                              ? totalStudent
                                                                  .toString()
                                                              : 'N/A',
                                                          style:
                                                              const TextStyle(
                                                                  fontSize: 16,
                                                                  fontWeight:
                                                                      FontWeight
                                                                          .bold,
                                                                  color: Colors
                                                                      .white),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                              Card(
                                                color: Colors.teal,
                                                shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10)),
                                                child: SizedBox(
                                                  height: size.height * 0.12,
                                                  width: size.width * 0.40,
                                                  child: Column(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment
                                                            .center,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .center,
                                                    children: [
                                                      const FittedBox(
                                                        fit: BoxFit.scaleDown,
                                                        child: Text(
                                                          "Today's Collection",
                                                          style: TextStyle(
                                                              fontSize: 14,
                                                              fontWeight:
                                                                  FontWeight
                                                                      .bold,
                                                              color:
                                                                  Colors.white),
                                                        ),
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Center(
                                                        child: FittedBox(
                                                          fit: BoxFit.scaleDown,
                                                          child: Text(
                                                            submittedFee
                                                                    .toString()
                                                                    .isNotEmpty
                                                                ? '\u{20B9}$submittedFee'
                                                                : 'N/A',
                                                            style: const TextStyle(
                                                                fontSize: 16,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .bold,
                                                                color: Colors
                                                                    .white),
                                                          ),
                                                        ),
                                                      )
                                                    ],
                                                  ),
                                                ),
                                              ),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 15,
                                    ),
                                    Card(
                                      color: Colors.red,
                                      shape: RoundedRectangleBorder(
                                          borderRadius:
                                              BorderRadius.circular(10)),
                                      child: SizedBox(
                                        height: size.height * 0.12,
                                        width: size.width,
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.center,
                                          children: [
                                            const FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Due Fee',
                                                style: TextStyle(
                                                    fontSize: 14,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                dueFee.toString().isNotEmpty
                                                    ? '\u{20B9}$dueFee'
                                                    : 'N/A',
                                                style: const TextStyle(
                                                    fontSize: 16,
                                                    fontWeight: FontWeight.bold,
                                                    color: Colors.white),
                                              ),
                                            )
                                          ],
                                        ),
                                      ),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    const Text(
                                      "Today's Attendance",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(
                                      color: Appcolor.themeColor,
                                      thickness: 1,
                                    ),
                                    dashBoardProvider
                                            .attendanceDashboard.isNotEmpty
                                        ? PieChart(
                                            chartRadius: 170,
                                            dataMap: dashBoardProvider
                                                .attendanceDashboard,
                                            chartType: ChartType.disc,
                                            colorList: const [
                                              Colors.green,
                                              Colors.red,
                                              Colors.blue
                                            ],
                                            chartValuesOptions:
                                                const ChartValuesOptions(
                                                    chartValueStyle: TextStyle(
                                                        fontSize: 10,
                                                        color: Colors.white,
                                                        fontWeight:
                                                            FontWeight.bold),
                                                    chartValueBackgroundColor:
                                                        Colors.transparent,
                                                    showChartValuesInPercentage:
                                                        true),
                                          )
                                        : Column(
                                            children: [
                                              SizedBox(
                                                height: size.height * 0.3,
                                                child: Image.asset(
                                                  'assets/images/attendance_calendar.jpg',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 2.0),
                                                child: Text(
                                                  'No Attendance for today',
                                                  style: TextStyle(
                                                      color: Colors.grey),
                                                ),
                                              ),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 20,
                                    ),
                                    const Text(
                                      "Today's Fee Submission",
                                      style: TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Divider(
                                      color: Appcolor.themeColor,
                                      thickness: 1,
                                    ),
                                    dashBoardProvider.paymentModeData.isNotEmpty
                                        ? const PieChartSample2()
                                        : Column(
                                            children: [
                                              SizedBox(
                                                height: size.height * 0.3,
                                                child: Image.asset(
                                                  'assets/images/fees.png',
                                                  fit: BoxFit.cover,
                                                ),
                                              ),
                                              const Padding(
                                                padding:
                                                    EdgeInsets.only(top: 2.0),
                                                child: Text(
                                                    'No fee submission for today',
                                                    style: TextStyle(
                                                        color: Colors.grey)),
                                              ),
                                            ],
                                          ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                    InkWell(
                                      onTap: () {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                            builder: (_) =>
                                                const GetStudentByFilterAdmin(),
                                          ),
                                        ).then((value) {
                                          setState(() {});
                                        });
                                      },
                                      child: Container(
                                        width: size.width * 0.3,
                                        height: size.height * 0.06,
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            color: Appcolor.themeColor),
                                        child: const Center(
                                          child: Padding(
                                            padding: EdgeInsets.all(2.0),
                                            child: FittedBox(
                                              fit: BoxFit.scaleDown,
                                              child: Text(
                                                'Search Student',
                                                style: TextStyle(
                                                    color: Colors.white),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    )
                                  ],
                                ),
                              ),
                            ),
                          )
                        : const SizedBox.shrink(),
              ],
            ),
          );
  }
}
