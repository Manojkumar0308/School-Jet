import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:zoom_widget/zoom_widget.dart';

import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../download_class.dart/downloads_methods.dart';

class ImageFullScreen extends StatefulWidget {
  final String imageUrl;

  const ImageFullScreen({super.key, required this.imageUrl});

  @override
  State<ImageFullScreen> createState() => _ImageFullScreenState();
}

class _ImageFullScreenState extends State<ImageFullScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.black,
        actions: [
          IconButton(
            icon: const Icon(Icons.file_download), // Add the download icon here
            onPressed: () {
              if (widget.imageUrl.isNotEmpty) {
                Downloads.downloadBuilder(context);
                Downloads.downloadFile(widget.imageUrl, widget.imageUrl);
              }
            },
          ),
        ],
        // Add any other customization you want for the app bar
      ),
      body: Center(
        child: GestureDetector(
          onTap: () {
            Navigator.pop(context); // Close the full-screen image when tapped
          },
          child: widget.imageUrl.contains('pdf')
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                        Icon(
                          Icons.picture_as_pdf,
                          color: Colors.red,
                          size: 35,
                        ),
                        SizedBox(
                          width: 5,
                        ),
                        Text('PDF FILE'),
                      ],
                    ),
                    const SizedBox(
                      height: 5,
                    ),
                    const Text(
                      'Please download the file to open it',
                      style: TextStyle(fontSize: 12, color: Colors.blueGrey),
                    ),
                  ],
                )
              : Zoom(
                  initTotalZoomOut: true,
                  child: Image.network(
                    widget.imageUrl,
                    fit: BoxFit.contain, // Adjust to your preference
                  ),
                ),
        ),
      ),
    );
  }
}
