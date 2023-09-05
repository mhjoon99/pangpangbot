import 'dart:async';
import 'package:flutter/material.dart';
import 'main.dart';

class Loading extends StatefulWidget {
  const Loading({Key? key}) : super(key: key);

  @override
  _LoadingState createState() => _LoadingState();
}

class _LoadingState extends State<Loading> {

  @override
  void initState() {
    super.initState();
    Timer(
      Duration(seconds: 3),
        () => Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => MyPage()),
        )
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Color(0xff00498c), //Colors.amber
      body: Center(
        child: Image(
          image: AssetImage('image/logo_pangpangbot.png'),
        ),
      ),
    );
  }
}