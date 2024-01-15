import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_constat.dart';
import '../config/assets_manager.dart';

class FirstOpenSreen extends StatefulWidget {
  @override
  _FirstOpenSreenState createState() => _FirstOpenSreenState();
}

class _FirstOpenSreenState extends State<FirstOpenSreen> {
  @override
  @override
  void initState() {
    super.initState();
    Timer(Duration(milliseconds: 3000), () {
      Navigator.popAndPushNamed(
        context,
        '/home',
      );
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppColors.linear5
          : Theme.of(context).primaryColor,
      body: Center(
          child: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? Image.asset(AssetsManager.webSplashImage)
              : Image.asset(AssetsManager.mobSplashImage)),
    );
  }

  webSplash(Size size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        //SizedBox(height: size.height * .35,),
        Center(
            child: Image.asset(
          AssetsManager.whiteJerasLogoIconPath,
          width: AppSize.w104.w,
          height: AppSize.h140.h,
        )),
        SizedBox(
          height: size.height * AppSize.h0_1.h,
        ),
        Center(
            child: Image.asset(
              AssetsManager.textSplashImage,
          width: AppSize.w570.w,
          height: AppSize.h63_5.h,
        )),
      ],
    );
  }
}
