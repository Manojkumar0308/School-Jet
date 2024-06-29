import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:loading_animation_widget/loading_animation_widget.dart';
import 'package:pie_chart/pie_chart.dart';
import 'package:provider/provider.dart';

import '../../utils/appcolors.dart';
import '../model/model.dart';
import '../view_model/view_model.dart';

class AdminSmsReportScreen extends StatefulWidget {
  const AdminSmsReportScreen({super.key});

  @override
  State<AdminSmsReportScreen> createState() => _AdminSmsReportScreenState();
}

class _AdminSmsReportScreenState extends State<AdminSmsReportScreen> {
  TextEditingController fromDateController = TextEditingController();
  TextEditingController toDateController = TextEditingController();
  TextEditingController searchController = TextEditingController();
  String? formattedToDate;
  String? formattedFromDate;
  DateTime? picked;
  bool isVisible = false;
  bool searchVisible = false;
  bool tapsearch = false;
  bool sent = false;
  bool delivered = false;
  bool undelivered = false;
  List<SmsMessage> filteredList = [];
  DateTime fromDate = DateTime.now();
  DateTime toDate = DateTime(DateTime.now().year, DateTime.now().month + 1, 0);
  Future<void> _selectFromDate(BuildContext context) async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // firstDate: DateTime(fromDate.year, fromDate.month, 1),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );
    if (picked != null && picked != fromDate) {
      setState(() {
        fromDate = picked!;
        formattedFromDate = DateFormat('yyyyMMdd000000').format(fromDate);
        Provider.of<AdminSmsReport>(context, listen: false)
            .fetchSmsMessagesReport(
                formattedFromDate.toString(), formattedToDate.toString());
        print('if to date selected only:$formattedToDate');
        print('if from date selected only:$formattedFromDate');

        fromDateController.text =
            'From: ${DateFormat.yMMMMd().format(fromDate)}';
        print('Manoj kumar');
        print(fromDateController.text);
        Provider.of<AdminSmsReport>(context, listen: false)
            .fetchSmsDeliverySummary(
                formattedFromDate.toString(), formattedToDate.toString());
      });
    }
  }

  Future<void> _selectToDate(BuildContext context) async {
    picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      // firstDate: DateTime(fromDate.year, fromDate.month, 1),
      firstDate: DateTime(2000, 1, 1),
      lastDate: DateTime(2100, 12, 31),
      builder: (context, child) {
        return Theme(
          data: ThemeData.dark(),
          child: child!,
        );
      },
    );

    if (picked != null && picked != toDate) {
      setState(() {
        toDate = picked!;
        formattedToDate = DateFormat('yyyyMMdd000000').format(toDate);

        print(formattedToDate);
        Provider.of<AdminSmsReport>(context, listen: false)
            .fetchSmsMessagesReport(
                formattedFromDate.toString(), formattedToDate.toString());
        toDateController.text = 'To: ${DateFormat.yMMMMd().format(toDate)}';
        Provider.of<AdminSmsReport>(context, listen: false)
            .fetchSmsDeliverySummary(
                formattedFromDate.toString(), formattedToDate.toString());
      });
      // ignore: use_build_context_synchronously
    }
  }

  @override
  void initState() {
    super.initState();

    final smsReportProvider =
        Provider.of<AdminSmsReport>(context, listen: false);
    if (picked == null) {
      print('from date is :$fromDate');
      formattedFromDate = DateFormat('yyyyMMdd000000').format(fromDate);
      formattedToDate = DateFormat('yyyyMMdd000000').format(toDate);
      print('$formattedFromDate+$formattedToDate');
      print(picked);
      smsReportProvider.fetchSmsDeliverySummary(
          formattedFromDate.toString(), formattedToDate.toString());

      // smsReportProvider.fetchSmsMessagesReport(
      //     formattedFromDate.toString(), formattedToDate.toString());
    }
  }

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    final adminSmsReportProvider = Provider.of<AdminSmsReport>(context);
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 2,
        title: tapsearch
            ? Container(
                height: size.height * 0.055,
                decoration: BoxDecoration(
                    color: Colors.white,
                    border: Border.all(color: Colors.black, width: 0.5),
                    borderRadius: BorderRadius.circular(5)),
                child: TextField(
                  keyboardType: TextInputType.phone,
                  cursorColor: Appcolor.themeColor,
                  cursorWidth: 1,
                  controller: searchController,
                  onChanged: (value) {
                    setState(() {
                      if (value.isNotEmpty) {
                        searchVisible = true;
                        isVisible = false;
                        // sent = false;
                        // delivered = false;
                        // undelivered = false;
                      } else {
                        setState(() {
                          searchVisible = false;
                          if (sent == true) {
                            delivered = false;
                            undelivered = false;
                            isVisible = false;
                          } else if (delivered == true) {
                            sent = false;
                            undelivered = false;
                            isVisible = false;
                          } else if (undelivered == true) {
                            delivered = false;
                            sent = false;
                            isVisible = false;
                          } else if (isVisible == true) {
                            isVisible = true;
                            delivered = false;
                            undelivered = false;
                            sent = false;
                          } else {
                            isVisible = true;
                            delivered = false;
                            undelivered = false;
                            sent = false;
                          }
                        });
                      }
                    });
                    print('value is: $value');
                    print(
                        'smsMessage List:${adminSmsReportProvider.smsMessages}');
                    // Clear the previous filteredList
                    filteredList.clear();

                    // Filter messages based on mobileNumber

                    if (sent == true) {
                      filteredList.addAll(adminSmsReportProvider.sentMessages
                          .where((message) =>
                              message.mobileNumber.contains(value)));
                    } else if (delivered == true) {
                      filteredList.addAll(adminSmsReportProvider
                          .deliveredMessages
                          .where((message) =>
                              message.mobileNumber.contains(value)));
                    } else if (undelivered == true) {
                      filteredList.addAll(adminSmsReportProvider
                          .undeliveredMessages
                          .where((message) =>
                              message.mobileNumber.contains(value)));
                    } else {
                      filteredList.addAll(adminSmsReportProvider.smsMessages
                          .where((message) =>
                              message.mobileNumber.contains(value)));
                    }

                    print('filteredList is: $filteredList');
                  },
                  style: const TextStyle(fontSize: 14),
                  decoration: const InputDecoration(
                    hintText: 'Search mobile number',
                    hintStyle: TextStyle(fontSize: 12),
                    border: InputBorder.none,
                    contentPadding:
                        EdgeInsets.only(left: 8, top: 0, bottom: 0, right: 5),
                  ),
                ),
              )
            : const Text(
                'SMS Summary',
                style: TextStyle(fontSize: 16),
              ),
        backgroundColor: Appcolor.themeColor,
        actions: [
          tapsearch
              ? const SizedBox.shrink()
              : Padding(
                  padding: const EdgeInsets.only(right: 10.0),
                  child: Center(
                      child: Text(
                    'Bal: ${adminSmsReportProvider.summary?.balance_sms ?? '0'.toString()}',
                    style: const TextStyle(fontWeight: FontWeight.w500),
                  )),
                ),
          IconButton(
              onPressed: () {
                setState(() {
                  // tapsearch = true;
                  tapsearch = !tapsearch;
                  isVisible = false;
                  sent = false;
                  delivered = false;
                  undelivered = false;
                });
              },
              icon: const Icon(Icons.search))
        ],
      ),
      body: Column(
        children: [
          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'From: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextField(
                          controller: TextEditingController(
                            text: DateFormat.yMMMMd().format(fromDate),
                          ),
                          onTap: () {
                            setState(() {
                              isVisible = true;
                              searchVisible = false;
                              sent = false;
                              delivered = false;
                              undelivered = false;
                            });
                            _selectFromDate(context);
                            searchController.clear();
                          },
                          readOnly: true,
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              hintText: DateFormat.yMMMMd().format(fromDate),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                Expanded(
                  flex: 5,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Text(
                        'To: ',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                      const SizedBox(
                        height: 2,
                      ),
                      Container(
                        decoration: BoxDecoration(
                            border: Border.all(color: Colors.grey),
                            borderRadius: BorderRadius.circular(5)),
                        child: TextField(
                          controller: TextEditingController(
                            text: DateFormat.yMMMMd().format(toDate),
                          ),
                          onTap: () {
                            setState(() {
                              isVisible = true;
                              searchVisible = false;
                              sent = false;
                              delivered = false;
                              undelivered = false;
                            });

                            _selectToDate(context);
                            searchController.clear();
                          },
                          readOnly: true,
                          decoration: InputDecoration(
                              contentPadding:
                                  const EdgeInsets.symmetric(horizontal: 10),
                              hintText: DateFormat.yMMMMd().format(toDate),
                              border: InputBorder.none),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // const SizedBox(
          //   height: 20,
          // ),
          adminSmsReportProvider.summaryChart.isNotEmpty
              ? SizedBox(
                  child: PieChart(
                      chartRadius: 160,
                      colorList: const [
                        Color.fromARGB(255, 10, 176, 29),
                        Color.fromARGB(255, 210, 20, 7),
                        Colors.purple,
                        Colors.blue,
                        Colors.amber
                      ],
                      chartValuesOptions: const ChartValuesOptions(
                          chartValueStyle: TextStyle(
                              fontSize: 10,
                              color: Colors.white,
                              fontWeight: FontWeight.bold),
                          chartValueBackgroundColor: Colors.transparent,
                          showChartValuesInPercentage: true),
                      dataMap: adminSmsReportProvider.summaryChart),
                )
              : const SizedBox.shrink(),
          TextButton(
            child: const Text('View Report'),
            onPressed: () {
              searchController.clear();
              setState(() {
                isVisible = true;
                searchVisible = false;
                sent = false;
                delivered = false;
                undelivered = false;
                if (picked == null) {
                  adminSmsReportProvider.fetchSmsMessagesReport(
                      formattedFromDate.toString(), formattedToDate.toString());
                }
                // adminSmsReportProvider.fetchSmsMessagesReport(fdate, tdate)
              });
            },
          ),

          const SizedBox(
            height: 20,
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15.0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: InkWell(
                    onTap: () {
                      searchController.clear();
                      setState(() {
                        searchVisible = false;
                        sent = true;
                        delivered = false;
                        undelivered = false;
                        isVisible = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: Colors.deepPurpleAccent),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                'Sent',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                adminSmsReportProvider.summary?.nsmssent
                                        .toString() ??
                                    'N/A',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      searchController.clear();
                      setState(() {
                        searchVisible = false;
                        sent = false;
                        delivered = true;
                        undelivered = false;
                        isVisible = false;
                      });
                    },
                    child: Container(
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(255, 10, 176, 29)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                'Delivered',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                adminSmsReportProvider.summary?.nsmsdelivered
                                        .toString() ??
                                    'N/A',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: InkWell(
                    onTap: () {
                      searchController.clear();
                      setState(() {
                        searchVisible = false;
                        sent = false;
                        delivered = false;
                        undelivered = true;
                        isVisible = false;
                      });
                    },
                    child: Container(
                      // width: size.width * 0.4,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(5),
                          color: const Color.fromARGB(255, 210, 20, 7)),
                      child: Padding(
                        padding: const EdgeInsets.all(12.0),
                        child: Center(
                          child: Column(
                            children: [
                              const Text(
                                'Undelivered',
                                style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                              const SizedBox(
                                height: 2,
                              ),
                              Text(
                                adminSmsReportProvider.summary?.nsmsnotdelivered
                                        .toString() ??
                                    'N/A',
                                style: const TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 14),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          const SizedBox(
            height: 20,
          ),
          adminSmsReportProvider.isLoading
              ? Center(
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
              : searchVisible
                  ? Expanded(
                      child: Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 15.0),
                      child: ListView.builder(
                        physics: const BouncingScrollPhysics(),
                        shrinkWrap: true,
                        itemCount: filteredList.length,
                        itemBuilder: (BuildContext context, int index) {
                          return Column(
                            mainAxisAlignment: MainAxisAlignment.start,
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const SizedBox(
                                height: 30,
                              ),
                              Text(
                                'Date: ${DateFormat.yMMMMd().format(filteredList[index].sentDate)}',
                                style: const TextStyle(
                                    fontSize: 16, fontWeight: FontWeight.bold),
                              ),
                              Column(
                                children: [
                                  Padding(
                                    padding: const EdgeInsets.only(
                                        top: 10.0, bottom: 5),
                                    child: Container(
                                      decoration: BoxDecoration(
                                          borderRadius:
                                              BorderRadius.circular(10),
                                          color: Colors.grey.shade200),
                                      child: Padding(
                                        padding: const EdgeInsets.all(15.0),
                                        child: Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('Status : '),
                                                Text(
                                                  filteredList[index].status,
                                                  style: TextStyle(
                                                      color: filteredList[index]
                                                                  .status ==
                                                              "SENT"
                                                          ? Colors
                                                              .deepPurpleAccent
                                                          : filteredList[index]
                                                                      .status ==
                                                                  "Delivered"
                                                              ? const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  10,
                                                                  176,
                                                                  29)
                                                              : const Color
                                                                      .fromARGB(
                                                                  255,
                                                                  210,
                                                                  20,
                                                                  7),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text("Msg : "),
                                                Expanded(
                                                    child: Text(
                                                        filteredList[index]
                                                            .smsStr))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                "Sent To : ${filteredList[index].mobileNumber}"),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ),
                                ],
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                            ],
                          );
                        },
                      ),
                    ))
                  : adminSmsReportProvider.sortedGroups.isNotEmpty &&
                          isVisible == true
                      ? Expanded(
                          child: Padding(
                            padding:
                                const EdgeInsets.symmetric(horizontal: 15.0),
                            child: ListView.builder(
                              physics: const BouncingScrollPhysics(),
                              shrinkWrap: true,
                              itemCount:
                                  adminSmsReportProvider.sortedGroups.length,
                              itemBuilder: (context, index) {
                                var group =
                                    adminSmsReportProvider.sortedGroups[index];
                                return Column(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(
                                      height: 30,
                                    ),
                                    Text(
                                      'Date: ${DateFormat.yMMMMd().format(group.key)}',
                                      style: const TextStyle(
                                          fontSize: 16,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Column(
                                      children: group.value.map((message) {
                                        return Padding(
                                          padding: const EdgeInsets.only(
                                              top: 10.0, bottom: 5),
                                          child: Container(
                                              decoration: BoxDecoration(
                                                  borderRadius:
                                                      BorderRadius.circular(10),
                                                  color: Colors.grey.shade200),
                                              child: Padding(
                                                padding:
                                                    const EdgeInsets.all(15.0),
                                                child: Column(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    Row(
                                                      mainAxisSize:
                                                          MainAxisSize.min,
                                                      children: [
                                                        const Text('Status : '),
                                                        Text(
                                                          message.status,
                                                          style: TextStyle(
                                                              color: message
                                                                          .status ==
                                                                      "SENT"
                                                                  ? Colors
                                                                      .deepPurpleAccent
                                                                  : message.status ==
                                                                          "Delivered"
                                                                      ? const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          10,
                                                                          176,
                                                                          29)
                                                                      : const Color
                                                                              .fromARGB(
                                                                          255,
                                                                          210,
                                                                          20,
                                                                          7),
                                                              fontWeight:
                                                                  FontWeight
                                                                      .w600),
                                                        ),
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Row(
                                                      mainAxisAlignment:
                                                          MainAxisAlignment
                                                              .start,
                                                      crossAxisAlignment:
                                                          CrossAxisAlignment
                                                              .start,
                                                      children: [
                                                        const Text("Msg : "),
                                                        Expanded(
                                                            child: Text(
                                                                message.smsStr))
                                                      ],
                                                    ),
                                                    const SizedBox(
                                                      height: 5,
                                                    ),
                                                    Text(
                                                        "Sent To : ${message.mobileNumber}"),
                                                  ],
                                                ),
                                              )),
                                        );
                                      }).toList(),
                                    ),
                                    const SizedBox(
                                      height: 10,
                                    ),
                                  ],
                                );
                              },
                            ),
                          ),
                        )
                      : adminSmsReportProvider.sentMessages.isNotEmpty &&
                              sent == true
                          ? Expanded(
                              child: Padding(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 15.0),
                                child: ListView.builder(
                                  physics: const BouncingScrollPhysics(),
                                  shrinkWrap: true,
                                  itemCount: adminSmsReportProvider
                                      .sentMessages.length,
                                  itemBuilder: (context, index) {
                                    var sentMessages = adminSmsReportProvider
                                        .sentMessages[index];
                                    return Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        const SizedBox(
                                          height: 30,
                                        ),
                                        Text(
                                          'Date: ${DateFormat.yMMMMd().format(sentMessages.sentDate)}',
                                          style: const TextStyle(
                                              fontSize: 16,
                                              fontWeight: FontWeight.bold),
                                        ),
                                        Row(
                                          mainAxisSize: MainAxisSize.min,
                                          children: [
                                            const Text('Status : '),
                                            Text(
                                              sentMessages.status,
                                              style: const TextStyle(
                                                  color:
                                                      Colors.deepPurpleAccent,
                                                  fontWeight: FontWeight.w600),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const Text("Msg : "),
                                            Expanded(
                                                child:
                                                    Text(sentMessages.smsStr))
                                          ],
                                        ),
                                        const SizedBox(
                                          height: 5,
                                        ),
                                        Text(
                                            "Sent To : ${sentMessages.mobileNumber}"),
                                        const SizedBox(
                                          height: 10,
                                        ),
                                      ],
                                    );
                                  },
                                ),
                              ),
                            )
                          : adminSmsReportProvider
                                      .deliveredMessages.isNotEmpty &&
                                  delivered == true
                              ? Expanded(
                                  child: Padding(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 15.0),
                                    child: ListView.builder(
                                      physics: const BouncingScrollPhysics(),
                                      shrinkWrap: true,
                                      itemCount: adminSmsReportProvider
                                          .deliveredMessages.length,
                                      itemBuilder: (context, index) {
                                        var deliveredMessages =
                                            adminSmsReportProvider
                                                .deliveredMessages[index];
                                        return Column(
                                          mainAxisAlignment:
                                              MainAxisAlignment.start,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            const SizedBox(
                                              height: 30,
                                            ),
                                            Text(
                                              'Date: ${DateFormat.yMMMMd().format(deliveredMessages.sentDate)}',
                                              style: const TextStyle(
                                                  fontSize: 16,
                                                  fontWeight: FontWeight.bold),
                                            ),
                                            Row(
                                              mainAxisSize: MainAxisSize.min,
                                              children: [
                                                const Text('Status : '),
                                                Text(
                                                  deliveredMessages.status,
                                                  style: const TextStyle(
                                                      color: Color.fromARGB(
                                                          255, 10, 176, 29),
                                                      fontWeight:
                                                          FontWeight.w600),
                                                ),
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const Text("Msg : "),
                                                Expanded(
                                                    child: Text(
                                                        deliveredMessages
                                                            .smsStr))
                                              ],
                                            ),
                                            const SizedBox(
                                              height: 5,
                                            ),
                                            Text(
                                                "Sent To : ${deliveredMessages.mobileNumber}"),
                                            const SizedBox(
                                              height: 10,
                                            ),
                                          ],
                                        );
                                      },
                                    ),
                                  ),
                                )
                              : adminSmsReportProvider
                                          .undeliveredMessages.isNotEmpty &&
                                      undelivered == true
                                  ? Expanded(
                                      child: Padding(
                                        padding: const EdgeInsets.symmetric(
                                            horizontal: 15.0),
                                        child: ListView.builder(
                                          physics:
                                              const BouncingScrollPhysics(),
                                          shrinkWrap: true,
                                          itemCount: adminSmsReportProvider
                                              .undeliveredMessages.length,
                                          itemBuilder: (context, index) {
                                            var undeliveredMessages =
                                                adminSmsReportProvider
                                                    .undeliveredMessages[index];
                                            return Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                const SizedBox(
                                                  height: 30,
                                                ),
                                                Text(
                                                  'Date: ${DateFormat.yMMMMd().format(undeliveredMessages.sentDate)}',
                                                  style: const TextStyle(
                                                      fontSize: 16,
                                                      fontWeight:
                                                          FontWeight.bold),
                                                ),
                                                Row(
                                                  mainAxisSize:
                                                      MainAxisSize.min,
                                                  children: [
                                                    const Text('Status : '),
                                                    Text(
                                                        undeliveredMessages
                                                            .status,
                                                        style:
                                                            const TextStyle(
                                                                color: Color
                                                                    .fromARGB(
                                                                        255,
                                                                        210,
                                                                        20,
                                                                        7),
                                                                fontWeight:
                                                                    FontWeight
                                                                        .w600)),
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.start,
                                                  crossAxisAlignment:
                                                      CrossAxisAlignment.start,
                                                  children: [
                                                    const Text("Msg : "),
                                                    Expanded(
                                                        child: Text(
                                                            undeliveredMessages
                                                                .smsStr))
                                                  ],
                                                ),
                                                const SizedBox(
                                                  height: 5,
                                                ),
                                                Text(
                                                    "Sent To : ${undeliveredMessages.mobileNumber}"),
                                                const SizedBox(
                                                  height: 10,
                                                ),
                                              ],
                                            );
                                          },
                                        ),
                                      ),
                                    )
                                  : Container(),

          const SizedBox(height: 15),
        ],
      ),
    );
  }
}
