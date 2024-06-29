import 'dart:convert';
import 'dart:io';
import 'package:flutter/cupertino.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../send_message/view_model/send_message_view_model.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/add_homeWork_view_model.dart';

class AddHomeWorkScreen extends StatefulWidget {
  const AddHomeWorkScreen({super.key});

  @override
  State<AddHomeWorkScreen> createState() => _AddHomeWorkScreenState();
}

class _AddHomeWorkScreenState extends State<AddHomeWorkScreen> {
  // isCamera bool is to identify that camera is tap or not.
  bool isCamera = false;
  String base64ImageCamera = '';
  Map<String, dynamic>? singleSelectedClassName;
  Map<String, dynamic>? singleSelectedSectionName;
  // imageCamera is use to store image file captured by camera.
  File? imageCamera;
  TextEditingController msgController = TextEditingController();
  bool addFile = false;
  String? mobno;

  @override
  void initState() {
    super.initState();
    initCall();
    // at initial this methods are called first from different view models class.
    Provider.of<SendMessageViewModel>(context, listen: false).fetchClasses();
    Provider.of<SendMessageViewModel>(context, listen: false).fetchSections();
    Provider.of<HomeworkProvider>(context, listen: false).savedData();
  }

  void initCall() async {
    final pref = await SharedPreferences.getInstance();

    mobno = pref.getString('mobno');
    print(mobno);

    //method called for to fetch teacher information present in MenuViewModel provider class.

    // ignore: use_build_context_synchronously
    final menuProvider = Provider.of<MenuViewModel>(context, listen: false);
    menuProvider.fetchTeacherInfo(mobno.toString());
    if (menuProvider.teacherInfo?.photo != null) {
      menuProvider
          .checkFileExistence(menuProvider.teacherInfo!.photo.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    //mediaquery used for responsive design.
    final size = MediaQuery.of(context).size;
    //provider,addHomeworkProvider,menuProvider provider class initialization at widget building.
    final provider = Provider.of<SendMessageViewModel>(context);
    final addHomeworkProvider = Provider.of<HomeworkProvider>(context);
    final menuProvider = Provider.of<MenuViewModel>(context);
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherContact = teacherInfo?.contactno ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();
    return addHomeworkProvider.isLoading
        ? SizedBox(
            height: size.height,
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Center(
                  child: Container(
                    color: Colors.black,
                    child: Padding(
                      padding: const EdgeInsets.all(15.0),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Text(
                            'Loading....',
                            style: TextStyle(color: Colors.white),
                          ),
                          LoadingAnimationWidget.twistingDots(
                            leftDotColor: const Color(0xFFFAFAFA),
                            rightDotColor: const Color(0xFFEA3799),
                            size: 30,
                          ),
                        ],
                      ),
                    ),
                  ),
                )
              ],
            ),
          )
        : Scaffold(
            appBar: AppBar(
              automaticallyImplyLeading: false,
              backgroundColor: Appcolor.themeColor,
              toolbarHeight: 70,
              titleSpacing: 2,
              elevation: 0,
              title: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  IconButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      icon: const Icon(Icons.arrow_back)),
                  menuProvider.fileExists
                      ? Container(
                          width: 50,
                          height: 50,
                          decoration: const BoxDecoration(
                              shape: BoxShape.circle,
                              color: Appcolor.lightgrey),
                          child: teacherPhoto == null
                              ? ClipOval(
                                  child: Image.asset(
                                    'assets/images/user_profile.png',
                                    fit: BoxFit.cover,
                                  ),
                                ) // Replace with your asset image path
                              : ClipOval(
                                  child: menuProvider.isLoading
                                      ? const Center(
                                          child: CupertinoActivityIndicator(
                                              color: Appcolor.themeColor),
                                        )
                                      : Image.network(
                                          teacherPhoto,
                                          fit: BoxFit.cover,
                                          errorBuilder:
                                              (context, error, stackTrace) {
                                            // Handle network image loading error here
                                            return Image.asset(
                                                'assets/images/user_profile.png'); // Replace with your error placeholder image
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
                          )),
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
                        Padding(
                          padding: const EdgeInsets.only(top: 2.0),
                          child: Text(
                            'Contact: $teacherContact',
                            style: TextStyle(
                                color: Colors.white,
                                overflow: TextOverflow.ellipsis,
                                fontSize: size.width * 0.03,
                                fontWeight: FontWeight.w600),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(
                    width: 5.0,
                  )
                ],
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
            bottomNavigationBar: Row(
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      setState(() {
                        isCamera = false;
                        imageCamera = null;
                        addFile = true;
                        addHomeworkProvider.selectedImage = null;
                        addHomeworkProvider.selectedPdfFile = null;
                        addHomeworkProvider.pickImageAndSetContent(context);
                      });
                    },
                    child: Container(
                      height: size.height * 0.06,
                      color: Appcolor.themeColor,
                      child: const Center(
                          child: Text(
                        'Add File',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                ),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      if (singleSelectedClassName != null &&
                          singleSelectedSectionName != null) {
                        if (singleSelectedClassName!['classId']
                                .toString()
                                .isNotEmpty &&
                            singleSelectedSectionName!['sectionId']
                                .toString()
                                .isNotEmpty) {
                          if (isCamera == true) {
                            addHomeworkProvider.addHomework(
                                context,
                                singleSelectedClassName!['classId'],
                                singleSelectedSectionName!['sectionId'],
                                addHomeworkProvider.teacherID!,
                                DateTime.now().toString(),
                                msgController.text,
                                "IMAGE",
                                base64ImageCamera);
                          } else if (addFile == true) {
                            if (addHomeworkProvider.fileSizeInKB >
                                addHomeworkProvider.fileSizeLimit) {
                              CommonMethods().showSnackBar(context,
                                  'Please select file size not more than 1 MB');
                            } else {
                              addHomeworkProvider.addHomework(
                                  context,
                                  singleSelectedClassName!['classId'],
                                  singleSelectedSectionName!['sectionId'],
                                  addHomeworkProvider.teacherID!,
                                  DateTime.now().toString(),
                                  msgController.text,
                                  addHomeworkProvider.fileType.toString(),
                                  addHomeworkProvider.fileType == "IMAGE"
                                      ? addHomeworkProvider.base64Content
                                          .toString()
                                      : addHomeworkProvider.fileType == "PDF"
                                          ? addHomeworkProvider.base64Pdf
                                              .toString()
                                          : '');
                            }
                          } else {
                            addHomeworkProvider.addHomework(
                                context,
                                singleSelectedClassName!['classId'],
                                singleSelectedSectionName!['sectionId'],
                                addHomeworkProvider.teacherID!,
                                DateTime.now().toString(),
                                msgController.text,
                                "TEXT",
                                "");
                          }

                          isCamera = false;
                          addFile = false;
                          base64ImageCamera = '';
                          singleSelectedClassName = null;
                          singleSelectedSectionName = null;
                          imageCamera = null;
                          addHomeworkProvider.selectedImage = null;
                          addHomeworkProvider.selectedPdfFile = null;
                          msgController.clear();
                        } else {
                          CommonMethods()
                              .showSnackBar(context, "Fields can't be empty");
                        }
                      } else {
                        CommonMethods()
                            .showSnackBar(context, "Fields can't be empty");
                      }
                    },
                    child: Container(
                      height: size.height * 0.06,
                      color: Colors.green,
                      child: const Center(
                          child: Text(
                        'Submit',
                        style: TextStyle(
                            color: Colors.white,
                            fontSize: 16,
                            fontWeight: FontWeight.bold),
                      )),
                    ),
                  ),
                )
              ],
            ),
            body: SingleChildScrollView(
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 15.0),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: ButtonTheme(
                        alignedDropdown: true,
                        child: DropdownButtonFormField<Map<String, dynamic>>(
                          decoration: InputDecoration(
                            labelText: 'Select Class',
                            labelStyle:
                                const TextStyle(color: Appcolor.themeColor),
                            enabledBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Appcolor.themeColor),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                            focusedBorder: OutlineInputBorder(
                              borderSide:
                                  const BorderSide(color: Appcolor.themeColor),
                              borderRadius: BorderRadius.circular(5.0),
                            ),
                          ),
                          value: singleSelectedClassName,
                          items: provider.classesData
                              .map<DropdownMenuItem<Map<String, dynamic>>>(
                            (classData) {
                              return DropdownMenuItem<Map<String, dynamic>>(
                                value: classData,
                                child: Text(
                                  classData['className'],
                                  style: const TextStyle(
                                      fontSize: 14, color: Colors.black),
                                ),
                              );
                            },
                          ).toList(),
                          onChanged: (value) {
                            setState(() {
                              if (value != null) {
                                singleSelectedClassName = value;
                              } else {
                                if (kDebugMode) {
                                  print(value);
                                }
                              }
                            });
                          },
                        ),
                      ),
                    ),
                    const SizedBox(
                      height: 10,
                    ),
                    ButtonTheme(
                      alignedDropdown: true,
                      child: DropdownButtonFormField<Map<String, dynamic>>(
                        decoration: InputDecoration(
                          labelText: 'Select Section',
                          labelStyle:
                              const TextStyle(color: Appcolor.themeColor),
                          enabledBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Appcolor.themeColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                          focusedBorder: OutlineInputBorder(
                            borderSide:
                                const BorderSide(color: Appcolor.themeColor),
                            borderRadius: BorderRadius.circular(5.0),
                          ),
                        ),
                        value: singleSelectedSectionName,
                        items: provider.sectionData
                            .map<DropdownMenuItem<Map<String, dynamic>>>(
                          (sectionData) {
                            return DropdownMenuItem<Map<String, dynamic>>(
                              value: sectionData,
                              child: Text(
                                sectionData['sectionName'],
                                style: const TextStyle(fontSize: 14),
                              ),
                            );
                          },
                        ).toList(),
                        onChanged: (value) {
                          setState(() {
                            if (value != null) {
                              singleSelectedSectionName = value;
                            }
                          });
                        },
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(top: 20.0),
                      child: Container(
                        decoration: BoxDecoration(
                            color: const Color.fromARGB(193, 255, 255, 255),
                            border: Border.all(color: Colors.blueGrey),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextField(
                          cursorColor: Appcolor.themeColor,
                          cursorWidth: 1,
                          controller: msgController,
                          maxLines: null,
                          style: const TextStyle(fontSize: 12),
                          decoration: const InputDecoration(
                            hintText: "Enter text here...",
                            hintStyle: TextStyle(
                              fontSize: 12,
                            ),
                            contentPadding: EdgeInsets.only(
                                left: 25, right: 25.0, top: 15, bottom: 15),
                            border: InputBorder.none,
                          ),
                        ),
                      ),
                    ),
                    addHomeworkProvider.fileType == "PDF" && isCamera == false
                        ? SizedBox(
                            height: 300,
                            width: 300,
                            child: Center(
                                child: addHomeworkProvider.selectedPdfFile !=
                                        null
                                    ? Container(
                                        decoration: BoxDecoration(
                                            borderRadius:
                                                BorderRadius.circular(10),
                                            color: Colors.grey.shade200),
                                        child: Padding(
                                          padding: const EdgeInsets.symmetric(
                                              vertical: 10.0),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.center,
                                            children: [
                                              const Icon(
                                                Icons.picture_as_pdf_rounded,
                                                color: Colors.red,
                                                size: 30,
                                              ),
                                              const SizedBox(
                                                width: 10,
                                              ),
                                              Text(addHomeworkProvider
                                                  .selectedPdfFile
                                                  .toString()),
                                            ],
                                          ),
                                        ),
                                      )
                                    : null),
                          )
                        : addHomeworkProvider.selectedImage != null ||
                                imageCamera != null
                            ? Padding(
                                padding: const EdgeInsets.only(top: 15.0),
                                child: Image.file(
                                  imageCamera ??
                                      addHomeworkProvider.selectedImage!,
                                  height: 300,
                                  width: 300,
                                ),
                              )
                            : Container(),
                    addHomeworkProvider.selectedImage != null ||
                            imageCamera != null
                        ? const SizedBox(
                            height: 30,
                          )
                        : const SizedBox.shrink(),
                  ],
                ),
              ),
            ),
            floatingActionButton: Padding(
              padding: const EdgeInsets.only(bottom: 10.0),
              child: SizedBox(
                height: 50,
                child: FloatingActionButton(
                  onPressed: () async {
                    setState(() {
                      isCamera = true;
                      addFile = false;
                      addHomeworkProvider.selectedImage = null;
                    });
                    try {
                      //create an ImagePicker instance named picker from ImagePicker class from image_picker library.
                      final picker = ImagePicker();
                      //captures an image from the device's camera and stored it in pickedFileCamera.
                      final pickedFileCamera =
                          await picker.pickImage(source: ImageSource.camera);

                      if (pickedFileCamera != null) {
                        //calls the compressImage method provided by the provider
                        //object and passes the captured image's file path as a File object.
                        //this compressImage method is  to compress the image and return the compressed image as a File object.
                        File? compressedImageFile = await provider
                            .compressImage(File(pickedFileCamera.path));
                        if (compressedImageFile != null) {
                          //reads the bytes of the compressed image using compressedImageFile.readAsBytesSync()
                          //and stores them in the compressedImageBytes variable.
                          Uint8List? compressedImageBytes =
                              compressedImageFile.readAsBytesSync();
                          // converts the image's bytes to base64 format using base64Encode(compressedImageBytes)
                          //and stores the result in the base64ImageCamera variable.
                          base64ImageCamera =
                              base64Encode(compressedImageBytes);
                        }
                        //the file path or information about the image that was captured using the camera.
                        final pickedImageFile = File(pickedFileCamera.path);
                        setState(() {
                          //imageCamera variable is updated with the pickedImageFile
                          imageCamera = pickedImageFile;
                        });
                      }
                    } catch (e) {
                      print("Error picking image: $e");
                    }
                  },
                  backgroundColor: Appcolor.themeColor,
                  child: const Icon(Icons.camera_alt),
                ),
              ),
            ),
          );
  }
}
