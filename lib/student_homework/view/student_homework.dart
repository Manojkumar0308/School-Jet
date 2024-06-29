import 'package:dio/dio.dart';
// ignore: unnecessary_import
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../menu/view/menu_screen.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../notification_services/notification_services.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../viewmodel/student_homework_viewmodel.dart';
import 'package:intl/intl.dart';
import 'package:percent_indicator/percent_indicator.dart';

class StudentHomeWorkScreen extends StatefulWidget {
  const StudentHomeWorkScreen({super.key});

  @override
  State<StudentHomeWorkScreen> createState() => _StudentHomeWorkScreenState();
}

class _StudentHomeWorkScreenState extends State<StudentHomeWorkScreen> {
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  bool tap = false;
  int? selectedStudentClassId;
  int? selectedStudentSectionId;
  String? attendanceStudentPhoto;
  String? attendanceStudentName;
  String? attendanceStudentClass;
  String? attendanceStudentRoll;
  String? attendanceRegNo;
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? selectedRoll;
  String? url;

  int? classId;
  int? sectionId;
  double progress = 0;
  int? selectedIndex;
  NotificationServices notificationServices = NotificationServices();
  List<int> isdownloadProgress = [];
  List<bool> isDownloadStart = [];
  List<bool> isDownloadFinish = [];
  List<bool> isException = [];
  bool isOk = false;

  bool isPermission = false;
  String getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  @override
  void initState() {
    super.initState();
    notificationServices.storagePermission();
    preference();

    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarBrightness: Brightness.dark,
      ),
    );
  }

  Future<void> downloadFile(int index) async {
    final homeworkProvider =
        Provider.of<StudentHomeWorkProvider>(context, listen: false);
    final homework = homeworkProvider.homeworkList[index];

    if (homework.filepath == null || homework.filepath!.isEmpty) {
      print("Homework filepath is null or empty");
      return;
    }
    if (homework.filepath != null || homework.filepath.toString().isNotEmpty) {
      print('homework filepath:${homework.filepath}');
      url = homework.filepath.toString().contains('demoapp.citronsoftwares.com')
          ? 'http://${homework.filepath}'
          : 'http://${homework.filepath}';
      print('url is $url');
    }
    final Dio dio = Dio();

    try {
      const dir =
          '/storage/emulated/0/Download'; // Get the application's temporary directory
      // final saveFileName = homework.work.replaceAll(RegExp(r"\s+"), "");
      final saveFileName = homework.work.replaceAll(' ', '_');
      final filePath =
          '$dir/$saveFileName${getFileExtension(homework.filepath!)}';
      print(filePath); // Define the file path

      final response = await dio.download(
        url.toString(),
        // Specify the path where you want to save the downloaded file
        filePath, // Replace with your desired path
        onReceiveProgress: (receivedBytes, totalBytes) {
          // Calculate download progress
          setState(() {
            progress = receivedBytes / totalBytes;
          });

          print(progress);
        },
      );

      if (response.statusCode == 200) {
        // File downloaded successfully
        setState(() {
          isOk = true;
        });
        print('Downloaded successfully');
        // ignore: use_build_context_synchronously
      } else {
        print(response.statusCode);
        print('File Downloading Error');
        // ignore: use_build_context_synchronously
      }
    } catch (e) {
      setState(() {
        progress = 0;
        isOk = false;
      });
      print('Error: $e');

      CommonMethods().showSnackBar(context, 'File Downloading Error');
    }
  }

  void preference() async {
    final pref = await SharedPreferences.getInstance();

    schoolId = pref.getInt('schoolid');
    print(schoolId);
    sessionId = pref.getInt('sessionid');
    mobno = pref.getString('mobno');
    print(mobno);
    selectedPhoto = pref.getString('attendanceStudentPhoto');
    selectedName = pref.getString('attendanceStudentName');
    selectedClass = pref.getString(
      'attendanceStudentClass',
    );

    selectedRoll = pref.getString(
      'attendanceStudentRoll',
    );

    attendanceRegNo = pref.getString('attendanceRegNo');
    classId = pref.getInt('classId');
    sectionId = pref.getInt('sectionId');
    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);

    final homework =
        // ignore: use_build_context_synchronously
        Provider.of<StudentHomeWorkProvider>(context, listen: false);
    if (classId != null && sectionId != null) {
      homework.fetchHomework(classId!, sectionId!);

      homework.initializeLoadingStates();
    } else {
      print('class Id or section Id is null');
    }
  }

  Future<void> _refreshHomework() async {
    final homeworkProvider =
        Provider.of<StudentHomeWorkProvider>(context, listen: false);

    if (classId != null && sectionId != null) {
      await homeworkProvider.fetchHomework(classId!, sectionId!);
      setState(() {
        // Update the UI to reflect the new data
      });
    }
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

                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                          if (student.classId != null &&
                              student.sectionId != null) {
                            Provider.of<StudentHomeWorkProvider>(context,
                                listen: false)
                                .fetchHomework(
                                student.classId!, student.sectionId!);
                          }
                        });
                        setState(() {
                          tap = true;
                        });
                        // ignore: use_build_context_synchronously
                        Navigator.of(context).pop();
                      },
                    ),
                    const Divider(
                      color: Colors.white,
                    ),
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
    final Size size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final menuProvider = Provider.of<MenuViewModel>(context);
    final homeworkProvider = Provider.of<StudentHomeWorkProvider>(context);
    final student = studentProvider.profile;
    final selectedStudentIndex = studentProvider.selectedIndex;
    final students = student?.stm ?? [];
    selectedStudentClassId =
        students.isNotEmpty ? students[selectedStudentIndex].classId ?? 0 : 0;
    selectedStudentSectionId =
        students.isNotEmpty ? students[selectedStudentIndex].sectionId ?? 0 : 0;

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
            width: double.infinity,
            child: Row(
              mainAxisSize: MainAxisSize.min,
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
                  padding: const EdgeInsets.only(left: 15.0),
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
                ),
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
      body: RefreshIndicator(
        onRefresh: _refreshHomework,
        backgroundColor: Appcolor.themeColor,
        color: Colors.white,
        child: homeworkProvider.isLoading
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
                              color: Colors.white, fontSize: size.width * 0.03),
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
            : homeworkProvider.homeworkList.isEmpty
                ? const Center(child: Text('No homewrok available'))
                : SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        ListView.builder(
                          physics: const BouncingScrollPhysics(),
                          shrinkWrap: true,
                          itemCount: homeworkProvider.homeworkList.length,
                          itemBuilder: (context, index) {
                            final homework =
                                homeworkProvider.homeworkList[index];

                            for (int i = 0;
                                i < homeworkProvider.homeworkList.length;
                                i++) {
                              isDownloadStart.add(false);
                              isDownloadFinish.add(false);
                              isdownloadProgress.add(0);
                            }
                            return Padding(
                              padding:
                                  const EdgeInsets.symmetric(horizontal: 15),
                              child: Container(
                                margin: const EdgeInsets.only(top: 10),
                                padding: const EdgeInsets.only(
                                    left: 10, right: 10, top: 10, bottom: 8),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(10),
                                  border: Border.all(color: Colors.grey),
                                ),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Work: ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Expanded(
                                          child: Text(
                                            homework.work,
                                            style: const TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.w400),
                                          ),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    Row(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const Text(
                                          'Date: ',
                                          style: TextStyle(
                                              fontSize: 15,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Text(
                                          DateFormat('dd,MMM,y').format(
                                              DateTime.parse(homework.date)),
                                          style: const TextStyle(
                                              fontSize: 14,
                                              fontWeight: FontWeight.w400),
                                        ),
                                      ],
                                    ),
                                    const SizedBox(
                                      height: 5,
                                    ),
                                    homework.filepath == null ||
                                            homework.filepath.toString().isEmpty
                                        ? const SizedBox.shrink()
                                        : Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.end,
                                            children: [
                                              Column(
                                                children: [
                                                  Visibility(
                                                    visible:
                                                        !isDownloadStart[index],
                                                    child: InkWell(
                                                      onTap: () {
                                                        downloadBuilder(index);

                                                        downloadFile(index);
                                                        // Set loading state for this item
                                                      },
                                                      child:
                                                          homework.filepath !=
                                                                      null ||
                                                                  homework
                                                                      .filepath!
                                                                      .isNotEmpty
                                                              ? Container(
                                                                  height:
                                                                      size.height *
                                                                          0.037,
                                                                  width:
                                                                      size.width *
                                                                          0.18,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    color: Colors
                                                                            .indigo[
                                                                        900],
                                                                    borderRadius:
                                                                        BorderRadius
                                                                            .circular(5),
                                                                  ),
                                                                  child:
                                                                      const Center(
                                                                    child: Text(
                                                                      'Download',
                                                                      style:
                                                                          TextStyle(
                                                                        fontSize:
                                                                            10,
                                                                        color: Colors
                                                                            .white,
                                                                        fontWeight:
                                                                            FontWeight.bold,
                                                                      ),
                                                                    ),
                                                                  ),
                                                                )
                                                              : const SizedBox
                                                                  .shrink(),
                                                    ),
                                                  ),
                                                  Visibility(
                                                    visible: isDownloadStart[
                                                            index] &&
                                                        progress != 0,
                                                    child: Column(
                                                      children: [
                                                        CircularPercentIndicator(
                                                          radius: 14.0,
                                                          lineWidth: 3.0,
                                                          percent:
                                                              (isdownloadProgress[
                                                                      index] /
                                                                  100),
                                                          progressColor: Colors
                                                              .indigo[900],
                                                        ),
                                                        const Text(
                                                          'Loading...',
                                                          style: TextStyle(
                                                              fontSize: 12),
                                                        )
                                                      ],
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                        const SizedBox(
                          height: 20,
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }

  void downloadBuilder(int index) async {
    isDownloadStart[index] = true;
    isDownloadFinish[index] = false;
    isdownloadProgress[index] = 0;
    setState(() {});
    while (isdownloadProgress[index] < 100) {
      isdownloadProgress[index] += 10;
      setState(() {});
      if (isdownloadProgress[index] == 100 && isOk == true) {
        setState(() {
          isDownloadFinish[index] = true;
          isDownloadStart[index] = false;
          CommonMethods().showSnackBar(context, 'Downloaded successfully');
        });

        break;
      }
      await Future.delayed(const Duration(milliseconds: 500));
    }
  }
}
