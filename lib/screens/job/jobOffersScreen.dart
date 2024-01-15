import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/TabButton.dart';
import 'package:jeras/widget/component/tab_bar/custom_tab_bar.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/app_constat.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/job.dart';
import '../../models/user.dart';
import '../../widget/component/textWidget.dart';
import '../../widget/jobOfferWidget.dart';

class JobsOffersScreen extends StatefulWidget {
  final GroceryUser user;

  const JobsOffersScreen({Key? key, required this.user}) : super(key: key);

  @override
  _JobsOffersScreenState createState() => _JobsOffersScreenState();
}

class _JobsOffersScreenState extends State<JobsOffersScreen>
    with SingleTickerProviderStateMixin {
  late Query query;
  bool load = false, all = false, forMe = true;
  late Size size;
  late String lang;

  List<dynamic> array = ['0'];

  @override
  void initState() {
    if (widget.user.interestListIds!.length > 0)
      array = widget.user.interestListIds!;
    query = queryValue();

    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    String theme = "light";
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
                        ? size.width * AppPadding.p0_06
                        : AppPadding.p20,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppPadding.p0_06
                        : AppPadding.p20,
                    top: AppPadding.p10,
                    bottom: AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomBackButton(),
                    SizedBox(width: AppSize.w21_3.w),
                    Text(
                      getTranslated(context, "availableOffers"),
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
          Center(
              child: Container(
                  color: Color.fromRGBO(236, 236, 236, .65),
                  height: AppSize.h1.h,
                  width: size.width)),
          Center(
            child: Padding(
              padding: EdgeInsets.only(
                  top: AppPadding.p20,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.h0_15
                      : AppPadding.p10,
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.h0_15
                      : AppPadding.p10,
                  bottom: AppPadding.p30.h),
              child: CustomTabBar(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h120.h
                    : AppSize.h58_6.h,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.width * AppSize.w0_3
                    : AppSize.w509_3.w,
                backgroundColor: AppColors.primaryColor.withOpacity(0.05),
                buttons: [
                  //button x
                  TabButton(
                    onPress: () {
                      setState(() {
                        all = true;
                        forMe = false;
                        query = queryValueAll();
                      });
                    },
                    Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w248.w
                        : AppSize.w244.w,
                        Height: AppSize.h50_6.h,
                    ButtonRadius:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r5_3.r
                            : convertPtToPx(AppRadius.r4),
                    ButtonColor: all
                        ? theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black
                        : Colors.transparent,
                    Title: getTranslated(context, "all"),
                    TextFont: "NotoKufiArabic-SemiBold",
                    TextSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : AppFontsSizeManager.s21_3.sp,
                    TextColor: all
                        ? theme == "light"
                            ? AppColors.white
                            : AppColors.white
                        : theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black,
                  ),

                  TabButton(
                    onPress: () {
                      setState(() {
                        all = false;
                        forMe = true;
                        query = queryValue();
                      });
                    },
                    Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w248.w
                        : AppSize.w244.w,
                    ButtonRadius:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r5_3.r
                            : convertPtToPx(AppRadius.r4),
                    ButtonColor: forMe
                        ? theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black
                        : Colors.transparent,
                    Title: getTranslated(context, "forMe"),
                   TextFont: "NotoKufiArabic-SemiBold",
                    TextSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : AppFontsSizeManager.s21_3.sp,
                    TextColor: forMe
                        ? theme == "light"
                            ? AppColors.white
                            : AppColors.white
                        : theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black,
                  ),
                ],radius:  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r5_3.r
                            : convertPtToPx(AppRadius.r4),
                padding: EdgeInsets.symmetric(
                    vertical: checkIfWeb(context)
                        ? AppPadding.p18
                        : AppPadding.p10.h,
                    horizontal: checkIfWeb(context)
                        ? AppPadding.p18
                        : AppPadding.p10.w
                        ),
              ),
            ),
          ),
          Expanded(
            child: PaginateFirestore(
              key: ValueKey(query),
              itemBuilderType:(kIsWeb || size.width >= AppConstants.kIsWebValue)? PaginateBuilderType.gridView: PaginateBuilderType.listView,
              initialLoader: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * AppSize.h0_1,
                  ),
                  CircularProgressIndicator()
                ],
              ),
              onEmpty: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  SizedBox(
                    height: size.height * AppSize.h0_1,
                  ),
                  TextWidget(
                    text: getTranslated(context, "noData"),
                    color: Color.fromRGBO(192, 192, 192, 1),
                    size: AppFontsSizeManager.s17.sp,
                    weight: FontWeight.w500,
                    family: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? getTranslated(context, "Montserrat")
                        : getTranslated(context, "Ithra"),
                    align: TextAlign.center,
                  ),
                ],
              ),
              padding: EdgeInsets.symmetric(
                horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.width * AppSize.w0_06
                    : AppSize.w32.w,
              ),
              gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 3
                          : 1,
                  crossAxisSpacing:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 50
                          : 30,
                  mainAxisSpacing:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? 50
                          : 32,
                  // mainAxisExtent: size.height*.25,
                  childAspectRatio:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? (3 / 2.6)
                          : (3 / 2.7)),

              itemBuilder: (context, documentSnapshot, index) {
                final job = Job.fromMap(documentSnapshot[index].data() as Map);
               
                return (kIsWeb || size.width >= AppConstants.kIsWebValue)? JobsOffersItem(
                  job: job,
                  loggedUser: widget.user,
                ): Padding(
                  padding:  EdgeInsets.only(bottom: AppPadding.p30.h,top:AppPadding.p2.h ),
                  child: JobsOffersItem(
                    job: job,
                    loggedUser: widget.user,
                  ),
                );
              },
              query: query,
              isLive: true,
            ),
          )
        ],
      ),
    );
  }

  Query<Map<String, dynamic>> queryValueAll() {
    print("all");
    Query<Map<String, dynamic>> query = FirebaseFirestore.instance
        .collection(Paths.jobsPath)
        .where('status', isEqualTo: 'new')
        .where("approved", isEqualTo: true)
        .orderBy('utcTime', descending: true);

    return query;
  }

  Query<Map<String, dynamic>> queryValue() {
    print("forme");
    return FirebaseFirestore.instance
        .collection(Paths.jobsPath)
        .where('status', isEqualTo: "new")
        .where('interestListIds', arrayContainsAny: array)
        .where("approved", isEqualTo: true)
        .orderBy('utcTime', descending: true);
  }
}
