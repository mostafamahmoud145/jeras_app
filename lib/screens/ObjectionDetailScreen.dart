import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../models/Objections.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';

class ObjectionDetailsScreen extends StatefulWidget {
  final Objections item;

  const ObjectionDetailsScreen({required this.item});

  @override
  _ObjectionDetailsScreenState createState() => _ObjectionDetailsScreenState();
}

class _ObjectionDetailsScreenState extends State<ObjectionDetailsScreen> {
  bool adding = false, saving = false;

  @override
  void initState() {
    super.initState();
  }

  updateStatus() async {
    setState(() {
      adding = true;
    });
    await FirebaseFirestore.instance
        .collection(Paths.objectionsPath)
        .doc(widget.item.objectionId)
        .set({
      'objectionStatus': true,
    }, SetOptions(merge: true));
    setState(() {
      adding = false;
    });
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton1(
                            onPress: Navigator.of(context).pop,
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w97.w
                                : AppSize.w50_6.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h97.h
                                : AppSize.h50.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r24.r
                                : AppRadius.r10_6.r,
                            IconWidth: AppSize.w32.w,
                            IconHeight: AppSize.h32.h,
                            IconColor: Theme.of(context).primaryColor,
                            Icon:
                                AssetsManager.blackArrowRightIconPath,
                            ButtonBackground: AppColors.white,
                          ),
                          const SizedBox(width: AppSize.w10),
                          Text(
                            getTranslated(context, "details"),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: AppFontsWeightManager.bold300,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s31.sp
                                  : AppFontsSizeManager.s15.sp,
                              color:AppColors.black2,
                            ),
                          ),
                        ],
                      ),
                      InkWell(
                        onTap: () {
                          Clipboard.setData(ClipboardData(
                              text: widget.item.appointmentId +
                                  "\n" +
                                  widget.item.objectionId +
                                  "\n" +
                                  widget.item.consult.name! +
                                  "\n" +
                                  widget.item.consult.phone! +
                                  "\n" +
                                  widget.item.user.name! +
                                  "\n" +
                                  widget.item.user.phone! +
                                  "\n"));
                          Fluttertoast.showToast(
                              msg: getTranslated(context, "textCopy"),
                              toastLength: Toast.LENGTH_SHORT,
                              gravity: ToastGravity.BOTTOM,
                              backgroundColor: AppColors.red,
                              textColor: AppColors.white,
                              fontSize: AppFontsSizeManager.s16);
                        },
                        child: Icon(
                          Icons.copy,
                          size: AppSize.w18,
                          color: AppColors.pink,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: AppSize.h1, width: size.width)),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p20),
              children: <Widget>[
                SizedBox(
                  height:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.height * AppSize.h0_05 : AppSize.h16,
                ),
                Center(
                  child: Container(
                    height: AppSize.h150,
                    width: size.width * AppSize.w0_9,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.r25),
                      border: Border.all(color: AppColors.white, width: AppSize.w2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grey,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              0.0, 1.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
                            borderRadius: BorderRadius.circular(AppRadius.r25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: AppPadding.p10, right: AppPadding.p10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated(context, "consultDetails"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.pink,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: widget.item.consult.name! +
                                            "\n" +
                                            widget.item.consult.phone!));
                                    Fluttertoast.showToast(
                                        msg: getTranslated(context, "textCopy"),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: AppColors.red,
                                        textColor: AppColors.white,
                                        fontSize: AppFontsSizeManager.s16);
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: AppSize.w18,
                                    color: AppColors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: AppPadding.p5,
                                  left: AppPadding.p5,
                                  right: AppPadding.p5),
                              child: Container(
                                height: AppSize.h60,
                                width: AppSize.w60,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color: AppColors.black, width: AppSize.w1),
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: widget.item.consult.image!.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color:  AppColors.black,
                                        size: AppSize.w50,
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.r100),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              AssetsManager.iconPersonIconPath,
                                          placeholderScale: 0.5,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.person,
                                            color:  AppColors.black,
                                            size: AppSize.w50,
                                          ),
                                          image: widget.item.consult.image!,
                                          fit: BoxFit.cover,
                                          fadeInDuration: Duration(
                                              milliseconds:
                                                  AppConstants.milliseconds250),
                                          fadeInCurve: Curves.easeInOut,
                                          fadeOutDuration: Duration(
                                              milliseconds:
                                                  AppConstants.milliseconds150),
                                          fadeOutCurve: Curves.easeInOut,
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Text(
                                    widget.item.consult.name!,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color:  AppColors.black,
                                      fontSize: AppFontsSizeManager.s13,
                                    ),
                                  ),
                                  Text(
                                    widget.item.consult.phone!,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color:  AppColors.black,
                                      fontSize: AppFontsSizeManager.s13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.height * AppSize.h0_05 : AppSize.h16,
                ),
                Center(
                  child: Container(
                    height: AppSize.h150,
                    width: size.width * AppSize.w0_9,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.r25),
                      border: Border.all(color: AppColors.white, width: AppSize.w2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grey,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              0.0, 1.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
                            borderRadius: BorderRadius.circular(AppRadius.r25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: AppPadding.p10, right: AppPadding.p10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated(context, "clientDetails"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.pink,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: widget.item.user.name! +
                                            "\n" +
                                            widget.item.user.phone!));
                                    Fluttertoast.showToast(
                                        msg: getTranslated(context, "textCopy"),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: AppColors.red,
                                        textColor: AppColors.white,
                                        fontSize: AppFontsSizeManager.s16);
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: AppSize.w18,
                                    color: AppColors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Padding(
                              padding: const EdgeInsets.only(
                                  top: AppPadding.p5,
                                  left: AppPadding.p5,
                                  right: AppPadding.p5),
                              child: Container(
                                height: AppSize.h60,
                                width: AppSize.w60,
                                decoration: BoxDecoration(
                                  border:
                                      Border.all(color:  AppColors.black, width: AppSize.w1),
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: widget.item.user.image!.isEmpty
                                    ? Icon(
                                        Icons.person,
                                        color:  AppColors.black,
                                        size: AppSize.w50,
                                      )
                                    : ClipRRect(
                                        borderRadius:
                                            BorderRadius.circular(AppRadius.r100),
                                        child: FadeInImage.assetNetwork(
                                          placeholder:
                                              AssetsManager.iconPersonIconPath,
                                          placeholderScale: 0.5,
                                          imageErrorBuilder:
                                              (context, error, stackTrace) =>
                                                  Icon(
                                            Icons.person,
                                            color:  AppColors.black,
                                            size:AppSize.w50,
                                          ),
                                          image: widget.item.user.image!,
                                          fit: BoxFit.cover,
                                          fadeInDuration: Duration(
                                              milliseconds:
                                                  AppConstants.milliseconds250),
                                          fadeInCurve: Curves.easeInOut,
                                          fadeOutDuration: Duration(
                                              milliseconds:
                                                  AppConstants.milliseconds150),
                                          fadeOutCurve: Curves.easeInOut,
                                        ),
                                      ),
                              ),
                            ),
                            Expanded(
                              flex: 2,
                              child: Column(
                                children: [
                                  Text(
                                    widget.item.user.name!,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color:  AppColors.black,
                                      fontSize: AppFontsSizeManager.s13,
                                    ),
                                  ),
                                  Text(
                                    widget.item.user.phone!,
                                    textAlign: TextAlign.start,
                                    overflow: TextOverflow.ellipsis,
                                    maxLines: 1,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color:  AppColors.black,
                                      fontSize: AppFontsSizeManager.s13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.height * AppSize.h0_05 : AppSize.h16,
                ),
                Center(
                  child: Container(
                    //height: 150,
                    width: size.width * AppSize.w0_9,
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(AppRadius.r25),
                      border: Border.all(color: AppColors.white, width: AppSize.w2),
                      boxShadow: [
                        BoxShadow(
                          color: AppColors.grey,
                          blurRadius: 2.0,
                          spreadRadius: 0.0,
                          offset: Offset(
                              0.0, 1.0), // shadow direction: bottom right
                        )
                      ],
                    ),
                    child: Column(
                      children: [
                        Container(
                          height: AppSize.h50,
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
                            borderRadius: BorderRadius.circular(AppRadius.r25),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: AppPadding.p10, right: AppPadding.p10),
                            child: Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                Text(
                                  getTranslated(context, "objections"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.pink,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                InkWell(
                                  onTap: () {
                                    Clipboard.setData(ClipboardData(
                                        text: widget.item.objectionId));
                                    Fluttertoast.showToast(
                                        msg: getTranslated(context, "textCopy"),
                                        toastLength: Toast.LENGTH_SHORT,
                                        gravity: ToastGravity.BOTTOM,
                                        backgroundColor: AppColors.red,
                                        textColor: AppColors.white,
                                        fontSize: AppFontsSizeManager.s16);
                                  },
                                  child: Icon(
                                    Icons.copy,
                                    size: AppSize.w18,
                                    color: AppColors.pink,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppPadding.p8),
                          child: Text(
                            widget.item.objection,
                            maxLines: 10,
                            overflow: TextOverflow.ellipsis,
                            style: GoogleFonts.poppins(
                              color:  AppColors.black.withOpacity(0.75),
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                SizedBox(
                  height:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.height * AppSize.h0_05 : AppSize.h16,
                ),
                widget.item.objectionStatus == false
                    ? adding
                        ? Center(child: CircularProgressIndicator())
                        : Center(
                            child: InkWell(
                              onTap: () {
                                updateStatus();
                              },
                              child: Container(
                                height:
                                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h60 : AppSize.h45,
                                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? size.width * AppSize.w0_15
                                    : size.width * AppSize.w0_6,
                                decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(
                                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                            ? AppRadius.r20
                                            : AppRadius.r10),
                                    gradient: LinearGradient(
                                      begin: Alignment.topCenter,
                                      end: Alignment.bottomCenter,
                                      colors: [
                                        AppColors.linear1,
                                        AppColors.linear2,
                                        AppColors.linear2,
                                      ],
                                    )),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, "closeObjection"),
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: AppColors.white,
                                      fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s25
                                          : AppFontsSizeManager.s18,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                          )
                    : SizedBox(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
