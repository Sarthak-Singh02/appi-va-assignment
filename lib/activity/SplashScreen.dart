import 'dart:async';

import 'package:appi_va/activity/HomeScreen.dart';
import 'package:appi_va/activity/LoginScreen.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../CONFIG.dart';
import '../SharedPrefrence.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    endSplashScreen();
    super.initState();
  }

// disposing the initialize contents after being initialized to prevent memory leak
  @override
  void dispose() {
    endSplashScreen();
    super.dispose();
  }

  Future<void> endSplashScreen() async {
    Timer(Duration(seconds: 2), () async {
      if (await SharePreference.getBooleanValue(CONFIG.IS_LOGIN) == true) {
        if (mounted)
          setState(() {
            Navigator.pushReplacement<void, void>(
              context,
              CupertinoPageRoute<void>(
                builder: (BuildContext context) => HomeScreen(),
              ),
            );
          });
      } else {
        if (mounted)
          setState(() {
            Navigator.pushReplacement<void, void>(
              context,
              CupertinoPageRoute<void>(
                builder: (BuildContext context) => LoginScreen(),
              ),
            );
          });
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
          child: FlutterLogo(
        size: 100,
      )),
    );
  }
}
