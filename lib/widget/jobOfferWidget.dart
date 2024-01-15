import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/paths.dart';
import '../models/job.dart';
import '../models/user.dart';
import '../screens/job/jobDetailsScreen.dart';

class JobsOffersItem extends StatefulWidget {
  final Job job;
  final GroceryUser loggedUser;
  JobsOffersItem({required this.job, required this.loggedUser});

  @override
  _JobsOffersItemState createState() => _JobsOffersItemState();
}

class _JobsOffersItemState extends State<JobsOffersItem>
    with SingleTickerProviderStateMixin {
  bool open = false, dealting = false;
  String lang = "ar";
  int length = 3;
  @override
  void initState() {
    super.initState();
    if (widget.job.interests.length < 3) length = widget.job.interests.length;
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return InkWell(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => JobDetailsScreen(
              job: widget.job,
              loggedUser: widget.loggedUser,
            ),
          ),
        );
      },
      child: Container(
        width: size.width,
        // height: AppSize.h449_3.h,
        padding: EdgeInsets.symmetric(
            horizontal: checkIfWeb(context)
                ? AppPadding.p40.w
                : convertPtToPx(AppPadding.p18.w)),
        decoration: BoxDecoration(
          color: AppColors.white,
          borderRadius: BorderRadius.circular(
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppRadius.r45.r
                  : AppRadius.r33.r),
          boxShadow: [
            BoxShadow(
                color: AppColors.primaryColor.withOpacity(0.19),
                offset: Offset(0, convertPtToPx(10.w)),
                blurRadius: checkIfWeb(context) ? 25.w : convertPtToPx(25.w),
                spreadRadius: 0)
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSize.h30_6.h,
            ),
    
            ///title
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Expanded(
                  child: Text(
                    widget.job.title,
                    textAlign: TextAlign.start,
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                    style: TextStyle(
                      fontFamily: "NotoKufiArabic-SemiBold",
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s28.sp
                              : convertPtToPx(AppFontsSizeManager.s16.sp),
                      height: 1.5,
                      fontWeight: FontWeight.w600,
                      color: AppColors.primaryColor,
                    ),
                  ),
                ),
                SizedBox(width: AppSize.w8.w),
                Row(
                  children: [
                    Text(
                      DateTime.parse(widget.job.utcTime)
                              .toUtc()
                              .hour
                              .toString() +
                          ":" +
                          DateTime.parse(widget.job.utcTime)
                              .toUtc()
                              .minute
                              .toString(), // DateFormat.jm("ar").format(
    
                      textAlign: TextAlign.start,
                      textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.grey6,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s16.sp
                                : convertPtToPx(AppFontsSizeManager.s11.sp),
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                    Text(
                      " ${DateTime.parse(widget.job.utcTime).toUtc().hour > 12 ? getTranslated(context, "pm") : getTranslated(context, "am")} ",
                      textAlign: TextAlign.start,
                      // textDirection: TextDirection.ltr,
                      style: TextStyle(
                        fontFamily: "NotoKufiArabic-Regular",
                        color: AppColors.grey6,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s16.sp
                                : AppFontsSizeManager.s16.sp,
                        fontWeight: FontWeight.normal,
                      ),
                    ),
                  ],
                ),
              ],
            ),
    
            Divider(
              height: AppSize.h32.h,
              color: AppColors.greyShade300,
            ),
            SizedBox(
              height: AppSize.h5.h,
            ),
            Text(
              getTranslated(context, "jobDesc"),
              style: TextStyle(
                  fontFamily: "NotoKufiArabic-SemiBold",
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s24.sp
                      : AppFontsSizeManager.s18_6.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black4),
            ),
            SizedBox(
              height: AppSize.h16.h,
            ),
            SizedBox(
              // height: AppSize.h129.h,
              child: Text(
                widget.job.desc,
                textAlign: TextAlign.start,
                maxLines: 6,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                  fontFamily: "NotoKufiArabic-Regular",
                  color: Color.fromRGBO(147, 147, 147, 1),
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s16.sp
                      : AppFontsSizeManager.s16.sp,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ),
            SizedBox(
              height: AppSize.h16.h,
            ),
            Text(
              getTranslated(context, "jobInterests"),
              style: TextStyle(
                  fontFamily: "NotoKufiArabic-SemiBold",
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s24.sp
                      : AppFontsSizeManager.s18_6.sp,
                  fontWeight: FontWeight.w600,
                  color: AppColors.black4),
            ),
            SizedBox(
              height: AppSize.h16.h,
            ),
    
            /// skills
            buildInterests(),
    
            SizedBox(
              height: AppSize.h24.h,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  height: AppSize.h40.h,
                  width: AppSize.w86_6.w,
                  padding: EdgeInsets.symmetric(
                      vertical: AppPadding.p9_3.h,
                      horizontal: AppPadding.p12_6.w),
                  decoration: BoxDecoration(
                    color: AppColors.primaryColor,
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r8.r
                            : convertPtToPx(AppRadius.r4.r)),
                  ),
                  child: Center(
                    child: Text(
                      getTranslated(context, "more2"),
                      style: TextStyle(
                        fontFamily: "NotoKufiArabic-SemiBold",
                        fontSize: checkIfWeb(context)
                            ? AppFontsSizeManager.s16.sp
                            : AppFontsSizeManager.s16.sp,
                        fontWeight: FontWeight.w600,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
                Expanded(
                  child: Row(
                    mainAxisAlignment: lang == "ar"
                        ? MainAxisAlignment.end
                        : MainAxisAlignment.start,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Expanded(
                        child: Padding(
                          padding: EdgeInsets.only(
                              left: lang == "ar" ? 0 : AppPadding.p170.w),
                          child: Text(
                            widget.job.owner.name!,
                            maxLines: 2,
                            softWrap: true,
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s14.sp
                                  : AppFontsSizeManager.s9.sp,
                              fontWeight: FontWeight.bold,
                              letterSpacing: 0.1,
                              color: AppColors.blackColor,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                        width: checkIfWeb(context)
                            ? AppSize.w8.w
                            : convertPtToPx(AppSize.w8.w),
                      ),
    
                      ///image icon
                      Container(
                        height: checkIfWeb(context)
                            ? AppSize.h32.sp
                            : AppSize.h32.sp,
                        width: checkIfWeb(context)
                            ? AppSize.w32.sp
                            : AppSize.w32.sp,
                        decoration: BoxDecoration(
                          color: Color.fromRGBO(199, 198, 198, 1),
                          border: Border.all(color: Colors.white, width: 1.w),
                          shape: BoxShape.circle,
                        ),
                        child: widget.job.owner.image!.isEmpty
                            ? Icon(
                                Icons.person,
                                color: AppColors.white,
                                size: AppSize.w15,
                              )
                            : ClipRRect(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r100.r),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                      AssetsManager.iconPersonIconPath,
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:
                                      (context, error, stackTrace) => Icon(
                                    Icons.person,
                                    color: AppColors.white,
                                    size: AppSize.w15,
                                  ),
                                  image: widget.job.owner.image!,
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
                    ],
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            )
          ],
        ),
      ),
    );
  }

  Widget buildInterests() {
    List<Widget> choices = [];
    for (int x = 0; x < length; x++) {
      choices.add(Container(
        height: AppSize.h33_4.h,
        padding: EdgeInsets.only(
            left: AppPadding.p26_6.w,
            right: AppPadding.p26_6.w,
            top: AppPadding.p7_5.h,
            bottom: AppPadding.p7_5.h),
        decoration: BoxDecoration(
          color: Color.fromRGBO(245, 243, 247, 1.0),
          borderRadius: BorderRadius.circular(
              (kIsWeb || MediaQuery.of(context).size.width >= 500)
                  ? AppRadius.r20.r
                  : AppRadius.r28.r),
        ),
        child: Text(
          widget.job.interests[x].arName,
          style: TextStyle(
            fontFamily: 'NotoKufiArabic-Regular',
            color: AppColors.primaryColor,
            fontSize: checkIfWeb(context)
                ? AppFontsSizeManager.s16.sp
                : AppFontsSizeManager.s16.sp,
            fontWeight: FontWeight.w400,
          ),
        ),
      ));
    }
    return Wrap(
      spacing: 5.0,
      runSpacing: 5,
      children: choices.sublist(0, choices.length > 2 ? 2 : choices.length),
    );
  }

  confirmEndCallDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15.r),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            top: AppPadding.p20,
            bottom: AppPadding.p10),
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: AppSize.h15.h,
                ),
                Text(
                  getTranslated(context, "deleteJob"),
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s14.sp,
                    fontWeight: FontWeight.bold,
                    color: AppColors.red,
                  ),
                ),
                SizedBox(
                  height: AppSize.h10.h,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {},
                      child: Container(
                        height: AppSize.h35.h,
                        width: AppSize.w50.w,
                        padding: const EdgeInsets.all(AppPadding.p2),
                        decoration: BoxDecoration(
                          color: AppColors.lightPink,
                          borderRadius: BorderRadius.circular(AppRadius.r10.r),
                        ),
                        child: Center(
                          child: Text(
                            getTranslated(context, "no"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pink,
                                fontSize: AppFontsSizeManager.s11.sp,
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ),
                    ),
                    dealting
                        ? Center(child: CircularProgressIndicator())
                        : InkWell(
                            onTap: () async {
                              setState(() {
                                dealting = true;
                              });
                              FirebaseFirestore.instance
                                  .collection(Paths.jobsPath)
                                  .doc(widget.job.jobId)
                                  .delete();
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: 35.h,
                              width: 50.w,
                              padding: const EdgeInsets.all(2),
                              decoration: BoxDecoration(
                                color: AppColors.pink,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10.r),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "yes"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.white,
                                    fontSize: AppFontsSizeManager.s11.sp,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                  ],
                ),
              ],
            );
          },
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
