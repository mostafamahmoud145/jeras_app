import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

import '../models/user.dart';
import 'account_screen.dart';

class LoadingScreen extends StatefulWidget {
  GroceryUser user;
  Video consultVideo;
  String? consultUid;
  bool? check;

  LoadingScreen(
      {Key? key,
      required this.user,
      required this.consultVideo,
      this.consultUid,
      this.check})
      : super(key: key);

  @override
  State<LoadingScreen> createState() => _LoadingScreenState();
}

class _LoadingScreenState extends State<LoadingScreen> {
  @override
  Widget build(BuildContext context) {
    Future.delayed(Duration(seconds: 3), () {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
            builder: (BuildContext context) => AccountScreen(
                  user: widget.user,
                  consultVideo: widget.consultVideo,
                  check: true,
                  consultUid: widget.consultUid,
                )),
      );
    });
    return Scaffold(
      body: SafeArea(
        child: Center(child: CircularProgressIndicator()),
      ),
    );
  }
}
