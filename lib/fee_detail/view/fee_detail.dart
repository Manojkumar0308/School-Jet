import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/view_model.dart';

// import 'package:flutter_inappwebview/flutter_inappwebview.dart';

class FeeDetailScreen extends StatefulWidget {
  const FeeDetailScreen({super.key});

  @override
  State<FeeDetailScreen> createState() => _FeeDetailScreenState();
}

class _FeeDetailScreenState extends State<FeeDetailScreen> {
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  bool tap = false;
  bool isLoading = true;
  String? userType;
  String? attendanceStudentPhoto;
  String? attendanceStudentName;
  String? attendanceStudentClass;
  String? attendanceStudentRoll;
  String? attendanceRegNo;
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? selectedRoll;
  @override
  void initState() {
    super.initState();
    preference();
  }

  void preference() async {
    final pref = await SharedPreferences.getInstance();
    schoolId = pref.getInt('schoolid');
    userType = pref.getString('userType');

    sessionId = pref.getInt('sessionid');

    mobno = pref.getString('mobno');

    selectedName = pref.getString('attendanceStudentName');
    selectedPhoto = pref.getString('attendanceStudentPhoto');
    selectedClass = pref.getString('attendanceStudentClass');
    selectedRoll = pref.getString('attendanceStudentRoll');

    attendanceRegNo = pref.getString('attendanceRegNo');

    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);
    final feedetailproviderforapi =
        // ignore: use_build_context_synchronously
        Provider.of<ParentFeeDetailViewModel>(context, listen: false);
    feedetailproviderforapi.requiredData();

    await feedetailproviderforapi
        .fetchStudentFeeDetail(attendanceRegNo.toString());
  }

  void fetchingData() async {}
  void _showStudentList(BuildContext context, List<Stm> students) {
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
                      splashColor: Appcolor.themeColor,
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
                        selectedRoll = pref.getString('attendanceStudentRoll');
                        attendanceRegNo = pref.getString('attendanceRegNo');
                        final studentProvider =
                            // ignore: use_build_context_synchronously
                            Provider.of<StudentProvider>(context,
                                listen: false);
                        // ignore: use_build_context_synchronously
                        studentProvider.fetchStudentData(mobno.toString(),
                            schoolId.toString(), sessionId.toString(), context);
                        final feedetailproviderforapi =
                            // ignore: use_build_context_synchronously
                            Provider.of<ParentFeeDetailViewModel>(context,
                                listen: false);
                        feedetailproviderforapi.requiredData();

                        await feedetailproviderforapi
                            .fetchStudentFeeDetail(attendanceRegNo.toString());

                        // Notify the builder to rebuild the DataTable
                        setState(() {});

                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
                        setState(() {
                          tap = true;
                          isLoading = true;
                        });

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
  Widget build(BuildContext context) {
    final feedetailprovider = Provider.of<ParentFeeDetailViewModel>(context);
    final size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final students = student?.stm ?? [];
    final menuProvider = Provider.of<MenuViewModel>(context);
    return Scaffold(
        appBar: AppBar(
          automaticallyImplyLeading: false,
          toolbarHeight: 70,
          titleSpacing: 2,
          backgroundColor: Appcolor.themeColor,
          title: InkWell(
            onTap: () {
              _showStudentList(context, students);
            },
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(builder: (_) => const MenuScreen()),
                        );
                      },
                      icon: const Icon(Icons.arrow_back)),
                  GestureDetector(
                    onTap: () {
                      _showStudentList(context, students);

                      setState(() {
                        tap = false;
                      });
                    },
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Appcolor.lightgrey),
                      child: selectedPhoto == null
                          ? ClipOval(
                              child: Image.asset(
                                'assets/images/user_profile.png',
                                fit: BoxFit.cover,
                              ),
                            ) // Replace with your asset image path
                          : ClipOval(
                              child: Image.network(
                                selectedPhoto!,
                                fit: BoxFit.cover,
                                errorBuilder: (context, error, stackTrace) {
                                  // Handle network image loading error here
                                  return ClipOval(
                                    child: Image.asset(
                                        'assets/images/user_profile.png'),
                                  ); // Replace with your error placeholder image
                                },
                              ),
                            ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.only(left: 10.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        Padding(
                          padding: const EdgeInsets.only(top: 3.0),
                          child: Text(
                            selectedName != null
                                ? 'Name:$selectedName'
                                : 'Name:N/A',
                            style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.w600,
                                overflow: TextOverflow.ellipsis,
                                fontSize: size.width * 0.03),
                          ),
                        ),
                        Text(
                          selectedClass != null
                              ? 'Class:$selectedClass'
                              : 'Class:N/A',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                        Text(
                          selectedRoll == null
                              ? 'Roll:N/A'
                              : 'Roll:$selectedRoll',
                          style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                              fontSize: 12),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5,
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
            children: [
              feedetailprovider.isLoading
                  ? Container()
                  : const SizedBox(
                      height: 20,
                    ),
              feedetailprovider.isLoading
                  ? SizedBox(
                      height: size.height,
                      child: Center(
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
                      ),
                    )
                  : feedetailprovider.studentFeeDetailList.isEmpty
                      ? const Center(
                          child: Text(
                            'No fee detail record found',
                            style: TextStyle(color: Colors.grey),
                          ),
                        )
                      : SizedBox(
                          child: Padding(
                            padding: const EdgeInsets.all(8.0),
                            child: SingleChildScrollView(
                              scrollDirection: Axis.horizontal,
                              child: DataTable(
                                  columnSpacing: size.width * 0.10,
                                  headingRowColor:
                                      MaterialStateColor.resolveWith(
                                    (states) {
                                      return Colors.greenAccent;
                                    },
                                  ),
                                  border:
                                      TableBorder.all(color: Colors.blueGrey),
                                  columns: const [
                                    DataColumn(
                                        label: Expanded(
                                      child: Text('Date',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12)),
                                    )),
                                    DataColumn(
                                        label: Expanded(
                                      child: Text('Intervals',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12)),
                                    )),
                                    DataColumn(
                                        label: Expanded(
                                      child: Text('Pay Mode',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12)),
                                    )),
                                    DataColumn(
                                        label: Expanded(
                                      child: Text('Amount',
                                          textAlign: TextAlign.center,
                                          style: TextStyle(fontSize: 12)),
                                    )),
                                  ],
                                  rows: feedetailprovider.studentFeeDetailList
                                      .map((feedetail) {
                                    return DataRow(
                                      cells: [
                                        DataCell(Center(
                                          child: Text(
                                              CommonMethods()
                                                  .teachersHomeworkreportDate(
                                                      feedetail.transactionDate
                                                          .toString()),
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                              feedetail.intervals.toString(),
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                              feedetail.payMode.toString(),
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        )),
                                        DataCell(Center(
                                          child: Text(
                                              '\u{20B9}${feedetail.amount}',
                                              style: const TextStyle(
                                                  fontSize: 12)),
                                        )),
                                      ],
                                    );
                                  }).toList()),
                            ),
                          ),
                        ),
              const SizedBox(
                height: 20,
              ),
            ],
          ),
        ));
  }
}
