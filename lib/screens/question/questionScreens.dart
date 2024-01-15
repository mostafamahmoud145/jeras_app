import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/custom_outlined_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/app_constat.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/assets_manager.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/questions.dart';
import '../../models/user.dart';
import '../../widget/questionListItem.dart';

class QuestionScreen extends StatefulWidget {
  final GroceryUser user;

  const QuestionScreen({Key? key, required this.user}) : super(key: key);

  @override
  _QuestionScreenState createState() => _QuestionScreenState();
}

class _QuestionScreenState extends State<QuestionScreen>
    with SingleTickerProviderStateMixin {
  late List<Questions> allQuestions;

  final TextEditingController searchController = new TextEditingController();
  bool load = false;
  String text = "";
  late Query filterQuery;
  late Size size;
  late String lang;

  @override
  void initState() {
    super.initState();
    initiateSearch(text);
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p20,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p20,
                    top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p58.w
                        : AppPadding.p10,
                    bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p41.w
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
                    Text(
                      getTranslated(context, "FAQs"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s34.sp
                                : AppFontsSizeManager.s21_3.sp,
                        color: Colors.black.withOpacity(0.8),
                        //fontWeight: AppFontsWeightManager.bold300,
                      ),
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h0_1.h
                      : AppSize.h2.h,
                  width: size.width)),
          (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? Container(
                  width: size.width,
                  height: AppSize.h0_1,
                  color: AppColors.grey2,
                )
              : SizedBox(),
          Padding(
            //padding: const EdgeInsets.only(left: 20, right: 20, top: 21, bottom: 0),
            padding: EdgeInsets.only(
                left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p140.w
                    : AppPadding.p20,
                right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p140.w
                    : AppPadding.p20,
                top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h40.h
                    : AppPadding.p21_3,
                bottom: 0),

            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "Welcome"),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: AppFontsWeightManager.semiBold,
                      fontFamily: getTranslated(context, "Ithra"),
                      fontStyle: FontStyle.normal,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s36.sp
                              : AppFontsSizeManager.s21_3.sp),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          Padding(
            // padding:  const EdgeInsets.only(left: 20, right: 20, top: 0, bottom: 10),
            padding: EdgeInsets.only(
                left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p140.w
                    : AppPadding.p20,
                right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p140.w
                    : AppPadding.p20,
                top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppPadding.p10.h
                    : AppPadding.p10,
                bottom: 0),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "howCanWeHelp"),
                  style: TextStyle(
                      color: Theme.of(context).primaryColor,
                      fontWeight: AppFontsWeightManager.semiBold,
                      fontFamily: getTranslated(context, "Ithra"),
                      fontStyle: FontStyle.normal,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s36.sp
                              : AppFontsSizeManager.s21_3.sp),
                  textAlign: TextAlign.left,
                ),
              ],
            ),
          ),
          SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h48.h
                  : AppSize.h32.h),
          //getTranslated(context, "askQuestion")

          Container(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h100.h
                : AppSize.h64.h,
            width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.w1110.w
                : AppSize.w509_3.w,
            decoration: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? BoxDecoration()
                : BoxDecoration(
                    border: CustomOulinedButton.outlineBorder(),
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r15.r
                            : AppRadius.r10_6.r),
                  ),
            child: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Row(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Container(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h100.h
                                : AppSize.h28.h,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w851.w
                                : size.width * AppSize.w0_8.w,
                            decoration: BoxDecoration(
                              border: CustomOulinedButton.outlineBorder(),
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular((kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r15.r
                                  : AppRadius.r10_6.r),
                            ),
                            padding: EdgeInsets.only(
                                left: AppPadding.p36.w,
                                right: AppPadding.p36.w),
                            child: Center(
                              child: TextField(
                                onChanged: (val) => initiateSearch(text),
                                keyboardType: TextInputType.text,
                                controller: searchController,
                                textInputAction: TextInputAction.search,
                                enableInteractiveSelection: true,
                                readOnly: false,
                                style: TextStyle(
                                  fontFamily:
                                      getTranslated(context, "Ithralight"),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s28.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  color: AppColors.black87,
                                  letterSpacing: AppConstants.letterSpacing0_5,
                                  fontWeight: AppFontsWeightManager.regular,
                                ),
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppPadding.p36.w
                                          : AppPadding.p5.w,
                                      vertical: AppPadding.p26.w),
                                  prefixIcon: Container(
                                    width: AppSize.w5.w,
                                    height: AppSize.h5.h,
                                    child: SvgPicture.asset(
                                      AssetsManager.newSearchICon,
                                      color: AppColors.primaryColor,
                                      width: AppSize.w48.w,
                                      height: AppSize.h48.h,
                                    ),
                                  ),
                                  border: InputBorder.none,
                                  hintText: // "Ask a question",
                                      getTranslated(context, "askQuestion"),
                                  hintStyle: TextStyle(
                                    color: AppColors.black1,
                                    fontWeight: FontWeight.w400,
                                    fontFamily:
                                        getTranslated(context, "Ithralight"),
                                    // fontStyle: FontStyle.normal,
                                    fontSize: AppFontsSizeManager.s21_3.sp,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                      SizedBox(
                        width: AppSize.w40.w,
                      ),
                      InkWell(
                        onTap: () {
                          initiateSearch(searchController.text);
                        },
                        child: Container(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h100.h
                                  : AppSize.h40.h,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w213.w
                                  : 101.3.w,
                          decoration: BoxDecoration(
                              color: AppColors.pink,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r15.r)),
                          child: Center(
                            child: Text(
                              "Ask",
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(
                                    context, "Montserratsemibold"),
                                color: AppColors.white,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s34.sp
                                    : AppFontsSizeManager.s18_6.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  )
                : Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h60.h
                                : AppSize.h28.h,
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppSize.w0_2.w
                                : size.width * AppSize.w0_8.w,
                        padding: EdgeInsets.only(
                            left: AppPadding.p5, right: AppPadding.p5),
                        child: Center(
                          child: TextField(
                            onChanged: (val) => initiateSearch(text),
                            keyboardType: TextInputType.text,
                            controller: searchController,
                            textInputAction: TextInputAction.search,
                            enableInteractiveSelection: true,
                            readOnly: false,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithralight"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s25.sp
                                  : AppFontsSizeManager.s18.sp,
                              color: AppColors.black87,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: AppFontsWeightManager.regular,
                            ),
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppPadding.p15.w
                                      : AppPadding.p5.w,
                                  vertical: 11.0.h),
                              prefixIcon: Container(
                                width: AppSize.w5.w,
                                height: AppSize.h5.h,
                                child: SvgPicture.asset(
                                  AssetsManager.newSearchICon,
                                  color: AppColors.primaryColor,
                                  width: AppSize.w32.w,
                                  height: AppSize.h32.h,
                                ),
                              ),
                              border: InputBorder.none,
                              hintText: // "Ask a question",
                                  getTranslated(context, "askQuestion"),
                              hintStyle: TextStyle(
                                color: AppColors.black1,
                                fontWeight: FontWeight.w400,
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                fontStyle: FontStyle.normal,
                                fontSize: AppFontsSizeManager.s21_3.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          initiateSearch(searchController.text);
                        },
                        child: Padding(
                          padding: EdgeInsets.symmetric(vertical: AppPadding.p12.h, horizontal: AppPadding.p26.w),
                          child: Container(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h60.h
                                : AppSize.h40.h,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppSize.w0_05.w
                                : 101.3.w,
                            decoration: BoxDecoration(
                                color: AppColors.pink,
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r5_3.r)),
                            child: Center(
                              child: Text(
                                "Ask",
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: getTranslated(
                                      context, "Montserratsemibold"),
                                  color: AppColors.white,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s26_6.sp
                                      : AppFontsSizeManager.s18_6.sp,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
          ),
          SizedBox(height: AppSize.h30.h,),
          Expanded(
            child: Padding(
               padding: EdgeInsets.only(
                            left: AppPadding.p5, right: AppPadding.p5),
              child: PaginateFirestore(
                key: ValueKey(filterQuery),
                separator: Center(
                  child: Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * 06.w
                                : AppPadding.p20.w),
                    child: Container(
                        color: AppColors.lightGrey,
                        height: AppSize.h1.h,
                        width: size.width * AppSize.w0_9.w),
                  ),
                ),
                itemBuilderType: PaginateBuilderType.listView,
                padding: EdgeInsets.symmetric(
                    horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_06.w
                        : AppSize.w20.w,
                    vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h120.h
                        : AppSize.h10.h),
                itemBuilder: (context, documentSnapshot, index) {
                  return QuestionListItem(
                      question: Questions.fromMap(
                          documentSnapshot[index].data() as Map),
                      user: widget.user);
                },
                query: filterQuery,
                // to fetch real-time data
                isLive: true,
              ),
            ),
          )
        ],
      ),
    );
  }

  void initiateSearch(String text) {
    if (text == "")
      setState(() {
        filterQuery = FirebaseFirestore.instance
            .collection(Paths.questionPath)
            .where('status', isEqualTo: true)
            .orderBy('order', descending: false);
      });
    else {
      if (lang == "ar")
        setState(() {
          filterQuery = FirebaseFirestore.instance
              .collection(Paths.questionPath)
              .where('searchIndexAr', arrayContains: text)
              .where('status', isEqualTo: true)
              .orderBy('order', descending: false);
        });
      else
        setState(() {
          filterQuery = FirebaseFirestore.instance
              .collection(Paths.questionPath)
              .where('searchIndexEn', arrayContains: text)
              .where('status', isEqualTo: true)
              .orderBy('order', descending: false);
        });
    }
  }
}
