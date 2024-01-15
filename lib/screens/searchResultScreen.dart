import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../widget/consultantListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../models/courses.dart';
import '../widget/component/textWidget.dart';
import '../widget/courseItem.dart';

class SearchResultScreen extends StatefulWidget {
  final GroceryUser? loggedUser;
  final Query consultsQuery;
  final Query coursesQuery;
  final List<GroceryUser> consultsFillter;

  const SearchResultScreen(
      {Key? key,
      this.loggedUser,
      required this.consultsQuery,
      required this.coursesQuery,
      required this.consultsFillter})
      : super(key: key);

  @override
  _SearchResultScreenState createState() => _SearchResultScreenState();
}

class _SearchResultScreenState extends State<SearchResultScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late Size size;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppPadding.p0_06
                          : AppPadding.p10,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppPadding.p0_06
                          : AppPadding.p10,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      IconButton1(
                        onPress: Navigator.of(context).pop,
                        Width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w97.w
                                : AppSize.w50_6.w,
                        Height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h97.h
                                : AppSize.h50_6.h,
                        ButtonRadius:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r24.r
                                : AppRadius.r10_6.r,
                        IconWidth: AppSize.w32.w,
                        IconHeight: AppSize.h32.h,
                        IconColor: Theme.of(context).primaryColor,
                        Icon: AssetsManager.blackArrowRightIconPath,
                        ButtonBackground: AppColors.white,
                      ),
                      const SizedBox(width: AppSize.w10),
                      TextWidget(
                        text: getTranslated(context, "search"),
                        color: AppColors.black4,
                        size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s31
                            : AppFontsSizeManager.s12.sp,
                        weight: FontWeight.w600,
                        align: TextAlign.center,
                      ),
                      SizedBox(width: AppSize.w10),
                    ],
                  ),
                ),
              )),
          Expanded(
            child: ListView(
              padding: EdgeInsets.only(
                left: (getTranslated(context, "lang")) == "ar"
                    ? 0
                    : size.width * AppSize.w0_06,
                right: (getTranslated(context, "lang")) == "ar"
                    ? size.width * AppSize.w0_06
                    : 0,
              ),
              children: <Widget>[
                Row(
                  children: [
                    TextWidget(
                      text: getTranslated(context, "_teachers"),
                      color: AppColors.black4,
                      size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppFontsSizeManager.s27.sp
                          : AppFontsSizeManager.s12.sp,
                      weight: FontWeight.w600,
                      family: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? getTranslated(context, "Montserrat")
                          : getTranslated(context, "Ithra"),
                      align: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h20.h
                      : AppSize.h10.h,
                ),
                consultListWidget(size),
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h20.h
                      : AppSize.h10.h,
                ),
                Row(
                  children: [
                    TextWidget(
                      text: getTranslated(context, "_courses"),
                      color: AppColors.black4,
                      size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppFontsSizeManager.s27.sp
                          : AppFontsSizeManager.s12.sp,
                      weight: FontWeight.w600,
                      family: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? getTranslated(context, "Montserrat")
                          : getTranslated(context, "Ithra"),
                      align: TextAlign.center,
                    ),
                  ],
                ),
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h20.h
                      : AppSize.h10.h,
                ),
                PaginateFirestore(
                  shrinkWrap: true,
                  padding: EdgeInsets.only(
                    left: (getTranslated(context, "lang")) == "ar"
                        ? size.width * AppPadding.p0_06
                        : 0,
                    right: (getTranslated(context, "lang")) == "ar"
                        ? 0
                        : size.width * AppPadding.p0_06,
                  ),
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
                        text: getTranslated(context, "noCoursesAvaliable"),
                        color: Color.fromRGBO(192, 192, 192, 1),
                        size: AppFontsSizeManager.s17.sp,
                        weight: FontWeight.w500,
                        family:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Montserrat")
                                : getTranslated(context, "Ithra"),
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilderType: PaginateBuilderType.gridView,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 2
                              : 1,
                      crossAxisSpacing:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 50
                              : 30,
                      mainAxisSpacing:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 50
                              : 20,
                      // mainAxisExtent: size.height*.25,
                      childAspectRatio:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 2
                              : 1.8),
                  itemBuilder: (context, documentSnapshot, index) {
                    return CourseItem(
                      course: Courses.fromMap(
                          documentSnapshot[index].data() as Map),
                      userType: "supervisor",
                    );
                  },
                  query: widget.coursesQuery,
                  isLive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget consultListWidget(Size size) {
    return Container(
      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.h295.h
          : AppSize.h300.h,
      child: PaginateFirestore(
        onEmpty: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * .1,
            ),
            TextWidget(
              text: getTranslated(context, "noConsultAvaliable"),
              color: Color.fromRGBO(192, 192, 192, 1),
              size: AppFontsSizeManager.s17.sp,
              weight: AppFontsWeightManager.bold500,
              align: TextAlign.center,
            ),
          ],
        ),
        initialLoader: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: size.height * .1,
            ),
            CircularProgressIndicator()
          ],
        ),
        itemBuilderType: PaginateBuilderType.listView,
        scrollDirection: Axis.horizontal,

        padding: const EdgeInsets.only(
            //left: 16.0,
            // right: 16.0,
            bottom: AppPadding.p16,
            top: AppPadding.p16),
        //
        itemBuilder: (context, documentSnapshot, index) {
          return ListView.builder(
            itemCount: widget.consultsFillter.length,
            scrollDirection: Axis.horizontal,
            shrinkWrap: true,
            itemBuilder: (BuildContext context, int index) {
              return Padding(
                padding: EdgeInsets.symmetric(
                  horizontal: AppSize.w10.w,
                ),
                child: ConsultantListItem(
                  consult: widget.consultsFillter[index],
                  loggedUser: widget.loggedUser,
                  lang: getTranslated(context, "lang"),
                  theme: "light",
                ),
              );
            },
          );
        },
        query: widget.consultsQuery,
        isLive: true,
      ),
    );
  }
}
