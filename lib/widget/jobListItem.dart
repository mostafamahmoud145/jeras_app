import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart' hide TextDirection;
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/paths.dart';
import '../models/job.dart';
import '../screens/job/jobDetailsScreen.dart';

class JobListItem extends StatefulWidget {
  final Job job;
  final GroceryUser loggedUser;
  final int index;

  JobListItem(
      {required this.job, required this.index, required this.loggedUser});

  @override
  _JobListItemState createState() => _JobListItemState();
}

class _JobListItemState extends State<JobListItem>
    with SingleTickerProviderStateMixin {
  bool open = false, dealting = false;
  String lang = "ar";

  @override
  void initState() {
    super.initState();
  }

  @override
//  onPressed: (BuildContext context){  },
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    lang = getTranslated(context, "lang");
    return Padding(
      padding: EdgeInsets.only(
          top: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 0 : 1.0,
          right: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 0 : 1.0,
          left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 0 : 1.0,
          bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h70.h
              : 1.0),
      child: GestureDetector(
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
        child: Slidable(
          key: UniqueKey(),
          closeOnScroll: false,
          startActionPane: ActionPane(
            closeThreshold: .5,
            dragDismissible: false,
            extentRatio: .2,
            motion: const ScrollMotion(),
            dismissible: DismissiblePane(onDismissed: () {}),
            children: [
              CustomSlidableAction(
                onPressed: (BuildContext context) {
                  confirmDeleteDialog(size);
                },
                padding: EdgeInsets.all(0),
                backgroundColor: AppColors.white,
                foregroundColor: Color.fromRGBO(215, 82, 82, 1),
                child: SvgPicture.asset(
                  AssetsManager.delete1IconPath,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h40
                      : AppSize.h32.h,
                  width: AppSize.w32.w,
                ),
                // label: 'Delete',
              ),
            ],
          ),
          child: Container(
            width: size.width,
            height: AppSize.h120.h,
            padding: EdgeInsets.only(
              left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p66_2.w
                  : AppPadding.p20.w,
              right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p66_2.w
                  : AppPadding.p20,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.r16.r),
              boxShadow: [
                BoxShadow(
                    color: const Color(0x0d202020),
                    offset: Offset(0, 6),
                    blurRadius: 18,
                    spreadRadius: 0)
              ],
            ),
            child: Padding(
              padding: EdgeInsets.symmetric(
                horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w30.h
                    : AppSize.w5,
              ),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: AppSize.h16.h,
                  ),
                  Row(
                    children: [
                      Text(
                        DateFormat('yyyy/MM/dd')
                                .format(DateTime.parse(widget.job.utcTime)) +
                            " ",
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontStyle: FontStyle.normal,
                            color: AppColors.grey6,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s25
                                : AppFontsSizeManager.s13_5.sp,
                            fontWeight: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsWeightManager.normal
                                : FontWeight.w300),
                      ),
                      SizedBox(
                    width: AppSize.w10.w,
                  ),
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
                      
                            // DateFormat.jm()
                            //     .format(DateTime.parse(widget.job.utcTime)),
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontStyle: FontStyle.normal,
                                color: AppColors.grey6,
                                fontSize: (kIsWeb ||
                                        size.width >=
                                            AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s25
                                    : AppFontsSizeManager.s13_5.sp,
                                fontWeight: (kIsWeb ||
                                        size.width >=
                                            AppConstants.kIsWebValue)
                                    ? AppFontsWeightManager.normal
                                    : FontWeight.w300),
                          ),
                          Text(
                            " ${DateTime.parse(widget.job.utcTime).toUtc().hour > 12 ? getTranslated(context, "pm") : getTranslated(context, "am")} ",
                            style: TextStyle(
                                fontFamily: "NotoKufiArabic-Regular",
                                fontStyle: FontStyle.normal,
                                color: AppColors.grey6,
                                fontSize: (kIsWeb ||
                                        size.width >=
                                            AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s25
                                    : AppFontsSizeManager.s13_5.sp,
                                fontWeight: (kIsWeb ||
                                        size.width >=
                                            AppConstants.kIsWebValue)
                                    ? AppFontsWeightManager.normal
                                    : FontWeight.w400),
                          ),
                        ],
                      ),
                    ],
                  ),
                  SizedBox(
                    height: AppSize.h16.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Image.asset(
                            AssetsManager.editOrder,
                            height: AppSize.h32.h,
                            width: AppSize.w32.w,
                          ),
                          SizedBox(
                            width: AppSize.w10.w,
                          ),
                          Text(
                            widget.job.title,
                            style: TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s35
                                  : AppFontsSizeManager.s21_3.sp,
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                        ],
                      ),
                      SvgPicture.asset(
                        AssetsManager.backIcon,
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w40.w
                                : AppSize.w20,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w40.w
                                : AppSize.w20,
                      ),
                    ],
                  ),
                  SizedBox(
                    height: AppSize.h34_9.h,
                  ),
                ],
              ),
            ),
            // ),
          ),
        ),
      ),
    );
  }

  confirmDeleteDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15),
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
                  height: AppSize.h15,
                ),
                Text(
                  getTranslated(context, "deleteJob"),
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: 14.0,
                    fontWeight: FontWeight.bold,
                    color: AppColors.black2,
                  ),
                ),
                SizedBox(
                  height: AppSize.h10,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    InkWell(
                      onTap: () async {
                        Navigator.pop(context);
                      },
                      child: Container(
                        height: AppSize.h35,
                        width: AppSize.w150,
                        padding: const EdgeInsets.all(AppPadding.p2),
                        decoration: BoxDecoration(
                          color: AppColors.lightPink,
                          borderRadius: BorderRadius.circular(AppRadius.r10),
                        ),
                        child: Center(
                          child: Text(
                            getTranslated(context, "no"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.pink,
                                fontSize: AppFontsSizeManager.s11,
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
                              var querySnapshot = await FirebaseFirestore
                                  .instance
                                  .collection("JobOffer")
                                  .where('jobId', isEqualTo: widget.job.jobId)
                                  .get();
                              for (var doc in querySnapshot.docs) {
                                await FirebaseFirestore.instance
                                    .collection("JobOffer")
                                    .doc(doc.id)
                                    .delete();
                              }
                              FirebaseFirestore.instance
                                  .collection(Paths.jobsPath)
                                  .doc(widget.job.jobId)
                                  .delete();
                              Navigator.pop(context);
                            },
                            child: Container(
                              height: AppSize.h35,
                              width: AppSize.w50,
                              padding: const EdgeInsets.all(AppPadding.p2),
                              decoration: BoxDecoration(
                                color: AppColors.pink,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r10),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "yes"),
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.white,
                                    fontSize: AppFontsSizeManager.s11,
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
