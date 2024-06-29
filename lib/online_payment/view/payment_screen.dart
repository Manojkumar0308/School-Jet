import 'package:flutter/material.dart';

class PaymentScreen extends StatefulWidget {
  final String selectedIntervals;
  final double cuamt;
  const PaymentScreen(
      {super.key, required this.selectedIntervals, required this.cuamt});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(),
        body: Center(
            child:
                Text('${widget.selectedIntervals}--> amount:${widget.cuamt}')));
  }
}
