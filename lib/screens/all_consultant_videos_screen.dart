import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/models/user.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_constat.dart';
import '../config/paths.dart';
import '../widget/firebase_video_player_widget.dart';
import '../widget/videoWidget.dart';

class AllConsultantVideosScreen extends StatefulWidget {
  GroceryUser consultant;

  AllConsultantVideosScreen({super.key, required this.consultant});

  @override
  State<AllConsultantVideosScreen> createState() =>
      _AllConsultantVideosScreenState();
}

class _AllConsultantVideosScreenState extends State<AllConsultantVideosScreen> {
  late Size size;
  String lang = "";
  List<String> vidLinks = [];

  Future<Map<String, dynamic>?> getFirstLinkForConsultUid() async {
    // Reference to the collection
    CollectionReference videoList =
        FirebaseFirestore.instance.collection("VideoList");

    try {
      // Query the collection for a specific consultUid
      log("UID:   ${widget.consultant.uid.toString()}");
      var querySnapshot = await videoList
          .where('consultUid', isEqualTo: widget.consultant.uid)
          .get();
      for (var doc in querySnapshot.docs) {
        // Do something with each document
        Map<String, dynamic> x = doc.data() as Map<String, dynamic>;
        print("Docccccc: ${doc.data()}");
        print("Linkkkkkk: ${x["link"]}");
        vidLinks.add(x["link"]);
      }
      print("List Length : ${vidLinks.length}");
      setState(() {});
    } catch (e) {
      print("Error getting document: $e");
      return null; // Return null if there's an error
    }
  }

  @override
  void initState() {
    super.initState();
    getFirstLinkForConsultUid();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
      body: Column(
        children: [
          SizedBox(
            height: AppSize.h16.h,
          ),
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 0
                        : AppPadding.p20,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p20,
                    top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p58.h
                        : AppPadding.p10,
                    bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p41.h
                        : AppPadding.p0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(child: CustomBackButton()),
                    SizedBox(width: AppSize.w34.w),
                    Text(
                      getTranslated(context, "allVideos"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s34.sp
                                : AppFontsSizeManager.s21_3.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black1,
                      ),
                    ),
                  ],
                ),
              ))),
          SizedBox(
            height: AppSize.h16.h,
          ),
          Container(
            width: double.infinity,
            height: AppSize.h1.h,
            color: AppColors.grey2,
          ),
          SizedBox(
            height: AppSize.h21_3.h,
          ),
          widget.consultant!.link != null
              ? ClipRRect(
                  borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                  child: Container(
                      width: AppSize.w509_3.w,
                      height: AppSize.h230_6.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                      ),
                      child: widget.consultant!.link!.contains('firebase')
                          ? FirebaseVideoPlayerWidget(
                              widget.consultant!.link,
                            )
                          : VideoWidget(
                              link: widget.consultant!.link.toString(),
                              VideoAppid: widget.consultant.link
                                  .toString()
                                  .substring(
                                      widget.consultant!.link
                                              .toString()
                                              .indexOf("=") +
                                          1,
                                      widget.consultant!.link
                                          .toString()
                                          .length),
                            )),
                )
              : SizedBox(),
          SizedBox(
            height: AppSize.h21_3.h,
          ),
          vidLinks.length > 0
              ? Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                    child: Container(
                        width: AppSize.w509_3.w,
                        height: AppSize.h230_6.h,
                        decoration: BoxDecoration(
                          borderRadius:
                              BorderRadius.circular(AppRadius.r10_6.r),
                        ),
                        child: vidLinks[0].contains('firebase')
                            ? FirebaseVideoPlayerWidget(
                                vidLinks[0],
                              )
                            : VideoWidget(
                                link: vidLinks[0].toString(),
                                VideoAppid: widget.consultant.link
                                    .toString()
                                    .substring(
                                        vidLinks[0].toString().indexOf("=") + 1,
                                        vidLinks[0].toString().length),
                              )),
                  ),
                )
              : SizedBox(),
          SizedBox(
            height: AppSize.h21_3.h,
          ),
          vidLinks.length == 2
              ? Center(
                  child: ClipRRect(
                    borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                    child: Expanded(
                      child: Container(
                          width: AppSize.w509_3.w,
                          height: AppSize.h230_6.h,
                          decoration: BoxDecoration(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: vidLinks[1].contains('firebase')
                              ? FirebaseVideoPlayerWidget(
                                  vidLinks[1],
                                )
                              : VideoWidget(
                                  link: vidLinks[1].toString(),
                                  VideoAppid: widget.consultant.link
                                      .toString()
                                      .substring(
                                          vidLinks[1].toString().indexOf("=") +
                                              1,
                                          vidLinks[1].toString().length),
                                )),
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }
}
