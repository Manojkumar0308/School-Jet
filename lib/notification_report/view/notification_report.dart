import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:provider/provider.dart';
import '../../utils/appcolors.dart';
import '../../utils/common_methods.dart';
import '../view_model/view_model.dart';
import 'package:intl/intl.dart';

class NotificationReportScreen extends StatefulWidget {
  const NotificationReportScreen({super.key});

  @override
  State<NotificationReportScreen> createState() =>
      _NotificationReportScreenState();
}

class _NotificationReportScreenState extends State<NotificationReportScreen> {
  int page = 1;
  bool noMoreData = false;

  @override
  void initState() {
    super.initState();
    Provider.of<NotificationReportProvider>(context, listen: false)
        .fetchNotificationReports(page);
  }

  void _fetchPreviousPage() {
    if (page > 1) {
      page--;
      noMoreData = false; // Reset the flag when going to the previous page
      Provider.of<NotificationReportProvider>(context, listen: false)
          .fetchNotificationReports(page);
    }
  }

  void _fetchNextPage() async {
    page++;
    final provider =
        Provider.of<NotificationReportProvider>(context, listen: false);
    await provider.fetchNotificationReports(page);

    if (provider.notificationReports.isEmpty) {
      // If there is no data on the next page, stop incrementing page number
      page--;
      noMoreData = true;
    } else {
      // Data is available on the next page, enable the "Next" button
      noMoreData = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    final notificationProvider =
        Provider.of<NotificationReportProvider>(context);
    final notificationReports = notificationProvider.notificationReports;

    return Scaffold(
      body: notificationProvider.isLoading
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
          : notificationProvider.notificationReports.isEmpty
              ? const Center(
                  child: Text('No Reports Found'),
                )
              : ListView.builder(
                  itemCount: notificationReports.length,
                  itemBuilder: (context, index) {
                    final report = notificationReports[index];
                    final isImageType = report.msgType == 'IMAGE';
                    final isMsgType = report.msgType == 'MSG';
                    final formattedDate =
                        DateFormat('MM/dd/yyyy').format(report.msgDate!);

                    return Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 15.0, vertical: 10),
                      child: Column(
                        mainAxisAlignment: isImageType
                            ? MainAxisAlignment.end
                            : MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          if (isImageType)
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    SizedBox(
                                      width: 200,
                                      height: 200,
                                      child: Image.network(
                                          'http://${report.msgContent}'),
                                    ),
                                    const SizedBox(
                                      height: 2,
                                    ),
                                    Text(
                                      'Date: $formattedDate'.toString(),
                                      style: const TextStyle(
                                          color: Colors.blueGrey, fontSize: 10),
                                    ),
                                    Text(
                                      'TYPE: ${report.msgGroup}',
                                      style: const TextStyle(
                                          color: Colors.blueGrey, fontSize: 10),
                                    ),
                                    Text(
                                      'Time: ${CommonMethods().notificationReportTime(report.msgDate.toString())}',
                                      style: const TextStyle(
                                          color: Colors.blueGrey, fontSize: 10),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          const SizedBox(width: 8),
                          if (isMsgType)
                            Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                report.msgContent != null
                                    ? Container(
                                        decoration: const BoxDecoration(
                                            gradient: Appcolor.blueGradient,
                                            borderRadius: BorderRadius.only(
                                                topRight: Radius.circular(20),
                                                bottomRight:
                                                    Radius.circular(20),
                                                bottomLeft:
                                                    Radius.circular(20))),
                                        child: Padding(
                                          padding: const EdgeInsets.all(10.0),
                                          child: Text(
                                            report.msgContent!,
                                            style: const TextStyle(
                                                color: Colors.white),
                                          ),
                                        ),
                                      )
                                    : const SizedBox.shrink(),
                                const SizedBox(
                                  height: 2,
                                ),
                                Text(
                                  'Date: $formattedDate'.toString(),
                                  style: const TextStyle(
                                      color: Colors.blueGrey, fontSize: 10),
                                ),
                                Text(
                                  'TYPE: ${report.msgGroup}',
                                  style: const TextStyle(
                                      color: Colors.blueGrey, fontSize: 10),
                                ),
                                Text(
                                  'Time: ${CommonMethods().notificationReportTime(report.msgDate.toString())}',
                                  style: const TextStyle(
                                      color: Colors.blueGrey, fontSize: 10),
                                ),
                              ],
                            ),
                          const SizedBox(width: 8),
                        ],
                      ),
                    );
                  },
                ),
      bottomNavigationBar: Row(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        children: [
          CupertinoButton(
            onPressed: _fetchPreviousPage,
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.back,
              color: Appcolor.themeColor,
            ),
          ),
          Text('Page $page'),
          CupertinoButton(
            onPressed: noMoreData ? null : _fetchNextPage,
            padding: EdgeInsets.zero,
            child: const Icon(
              CupertinoIcons.forward,
              color: Appcolor.themeColor,
            ),
          ),
        ],
      ),
    );
  }
}
