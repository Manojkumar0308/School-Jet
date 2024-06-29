import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../dashboard/view/dashboard_screen.dart';
import '../leave/view/leave.dart';
import '../menu/view/menu_screen.dart';
import '../notification_services/notification_services.dart';

import '../profile/view/profile_screen.dart';
import '../all_notifications.dart';
import '../utils/appcolors.dart';
import '../utils/common_methods.dart';

class BottomNavigationScreen extends StatefulWidget {
  const BottomNavigationScreen({
    super.key,
  });

  @override
  State<BottomNavigationScreen> createState() => _BottomNavigationScreenState();
}

class _BottomNavigationScreenState extends State<BottomNavigationScreen> {
  NotificationServices notificationServices = NotificationServices();
  FirebaseMessaging firebaseMessaging = FirebaseMessaging.instance;
  int currentIndex = 0;
  String userType = '';
  bool isDataInitialized = false;
  //method for set index for different tabs.
  void onTabTapped(int index) {
    setState(() {
      currentIndex = index;
    });
  }

//initial method for determining userType on which tabs are depend.
  Future<void> initData() async {
    final pref = await SharedPreferences.getInstance();
    userType = pref.getString('userType').toString();
    setState(() {
      isDataInitialized = true; // Mark data as initialized
    });
  }

//when this screen calls initState method is called first.
  @override
  void initState() {
    super.initState();
    initData();
  }

  @override
  Widget build(BuildContext context) {
    if (!isDataInitialized) {
      return const Center(
          child:
              CircularProgressIndicator()); // Show loading indicator until data is initialized
    }
    return WillPopScope(
      onWillPop: () async {
        return CommonMethods().onwillPop(context);
      },
      child: Scaffold(
          bottomNavigationBar: userType == "Principal" || userType == "Admin"
              ? BottomNavigationBar(
                  type: BottomNavigationBarType.fixed,
                  //initially current index of tabs will be zero.
                  currentIndex: currentIndex,
                  //this function calls when user tap on different tabs for updating currentIndex.
                  onTap: onTabTapped,
                  selectedItemColor: const Color.fromARGB(255, 8, 22, 95),
                  unselectedItemColor: Colors.blueGrey,
                  selectedLabelStyle:
                      const TextStyle(color: Appcolor.themeColor, fontSize: 12),
                  unselectedLabelStyle:
                      const TextStyle(color: Colors.blueGrey, fontSize: 10),
                  showSelectedLabels: true,
                  showUnselectedLabels: true,
                  items: const [
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.bar_chart,
                        ),
                        label: 'Dashboard',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.window,
                        ),
                        label: 'Menu',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.chat,
                        ),
                        label: 'Leave',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.notifications,
                        ),
                        label: 'Notifications',
                      ),
                      BottomNavigationBarItem(
                        icon: Icon(
                          Icons.person,
                        ),
                        label: 'Profile',
                      ),
                    ])
              : userType == "Teacher"
                  ? BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      //initially current index of tabs will be zero.
                      currentIndex: currentIndex,
                      //this function calls when user tap on different tabs for updating currentIndex.
                      onTap: onTabTapped,
                      selectedItemColor: const Color.fromARGB(255, 8, 22, 95),
                      unselectedItemColor: Colors.blueGrey,
                      selectedLabelStyle: const TextStyle(
                          color: Appcolor.themeColor, fontSize: 12),
                      unselectedLabelStyle:
                          const TextStyle(color: Colors.blueGrey, fontSize: 10),
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      items: const [
                          BottomNavigationBarItem(
                            icon: Icon(
                              Icons.bar_chart,
                            ),
                            label: 'Dashboard',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(
                              Icons.window,
                            ),
                            label: 'Menu',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(
                              Icons.notifications,
                            ),
                            label: 'Notifications',
                          ),
                          BottomNavigationBarItem(
                            icon: Icon(
                              Icons.person,
                            ),
                            label: 'Profile',
                          ),
                        ])
                  : BottomNavigationBar(
                      type: BottomNavigationBarType.fixed,
                      currentIndex: currentIndex,
                      onTap: onTabTapped,
                      selectedItemColor: const Color.fromARGB(255, 8, 22, 95),
                      unselectedItemColor: Colors.blueGrey,
                      selectedLabelStyle: const TextStyle(
                          color: Appcolor.themeColor, fontSize: 12),
                      unselectedLabelStyle:
                          const TextStyle(color: Colors.blueGrey, fontSize: 10),
                      showSelectedLabels: true,
                      showUnselectedLabels: true,
                      items: const [
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.bar_chart,
                          ),
                          label: 'Dashboard',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.chat,
                          ),
                          label: 'Leave',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.notifications,
                          ),
                          label: 'Notifications',
                        ),
                        BottomNavigationBarItem(
                          icon: Icon(
                            Icons.person,
                          ),
                          label: 'Profile',
                        ),
                      ],
                    ),
          body: userType == "Admin" || userType == "Principal"
              // Builder are use to update the UI accordingly.
              ? Builder(
                  builder: (BuildContext context) {
                    switch (currentIndex) {
                      case 0:
                        return const DashBoardScreen();
                      case 1:
                        return const MenuScreen();
                      case 2:
                        return const LeaveScreen();
                      case 3:
                        return const AllNotifications();
                      case 4:
                        return const ProfileScreen();
                      default:
                        return Container();
                    }
                  },
                )
              : userType == "Teacher"
                  ? Builder(
                      builder: (BuildContext context) {
                        switch (currentIndex) {
                          case 0:
                            return const DashBoardScreen();
                          case 1:
                            return const MenuScreen();

                          case 2:
                            return const AllNotifications();
                          case 3:
                            return const ProfileScreen();
                          default:
                            return Container();
                        }
                      },
                    )
                  : Builder(
                      builder: (BuildContext context) {
                        switch (currentIndex) {
                          case 0:
                            return const DashBoardScreen();

                          case 1:
                            return const LeaveScreen();
                          case 2:
                            return const AllNotifications();
                          case 3:
                            return const ProfileScreen();
                          default:
                            return Container();
                        }
                      },
                    )),
    );
  }
}
