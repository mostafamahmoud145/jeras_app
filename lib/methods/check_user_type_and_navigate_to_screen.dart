import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/methods/navigation_method.dart';
import '../config/paths.dart';
import '../models/user.dart';
import '../screens/consultRules.dart';
import '../app/authentication/view/screens/verification_success_screen.dart';
import '../services/app_flyer_service.dart';
import 'get_device_type.dart';

/// check the user type.
/// after signing in, [checkUserTypeAndNavigateToScreens] method is called,
/// to check if the user is new user or old user,
/// if new user => create initial data to him in firebase,
/// and navigate to his profile to complete his information.
///
/// if old user => navigate to home screen.
/// if the user blocked => logout.
///

Future<String?> checkUserTypeAndNavigateToScreens({
  required String phoneNumber,
  required String userType,
  required String uid,
  required BuildContext context,
  required String countryCode,
  required String isoCode,
  required Function onError,
  required Function onNavigate,
}) async {
  try {
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .where('phoneNumber', isEqualTo: phoneNumber)
        .get()
        .then((value) async {
      if (value.size > 0) {
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(uid)
            .set({
          'countryCode': countryCode,
          'countryISOCode': isoCode,
          'deviceType': kIsWeb ? "web" : await getDeviceType()
        }, SetOptions(merge: true));
        // accountBloc.add(GetLoggedUserEvent());
        String eventName = "af_login";
        Map eventValues = {};
        addEvent(eventName, eventValues);
        Map<String, dynamic> data = value.docs[0].data();
        Map<String, dynamic>? data2 = value.docs[0].data();
        if (data['isBlocked'] != null && data['isBlocked']) {
          AppFlyerService().clear();
          await FirebaseAuth.instance.signOut();
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
          onNavigate();
        } else if (data['profileCompleted'] != null &&
            data['profileCompleted']) {
          await AppFlyerService()
              .initAppFlyerUser(FirebaseAuth.instance.currentUser!.uid);
          var user = GroceryUser.fromMap(data2);

          onNavigate();
          navigateTo(
              context,
              VerificationSuccessScreen(
                loggedUser: user,
              ));
        } else {
          DocumentReference docRef =
              FirebaseFirestore.instance.collection(Paths.usersPath).doc(uid);
          final DocumentSnapshot documentSnapshot = await docRef.get();
          var user = GroceryUser.fromMap(documentSnapshot.data() as Map);
          Video video = Video();
          if (user.userType == "CONSULTANT") {
            onNavigate();
            navigateTo(
                context,
                consultRuleScreen(
                  user: user,
                  video: video,
                ));
          } else {
            await AppFlyerService()
                .initAppFlyerUser(FirebaseAuth.instance.currentUser!.uid);

            onNavigate();
            navigateTo(
                context,
                VerificationSuccessScreen(
                  loggedUser: user,
                ));
          }
        }
      } else {
        //user nit found-create user and save it
        String eventName = "af_complete_registration";
        Map eventValues = {
          "af_registration_method": "phone number",
        };
        addEvent(eventName, eventValues);
        DocumentReference ref =
            FirebaseFirestore.instance.collection(Paths.usersPath).doc(uid);
        var data = {
          'accountStatus': 'NotActive',
          'userLang': 'ar',
          'profileCompleted': false,
          'isBlocked': false,
          'uid': uid,
          'name': "",
          'email': " ",
          'phoneNumber': phoneNumber,
          'photoUrl': '',
          'tokenId': "",
          'loggedInVia': "mobile",
          "userType": userType,
          'deviceType': await getDeviceType(),
          "languages": [],
          "countryCode": countryCode,
          "countryISOCode": isoCode,
          "createdDate": Timestamp.now(),
          'utcTime': DateTime.now().toUtc().toString(),
          'date': {
            'day': DateTime.now().day,
            'month': DateTime.now().month,
            'year': DateTime.now().year,
          },
          "createdDateValue": DateTime(
                  DateTime.now().year, DateTime.now().month, DateTime.now().day)
              .millisecondsSinceEpoch,
        };
        ref.set(data, SetOptions(merge: true));
        final DocumentSnapshot currentDoc = await ref.get();
        var user = GroceryUser.fromMap(currentDoc.data() as Map);

        if (user.userType == "CONSULTANT") {
          onNavigate();
          Video video = Video();
          navigateTo(context, consultRuleScreen(user: user, video: video));
        } else {
          /**
           * DEEP LINK LOGIC
           */
          await AppFlyerService()
              .updateCurrentUserDeepLinkDataAtRegistration(uid);
          await AppFlyerService()
              .initAppFlyerUser(FirebaseAuth.instance.currentUser!.uid);

          onNavigate();
          navigateTo(
              context,
              VerificationSuccessScreen(
                loggedUser: user,
              ));
        }
      }
    }).catchError((err) {
      onError();
    });
  } catch (e) {
    onError();
    return null;
  }
  return null;
}

addEvent(String eventName, Map eventValues) async {
  if (eventName == "af_login")
    await FirebaseAnalytics.instance.logLogin(
      loginMethod: "phone",
    );
  else
    await FirebaseAnalytics.instance.logSignUp(
      signUpMethod: "phone",
    );
}
