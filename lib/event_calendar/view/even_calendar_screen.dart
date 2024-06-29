import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:intl/intl.dart';

import 'package:school_jet/host_service/host_services.dart';
import 'package:school_jet/utils/appcolors.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:table_calendar/table_calendar.dart';
import 'package:http/http.dart' as http;

import '../model/model.dart';

class CalenderPage extends StatefulWidget {
  const CalenderPage({super.key});

  @override
  State<CalenderPage> createState() => _CalenderPageState();
}

class _CalenderPageState extends State<CalenderPage> {
  EventData? _eventData;
  EventData? get eventData => _eventData;
  List<EventData> events = [];
  List<EventData> focusedMonthEvents = [];
  // CalendarController _controller = CalendarController();
  Map<DateTime, List<dynamic>> _events = {};
  // List<dynamic> events = [];
  List<String> formattedDates = [];
  String month = '';
  DateTime _focusedDay = DateTime.now();
  String monthName(int month) {
    return DateFormat('MMMM').format(DateTime(DateTime.now().year, month));
  }

// Example usage:

  Future<void> fetchData() async {
    final pref = await SharedPreferences.getInstance();
    final baseurl = pref.getString('apiurl');
    final url = Uri.parse('$baseurl${HostService().eventCalender}');
    try {
      final response = await http.get(url);

      final data = jsonDecode(response.body);
      print(data);
      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        events = data.map<EventData>((event) {
          return EventData.fromJson(event);
        }).toList();
        // List to store event dates
        // List to store event dates
        List<dynamic> eventDates = [];

// Extract event dates
        events.forEach((element) {
          eventDates.add(element.edate ?? '');
        });

// Convert event dates to desired format
        formattedDates = eventDates.map((date) {
          DateTime dateTime = DateTime.parse(date);
          return DateFormat("yyyy-MM-dd").format(dateTime);
        }).toList();

        // Print the formatted dates
        print(formattedDates);
        focusedMonthEvents = events
            .where((event) =>
                event.edate != null &&
                DateTime.parse(event.edate!).month == _focusedDay.month)
            .toList();
        int monthNumber = _focusedDay.toLocal().month;
        month = monthName(monthNumber);

        // Update stream with EventData list
        setState(() {});
      } else {
        print('fail');
      }
    } catch (e) {
      print(e.toString());
    }
  }

  String formatDate(String dateString) {
    DateTime dateTime = DateTime.parse(dateString);
    return DateFormat('d MMM yyyy').format(dateTime);
  }

  Timer? timer;

  @override
  void initState() {
    super.initState();
    SystemChrome.setSystemUIOverlayStyle(
      const SystemUiOverlayStyle(
        statusBarColor: Appcolor.themeColor,
        statusBarIconBrightness: Brightness.dark,
      ),
    );

    fetchData();
    // Start periodic timer to fetch events every 2 seconds
    timer =
        Timer.periodic(const Duration(seconds: 2), (Timer t) => fetchData());
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      appBar: AppBar(
        elevation: 0,
        backgroundColor: Appcolor.themeColor,
        title: Text(
          'Event Calender',
          style: TextStyle(fontSize: size.height * 0.022),
        ),
      ),
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          TableCalendar(
            eventLoader: (day) => formattedDates
                .where(
                    (eventDates) => isSameDay(DateTime.parse(eventDates), day))
                .toList(),
            onPageChanged: (focusedDay) {
              setState(() {
                _focusedDay = focusedDay;
              });
            },
            headerStyle: HeaderStyle(
              titleTextStyle: const TextStyle(
                fontSize: 14,
                fontWeight: FontWeight.bold,
              ),
              formatButtonTextStyle: const TextStyle(
                  fontSize: 14,
                  color: Colors.white,
                  fontWeight: FontWeight.bold),
              formatButtonDecoration: BoxDecoration(
                color: Colors.red,
                borderRadius: BorderRadius.circular(5.0),
              ),
              // formatButtonTextStyle: TextStyle(color: Colors.white),
              formatButtonShowsNext: false,
            ),
            calendarBuilders: CalendarBuilders(
              markerBuilder: (context, date, events) => events.isNotEmpty
                  ? Container(
                      width: 14,
                      height: 14,
                      alignment: Alignment.center,
                      decoration: const BoxDecoration(
                        color: Colors.orange,
                      ),
                      child: Text(
                        '${events.length}',
                        style:
                            const TextStyle(color: Colors.white, fontSize: 10),
                      ),
                    )
                  : null,
            ),
            firstDay: DateTime(2010),
            focusedDay: _focusedDay,
            lastDay: DateTime(2030),
          ),
          Expanded(
            child: ListView.builder(
              physics: const BouncingScrollPhysics(),
              shrinkWrap: true,
              itemCount: focusedMonthEvents.length,
              itemBuilder: (_, index) {
                return focusedMonthEvents.isNotEmpty
                    ? Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 10.0),
                        child: Card(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.center,
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                decoration: BoxDecoration(
                                    color: Colors.blue,
                                    borderRadius: BorderRadius.circular(5)),
                                width: size.width,
                                child: Padding(
                                  padding: const EdgeInsets.all(2.0),
                                  child: Text(
                                    ' Events',
                                    style: TextStyle(
                                        color: Colors.white,
                                        fontSize: size.height * 0.016,
                                        fontWeight: FontWeight.bold),
                                  ),
                                ),
                              ),
                              const SizedBox(
                                height: 10,
                              ),
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 5.0,
                                ),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: [
                                    Text(
                                      'Event Date: ',
                                      style: TextStyle(
                                          fontSize: size.height * 0.017,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    const Spacer(),
                                    const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                      size: 16,
                                    ),
                                    const SizedBox(
                                      width: 5,
                                    ),
                                    Container(
                                      decoration: BoxDecoration(
                                          gradient: Appcolor.sliderGradient,
                                          borderRadius:
                                              BorderRadius.circular(5)),
                                      child: Padding(
                                        padding: const EdgeInsets.all(2.0),
                                        child: Text(
                                          formatDate(
                                            focusedMonthEvents[index]
                                                .edate
                                                .toString(),
                                          ),
                                          style: TextStyle(
                                              fontSize: size.height * 0.016,
                                              color: Colors.white),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Event Name: ',
                                      style: TextStyle(
                                          fontSize: size.height * 0.017,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(
                                        focusedMonthEvents[index]
                                            .ename
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: size.height * 0.016,
                                            color: Colors.blueGrey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const Divider(),
                              Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 5.0),
                                child: Row(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    Text(
                                      'Description: ',
                                      style: TextStyle(
                                          fontSize: size.height * 0.017,
                                          fontWeight: FontWeight.bold),
                                    ),
                                    Expanded(
                                      child: Text(
                                        focusedMonthEvents[index]
                                            .edesc
                                            .toString(),
                                        style: TextStyle(
                                            fontSize: size.height * 0.016,
                                            color: Colors.blueGrey),
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                              const SizedBox(height: 2)
                            ],
                          ),
                        ),
                      )
                    : const SizedBox(
                        child: Text('No events present'),
                      ); // Return an empty SizedBox if there are no events for the current month
              },

              // Padding(
              //   padding: const EdgeInsets.symmetric(horizontal: 10.0),
              //   child: Card(
              //     child: Padding(
              //       padding: const EdgeInsets.all(8.0),
              //       child: Column(
              //         crossAxisAlignment: CrossAxisAlignment.start,
              //         mainAxisSize: MainAxisSize.min,
              //         children: [
              //           Padding(
              //             padding: const EdgeInsets.all(2.0),
              //             child: Row(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               mainAxisAlignment: MainAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   'Event Name: ',
              //                   style: TextStyle(
              //                       fontSize: size.height * 0.017,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     events[index].ename.toString(),
              //                     style: TextStyle(
              //                         fontSize: size.height * 0.016,
              //                         color: Colors.blueGrey),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           ),
              //           const Divider(),
              //           Padding(
              //             padding: const EdgeInsets.all(2.0),
              //             child: Row(
              //               crossAxisAlignment: CrossAxisAlignment.start,
              //               children: [
              //                 Text(
              //                   'Description: ',
              //                   style: TextStyle(
              //                       fontSize: size.height * 0.017,
              //                       fontWeight: FontWeight.bold),
              //                 ),
              //                 Expanded(
              //                   child: Text(
              //                     events[index].edesc.toString(),
              //                     style: TextStyle(
              //                         fontSize: size.height * 0.016,
              //                         color: Colors.blueGrey),
              //                   ),
              //                 ),
              //               ],
              //             ),
              //           )
              //         ],
              //       ),
              //     ),
              // ),
              // ),
            ),
          ),
        ],
      ),
    );
  }
}
