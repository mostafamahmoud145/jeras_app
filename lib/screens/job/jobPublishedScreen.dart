import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_slidable/flutter_slidable.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/screens/job/addJobScreen.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/job.dart';
import '../../models/user.dart';
import '../../widget/jobListItem.dart';

class JobPublishedListScreen extends StatefulWidget {
  final GroceryUser user;

  const JobPublishedListScreen({
    Key? key,
    required this.user,
  }) : super(key: key);

  @override
  _JobPublishedListScreenState createState() => _JobPublishedListScreenState();
}

class _JobPublishedListScreenState extends State<JobPublishedListScreen>
    with SingleTickerProviderStateMixin {
  bool load = false;
  late Size size;
  late String lang;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Container(
        width: double.infinity,
        child: Column(
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p142.w
                          : AppPadding.p20,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p142.w
                          : AppPadding.p20,
                      top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p58.h
                          : AppPadding.p10,
                      bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p100.h
                          : AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(),
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w34.w
                                  : AppSize.w21_3.w),
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? SizedBox()
                          : Text(
                              getTranslated(context, "jobPublished"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s34.sp
                                    : AppFontsSizeManager.s21_3.sp,
                                fontWeight: FontWeight.bold,
                                color: AppColors.black1,
                              ),
                            ),
                    ],
                  ),
                ))),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? SizedBox()
                : Center(
                    child: Container(
                        color: AppColors.lightGrey,
                        height: AppSize.h1,
                        width: size.width)),
            // SizedBox(height: AppSize.h12.h),
            Expanded(
              child: PaginateFirestore(
                separator: SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? 0
                      : AppSize.h20.h,
                ),
                itemBuilderType: PaginateBuilderType.listView,
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppPadding.p0_06
                        : AppPadding.p32.w,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppPadding.p0_06
                        : AppPadding.p32.w,
                    bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 0
                        : AppPadding.p16,
                    top: AppPadding.p37_3.h),
                itemBuilder: (context, documentSnapshot, index) {
                  final job =
                      Job.fromMap(documentSnapshot[index].data() as Map);
                  if (index == 0) {
                    return Column(
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              getTranslated(context, "delAll"),
                              style: TextStyle(
                                fontFamily: 'NotoKufiArabic-SemiBold',
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.grey_dark,
                                fontWeight: FontWeight.w600,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            SizedBox(
                              width: AppSize.w32.w,
                              height: AppSize.h32.h,
                              child: ElevatedButton(
                                onPressed: () {
                                  deleteAllAdsDialoge(size);
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: AppColors.white,
                                  foregroundColor:
                                      Color.fromRGBO(215, 82, 82, 1),
                                  padding: EdgeInsets.all(0),
                                  elevation: 0,
                                ),
                                child: SvgPicture.asset(
                                  AssetsManager.delete1IconPath,
                                  width: AppSize.w32.w,
                                  height: AppSize.h32.h,
                                ),
                              ),
                            )
                          ],
                        ),
                        job.approved!
                            ? JobListItem(
                                job: job, index: index, loggedUser: widget.user)
                            : SizedBox.shrink()
                      ],
                    );
                  } else
                    return job.approved!
                        ? JobListItem(
                            job: job, index: index, loggedUser: widget.user)
                        : SizedBox.shrink();
                },
                query: FirebaseFirestore.instance
                    .collection(Paths.jobsPath)
                    .where('owner.uid', isEqualTo: widget.user.uid)
                    .orderBy('utcTime', descending: true),
                isLive: true,
                onEmpty: Padding(
                  padding: EdgeInsets.only(
                    right: AppPadding.p34.w,
                    left: AppPadding.p20.w,
                  ),
                  child: Column(
                    children: [
                      SizedBox(
                        height: AppSize.h28.h,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            getTranslated(context, "addAdvertisement"),
                            style: TextStyle(
                                fontFamily: 'NotoKufiArabic-SemiBold',
                                fontSize: AppFontsSizeManager.s21_3.sp,
                                color: AppColors.black),
                          ),
                          IconButton(
                            onPressed: () {
                              // Navigator.push(
                              //   context,
                              //   MaterialPageRoute(
                              //       builder: (context) => AddJobScreen(
                              //             loggedUser: FirebaseAuth.instance.currentUser,
                              //           )),
                              // );
                            },
                            icon: Icon(
                              Icons.add_circle_outline_outlined,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        height: AppSize.h325_3.h,
                      ),
                      SvgPicture.asset(
                        AssetsManager.editFile,
                        height: AppSize.h61_3.h,
                        width: AppSize.h74_6.w,
                      ),
                      SizedBox(
                        height: AppSize.h32.h,
                      ),
                      Text(
                        getTranslated(context, 'Noads'),
                        style: TextStyle(
                            fontFamily: 'NotoKufiArabic-SemiBold',
                            fontSize: AppFontsSizeManager.s32.sp,
                            color: AppColors.greyDark),
                      ),
                      Spacer(),
                    ],
                  ),
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  deleteAllAdsDialoge(Size size) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    AssetsManager.moveCloseIconPath,
                    width: AppSize.w32.w,
                    height: AppSize.h32.h,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h33_3.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "DoYouWantDeleteAllAds"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h42_6.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          var querySnapshot = await FirebaseFirestore.instance
                              .collection(Paths.jobOffersPath)
                              .where('jobOwnerUid', isEqualTo: widget.user.uid)
                              .get();

                          for (var doc in querySnapshot.docs) {
                            await FirebaseFirestore.instance
                                .collection(Paths.jobOffersPath)
                                .doc(doc.id)
                                .delete();
                          }

                          var querySnapshot1 = await FirebaseFirestore.instance
                              .collection(Paths.jobsPath)
                              .where('owner.uid', isEqualTo: widget.user.uid)
                              .get();

                          for (var doc1 in querySnapshot1.docs) {
                            await FirebaseFirestore.instance
                                .collection(Paths.jobsPath)
                                .doc(doc1.id)
                                .delete();
                          }
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.linear2,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'delete'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.white,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      //SizedBox(width: AppSize.w57_3.w),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10_6.r)),
                              border: Border.all(
                                color: AppColors.linear2,
                                width: 1.5.w,
                              )),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'cancel'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.linear2,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
