import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_shadow.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';
import '../config/paths.dart';
import '../models/consultReview.dart';
import '../screens/reviews_screen.dart';

class ReviewWidget extends StatefulWidget {
  final GroceryUser consultant;

  ReviewWidget({required this.consultant});

  @override
  _ReviewWidgetState createState() => _ReviewWidgetState();
}

class _ReviewWidgetState extends State<ReviewWidget>
    with SingleTickerProviderStateMixin {
  bool loadReviews = true;
  int reviewLength = 1;
  List<ConsultReview> reviews = [];
  String lang = "";

  @override
  void initState() {
    super.initState();
    getConsultReviews();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return (kIsWeb || size.width >= AppConstants.kIsWebValue)
        ? Container(
            padding: EdgeInsets.only(
                right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p46.w
                    : 0,
                left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p46.w
                    : 0,
                top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p30.h
                    : 0),
            decoration: BoxDecoration(
              color: AppColors.white,
              border: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? Border.all(color: AppColors.white, width: AppSize.w2.w)
                  : null,
              boxShadow: [
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppShadow.greyshadow
                    : AppShadow.fabshadow
              ],
              borderRadius: BorderRadius.circular(
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppRadius.r50.r
                      : AppRadius.r5.r),
            ),
            child: Column(
              children: [
                Center(
                  child: Container(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h75.h
                        : AppSize.h48.h,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w120.w
                        : AppSize.w217_3.w,
                    decoration: BoxDecoration(
                      border: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? Border.all(
                              color: AppColors.white, width: AppSize.w2.w)
                          : null,
                      boxShadow: [
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppShadow.fabshadow
                            : AppShadow.fabshadow
                      ],
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r25.r
                              : AppRadius.r5.r),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? SizedBox()
                            : Text(
                                getTranslated(context, "Reviews"),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s29.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? SizedBox(
                                width: AppSize.w10_6.w,
                              )
                            : SizedBox(),
                        Center(
                          //dc
                          child: SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 1,
                            rating: 1,
                            size: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h38.h
                                : AppSize.h20.h,
                            color: AppColors.yellow,
                            borderColor: AppColors.yellow,
                            spacing: 1.0,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? SizedBox(
                        height: AppSize.h56.h,
                      )
                    : SizedBox(
                        height: AppSize.h26.h,
                      ),
                Center(
                  child: Container(
                    padding: EdgeInsets.all(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? 0
                            : AppPadding.p0),
                    decoration: BoxDecoration(
                      color: AppColors.white,
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 0
                              : AppRadius.r21_3.r),
                      border: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? null
                          : Border.all(
                              color: AppColors.white, width: AppSize.w2.w),
                      // boxShadow: [AppShadow.fabshadow],
                    ),
                    child: Column(
                      children: [
                        loadReviews
                            ? Center(child: CircularProgressIndicator())
                            : SizedBox(),
                        (loadReviews == false && reviews.length == 0)
                            ? Padding(
                                padding: EdgeInsets.symmetric(
                                    vertical: AppPadding.p8.h),
                                child: Center(
                                  child: Column(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.center,
                                    children: <Widget>[
                                      SizedBox(
                                        height: AppSize.h30.h,
                                      ),
                                      Text(
                                        getTranslated(context, "noReviews"),
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: Colors.black.withOpacity(0.5),
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppFontsSizeManager.s25.sp
                                              : AppFontsSizeManager.s13.sp,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              )
                            : SizedBox(),
                        (loadReviews == false && reviews.length > 0)
                            ? ListView.separated(
                                itemCount:
                                    reviews.length > 2 ? 2 : reviews.length,
                                shrinkWrap: true,
                                physics: NeverScrollableScrollPhysics(),
                                padding: EdgeInsets.all(0),
                                itemBuilder: (context, index) {
                                  return Container(
                                    padding: const EdgeInsets.only(
                                        left: 20, right: 20, top: 10),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      children: [
                                        //image
                                        Container(
                                          padding: EdgeInsets.all((kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppPadding.p15
                                              : AppPadding.p10),
                                          decoration: BoxDecoration(
                                            shape: BoxShape.circle,
                                            color: AppColors.grey4,
                                          ),
                                          child: reviews[index].image!.isEmpty
                                              ? SvgPicture.asset(
                                                  AssetsManager.personIconPath,
                                                  width: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.w26_5.w
                                                      : AppSize.w16.w,
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h27_7.h
                                                      : AppSize.h16.h,
                                                )
                                              : ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppRadius.r100.r),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder: AssetsManager
                                                        .iconPersonIconPath,
                                                    placeholderScale: 0.5,
                                                    width: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppSize.w26_5.w
                                                        : AppSize.w15_8.w,
                                                    height: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppSize.h27_9.h
                                                        : AppSize.h16_7.h,
                                                    imageErrorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        SvgPicture.asset(
                                                      AssetsManager
                                                          .personIconPath,
                                                      width: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.w26_5.w
                                                          : AppSize.w15_8.w,
                                                      height: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.h27_9.h
                                                          : AppSize.h16_7.h,
                                                    ),
                                                    image:
                                                        reviews[index].image!,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                        ), //
                                        SizedBox(
                                            width: lang == "ar"
                                                ? AppSize.w19.w
                                                : AppSize.w25.w),
                                        Expanded(
                                          child: Container(
                                            // width: (kIsWeb ||
                                            //         size.width >=
                                            //             AppConstants.kIsWebValue)
                                            //     ? size.width * AppSize.w0_18
                                            //     : size.width * AppSize.w0_4,
                                            child: Column(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.start,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.start,
                                              children: [
                                                SizedBox(height: AppSize.h5.h),
                                                //name
                                                Text(
                                                  reviews[index].name,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: getTranslated(
                                                        context, "Ithra"),
                                                    color: AppColors.darkPurple,
                                                    fontSize: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppFontsSizeManager
                                                            .s24.sp
                                                        : AppFontsSizeManager
                                                            .s14.sp,
                                                    fontWeight:
                                                        AppFontsWeightManager
                                                            .normal,
                                                    letterSpacing: AppConstants
                                                        .letterSpacing0_5,
                                                  ),
                                                ),
                                                //sub
                                                SizedBox(
                                                    height: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppSize.h2.h
                                                        : AppSize.h5.h),
                                                Text(
                                                  reviews[index].review!,
                                                  maxLines: 1,
                                                  overflow:
                                                      TextOverflow.ellipsis,
                                                  style: TextStyle(
                                                    fontFamily: getTranslated(
                                                        context, "Ithra"),
                                                    color: AppColors.darkGrey9,
                                                    fontSize: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppFontsSizeManager
                                                            .s19.sp
                                                        : AppFontsSizeManager
                                                            .s12.sp,
                                                    fontWeight:
                                                        FontWeight.normal,
                                                    letterSpacing: AppConstants
                                                        .letterSpacing0_5,
                                                  ),
                                                ),
                                              ],
                                            ),
                                          ),
                                        ),
                                        SizedBox(width: AppSize.w25),

                                        Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.end,
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: [
                                            SmoothStarRating(
                                              allowHalfRating: true,
                                              starCount: 1,
                                              rating: 1,
                                              size: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppSize.w23.w
                                                  : 30.w,
                                              color: AppColors.yellow,
                                              borderColor: AppColors.yellow,
                                              spacing: 1.0,
                                            ),
                                            SizedBox(
                                              width: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppSize.w8_8.w
                                                  : AppSize.w2.w,
                                            ),
                                            Padding(
                                              padding: EdgeInsets.only(
                                                  top: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? 0
                                                      : AppPadding.p5.h),
                                              child: Text(
                                                reviews[index]
                                                    .rating
                                                    .toStringAsFixed(1),
                                                textAlign: TextAlign.start,
                                                style: TextStyle(
                                                  fontFamily: 'Montserrat',
                                                  color: AppColors.black,
                                                  fontSize: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppFontsSizeManager
                                                          .s24.sp
                                                      : AppFontsSizeManager
                                                          .s14.sp,
                                                  fontWeight:
                                                      AppFontsWeightManager
                                                          .bold300,
                                                ),
                                              ),
                                            ),
                                          ],
                                        )
                                      ],
                                    ),
                                  );
                                },
                                separatorBuilder:
                                    (BuildContext context, int index) {
                                  return Center(
                                      child: Container(
                                    // margin: EdgeInsets.only(top: 20),
                                    color: AppColors.grey9,
                                    width: size.width * AppSize.w0_8,
                                    height: AppSize.h1.h,
                                  ));
                                },
                              )
                            : SizedBox(),
                        SizedBox(
                          height: AppSize.h5.h,
                        ),
                        SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h41.h
                                : null),
                        Padding(
                          padding: EdgeInsets.only(
                              bottom: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 0
                                  : AppPadding.p1.h),
                          child: Row(
                            mainAxisAlignment: lang == "ar"
                                ? MainAxisAlignment.end
                                : MainAxisAlignment.start,
                            children: [
                              InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => ReviewScreens(
                                          consult: widget.consultant,
                                          reviewLength: reviewLength),
                                    ),
                                  );
                                },
                                child: Container(
                                  height:
                                      AppSize.h37_6.r, //width: size.width*.40,
                                  padding: const EdgeInsets.only(
                                      left: AppPadding.p10,
                                      right: AppPadding.p10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      SizedBox(
                                        width: AppSize.w22_6.r,
                                        child: Stack(
                                          children: [
                                            if (reviews.length >= 1)
                                              Container(
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h37_6.r
                                                    : AppSize.h22_6.r,
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h37_6.r
                                                    : AppSize.h22_6.r,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: const Color(
                                                            0x33ae9cce),
                                                        offset: Offset(0, 6),
                                                        blurRadius: 12,
                                                        spreadRadius: 0)
                                                  ],
                                                  color: AppColors.white,
                                                  border: Border.all(
                                                    width: AppSize.w6.w,
                                                    color: AppColors.white,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppRadius.r100.r),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        reviews[0].image ?? '',
                                                    //placeholderScale: 0.5,
                                                    imageErrorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      AssetsManager
                                                          .whiteJerasLogoIconPath,
                                                      height: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.h37_6.r
                                                          : AppSize.h22_6.r,
                                                      width: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.h37_6.r
                                                          : AppSize.h22_6.r,
                                                    ),
                                                    image: AssetsManager
                                                        .whiteJerasLogoIconPath,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                              ),
                                            if (reviews.length >= 2)
                                              Transform.translate(
                                                offset: Offset(15, 0),
                                                child: Container(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h37_6.r
                                                      : AppSize.h22_6.r,
                                                  width: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h37_6.r
                                                      : AppSize.h22_6.r,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: AppColors
                                                              .lightPurple,
                                                          offset: Offset(0, 6),
                                                          blurRadius: 12,
                                                          spreadRadius: 0)
                                                    ],
                                                    color: AppColors.white,
                                                    border: Border.all(
                                                      width: AppSize.w6.w,
                                                      color: AppColors.white,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppRadius.r100.r),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder:
                                                          reviews[1].image ??
                                                              '',
                                                      //placeholderScale: 0.5,
                                                      imageErrorBuilder:
                                                          (context, error,
                                                                  stackTrace) =>
                                                              Image.asset(
                                                        AssetsManager
                                                            .whiteJerasLogoIconPath,
                                                        height: (kIsWeb ||
                                                                size.width >=
                                                                    AppConstants
                                                                        .kIsWebValue)
                                                            ? AppSize.h37_6.r
                                                            : AppSize.h22_6.r,
                                                        width: (kIsWeb ||
                                                                size.width >=
                                                                    AppConstants
                                                                        .kIsWebValue)
                                                            ? AppSize.h37_6.r
                                                            : AppSize.h22_6.r,
                                                      ),
                                                      image: AssetsManager
                                                          .whiteJerasLogoIconPath,
                                                      fit: BoxFit.cover,
                                                      fadeInDuration: Duration(
                                                          milliseconds: AppConstants
                                                              .milliseconds250),
                                                      fadeInCurve:
                                                          Curves.easeInOut,
                                                      fadeOutDuration: Duration(
                                                          milliseconds: AppConstants
                                                              .milliseconds150),
                                                      fadeOutCurve:
                                                          Curves.easeInOut,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                            if (reviews.length >= 3)
                                              Transform.translate(
                                                offset: Offset(30, 0),
                                                child: Container(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h37_6.r
                                                      : AppSize.h22_6.r,
                                                  width: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h37_6.r
                                                      : AppSize.h22_6.r,
                                                  decoration: BoxDecoration(
                                                    boxShadow: [
                                                      BoxShadow(
                                                          color: AppColors
                                                              .lightPurple,
                                                          offset: Offset(0, 6),
                                                          blurRadius: 12,
                                                          spreadRadius: 0)
                                                    ],
                                                    color: AppColors.white,
                                                    border: Border.all(
                                                      width: AppSize.w6.w,
                                                      color: AppColors.white,
                                                    ),
                                                    shape: BoxShape.circle,
                                                  ),
                                                  child: ClipRRect(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            AppRadius.r100.r),
                                                    child: FadeInImage
                                                        .assetNetwork(
                                                      placeholder:
                                                          reviews[2].image ??
                                                              '',
                                                      //placeholderScale: 0.5,
                                                      imageErrorBuilder:
                                                          (context, error,
                                                                  stackTrace) =>
                                                              Image.asset(
                                                        AssetsManager
                                                            .whiteJerasLogoIconPath,
                                                        height: (kIsWeb ||
                                                                size.width >=
                                                                    AppConstants
                                                                        .kIsWebValue)
                                                            ? AppSize.h37_6.r
                                                            : AppSize.h22_6.r,
                                                        width: (kIsWeb ||
                                                                size.width >=
                                                                    AppConstants
                                                                        .kIsWebValue)
                                                            ? AppSize.h37_6.r
                                                            : AppSize.h22_6.r,
                                                      ),
                                                      image: AssetsManager
                                                          .whiteJerasLogoIconPath,
                                                      fit: BoxFit.cover,
                                                      fadeInDuration: Duration(
                                                          milliseconds: AppConstants
                                                              .milliseconds250),
                                                      fadeInCurve:
                                                          Curves.easeInOut,
                                                      fadeOutDuration: Duration(
                                                          milliseconds: AppConstants
                                                              .milliseconds150),
                                                      fadeOutCurve:
                                                          Curves.easeInOut,
                                                    ),
                                                  ),
                                                ),
                                              ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(
                                        width: lang == "ar"
                                            ? AppSize.w10.w
                                            : AppSize.w60.w,
                                      ),
                                      Container(
                                        // width: (kIsWeb ||
                                        //         size.width >= AppConstants.kIsWebValue)
                                        //     ? AppSize.w95.w
                                        //     : AppSize.w74.w,
                                        // height: (kIsWeb ||
                                        //         size.width >= AppConstants.kIsWebValue)
                                        //     ? AppSize.h34.h
                                        //     : AppSize.h29.h,
                                        padding: EdgeInsets.all(AppSize.w4),
                                        decoration: BoxDecoration(
                                            color: AppColors.primaryColor,
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r5_3.r)),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            Text(
                                              getTranslated(context, "more"),
                                              textAlign: TextAlign.center,
                                              maxLines: 3,
                                              style: TextStyle(
                                                fontFamily: getTranslated(
                                                    context, "Ithra"),
                                                color: AppColors.grey4,
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppFontsSizeManager.s16.sp
                                                    : AppFontsSizeManager
                                                        .s10.sp,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            SizedBox(
                                              width: AppSize.w5.w,
                                            ),
                                            Icon(
                                              Icons.arrow_forward,
                                              size: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppSize.w20.r
                                                  : AppSize.w10.r,
                                              color: AppColors.grey4,
                                            ),
                                          ],
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          )
        : Column(
            children: [
              Center(
                child: Container(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h75.h
                      : AppSize.h48.h,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w120.w
                      : AppSize.w217_3.w,
                  decoration: BoxDecoration(
                    border: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? Border.all(
                            color: AppColors.white, width: AppSize.w2.w)
                        : null,
                    boxShadow: [
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppShadow.fabshadow
                          : AppShadow.fabshadow
                    ],
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r25.r
                            : AppRadius.r5.r),
                  ),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? SizedBox()
                          : Center(
                              child: Text(
                                getTranslated(context, "Reviews"),
                                textAlign: TextAlign.center,
                                maxLines: 3,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: Color.fromRGBO(0, 0, 0, 1),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s29.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  fontWeight: FontWeight.normal,
                                ),
                              ),
                            ),
                      SizedBox(
                        width: AppSize.w16.w,
                      ),
                      Padding(
                        padding: EdgeInsets.only(bottom: AppPadding.p5.h),
                        child: SmoothStarRating(
                          allowHalfRating: true,
                          starCount: 1,
                          rating: 1,
                          size:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h38.h
                                  : AppSize.h21_3.h,
                          color: AppColors.yellow,
                          borderColor: AppColors.yellow,
                          spacing: 1.0,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? SizedBox(
                      height: AppSize.h56.h,
                    )
                  : SizedBox(
                      height: AppSize.h26.h,
                    ),
              Center(
                child: Container(
                  padding: EdgeInsets.all(
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 0
                          : AppPadding.p0),
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? 0
                            : AppRadius.r21_3.r),
                    border: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? null
                        : Border.all(
                            color: AppColors.white, width: AppSize.w2.w),
                    // boxShadow: [AppShadow.fabshadow],
                  ),
                  child: Column(
                    children: [
                      loadReviews
                          ? Center(child: CircularProgressIndicator())
                          : SizedBox(),
                      (loadReviews == false && reviews.length == 0)
                          ? Padding(
                              padding: EdgeInsets.symmetric(
                                  vertical: AppPadding.p8.h),
                              child: Center(
                                child: Column(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  children: <Widget>[
                                    SizedBox(
                                      height: AppSize.h30.h,
                                    ),
                                    Text(
                                      getTranslated(context, "noReviews"),
                                      style: TextStyle(
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        color: Colors.black.withOpacity(0.5),
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s25.sp
                                            : AppFontsSizeManager.s13.sp,
                                        fontWeight: FontWeight.normal,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            )
                          : SizedBox(),
                      (loadReviews == false && reviews.length > 0)
                          ? ListView.separated(
                              itemCount:
                                  reviews.length > 2 ? 2 : reviews.length,
                              shrinkWrap: true,
                              physics: NeverScrollableScrollPhysics(),
                              padding: EdgeInsets.all(0),
                              itemBuilder: (context, index) {
                                return Container(
                                  padding: const EdgeInsets.only(
                                      left: 20, right: 20, top: 10),
                                  child: Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    children: [
                                      //image
                                      Container(
                                        padding: EdgeInsets.all((kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppPadding.p15
                                            : AppPadding.p10),
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: AppColors.grey4,
                                        ),
                                        child: reviews[index].image!.isEmpty
                                            ? SvgPicture.asset(
                                                AssetsManager.personIconPath,
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w26_5.w
                                                    : AppSize.w16.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h27_7.h
                                                    : AppSize.h16.h,
                                              )
                                            : ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.r100.r),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder: AssetsManager
                                                      .iconPersonIconPath,
                                                  placeholderScale: 0.5,
                                                  width: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.w26_5.w
                                                      : AppSize.w15_8.w,
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h27_9.h
                                                      : AppSize.h16_7.h,
                                                  imageErrorBuilder: (context,
                                                          error, stackTrace) =>
                                                      SvgPicture.asset(
                                                    AssetsManager
                                                        .personIconPath,
                                                    width: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppSize.w26_5.w
                                                        : AppSize.w15_8.w,
                                                    height: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppSize.h27_9.h
                                                        : AppSize.h16_7.h,
                                                  ),
                                                  image: reviews[index].image!,
                                                  fit: BoxFit.cover,
                                                  fadeInDuration: Duration(
                                                      milliseconds: AppConstants
                                                          .milliseconds250),
                                                  fadeInCurve: Curves.easeInOut,
                                                  fadeOutDuration: Duration(
                                                      milliseconds: AppConstants
                                                          .milliseconds150),
                                                  fadeOutCurve:
                                                      Curves.easeInOut,
                                                ),
                                              ),
                                      ), //
                                      SizedBox(
                                          width: lang == "ar"
                                              ? AppSize.w19.w
                                              : AppSize.w25.w),
                                      Expanded(
                                        child: Container(
                                          // width: (kIsWeb ||
                                          //         size.width >=
                                          //             AppConstants.kIsWebValue)
                                          //     ? size.width * AppSize.w0_18
                                          //     : size.width * AppSize.w0_4,
                                          child: Column(
                                            mainAxisAlignment:
                                                MainAxisAlignment.start,
                                            crossAxisAlignment:
                                                CrossAxisAlignment.start,
                                            children: [
                                              SizedBox(height: AppSize.h5.h),
                                              //name
                                              Text(
                                                reviews[index].name,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, "Ithra"),
                                                  color: AppColors.darkPurple,
                                                  fontSize: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppFontsSizeManager
                                                          .s24.sp
                                                      : AppFontsSizeManager
                                                          .s14.sp,
                                                  fontWeight:
                                                      AppFontsWeightManager
                                                          .normal,
                                                  letterSpacing: AppConstants
                                                      .letterSpacing0_5,
                                                ),
                                              ),
                                              //sub
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h2.h
                                                      : AppSize.h5.h),
                                              Text(
                                                reviews[index].review!,
                                                maxLines: 1,
                                                overflow: TextOverflow.ellipsis,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(
                                                      context, "Ithra"),
                                                  color: AppColors.darkGrey9,
                                                  fontSize: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppFontsSizeManager
                                                          .s19.sp
                                                      : AppFontsSizeManager
                                                          .s12.sp,
                                                  fontWeight: FontWeight.normal,
                                                  letterSpacing: AppConstants
                                                      .letterSpacing0_5,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                      ),
                                      SizedBox(width: AppSize.w25),

                                      Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.end,
                                        crossAxisAlignment:
                                            CrossAxisAlignment.start,
                                        children: [
                                          SmoothStarRating(
                                            allowHalfRating: true,
                                            starCount: 1,
                                            rating: 1,
                                            size: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.w23.w
                                                : 30.w,
                                            color: AppColors.yellow,
                                            borderColor: AppColors.yellow,
                                            spacing: 1.0,
                                          ),
                                          SizedBox(
                                            width: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.w8_8.w
                                                : AppSize.w2.w,
                                          ),
                                          Padding(
                                            padding: EdgeInsets.only(
                                                top: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? 0
                                                    : AppPadding.p5.h),
                                            child: Text(
                                              reviews[index]
                                                  .rating
                                                  .toStringAsFixed(1),
                                              textAlign: TextAlign.start,
                                              style: TextStyle(
                                                fontFamily: 'Montserrat',
                                                color: AppColors.black,
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppFontsSizeManager.s24.sp
                                                    : AppFontsSizeManager
                                                        .s14.sp,
                                                fontWeight:
                                                    AppFontsWeightManager
                                                        .bold300,
                                              ),
                                            ),
                                          ),
                                        ],
                                      )
                                    ],
                                  ),
                                );
                              },
                              separatorBuilder:
                                  (BuildContext context, int index) {
                                return Center(
                                    child: Container(
                                  // margin: EdgeInsets.only(top: 20),
                                  color: AppColors.grey9,
                                  width: size.width * AppSize.w0_8,
                                  height: AppSize.h1.h,
                                ));
                              },
                            )
                          : SizedBox(),
                      SizedBox(
                        height: AppSize.h5.h,
                      ),
                      SizedBox(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h41.h
                                  : null),
                      Padding(
                        padding: EdgeInsets.only(
                            bottom: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 0
                                : AppPadding.p1.h),
                        child: Row(
                          mainAxisAlignment: lang == "ar"
                              ? MainAxisAlignment.end
                              : MainAxisAlignment.start,
                          children: [
                            InkWell(
                              onTap: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => ReviewScreens(
                                        consult: widget.consultant,
                                        reviewLength: reviewLength),
                                  ),
                                );
                              },
                              child: Container(
                                height:
                                    AppSize.h37_6.r, //width: size.width*.40,
                                padding: const EdgeInsets.only(
                                    left: AppPadding.p10,
                                    right: AppPadding.p10),
                                child: Row(
                                  mainAxisAlignment: MainAxisAlignment.center,
                                  children: [
                                    SizedBox(
                                      width: AppSize.w22_6.r,
                                      child: Stack(
                                        children: [
                                          if (reviews.length >= 1)
                                            Container(
                                              height: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppSize.h37_6.r
                                                  : AppSize.h22_6.r,
                                              width: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppSize.h37_6.r
                                                  : AppSize.h22_6.r,
                                              decoration: BoxDecoration(
                                                boxShadow: [
                                                  BoxShadow(
                                                      color: const Color(
                                                          0x33ae9cce),
                                                      offset: Offset(0, 6),
                                                      blurRadius: 12,
                                                      spreadRadius: 0)
                                                ],
                                                color: AppColors.white,
                                                border: Border.all(
                                                  width: AppSize.w6.w,
                                                  color: AppColors.white,
                                                ),
                                                shape: BoxShape.circle,
                                              ),
                                              child: ClipRRect(
                                                borderRadius:
                                                    BorderRadius.circular(
                                                        AppRadius.r100.r),
                                                child: FadeInImage.assetNetwork(
                                                  placeholder:
                                                      reviews[0].image ?? '',
                                                  //placeholderScale: 0.5,
                                                  imageErrorBuilder: (context,
                                                          error, stackTrace) =>
                                                      Image.asset(
                                                    AssetsManager
                                                        .whiteJerasLogoIconPath,
                                                    height: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppSize.h37_6.r
                                                        : AppSize.h22_6.r,
                                                    width: (kIsWeb ||
                                                            size.width >=
                                                                AppConstants
                                                                    .kIsWebValue)
                                                        ? AppSize.h37_6.r
                                                        : AppSize.h22_6.r,
                                                  ),
                                                  image: AssetsManager
                                                      .whiteJerasLogoIconPath,
                                                  fit: BoxFit.cover,
                                                  fadeInDuration: Duration(
                                                      milliseconds: AppConstants
                                                          .milliseconds250),
                                                  fadeInCurve: Curves.easeInOut,
                                                  fadeOutDuration: Duration(
                                                      milliseconds: AppConstants
                                                          .milliseconds150),
                                                  fadeOutCurve:
                                                      Curves.easeInOut,
                                                ),
                                              ),
                                            ),
                                          if (reviews.length >= 2)
                                            Transform.translate(
                                              offset: Offset(15, 0),
                                              child: Container(
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h37_6.r
                                                    : AppSize.h22_6.r,
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h37_6.r
                                                    : AppSize.h22_6.r,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: AppColors
                                                            .lightPurple,
                                                        offset: Offset(0, 6),
                                                        blurRadius: 12,
                                                        spreadRadius: 0)
                                                  ],
                                                  color: AppColors.white,
                                                  border: Border.all(
                                                    width: AppSize.w6.w,
                                                    color: AppColors.white,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppRadius.r100.r),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        reviews[1].image ?? '',
                                                    //placeholderScale: 0.5,
                                                    imageErrorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      AssetsManager
                                                          .whiteJerasLogoIconPath,
                                                      height: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.h37_6.r
                                                          : AppSize.h22_6.r,
                                                      width: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.h37_6.r
                                                          : AppSize.h22_6.r,
                                                    ),
                                                    image: AssetsManager
                                                        .whiteJerasLogoIconPath,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                              ),
                                            ),
                                          if (reviews.length >= 3)
                                            Transform.translate(
                                              offset: Offset(30, 0),
                                              child: Container(
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h37_6.r
                                                    : AppSize.h22_6.r,
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h37_6.r
                                                    : AppSize.h22_6.r,
                                                decoration: BoxDecoration(
                                                  boxShadow: [
                                                    BoxShadow(
                                                        color: AppColors
                                                            .lightPurple,
                                                        offset: Offset(0, 6),
                                                        blurRadius: 12,
                                                        spreadRadius: 0)
                                                  ],
                                                  color: AppColors.white,
                                                  border: Border.all(
                                                    width: AppSize.w6.w,
                                                    color: AppColors.white,
                                                  ),
                                                  shape: BoxShape.circle,
                                                ),
                                                child: ClipRRect(
                                                  borderRadius:
                                                      BorderRadius.circular(
                                                          AppRadius.r100.r),
                                                  child:
                                                      FadeInImage.assetNetwork(
                                                    placeholder:
                                                        reviews[2].image ?? '',
                                                    //placeholderScale: 0.5,
                                                    imageErrorBuilder: (context,
                                                            error,
                                                            stackTrace) =>
                                                        Image.asset(
                                                      AssetsManager
                                                          .whiteJerasLogoIconPath,
                                                      height: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.h37_6.r
                                                          : AppSize.h22_6.r,
                                                      width: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppSize.h37_6.r
                                                          : AppSize.h22_6.r,
                                                    ),
                                                    image: AssetsManager
                                                        .whiteJerasLogoIconPath,
                                                    fit: BoxFit.cover,
                                                    fadeInDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds250),
                                                    fadeInCurve:
                                                        Curves.easeInOut,
                                                    fadeOutDuration: Duration(
                                                        milliseconds: AppConstants
                                                            .milliseconds150),
                                                    fadeOutCurve:
                                                        Curves.easeInOut,
                                                  ),
                                                ),
                                              ),
                                            ),
                                        ],
                                      ),
                                    ),
                                    SizedBox(
                                      width: lang == "ar"
                                          ? AppSize.w10.w
                                          : AppSize.w60.w,
                                    ),
                                    Container(
                                      // width: (kIsWeb ||
                                      //         size.width >= AppConstants.kIsWebValue)
                                      //     ? AppSize.w95.w
                                      //     : AppSize.w74.w,
                                      // height: (kIsWeb ||
                                      //         size.width >= AppConstants.kIsWebValue)
                                      //     ? AppSize.h34.h
                                      //     : AppSize.h29.h,
                                      padding: EdgeInsets.all(AppSize.w4),
                                      decoration: BoxDecoration(
                                          color: AppColors.primaryColor,
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r5_3.r)),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.center,
                                        children: [
                                          Text(
                                            getTranslated(context, "more"),
                                            textAlign: TextAlign.center,
                                            maxLines: 3,
                                            style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, "Ithra"),
                                              color: AppColors.grey4,
                                              fontSize: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppFontsSizeManager.s16.sp
                                                  : AppFontsSizeManager.s10.sp,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                          SizedBox(
                                            width: AppSize.w5.w,
                                          ),
                                          Icon(
                                            Icons.arrow_forward,
                                            size: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.w20.r
                                                : AppSize.w10.r,
                                            color: AppColors.grey4,
                                          ),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
  }

  getConsultReviews() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.consultReviewsPath)
          .where('consultUid', isEqualTo: widget.consultant.uid)
          .limit(3)
          .orderBy("reviewTime", descending: true)
          .get();
      var reviewsList = List<ConsultReview>.from(
        querySnapshot.docs.map(
          (snapshot) => ConsultReview.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        reviewLength = reviewsList.length;
        reviews = reviewsList;
        loadReviews = false;
      });
    } catch (e) {
      setState(() {
        loadReviews = false;
      });
    }
  }

  BoxShadow shadow(Size size) {
    return BoxShadow(
      color: AppColors.lightGrey,
      blurRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 23 : 2.0,
      spreadRadius: 0.0,
      offset: Offset(
          0.0,
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? 3
              : 1.0), // shadow direction: bottom right
    );
  }
}
