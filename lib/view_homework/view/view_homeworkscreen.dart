import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';

import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../host_service/host_services.dart';
import '../../menu/view_model/menu_view_model.dart';
import '../../notification/view/show_image.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/view_homework_view_model.dart';

class ViewHomeWorkScreen extends StatefulWidget {
  const ViewHomeWorkScreen({super.key});

  @override
  State<ViewHomeWorkScreen> createState() => _ViewHomeWorkScreenState();
}

class _ViewHomeWorkScreenState extends State<ViewHomeWorkScreen> {
  HostService hostService = HostService();
  String? url;
  @override
  void initState() {
    super.initState();
    CommonMethods().initCall(context);

    data();
  }

  void data() async {
    final pref = await SharedPreferences.getInstance();
    if (pref.getInt('teacherId') != null) {
      // ignore: use_build_context_synchronously
      Provider.of<ViewHomeworkProvider>(context, listen: false)
          .fetchHomeworkData(pref.getInt('teacherId')!);
    } else {
      print('id is null');
    }
  }

  @override
  Widget build(BuildContext context) {
    final viewHomeworkProvider = Provider.of<ViewHomeworkProvider>(context);
    final menuProvider = Provider.of<MenuViewModel>(context);
    final size = MediaQuery.of(context).size;
    final teacherInfo = menuProvider.teacherInfo;
    final teacherName = teacherInfo?.tname ?? 'N/A';
    final teacherEmail = teacherInfo?.email ?? 'N/A';
    final teacherContact = teacherInfo?.contactno ?? 'N/A';
    final teacherPhoto = teacherInfo?.photo.toString();
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Appcolor.themeColor,
        toolbarHeight: 70,
        titleSpacing: 0,
        elevation: 0,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            menuProvider.fileExists
                ? Container(
                    width: 50,
                    height: 50,
                    decoration: const BoxDecoration(
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
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
                                    errorBuilder: (context, error, stackTrace) {
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
                        shape: BoxShape.circle, color: Appcolor.lightgrey),
                    child: ClipOval(
                      child: Image.asset(
                        'assets/images/user_profile.png',
                        fit: BoxFit.cover,
                      ),
                    )),
            Padding(
              padding: const EdgeInsets.only(left: 7.0),
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
              width: 5,
            ),
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
      body: viewHomeworkProvider.isLoading
          ? Center(
              child: Container(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(20),
                  color: Colors.black,
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: 10.0, vertical: 5.0),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        'Loading....',
                        style: TextStyle(
                            color: Colors.white, fontSize: size.width * 0.03),
                      ),
                      LoadingAnimationWidget.twistingDots(
                        leftDotColor: const Color(0xFFFAFAFA),
                        rightDotColor: const Color(0xFFEA3799),
                        size: size.width * 0.05,
                      ),
                    ],
                  ),
                ),
              ),
            )
          : Column(
              children: [
                Flexible(
                  child: ListView.builder(
                    shrinkWrap: true,
                    itemCount: viewHomeworkProvider.homeworkData.length,
                    itemBuilder: (_, index) {
                      return InkWell(
                        onTap: () {
                          if (viewHomeworkProvider
                                      .homeworkData[index].filepath ==
                                  null ||
                              viewHomeworkProvider
                                  .homeworkData[index].filepath!.isEmpty) {
                            print("Homework filepath is null or empty");
                            return;
                          }
                          if (viewHomeworkProvider
                                      .homeworkData[index].filepath !=
                                  null ||
                              viewHomeworkProvider.homeworkData[index].filepath
                                  .toString()
                                  .isNotEmpty) {
                            url = viewHomeworkProvider
                                    .homeworkData[index].filepath
                                    .toString()
                                    .contains('demoapp.citronsoftwares.com')
                                ? 'http://${viewHomeworkProvider.homeworkData[index].filepath}'
                                : 'http://${viewHomeworkProvider.homeworkData[index].filepath}';
                            print('url is $url');
                          }
                          if (viewHomeworkProvider.homeworkData[index].filepath
                                  .toString()
                                  .isNotEmpty ||
                              viewHomeworkProvider
                                      .homeworkData[index].filepath !=
                                  null) {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) =>
                                    ImageFullScreen(imageUrl: url.toString()),
                              ),
                            );
                          }
                        },
                        child: Padding(
                          padding: const EdgeInsets.only(
                              top: 10.0, left: 15.0, right: 15.0),
                          child: Card(
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                            child: Container(
                              width: double.infinity,
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                              ),
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10.0),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    Image.asset(
                                      'assets/images/book.png',
                                      height: 40,
                                      width: 60,
                                    ),
                                    const SizedBox(
                                      width: 10,
                                    ),
                                    Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            vertical: 10.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text(
                                                  'Work: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Expanded(
                                                  child: Text(
                                                    viewHomeworkProvider
                                                        .homeworkData[index]
                                                        .work
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color: Colors.blueGrey),
                                                  ),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Class: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                    viewHomeworkProvider
                                                        .homeworkData[index]
                                                        .clas
                                                        .toString(),
                                                    style: const TextStyle(
                                                        fontSize: 14,
                                                        color:
                                                            Colors.blueGrey)),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Section: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  viewHomeworkProvider
                                                      .homeworkData[index]
                                                      .section
                                                      .toString(),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.blueGrey),
                                                ),
                                              ],
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Date: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  CommonMethods()
                                                      .teachersHomeworkreportDate(
                                                          viewHomeworkProvider
                                                              .homeworkData[
                                                                  index]
                                                              .date
                                                              .toString()),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.blueGrey),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 2,
                                            ),
                                            Row(
                                              children: [
                                                const Text(
                                                  'Time: ',
                                                  style: TextStyle(
                                                      fontWeight:
                                                          FontWeight.w500),
                                                ),
                                                Text(
                                                  CommonMethods()
                                                      .notificationReportTime(
                                                          viewHomeworkProvider
                                                              .homeworkData[
                                                                  index]
                                                              .date
                                                              .toString()),
                                                  style: const TextStyle(
                                                      fontSize: 14,
                                                      color: Colors.blueGrey),
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
    );
  }
}
