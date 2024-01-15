import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/api/dynamicLink.dart';
import 'package:jeras/config/app_shadow.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/models/user.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/consultItem.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:simple_gradient_text/simple_gradient_text.dart';
import 'package:uuid/uuid.dart';

import '../Utils/helper.dart';
import '../Utils/styles.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/paths.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../localization/localization_methods.dart';
import '../models/courseRate.dart';
import '../models/courses.dart';
import '../models/promoCode.dart';
import '../widget/component/textWidget.dart';
import '../widget/rateItem.dart';

class CourseDetailScreen extends StatefulWidget {
  final String courseId;
  final String? tabid;
  final String? paydata;

  CourseDetailScreen(
      {Key? key, required this.courseId, this.tabid, this.paydata})
      : super(key: key);

  @override
  State<CourseDetailScreen> createState() => _CourseDetailScreenState();
}

class _CourseDetailScreenState extends State<CourseDetailScreen>
    with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  List<GroceryUser> allConsult = [];
  List<CourseRate> allRates = [];
  late Courses course;
  GroceryUser? user;
  bool sharing = false;
  late String lang;
  late Size size;

  @override
  void initState() {
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetCourseDetailsEvent(widget.courseId));
    getCoursesConsult(widget.courseId);
    getCoursesRates(widget.courseId);
    super.initState();

    if (widget.tabid != null && widget.tabid!.isNotEmpty) {
      checkwithTab();
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Scaffold(
      body: BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          if (state is getCourseDetailsProgressState) {
            return Center(child: CircularProgressIndicator());
          } else if (state is getCourseDetailsCompletedState) {
            user = state.user;
            course = state.course!;
            return (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? webBodyWidget(size)
                : bodyWidget();
          } else {
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  //tablet
  Widget webBodyWidget(Size size) {
    return ListView(
      children: [
        headerWidget(size),
        courseDataWidget(size),
        ListView.separated(
          itemCount: allConsult.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            return ConsultItem(
              consultant: allConsult[index],
              course: course,
              user: user,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 20.0.w,
            );
          },
        ),
        rateWidget(size),
        ListView.separated(
          itemCount: allRates.length,
          shrinkWrap: true,
          physics: const NeverScrollableScrollPhysics(),
          padding: const EdgeInsets.all(0),
          itemBuilder: (context, index) {
            return RateItem(
              courseRate: allRates[index],
              isFinalOne: false,
            );
          },
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(
              width: 20.0.w,
            );
          },
        ),
      ],
    );
  }

  headerWidget(Size size) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Padding(
          padding: EdgeInsets.symmetric(
              vertical: AppPadding.p58.h, horizontal: AppPadding.p140.w),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              IconButton(
                  padding: EdgeInsets.zero,
                  icon: Container(
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w80.w
                          : AppSize.w75.w,
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w80.w
                          : AppSize.h75.h,
                      //p

                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r25.r
                                  : AppRadius.r45.r),
                          border: Border.all(color: AppColors.grey2),
                          color: AppColors.white),
                      child: Icon(
                        Icons.arrow_back,
                        size: AppSize.h48.h,
                        color: AppColors.black4,
                      )),
                  onPressed: () {
                    Navigator.pop(context);
                  }),
              Spacer(
                flex: 2,
              ),
              Row(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Stack(
                    alignment: AlignmentDirectional.center,
                    children: [
                      Container(
                        height: AppSize.h506_2.h,
                        width: AppSize.w802_9.w,
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r50.r),
                            boxShadow: [AppShadow.greyshadow2]),
                        padding: EdgeInsets.all(AppPadding.p31.r),
                        child: Container(
                          height: AppSize.h444_6.h,
                          width: AppSize.w740.w,
                          child: SvgPicture.asset(
                            AssetsManager.coursesCart,
                            fit: BoxFit.fill,
                          ),
                        ),
                      ),
                      Positioned(
                          bottom: 0,
                          left: 0,
                          right: 0,
                          top: 0,
                          child: Padding(
                            padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p10.w,
                            ),
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              crossAxisAlignment: CrossAxisAlignment.center,
                              children: [
                                GradientText(
                                  course.name,
                                  textAlign: TextAlign.center,
                                  style: TextStyle(
                                      fontSize: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppFontsSizeManager.s30.sp
                                          : AppFontsSizeManager.s25.sp,
                                      fontFamily: "Bukra",
                                      fontWeight: FontWeight.bold),
                                  // gradientType: GradientType.radial,
                                  // radius: 2.5,
                                  colors: const [
                                    AppColors.darkYellow2,
                                    AppColors.primaryColor,
                                  ],
                                ),

                                SizedBox(
                                  height: AppSize.h5.h,
                                ),
                                TextWidget(
                                  text: course.summary!,
                                  color: AppColors.primaryColor,
                                  size: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s18.sp
                                      : AppFontsSizeManager.s10.sp,
                                  weight: FontWeight.w400,
                                  lines: 2,
                                  family: "Bukra",
                                  align: TextAlign.center,
                                ),
                                SizedBox(
                                  height: AppSize.h5.h,
                                ),

                                //
                              ],
                            ),
                          ))
                    ],
                  ),
                  SizedBox(width: AppSize.w44.w),
                  Container(
                    height: AppSize.h430.h,
                    width: AppSize.w131.w,
                    padding: EdgeInsets.symmetric(
                        horizontal: AppSize.w32.w, vertical: AppPadding.p51.h),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Container(
                              width: size.width >= AppConstants.kIsWebValue
                                  ? AppSize.w67.w
                                  : AppSize.w50.w,
                              height: size.width >= AppConstants.kIsWebValue
                                  ? AppSize.h67.h
                                  : AppSize.h50.h,
                              padding: EdgeInsets.all(AppPadding.p20_5.r),
                              decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(40.r),
                                  color: AppColors.white1),
                              child: Image.asset(
                                AssetsManager.blackShareIconPath,
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w23_6.w
                                    : AppSize.w15.r,
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h26_3.h
                                    : AppSize.h15.r,
                              ),
                            ),
                            onPressed: () {
                              share();
                            }),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Container(
                                width: size.width >= AppConstants.kIsWebValue
                                    ? AppSize.w67.w
                                    : AppSize.w49_3.w,
                                height: size.width >= AppConstants.kIsWebValue
                                    ? AppSize.h67.h
                                    : AppSize.h49_3.h,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r40.r),
                                    color: AppColors.white1),
                                child: Icon(
                                  Icons.favorite,
                                  size: AppSize.w25,
                                  color: user != null
                                      ? user!.favoriteCorses!
                                              .contains(course.courseId)
                                          ? AppColors.red
                                          : AppColors.grey
                                      : AppColors.grey,
                                )),
                            onPressed: () {}),
                        IconButton(
                            padding: EdgeInsets.zero,
                            icon: Container(
                                width: size.width >= AppConstants.kIsWebValue
                                    ? AppSize.w67.r
                                    : AppSize.w38.r,
                                height: size.width >= AppConstants.kIsWebValue
                                    ? AppSize.h67.r
                                    : AppSize.h38.r,
                                decoration: BoxDecoration(
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r40.r),
                                    color: AppColors.white),
                                child: Center(
                                  child: Row(
                                    children: [
                                      Spacer(),
                                      Icon(
                                        Icons.star,
                                        color: AppColors.yellow,
                                        size: AppSize.w15,
                                      ),
                                      SizedBox(
                                        width: AppSize.w2.w,
                                      ),
                                      TextDefaultWidget(
                                          title: "${course.rating}",
                                          color: AppColors.black,
                                          fontSize: size.width >=
                                                  AppConstants.kIsWebValue
                                              ? AppFontsSizeManager.s25.sp
                                              : AppFontsSizeManager.s17.sp,
                                          fontWeight: FontWeight.bold),
                                      Spacer(),
                                    ],
                                  ),
                                )),
                            onPressed: () {}),
                      ],
                    ),
                    decoration: BoxDecoration(
                      color: AppColors.grey4,
                      borderRadius: BorderRadius.circular(AppRadius.r66.r),
                      boxShadow: [
                        BoxShadow(
                            color: Color.fromRGBO(0, 0, 0, 0.08),
                            offset: Offset(9, 12),
                            blurRadius: 17,
                            spreadRadius: 0)
                      ],
                    ),
                  ),
                ],
              ),
              Spacer(),
            ],
          ),
        ),
        // Padding(
        //   padding: EdgeInsets.only(bottom: AppPadding.p58.h),
        //   child: Container(
        //     height: AppSize.h1.h,
        //     color: AppColors.grey2,
        //   ),
        // ),
      ],
    );
  }

  courseDataWidget(Size size) {
    return Container(
      padding: size.width >= AppConstants.kIsWebValue
          ? EdgeInsets.symmetric(horizontal: AppPadding.p140.w)
          : EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
      decoration: BoxDecoration(
        color: AppColors.white,
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(33.r),
          topRight: Radius.circular(33.r),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            height: AppSize.h10.h,
          ),
          Padding(
            padding: EdgeInsets.symmetric(vertical: AppPadding.p20.h),
            child: Center(
              child: GradientText(
                "${course.name}",
                textAlign: TextAlign.center,
                maxLines: 1,
                style: TextStyle(
                    fontSize: size.width >= AppConstants.kIsWebValue
                        ? AppFontsSizeManager.s38.sp
                        : AppFontsSizeManager.s29.sp,
                    fontFamily: "Bukra",
                    fontWeight: FontWeight.bold),
                // gradientType: GradientType.radial,
                radius: AppRadius.r2_5,
                colors: const [
                  AppColors.darkYellow2,
                  AppColors.primaryColor,
                ],
              ),
            ),
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h44_4.h
                : AppSize.h30.h,
          ),
          Text(
            "${getTranslated(context, "course_desc")}",
            style: Styles.getTextStyle(
              color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppColors.black
                  : AppColors.primaryColor,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s36.sp
                  : AppFontsSizeManager.s24.sp,
              fontfamily: getTranslated(context, "Ithra"),
              fontWeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsWeightManager.bold100
                  : AppFontsWeightManager.bold,
            ),
          ),
          SizedBox(
            height: AppSize.h10.h,
          ),
          Text(
            "${course.desc}ً",
            style: Styles.getTextStyle(
              color: AppColors.lightGrey1,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s30.sp
                  : AppFontsSizeManager.s20.sp,
              fontfamily: getTranslated(context, "Ithra"),
              fontWeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsWeightManager.bold100
                  : AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h44_4.h
                : AppSize.h30.h,
          ),
          Text(
            "${getTranslated(context, "course_sections")}",
            style: Styles.getTextStyle(
              color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppColors.black
                  : AppColors.primaryColor,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s36.sp
                  : AppFontsSizeManager.s24.sp,
              fontfamily: getTranslated(context, "Ithra"),
              fontWeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsWeightManager.bold100
                  : AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: AppSize.h7.h,
          ),
          Text(
            "${course.sections}ً",
            style: Styles.getTextStyle(
              color: AppColors.lightGrey1,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s30.sp
                  : AppFontsSizeManager.s20.sp,
              fontfamily: getTranslated(context, "Ithra"),
              fontWeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsWeightManager.bold100
                  : AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h44_4.h
                : AppSize.h30.h,
          ),
          Text(
            "${getTranslated(context, "course_notes")}",
            style: Styles.getTextStyle(
              color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppColors.black
                  : AppColors.primaryColor,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s36.sp
                  : AppFontsSizeManager.s24.sp,
              fontfamily: getTranslated(context, "Ithra"),
              fontWeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsWeightManager.bold100
                  : AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: AppSize.h7.h,
          ),
          Text(
            "${course.notes}ً",
            style: Styles.getTextStyle(
              color: AppColors.lightGrey1,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s30.sp
                  : AppFontsSizeManager.s20.sp,
              fontfamily: getTranslated(context, "Ithra"),
              fontWeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsWeightManager.bold100
                  : AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h44_4.h
                : AppSize.h40.h,
          ),
          Text(
            "${getTranslated(context, "courseCandidates")}",
            style: Styles.getTextStyle(
              color: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppColors.black
                  : AppColors.primaryColor,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s36.sp
                  : AppFontsSizeManager.s24.sp,
              fontfamily: getTranslated(context, "Ithra"),
              fontWeight: AppFontsWeightManager.bold300,
            ),
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h24_4.h
                  :AppSize.h20.h,
          ),
        ],
      ),
    );
  }

  //d.c
  rateWidget(Size size) {
    return Container(
      color: AppColors.white,
      padding: EdgeInsets.symmetric(horizontal: AppPadding.p30.w),
      child: Column(
        children: [
          Row(children: [
            Text("${getTranslated(context, "course_rates")}",
                style: Styles.getTextStyle(
                  color: AppColors.black1,
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s35.sp
                      : AppFontsSizeManager.s24.sp,
                  fontfamily: getTranslated(context, "Ithra"),
                  fontWeight: AppFontsWeightManager.bold300,
                )),
            SizedBox(
              width: AppSize.w5.w,
            ),
            Text(
              "(",
              style: Styles.getTextStyle(
                  color: AppColors.pink,
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s20.sp
                      : AppFontsSizeManager.s17.sp),
            ),
            Text("${allRates.length}",
                style: Styles.getTextStyle(
                    color: AppColors.pink,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s20.sp
                        : AppFontsSizeManager.s13.sp)),
            Icon(
              Icons.star,
              color: AppColors.yellow,
              size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w15
                  : AppSize.w10,
            ),
            Text(")",
                style: Styles.getTextStyle(
                    color: AppColors.pink,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s20.sp
                        : AppFontsSizeManager.s17.sp)),
          ]),
          SizedBox(
            height: AppSize.h30.h,
          ),
        ],
      ),
    );
  }

  checkwithTab() async {
    try {
      FirebaseFunctions functions = FirebaseFunctions.instance;
      HttpsCallable callable = functions.httpsCallable("checkWithTab");
      final res = await callable.call({
        'consultid': widget.courseId,
        'tabid': widget.tabid,
        "tabdata": widget.paydata
      });

      if (res.data['status'] == "CAPTURED") {
        //
        updateDatabaseAfterAddingOrder(res); //,res.data['amount']);
      } else {
        //--------add details event
        /*
        String eventName = "af_add_payment_info";
        Map eventValues = {
          "af_success": "false",
          "af_achievement_id": res['status'],
        };
        addEvent(eventName, eventValues);
        await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
          "success": false,
          "reason": res['status'],
          "userUid": user!.uid
        });*/
        String id = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.errorLogPath)
            .doc(id)
            .set({
          'timestamp': Timestamp.now(),
          'id': id,
          'seen': false,
          'desc': res.data['status'],
          'phone': user == null ? " " : user!.phoneNumber,
          'screen': "ConsultantDetailsScreen",
          'function': "payStatus",
        });
        setState(() {
          // showPayView = false;
          // load = false;
        });
        Helper.ShowToastMessage(getTranslated(context, "failed"), true);
      }

      //   js.context.callMethod('open', [res.data['transaction']['url'],'_self']); //<= find explanation below

      //  !await launchUrl(Uri.parse( res.data['transaction']['url']));
      //   html.WindowBase _popup = html.window.open(res.data['transaction']['url'], '_blank','left=100,top=100,width=800,height=600');
      //   html.window.onMessage.listen((event) async {
      //      // Prints out the Message
      //
      //   });
      //
      // _popup.addEventListener("message", (event) {
      //  //
      //
      //
      // });
      // html.window.onMessage.listen((event) {
      //
      //
      //   // if (event.data.toString().contains('code=')) {
      //   //   code = event.data.toString().split('code=')[1].split('&')[0];
      //   // }
      // });

      //

      return res.data;
    } catch (e) {
      throw e;
    }
  }

  updateDatabaseAfterAddingOrder(var res) async {
    try {
      PromoCode? promo;
      GroceryUser? _consultant, _user;
      Courses? course;
      if (res.data['metadata']['promoCodeId'] != null) {
        var promoData = await FirebaseFirestore.instance
            .collection("PromoCode")
            .doc(res.data['metadata']['promoCodeId'])
            .get();
        promo = PromoCode.fromMap(promoData.data() as Map);
      }
      var coursedata = await FirebaseFirestore.instance
          .collection("Courses")
          .doc(res.data['metadata']['courseId'])
          .get();
      course = Courses.fromMap(coursedata.data() as Map);
      var consdata = await FirebaseFirestore.instance
          .collection("Users")
          .doc(res.data['metadata']['consultUid'])
          .get();
      _consultant = GroceryUser.fromMap(consdata.data() as Map);
      var userdata = await FirebaseFirestore.instance
          .collection("Users")
          .doc(res.data['metadata']['userUid'])
          .get();
      _user = GroceryUser.fromMap(userdata.data() as Map);

      String orderId = Uuid().v4();
      DateTime dateValue = DateTime.now();

      //double remove5price=   double.parse(amount.toString())- double.parse(amount.toString())*.05;

      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .doc(orderId)
          .set({
        'orderStatus': "completed",
        'consultType': "jeras",
        'orderId': orderId,
        'chargeId': "",
        'date': {
          'day': dateValue.day,
          'month': dateValue.month,
          'year': dateValue.year,
        },
        'utcTime': dateValue.toUtc().toString(),
        'orderTimestamp': Timestamp.now(),
        'orderTimeValue':
            DateTime(dateValue.year, dateValue.month, dateValue.day)
                .millisecondsSinceEpoch,
        'packageId': "",
        'promoCodeId': res.data['metadata']['promoCodeId'],
        'remainingCallNum': course.lessonNum,
        'packageCallNum': course.lessonNum,
        'answeredCallNum': 0,
        'callPrice': res.data['metadata']['callPrice'],
        "payWith": "tabCompany",
        "platform": 'Web',
        'price': res.data['metadata']['price'],
        'consult': {
          'uid': _consultant.uid,
          'name': _consultant.name,
          'image': _consultant.photoUrl,
          'phone': _consultant.phoneNumber,
          'countryCode': _consultant.countryCode,
          'countryISOCode': _consultant.countryISOCode,
        },
        'user': {
          'uid': _user.uid!,
          'name': _user.name,
          'image': _user.photoUrl,
          'phone': _user.phoneNumber,
          'countryCode': _user.countryCode,
          'countryISOCode': _user.countryISOCode,
        },
        'course': {
          'courseId': course.courseId,
          'courseName': course.name,
          'courseImage': ".",
        }
      }).then((value) {});
      //currentNumber= course!.lessonNum;
      // update consult order numbers
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(_consultant.uid)
          .set({
        'openOrders': _consultant.openOrders + 1,
      }, SetOptions(merge: true));

      //update user order numbers
      if (_user.ordersNumbers == null || _user.ordersNumbers! < 1)
        await FirebaseFirestore.instance
            .collection(Paths.appAnalysisPath)
            .doc("TgWCp3B22sbkl0Nm3wLx")
            .set({
          'buyedMagadUsers': FieldValue.increment(1),
        }, SetOptions(merge: true));

      int userOrdersNumbers = 1;
      dynamic payedBalance =
          double.parse(res.data['metadata']['price'].toString());
      if (_user.ordersNumbers != null)
        userOrdersNumbers = _user.ordersNumbers! + 1;
      if (_user.payedBalance != null)
        payedBalance = _user.payedBalance + payedBalance;
      if (res.data['metadata']['promoCodeId'] != null &&
          res.data['metadata']['promoCodeId'].toString().isNotEmpty &&
          promo!.type == "primary")
        user?.promoList!.add(res.data['metadata']['promoCodeId']);
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(_user.uid)
          .set({
        'ordersNumbers': userOrdersNumbers,
        'payedBalance': payedBalance,
        'preferredPaymentMethod': "tapCompany",
        'promoList': user!.promoList,
      }, SetOptions(merge: true));
      //  accountBloc.add(GetLoggedUserEvent());
//======update number of use of promocode
      if (promo != null) {
        await FirebaseFirestore.instance
            .collection(Paths.promoPath)
            .doc(promo.promoCodeId)
            .set({
          'usedNumber': promo.usedNumber + 1,
        }, SetOptions(merge: true));
      }

      //  --------add details event

      //
      // String eventName = "af_add_payment_info";
      // Map eventValues = {
      //   "af_success": true,
      //   "af_achievement_id": "success",
      // };
      // Helper.addEvent(eventName, eventValues);
      // await FirebaseAnalytics.instance.logEvent(name: "payInfo",parameters:{
      //   "success": true,
      //   "reason": "success",
      //   "userUid":widget.user!.uid
      // } );
      //-----------
      //
      // eventName = "af_purchase";
      // eventValues = {
      //   "af_revenue": price.toString(),
      //   "af_price": price.toString(),
      //   "af_content_id": widget.consultant.uid,
      //   "af_order_id": orderId,
      //   "af_currency": "USD",
      // };

      // addEvent(eventName, eventValues);
      //  Navigator.pop(context);
      ///*****************
      // showAddAppointmentDialog(
      //     orderId: orderId,
      //     callPrice: double.parse(res.data['metadata']['callPrice'].toString()),
      //     localFrom: int.parse(res.data['metadata']['localFrom'].toString()),
      //     localTo: int.parse(res.data['metadata']['localTo'].toString()),
      //     remainingCalls: course.lessonNum,
      //     consltantid: _consultant.uid.toString(),
      //     courseId: course.courseId,
      //     coursename: course.name);
    } catch (e) {
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone': user == null ? " " : user!.phoneNumber,
        'screen': "courseDetails",
        'function': "pay",
      });
    }
  }

  // showAddAppointmentDialog(
  //     {required String orderId,
  //     required dynamic callPrice,
  //     required int localFrom,
  //     required String consltantid,
  //     required String courseId,
  //     required String coursename,
  //     required int localTo,
  //     required int remainingCalls}) async {
  //   await showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) {
  //       return AddAppointmentDialog(
  //           loggedUser: user!,
  //           consultant: allConsult.firstWhere((element) => element.uid == consltantid),
  //           consultType: allConsult.firstWhere((element) => element.uid == consltantid).consultType!,
  //           order: Orders.fromMap({}),
  //           //callPrice: callPrice,
  //           //orderId: orderId,
  //           localFrom: localFrom,
  //           localTo: localTo,
  //           //course: CourseOrder(id: courseId, name: coursename, image: "."),
  //           currentNumber: (allConsult
  //                           .firstWhere((element) => element.uid == consltantid)
  //                           .consultType ==
  //                       "perfect" ||
  //                   allConsult
  //                           .firstWhere((element) => element.uid == consltantid)
  //                           .consultType ==
  //                       "jeras")
  //               ? remainingCalls
  //               : remainingCalls - 1);
  //     },
  //   );
  // }

  Widget bodyWidget() {
    return CustomScrollView(
      slivers: [
        SliverAppBar(
          stretch: true,
          centerTitle: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.only(
              bottomLeft: Radius.circular(0.0.r),
              bottomRight: Radius.circular(0.0.r),
            ),
          ),
          // pinned: true,
          snap: true,
          floating: true,
          expandedHeight: AppSize.h274.h,
          leading: const SizedBox(),
          actions: [
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p48.w),
              child: CustomBackButton(),
            ),
            const Spacer(),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p48.w),
              child: IconButton1(
                onPress: () {
                  share();
                },
                Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w75.w
                    : AppSize.w50_6.w,
                Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w75.h
                    : AppSize.h45.h,
                ButtonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppRadius.r24.r
                    : AppRadius.r10_6.r,
                IconWidth: AppSize.w32.r,
                IconHeight: AppSize.h32.r,
                IconColor: Theme.of(context).primaryColor,
                Icon: AssetsManager.shareIconPath,
                ButtonBackground: AppColors.white,
              ),
            ),
          ],
          flexibleSpace: FlexibleSpaceBar(
            centerTitle: true,
            stretchModes: const <StretchMode>[
              StretchMode.zoomBackground,
              StretchMode.blurBackground,
              StretchMode.fadeTitle,
            ],
            // ClipRRect added here for rounded corners
            background: ClipRRect(
              borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0.r),
                  bottomRight: Radius.circular(0.0.r)),
              child: Stack(
                children: [
                  course.backgroundImage == null
                      ? Container(
                          height: size.height,
                          decoration: BoxDecoration(
                            // borderRadius: BorderRadius.only(bottomLeft: Radius.circular(35),bottomRight: Radius.circular(35)),
                            color: Colors.grey,
                          ),
                        )
                      : Container(
                          child: FadeInImage.assetNetwork(
                            placeholder: AssetsManager.lodeGif,
                            placeholderScale: 0.5,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Icon(
                              Icons.image,
                              color: Colors.grey,
                              size: AppSize.w32,
                            ),
                            image: course.backgroundImage!,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(
                                milliseconds: AppConstants.milliseconds250),
                            fadeInCurve: Curves.easeInOut,
                            fadeOutDuration: Duration(
                                milliseconds: AppConstants.milliseconds150),
                            fadeOutCurve: Curves.easeInOut,
                          ),
                        ),

                  //icons
                  PositionedDirectional(
                    //padding:  EdgeInsets.symmetric(vertical: size.height * .1),
                    top: AppPadding.p176.h,
                    end: AppPadding.p45.w,
                    child: Column(
                      children: [
                        Container(
                            width: AppSize.w50_6.r,
                            height: AppSize.h50_6.r,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r40.r),
                              color: Colors.white,
                              boxShadow: [
                                BoxShadow(
                                    color: const Color(0x0d202020),
                                    offset: Offset(0, 7),
                                    blurRadius: 25,
                                    spreadRadius: 0)
                              ],
                            ),
                            //course icon problem
                            //done
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.center,
                              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                              children: [
                                Expanded(child: SizedBox()),
                                TextDefaultWidget(
                                    title: "${course.rating}",
                                    color: AppColors.black,
                                    fontSize: AppFontsSizeManager.s16.sp),
                                SizedBox(
                                  width: AppSize.w1.w,
                                ),
                                Icon(
                                  Icons.star,
                                  color: AppColors.yellow,
                                  size: AppSize.w18_6.r,
                                ),
                                Expanded(child: SizedBox()),
                              ],
                            )),
                      ],
                    ),
                  )
                ],
              ),
            ),
          ),
        ),
        // SliverToBoxAdapter(
        //   child: Column(
        //     mainAxisAlignment: MainAxisAlignment.end,
        //     children: <Widget>[
        //       Container(
        //         height: AppSize.h30.h,
        //         decoration: BoxDecoration(
        //           color: Colors.blue,
        //           borderRadius: BorderRadius.only(
        //             topLeft: Radius.circular(35.r),
        //             topRight: Radius.circular(35.r),
        //           ),
        //         ),
        //       ),
        //     ],
        //   ),
        // ),
        SliverToBoxAdapter(
          child: courseDataWidget(size),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: allConsult.length,
            (BuildContext context, int index) {
              return ConsultItem(
                consultant: allConsult[index],
                course: course,
                user: user,
              );
            },
          ),
        ),
        SliverToBoxAdapter(
          child: rateWidget(size),
        ),
        SliverList(
          delegate: SliverChildBuilderDelegate(
            childCount: allRates.length,
            (BuildContext context, int index) {
              return RateItem(
                courseRate: allRates[index],
                isFinalOne: false,
              );
            },
          ),
        ),
      ],
    );
  }

  getCoursesConsult(String courseId) async {
    List<String> list = [courseId];
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('Users')
        .where('courses', arrayContainsAny: list)
        .where("openOrders", isLessThan: 5)
        .where("accountStatus", isEqualTo: "Active")
        .where("userType", isEqualTo: "CONSULTANT")
        .get();

    var ConsultList = List<GroceryUser>.from(
      querySnapshot.docs.map(
        (snapshot) => GroceryUser.fromMap(snapshot.data() as Map),
      ),
    );
    setState(() {
      allConsult = ConsultList;
    });
  }

  getCoursesRates(String courseId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection('CourseReviews')
        .where('courseId', isEqualTo: courseId)
        .get();
    var CourseReviewList = List<CourseRate>.from(
      querySnapshot.docs.map(
        (snapshot) => CourseRate.fromMap(snapshot.data() as Map),
      ),
    );
    setState(() {
      allRates = CourseReviewList;
    });
  }

  share() async {
    try {
      setState(() {
        sharing = true;
      });
      String courseId = widget.courseId;

      String courseUrl =
          "https://jerasnew.web.app/courses?course_id=${courseId}";
      String url = await dynamicLinks.shareProgrambyDynamicLink(
          courseUrl, context, course);
      Share.share(url);
      setState(() {
        sharing = false;
      });
    } catch (e) {}
  }
}
