import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:table_calendar/table_calendar.dart';

import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../view_model/student_attendance_view_model.dart';

class StudentAttendScreen extends StatefulWidget {
  const StudentAttendScreen({super.key});

  @override
  State<StudentAttendScreen> createState() => _StudentAttendScreenState();
}

class _StudentAttendScreenState extends State<StudentAttendScreen> {
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  bool tap = false;
  bool isLoading = true;
  // ignore: prefer_typing_uninitialized_variables
  // ignore: prefer_typing_uninitialized_variables
  var attendance;
  String? userType;
//piechart stuffs
  int totalPresentForMonth = 0;
  int totalAbsentForMonth = 0;
  double percentagePresentForMonth = 0.0;
  double percentageAbsentForMonth = 0.0;
  bool isPiechartLoader = false;
  String formattedFirstDay = '';
  String formattedLastDay = '';
  String? attendanceStudentPhoto;
  String? attendanceStudentName;
  String? attendanceStudentClass;
  String? attendanceStudentRoll;
  String? attendanceRegNo;
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? selectedRoll;
  DateTime _focusedDay = DateTime.now();
  DateTime _getFirstDayOfCurrentMonth(DateTime focusedDay) {
    return DateTime(focusedDay.year, focusedDay.month, 1);
  }

  DateTime _getLastDateOfCurrentMonth(DateTime focusedDay) {
    final nextMonth = focusedDay.month + 1;
    final year = focusedDay.year;

    if (nextMonth > 12) {
      return DateTime(year + 1, 1, 0).subtract(const Duration(days: 1));
    } else {
      return DateTime(year, nextMonth, 0).subtract(const Duration(days: 1));
    }
  }

  @override
  void initState() {
    super.initState();

    preference();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );
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
    final studentAttendanceProvider =
        // ignore: use_build_context_synchronously
        Provider.of<AttendanceProvider>(context, listen: false);

    final DateTime firstDayOfCurrentMonth =
        _getFirstDayOfCurrentMonth(_focusedDay);
    final DateTime lastDayOfPreviousMonth =
        _getLastDateOfCurrentMonth(_focusedDay);

    formattedFirstDay = formatForAPI(firstDayOfCurrentMonth);

    formattedLastDay = formatForAPI(lastDayOfPreviousMonth);

    studentAttendanceProvider.fetchAttendance(schoolId!, sessionId!,
        attendanceRegNo.toString(), formattedFirstDay, formattedLastDay);
  }

  String formatDate(DateTime date) {
    final year = date.year.toString().padLeft(4, '0');
    final month = date.month.toString().padLeft(2, '0');
    final day = date.day.toString().padLeft(2, '0');
    final hour = date.hour.toString().padLeft(2, '0');
    final minute = date.minute.toString().padLeft(2, '0');
    final second = date.second.toString().padLeft(2, '0');
    return '$year$month$day$hour$minute$second';
  }

  String apiFromDate = '';
  String apiToDate = '';
  String pref = '';

  String formatForDisplay(DateTime date) {
    return '${date.day.toString().padLeft(2, '0')}/${date.month.toString().padLeft(2, '0')}/${date.year}';
  }

  String formatForAPI(DateTime date) {
    return '${date.year.toString().padLeft(4, '0')}${date.month.toString().padLeft(2, '0')}${date.day.toString().padLeft(2, '0')}000000';
  }

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

                        final currentDate = DateTime.now();
                        // ignore: use_build_context_synchronously
                        final calendarProvider =
                            // ignore: use_build_context_synchronously
                            Provider.of<AttendanceProvider>(context,
                                listen: false);
                        final newMonth = calendarProvider.currentMonth;
                        calendarProvider.rebuildCalendar(newMonth);

                        // Calculate the first day of the current month
                        final firstDayOfCurrentMonth =
                            DateTime(currentDate.year, currentDate.month, 1);

                        // Calculate the last day of the current month
                        final nextMonth = currentDate.month + 1;
                        final nextYear =
                            currentDate.year + (nextMonth > 12 ? 1 : 0);
                        final lastDayOfCurrentMonth =
                            DateTime(nextYear, nextMonth, 0);

                        final formattedFirstDate =
                            formatForAPI(firstDayOfCurrentMonth);
                        final formattedLastDate =
                            formatForAPI(lastDayOfCurrentMonth);

                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);

                          Provider.of<AttendanceProvider>(context,
                                  listen: false)
                              .fetchAttendance(
                                  schoolId!,
                                  sessionId!,
                                  student.regNo.toString(),
                                  formattedFirstDate,
                                  formattedLastDate)
                              .then((_) {
                            _focusedDay = firstDayOfCurrentMonth;
                            setState(() {});
                          });
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

  double totalPPercentage = 0;
  double totalAPercentage = 0;
  double totalLPercentage = 0;

  // DateTime _focusedDay = DateTime.now();
  Map<String, double> pieChartData = {};

  @override
  Widget build(BuildContext context) {
    final attendanceProvider = Provider.of<AttendanceProvider>(context);
    final menuProvider = Provider.of<MenuViewModel>(context);
    final Size size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final student = studentProvider.profile;
    final selectedStudentIndex = studentProvider.selectedIndex;
    final students = student?.stm ?? [];
    final selectedStudentRegNo = students.isNotEmpty
        ? students[selectedStudentIndex].regNo ?? 'N/A'
        : 'N/A';
    if (attendanceProvider.dataMap['totalP'] != null &&
        attendanceProvider.dataMap['totalA'] != null &&
        attendanceProvider.dataMap['totalL'] != null) {
      totalPPercentage = (attendanceProvider.dataMap['totalP']! /
              attendanceProvider.attendanceList.length) *
          100;
      totalAPercentage = (attendanceProvider.dataMap['totalA']! /
              attendanceProvider.attendanceList.length) *
          100;
      totalLPercentage = (attendanceProvider.dataMap['totalL']! /
              attendanceProvider.attendanceList.length) *
          100;
    }

    // Update pie chart data
    pieChartData = {
      'Total P': totalPPercentage,
      'Total A': totalAPercentage,
      'Total L': totalLPercentage,
    };

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
                                return Image.asset(
                                    'assets/images/user_profile.png'); // Replace with your error placeholder image
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
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontSize: size.width * 0.03),
                      ),
                      Text(
                        selectedRoll == null
                            ? 'Roll:N/A'
                            : 'Roll:$selectedRoll',
                        style: TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                            overflow: TextOverflow.ellipsis,
                            fontSize: size.width * 0.03),
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
            Padding(
              padding: const EdgeInsets.only(top: 20.0),
              child: Column(
                children: [
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 25.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                      children: [
                        Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.12,
                              width: size.width * 0.25,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Appcolor.themeColor,
                                elevation: 5,
                                child: Center(
                                    child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    const Text('Total',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                    const Text('Present',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600)),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Text(
                                      attendanceProvider.dataMap['totalP'] !=
                                              null
                                          ? '${attendanceProvider.dataMap['totalP']}'
                                          : '0',
                                      style: const TextStyle(
                                          color: Colors.green,
                                          fontWeight: FontWeight.bold,
                                          fontSize: 18),
                                    ),
                                  ],
                                )),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.12,
                              width: size.width * 0.25,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Appcolor.themeColor,
                                elevation: 5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Text('Absent',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        attendanceProvider.dataMap['totalA'] !=
                                                null
                                            ? '${attendanceProvider.dataMap['totalA']}'
                                            : '0',
                                        style: const TextStyle(
                                            color: Colors.red,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        Column(
                          children: [
                            SizedBox(
                              height: size.height * 0.12,
                              width: size.width * 0.25,
                              child: Card(
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(10)),
                                color: Appcolor.themeColor,
                                elevation: 5,
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      const Text(
                                        'Total',
                                        style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600),
                                      ),
                                      const Text('Leave',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600)),
                                      const SizedBox(
                                        height: 5,
                                      ),
                                      Text(
                                        attendanceProvider.dataMap['totalL'] !=
                                                null
                                            ? '${attendanceProvider.dataMap['totalL']}'
                                            : '0',
                                        style: const TextStyle(
                                            color: Colors.blue,
                                            fontWeight: FontWeight.bold,
                                            fontSize: 18),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  attendanceProvider.isLoading
                      ? Padding(
                          padding: const EdgeInsets.only(top: 20.0),
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
                      : attendanceProvider.dataMap['totalP'] == 0 &&
                              attendanceProvider.dataMap['totalA'] == 0 &&
                              attendanceProvider.dataMap['totalL'] == 0
                          ? const Padding(
                              padding: EdgeInsets.only(top: 30.0),
                              child: SizedBox(
                                height: 130,
                                child: Center(
                                  child: Text(
                                    'No Attendance Data available',
                                    style: TextStyle(
                                        fontSize: 16, color: Colors.grey),
                                  ),
                                ),
                              ),
                            )
                          : PieChart(
                              chartRadius: 150,
                              dataMap: pieChartData,
                              chartType: ChartType.disc,
                              colorList: const [
                                Colors.green,
                                Colors.red,
                                Colors.blue
                              ],
                            ),
                ],
              ),
            ),
            Consumer<AttendanceProvider>(
              builder: (context, provider, _) {
                return TableCalendar(
                  availableCalendarFormats: const {
                    CalendarFormat.month: 'Month',
                  },
                  onFormatChanged: (format) {},
                  onPageChanged: (DateTime focusedDay) {
                    // _onDaySelected(focusedDay);
                    final DateTime firstDayOfCurrentMonth =
                        _getFirstDayOfCurrentMonth(focusedDay);
                    final DateTime lastDateOfCurrentMonth =
                        _getLastDateOfCurrentMonth(focusedDay);
                    formattedFirstDay = formatForAPI(firstDayOfCurrentMonth);

                    formattedLastDay = formatForAPI(lastDateOfCurrentMonth);
                    tap
                        ? attendanceProvider.fetchAttendance(
                            schoolId!,
                            sessionId!,
                            selectedStudentRegNo,
                            formattedFirstDay,
                            formattedLastDay)
                        : attendanceProvider.fetchAttendance(
                            schoolId!,
                            sessionId!,
                            attendanceRegNo.toString(),
                            formattedFirstDay,
                            formattedLastDay);
                    setState(() {
                      isPiechartLoader = true;
                      _focusedDay = focusedDay;
                    });
                    attendanceProvider.onPageChanged(focusedDay);
                    setState(() {
                      isPiechartLoader = false;
                    });
                  },
                  calendarStyle: const CalendarStyle(
                    markersAlignment: Alignment.bottomRight,
                  ),
                  headerStyle: const HeaderStyle(
                    formatButtonVisible: false,
                  ),
                  daysOfWeekStyle: const DaysOfWeekStyle(
                    weekendStyle: TextStyle(color: Colors.red),
                  ),
                  calendarBuilders: CalendarBuilders(
                    selectedBuilder: (context, date, _) => buildDayContainer(
                      date: date,
                      color: Colors.blue,
                      textColor: Colors.white,
                      provider: provider,
                    ),
                    todayBuilder: (context, date, _) => buildDayContainer(
                      date: date,
                      color: Colors.blueGrey,
                      textColor: Colors.black,
                      provider: provider,
                    ),
                    markerBuilder: (context, date, events) {
                      final formattedDate =
                          '${date.month}/${date.day}/${date.year}';

                      final attendanceData =
                          provider.getAttendanceData(formattedDate);

                      if (attendanceData != null &&
                          attendanceData['attendance'] != null) {
                        final color = provider
                            .getAttendanceColor(attendanceData['attendance']);
                        return buildDayContainer(
                            date: date,
                            color: color,
                            textColor: Colors.black,
                            provider: provider);
                      }
                      return null;
                    },
                  ),
                  firstDay: DateTime(2010),
                  focusedDay: _focusedDay,
                  lastDay: DateTime(2030),
                );
              },
            ),
            const SizedBox(
              height: 10,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildDayContainer(
      {required DateTime date,
      required Color color,
      required Color textColor,
      required AttendanceProvider provider}) {
    final formattedDate = '${date.month}/${date.day}/${date.year}';
    final attendanceData = provider.getAttendanceData(formattedDate);
    if (attendanceData != null) {
      return Container(
        margin: const EdgeInsets.all(5),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: color.withOpacity(0.3),
          shape: BoxShape.circle,
        ),
        child: Text(
          '${date.day}',
          style: TextStyle(
              color: textColor,
              // fontWeight: FontWeight.bold,
              fontSize: 12),
        ),
      );
    } else {
      return Container(
        margin: const EdgeInsets.all(4),
        alignment: Alignment.center,
        child: Text(
          '${date.day}',
          style: TextStyle(
            color: textColor,
          ),
        ),
      );
    }
  }

  Widget buildLoadingIndicator() {
    return const Center(
      child: CircularProgressIndicator(
        color: Appcolor.themeColor,
      ),
    );
  }
}
