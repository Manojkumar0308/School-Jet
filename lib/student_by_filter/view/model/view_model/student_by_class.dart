import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:school_jet/student_by_filter/view/model/view_model/student_detail.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../../../menu/view_model/menu_view_model.dart';
import '../../../../send_message/view_model/send_message_view_model.dart';
import '../../../../utils/appcolors.dart';
import '../view_model/student_by_class_view_model.dart';

class StudentByClass extends StatefulWidget {
  const StudentByClass({super.key});

  @override
  State<StudentByClass> createState() => _StudentByClassState();
}

class _StudentByClassState extends State<StudentByClass> {
  String? singleSelectedClassName;
  String? singleSelectedSectionName;
  String mobno = '';
  bool isTap = false;
  @override
  void initState() {
    super.initState();
    final studentByClass =
        Provider.of<StudentByClassViewModel>(context, listen: false);
    studentByClass.students = [];
    preference();
    final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
    menuProvider.fetchTeacherInfo(mobno);
    if (menuProvider.teacherInfo?.photo != null) {
      menuProvider
          .checkFileExistence(menuProvider.teacherInfo!.photo.toString());
    }
    Provider.of<SendMessageViewModel>(context, listen: false).fetchClasses();
  }

  String userType = '';
  Future<void> preference() async {
    final pref = await SharedPreferences.getInstance();

    // schoolId = pref.getInt('schoolid');
    userType = pref.getString('userType').toString();
    print(userType);
    mobno = pref.getString('mobno').toString();
  }

  @override
  Widget build(BuildContext context) {
    final provider = Provider.of<SendMessageViewModel>(context);
    final menuProvider = Provider.of<MenuViewModel>(context);
    final studentByClass = Provider.of<StudentByClassViewModel>(context);
    final size = MediaQuery.of(context).size;
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherContact = teacherInfo?.contactno ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();
    return Scaffold(
      appBar: AppBar(
        // automaticallyImplyLeading: false,
        backgroundColor: Appcolor.themeColor,
        toolbarHeight: 70,
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            userType == "Teacher" ||
                    userType == "Admin" ||
                    userType == "Principal"
                ? menuProvider.fileExists
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
                                        errorBuilder:
                                            (context, error, stackTrace) {
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
                        ))
                : const SizedBox.shrink(),
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
              width: 5,
            )
          ],
        ),
        actions: [
          Padding(
            padding: const EdgeInsets.only(right: 15.0),
            child: menuProvider.bytesImage != null &&
                    menuProvider.bytesImage.toString().isNotEmpty
                ? Image.memory(
                    menuProvider.bytesImage!,
                    height: size.height * 0.08,
                    width: size.width * 0.08,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
      body: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: SizedBox(
              height: size.height * 0.10,
              child: DropdownButtonFormField<String>(
                decoration: InputDecoration(
                  labelText: 'Select Class',
                  labelStyle:
                      const TextStyle(color: Appcolor.themeColor, fontSize: 12),
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
                items: provider.classes
                    .map((className) => DropdownMenuItem<String>(
                          value: className,
                          child: Text(className,
                              style: const TextStyle(
                                  color: Colors.black, fontSize: 12)),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    if (value != null) {
                      singleSelectedClassName = value;

                      if (singleSelectedClassName != null &&
                          singleSelectedSectionName != null) {
                        studentByClass.getStudentsByFilter(
                            singleSelectedClassName.toString(),
                            singleSelectedSectionName.toString());

                        isTap = true;
                      }

                      print(singleSelectedClassName);
                    } else {
                      singleSelectedClassName = null;
                    }
                  });
                },
              ),
            ),
          ),
          const SizedBox(height: 20),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: DropdownButtonFormField<String>(
              decoration: InputDecoration(
                labelText: 'Select Section',
                labelStyle:
                    const TextStyle(color: Appcolor.themeColor, fontSize: 12),
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
              items: provider.sections
                  .map((sectionName) => DropdownMenuItem<String>(
                        value: sectionName,
                        child: Text(sectionName,
                            style: const TextStyle(
                                color: Colors.black, fontSize: 12)),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  singleSelectedSectionName = value;
                  print(singleSelectedSectionName);
                  if (singleSelectedClassName != null &&
                      singleSelectedSectionName != null) {
                    studentByClass.getStudentsByFilter(
                        singleSelectedClassName.toString(),
                        singleSelectedSectionName.toString());
                    setState(() {
                      isTap = true;
                    });
                  } else {
                    print('selected value is null');
                  }
                });
              },
            ),
          ),
          const SizedBox(
            height: 20,
          ),
          studentByClass.isLoading
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
              : studentByClass.students == null
                  ? Expanded(
                      child: Center(
                          child:
                              Text(isTap ? 'No students are available' : '')))
                  : Expanded(
                      child: ListView.builder(
                        shrinkWrap: true,
                        itemCount: studentByClass.students?.length,
                        itemBuilder: (context, index) {
                          final student = studentByClass.students![index];

                          return InkWell(
                            onTap: () {
                              // Redirect to the student details screen when tapped
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => StudentDetailsScreen(
                                    studentDetails: student,
                                  ),
                                ),
                              );
                            },
                            child: Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15.0),
                              child: Column(
                                mainAxisSize: MainAxisSize.min,
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Card(
                                    child: Container(
                                      height: size.height * 0.16,
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
                                              gradient: Appcolor.blueGradient,
                                              borderRadius: BorderRadius.only(
                                                topLeft: Radius.circular(10),
                                                bottomLeft: Radius.circular(10),
                                              ),
                                            ),
                                          ),
                                          Container(
                                            height: size.height * 0.16,
                                            decoration: const BoxDecoration(
                                              borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(10),
                                                bottomRight:
                                                    Radius.circular(10),
                                              ),
                                            ),
                                            child: Row(
                                              children: [
                                                const SizedBox(
                                                  width: 10,
                                                ),
                                                student['photo'] != null
                                                    ? Container(
                                                        height: 50,
                                                        width: 50,
                                                        decoration:
                                                            const BoxDecoration(
                                                                shape: BoxShape
                                                                    .circle,
                                                                color: Appcolor
                                                                    .lightgrey),
                                                        child: ClipOval(
                                                          child: Image.network(
                                                            student['photo'],
                                                            fit: BoxFit.cover,
                                                          ),
                                                        ),
                                                      )
                                                    : const CircleAvatar(
                                                        radius: 25,
                                                        backgroundColor:
                                                            Appcolor.lightgrey,
                                                        backgroundImage: AssetImage(
                                                            'assets/images/user_profile.png'),
                                                      ),
                                                Padding(
                                                  padding: const EdgeInsets.all(
                                                      10.0),
                                                  child: Column(
                                                    mainAxisSize:
                                                        MainAxisSize.min,
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.start,
                                                    crossAxisAlignment:
                                                        CrossAxisAlignment
                                                            .start,
                                                    children: [
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Name: ',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          Text(
                                                            student['StuName'] ??
                                                                '',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Gender: ',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          Text(
                                                            student['gender'] ??
                                                                'N/A',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          const Text(
                                                            'Adm.no: ',
                                                            style: TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600),
                                                          ),
                                                          Text(
                                                            student['RegNo'] ??
                                                                '',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        children: [
                                                          // const Text(
                                                          //   'Class: ',
                                                          //   style: TextStyle(
                                                          //       fontSize: 12,
                                                          //       color: Colors.black,
                                                          //       fontWeight:
                                                          //           FontWeight
                                                          //               .w600),
                                                          // ),
                                                          Text(
                                                            'Class:${student['ClassName'] ?? 'N/A'} | ',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                          Text(
                                                            '${student['SectionName'] ?? 'N/A'}',
                                                            style: const TextStyle(
                                                                fontSize: 12,
                                                                color: Colors
                                                                    .black,
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w500),
                                                          ),
                                                        ],
                                                      ),
                                                      const SizedBox(
                                                        height: 5,
                                                      ),
                                                      Row(
                                                        mainAxisSize:
                                                            MainAxisSize.min,
                                                        children: [
                                                          // const Text(
                                                          //   'Section: ',
                                                          //   style: TextStyle(
                                                          //       fontSize: 12,
                                                          //       color: Colors.black,
                                                          //       fontWeight:
                                                          //           FontWeight
                                                          //               .w600),
                                                          // ),
                                                        ],
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                                    ),
                                  ),
                                  const SizedBox(height: 10),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
                    ),
        ],
      ),
    );
  }
}
