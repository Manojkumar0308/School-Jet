import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../add_homework/view_model/add_homeWork_view_model.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../send_message/view_model/send_message_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/view_model.dart';
import 'package:intl/intl.dart';

class AddAttendanceScreen extends StatefulWidget {
  const AddAttendanceScreen({super.key});

  @override
  State<AddAttendanceScreen> createState() => _AddAttendanceScreenState();
}

class _AddAttendanceScreenState extends State<AddAttendanceScreen> {
  Map<String, dynamic>? singleSelectedClassName;
  Map<String, dynamic>? singleSelectedSectionName;
  bool buttonTap = false;
  bool editTap = false;
  bool showSnackbarOnce = false;

  List<String> selectedAttendanceValues = [];
  //selectedAttendanceValues use to store attendance value for a particular index student.

  @override
  void initState() {
    super.initState();
    CommonMethods().initCall(context);
    //api calling using provider package at initial level of screen.
    Provider.of<SendMessageViewModel>(context, listen: false).fetchClasses();
    Provider.of<SendMessageViewModel>(context, listen: false).fetchSections();
    Provider.of<HomeworkProvider>(context, listen: false).savedData();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    //It retrieves the instance of SendMessageViewModel and assigns it to the provider variable.
    final provider = Provider.of<SendMessageViewModel>(context);
    // It retrieves the instance of AttendanceViewModel and assigns it to the getStudent variable.
    final getStudent = Provider.of<AttendanceViewModel>(context);
    DateTime now = DateTime.now();
    //above code retreieves current DateTime.
    final showingDate = DateFormat.yMMMEd().format(DateTime.now());
    //above line is for date format 03,May,2023
    final currentDate = DateFormat("yyyyMMdd").format(now);
    //above line is for date format 20230919 year month and date with no space.
    final formattedDate = currentDate + '000000'.toString();
    //adding 6 zeros at the end as a string in currentDate using for api calling.
    final menuProvider = Provider.of<MenuViewModel>(context);
    //It retrieves the instance of MenuViewModel and assigns it to the menuProvider variable.

    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherContact = teacherInfo?.contactno ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();

    DateTime absentCurrentDate = DateTime.now();
    String sentencedDate = DateFormat('dd MMMM yyyy').format(absentCurrentDate);
    print('sentencedDate is $sentencedDate');
    String editableDate = absentCurrentDate.toString().split('.').first;
    final absentFormattedDate = editableDate.replaceAll(RegExp(r'[- :.]'), '');
    return Scaffold(
      appBar: AppBar(
        automaticallyImplyLeading: false,
        backgroundColor: Appcolor.themeColor,
        toolbarHeight: 70,
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            IconButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                icon: const Icon(Icons.arrow_back)),
            menuProvider.fileExists
                ? Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
                    child: teacherPhoto == null
                        ? ClipOval(
                            child: Image.asset(
                              'assets/images/user_profile.png',
                              fit: BoxFit.cover,
                            ),
                          ) // Replace with your asset image path
                        : ClipOval(
                            child: menuProvider.isLoading
                                ? const Center(
                                    child: CupertinoActivityIndicator(
                                        color: Appcolor.themeColor),
                                  )
                                : Image.network(
                                    teacherPhoto,
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Handle network image loading error here
                                      return Image.asset(
                                          'assets/images/user_profile.png'); // Replace with your error placeholder image
                                    },
                                  ),
                          ),
                  )
                : Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/user_profile.png',
                        fit: BoxFit.cover,
                      ),
                    )),
            Padding(
              padding: const EdgeInsets.only(left: 10.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Padding(
                    padding: const EdgeInsets.only(top: 3.0),
                    child: Text(
                      'Name:$teacherName',
                      style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                          overflow: TextOverflow.ellipsis,
                          fontSize: size.width * 0.03),
                    ),
                  ),
                  Text(
                    'Email: $teacherEmail',
                    style: TextStyle(
                        color: Colors.white,
                        fontWeight: FontWeight.w600,
                        overflow: TextOverflow.ellipsis,
                        fontSize: size.width * 0.03),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(top: 2.0),
                    child: Text(
                      'Contact: $teacherContact',
                      style: TextStyle(
                          color: Colors.white,
                          overflow: TextOverflow.ellipsis,
                          fontSize: size.width * 0.03,
                          fontWeight: FontWeight.w600),
                    ),
                  )
                ],
              ),
            ),
            const SizedBox(
              width: 5.0,
            )
          ],
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
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 15.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.only(top: 20.0),
                child: DropdownButtonFormField<Map<String, dynamic>>(
                  decoration: InputDecoration(
                    labelText: 'Select Class',
                    labelStyle: const TextStyle(color: Colors.black),
                    enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Appcolor.themeColor),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                    focusedBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Appcolor.themeColor),
                      borderRadius: BorderRadius.circular(5.0),
                    ),
                  ),
                  value: singleSelectedClassName,
                  items: provider.classesData
                      .map<DropdownMenuItem<Map<String, dynamic>>>(
                    (classData) {
                      return DropdownMenuItem<Map<String, dynamic>>(
                        value: classData,
                        child: Text(
                          classData['className'],
                          style: const TextStyle(fontSize: 14),
                        ),
                      );
                    },
                  ).toList(),
                  onChanged: (value) {
                    setState(() {
                      if (value != null) {
                        singleSelectedClassName = value;
                      } else {
                        if (kDebugMode) {
                          print(value);
                        }
                      }
                    });
                  },
                ),
              ),
              const SizedBox(
                height: 10,
              ),
              DropdownButtonFormField<Map<String, dynamic>>(
                decoration: InputDecoration(
                  labelText: 'Select Section',
                  labelStyle: const TextStyle(color: Colors.black),
                  enabledBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Appcolor.themeColor),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Appcolor.themeColor),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                ),
                value: singleSelectedSectionName,
                items: provider.sectionData
                    .map<DropdownMenuItem<Map<String, dynamic>>>(
                  (sectionData) {
                    return DropdownMenuItem<Map<String, dynamic>>(
                      value: sectionData,
                      child: Text(
                        sectionData['sectionName'],
                        style: const TextStyle(fontSize: 14),
                      ),
                    );
                  },
                ).toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      singleSelectedSectionName = value;
                    }
                  });
                },
              ),
              const SizedBox(
                height: 10,
              ),
              TextField(
                readOnly: true,
                decoration: InputDecoration(
                  hintText: showingDate.toString(),
                  hintStyle: const TextStyle(color: Colors.black),
                  border: InputBorder.none,
                  enabledBorder: OutlineInputBorder(
                      borderSide: const BorderSide(color: Appcolor.themeColor),
                      borderRadius: BorderRadius.circular(5)),
                  focusedBorder: OutlineInputBorder(
                    borderSide: const BorderSide(color: Appcolor.themeColor),
                    borderRadius: BorderRadius.circular(5.0),
                  ),
                  suffixIcon: const Icon(
                    Icons.calendar_month,
                    color: Appcolor.themeColor,
                  ),
                ),
              ),
              const SizedBox(
                height: 20,
              ),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    buttonTap = true;
                  });
                  if (singleSelectedClassName?['className'] != null &&
                      singleSelectedSectionName?['sectionName'] != null) {
                    getStudent.getStudentByFilter(
                        singleSelectedClassName!['className'].toString(),
                        singleSelectedSectionName!['sectionName'].toString(),
                        context);
                  } else {
                    if (singleSelectedClassName?['className'] != null) {
                      CommonMethods().showSnackBar(context, 'Enter Class');
                    } else if (singleSelectedSectionName?['sectionName'] !=
                        null) {
                      CommonMethods().showSnackBar(context, 'Enter Section');
                    } else if (singleSelectedClassName?['className'] == null &&
                        singleSelectedSectionName?['sectionName'] == null) {
                      CommonMethods()
                          .showSnackBar(context, 'Both fields are mandatory');
                    }
                  }
                },
                style: ElevatedButton.styleFrom(
                  foregroundColor: Colors.white,
                  backgroundColor:
                      Appcolor.themeColor, // Set the text color on the button.
                  elevation: 5, // Adjust the button's elevation.
                ),
                child: const Text('Get Students'),
              ),
              getStudent.isLoading && getStudent.students.isNotEmpty
                  ? Center(
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
                  : buttonTap && getStudent.students.isNotEmpty
                      //Table with row and column to show student list with attendance value P,A,L
                      ? DataTable(
                          border:
                              TableBorder.all(width: 1, color: Colors.black),
                          columns: const <DataColumn>[
                            DataColumn(label: Text('S.No')),
                            DataColumn(label: Text('Name')),
                            DataColumn(label: Text('Attendance')),
                          ],
                          rows: List<DataRow>.generate(
                            getStudent.students.length,
                            (int index) {
                              //by default attendance value for each index student.
                              selectedAttendanceValues.add('P');
                              return DataRow(
                                cells: <DataCell>[
                                  DataCell(Text(
                                    '${index + 1}',
                                    style:
                                        TextStyle(fontSize: size.width * 0.035),
                                  )), // S.No
                                  DataCell(Center(
                                    child: Text(
                                      getStudent.students[index].stuName!,
                                      style: TextStyle(
                                          fontSize: size.width * 0.035),
                                    ),
                                  )), // Student Name
                                  DataCell(
                                    Center(
                                      child: DropdownButton<String>(
                                        value: selectedAttendanceValues[
                                            index], // Default value
                                        onChanged: (String? newValue) {
                                          setState(() {
                                            selectedAttendanceValues[index] =
                                                newValue!;
                                          });
                                        },
                                        items: <String>[
                                          'P',
                                          'A',
                                          'L'
                                        ] // Dropdown options
                                            .map<DropdownMenuItem<String>>(
                                          (String value) {
                                            return DropdownMenuItem<String>(
                                              value: value,
                                              child: Padding(
                                                padding: const EdgeInsets.only(
                                                    right: 10.0),
                                                child: Text(
                                                  value,
                                                  style: TextStyle(
                                                      fontSize:
                                                          size.width * 0.035),
                                                ),
                                              ),
                                            );
                                          },
                                        ).toList(),
                                      ),
                                    ),
                                  ),
                                ],
                              );
                            },
                          ),
                        )
                      : const SizedBox.shrink()
            ],
          ),
        ),
      ),
      bottomNavigationBar: Row(
        children: [
          Expanded(
            child: InkWell(
              onTap: () async {
                final pref = await SharedPreferences.getInstance();
                final schoolid = pref.getInt('schoolid');
                final sessionid = pref.getInt('sessionid');
                final userId = pref.getInt('userid');

                final userToken = pref.getString('userToken').toString();
                await menuProvider.getTeacherPermission();
                if (menuProvider.permissionUrlResult == true) {
                  for (int i = 0; i < getStudent.students.length; i++) {
                    String regNo = getStudent.students[i].regNo.toString();
                    List<String> regNoList = regNo.split(",");
                    String name = getStudent.students[i].stuName.toString();
                    String className =
                        getStudent.students[i].className.toString();
                    String sectionName =
                        getStudent.students[i].sectionName.toString();
                    String attendanceValue =
                        selectedAttendanceValues[i]; // Get the attendance value

                    // ignore: use_build_context_synchronously
                    getStudent.addAttendance(
                        regNo, formattedDate, attendanceValue, context);
                    print(getStudent.resultAttendance == 'Success');
                    if (attendanceValue == 'A' &&
                        getStudent.resultAttendance == 'Success') {
                      if (schoolid != null &&
                          sessionid != null &&
                          userId != null) {
                        // ignore: use_build_context_synchronously
                        provider.registrationNoWiseApi(
                            'MSG',
                            "Your Ward $name, Regn No. :$regNo of class: $className $sectionName is Absent in school today on $sentencedDate.",
                            absentFormattedDate,
                            userId,
                            schoolid,
                            userToken,
                            regNoList,
                            sessionid,
                            context);
                      }
                    }
                  }

                  selectedAttendanceValues.clear();
                } else {
                  selectedAttendanceValues.clear();
                  Fluttertoast.showToast(msg: 'Unauthorized user');
                }

                // Reset other state variables to their initial values
                setState(() {
                  singleSelectedClassName = null;
                  singleSelectedSectionName = null;
                  buttonTap = false;
                  getStudent.students.clear(); // Clear student data
                });
              },
              child: Container(
                height: size.height * 0.06,
                color: Appcolor.themeColor,
                child: const Center(
                    child: Text(
                  'Submit',
                  style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold),
                )),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
