// ignore: file_names
import 'dart:convert';
import 'dart:io';
import 'dart:math';

import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:image/image.dart' as img;
import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../../utils/common_methods.dart';

class HomeworkProvider extends ChangeNotifier {
  // A boolean flag indicating whether an operation is in progress.
  bool isLoading = false;
  int? teacherID;
  HostService hostService =
      HostService(); //class for all api urls instantiation.
//addHomework is the method to add homework to the students.
  Future<void> addHomework(
    BuildContext context,
    int classId,
    int sectionId,
    int teacherId,
    String date,
    String work,
    String msgType,
    String content,
  ) async {
    isLoading = true;
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');

    try {
      final url = Uri.parse(baseurl.toString() + hostService.addHomework);
      print('add homework url:$url');
      if (kDebugMode) {
        print(url);
      }
      final headers = {
        'Content-Type': 'application/json',
        'Charset': 'utf-8',
      };

      // Create the request payload
      final body = jsonEncode(
        {
          "classid": classId,
          "sectionid": sectionId,
          "teacherid": teacherId,
          "date": date,
          "work": work,
          "msgType": msgType,
          "content": content,
        },
      );

      final response = await http.post(url, headers: headers, body: body);
      if (response.statusCode == 200) {
        final result = jsonDecode(response.body);
        isLoading = false;

        if (result['resultcode'] == 0) {
// ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Homework added successfully');
        } else {
          // ignore: use_build_context_synchronously
          CommonMethods().showSnackBar(context, 'Something went wrong');
        }
      } else {
        // Handle API error
        print('API Error: ${response.statusCode} - ${response.reasonPhrase}');
      }
      notifyListeners();
    } catch (e) {
      print('Exception :$e');
    }
  }

  String? fileType; //to know the type of file picked IMAGE/PDF.
  String? base64Content; //to store base64 converted string of image file.
  String? base64Pdf; //to storebase64 converted string of pdf file
  File? selectedImage; //to store picked image file.
  String? selectedPdfFile; //to store picked pdf file.
  int? sizeInMegabytes;
  var fileSizeLimit = 1024;
  // ignore: prefer_typing_uninitialized_variables
  var fileSizeInKB;

//below method is for file picking.
  Future<void> pickImageAndSetContent(BuildContext context) async {
    FilePickerResult? result =
        await FilePicker.platform.pickFiles(allowMultiple: false);

    if (result != null) {
      //FilePicker library allows users to select multiple files,
      // .first is used here to work with the first (and possibly the only) selected file.
      PlatformFile file = result.files.first;

      if (file.extension == 'jpg' ||
          file.extension == 'png' ||
          file.extension == 'jpeg') {
        //checking picked file extension for image if it is one of them then set fileType to IMAGE.
        fileType = "IMAGE";
        try {
          final imageFile =
              File(file.path!); //picked image stored in imageFile.

          var s = imageFile.lengthSync(); // returns in bytes

          fileSizeInKB = s / 1024;
          // Convert the KB to MegaBytes (1 MB = 1024 KBytes)
          var fileSizeInMB = fileSizeInKB / 1024;
          print(fileSizeInMB);

          if (fileSizeInKB > fileSizeLimit) {
            print("File size greater than the limit");
          } else {
            print("file can be selected");
          }

          File? compressedImageFile = await compressImage(
              imageFile); //compressing the picked image file.
          /*Uint8List is a type representing an immutable list of 8-bit unsigned 
          integers,often used to store binary data, such as image bytes. */

          Uint8List? compressedImageBytes =
              compressedImageFile?.readAsBytesSync();
          //readAsBytesSync method reads the content of the
          //file synchronously and returns it as a Uint8List.

          if (compressedImageBytes != null) {
            // Convert the image to base64
            base64Content = base64.encode(compressedImageBytes);
            //to send image file to the server

            notifyListeners();
          }

          selectedImage = imageFile;
          notifyListeners(); //to update or notify any change.
        } catch (e) {
          print("Error compressing the image: $e");
        }
      } else if (file.extension == 'pdf') {
        //If the file extension is 'pdf', it sets fileType to "PDF".
        fileType = "PDF";
        try {
          //Create a pdfFile instance of the File class using the file.path.
          final pdfFile = File(file.path!);
          /* Reads the content of the PDF file as bytes using pdfFile.readAsBytes().
           This reads the entire PDF file and returns a list of integers (List<int>) 
           representing the bytes of the PDF. */

          var s = pdfFile.lengthSync(); // returns in bytes

          fileSizeInKB = s / 1024;
          // Convert the KB to MegaBytes (1 MB = 1024 KBytes)
          var fileSizeInMB = fileSizeInKB / 1024;
          print(fileSizeInMB);

          if (fileSizeInKB > fileSizeLimit) {
            print("File size greater than the limit");
          } else {
            print("file can be selected");
          }
          List<int> pdfBytes = await pdfFile.readAsBytes();

          //Converts the PDF bytes to base64 format using base64.encode(pdfBytes)
          //and stores the result in the base64Pdf variable.
          base64Pdf = base64.encode(pdfBytes);
          //Retrieves the filename of the selected PDF file using basename(file.path.toString())
          //and assigns it to selectedPdfFile.
          selectedPdfFile = basename(file.path.toString());
          //Notifies listeners about the changes using
          notifyListeners();
        } catch (e) {
          print("Error converting PDF to base64: $e");
        }
      } else {
        fileType = "UNKNOWN";
        base64Content = null;
      }

      notifyListeners();
    }
  }

//function to compress the image and converting the image to jpg.
  Future<File?> compressImage(File file) async {
    try {
      // getting the temporary directory path using getTemporaryDirectory() from the path_provider library.
      final tempDir = await getTemporaryDirectory();
      final tempFilePath = "${tempDir.path}/temp.jpg";

      /* his method reads the bytes of the image file and decodes them into an Image object. 
     (img.Image?). If the decoding is successful and the image is not null, the process continues.*/
      final img.Image? image = img.decodeImage(file.readAsBytesSync());
      if (image != null) {
        //image is resized to a specified width of 800 pixels using img.copyResize.
        final img.Image resizedImage = img.copyResize(image, width: 800);
        /* img.encodeJpg method is used to encode the resized image
         as a JPEG with a specified quality of 60.The resulting
         compressed image file is returned as a File object. */

        File compressedImageFile = File(tempFilePath)
          ..writeAsBytesSync(img.encodeJpg(resizedImage, quality: 60));

        return compressedImageFile;
      }

      return null;
    } catch (e) {
      print("Error compressing the image: $e");
      return null;
    }
  }

  void savedData() async {
    final pref = await SharedPreferences.getInstance();
    teacherID = pref.getInt('teacherId');
  }
}
