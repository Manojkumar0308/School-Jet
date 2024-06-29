import 'dart:async';

import 'package:flutter/material.dart';
import 'package:school_jet/utils/common_methods.dart';

import 'online_payment_screen.dart';

class Failure extends StatefulWidget {
  const Failure({Key? key}) : super(key: key);

  @override
  State<Failure> createState() => _FailureState();
}

class _FailureState extends State<Failure> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;
  int _secondsLeft = 5;
  late Timer _timer;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );

    _scaleAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(
        parent: _animationController,
        curve: Curves.easeInOutBack,
      ),
    );

    // Start the animation
    _animationController.forward();

    // Start the countdown timer
    _startTimer();
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_secondsLeft == 0) {
        _timer.cancel();
        // Navigate to the next screen after countdown ends
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => const OnlinePaymentScreen()),
        );
      } else {
        setState(() {
          _secondsLeft--;
        });
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    _timer.cancel(); // Cancel the timer when disposing the state
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async {
        return CommonMethods().onwillPop(context);
      },
      child: Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              ScaleTransition(
                scale: _scaleAnimation,
                child: Container(
                  width: 100,
                  height: 100,
                  decoration: const BoxDecoration(
                    shape: BoxShape.circle,
                    color: Colors.red,
                  ),
                  child: const Icon(
                    Icons.close,
                    color: Colors.white,
                    size: 60,
                  ),
                ),
              ),
              const SizedBox(height: 16),
              const Text(
                'Transaction Failed',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
              const SizedBox(height: 5),
              Text(
                'Please wait for $_secondsLeft seconds...',
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.blueGrey,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
