// import 'package:camera/camera.dart';
// import 'package:flutter/material.dart';
// import 'dart:io';

// import 'package:school_jet/send_message/view/send_message_view.dart';

// class PreviewPage extends StatelessWidget {
//   const PreviewPage(
//       {Key? key,
//       required this.picture,
//       required this.base64ImageCamera,
//       required this.fileType})
//       : super(key: key);

//   final XFile picture;
//   final String base64ImageCamera;
//   final String fileType;

//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(title: const Text('Preview Page')),
//       body: Center(
//         child: Column(mainAxisSize: MainAxisSize.min, children: [
//           Image.file(File(picture.path), fit: BoxFit.cover, width: 250),
//           const SizedBox(height: 24),
//           GestureDetector(
//               onTap: () {
//                 Navigator.push(
//                     context,
//                     MaterialPageRoute(
//                         builder: (context) => SendMessageScreen(
//                               picture: picture,
//                               base64ImageCamera: base64ImageCamera,
//                               cameraFileType: fileType,
//                             )));
//               },
//               child: Text(picture.name)),
//         ]),
//       ),
//     );
//   }
// }
