import 'package:flutter/material.dart';

import '../../../../utils/appcolors.dart';
import '../../../../utils/common_methods.dart';

class StudentDetailsScreen extends StatelessWidget {
  final Map<String, dynamic> studentDetails;

  const StudentDetailsScreen({Key? key, required this.studentDetails})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        titleSpacing: 2,
        backgroundColor: Appcolor.themeColor,
        title: Row(
          children: [
            studentDetails['photo'] != null
                ? Image.network(studentDetails['photo'])
                : const CircleAvatar(
                    radius: 20,
                    backgroundColor: Appcolor.lightgrey,
                    backgroundImage:
                        AssetImage('assets/images/user_profile.png'),
                  ),
            const SizedBox(
              width: 10,
            ),
            Text(studentDetails['StuName'] ?? 'N/A',
                style: const TextStyle(fontSize: 14)),
          ],
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Card(
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Name: ${studentDetails['StuName'] ?? 'N/A'}',
                          style: const TextStyle(
                            fontSize: 12,
                          ),
                        ),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(
                          color: Appcolor.themeColor,
                          thickness: 2,
                        ),
                        Text(
                            'Father\'s Name: ${studentDetails['FatherName'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(
                          color: Appcolor.themeColor,
                          thickness: 2,
                        ),
                        Text('Gender: ${studentDetails['gender'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(
                          color: Appcolor.themeColor,
                          thickness: 2,
                        ),
                        Text(
                            'DOB: ${CommonMethods().formatDate(studentDetails['DOB'])}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(
                          color: Appcolor.themeColor,
                          thickness: 2,
                        ),
                        Text('Class: ${studentDetails['ClassName'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(color: Appcolor.themeColor, thickness: 2),
                        Text(
                            'Section: ${studentDetails['SectionName'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(color: Appcolor.themeColor, thickness: 2),
                        Text('Category: ${studentDetails['Category'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(color: Appcolor.themeColor, thickness: 2),
                        Text(
                            'Contact No: ${studentDetails['ContactNo'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Card(
                child: Container(
                  width: double.infinity,
                  child: Padding(
                    padding: const EdgeInsets.all(15.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('Address: ${studentDetails['Address'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(color: Appcolor.themeColor, thickness: 2),
                        Text(
                            'Conveyance: ${studentDetails['Conveyance'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                        const SizedBox(
                          height: 5,
                        ),
                        const Divider(color: Appcolor.themeColor, thickness: 2),
                        Text('Stop: ${studentDetails['Stop'] ?? 'N/A'}',
                            style: const TextStyle(
                              fontSize: 12,
                            )),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
