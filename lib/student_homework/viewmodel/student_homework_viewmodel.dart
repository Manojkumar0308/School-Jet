import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter_file_downloader/flutter_file_downloader.dart';
import 'package:fluttertoast/fluttertoast.dart';

import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../../utils/common_methods.dart';
import '../model/model.dart';
import 'package:http/http.dart' as http;

class StudentHomeWorkProvider with ChangeNotifier {
  final List<Homework> _homeworkList = [];
  bool isLoading = false;
  Map<int, double> progressDwnld = {};
  List<bool> loadingStates = [];
  List<DownloadTaskInfo> downloadTasks = [];
  double? progress;

  Future<void> startDownload(
      String url, int index, BuildContext context) async {
    try {
      final File? file = await FileDownloader.downloadFile(
        url: url,
        onProgress: (String? fileName, double dwnloadprogress) {
          progress = dwnloadprogress;

          notifyListeners();
        },
        onDownloadCompleted: (String path) {
          progress = null;

          notifyListeners();
          CommonMethods().showSnackBar(context, 'Downloaded successfully');
        },
        onDownloadError: (String error) {
          CommonMethods().showSnackBar(context, 'File Downloading Error');
          notifyListeners();
        },
      );
      downloadTasks.add(DownloadTaskInfo(file!, index));
      notifyListeners();
    } catch (e) {
      notifyListeners();
      print("Error starting download: $e");
    }
  }

  // ... Other methods ...

  List<Homework> get homeworkList => _homeworkList;

  Future<void> fetchHomework(
    int classId,
    int sectionId,
  ) async {
    try {
      isLoading = true;
      final pref = await SharedPreferences.getInstance();
      final baseurl = pref.getString('apiurl');
      final url = Uri.parse('$baseurl${HostService().studentViewHomework}');
      print('student homework :$url');

      notifyListeners();
      final body = jsonEncode({
        "classid": classId,
        "sectionid": sectionId,
        "teacherid": 77,
        "date": "",
        "work": "",
        "msgtype": "",
        "content": ""
      });
      final response = await http.post(url,
          headers: {'Content-Type': 'application/json'}, body: body);

      if (response.statusCode == 200) {
        final List<dynamic> responseData = json.decode(response.body);
        print(responseData);

        _homeworkList.clear(); // Clear the existing list
        for (var data in responseData) {
          _homeworkList.add(Homework.fromJson(data));
        }
        isLoading = false;
        notifyListeners();
      } else {
        Fluttertoast.showToast(
            msg: 'Something went wrong',
            toastLength: Toast.LENGTH_SHORT,
            gravity: ToastGravity.BOTTOM,
            timeInSecForIosWeb: 2,
            backgroundColor: Colors.black,
            textColor: Colors.white,
            fontSize: 12.0);
      }
    } catch (e) {
      print('Exception is $e');
    }
  }

  // Method to initialize loading states
  void initializeLoadingStates() {
    loadingStates = List.filled(homeworkList.length, false);
  }

  void updateProgress(int index, double progress) {
    progressDwnld[index] = progress;
    notifyListeners();
  }
}

class DownloadTaskInfo {
  final File file;
  final int index;

  DownloadTaskInfo(this.file, this.index);
}
