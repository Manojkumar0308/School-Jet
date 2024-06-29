import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:school_jet/notification_services/notification_services.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../admin/get_student_by_filter/view_model/view_model.dart';
import '../../database/database_helper.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../utils/appcolors.dart';
import 'show_image.dart';
import 'view_model/notification_refresh_data.dart';

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
// bool _isLoading = true;
NotificationData? notification;
NotificationServices notificationServices = NotificationServices();
//

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
        ],
      ),
    );
  } else {
    return Container();
  }
}

class DirectNotificationScreen extends StatefulWidget {
  const DirectNotificationScreen({super.key});

  @override
  State<DirectNotificationScreen> createState() =>
      _DirectNotificationScreenState();
}

class _DirectNotificationScreenState extends State<DirectNotificationScreen> {
  //database class instance created.
  final NotificationDatabaseHelper _databaseHelper =
      NotificationDatabaseHelper();
  // List of NotificationData objects representing notifications.
  final List<NotificationData> _notifications = [];
  int _pageNumber = 1;
  final int _pageSize = 12; // Number of notifications to load per page.
  //gives detail about more data is available or not.
  bool _moreDataAvailable = true;
  String? currentRegNo;

/*
It first retrieves the selected student's registration number (selectedStudentRegno) 
from the studentProvider.If avatarTap is true, it retrieves notifications 
for the selected student; otherwise, it retrieves notifications for the student
 with attributes previously stored in SharedPreferences.
  */
  Future<void> _loadNotifications() async {
    final pref = await SharedPreferences.getInstance();
    print(pref.getString('notifyregno').toString());
    String currentRegNo = pref.getString('notifyregno').toString();
    print('currentRegNo:$currentRegNo');
    final studentFilterByAdmin =
        // ignore: use_build_context_synchronously
        Provider.of<GetStudentByRegNoAdmin>(context, listen: false);
    studentFilterByAdmin.fetchStudentDetail(currentRegNo);
    await _databaseHelper.init();

    final notifications = await _databaseHelper.getNotifications(
      currentRegNo,
      // _pageNumber, _pageSize
    );

    setState(() {
      if (notifications.length < _pageSize) {
        _moreDataAvailable = false;
      }
      _notifications.addAll(notifications);
      print(notifications);
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

    _loadNotifications();
  }

  bool showLoadMoreButton = false;
  @override
  Widget build(BuildContext context) {
    final menuProvider = Provider.of<MenuViewModel>(context);
    final size = MediaQuery.of(context).size;
    final studentFilterByAdmin =
        // ignore: use_build_context_synchronously
        Provider.of<GetStudentByRegNoAdmin>(context);
    return Scaffold(
        appBar: AppBar(
          toolbarHeight: 70,
          titleSpacing: 2,
          backgroundColor: Appcolor.themeColor,
          title: InkWell(
            onTap: () {},
            child: SizedBox(
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  GestureDetector(
                    onTap: () {},
                    child: Container(
                      width: 50,
                      height: 50,
                      decoration: const BoxDecoration(
                          shape: BoxShape.circle, color: Colors.blue),
                      child: ClipOval(
                        child: Image.network(
                          studentFilterByAdmin.student?.sp?.photo ??
                              'https://source.unsplash.com/random/?city,night',
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
                  Flexible(
                    child: Padding(
                      padding: const EdgeInsets.only(left: 7.0),
                      child: SizedBox(
                        width: size.width * 0.6,
                        child: FittedBox(
                          fit: BoxFit.scaleDown,
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Padding(
                                padding: const EdgeInsets.only(top: 3.0),
                                child: Text(
                                  'Name: ${studentFilterByAdmin.student?.sp?.stuName ?? 'N/A'}',
                                  style: const TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ),
                              Text(
                                'Class: ${studentFilterByAdmin.student?.sp?.className ?? 'N/A'} | ${studentFilterByAdmin.student?.sp?.sectionName ?? ''}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                              Text(
                                'Roll: ${studentFilterByAdmin.student?.sp?.rollNo ?? 'N/A'}',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.w600,
                                    fontSize: 12),
                              ),
                            ],
                          ),
                        ),
                      ),
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
        body: _buildNotificationList());
  }

  void _handleRefresh() async {
    final pref = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        /*first clears the current list of notifications (_notifications), 
        resets the _pageNumber to 1, and sets _moreDataAvailable 
        and _isLoading to appropriate values.*/
        _notifications.clear();
        _pageNumber = 1;

        _moreDataAvailable = true;
        // _isLoading = true;
      });
//  based on the selected student's registration number, page number, and page size.

      final notifications = await _databaseHelper.getNotifications(
        pref.getString('notifyregno').toString(),
        // _pageNumber, _pageSize
      );
      setState(() {
        /* retrieved notifications replace the current list in _notifications,
         and _moreDataAvailable is updated based on the number 
         of retrieved notifications.*/
        _notifications.clear();
        _notifications.addAll(notifications);
        // _isLoading = false;
        // Hide loader after refreshing
        _moreDataAvailable = notifications.length >= _pageSize;
      });
    }
  }

  Widget _buildNotificationList() {
    if (_notifications.isEmpty) {
      return const Center(
        child: Text(
          'No notifications are available.',
          style: TextStyle(fontSize: 16),
        ),
      );
    } else {
      return ListView.builder(
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
            // _isLoading = true;
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
}
