import 'package:flutter/material.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../notification/view/show_image.dart';
import '../../notification/view/view_model/notification_refresh_data.dart';

import '../../database/database_helper.dart';
import '../../menu/view/menu_screen.dart';
import '../../profile/model/profile_model.dart';
import '../../profile/view_model/profile_view_model.dart';
import '../../utils/appcolors.dart';
import 'pdf_viewer.dart';

String formatDate(String inputDate) {
  if (inputDate.length < 8) {
    return 'Invalid Date'; // Handle this case as needed
  }

  final year = inputDate.substring(0, 4);
  final month = inputDate.substring(4, 6);
  final day = inputDate.substring(6, 8);

  final formattedDate = '$day/$month/$year';
  return formattedDate;
}

String formatTime24Hr(String dateTime) {
  if (dateTime.length < 12) {
    return 'Invalid DateTime'; // Handle this case as needed
  }

  String hours = dateTime.substring(8, 10);
  String minutes = dateTime.substring(10, 12);

  int hourValue = int.parse(hours);

  // Convert 04 to 16 format
  if (hourValue < 10) {
    hourValue += 12;
    hours = hourValue.toString().padLeft(2, '0');
  }
  String ampm = (hourValue < 12) ? 'AM' : 'PM';

  print('$hours:$minutes');
  return '$hours:$minutes $ampm';
}

bool imageVisible = false;

/*
In buildCard Widget it represents the how our notifications content are shown.
If our notification title is of 'MSG' then it shows content in green color Container in left position
of the screen and if it is of type IMAGE the show it in right side corner position. */
Widget buildCard(NotificationData notification, BuildContext context) {
  if (notification.title == 'MSG') {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            decoration: const BoxDecoration(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(2),
                  topRight: Radius.circular(20),
                  bottomRight: Radius.circular(20),
                  bottomLeft: Radius.circular(20),
                ),
                color: Colors.green),
            child: Padding(
              padding: const EdgeInsets.all(15.0),
              child: Text(
                notification.content,
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ),
          ),

          // Add other widgets as needed for "MSG" type notification
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              'Date: ${formatDate(notification.mdate)}',
              style: const TextStyle(color: Colors.blueGrey),
            ),
          ),
          Text(
            'Time: ${formatTime24Hr(notification.mdate)}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  }
  // If the title is "IMAGE," return an image widget
  else if (notification.title == 'IMAGE') {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 15.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              GestureDetector(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => ImageFullScreen(
                          imageUrl: 'http://${notification.content}'),
                    ),
                  );
                },
                child: Image.network(
                  'http://${notification.content}',
                  height: 200,
                  width: 200,
                ),
              ),
            ],
          ),
          Text(
            'Date: ${formatDate(notification.mdate)}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          Text(
            'Time: ${formatTime24Hr(notification.mdate)}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  } else if (notification.title == "PDF") {
    return Padding(
      padding: const EdgeInsets.only(right: 25),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          GestureDetector(
            onTap: () {
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => PDFScreen(
                            path: 'http://${notification.content}',
                          )));
            },
            child: Container(
              width: 200,
              decoration: BoxDecoration(
                  color: Colors.white, borderRadius: BorderRadius.circular(15)),
              // height: 50,
              child: Padding(
                padding: const EdgeInsets.all(10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  mainAxisSize: MainAxisSize.min,
                  children: const [
                    Icon(
                      Icons.picture_as_pdf,
                      color: Colors.red,
                      size: 45,
                    ),
                    Center(
                      child: Text(
                        'Tap to open', // Display the PDF name
                        style: TextStyle(
                            fontSize: 14,
                            color: Colors.blueGrey,
                            fontWeight: FontWeight.bold),
                      ),
                    ),
                    Icon(
                      Icons.arrow_forward_ios,
                      size: 20,
                      color: Colors.blueGrey,
                    )
                  ],
                ),
              ),
            ),
          ),
          Text(
            'Date: ${formatDate(notification.mdate)}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          Text(
            'Time: ${formatTime24Hr(notification.mdate)}',
            style: const TextStyle(color: Colors.blueGrey),
          ),
          const SizedBox(
            height: 10,
          ),
        ],
      ),
    );
  } else {
    return Container();
  }
}

class NotificationScreen extends StatefulWidget {
  const NotificationScreen({super.key});

  @override
  State<NotificationScreen> createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen> {
  int? schoolId;
  int? sessionId;
  String mobno = '';
  Stm? selectedStudent;
  bool tap = false;
  bool avatarTap = false;
  bool _isLoading = true;

  // bool isLoading = true;
  // ignore: prefer_typing_uninitialized_variables
  var attendanceProvider;
  // ignore: prefer_typing_uninitialized_variables
  var attendance;
  String? feeDetail;
  String? dueFeeWebView;
  String sharedPrefStuName = '';
  String sharedPrefClass = '';
  String sharedPrefRoll = '';
  String sharedPrefStuPhoto = '';
  String sharedPrefStuRegno = '';
  String? selectedPhoto;
  String? selectedName;
  String? selectedClass;
  String? selectedRoll;

  final NotificationDatabaseHelper databaseHelper =
      NotificationDatabaseHelper();
  late Stream<List<NotificationData>> _notificationsStream;
//method to open dialogbox on avatar tap to show the list of student in the dialog.

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
                        /* in dialog's student list onTap on any student first the data stored 
                       in a particular key is removed and the data of the tapped student 
                       will get stored  on the same key. */

                        pref.remove('attendanceRegNo');
                        pref.remove('attendanceStudentName');
                        pref.remove('attendanceStudentClass');
                        pref.remove('attendanceStudentRoll');
                        pref.remove('attendanceStudentPhoto');
                        // pref.setString(
                        //     'attendanceRegNo', student.regNo.toString());
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

                        selectedName = pref.getString('attendanceStudentName');
                        selectedPhoto =
                            pref.getString('attendanceStudentPhoto');
                        selectedClass =
                            pref.getString('attendanceStudentClass');
                        selectedRoll = pref.getString('attendanceStudentRoll');

                        setState(() {
                          sharedPrefStuRegno = student.regNo.toString();
                          avatarTap = true;
                          Provider.of<StudentProvider>(context, listen: false)
                              .selectStudent(index);
                          // Clear old notifications after selecting students.
                          _notifications.clear();
                          //shows the first page of the database data.
                          _pageNumber = 1;
                          //indicates that the data is available or not.
                          _moreDataAvailable = true;
                        });
                        //loading notifications from database
                        _loadNotifications();
                        //close the dialog.
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

  String userType = '';
  String? selectedStudentRegno;

//method initially calls at initState when screen launches.
  Future<void> initializeData() async {
    await init();

    _loadNotifications();
  }

  Future<void> init() async {
    final pref = await SharedPreferences.getInstance();
    mobno = pref.getString('mobno').toString();
    schoolId = pref.getInt('schoolid') ?? 0;
    userType = pref.getString('userType').toString();

    sessionId = pref.getInt('sessionid') ?? 0;

    mobno = pref.getString('mobno').toString();
    selectedStudentRegno = pref.getString('attendanceRegNo');
    selectedName = pref.getString('attendanceStudentName');
    selectedPhoto = pref.getString('attendanceStudentPhoto');
    selectedClass = pref.getString('attendanceStudentClass');
    selectedRoll = pref.getString('attendanceStudentRoll');
  }

  //database class instance created.
  final NotificationDatabaseHelper _databaseHelper =
      NotificationDatabaseHelper();
  // List of NotificationData objects representing notifications.
  final List<NotificationData> _notifications = [];
  int _pageNumber = 1;
  final int _pageSize = 12; // Number of notifications to load per page.
  //gives detail about more data is available or not.
  bool _moreDataAvailable = true;

/*
It first retrieves the selected student's registration number (selectedStudentRegno) 
from the studentProvider.If avatarTap is true, it retrieves notifications 
for the selected student; otherwise, it retrieves notifications for the student
 with attributes previously stored in SharedPreferences.
  */
  Future<void> _loadNotifications() async {
    setState(() {
      _isLoading = true; // Show the loader
    });
    await _databaseHelper.init();
    if (selectedStudentRegno != null || sharedPrefStuRegno.isNotEmpty) {
      final notifications = avatarTap
          ? await _databaseHelper.getNotifications(
              sharedPrefStuRegno.toString(),
              // _pageNumber, _pageSize
            )
          : await _databaseHelper.getNotifications(
              selectedStudentRegno.toString(),
              // _pageNumber, _pageSize
            );

      setState(() {
        if (notifications.length < _pageSize) {
          _moreDataAvailable = false;
        }
        _notifications.addAll(notifications);
        _isLoading = false;
      });
    }

    final notificationProvider =

        // ignore: use_build_context_synchronously
        Provider.of<NotificationRefreshProvider>(context, listen: false);
    notificationProvider
        .addListener(_handleRefresh); //to handle notification refreshes.
  }

  @override
  void initState() {
    super.initState();

    _notificationsStream = _databaseHelper.getNotificationsStream(
      selectedStudentRegno != null || sharedPrefStuRegno.isNotEmpty
          ? avatarTap
              ? sharedPrefStuRegno.toString()
              : selectedStudentRegno.toString()
          : '',
      // _pageNumber,
      // _pageSize
    );

    initializeData();
  }

  bool showLoadMoreButton = false;

  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuViewModel>(context);
    final studentProvider = Provider.of<StudentProvider>(context);
    final size = MediaQuery.of(context).size;
    final student = studentProvider.profile;
    final students = student?.stm ?? [];

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
                      shape: BoxShape.circle,
                      color: Appcolor.lightgrey,
                    ),
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
      body: _buildNotificationList(),
    );
  }

  Widget _buildNotificationList() {
    final size = MediaQuery.of(context).size;

    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications are available.',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return StreamBuilder<List<NotificationData>>(
        stream: _databaseHelper.getNotificationsStream(
          selectedStudentRegno != null || sharedPrefStuRegno.isNotEmpty
              ? avatarTap
                  ? sharedPrefStuRegno.toString()
                  : selectedStudentRegno.toString()
              : '',
          // _pageNumber,
          // _pageSize,
        ),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(
              child: Container(
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(10),
                    color: Colors.black),
                child: Padding(
                  padding: const EdgeInsets.all(25.0),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: const [
                      CircularProgressIndicator(),
                      SizedBox(
                        height: 10,
                      ),
                      Text(
                        'Loading....',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 12,
                            fontWeight: FontWeight.w500),
                      )
                    ],
                  ),
                ),
              ),
            );
          } else if (snapshot.hasError) {
            return Center(
              child: Text('Error: ${snapshot.error}'),
            ); // Show an error message if there's an error
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(
              child: Text('No notifications available'),
            ); // Show a message when no notifications are available
          } else {
            final List<NotificationData> notifications = snapshot.data!;
            return ListView.builder(
              shrinkWrap: true,
              itemCount: notifications.length,
              itemBuilder: (context, index) {
                final notification = notifications[index];
                return Padding(
                  padding: const EdgeInsets.only(top: 5.0),
                  child: buildCard(notification, context),
                );
              },
            );
          }
        },
      );
    }
  }

  Widget _buildLoadMoreButton() {
    final size = MediaQuery.of(context).size;

    if (_notifications.isEmpty) {
      return SizedBox(
        height: size.height * 0.035,
        child: const Center(
            child: Text(
          'No more data available.',
          style: TextStyle(
              color: Colors.redAccent,
              fontSize: 16,
              fontWeight: FontWeight.w600),
        )),
      );
    } else if (_moreDataAvailable && _notifications.length >= _pageSize) {
      return TextButton(
        onPressed: () {
          setState(() {
            _pageNumber++; // Load the next page
            _isLoading = true;
          });
          _loadNotifications();
        },
        child: const Text(
          'Load More',
          style: TextStyle(color: Appcolor.themeColor),
        ),
      );
    } else {
      return const SizedBox.shrink();
    }
  }

// to handle the refreshing of notifications when a user initiates a refresh action.
  void _handleRefresh() async {
    if (mounted) {
      setState(() {
        /*first clears the current list of notifications (_notifications), 
        resets the _pageNumber to 1, and sets _moreDataAvailable 
        and _isLoading to appropriate values.*/
        _notifications.clear();
        _pageNumber = 1;

        _moreDataAvailable = true;
        _isLoading = true;
      });
//  based on the selected student's registration number, page number, and page size.
      final notifications = await _databaseHelper.getNotifications(
        selectedStudentRegno!,
        // _pageNumber,
        // _pageSize
      );

      setState(() {
        /* retrieved notifications replace the current list in _notifications,
         and _moreDataAvailable is updated based on the number 
         of retrieved notifications.*/
        _notifications.clear();
        _notifications.addAll(notifications);
        _isLoading = false;
        // Hide loader after refreshing
        _moreDataAvailable = notifications.length >= _pageSize;
      });
    }
  }
}
