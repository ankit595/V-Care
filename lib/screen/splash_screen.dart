import 'package:flutter/material.dart';
import 'dart:async';

import 'package:major_vcare/screen/selection.dart';




class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  String text = '';
  int textIndex = 0;

  final String targetText = "FEEL THE HEAL";

  @override
  void initState() {
    super.initState();
    _animateText();
    Timer(Duration(seconds: 3), () {
      //Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => Homescreen()));

    });
  }

  void _animateText() {
    if (textIndex < targetText.length) {
      Timer.periodic(Duration(milliseconds: 150), (timer) {
        if (text.length < textIndex + 1) {
          setState(() {
            text = targetText.substring(0, text.length + 1);
          });
        }
        textIndex++;
        if (textIndex >= targetText.length) {
          timer.cancel();
        }
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.only(top: 25),
            child: Image(
              image: AssetImage("assets/spl.png"),
              height: MediaQuery.of(context).size.height * 0.4,
            ),
          ),
          Text(
            text,
            style: TextStyle(
              fontSize: 20.0,
              fontWeight: FontWeight.bold,
              color: Color.fromRGBO(
                  129, 71, 255, 1.0), // Change the color to your desired color
            ),
          ),
        ],
      ),
    );
  }
}