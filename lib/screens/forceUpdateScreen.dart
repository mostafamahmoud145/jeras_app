import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/widget/component/TextButton.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';

class ForceUpdateScreen extends StatefulWidget {
  const ForceUpdateScreen({Key? key}) : super(key: key);

  @override
  _ForceUpdateScreenState createState() => _ForceUpdateScreenState();
}

class _ForceUpdateScreenState extends State<ForceUpdateScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  TextEditingController nameController = TextEditingController();
  String? lang;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          SizedBox(
            height: AppSize.h156.h,
          ),
          Center(
              child: Image.asset(
            AssetsManager.whiteJerasLogoIconPath,
            width: AppSize.w94.w,
            height: AppSize.h125_7.h,
          )),
          SizedBox(
            height: AppSize.h26_6.h,
          ),
          Padding(
            padding: EdgeInsets.only(
                left: lang == "ar" ? 0 : AppPadding.p80.r,
                right: lang == "ar" ? 0 : AppPadding.p80.r),
            child: Text(
              getTranslated(context, 'jerasText'),
              style: TextStyle(
                color: Theme.of(context).primaryColor,
                fontSize: AppFontsSizeManager.s24.sp,
                fontWeight: AppFontsWeightManager.bold500,
                fontStyle: FontStyle.normal,
                letterSpacing: 0,
                fontFamily: getTranslated(context, "Ithra"),
              ),
            ),
          ),
          SizedBox(
            height: AppSize.h206_2.h,
          ),
          Padding(
            padding: EdgeInsets.only(
                left: AppPadding.p68.r, right: AppPadding.p68.r),
            child: Center(
              child: Text(
                getTranslated(context, "lastVersion"),
                maxLines: 3,
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  color: AppColors.greyUpdate,
                  fontSize: AppFontsSizeManager.s26_6.sp,
                  fontWeight: FontWeight.w800,
                  letterSpacing: AppConstants.letterSpacing0_5,
                ),
              ),
            ),
          ),
          SizedBox(
            height: AppSize.h64.h,
          ),
          TextButton1(
              onPress: () async {
                String url = Platform.isIOS
                    ? "https://apps.apple.com/us/app/1612021922"
                    : "https://play.google.com/store/apps/details?id=com.app.jeras";
                if (await canLaunch(url)) {
                  await launch(url);
                } else {
                  throw 'Could not launch $url';
                }
              },
              Title: getTranslated(context, "install"),
              Width: AppSize.w390_6.w,
              Height: AppSize.h66_6.h,
              ButtonRadius: AppRadius.r16.r,
              GradientColor: Color.fromRGBO(174, 156, 206, 1),
              GradientColor2: Color.fromRGBO(123, 108, 150, 1),
              TextSize: AppFontsSizeManager.s21_3.sp,
              TextFont: getTranslated(context, "Ithra"),
              TextColor: AppColors.white),
          /*Container(
        width: size.width*AppSize.w0_8.w,
        height:AppSize.h45.h,
        child: MaterialButton(
          onPressed: () async {
           String url = Platform.isIOS ?"https://apps.apple.com/us/app/1612021922": "https://play.google.com/store/apps/details?id=com.app.jeras";
            if (await canLaunch(url)) {
              await launch(url);
            } else {
              throw 'Could not launch $url';
            }
          },
          color: Theme.of(context).primaryColor,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.r40.r),
          ),
          child: Text(
            getTranslated(context, "install"),
            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
              color: AppColors.white,
              fontSize: AppFontsSizeManager.s20.sp,
              fontWeight: AppFontsWeightManager.semiBold,
              letterSpacing: AppConstants.letterSpacing0_5,
            ),
          ),
        ),
      ),*/
          //SizedBox(height: AppSize.h376.h,),
        ],
      ),
    );
  }
}
