import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../utils/appcolors.dart';
import '../model/profile_model.dart';
import '../view_model/profile_view_model.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  int? schoolId;
  int? sessionId;
  String? mobno;
  Stm? selectedStudent;
  String? selectedStudentPhotoUrl;
  bool tap = false;
  final String defaultPhoto =
      'https://www.flaticon.com/free-icon/profile_3135715';

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

  String userType = '';

  void preference() async {
    final pref = await SharedPreferences.getInstance();
    schoolId = pref.getInt('schoolid');

    sessionId = pref.getInt('sessionid');
    mobno = pref.getString('mobno');
    userType = pref.getString('userType').toString();

    final studentProvider =
        // ignore: use_build_context_synchronously
        Provider.of<StudentProvider>(context, listen: false);
    // ignore: use_build_context_synchronously
    studentProvider.fetchStudentData(
        mobno.toString(), schoolId.toString(), sessionId.toString(), context);
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
                      onTap: () {
                        setState(() {
                          tap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                        });
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

  void requiredData() {}

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final studentProvider = Provider.of<StudentProvider>(context);
    final menuProvider = Provider.of<MenuViewModel>(context);
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();
    final teacherContact = teacherInfo?.contactno ?? 'N/A';

    final student = userType == "Parent" ? studentProvider.profile : null;
    final selectedStudentIndex = studentProvider.selectedIndex;
    final students = student?.stm ?? [];
    final selectedStudentName = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].stuName ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentClass = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].className ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentRoll = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].rollNo ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentSection = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].sectionName ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentFather = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].fatherName ?? 'N/A'
            : 'N/A'
        : null;

    final selectedStudentDob = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].dob != null
                ? students[selectedStudentIndex].dob!.length >= 11
                    ? students[selectedStudentIndex].dob!.substring(0, 11)
                    : students[selectedStudentIndex].dob!
                : 'N/A'
            : 'N/A'
        : null;

    final selectedStudentGender = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].gender ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentCategory = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].category ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentContact = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].contactNo ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentRegNo = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].regNo ?? 'N/A'
            : 'N/A'
        : null;

    final selectedStudentConveyance = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].conveyance ?? 'N/A'
            : 'N/A'
        : null;
    final selectedStudentAddress = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].address ?? 'N/A'
            : 'N/A'
        : null;

    final selectedStudentPhoto = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].photo
            : null
        : null;

    final selectedStudentStop = userType == "Parent"
        ? students.isNotEmpty
            ? students[selectedStudentIndex].stop ?? 'N/A'
            : 'N/A'
        : null;

    return Scaffold(
      appBar: userType == "Parent"
          ? AppBar(
              automaticallyImplyLeading: false,
              leadingWidth: 0,
              toolbarHeight: 70,
              titleSpacing: 20,
              backgroundColor: Appcolor.themeColor,
              title: InkWell(
                onTap: () {
                  _showStudentList(context, students);
                },
                child: SizedBox(
                  width: double.infinity,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      GestureDetector(
                        child: Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Appcolor.lightgrey),
                          child: selectedStudentPhoto != null
                              ? ClipOval(
                                  child: Image.network(
                                    selectedStudentPhoto.toString(),
                                    fit: BoxFit.cover,
                                    errorBuilder: (context, error, stackTrace) {
                                      // Handle network image loading error here
                                      return Image.asset(
                                          'assets/images/user_profile.png'); // Replace with your error placeholder image
                                    },
                                  ),
                                )
                              : ClipOval(
                                  child: Image.asset(
                                    'assets/images/user_profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(top: 3.0),
                              child: Text(
                                'Name: $selectedStudentName',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: size.width * 0.03),
                              ),
                            ),
                            Text(
                              'Class: $selectedStudentClass |  $selectedStudentSection',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: size.width * 0.03),
                            ),
                            Text(
                              'Roll no: $selectedStudentRoll',
                              style: TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.w600,
                                  overflow: TextOverflow.ellipsis,
                                  fontSize: size.width * 0.03),
                            )
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
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
            )
          : userType == "Teacher" ||
                  userType == "Admin" ||
                  userType == "Principal"
              ? AppBar(
                  automaticallyImplyLeading: false,
                  leadingWidth: 0,
                  toolbarHeight: 70,
                  titleSpacing: 20,
                  backgroundColor: Appcolor.themeColor,
                  title: SizedBox(
                    width: double.infinity,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        menuProvider.fileExists
                            ? Container(
                                width: 50,
                                height: 50,
                                decoration: const BoxDecoration(
                                    shape: BoxShape.circle,
                                    color: Appcolor.lightgrey),
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
                                                child:
                                                    CupertinoActivityIndicator(
                                                        color: Appcolor
                                                            .themeColor),
                                              )
                                            : Image.network(
                                                teacherPhoto,
                                                fit: BoxFit.cover,
                                                errorBuilder: (context, error,
                                                    stackTrace) {
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
                                    shape: BoxShape.circle,
                                    color: Appcolor.lightgrey),
                                child: ClipOval(
                                  child: Image.asset(
                                    'assets/images/user_profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                )),
                        Padding(
                          padding: const EdgeInsets.only(
                            left: 10,
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Name: $teacherName',
                                  style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      overflow: TextOverflow.ellipsis,
                                      fontSize: size.width * 0.03),
                                ),
                              ),
                              Text(
                                'Email:$teacherEmail',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    overflow: TextOverflow.ellipsis,
                                    fontSize: size.width * 0.03),
                              ),
                              Text(
                                'Contact: $teacherContact',
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
                )
              : AppBar(
                  automaticallyImplyLeading: false,
                  leadingWidth: 0,
                  toolbarHeight: 70,
                  titleSpacing: 20,
                  backgroundColor: Appcolor.themeColor,
                  title: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: 50,
                        height: 50,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.grey),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 10,
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Container(
                                    width: size.width * 0.4,
                                    height: 4,
                                    color: Colors.grey)),
                            const SizedBox(height: 5),
                            Container(
                                width: size.width * 0.4,
                                height: 4,
                                color: Colors.grey),
                            const SizedBox(height: 5),
                            Container(
                                width: size.width * 0.4,
                                height: 4,
                                color: Colors.grey),
                            const SizedBox(height: 5),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
      body: studentProvider.isLoading || menuProvider.isLoading
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
          : SingleChildScrollView(
              child: students.isNotEmpty
                  ? Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const SizedBox(
                          height: 15,
                        ),
                        userType == "Parent"
                            ? Container(
                                width: size.width * 0.5,
                                child: Card(
                                  margin: EdgeInsets.zero,
                                  color: Colors.red[600],
                                  shape: const RoundedRectangleBorder(
                                    borderRadius: BorderRadius.only(
                                      topRight: Radius.circular(20),
                                      bottomRight: Radius.circular(20),
                                    ),
                                  ),
                                  child: Container(
                                    // width: size.width * 0.4,
                                    child: Padding(
                                      padding: const EdgeInsets.all(8.0),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            'Student Personal details',
                                            style: TextStyle(
                                                color: Colors.white,
                                                fontSize: size.width * 0.035),
                                          ),
                                          //Text
                                          const Icon(
                                            Icons.star,
                                            color: Colors.amber,
                                            size: 16,
                                          )
                                        ],
                                      ),
                                    ),
                                  ),
                                ),
                              )
                            : Container(),
                        if (userType == "Parent")
                          Padding(
                            padding: const EdgeInsets.all(15.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                const SizedBox(
                                  height: 10,
                                ),

                                Text(
                                  'Name: $selectedStudentName',
                                  style: const TextStyle(
                                    color: Colors.black,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12,
                                  ),
                                ),

                                const SizedBox(
                                  height: 10,
                                ),

                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(5),
                                          gradient: Appcolor.blueGradient),
                                      child: Padding(
                                        padding: const EdgeInsets.only(
                                            left: 20.0,
                                            right: 20.0,
                                            top: 10,
                                            bottom: 10),
                                        child: Text(
                                          'Class: $selectedStudentClass',
                                          style: TextStyle(
                                            color: Colors.white,
                                            fontWeight: FontWeight.w600,
                                            fontSize: size.width * 0.035,
                                          ),
                                        ),
                                      ),
                                    ),
                                    Padding(
                                      padding:
                                          const EdgeInsets.only(left: 15.0),
                                      child: Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(5),
                                            gradient: Appcolor.pinkGradient),
                                        child: Padding(
                                          padding: const EdgeInsets.only(
                                              left: 20.0,
                                              right: 20.0,
                                              top: 10,
                                              bottom: 10),
                                          child: Text(
                                            'Section: $selectedStudentSection',
                                            style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: size.width * 0.035,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    const SizedBox(),
                                  ],
                                ),

                                const SizedBox(
                                  height: 5,
                                ),
                                Chip(
                                  elevation: 20,
                                  padding: const EdgeInsets.all(8),

                                  shadowColor: Colors.black,
                                  avatar: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/star.png'), //NetworkImage
                                  ), //CircleAvatar
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Roll: $selectedStudentRoll',
                                        style: TextStyle(
                                            color: Colors.black,
                                            fontSize: size.width * 0.035),
                                      ),
                                      Text(
                                        'Adm.no: $selectedStudentRegNo',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: size.width * 0.035,
                                        ),
                                      ),
                                    ],
                                  ), //Text
                                ), //Chip

                                const SizedBox(
                                  height: 2,
                                ),

                                const SizedBox(
                                  height: 5,
                                ),
                                Chip(
                                  elevation: 20,
                                  padding: const EdgeInsets.all(8),

                                  shadowColor: Colors.black,
                                  avatar: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/schedule.png'), //NetworkImage
                                  ), //CircleAvatar
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'DOB: $selectedStudentDob',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),
                                Chip(
                                  elevation: 20,
                                  padding: const EdgeInsets.all(8),

                                  shadowColor: Colors.black,
                                  avatar: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/user_profile.png'), //NetworkImage
                                  ), //CircleAvatar
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Father Name: $selectedStudentFather',
                                        style: const TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: 12,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 2,
                                ),

                                Chip(
                                  elevation: 20,
                                  padding: const EdgeInsets.all(8),

                                  shadowColor: Colors.black,
                                  avatar: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/user-interface.png'), //NetworkImage
                                  ), //CircleAvatar
                                  label: Text(
                                    'Contact: $selectedStudentContact',
                                    style: const TextStyle(
                                      color: Colors.black,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12,
                                    ),
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),
                                Chip(
                                  elevation: 20,
                                  padding: const EdgeInsets.all(8),

                                  shadowColor: Colors.black,
                                  avatar: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/symbol.png'), //NetworkImage
                                  ), //CircleAvatar
                                  label: Row(
                                    mainAxisAlignment:
                                        MainAxisAlignment.spaceBetween,
                                    children: [
                                      Text(
                                        'Category: $selectedStudentCategory',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: size.width * 0.035,
                                        ),
                                      ),
                                      Text(
                                        'Gender: $selectedStudentGender',
                                        style: TextStyle(
                                          color: Colors.black,
                                          fontWeight: FontWeight.w600,
                                          fontSize: size.width * 0.035,
                                        ),
                                      ),
                                      const SizedBox(),
                                    ],
                                  ),
                                ),

                                const SizedBox(
                                  height: 5,
                                ),
                                Row(
                                  children: [
                                    Container(
                                      decoration: const BoxDecoration(
                                        gradient: Appcolor.blackGradient,
                                        borderRadius: BorderRadius.only(
                                          topLeft: Radius.circular(5),
                                          bottomLeft: Radius.circular(5),
                                        ),
                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Text(
                                          'Address',
                                          style: TextStyle(
                                              color: Colors.white,
                                              fontWeight: FontWeight.w600,
                                              fontSize: size.width * 0.035),
                                        ),
                                      ),
                                    ),
                                    Expanded(
                                      flex: 1,
                                      child: Container(
                                        decoration: BoxDecoration(
                                            color: Colors.red.shade50,
                                            borderRadius:
                                                const BorderRadius.only(
                                                    topRight:
                                                        Radius.circular(5),
                                                    bottomRight:
                                                        Radius.circular(5))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(15.0),
                                          child: Text(
                                            ' $selectedStudentAddress',
                                            style: TextStyle(
                                                color: Colors.black,
                                                fontWeight: FontWeight.w600,
                                                fontSize: size.width * 0.035),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                                const SizedBox(
                                  height: 2,
                                ),

                                Chip(
                                  elevation: 20,
                                  padding: const EdgeInsets.all(8),

                                  shadowColor: Colors.black,
                                  avatar: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/bus-school.png'), //NetworkImage
                                  ), //CircleAvatar
                                  label: Text(
                                    selectedStudentConveyance!.isNotEmpty
                                        ? 'Conveyance: $selectedStudentConveyance'
                                        : 'Conveyance: N/A',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                                const SizedBox(
                                  height: 2,
                                ),

                                Chip(
                                  elevation: 20,
                                  padding: const EdgeInsets.all(8),

                                  shadowColor: Colors.black,
                                  avatar: const CircleAvatar(
                                    backgroundImage: AssetImage(
                                        'assets/images/bus-stops.png'), //NetworkImage
                                  ), //CircleAvatar
                                  label: Text(
                                    selectedStudentStop != null &&
                                            selectedStudentStop
                                                .toString()
                                                .isNotEmpty
                                        ? 'Stop: $selectedStudentStop'
                                        : 'Stop: N/A',
                                    style: const TextStyle(
                                        color: Colors.black,
                                        fontWeight: FontWeight.w600,
                                        fontSize: 12),
                                  ),
                                ),
                              ],
                            ),
                          ),
                      ],
                    )
                  : userType == "Parent"
                      ? const Center(
                          child: Text('No student data available.'),
                        )
                      : const SizedBox.shrink(),
            ),
    );
  }
}
