import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/consultReview.dart';
import '../../models/user.dart';
import '../../widget/consultReviewWidget.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../widget/component/IconButton.dart';

class ReviewScreens extends StatefulWidget {
  final GroceryUser consult;
  final int reviewLength;

  const ReviewScreens(
      {Key? key, required this.consult, required this.reviewLength})
      : super(key: key);

  @override
  _ReviewScreensState createState() => _ReviewScreensState();
}

class _ReviewScreensState extends State<ReviewScreens> {
  late List<ConsultReview> reviews;
  String theme = "light";
  String lang = "";

  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
  }

  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    dynamic rating = 0.0;
    rating = (widget.consult.rating == null) ? 0.0 : widget.consult.rating;
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [
            Container(
                width: size.width,
                child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p140.r
                          : AppPadding.p35,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p140.r
                          : AppRadius.r35,
                      top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p58.r
                          : AppPadding.p30,
                      bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p41.r
                          : AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w80.r
                                : AppSize.w45.r,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h80.r
                                : AppSize.h45.r,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r25.r
                                  : AppRadius.r13.r),
                        ),
                        child: IconButton1(
                          onPress: Navigator.of(context).pop,
                          Width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w97.w
                                  : AppSize.w50.w,
                          Height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h97.h
                                  : AppSize.h50.h,
                          ButtonRadius: AppRadius.r10_6.r,
                          IconWidth:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h41.h
                                  : AppSize.w22.w,
                          IconHeight:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h47_6.h
                                  : AppSize.h20.h,
                          IconColor: Theme.of(context).primaryColor,
                          Icon: lang == "ar"
                              ? AssetsManager.whiteArrowRight
                              : AssetsManager.whiteArrowLeft,
                          ButtonBackground: AppColors.white,
                        ),
                      ),
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w34.w
                                  : AppSize.w10.w),
                      Text(
                        getTranslated(context, "Reviews"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: AppFontsWeightManager.bold300,
                          fontFamily:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Ithralight")
                                  : getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          color: AppColors.black,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s21_3.sp,
                        ),
                      ),
                    ],
                  ),
                )),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: size.width)),
            SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h20.h
                    : AppSize.h30.h),
            Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 20
                        : AppSize.h10.h,
                  ),
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? Container(
                          height: AppSize.h250.h,
                          width: AppSize.w250.w,
                          padding: EdgeInsets.only(top: AppSize.h50.h),
                          child: Stack(
                            alignment: Alignment.center,
                            children: [
                              Container(
                                height: AppSize.h140.h,
                                width: AppSize.w140.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.white, width: 1.w),
                                  shape: BoxShape.circle,
                                ),
                                child: Container(
                                  height: AppSize.h80.h,
                                  width: AppSize.w180.w,
                                  decoration: BoxDecoration(
                                    border: Border.all(
                                        color: AppColors.grey2,
                                        width: AppSize.w2.w),
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                  ),
                                  child: widget.consult.photoUrl!.isEmpty
                                      ? Image.asset(
                                          AssetsManager.whiteJerasLogoIconPath,
                                          width: AppSize.w140.w,
                                          height: AppSize.h140.h,
                                          fit: BoxFit.fill,
                                        )
                                      : ClipRRect(
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r100.r),
                                          child: FadeInImage.assetNetwork(
                                            placeholder: AssetsManager.lodeGif,
                                            placeholderScale: 0.5,
                                            imageErrorBuilder: (context, error,
                                                    stackTrace) =>
                                                Image.asset(
                                                    AssetsManager
                                                        .whiteJerasLogoIconPath,
                                                    width: AppSize.w80.w,
                                                    height: AppSize.h80.h,
                                                    fit: BoxFit.fill),
                                            image: widget.consult.photoUrl
                                                .toString(),
                                            fit: BoxFit.cover,
                                            fadeInDuration: Duration(
                                                milliseconds: AppConstants
                                                    .milliseconds250),
                                            fadeInCurve: Curves.easeInOut,
                                            fadeOutDuration: Duration(
                                                milliseconds: AppConstants
                                                    .milliseconds150),
                                            fadeOutCurve: Curves.easeInOut,
                                          ),
                                        ),
                                ),
                              ),
                              Positioned(
                                top: 0,
                                child: Column(
                                  children: [
                                    _StartsWidget(double.parse(
                                        widget.consult.rating.toString())),
                                    SizedBox(
                                        height: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h50.h
                                            : 0),
                                  ],
                                ),
                              ),
                            ],
                          ),
                        )
                      : Stack(
                          alignment: Alignment.center,
                          children: [
                            Container(
                              height: AppSize.h81.h,
                              width: AppSize.w81.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.white, width: 1.w),
                                shape: BoxShape.circle,
                                color: AppColors.white,
                              ),
                              child: Container(
                                height: AppSize.h80.h,
                                width: AppSize.w180.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                      color: AppColors.white, width: 5.w),
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: widget.consult.photoUrl!.isEmpty
                                    ? Image.asset(
                                        AssetsManager.whiteJerasLogoIconPath,
                                        width: AppSize.w80.w,
                                        height: AppSize.h80.h,
                                        fit: BoxFit.fill,
                                      )
                                    : ClipRRect(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r100.r),
                                        child: FadeInImage.assetNetwork(
                                          placeholder: AssetsManager.lodeGif,
                                          placeholderScale: 0.5,
                                          imageErrorBuilder: (context, error,
                                                  stackTrace) =>
                                              Image.asset(
                                                  AssetsManager
                                                      .whiteJerasLogoIconPath,
                                                  width: AppSize.w80.w,
                                                  height: AppSize.h80.h,
                                                  fit: BoxFit.fill),
                                          image: widget.consult.photoUrl
                                              .toString(),
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
                            Positioned(
                              top: 0,
                              child: _StartsWidget(double.parse(
                                  widget.consult.rating.toString())),
                            ),
                          ],
                        ),
                  Center(
                    child: Text(
                      widget.consult.name!,
                      style: TextStyle(
                        fontWeight: AppFontsWeightManager.bold,
                        fontFamily:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Ithralight")
                                : getTranslated(context, "Ithra"),
                        fontStyle: FontStyle.normal,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : AppFontsSizeManager.s21_3.sp,
                        color: AppColors.black2,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              child: PaginateFirestore(
                onEmpty: Padding(
                  padding: EdgeInsets.symmetric(vertical: AppPadding.p8.h),
                  child: Center(
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: <Widget>[
                        SizedBox(
                          height: 15.0.h,
                        ),
                        Text(
                          getTranslated(context, "noReviews"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.grey,
                            fontSize: AppFontsSizeManager.s20.sp,
                            fontWeight: AppFontsWeightManager.semiBold,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                itemBuilderType: PaginateBuilderType.listView,
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p16,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p16,
                    bottom: AppPadding.p16,
                    top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p56.w
                        : AppPadding.p16),
                //Change types accordingly
                itemBuilder: (context, documentSnapshot, index) {
                  return ConsultReviewWidget(
                    review: ConsultReview.fromMap(
                        documentSnapshot[index].data() as Map),
                  );
                },
                separator: Center(
                    child: Container(
                        color: AppColors.lightGrey,
                        height: AppSize.h1.h,
                        width: size.width * AppSize.w0_9)),
                query: widget.consult.userType == "CONSULTANT"
                    ? FirebaseFirestore.instance
                        .collection('ConsultReview')
                        .where('consultUid', isEqualTo: widget.consult.uid)
                        .orderBy("reviewTime", descending: true)
                    : FirebaseFirestore.instance
                        .collection('ConsultReview')
                        .where('uid', isEqualTo: widget.consult.uid)
                        .orderBy("reviewTime", descending: true),
                // to fetch real-time data
                isLive: true,
              ),
            )
          ],
        ),
      ),
    );
  }
}

class _StartsWidget extends StatelessWidget {
  const _StartsWidget(this.rate);

  final double rate;

  @override
  Widget build(BuildContext context) {
      Size size = MediaQuery.of(context).size;
    return Row(
      children: [
        for (int i = 0; i < 5; i++)
          Transform.translate(
            offset: Offset(
                0,
                (i == 2)
                    ? -12
                    : (i == 1 || i == 3)
                        ? -10
                        : -5),
            child: i < rate
                ? Icon(
                    Icons.star,
                    color: AppColors.yellow,
                    size: AppSize.w10,
                  )
                : Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w2.w
                                : 0),
                    child: Icon(
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? Icons.star
                          : Icons.star_border,
                      color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppColors.grey2
                          : AppColors.yellow,
                      size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w32.w
                          : AppSize.w10,
                    ),
                  ),
          ),
      ],
    );
  }
}
