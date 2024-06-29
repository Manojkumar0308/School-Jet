import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_inappwebview/flutter_inappwebview.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:provider/provider.dart';
import 'package:url_launcher/url_launcher.dart';

import 'online_payment/model/atom_pay_helper.dart';
import 'online_payment/view/failure.dart';
import 'online_payment/view/online_payment_screen.dart';
import 'online_payment/view/success.dart';
import 'online_payment/view_model/online_payment_viewmodel.dart';

class WebViewContainer extends StatefulWidget {
  final mode;
  final payDetails;
  final responsehashKey;
  final responseDecryptionKey;
  final monthString;

  const WebViewContainer(this.mode, this.payDetails, this.responsehashKey,
      this.responseDecryptionKey, this.monthString);

  @override
  createState() => _WebViewContainerState(this.mode, this.payDetails,
      this.responsehashKey, this.responseDecryptionKey);
}

class _WebViewContainerState extends State<WebViewContainer> {
  final mode;
  final payDetails;
  final _responsehashKey;
  final _responseDecryptionKey;
  final _key = UniqueKey();
  late InAppWebViewController _controller;

  final Completer<InAppWebViewController> _controllerCompleter =
      Completer<InAppWebViewController>();
  Map<String, dynamic> jsonInput = {};

  @override
  void initState() {
    super.initState();
    // if (Platform.isAndroid) WebView.platform  = SurfaceAndroidViewController();
  }

  _WebViewContainerState(this.mode, this.payDetails, this._responsehashKey,
      this._responseDecryptionKey);

  @override
  Widget build(BuildContext context) {
    print('hhh');
    print('${widget.monthString},');
    return WillPopScope(
      onWillPop: () => _handleBackButtonAction(context),
      child: Scaffold(
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          automaticallyImplyLeading: false,
          elevation: 0,
          toolbarHeight: 2,
        ),
        body: SafeArea(
            child: InAppWebView(
          // initialUrl: 'about:blank',
          key: UniqueKey(),
          onWebViewCreated: (InAppWebViewController inAppWebViewController) {
            _controllerCompleter.future.then((value) => _controller = value);
            _controllerCompleter.complete(inAppWebViewController);

            debugPrint("payDetails from webview $payDetails");
            _loadHtmlFromAssets(mode);
          },
          shouldOverrideUrlLoading: (controller, navigationAction) async {
            String url = navigationAction.request.url as String;
            var uri = navigationAction.request.url!;
            if (url.startsWith("upi://")) {
              debugPrint("upi url started loading");
              try {
                await launchUrl(uri);
              } catch (e) {
                _closeWebView(context,
                    "Transaction Status = cannot open UPI applications");
                throw 'custom error for UPI Intent';
              }
              return NavigationActionPolicy.CANCEL;
            }
            return NavigationActionPolicy.ALLOW;
          },

          onLoadStop: (controller, url) async {
            debugPrint("onloadstop_url: $url");

            if (url.toString().contains("AIPAYLocalFile")) {
              debugPrint(" AIPAYLocalFile Now url loaded: $url");
              await _controller.evaluateJavascript(
                  source: "openPay('" + payDetails + "')");
            }

            if (url.toString().contains('/mobilesdk/param')) {
              final String response = await _controller.evaluateJavascript(
                  source: "document.getElementsByTagName('h5')[0].innerHTML");
              debugPrint("HTML response : $response");
              var transactionResult = "";
              if (response.trim().contains("cancelTransaction")) {
                transactionResult = "Transaction Cancelled!";
              } else {
                final split = response.trim().split('|');
                final Map<int, String> values = {
                  for (int i = 0; i < split.length; i++) i: split[i]
                };

                final splitTwo = values[1]!.split('=');
                const platform = MethodChannel('flutter.dev/NDPSAESLibrary');

                try {
                  final String result =
                      await platform.invokeMethod('NDPSAESInit', {
                    'AES_Method': 'decrypt',
                    'text': splitTwo[1].toString(),
                    'encKey': _responseDecryptionKey
                  });
                  var respJsonStr = result.toString();
                  jsonInput = jsonDecode(respJsonStr);
                  debugPrint("read full respone : $jsonInput");

                  //calling validateSignature function from atom_pay_helper file
                  var checkFinalTransaction =
                      validateSignature(jsonInput, _responsehashKey);

                  if (checkFinalTransaction) {
                    print(jsonInput["payInstrument"]["responseDetails"]
                        ["statusCode"]);
                    if (jsonInput["payInstrument"]["responseDetails"]
                                ["statusCode"] ==
                            'OTS0000' ||
                        jsonInput["payInstrument"]["responseDetails"]
                                ["statusCode"] ==
                            'OTS0551') {
                      debugPrint("Transaction success");
                      transactionResult = "Transaction Success";
                    } else {
                      debugPrint("Transaction failed");
                      transactionResult = "Transaction Failed";
                    }
                  } else {
                    debugPrint("signature mismatched");
                    transactionResult = "Signature missmatched";
                  }
                  debugPrint("Transaction Response : $jsonInput");
                  print("Transaction message ${jsonInput['message']}");
                } on PlatformException catch (e) {
                  debugPrint("Failed to decrypt: '${e.message}'.");
                }
              }
              _closeWebView(context, transactionResult);
            }
          },
        )),
      ),
    );
  }

  _loadHtmlFromAssets(mode) async {
    final localUrl =
        mode == 'uat' ? "assets/aipay_uat.html" : "assets/aipay_prod.html";
    String fileText = await rootBundle.loadString(localUrl);
    _controller.loadUrl(
        urlRequest: URLRequest(
            url: Uri.dataFromString(fileText,
                mimeType: 'text/html', encoding: Encoding.getByName('utf-8'))));
  }

  _closeWebView(context, transactionResult) {
    if (jsonInput != null &&
        jsonInput["payInstrument"] != null &&
        jsonInput["payInstrument"]["responseDetails"] != null &&
        (jsonInput["payInstrument"]["responseDetails"]["statusCode"] ==
                'OTS0000' ||
            jsonInput["payInstrument"]["responseDetails"]["statusCode"] ==
                'OTS0551')) {
      final onlinepaymentProviders =
          // ignore: use_build_context_synchronously
          Provider.of<OnlinePaymentViewModel>(context, listen: false);
      onlinepaymentProviders.getResponseOnlineTransaction(
          "success",
          // jsonInput['payInstrument']['responseDetails']['message'],
          jsonInput['payInstrument']['merchDetails']['merchTxnId'],
          '${widget.monthString},',
          jsonInput['payInstrument']['payDetails']['atomTxnId'].toString(),
          jsonInput['payInstrument']['payModeSpecificData']['bankDetails']
              ['bankTxnId'],
          jsonInput['payInstrument']['payDetails']['amount'],
          jsonInput['payInstrument']['payModeSpecificData']['bankDetails']
              ['otsBankName'],
          jsonInput['payInstrument']['responseDetails']['statusCode'],
          jsonInput['payInstrument']['payDetails']['signature']);
      if (onlinepaymentProviders.responseDataGetResponse['resultcode'] == 0) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Success(),
          ),
        );
      } else {
        print(
            'resultcode after getResponseTransaction-->> ${onlinepaymentProviders.responseDataGetResponse['resultcode']}');

        // Fluttertoast.showToast(
        //     msg:
        //         'SERVER UPDATION FAILED :${onlinepaymentProviders.responseDataGetResponse['resultstring']}',
        //     timeInSecForIosWeb: 2,
        //     gravity: ToastGravity.CENTER,
        //     toastLength: Toast.LENGTH_SHORT);
      }
    } else {
      Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (_) => const Failure(),
          ));
    }

    // Close current window
    // ignore: use_build_context_synchronously
    ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text("Transaction Status = $transactionResult")));
  }

  Future<bool> _handleBackButtonAction(BuildContext context) async {
    debugPrint("_handleBackButtonAction called");
    showDialog(
        context: context,
        builder: (context) => AlertDialog(
              title: const Text('Do you want to exit the payment ?'),
              actions: <Widget>[
                // ignore: deprecated_member_use
                ElevatedButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('No'),
                ),
                // ignore: deprecated_member_use
                ElevatedButton(
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.of(context).pop(); // Close current window
                    ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                        content: Text(
                            "Transaction Status = Transaction cancelled")));
                  },
                  child: const Text('Yes'),
                ),
              ],
            ));
    return Future.value(true);
  }
}
