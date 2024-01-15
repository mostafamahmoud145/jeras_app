import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/screens/home_screen.dart';
import 'package:jeras/screens/userAccountScreen.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/responsive_layout.dart';

import '../../../../config/app_fonts.dart';
import '../../../../config/app_values.dart';
import '../../../../models/user.dart';
import '../../../../screens/PrivacyScreen/privacyscreen.dart';

class VerificationSuccessScreen extends StatefulWidget {
  GroceryUser? loggedUser;

  VerificationSuccessScreen({super.key, this.loggedUser});

  @override
  State<VerificationSuccessScreen> createState() =>
      _VerificationSuccessScreenState();
}

class _VerificationSuccessScreenState extends State<VerificationSuccessScreen> {
  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return ResponsiveLayout(
      desktop: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: EdgeInsets.only(
                  bottom: AppPadding.p253.h,
                  top: AppPadding.p48.h,
                  left: AppPadding.p140.w,
                  right: AppPadding.p140.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                      width: AppSize.w75.w,
                      height: AppSize.h75.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r25.r),
                      ),
                      child: CustomBackButton()),
                  const SizedBox(width: AppSize.w10),
                ],
              ),
            ),
            Image.asset(
              AssetsManager.verificationSuccess,
              width: AppSize.w149.w,
              height: AppSize.h149.h,
            ),
            SizedBox(height: AppSize.h14.h),
            // تم التحقـق
            Text(
              getTranslated(context, 'verificationChecked'),
              style: TextStyle(
                color: AppColors.black2,
                fontWeight: AppFontsWeightManager.bold300,
                fontFamily: getTranslated(context, "Ithra"),
                fontStyle: FontStyle.normal,
                fontSize: AppFontsSizeManager.s34.sp,
              ),
              textAlign: TextAlign.center,
            ),
            Text(
              getTranslated(context, "verificationCheckedDescription"),
              style: TextStyle(
                color: AppColors.grey2,
                fontWeight: AppFontsWeightManager.normal,
                fontFamily: getTranslated(context, "Ithra"),
                fontStyle: FontStyle.normal,
                fontSize: AppFontsSizeManager.s30.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSize.h150.h),
            Center(
              child: PrimaryButton(
                width: AppSize.w720.w,
                height: AppSize.h95.h,
                onPress: () async {
                  Navigator.pushAndRemoveUntil(
                      context,
                      MaterialPageRoute(
                          builder: (BuildContext context) =>
                              HomeScreen(user2: widget.loggedUser!)),
                      (route) => false);
                },
                text: getTranslated(context, 'start'),
                textSize: AppFontsSizeManager.s25.sp,
              ),
            ),
          ],
        ),
      ),
      mobile: Scaffold(
        body: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            SizedBox(height: AppSize.h396.h),
            Image.asset(
              AssetsManager.verificationSuccess,
              width: AppSize.w124.r,
              height: AppSize.h124.r,
            ),
            SizedBox(height: AppSize.h32.r),
            // تم التحقـق
            Text(
              getTranslated(context, 'verificationChecked'),
              style: TextStyle(
                color: AppColors.black,
                fontWeight: AppFontsWeightManager.bold100,
                fontFamily: getTranslated(context, "Ithra"),
                fontStyle: FontStyle.normal,
                fontSize: AppFontsSizeManager.s37_3.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: AppSize.h32.r,
            ),
            Text(
              getTranslated(context, 'verificationCheckedDescription'),
              style: TextStyle(
                color: AppColors.lightGrey1,
                fontFamily: getTranslated(context, "Ithralight"),
                fontStyle: FontStyle.normal,
                fontSize: AppFontsSizeManager.s26_6.sp,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(height: AppSize.h232.h),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p90_6.w),
              child: PrimaryButton(
                height: AppSize.h66_6.r,
                buttonRadius: AppRadius.r16.r,
                textSize: AppFontsSizeManager.s21_3.sp,
                onPress: () {
                  FirebaseFirestore.instance
                      .collection('Users')
                      .doc(FirebaseAuth.instance.currentUser!.uid)
                      .get()
                      .then((value) {
                    if (value.exists) {
                      Map<String, dynamic>? data = value.data();
                      var user = GroceryUser.fromMap(value.data() as Map);

                      var userbalance = data?['privacy'];
                      var isComplete = data?['profileCompleted'];
                      ////
                      if (isComplete != true) {
                        Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) => UserAccountScreen(
                                      user: user,
                                      firstLogged: true,
                                    )));
                      } else {
                        if (userbalance != true) {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) =>
                                      PrivacyScreen(user: user)));
                        } else {
                          Navigator.pushAndRemoveUntil(
                              context,
                              MaterialPageRoute(
                                  builder: (BuildContext context) => HomeScreen(
                                        user2: widget.loggedUser!,
                                      )),
                              (route) => false);
                        }
                      }
                    }
                  });
                },
                text: getTranslated(context, 'start'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
