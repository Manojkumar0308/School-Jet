import 'package:crypto/crypto.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';

import 'dart:convert';

import 'package:shared_preferences/shared_preferences.dart';

import '../../host_service/host_services.dart';
import '../../utils/common_methods.dart';
import '../view/success.dart';

class OnlinePaymentViewModel extends ChangeNotifier {
  String? baseUrl;
  late List<bool> selectedCardCheckboxes = [];
  HostService hostService = HostService();
  Map<String, dynamic> data = {};
  List responseData = [];
  bool isLoading = false;
  String? keys;
  String? paymentsalt;
  String? easebuzzbaseUrl;
  String accesskey = '';
  String? tranid;
  String? mail;
  String? hash;
  String? submerchantid;
  int? numericClass;
  Map<String, dynamic> decodedResponse = {};
  Map<Object?, dynamic> detailedResponse = {};
  static MethodChannel channel = const MethodChannel("easebuzz");
  Map<String, dynamic> responseDataGetResponse = {};
   bool _isLoadings = false; // Track loading state
  bool get isLoadings => _isLoadings; // Getter for loading state

  Future<void> onlineFeeDetail(
      BuildContext context, String regno, int stuid, int sessid) async {
    final pref = await SharedPreferences.getInstance();
    baseUrl = pref.getString('apiurl');
    final url = Uri.parse(baseUrl.toString() + hostService.onlineFeeDetail);
    print(url);
    final headers = {
      'Content-Type': 'application/json',
      'Charset': 'utf-8',
    };
    final body =
        jsonEncode({"regno": regno, "stuid": stuid, "sessionid": sessid});
    print('Fee Submissiondetail body: $body');
    try {
      isLoading = true;
      responseData = [];
      notifyListeners();
      final response = await http.post(url, body: body, headers: headers);
      print(response);

      if (response.statusCode == 200) {
        isLoading = false;

        final decodedResponse = jsonDecode(response.body);

        if (decodedResponse != null) {
          data = decodedResponse;
          if (data['ofeelist'] != null) {
            responseData = data['ofeelist'];
          }

          print(response.body);
          selectedCardCheckboxes = List.generate(
            responseData.length,
            (index) {
              if (responseData[index]['paid'] == true) {
                return true;
              } else {
                return false;
              }
            },
          );
          notifyListeners();
          print(responseData);
        } else {
          // Handle the case where decodedResponse is null
          print("Decoded response is null");
        }
      } else {
        isLoading = false;
        print('object');
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, "Something went wrong");
      }

      notifyListeners();
    } catch (e) {
      isLoading = false;
      print(e.toString());
      // ignore: use_build_context_synchronously
      CommonMethods().showSnackBar(context, 'Error occurred');
      notifyListeners();
    }
  }

  //get gateway detail api

  Future<void> getGateWayDetail(BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final sessionId = pref.getInt('sessionid');
    print(DateTime.now());
    final stuId = pref.getInt('StuId');
    final token = pref.getString('userToken');
    final schoolId = pref.getInt('schoolid');
    notifyListeners();
    baseUrl = pref.getString('apiurl');
    final url = Uri.parse(baseUrl.toString() + hostService.getGatewayDet);
    print(url);
    final headers = {
      "Content-Type":
          "application/x-www-form-urlencoded", // or "application/json" depending on the server
      "Accept": "application/json",
    };
    final body = {
      "stuid": stuId.toString(),
      "sessionid": sessionId.toString(),
      "token": token.toString(),
      "schoolid": schoolId.toString()
    };
    print('get gatewayDetail  body: $body');

    try {
      final response = await http.post(url, body: body, headers: headers);
      print('response is: ${response.body}');

      if (response.statusCode == 200) {
        if (response != null) {
          decodedResponse = jsonDecode(response.body);
          print('decodedResponse is :$decodedResponse');
          if (decodedResponse != null) {
            keys = decodedResponse['key'];

            easebuzzbaseUrl = decodedResponse['baseurl'];
            print('decodedResponse is $decodedResponse');
            if (decodedResponse['submerchantid'] != null &&
                decodedResponse['submerchantid'].toString().isNotEmpty) {
              submerchantid = decodedResponse['submerchantid'];
              notifyListeners();
            }

            if (decodedResponse['numricclass'] != null) {
              numericClass = decodedResponse['numricclass'];
              notifyListeners();
            }
            notifyListeners();
          } else {
            // Handle the case where decodedResponse is null
            print("Decoded response is null");
          }
        }
      } else {
        print('hello1');
        // ignore: use_build_context_synchronously
        CommonMethods().showSnackBar(context, "Something went wrong");
      }

      notifyListeners();
    } catch (e) {
      print(e.toString());
      // ignore: use_build_context_synchronously
      CommonMethods().showSnackBar(context, 'Error occurred');
      notifyListeners();
    }
  }

  Future<void> getTransactionId(
      BuildContext context, String interval, double amount) async {
    final pref = await SharedPreferences.getInstance();
    final sessionId = pref.getInt('sessionid');

    final stuId = pref.getInt('StuId');
    final classId = pref.getInt('classId');
    print('class id is : $classId');
    notifyListeners();
    baseUrl = pref.getString('apiurl');
    final url = Uri.parse(baseUrl.toString() + hostService.getTransId);
    print(url);
    DateTime now = DateTime.now();
    String formattedDate = DateFormat('yyyy-MM-dd').format(now);
    var headers = {'Content-Type': 'application/json'};
    final body = jsonEncode({
      "Transaction_id": DateTime.now().millisecondsSinceEpoch,
      "Transaction_date": formattedDate,
      "stuid": stuId,
      "Intervals": interval,
      "Remark": "",
      "Receipt_no": 0,
      "sessionid": sessionId,
      "amount": amount,
      "Bal_amt": 0.0,
      "PayMode": "",
      "BankId": 0,
      "ETransDetail": "",
      "UpdatedBy": 0,
      "UpdatedOn": "",
      "feesubmissiontype": "",
      "prev_bal": 0.0,
      "discount": 0.0,
      "latefee": 0.0,
      "numericclass": numericClass,
      "convamt": "sample string 20"
    });
    print('get Transaction id body is:$body');
    try {
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        if (response != null) {
          var result = jsonDecode(response.body);
          print('get Transaction id $result');

          if (result['tranid'] != null ||
              result['tranid'].toString().isNotEmpty) {
            tranid = result['tranid'];
          } else {
            print('txnid is null');
          }
          if (result['email'] != null &&
              result['email'].toString().isNotEmpty) {
            mail = result['email'];
            print('mail is :$mail');
          } else {
            print('email is null');
          }

          if (result['hash'] != null || result['hash'].toString().isNotEmpty) {
            hash = result['hash'];
          } else {
            print('txnid is null');
          }

          print(result);
        }
      }
    } catch (e) {
      print(e.toString());
      // ignore: use_build_context_synchronously
      CommonMethods().showSnackBar(context, "Something went wrong");
    }
  }

  //main payment method
  Future<void> initiatePayment(
      double amounttopay, String name, BuildContext context) async {
    final pref = await SharedPreferences.getInstance();
    final phoneNumber = pref.getString('mobno');
    try {
      String key = keys.toString();
      String txnid = tranid.toString();
      num amount = amounttopay;
      String productinfo = "Fee";
      String firstname = name;
      String email = mail ?? "test@b.com";
      String phone = phoneNumber.toString();

      String udf1 = "";
      String udf2 = "";
      String udf3 = "";
      String udf4 = "";
      String udf5 = "";
      String udf6 = "";
      String udf7 = "";
      String udf8 = "";
      String udf9 = "";
      String udf10 = "";
      // Convert amount to string
      String amountString = amount.toString();
      String phonenumber = phone.toString();
      print(key);
      // Concatenate the parameters for hashing
      // final hashString =
      //     "$key|$txnid|$amountString|$productinfo|$firstname|$email|$udf1|$udf2|$udf3|$udf4|$udf5|$udf6|$udf7|$udf8|$udf9|$udf10|$salt";
      // print("hashString:$hashString");

      // // Generate SHA-512 hash
      // hash = generateSHA512Hash(hashString);
      print("hash:$hash");
      final url = Uri.parse("$easebuzzbaseUrl/payment/initiateLink");
      print(url);

      //RequestData....
      final requestData = {
        "key": key,
        "txnid": txnid,
        "amount": amountString,
        "productinfo": productinfo,
        "firstname": firstname,
        "phone": int.parse(phone).toString(),
        "email": email,
        "surl": "https://medium.com/@easebuzz",
        "furl":
            "https://www.youtube.com/results?search_query=easebuzz+payment+gateway+integration+flutter",
        "hash": hash,
        "show_payment_mode": "NB,CC,DAP,MW,UPI,OM,EMI",
        "sub_merchant_id": submerchantid
      };
      print("body:$requestData");
      final headers = {
        "Content-Type":
            "application/x-www-form-urlencoded", // or "application/json" depending on the server
        "Accept": "application/json",
      };
      final response =
          await http.post(url, body: requestData, headers: headers);
      print('Response of initiatedpayment is: $response');

      if (response.statusCode == 200) {
        // Handle successful payment initiation
        final Map<String, dynamic> responseData = json.decode(response.body);
        // Process the response as needed
        print("Payment initiated successfully. Response: $responseData");
        accesskey = responseData['data'];
        String payMode = "production";
        Object parameters = {
          "access_key": responseData['data'],
          "pay_mode": payMode
        };
        print('Parameters are: $parameters');
        final paymentResponse =
            await channel.invokeMethod("payWithEasebuzz", parameters);
        detailedResponse = paymentResponse['payment_response'];

        if (kDebugMode) {
          print('payment response :$detailedResponse');
        }
        if (paymentResponse['result'] == 'payment_successfull') {
          // ignore: use_build_context_synchronously
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const Success()),
          );
        } else {
          Fluttertoast.showToast(
              msg: "User cancelled transaction",
              toastLength: Toast.LENGTH_SHORT,
              gravity: ToastGravity.BOTTOM,
              timeInSecForIosWeb: 2,
              backgroundColor: Colors.black,
              textColor: Colors.white,
              fontSize: 12.0);
        }
      } else {
        // Handle errors
        print("Error initiating payment: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
    } catch (e) {
      print("Error: $e");
    }
  }

//method to send transaction of failure or success payment to the server.
  Future<void> getResponseOnlineTransaction(
      String status,
      String txnid,
      String interval,
      String easepayid,
      String bankRefNum,
      double amount,
      String bankcode,
      String statuscode,
      String returnedHash) async {
    final pref = await SharedPreferences.getInstance();
    final sessionId = pref.getInt('sessionid');

    final stuId = pref.getInt('StuId');
    notifyListeners();
    baseUrl = pref.getString('apiurl');
    final classID = pref.getInt('classId');
    try {
      final url = Uri.parse(
          baseUrl.toString() + hostService.getResponseOnlineTransactionUrl);

      final body = jsonEncode({
        "status": status,
        "stuid": stuId,
        "txnid": txnid,
        "classid": classID,
        "interval": interval,
        "easepayid": easepayid,
        "bank_ref_num": bankRefNum,
        "amount": amount,
        "bankcode": bankcode,
        "statuscode": statuscode,
        "sessionid": sessionId,
        "hash": returnedHash,
        "numericclass": numericClass
      });

      print('getResponseOnlineTransaction body is :$body');
      final headers = {'Content-Type': 'application/json'};
      final response = await http.post(url, body: body, headers: headers);
      if (response.statusCode == 200) {
        responseDataGetResponse = json.decode(response.body);

        print(
            'Response Body of getResponseOnlineTransaction --->> $responseDataGetResponse');
      } else {
        // Handle errors
        print("Error initiating payment: ${response.statusCode}");
        print("Response Body: ${response.body}");
      }
      notifyListeners();
    } catch (e) {
      print(e.toString());
      notifyListeners();
    }
  }

  String generateSHA512Hash(String input) {
    var bytes = utf8.encode(input);
    var digest = sha512.convert(bytes);
    return digest.toString();
  }
}
