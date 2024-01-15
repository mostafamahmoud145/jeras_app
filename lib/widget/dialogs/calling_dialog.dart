import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_database/firebase_database.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/blocs/jitsi_meet/start_call_screen.dart';
import 'package:jeras/services/call_services.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';

showCallingDialog(
    {required context, required String callerId, required String receiverId, required String callerName}) {
  return showDialog(
    builder: (context) {

    FirebaseDatabase.instance
        .ref('userCallState')
        .child(FirebaseAuth.instance.currentUser!.uid)
        .child('callState')
        .onValue
        .listen((event) {
      if (event.snapshot.value == 'closed' || event.snapshot.value == 'refused'){
        Navigator.pop(context);
      }});

      return JerasDialogWidget(
      dialogContent: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          SizedBox(width: 140.w),

          /// app logo
          ///
          Image.asset(
            AssetsManager.whiteJerasLogoIconPath,
            width: 65,
            height: 65,
          ),
          SizedBox(height: AppSize.h21_3.h),
          Text(
            callerName,
            style: TextStyle(
              fontFamily: getTranslated(context, 'Ithra'),
              fontSize: AppFontsSizeManager.s21_3.sp,
              color: AppColors.linear2,
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w700,
            ),
          ),

          SizedBox(
            height: AppSize.h32.h,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              InkWell(
                onTap: () {
                  ///
                  Navigator.pushReplacement(
                      context,
                      MaterialPageRoute(
                          builder: (context) => StartCallScreen(
                                isWeb: true,
                            callerId: callerId,
                              )));
                  // Navigator.pushReplacementNamed(context, '/startCallScreen');
                },
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppColors.green2,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(AssetsManager.whiteCallIconPath, color: Colors.white,),
                  ),
                ),
              ),
              InkWell(
                onTap: () async {
                  CallServices.refuseCall(state: 'refused', callerId: callerId)
                      .then((value) {
                    Navigator.pop(context);
                  });
                },
                child: CircleAvatar(
                  radius: 40.r,
                  backgroundColor: AppColors.red,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: SvgPicture.asset(AssetsManager.whiteCall2IconPath),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
    },
    barrierDismissible: false,
    context: context,
  );
}
