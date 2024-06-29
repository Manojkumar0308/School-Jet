import 'package:dio/dio.dart';
import 'package:flutter/material.dart';

import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';

class Downloads {
  static double? progress;
  static bool isDownloadStart = false;
  static bool isDownloadFinish = false;
  static double isdownloadProgress = 0;

  static String getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  static Future<void> downloadFile(String url, String file) async {
    final Dio dio = Dio();
    try {
      const dir = '/storage/emulated/0/Download';
      DateTime now = DateTime.now();
      String dateString =
          now.toLocal().toString().split(' ')[0]; // Remove HH:mm:ss part
      String cleanedDateString = dateString.replaceAll(
          RegExp(r'[ -]'), ''); // Remove whitespace and hyphens

      final filePath = file.contains('pdf')
          ? '$dir/PDF_$cleanedDateString${getFileExtension(file)}'
          : '$dir/IMG_$cleanedDateString${getFileExtension(file)}';
      print(filePath);
      final response = await dio.download(
        url,
        filePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          // Calculate download progress

          progress = receivedBytes / totalBytes;

          print(progress);
        },
      );
      if (response.statusCode == 200) {
        print('Downloaded successfully');
      } else {
        print('Download failed');
      }
    } catch (e) {
      print('Exception is $e');
    }
  }

  static void downloadBuilder(BuildContext context) async {
    isDownloadStart = true;
    isDownloadFinish = false;
    isdownloadProgress = 0;
    if (isDownloadStart) {
      // Show the download dialog with a loader
      showDialog(
        context: context,
        barrierDismissible: false, // Prevent dismissing while downloading
        builder: (BuildContext context) {
          return AlertDialog(
            backgroundColor: Colors.black,
            title: const Text(
              'Downloading...',
              style: TextStyle(color: Colors.white),
            ),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: const [
                CircularProgressIndicator(
                  color: Appcolor.themeColor,
                ),
                SizedBox(height: 16),
                Text(
                  'Loading...',
                  style: TextStyle(color: Colors.white),
                ),
              ],
            ),
          );
        },
      );
      while (isdownloadProgress < 100) {
        isdownloadProgress += 10;

        if (isdownloadProgress == 100) {
          isDownloadFinish = true;
          isDownloadStart = false;
          CommonMethods().showSnackBar(context, 'Downloaded successfully');

          // Close the dialog
          Navigator.pop(context);
          break;
        }

        await Future.delayed(const Duration(milliseconds: 500));
      }
    }
  }
}
