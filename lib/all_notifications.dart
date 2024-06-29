import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'database/database_helper.dart';
import 'menu/view_model/menu_view_model.dart';
import 'notification/view/show_image.dart';
import 'notification/view/view_model/notification_refresh_data.dart';
import 'notification_report/view/notification_report.dart';
import 'profile/view_model/profile_view_model.dart';
import 'utils/appcolors.dart';

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
  final studentProviders =
      // ignore: use_build_context_synchronously
      Provider.of<StudentProvider>(context, listen: false);
  final matchingStudent = studentProviders.profile?.stm.firstWhere(
    (student) => student.regNo == notification.regno,
  );
  if (notification.title == 'MSG') {
    return Padding(
      padding: const EdgeInsets.all(15.0),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 15.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                matchingStudent?.photo != null
                    ? Container(
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.blueGrey),
                        child: ClipOval(
                          child: Image.network(
                            matchingStudent!.photo.toString(),
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
                        width: 30,
                        height: 30,
                        decoration: const BoxDecoration(
                            shape: BoxShape.circle, color: Colors.blueGrey),
                        child: ClipOval(
                            child: Image.asset(
                          'assets/images/user_profile.png',
                          fit: BoxFit.cover,
                        )),
                      ),
                const SizedBox(
                  width: 10,
                ),
                Expanded(
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.start,
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
                            maxLines: null,
                            style: const TextStyle(
                                color: Colors.white, fontSize: 12),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(top: 1.0),
                        child: Text(
                          'Date: ${formatDate(notification.mdate)}',
                          style: const TextStyle(
                              color: Colors.blueGrey, fontSize: 10),
                        ),
                      ),
                      Text(
                        'Time: ${formatTime24Hr(notification.mdate)}',
                        style: const TextStyle(
                            color: Colors.blueGrey, fontSize: 10),
                      ),
                      Text(
                        'Name: ${matchingStudent?.stuName.toString()}',
                        style: const TextStyle(
                            color: Colors.blueGrey, fontSize: 10),
                      ),
                      Text(
                        'Class:${matchingStudent?.className.toString()} | Section:${matchingStudent?.sectionName.toString()}',
                        style: const TextStyle(
                            color: Colors.blueGrey, fontSize: 10),
                      ),
                    ],
                  ),
                ),
              ],
            ),

            // Add other widgets as needed for "MSG" type notification
          ],
        ),
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
              matchingStudent?.photo != null
                  ? Container(
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blueGrey),
                      child: ClipOval(
                        child: Image.network(
                          matchingStudent!.photo.toString(),
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
                      width: 30,
                      height: 30,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blueGrey),
                      child: ClipOval(
                          child: Image.asset(
                        'assets/images/user_profile.png',
                        fit: BoxFit.cover,
                      )),
                    ),
              const SizedBox(
                width: 10,
              ),
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
          Padding(
            padding: const EdgeInsets.only(top: 1.0),
            child: Text(
              'Date: ${formatDate(notification.mdate)}',
              style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
            ),
          ),
          Text(
            'Time: ${formatTime24Hr(notification.mdate)}',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
          ),
          Text(
            'Name: ${matchingStudent?.stuName.toString()}',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
          ),
          Text(
            'Class:${matchingStudent?.className.toString()} | Section:${matchingStudent?.sectionName.toString()}',
            style: const TextStyle(color: Colors.blueGrey, fontSize: 10),
          ),
        ],
      ),
    );
  } else {
    return Container();
  }
}

class AllNotifications extends StatefulWidget {
  const AllNotifications({super.key});

  @override
  State<AllNotifications> createState() => _AllNotificationsState();
}

class _AllNotificationsState extends State<AllNotifications> {
  String userType = '';

  int? schoolId;
  int? sessionId;
  String mobno = '';

  bool _isLoading = true;

  // bool isLoading = true;
  // ignore: prefer_typing_uninitialized_variables
  var attendanceProvider;
  // ignore: prefer_typing_uninitialized_variables
  var attendance;

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
    // ignore: use_build_context_synchronously
    Provider.of<MenuViewModel>(context, listen: false)
        .fetchTeacherInfo(mobno.toString());
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
    // final selectedStudentRegno = students[selectedStudentIndex].regNo ?? '';

    setState(() {
      _isLoading = true; // Show the loader
    });
    await _databaseHelper.init();

    final notifications =
        await _databaseHelper.getNotificationsAll(_pageNumber, _pageSize);

    setState(() {
      if (notifications.length < _pageSize) {
        _moreDataAvailable = false;
      }

      _notifications.addAll(notifications);
      _isLoading = false;
    });

    final notificationProvider =

        // ignore: use_build_context_synchronously
        Provider.of<NotificationRefreshProvider>(context, listen: false);
    notificationProvider
        .addListener(_handleRefresh); //to handle notification refreshes.
  }

  @override
  void initState() {
    super.initState();

    initializeData();
  }

  bool showLoadMoreButton = false;
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuViewModel>(context);
    final size = MediaQuery.of(context).size;
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherContact = teacherInfo?.contactno ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo;
    return Scaffold(
      appBar: userType == "Parent"
          ? AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Appcolor.themeColor,
              title: const Text(
                'All Notifications',
                style: TextStyle(fontSize: 16),
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
                  backgroundColor: Appcolor.themeColor,
                  toolbarHeight: 70,
                  titleSpacing: 2,
                  elevation: 0,
                  title: Padding(
                    padding: const EdgeInsets.only(left: 15.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        userType == "Teacher" ||
                                userType == "Admin" ||
                                userType == "Principal"
                            ? menuProvider.fileExists && teacherPhoto != null
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
                              ), // Replace with your asset image path

                        // Replace with your a
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
                  backgroundColor: Appcolor.themeColor,
                  title: const Text(
                    'All Notifications',
                    style: TextStyle(fontSize: 16),
                  ),
                  actions: [
                    Padding(
                      padding: const EdgeInsets.only(right: 15.0),
                      child: menuProvider.bytesImage != null
                          ? Image.memory(
                              menuProvider.bytesImage!,
                              height: size.height * 0.07,
                              width: size.width * 0.07,
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
    if (_isLoading) {
      return SizedBox(
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
          ],
        ),
      );
    } else if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications are available.',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return userType != "Parent"
          ? const NotificationReportScreen()
          : ListView.builder(
              shrinkWrap: true,
              itemCount: _notifications.length + 1,
              itemBuilder: (context, index) {
                if (index < _notifications.length) {
                  showLoadMoreButton = true;
                  final notification = _notifications[index];
                  return Padding(
                    padding: const EdgeInsets.only(top: 5.0),
                    child: buildCard(notification, context),
                  );
                } else {
                  return Visibility(
                    visible: showLoadMoreButton,
                    child: _buildLoadMoreButton(),
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
      final notifications =
          await _databaseHelper.getNotificationsAll(_pageNumber, _pageSize);

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
