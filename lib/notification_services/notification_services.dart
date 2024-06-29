import 'dart:convert';
import 'dart:io';

import 'dart:math';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:flutter_local_notifications/flutter_local_notifications.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:permission_handler/permission_handler.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../database/database_helper.dart';
import '../host_service/host_services.dart';
import 'package:device_info_plus/device_info_plus.dart';

class NotificationServices {
  String? receivedRegNo;
  //instance of a firebasemessaging.
  FirebaseMessaging messaging = FirebaseMessaging.instance;
  // instance of a database helper class.
  final NotificationDatabaseHelper _databaseHelper =
      NotificationDatabaseHelper();

  String? token;
  bool isFirebaseInitialized = false;

// flutterlocalNotification instance created.
  final FlutterLocalNotificationsPlugin flutterLocalNotificationsPlugin =
      FlutterLocalNotificationsPlugin();
/* 
Initializes local notifications with platform-specific settings 
and configurations when the app is launched.
Sets up a callback for handling local notification interactions.*/
  void initLocalNotification(
      BuildContext context, RemoteMessage message) async {
    var androidInitializationSettings =
        const AndroidInitializationSettings('@mipmap/ic_launcher');
    var iosInitializationSettings = const DarwinInitializationSettings();

    var initializationSettings = InitializationSettings(
        android: androidInitializationSettings, iOS: iosInitializationSettings);
    await flutterLocalNotificationsPlugin.initialize(
      initializationSettings,
      onDidReceiveNotificationResponse: (details) {
        handleMessage(context, message);
      },
    );
  }

/* 
Requests permission for notifications from the user.
Handles different types of notifications (alert, sound, badge)
and authorization statuses. */
  void requestNotificationPermission() async {
    NotificationSettings settings = await messaging.requestPermission(
        alert: true,
        announcement: true,
        carPlay: true,
        criticalAlert: true,
        provisional: true,
        sound: true,
        badge: true);
    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      print('User granted permission');
    } else if (settings.authorizationStatus ==
        AuthorizationStatus.provisional) {
      print('User granted provisional permission');
    } else {
      print('User denied permission');
    }
  }

//method to getDevice token and update the userToken.
  Future<String> getDeviceToken() async {
    token = await messaging.getToken();

    print('device token is:$token');
    await updateUserToken();

    return token!;
  }

//  token refresh events, which can occur when the FCM token is updated.
  void isTokenRefresh() {
    messaging.onTokenRefresh.listen((event) {
      event.toString();
    });
  }

//method to update the user Token.
  Future<void> updateUserToken() async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final url = Uri.parse('$baseurl${HostService().updateToken}');
    print('update token url :$url');
    final body = {
      'mobno': pref.getString('mobno').toString(),
      'fcmtoken': token,
      'imei': '',
    };
    print('update userToken body :$body');
    try {
      final response = await http.post(url, body: body);

      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        // Request successful
        print('Success');
        print('result is:$result');
      } else {
        // Request failed
        print('Failed to update token. Status code: ${response.statusCode}');
      }
    } catch (e) {
      print(e.toString());
    }
  }

/* 
Displays a local notification when a push notification is received.
Creates Android and iOS notification details and uses flutterLocalNotificationsPlugin
 to display the notification.Also inserts the notification into the local database 
 and triggers a refresh of the notification screen.
 */
  void showNotification(
    RemoteMessage message,
    BuildContext context,
  ) async {
    final pref = await SharedPreferences.getInstance();
    // final msgToken = pref.getInt('notificationToken');
    // print('msgToken is-------->>>>>> $msgToken');
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(Random.secure().nextInt(100000).toString(),
            'High Importance Notification',
            importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name.toString(),
      channelDescription: 'Your channel description',
      importance: Importance.max,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      ticker: 'ticker',
      playSound: true,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    // Check if a notification with the same content already exists in the database

    await flutterLocalNotificationsPlugin.show(
        0,
        message.data['msgtype'] ?? '', // Use msgtype as the title
        message.data['msgtype'] == "IMAGE"
            ? 'Image file'
            : message.data['content'],
        notificationDetails,
        payload: 'navigate');
    // ignore: use_build_context_synchronously

    try {
      NotificationData notification = NotificationData(
          id: DateTime.now().millisecondsSinceEpoch,
          title: message.data['msgtype'] ?? '',
          content: message.data['content'] ?? '',
          regno: message.data['regno'] ?? '',
          mdate: message.data['mdate'] ?? '',
          msgid: message.data['msgid'] ?? '');

      _databaseHelper.insertNotification(notification);
      print('msgid is :${message.data['msgid']}');

      // // ignore: use_build_context_synchronously
      // Provider.of<NotificationRefreshProvider>(context, listen: false)
      //     .refresh();
      final msgNotifictionId = int.parse(message.data['msgid']);
      DateTime now = DateTime.now();
      //above code retreieves current DateTime.

      final currentDate = DateFormat("yyyyMMdd").format(now);
      //above line is for date format 20230919 year month and date with no space.
      final formattedDate = currentDate + '000000'.toString();

      downloadStatus(msgNotifictionId, formattedDate);
    } catch (e, stacktrace) {
      print("Error inserting notification: $e");
      print('stacktrace is : $stacktrace');
    }
  }

/* Initializes the Firebase messaging and sets up callbacks for handling incoming messages.
Calls initLocalNotification() and showNotification() to display the notification */
  void firebaseInit(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();

    if (!isFirebaseInitialized) {
      FirebaseMessaging.onMessage.listen((message) {
        if (Platform.isAndroid) {
          initLocalNotification(context, message);
          showNotification(message, context);
          // Save regno in the variable
          pref.setString('notifyregno', message.data['regno']);
          receivedRegNo = message.data['regno'];

          // Print for verification
          print('Received regno: $receivedRegNo');
        } else {
          showNotification(message, context);
        }
      });
      isFirebaseInitialized = true;
    }
  }

  void backgroundNavigation(BuildContext context) {}

// Handles navigation to the notification screen when a notification is tapped.
  void handleMessage(BuildContext context, RemoteMessage message) {}

// Handles navigation to the notification screen when a notification is tapped in terminate state.
  void setupInteractMessage(BuildContext context) async {
    FirebaseMessaging.onMessageOpenedApp.listen((RemoteMessage message) {
      // handleMessage(context, message);
    });
  }

/* Displays a local notification when the app is in the background.
Similar to showNotification() but without context handling.*/
  void showNotificationInBackground(RemoteMessage message) async {
    AndroidNotificationChannel androidNotificationChannel =
        AndroidNotificationChannel(Random.secure().nextInt(100000).toString(),
            'High Importance Notification',
            importance: Importance.max);
    AndroidNotificationDetails androidNotificationDetails =
        AndroidNotificationDetails(
      androidNotificationChannel.id.toString(),
      androidNotificationChannel.name.toString(),
      channelDescription: 'Your channel description',
      importance: Importance.high,
      priority: Priority.high,
      icon: '@mipmap/ic_launcher',
      ticker: 'ticker',
      playSound: true,
    );

    const DarwinNotificationDetails darwinNotificationDetails =
        DarwinNotificationDetails(
            presentAlert: true, presentBadge: true, presentSound: true);

    NotificationDetails notificationDetails = NotificationDetails(
        android: androidNotificationDetails, iOS: darwinNotificationDetails);

    flutterLocalNotificationsPlugin.show(
      0,
      message.data['msgtype'] ?? '',
      message.data['msgtype'] == "IMAGE"
          ? 'Image file'
          : message.data['content'],
      notificationDetails,
    );
    final pref = await SharedPreferences.getInstance();
    pref.setString('notifyregno', message.data['regno']);
  }

  void storagePermission() async {
    final plugin = DeviceInfoPlugin();
    if (Platform.isAndroid) {
      final android = await plugin.androidInfo;

      final storageStatus = android.version.sdkInt < 33
          ? await Permission.storage.request()
          : PermissionStatus.granted;

      if (storageStatus == PermissionStatus.granted) {
        print("granted");
      }
      if (storageStatus == PermissionStatus.denied) {
        print("denied");
      }
      if (storageStatus == PermissionStatus.permanentlyDenied) {
        openAppSettings();
      }
    } else {
      final ios = await plugin.iosInfo;
      final iosVersion = ios.systemVersion;
      if (int.tryParse(iosVersion.split('.')[0])! < 9) {
        print("iOS version less than 9. Storage permission not requested.");
      } else {
        final storageStatus = await Permission.storage.request();
        if (storageStatus == PermissionStatus.granted) {
          print("Storage permission granted");
        } else if (storageStatus == PermissionStatus.denied) {
          print("Storage permission denied");
        } else if (storageStatus == PermissionStatus.permanentlyDenied) {
          openAppSettings();
        }
      }
    }
  }

  Future<void> downloadStatus(
    int msgid,
    String downloadadddate,
  ) async {
    try {
      print('downloadStatus call');
      final pref = await SharedPreferences.getInstance();
      final baseUrl = pref.getString('apiurl');
      final url =
          Uri.parse('$baseUrl${HostService().notificationDownloadStatus}');
      print('downloadStatus url is---->>> $url');
      final body =
          jsonEncode({"messageid": msgid, "downloaddate": downloadadddate});
      print('body of downloadStatus is -->>$body');
      final headers = {
        'Content-Type': 'application/json',
      };
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        print('response of downloadStatus is -->>$result');
      } else {
        print(response.statusCode);
        // ignore: use_build_context_synchronously
        Fluttertoast.showToast(msg: 'Something went wrong');
      }
    } catch (e) {
      print(e.toString());
    }
  }
}
