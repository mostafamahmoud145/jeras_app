import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/models/AppAppointments.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:shared_preferences/shared_preferences.dart';

import '../../config/app_constat.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../widget/primary_button.dart';

class PrivacyScreen extends StatefulWidget {
  GroceryUser? user;

  AppAppointments? appointment;

  PrivacyScreen({this.user});

  @override
  PrivacyScreenState createState() => PrivacyScreenState();
}

class PrivacyScreenState extends State<PrivacyScreen>
    with SingleTickerProviderStateMixin {
  @override
  void initState() {
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p20.w, vertical: AppPadding.p10.h),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: [
              Row(
                children: [
                  Icon(Icons.privacy_tip_outlined,
                      size: size.height * AppSize.w0_075,
                      color: Theme.of(context).primaryColor),
                  SizedBox(
                    width: AppSize.w10.w,
                  ),
                  Expanded(
                      child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        getTranslated(context, "Terms of Service"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold700,
                            color: AppColors.black.withOpacity(0.85)),
                      ),
                      Text(
                        getTranslated(context, "privacy status update"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s12.sp,
                            color: AppColors.black.withOpacity(0.7)),
                      ),
                    ],
                  ))
                ],
              ),
              Expanded(
                  child: SingleChildScrollView(
                child: (widget.user!.userType == "USER")
                    ? Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated(context, "Student Data"),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s15.sp,
                                color: AppColors.black.withOpacity(0.7)),
                          ),
                        ],
                      )
                    : Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            getTranslated(context, "Teacher Data"),
                            textAlign: TextAlign.start,
                            style: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s15.sp,
                                color: AppColors.black.withOpacity(0.7)),
                          ),
                        ],
                      ),
              )),
              SizedBox(
                height: AppSize.h10.h,
              ),
              Center(
                child: PrimaryButton(
                  onPress: () {
                    accept();
                  },
                  text: getTranslated(context, "accept"),
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h60.h : AppSize.h40.h,
                  textSize: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s18.sp : AppFontsSizeManager.s15.sp,
                  buttonRadius: 10.r,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
  static bool firstLaunch = false;

  Future<void> accept() async {
    var collection = FirebaseFirestore.instance.collection('Users');
    await collection.doc(widget.user!.uid).set({
      'privacy': true,
    }, SetOptions(merge: true));
    Navigator.pushNamedAndRemoveUntil(
      context,
      '/home',
      (route) => false,
    );
  }
}
