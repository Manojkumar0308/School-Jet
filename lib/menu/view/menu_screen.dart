import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../Add_attendance/view/add_attendance.dart';
import '../../Exam_result/view/exam_result_view.dart';
import '../../add_homework/view/add_homework_view.dart';

import '../../admin/get_student_by_filter/view/get_student_by_filter.dart';
import '../../admin_sms_report/view/admin_sms_report.dart';
import '../../bottomnavigation/bottomnavigation_screen.dart';

import '../../event_calendar/view/even_calendar_screen.dart';
import '../../fee_detail/view/fee_detail.dart';
import '../../notification/view/notification_screen.dart';
import '../../online_payment/view/online_payment_screen.dart';
import '../../parent_due_fee/view/parent_due_fee.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../send_message/view/send_message_view.dart';
import '../../student_attendance/view/student_attendance.dart';
import '../../student_by_filter/view/model/view_model/student_by_class.dart';

import '../../student_by_regNo/view/studentByRegno_view.dart';
import '../../student_homework/view/student_homework.dart';

import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../../view_homework/view/view_homeworkscreen.dart';
import '../view_model/menu_view_model.dart';
import 'package:flutter_staggered_grid_view/flutter_staggered_grid_view.dart';

class MenuScreen extends StatefulWidget {
  const MenuScreen({
    super.key,
  });

  @override
  State<MenuScreen> createState() => _MenuScreenState();
}

class _MenuScreenState extends State<MenuScreen> with TickerProviderStateMixin {
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  bool tap = false;
  bool avatarTap = false;
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? classSection;
  String? selectedRoll;
  bool isLoading = false;

  var attendance;
  String? feeDetail;
  String? dueFeeWebView;
//method to show dialog under which having student list of a Parent userType.
  void _showStudentList(BuildContext context, List<Stm> students) {
    final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
          backgroundColor: Colors.grey[900],
          title: const Text(
            'Select Student',
            style: TextStyle(
                color: Colors.white, fontWeight: FontWeight.w600, fontSize: 14),
          ),
          content: SizedBox(
            width: double.maxFinite,
            height: 200,
            child: ListView.builder(
              shrinkWrap: true,
              itemCount: students.length,
              itemBuilder: (BuildContext context, int index) {
                final student = students[index];
                return Column(
                  children: [
                    ListTile(
                      contentPadding: const EdgeInsets.only(left: 0),
                      dense: true,
                      leading: student.photo != null
                          ? CircleAvatar(
                              radius: 20,
                              backgroundColor: Appcolor.lightgrey,
                              backgroundImage:
                                  NetworkImage(student.photo.toString()),
                            )
                          : const CircleAvatar(
                              radius: 20,
                              backgroundColor: Appcolor.lightgrey,
                              backgroundImage:
                                  AssetImage('assets/images/user_profile.png'),
                            ),
                      title: Text(
                        student.stuName ?? '',
                        style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            fontSize: 12),
                      ),
                      onTap: () async {
                        final pref = await SharedPreferences.getInstance();
                        //onTap particular student listtile first remove the previous stored data.
                        pref.remove('attendanceRegNo');
                        pref.remove('attendanceStudentName');
                        pref.remove('attendanceStudentClass');
                        pref.remove('attendanceStudentRoll');
                        pref.remove('attendanceStudentPhoto');
                        pref.remove('classId');
                        pref.remove('sectionId');
                        pref.remove('attendanceStudentSection');
                        pref.remove('StuId');
                        /*after removing the following data by selecting student again following
                        details of a student is saving again in sharedPreferences */
                        pref.setString(
                            'attendanceRegNo', student.regNo.toString());
                        if (student.stuName != null) {
                          pref.setString('attendanceStudentName',
                              student.stuName.toString());
                        } else {
                          pref.setString('attendanceStudentName', 'N/A');
                        }

                        if (student.className != null) {
                          pref.setString('attendanceStudentClass',
                              student.className.toString());
                        } else {
                          pref.setString('attendanceStudentClass', 'N/A');
                        }
                        if (student.stuId != null) {
                          pref.setInt('StuId', student.stuId!);
                        } else {
                          pref.setInt('StuId', 0);
                        }

                        if (student.rollNo != null) {
                          pref.setString('attendanceStudentRoll',
                              student.rollNo.toString());
                        } else {
                          pref.setString('attendanceStudentRoll', 'N/A');
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
                        pref.setInt('sectionId', student.sectionId!);
                        selectedName = pref.getString('attendanceStudentName');
                        selectedPhoto =
                            pref.getString('attendanceStudentPhoto');
                        selectedClass =
                            pref.getString('attendanceStudentClass');
                        classSection =
                            pref.getString('attendanceStudentSection');
                        selectedRoll = pref.getString('attendanceStudentRoll');

                        setState(() {
                          // set the bool value to true.
                          avatarTap = true;
                          //calling selectstudent method from studentProvider class.
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        // for exit the dialog box

                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                    )
                  ],
                );
              },
            ),
          ),
        );
      },
    );
  }

  @override
  void initState() {
    super.initState();

    //when screen launches below method is called first.

    initializeData();
    setBool(context);
  }

  String userType = '';
  String? baseurl;

  Future<void> initializeData() async {
    // Get a specific camera from the list of available cameras.

    await init();
  }

//in below method storing data saved in our storage and on the basis of usertype
//different functions arae called.
  Future<void> init() async {
    final pref = await SharedPreferences.getInstance();

    baseurl = pref.getString('apiurl');

    schoolId = pref.getInt('schoolid');
    userType = pref.getString('userType').toString();

    sessionId = pref.getInt('sessionid');

    mobno = pref.getString('mobno');
    selectedName = pref.getString('attendanceStudentName');
    selectedPhoto = pref.getString('attendanceStudentPhoto');
    print('selectedPhoto is $selectedPhoto');
    selectedClass = pref.getString('attendanceStudentClass');
    classSection = pref.getString('attendanceStudentSection');
    selectedRoll = pref.getString('attendanceStudentRoll');

    if (userType == 'Teacher' ||
        userType == 'Admin' ||
        userType == 'Principal') {
      //method called for to fetch teacher information present in MenuViewModel provider class.
      // ignore: use_build_context_synchronously
      final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
      menuProvider.fetchTeacherInfo(mobno.toString());
      if (menuProvider.teacherInfo?.photo != null) {
        menuProvider
            .checkFileExistence(menuProvider.teacherInfo!.photo.toString());
      }
    } else if (userType == 'Parent') {
      // ignore: use_build_context_synchronously
      final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
      //method called for to fetch student information present in StudentProvider provider class.
      final studentProvider =
          // ignore: use_build_context_synchronously
          Provider.of<StudentProvider>(context, listen: false);
      // ignore: use_build_context_synchronously
      studentProvider.fetchStudentData(
          mobno.toString(), schoolId.toString(), sessionId.toString(), context);
      final student = studentProvider.profile;
      final students = student?.stm ?? [];
    } else {}
  }

  void setBool(BuildContext context) async {
    await SharedPreferences.getInstance();
    // final user = pref.getString('userType').toString();
    // print(user);

    print('binod');
    print('userType $userType');
    if (userType == 'Teacher') {
      isLoading = true;
    } else if (userType == 'Admin' || userType == 'Principal') {
      isLoading = true;
    } else {
      isLoading = true;
    }
    isLoading = false;
  }

  @override
  Widget build(BuildContext context) {
    final isAdmin = userType != "Teacher" && userType != "Parent";

    final Size size = MediaQuery.of(context).size;
    // initializations of the providers are done inside build method.
    final menuProvider = Provider.of<MenuViewModel>(context);
    // final dashBoardProvider = Provider.of<DashBoardViewModel>(context);

    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final students = student?.stm ?? [];

    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo;
    return WillPopScope(
      onWillPop: () async {
        return CommonMethods().onwillPop(context);
      },
      child: Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          titleSpacing: 2,
          backgroundColor: Appcolor.themeColor,
          title: InkWell(
            onTap: () {
              if (userType != "Teacher" &&
                  userType != "Admin" &&
                  userType != 'Principal') {
                _showStudentList(context, students);
              }
            },
            child: SizedBox(
              width: double.infinity,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        menuProvider.removepref();
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const BottomNavigationScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back)),
                  GestureDetector(
                    onTap: () {
                      if (userType != "Teacher" &&
                          userType != "Admin" &&
                          userType != 'Principal') {
                        // on avatar tap this methods invokes dialogbox.
                        _showStudentList(context, students);
                      }
                      setState(() {
                        tap = false;
                      });
                    },
                    child: userType == "Teacher" ||
                            userType == "Admin" ||
                            userType == "Principal"
                        ? teacherPhoto != null
                            ? menuProvider.fileExists
                                ? Container(
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Appcolor.lightgrey),
                                    child: ClipOval(
                                      child: Image.network(
                                        teacherPhoto,
                                        fit: BoxFit.cover,
                                        errorBuilder:
                                            (context, error, stackTrace) {
                                          // Handle network image loading error here
                                          return Image.asset(
                                              'assets/images/user_profile.png'); // Replace with your error placeholder image
                                        },
                                        loadingBuilder:
                                            (context, child, loadingProgress) {
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
                                    width: 50,
                                    height: 50,
                                    decoration: const BoxDecoration(
                                        shape: BoxShape.circle,
                                        color: Appcolor.lightgrey),
                                    child: ClipOval(
                                      child: Image.asset(
                                        'assets/images/user_profile.png',
                                        fit: BoxFit.cover,
                                      ),
                                    ),
                                  ) // Replace with your asset image path

                            : Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Appcolor.lightgrey),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/user_profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ) // Replace with your asset image path

                        : Container(
                            width: 50,
                            height: 50,
                            decoration: const BoxDecoration(
                                shape: BoxShape.circle, color: Colors.white),
                            child: selectedPhoto == null ||
                                    selectedPhoto.toString().isEmpty
                                ? ClipOval(
                                    child: Image.asset(
                                      'assets/images/user_profile.png',
                                      fit: BoxFit.cover,
                                    ),
                                  ) // Replace with your asset image path
                                : ClipOval(
                                    child: Image.network(
                                      selectedPhoto.toString(),
                                      fit: BoxFit.cover,
                                      errorBuilder:
                                          (context, error, stackTrace) {
                                        // Handle network image loading error here
                                        return Image.asset(
                                          'assets/images/user_profile.png',
                                          fit: BoxFit.cover,
                                        ); // Replace with your error placeholder image
                                      },
                                      loadingBuilder:
                                          (context, child, loadingProgress) {
                                        if (loadingProgress == null) {
                                          return child;
                                        } else {
                                          return const Center(
                                              child: CupertinoActivityIndicator(
                                            color: Colors.blueGrey,
                                          ));
                                        }
                                      },
                                    ),
                                  ),
                          ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 7.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            userType == 'Teacher' || userType == 'Admin'
                                ? 'Name:$teacherName'
                                : userType == 'Parent'
                                    ? selectedName != null
                                        ? 'Name:$selectedName'
                                        : 'Name:N/A'
                                    : '',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: size.width * 0.03),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            userType == 'Teacher' || userType == 'Admin'
                                ? 'Email: $teacherEmail'
                                : userType == 'Parent'
                                    ? selectedClass != null
                                        ? 'Class:$selectedClass'
                                        : 'Class:N/A'
                                    : isAdmin
                                        ? ''
                                        : 'N/A',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: size.width * 0.03),
                          ),
                        ),
                        userType == 'Parent'
                            ? Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  selectedRoll == null
                                      ? 'Roll:N/A'
                                      : 'Roll:$selectedRoll',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: size.width * 0.03),
                                ),
                              )
                            : const SizedBox.shrink(),
                        userType == "Admin" ||
                                userType == 'Teacher' ||
                                userType == "Principal"
                            ? Padding(
                                padding: const EdgeInsets.only(top: 2.0),
                                child: Text(
                                  'Contact: $mobno',
                                  style: TextStyle(
                                      color: Colors.white,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: size.width * 0.03,
                                      fontWeight: FontWeight.w600),
                                ),
                              )
                            : const SizedBox.shrink(),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  )
                ],
              ),
            ),
          ),
          actions: [
            Padding(
              padding: const EdgeInsets.only(right: 15.0),
              child: menuProvider.bytesImage != null
                  ? Image.memory(
                      menuProvider.bytesImage!,
                      height: size.height * 0.08,
                      width: size.width * 0.08,
                    )
                  : const SizedBox.shrink(),
            ),
          ],
        ),
        body: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const SizedBox(
                height: 15,
              ),
              Flexible(
                child: Visibility(
                  visible: (userType == 'Teacher' ||
                      userType == 'Parent' ||
                      isAdmin ||
                      userType == 'Principal'),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 15.0),
                    // Gridview with woven style is generated here.
                    child: GridView.custom(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      gridDelegate: SliverWovenGridDelegate.count(
                        crossAxisCount: 3,
                        mainAxisSpacing: 0,
                        crossAxisSpacing: 0,
                        pattern: [
                          const WovenGridTile(1),
                          const WovenGridTile(
                            5 / 7,
                            crossAxisRatio: 1,
                            alignment: AlignmentDirectional.centerEnd,
                          ),
                        ],
                      ),
                      childrenDelegate: SliverChildBuilderDelegate(
                        (context, index) {
                          return GestureDetector(
                            onTap: () {
                              //navigation done on the basis of userType and menu items text.
                              setState(() {
                                if (userType == 'Teacher') {
                                  if (menuProvider.itemsTeacher[index].text ==
                                      'Send Notification') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SendMessageScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .itemsTeacher[index].text ==
                                      'Add Homework') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AddHomeWorkScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .itemsTeacher[index].text ==
                                      'Student By Reg No') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const StudentByRegNoScreen(),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  } else if (menuProvider
                                          .itemsTeacher[index].text ==
                                      'Add Attendance') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AddAttendanceScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .itemsTeacher[index].text ==
                                      'Events') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CalenderPage(),
                                      ),
                                    );
                                  } else if (menuProvider
                                              .itemsTeacher[index].text ==
                                          'Homework Report' &&
                                      userType == 'Teacher') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ViewHomeWorkScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .itemsTeacher[index].text ==
                                      'Student By Class') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const StudentByClass(),
                                      ),
                                    );
                                  }
                                } else if (userType == 'Parent') {
                                  if (menuProvider.studentMenu[index].text ==
                                      'Attendance') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const StudentAttendScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .studentMenu[index].text ==
                                      'Fee Submission') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const OnlinePaymentScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .studentMenu[index].text ==
                                      'Events') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const CalenderPage(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .studentMenu[index].text ==
                                      'Notifications') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const NotificationScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .studentMenu[index].text ==
                                      'View Homework') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const StudentHomeWorkScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .studentMenu[index].text ==
                                      'Due Fee') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ParentDueFeeScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .studentMenu[index].text ==
                                      'Exam Result') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const ExamResultScreen(),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  } else if (menuProvider
                                          .studentMenu[index].text ==
                                      'Fees') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const FeeDetailScreen(),
                                      ),
                                    );
                                  }
                                } else {
                                  if (menuProvider.adminMenu[index].text ==
                                      'Send Notification') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const SendMessageScreen(),
                                      ),
                                    );
                                  } else if (menuProvider
                                          .adminMenu[index].text ==
                                      'Student By Reg No') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const GetStudentByFilterAdmin(),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  } else if (menuProvider
                                          .adminMenu[index].text ==
                                      'Sms Report') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) =>
                                            const AdminSmsReportScreen(),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  } else if (menuProvider
                                          .adminMenu[index].text ==
                                      'Student By Class') {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (_) => const StudentByClass(),
                                      ),
                                    ).then((value) {
                                      setState(() {});
                                    });
                                  }
                                }
                              });
                            },
                            child: userType == "Teacher"
                                ? Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        height: size.height * 0.12,
                                        child: Card(
                                          color: Appcolor.themeColor,

                                          elevation: 4,
                                          // Optional: You can add an elevation to the Card
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.circular(
                                                10), // Optional: Rounded corners for the Card
                                          ),
                                          child: Padding(
                                            padding: const EdgeInsets.all(15.0),
                                            child: Image.asset(menuProvider
                                                .itemsTeacher[index].imageUrl),
                                          ),
                                        ),
                                      ),
                                      const SizedBox(height: 5),
                                      Text(
                                        menuProvider.itemsTeacher[index].text,
                                        style: const TextStyle(
                                            fontSize: 12,
                                            fontWeight: FontWeight.bold),
                                      ),
                                    ],
                                  )
                                : userType == "Parent"
                                    ? Column(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.center,
                                        children: [
                                          SizedBox(
                                            height: size.height * 0.12,
                                            child: Card(
                                              color: Appcolor.themeColor,

                                              elevation: 4,
                                              // Optional: You can add an elevation to the Card
                                              shape: RoundedRectangleBorder(
                                                borderRadius: BorderRadius.circular(
                                                    10), // Optional: Rounded corners for the Card
                                              ),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Image.asset(menuProvider
                                                    .studentMenu[index]
                                                    .imageUrl),
                                              ),
                                            ),
                                          ),
                                          const SizedBox(height: 2),
                                          Flexible(
                                            child: Text(
                                              menuProvider
                                                  .studentMenu[index].text,
                                              style: const TextStyle(
                                                  fontSize: 12,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                          ),
                                        ],
                                      )
                                    : userType == "Admin" ||
                                            userType == "Principal" &&
                                                (userType != 'Parent' &&
                                                    userType != 'Teacher')
                                        ? Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              SizedBox(
                                                height: size.height * 0.12,
                                                child: Card(
                                                  color: Appcolor.themeColor,

                                                  elevation: 4,
                                                  // Optional: You can add an elevation to the Card
                                                  shape: RoundedRectangleBorder(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            10), // Optional: Rounded corners for the Card
                                                  ),
                                                  child: Padding(
                                                    padding:
                                                        const EdgeInsets.all(
                                                            15.0),
                                                    child: Image.asset(
                                                        menuProvider
                                                            .adminMenu[index]
                                                            .imageUrl),
                                                  ),
                                                ),
                                              ),
                                              const SizedBox(height: 5),
                                              Text(
                                                menuProvider
                                                    .adminMenu[index].text,
                                                style: const TextStyle(
                                                    fontSize: 12,
                                                    fontWeight:
                                                        FontWeight.bold),
                                              ),
                                            ],
                                          )
                                        : Container(),
                          );
                        },
                        childCount: userType == 'Teacher'
                            ? menuProvider.itemsTeacher.length
                            : userType == 'Parent'
                                ? menuProvider.studentMenu.length
                                : isAdmin || userType == 'Principal'
                                    ? menuProvider.adminMenu.length
                                    : null,
                      ),
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
