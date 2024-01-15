import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/Objections.dart';
import '../../models/user.dart';
import '../../widget/objectionWidget.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';

class ObjectionScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const ObjectionScreen({Key? key, required this.loggedUser}) : super(key: key);

  @override
  _ObjectionScreenState createState() => _ObjectionScreenState();
}

class _ObjectionScreenState extends State<ObjectionScreen>
    with SingleTickerProviderStateMixin {
  bool seen = false, notSeen = true;
  late Query userQuery, query;

  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance
        .collection(Paths.objectionsPath)
        .where('objectionStatus', isEqualTo: false)
        .orderBy('timestamp', descending: true);
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
                        IconWidth: AppSize.w32.r,
                        IconHeight: AppSize.h32.r,
                        IconColor: Theme.of(context).primaryColor,
                        Icon: AssetsManager.blackArrowRightIconPath,
                        ButtonBackground: AppColors.white,
                      ),
                      SizedBox(width: AppSize.w10.w),
                      Text(
                        getTranslated(context, "objections"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s31.sp : AppFontsSizeManager.s15.sp,
                          color: AppColors.black2,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1.h,
                  width: size.width)),
          SizedBox(
            height: AppSize.h10.h,
          ),
          Center(
            child: Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p20.w,
                    vertical: AppPadding.p20.h),
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      InkWell(
                        onTap: () {
                          setState(() {
                            seen = false;
                            notSeen = true;
                            query = FirebaseFirestore.instance
                                .collection(Paths.objectionsPath)
                                .where('objectionStatus', isEqualTo: false)
                                .orderBy('timestamp', descending: true);
                          });
                        },
                        child: Container(
                          height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h60.h : AppSize.h30.h,
                          width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? size.width * AppSize.w0_1
                              : size.width * AppSize.w0_3,
                          padding: const EdgeInsets.all(AppPadding.p2),
                          decoration: BoxDecoration(
                            color: notSeen
                                ? Theme.of(context).primaryColor
                                : AppColors.lightPink,
                            borderRadius: BorderRadius.circular(
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r30.r : AppRadius.r15.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "notSeen"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: notSeen
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s25.sp
                                    : AppFontsSizeManager.s11.sp,
                                letterSpacing: AppConstants.letterSpacing0_3,
                              ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(
                         width: AppSize.w5.w,
                      ),
                      InkWell(
                        splashColor: AppColors.pink.withOpacity(0.6),
                        onTap: () {
                          setState(() {
                            seen = true;
                            notSeen = false;
                            query = FirebaseFirestore.instance
                                .collection(Paths.objectionsPath)
                                .where('objectionStatus', isEqualTo: true)
                                .orderBy('timestamp', descending: true);
                          });
                        },
                        child: Container(
                          height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h60.h : AppSize.h30.h,
                          width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? size.width * AppSize.w0_1
                              : size.width * AppSize.w0_3,
                          padding: const EdgeInsets.all(AppPadding.p2),
                          decoration: BoxDecoration(
                            color: seen
                                ? Theme.of(context).primaryColor
                                : AppColors.lightPink,
                            borderRadius: BorderRadius.circular(
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r30.r : AppRadius.r15.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "seen"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: seen
                                    ? Colors.white
                                    : Theme.of(context).primaryColor,
                                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s25.sp
                                    : AppFontsSizeManager.s11.sp,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ])),
          ),
          Expanded(
            child: PaginateFirestore(
              key: ValueKey(query),
              itemBuilderType: PaginateBuilderType.listView,
              separator:
                  SizedBox(height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h40.h : AppSize.h20.h),
              padding: EdgeInsets.only(
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ?size.width * AppPadding.p0_3 : AppPadding.p16,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue) ?size.width * AppPadding.p0_3 : AppPadding.p16,
                  bottom:AppPadding.p16,
                  top: AppPadding.p16),
              //Change types accordingly
              itemBuilder: (context, documentSnapshot, index) {
                return ObjectionWidget(
                  item:
                      Objections.fromMap(documentSnapshot[index].data() as Map),
                  size: size,
                );
              },
              query: query,
              // to fetch real-time data
              isLive: true,
            ),
          )
        ],
      ),
    );
  }
}
