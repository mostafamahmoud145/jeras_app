import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_share/flutter_share.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:share_plus/share_plus.dart';
import 'package:url_launcher/url_launcher.dart';

import '../api/dynamicLink.dart';
import '../config/app_fonts.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../localization/language_constants.dart';
import '../localization/localization_methods.dart';
import '../main.dart';
import '../models/promoCode.dart';
import '../models/user.dart';
import '../screens/techUserDetails/userDetailsScreen.dart';

class Helper {
  static void ShowToastMessage(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: status ? AppColors.red : AppColors.green,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  static payByTap(GroceryUser user, String price, BuildContext context,
      String initUrl) async {
    try {
      //if(user!=null&& user!.name!=null)

      // Navigator.pop(context);
      // setState(() {
      //    initialUrl=url;
      //    showPayView = true;
      // });
    } catch (e) {
      // errorLog("pay",e.toString());
      await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        "success": false,
        "reason": e.toString(),
        "userUid": user.uid
      });
      // setState(() {
      //   showPayView=false;
      //    load=false;
      // });
      Helper.ShowToastMessage(getTranslated(context, "failed"), true);
    }
  }

  static Future<int> calculateDiscount(
      TextEditingController promoController, GroceryUser user) async {
    // setState(() {
    //   checkPromo=true;
    // });
    int discount = 0;
    if (promoController.text != "") {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: true)
          .where('code', isEqualTo: promoController.text)
          .limit(1)
          .get();
      var codes = List<PromoCode>.from(
        querySnapshot.docs.map(
          (snapshot) => PromoCode.fromMap(snapshot.data() as Map),
        ),
      );

      if (codes.length > 0) {
        bool isPrimary = (codes[0].type == "primary" &&
            codes[0].promoCodeStatus &&
            user.promoList != null &&
            user.promoList!.contains(codes[0].promoCodeId) == false);
        if ((codes[0].type == "default" && codes[0].promoCodeStatus) ||
            isPrimary) {
          discount = codes[0].discount;
          //
          // setState(() {
          //   promo = codes[0];
          //   promoCodeId=promo!.promoCodeId;
          //   //checkPromo=false;
          //   //valid=true;
          //   discount=promo!.discount;
          // });
        }

        // else
        //   setState(() {
        //
        //     promoCodeId="";
        //    // checkPromo=false;
        //    // valid=false;
        //     discount=codes[0].discount;
        //   });
      } else {
        discount = 0;
        // setState(() {
        //
        // promo = null;
        //promoCodeId="";
        //checkPromo=false;
        //valid=false;

        //});
      }
    }
    return discount;
  }

  static addEvent(String eventName, Map eventValues) async {
    // if (Platform.isIOS) {
    //   Map<String, Object> appsFlyerOptions = {
    //     "afDevKey": "S5MWquwKPo3DXx3PrxXECo",
    //     "afAppId": "id1612021922",
    //     "isDebug": true
    //   };
    //   appsflyerSdk = AppsflyerSdk(appsFlyerOptions);
    //   appsflyerSdk.initSdk(
    //       registerConversionDataCallback: true,
    //       registerOnAppOpenAttributionCallback: true,
    //       registerOnDeepLinkingCallback: true
    //   );
    // }
  }

  static Future<File?> pickImage(
      {required BuildContext context, bool? isGallery}) async {
    isGallery ??= await Helper.getImageSource(
      context,
    );
    if (isGallery == null) return null;
    final XFile? file = await ImagePicker().pickImage(
        source: isGallery ? ImageSource.gallery : ImageSource.camera,
        imageQuality: 65);
    if (file != null) return File(file.path);
    return null;
  }

  static Future<bool?> getImageSource(BuildContext context,
      {bool isImage = true}) async {
    bool? isGallery;
    await showCupertinoModalPopup(
        context: context,
        barrierDismissible: true,
        useRootNavigator: true,
        builder: (context) {
          return CupertinoAlertDialog(
            title: Padding(
              padding: EdgeInsets.all(10),
              child: Text(
                  isImage
                      ? getTranslated(context, 'choose_image_source')
                      : getTranslated(context, 'choose_video_source'),
                  style: TextStyle(color: AppColors.pink, fontSize: 20)),
            ),
            actions: [
              Material(
                  color: Colors.grey.shade200,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      isGallery = true;
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Text(
                          getTranslated(context, 'from_gallery'),
                          style:
                              TextStyle(color: AppColors.black87, fontSize: 18),
                        )),
                  )),
              Material(
                  color: Colors.grey.shade200,
                  child: InkWell(
                    onTap: () {
                      Navigator.of(context).pop();
                      isGallery = false;
                    },
                    child: Container(
                        alignment: Alignment.center,
                        padding:
                            EdgeInsets.symmetric(horizontal: 10, vertical: 20),
                        child: Text(
                          getTranslated(context, 'from_camera'),
                          style:
                              TextStyle(color: AppColors.black87, fontSize: 18),
                        )),
                  )),
            ],
          );
        });
    return isGallery;
  }

  static openwhatsapp() async {
    var whatsapp = "+966554925139";
    // var whatsappURl_android = "whatsapp://send?phone=" +
    //     whatsapp +
    //     "&text=مرحباً تطبيق غراس، كنت أريد الاستفسار عن";

            var message = Uri.encodeFull('مرحباً تطبيق غراس، كنت أريد الاستفسار عن');

            var whatsappUrl = "https://wa.me/$whatsapp/?text=$message";

    await launchUrl(Uri.parse(whatsappUrl));
  }

  static Future inviteAFriend() async {
    await FlutterShare.share(
        title: 'غراس  - Jeras',
        text:
            'غراس  - Jeras \n يمكنك تحميل تطبيق غراس من خلال موقعنا الرسمي You can get Jeras app from our website ',
        linkUrl: 'https://www.jeras.io/',
        chooserTitle: 'غراس  - Jeras');
  }

  static shareApp(BuildContext context) async {
    try {
      String appUrl = "https://app-jeras.web.app";

      String url = await dynamicLinks.shareAppbyDynamicLink(appUrl, context);
      Share.share(url); //${dynamicLink.shortUrl.toString()}
    } catch (e) {}
  }

  static Future<bool> initiateSearch(
      BuildContext context, String text, GroceryUser loggedUser) async {
    // setState(() {
    //   load = true;
    // });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .where(
          'phoneNumber',
          isEqualTo: text,
        )
        .limit(1)
        .get();
    if (querySnapshot.docs.length != 0) {
      var userSearch = GroceryUser.fromMap(querySnapshot.docs[0].data() as Map);
      // setState(() {
      //   load = false;
      // });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => UserDetailsScreen(
            user: userSearch,
            loggedUser: loggedUser,
          ),
        ),
      );
      return true;
    } else {
      return false;
      // setState(() {
      //   load = false;
      //   wrongNumber = true;
      // });
    }
  }

  static Future<int> checkJob(GroceryUser loggedUser) async {
    try {
      QuerySnapshot snapshot = await FirebaseFirestore.instance
          .collection(Paths.jobsPath)
          .where('status', isEqualTo: "new")
          .where('interestsIds', arrayContainsAny: loggedUser.interestListIds)
          .orderBy('utcTime', descending: true)
          .get();
      return snapshot.docs.length;
    } catch (e) {
      return 0;
    }
  }

  static changelanguage(BuildContext context,
      {required String lang,
      required String code,
      required AccountBloc accountBloc}) async {
    await setLocale(lang);
    Locale _temp = Locale(lang, code);
    MyApp.setLocale(context, _temp);
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(FirebaseAuth.instance.currentUser!.uid)
          .set({
        'userLang': lang,
      }, SetOptions(merge: true));
      accountBloc.add(GetLoggedUserEvent());
    }
  }

  static showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        backgroundColor: AppColors.red,
        textColor: AppColors.white);
  }

  static bool checkAvaliable(GroceryUser consult) {
    var _now = DateTime.now();
    bool available = false;
    try {
      if (consult.userType == "CONSULTANT" &&
          consult.profileCompleted == true) {
        String dayNow = _now.weekday.toString();
        int timeNow = _now.hour;
        if (consult.workDays!.contains(dayNow)) {
          if (int.parse(consult.workTimes![0].from!) <= timeNow &&
              int.parse(consult.workTimes![0].to!) > timeNow) {
            available = true;
          }
        }
      } else
        available = false;
    } catch (exception) {
      available = false;
    }

    return available;
  }
}
