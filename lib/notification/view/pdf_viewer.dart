import 'dart:async';

import 'package:advance_pdf_viewer2/advance_pdf_viewer.dart';
import 'package:dio/dio.dart';

import 'package:flutter/material.dart';

import '../download_class.dart/downloads_methods.dart';

class PDFScreen extends StatefulWidget {
  final String? path;

  const PDFScreen({Key? key, required this.path}) : super(key: key);
  @override
  _PDFScreenState createState() => _PDFScreenState();
}

class _PDFScreenState extends State<PDFScreen> with WidgetsBindingObserver {
  int? pages = 0;
  int? currentPage = 0;
  bool isReady = false;
  String errorMessage = '';
  late PDFDocument document;
  bool _isLoading = true;

  double? progress;
  bool isDownloadStart = false;
  bool isDownloadFinish = false;
  double isdownloadProgress = 0;

  Future<void> loadDocument(String url) async {
    document = await PDFDocument.fromURL(url);
    setState(() {
      _isLoading = false;
    });
  }

  String getFileExtension(String fileName) {
    return ".${fileName.split('.').last}";
  }

  Future<void> downloadImage(String url) async {
    final Dio dio = Dio();
    try {
      const dir = '/storage/emulated/0/Download';
      DateTime now = DateTime.now();
      String dateString =
          now.toLocal().toString().split(' ')[0]; // Remove HH:mm:ss part
      String cleanedDateString = dateString.replaceAll(
          RegExp(r'[ -]'), ''); // Remove whitespace and hyphens

      final filePath = widget.path!.contains('pdf')
          ? '$dir/PDF_$cleanedDateString${getFileExtension(widget.path.toString())}'
          : '$dir/IMG_$cleanedDateString${getFileExtension(widget.path.toString())}';
      print(filePath);
      final response = await dio.download(
        url,
        filePath,
        onReceiveProgress: (receivedBytes, totalBytes) {
          // Calculate download progress
          setState(() {
            progress = receivedBytes / totalBytes;
          });

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

  @override
  void initState() {
    super.initState();
    loadDocument(widget.path.toString());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        title: const Text(
          'PDF View',
          style: TextStyle(
            fontSize: 14,
          ),
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.download),
            onPressed: () {
              if (widget.path != null) {
                Downloads.downloadBuilder(context);
                Downloads.downloadFile(
                    widget.path.toString(), widget.path.toString());
              }
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
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
            )
          : PDFViewer(
              progressIndicator: Center(
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
              ),
              document: document,
              zoomSteps: 1,
              scrollDirection: Axis.vertical,
              pickerButtonColor: Colors.black,
            ),
    );
  }
}
