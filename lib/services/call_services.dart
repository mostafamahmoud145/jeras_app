

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';

import '../blocs/web_rtc_bloc/start_call.dart';
import '../config/app_fonts.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../methods/change_user_call_state.dart';
import '../methods/convert_pt_to_px.dart';
import '../models/AppAppointments.dart';
import '../models/user.dart';
//import 'dart:js' as js;


class CallServices{


  /// refused the incoming calls.
  static Future <void> refuseCall({
    required String state,
     BuildContext ? context,
    required String callerId,

  }) async{
    // CallKeep.instance.endAllCalls().then((value) {
      ///================== change caller and user state to refused, then show dialog to current user contains (refused) ================///

      changeUserState(userId: callerId, state: state);
      changeUserState(userId: FirebaseAuth.instance.currentUser!.uid, state: state);

      if(context != null)
        ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          backgroundColor: AppColors.white,
          content: Container(
            //height: 200,
            width: double.infinity,
            padding: EdgeInsets.all(20.w),
            decoration: BoxDecoration(
              color: AppColors.pink,
              borderRadius: BorderRadius.circular(12.r),
            ),
            child: Text(
              getTranslated(context, 'userRefuse'),
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontWeight: AppFontsWeightManager.semiBold,
                fontFamily: getTranslated(context, getTranslated(context, "Ithra")),
                color: AppColors.white,
                fontSize: convertPtToPx(13.sp),
              ),
            ),
          ),
        ),
      );

    }
  // }



  /// start incoming calls when the user press accept button on calling dialog.
  static Future<void> startCall({
    required String appointmentId,
    required String callerId,
    required BuildContext context,
  }) async{

    changeUserState(userId: FirebaseAuth.instance.currentUser!.uid, state: 'oncall')
        .then((value) {
      FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(appointmentId)
          .get()
          .then((appointment) {

        getUserFromFirebase(userId: FirebaseAuth.instance.currentUser!.uid).then((user) {
          Future(() =>
              StartCall(
                  host: appointmentId,
                  iscaller: false,
                  isVideo: false,
                  loggedUser: user,
                  appointment: AppAppointments.fromMap(appointment.data() as Map<dynamic, dynamic>),
                  normalCall: false,
                  CallerId: callerId,
                  ReciverId: FirebaseAuth.instance.currentUser!.uid,
                  context: context)
                  .startCall());
        });

      });
    });
  }



  static Future<void> startWebCall({required String callerId}) async{
    await FirebaseFirestore.instance.collection('servers').doc('settings').get().then((value) async {
      String serverUrl = value.data()!['jitsiServer'];
      String jitsiToken = value.data()!['jitsiToken'];
      String webFeatures = value.data()!['webFeatures'];
      await changeUserState(
          userId: FirebaseAuth.instance.currentUser!.uid, state: 'oncall');
      // js.context.callMethod('open', ['$serverUrl/$callerId?jwt=$jitsiToken#$webFeatures']);
    });
  }


}



Future<GroceryUser?> getUserFromFirebase({required String userId}) async{
  await FirebaseFirestore.instance
      .collection(Paths.usersPath)
      .doc(FirebaseAuth.instance.currentUser!.uid)
      .get().then((value) {
        return GroceryUser.fromMap(value.data() as Map<dynamic, dynamic>);
      });
  return null;
}