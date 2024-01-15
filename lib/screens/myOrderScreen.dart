import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/TabButton.dart';
import 'package:jeras/widget/component/tab_bar/custom_tab_bar.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/order.dart';
import '../../models/user.dart';
import '../../widget/orderListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_shadow.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../widget/component/IconButton.dart';
import '../widget/component/textWidget.dart';

class MyOrdersScreen extends StatefulWidget {
  final GroceryUser? user;
  final String? loggedType;
  final bool? fromSupport;

  const MyOrdersScreen({Key? key, this.user, this.loggedType, this.fromSupport})
      : super(key: key);

  @override
  _MyOrdersScreenState createState() => _MyOrdersScreenState();
}

class _MyOrdersScreenState extends State<MyOrdersScreen>
    with SingleTickerProviderStateMixin {
  late List<GroceryUser> activeList;
  final TextEditingController searchController = new TextEditingController();
  bool load = false, open = true, closed = false, summary = false;
  late String lang, userImage, theme;
  String name = "";
  late Query filterQuery;
  late String from, to;
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool loadingNumber = false, loadingEarn = false;
  late String filterEarn, filterOrders;
  late Query query;

  @override
  void initState() {
    super.initState();
    from = "From"; //DateTime(2020,01, 01 ).toString().substring(0,10);
    to = "To"; //DateTime.now().toString().substring(0,10);
    filterEarn = "0";
    filterOrders = "0";
    theme = "light";
    activeList = [];
    query = widget.user!.userType == "CONSULTANT"
        ? FirebaseFirestore.instance
            .collection(Paths.ordersPath)
            .where('consult.uid', isEqualTo: widget.user!.uid)
            .where('orderStatus', whereIn: ["open", "completed"]).orderBy(
                'orderTimestamp',
                descending: true)
        : FirebaseFirestore.instance
            .collection(Paths.ordersPath)
            .where('user.uid', isEqualTo: widget.user!.uid)
            .where('orderStatus', whereIn: ["open", "completed"]).orderBy(
                'orderTimestamp',
                descending: true);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

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
                    CustomBackButton(),
                    SizedBox(width: AppSize.w10.w),
                    Text(
                      getTranslated(context, "orders"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: checkIfWeb(context)
                              ? AppFontsSizeManager.s34.sp
                              : convertPtToPx(AppFontsSizeManager.s16.sp),
                          color: AppColors.blackColor,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ))),
          Divider(
            color: AppColors.greyShade300,
          ),
          Padding(
            padding: EdgeInsets.only(
                top: AppPadding.p20,
                right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.width * AppSize.h0_15
                    : AppPadding.p10,
                left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.width * AppSize.h0_15
                    : AppPadding.p10,
                bottom: AppPadding.p20),
            child: CustomTabBar(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h120.h
                    : AppSize.h58_6.h,
                backgroundColor: AppColors.primaryColor.withOpacity(0.05),
                buttons: [
                  //button x
                  TabButton(
                    onPress: () {
                      setState(() {
                        open = true;
                        closed = false;
                        summary = false;
                        query = widget.user!.userType == "CONSULTANT"
                            ? FirebaseFirestore.instance
                                .collection(Paths.ordersPath)
                                .where('consult.uid',
                                    isEqualTo: widget.user!.uid)
                                .where('orderStatus', whereIn: [
                                "open",
                                "completed"
                              ]).orderBy('orderTimestamp', descending: true)
                            : FirebaseFirestore.instance
                                .collection(Paths.ordersPath)
                                .where('user.uid', isEqualTo: widget.user!.uid)
                                .where('orderStatus', whereIn: [
                                "open",
                                "completed"
                              ]).orderBy('orderTimestamp', descending: true);
                      });
                    },
                    Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w248.w
                        : convertPtToPx(AppSize.w115.w),
                    ButtonRadius:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r5_3.r
                            : convertPtToPx(AppRadius.r4),
                    ButtonColor: open
                        ? theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black
                        : Colors.transparent,
                    Title: getTranslated(context, "openOrders"),
                    TextFont: getTranslated(context, "Ithra"),
                    TextSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : convertPtToPx(AppFontsSizeManager.s16.sp),
                    TextColor: open
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
                        closed = true;
                        open = false;
                        summary = false;
                        query = widget.user!.userType == "CONSULTANT"
                            ? FirebaseFirestore.instance
                                .collection(Paths.ordersPath)
                                .where('consult.uid',
                                    isEqualTo: widget.user!.uid)
                                .where('orderStatus', isEqualTo: "closed")
                                .orderBy('orderTimestamp', descending: true)
                            : FirebaseFirestore.instance
                                .collection(Paths.ordersPath)
                                .where('user.uid', isEqualTo: widget.user!.uid)
                                .where('orderStatus', isEqualTo: "closed")
                                .orderBy('orderTimestamp', descending: true);
                      });
                    },
                    Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? size.width * AppSize.w0_1
                        : size.width * AppSize.w0_25,
                    ButtonRadius:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r16.r
                            : convertPtToPx(AppRadius.r4),
                    ButtonColor: closed
                        ? theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black
                        : Colors.transparent,
                    Title: getTranslated(context, "closedOrders"),
                    TextFont: size.width >= 500
                        ? getTranslated(context, "Ithra")
                        : getTranslated(context, "Ithra"),
                    TextSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : convertPtToPx(AppFontsSizeManager.s16.sp),
                    TextColor: closed
                        ? theme == "light"
                            ? Colors.white
                            : Colors.white
                        : theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black,
                  ),
                  TabButton(
                    onPress: () {
                      setState(() {
                        closed = false;
                        open = false;
                        summary = true;
                      });
                    },
                    Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w244
                        : convertPtToPx(AppSize.w115.w),
                    ButtonRadius:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r16.r
                            : convertPtToPx(AppRadius.r4),
                    ButtonColor: summary
                        ? theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black
                        : Colors.transparent,
                    Title: getTranslated(context, "summary"),
                    TextFont: size.width >= 500
                        ? getTranslated(context, "Ithra")
                        : getTranslated(context, "Ithra"),
                    TextSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : convertPtToPx(AppFontsSizeManager.s16.sp),
                    TextColor: summary
                        ? theme == "light"
                            ? AppColors.white
                            : AppColors.white
                        : theme == "light"
                            ? Theme.of(context).primaryColor
                            : AppColors.black,
                  ),
                ],
                padding: EdgeInsets.all(checkIfWeb(context)
                    ? AppPadding.p18
                    : convertPtToPx(AppPadding.p7.w))),
          ),
          summary == false
              ? Expanded(
                  child: PaginateFirestore(
                    key: ValueKey(query),
                    itemBuilderType: PaginateBuilderType.gridView,
                    initialLoader: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height * AppSize.w0_1,
                        ),
                        CircularProgressIndicator()
                      ],
                    ),
                    onEmpty: Column(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        SizedBox(
                          height: size.height * AppSize.h0_1.h,
                        ),
                        TextWidget(
                          text: getTranslated(context, "noData"),
                          color: AppColors.lightGrey2,
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
                    padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppSize.w0_06
                            : AppPadding.p20,
                        right:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppSize.w0_06
                                : AppPadding.p20,
                        bottom: AppPadding.p16,
                        top: AppPadding.p10),

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
                                ? 10
                                : 5,
                        childAspectRatio:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? (1.2)
                                : (1.2)),

                    itemBuilder: (context, documentSnapshot, index) {
                      return OrderListItem(
                          order: Orders.fromMap(
                              documentSnapshot[index].data() as Map),
                          type: widget.loggedType,
                          //widget.user!.userType,//.user.userType
                          fromSupport: widget.fromSupport,
                          theme: theme);
                    },
                    query: query,
                    // to fetch real-time data
                    isLive: true,
                  ),
                )
              : SizedBox(),
          summary
              ? Padding(
                  padding: EdgeInsets.symmetric(
                      horizontal:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? size.width * AppPadding.p0_25.w
                              : AppPadding.p10.w,
                      ),
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: AppPadding.p50.r, right: AppPadding.p50.r),
                    child: Column(
                      children: [
                          SizedBox(
                          height: AppSize.h25.h,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: AppSize.w26_6.w,
                              child: SvgPicture.asset(
                                AssetsManager.dollarIconPath,
                                height: AppSize.h25.h,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w16.w,
                            ),
                            Text(
                              getTranslated(context, "balance"),
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: theme == "light"
                                    ? AppColors.black87
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21.sp,
                                fontWeight: FontWeight.w500,
                                fontFamily: lang == "ar"
                                    ? "NotoKufiArabic-Regular"
                                    : getTranslated(context, "Montserrat"),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h10.h,
                            ),
                            Spacer(),
                            Text(
                              widget.user!.balance == null
                                  ? '0'
                                  : double.parse(
                                              widget.user!.balance.toString())
                                          .toStringAsFixed(3) +
                                      "\$",
                              style: GoogleFonts.poppins(
                                color: theme == "light"
                                    ? AppColors.black87
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h34_6.h,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: AppSize.w26_6.w,
                              child: SvgPicture.asset(
                                AssetsManager.requestQuoteIconPath,
                                width: AppSize.w26_6.w,
                                height: AppSize.w26_6.h,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w16.w,
                            ),
                            Text(
                              getTranslated(context, "ordersNum"),
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: theme == "light"
                                    ? AppColors.black87
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21.sp,
                                fontWeight: AppFontsWeightManager.bold500,
                                fontFamily: lang == "ar"
                                    ? "NotoKufiArabic-Regular"
                                    : getTranslated(context, "Montserrat"),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h10.h,
                            ),
                            Spacer(),
                            Text(
                              widget.user!.ordersNumbers == null
                                  ? '0'
                                  : widget.user!.ordersNumbers.toString(),
                              style: GoogleFonts.poppins(
                                color: theme == "light"
                                    ? AppColors.black87
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h34_6.h,
                        ),
                        Row(
                          children: <Widget>[
                            Container(
                              width: AppSize.w26_6.w,
                              child: SvgPicture.asset(
                                AssetsManager.solarHandMoneyIconPath,
                                width: AppSize.w13_3.w,
                                height: AppSize.h25.h,
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w16.w,
                            ),
                            Text(
                              widget.user!.userType == "USER"
                                  ? getTranslated(context, "payed")
                                  : getTranslated(context, "totalEarn"),
                              overflow: TextOverflow.clip,
                              style: TextStyle(
                                color: theme == "light"
                                    ? AppColors.black87
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21.sp,
                                fontWeight: AppFontsWeightManager.bold500,
                                fontFamily: lang == "ar"
                                    ? "NotoKufiArabic-Regular"
                                    : getTranslated(context, "Montserrat"),
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h10.h,
                            ),
                            Spacer(),
                            Text(
                              widget.user!.payedBalance == null
                                  ? "0"
                                  : '\$' +
                                      double.parse(widget.user!.payedBalance
                                              .toString())
                                          .toStringAsFixed(2),
                              style: GoogleFonts.poppins(
                                color: theme == "light"
                                    ? AppColors.black87
                                    : AppColors.white,
                                fontSize: AppFontsSizeManager.s21.sp,
                                fontWeight: FontWeight.w500,
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h47_3.h,
                        ),
                        Center(
                            child: Container(
                                color: AppColors.lightGrey,
                                height: AppSize.h2_3.h,
                                width: size.width * AppSize.w0_9)),
                        SizedBox(
                          height: AppSize.h18.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "filterByDate"),
                              style: TextStyle(
                                color: theme == "light"
                                    ? AppColors.primaryColor
                                    : AppColors.white,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s21.sp,
                                fontWeight: FontWeight.w600,
                                fontFamily: lang == "ar"
                                    ? "NotoKufiArabic-SemiBold"
                                    : getTranslated(context, "Montserrat"),
                              ),
                            ),
                            SizedBox(
                              width: AppSize.w10.w,
                            ),
                            SvgPicture.asset(
                              AssetsManager.eventNote,
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w42.r
                                  : AppSize.w26_5.r,
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w42.r
                                  : AppSize.w26_5.r,
                            ),
                          ],
                        ),
                        SizedBox(
                          height: 15.h,
                        ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "from"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: Theme.of(context).primaryColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s13,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                            SizedBox(
                              width:
                                  lang == "ar" ? AppSize.w10.w : AppSize.w5.w,
                            ),
                            InkWell(
                              splashColor: AppColors.white.withOpacity(0.6),
                              onTap: () {
                                _selectFromDate(context);
                              },
                              child: Container(
                                height: AppSize.h45.h,
                                width: AppSize.w140.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.grey,
                                    //                   <--- border color
                                    width: 1,
                                  ),
                                  color: AppColors.white,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r5_3.r),
                                ),
                                child: Center(
                                  child: Text(
                                    from,
                                    style: TextStyle(
                                        fontWeight: from != "From"
                                            ? FontWeight.w500
                                            : FontWeight.w300,
                                        fontFamily: getTranslated(
                                            context, 'Montserrat-Medium'),
                                        fontSize: AppFontsSizeManager.s18_6.sp),
                                  ),
                                ),
                              ),
                            ),
                            SizedBox(
                              width: 26,
                            ),
                            Text(
                              getTranslated(context, "to"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                color: Theme.of(context).primaryColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold700,
                              ),
                            ),
                            SizedBox(
                              width:
                                  lang == "ar" ? AppSize.w10.w : AppSize.w5.w,
                            ),
                            InkWell(
                              splashColor: AppColors.white.withOpacity(0.6),
                              onTap: () {
                                _selectToDate(context);
                              },
                              child: Container(
                                height: AppSize.h45.h,
                                width: AppSize.w140.w,
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: AppColors.grey,
                                    //                   <--- border color
                                    width: 1,
                                  ),
                                  color: AppColors.white,
                                  borderRadius:
                                  BorderRadius.circular(AppRadius.r5_3.r),
                                ),
                                child: Center(
                                  child: Text(
                                    to,
                                    style: TextStyle(
                                        fontWeight: to != "To"
                                            ? FontWeight.w500
                                            : FontWeight.w300,
                                        fontFamily: getTranslated(
                                            context, 'Montserrat-Medium'),
                                        fontSize: AppFontsSizeManager.s18_6.sp),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                        SizedBox(
                          height: AppSize.h42.h,
                        ),
                        Container(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h84.h
                                  : AppSize.h42.h,
                          child: MaterialButton(
                            onPressed: () {
                              calculateOrderNumbers();
                              if (widget.user!.userType == "USER")
                                setState(() {
                                  loadingEarn = false;
                                });
                              else
                                calculateTotalEarn();
                            },
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                            shape: RoundedRectangleBorder(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r5_3.r),
                            ),
                            child: Text(
                              getTranslated(context, "results"),
                              style: TextStyle(
                                color: AppColors.white,
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                fontWeight: AppFontsWeightManager.semiBold,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                fontFamily: lang == "ar"
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(context, "Montserrat"),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h21.h,
                        ),
                        (loadingNumber == false && loadingEarn == false)
                            ? Padding(
                                padding: const EdgeInsets.all(8.0),
                                child: Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceEvenly,
                                  crossAxisAlignment: CrossAxisAlignment.center,
                                  mainAxisSize: MainAxisSize.min,
                                  children: <Widget>[
                                    Expanded(
                                      child: Material(
                                        child: InkWell(
                                          splashColor:
                                              Colors.blue.withOpacity(0.3),
                                          onTap: () {},
                                          child: Container(
                                            width: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.w284.r
                                                : AppSize.w170.r,
                                            height: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.h220.r
                                                : AppSize.h170.r,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor
                                                  .withOpacity(0.05),
                                              // color: AppColors.primaryColor,//0xffF8F8FA
                                              // boxShadow: [
                                              //   AppShadow.primaryShadow
                                              // ],
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.r21_3.r),
                                            ),
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    getTranslated(
                                                        context, "ordersNum"),
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      color: theme == "light"
                                                          ? AppColors
                                                              .primaryColor
                                                          : AppColors.white,
                                                      fontSize: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppFontsSizeManager
                                                              .s32.sp
                                                          : AppFontsSizeManager
                                                              .s21.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: lang == "ar"
                                                          ? "NotoKufiArabic-SemiBold"
                                                          : getTranslated(
                                                              context,
                                                              "Montserrat"),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: AppSize.h10,
                                                  ),
                                                  Text(
                                                    filterOrders,
                                                    style: GoogleFonts.poppins(
                                                      color: AppColors.black1,
                                                      fontSize:
                                                          AppFontsSizeManager
                                                              .s18,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: AppSize.w15,
                                    ),
                                    Expanded(
                                      child: Material(
                                        child: InkWell(
                                          splashColor:
                                              Colors.blue.withOpacity(0.3),
                                          onTap: () {},
                                          child: Container(
                                            width: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.w284.r
                                                : AppSize.w170.r,
                                            height: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppSize.h220.r
                                                : AppSize.h170.r,
                                            decoration: BoxDecoration(
                                              color: AppColors.primaryColor
                                                  .withOpacity(
                                                      0.05), //0xffF8F8FA
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.r21_3.r),
                                              // boxShadow: [
                                              //   AppShadow.primaryShadow
                                              // ],
                                            ),
                                            child: Center(
                                              child: Column(
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                mainAxisAlignment:
                                                    MainAxisAlignment.start,
                                                mainAxisSize: MainAxisSize.min,
                                                children: <Widget>[
                                                  Text(
                                                    getTranslated(
                                                        context, "totalEarn"),
                                                    overflow: TextOverflow.clip,
                                                    style: TextStyle(
                                                      color: theme == "light"
                                                          ? AppColors
                                                              .primaryColor
                                                          : AppColors.white,
                                                      fontSize: (kIsWeb ||
                                                              size.width >=
                                                                  AppConstants
                                                                      .kIsWebValue)
                                                          ? AppFontsSizeManager
                                                              .s32.sp
                                                          : AppFontsSizeManager
                                                              .s21.sp,
                                                      fontWeight:
                                                          FontWeight.w600,
                                                      fontFamily: lang == "ar"
                                                          ? "NotoKufiArabic-SemiBold"
                                                          : getTranslated(
                                                              context,
                                                              "Montserrat"),
                                                    ),
                                                  ),
                                                  SizedBox(
                                                    height: AppSize.h10,
                                                  ),
                                                  Text(
                                                    filterEarn + " \$",
                                                    style: GoogleFonts.poppins(
                                                      color: AppColors.black1,
                                                      fontSize:
                                                          AppFontsSizeManager
                                                              .s18,
                                                      fontWeight:
                                                          AppFontsWeightManager
                                                              .semiBold,
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),
                              )
                            : Center(child: CircularProgressIndicator()),
                        SizedBox(
                          height: AppSize.h15.h,
                        ),
                      ],
                    ),
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  calculateOrderNumbers() async {
    setState(() {
      loadingNumber = true;
    });
    QuerySnapshot querySnapshot;
    if (widget.user!.userType == "USER")
      querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where('user.uid', isEqualTo: widget.user!.uid)
          .where('orderTimeValue',
              isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
          .where('orderTimeValue',
              isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
          .get();
    else
      querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where('consult.uid', isEqualTo: widget.user!.uid)
          .where('orderTimeValue',
              isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
          .where('orderTimeValue',
              isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
          .get();
    if (querySnapshot.docs.length > 0) {
      if (widget.user!.userType == "USER") {
        double total = 0;
        for (var item in querySnapshot.docs) {
          total = total + double.parse(item['price'].toString());
        }
        setState(() {
          filterEarn = total.toString() + "\$";
          loadingEarn = false;
        });
      }
      setState(() {
        filterOrders = querySnapshot.docs.length.toString();
        loadingNumber = false;
      });
    } else {
      setState(() {
        filterOrders = "0";
        loadingNumber = false;
      });
    }
  }

  calculateTotalEarn() async {
    setState(() {
      loadingEarn = true;
    });
    double total = 0;
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.payHistoryPath)
        .where('consultUid', isEqualTo: widget.user!.uid)
        .where('payDate',
            isGreaterThanOrEqualTo: selectedFromDate.millisecondsSinceEpoch)
        .where('payDate',
            isLessThanOrEqualTo: selectedToDate.millisecondsSinceEpoch)
        .get();
    if (querySnapshot.docs.length > 0) {
      for (var item in querySnapshot.docs) {
        total = total + double.parse(item['balance'].toString());
      }
      setState(() {
        filterEarn = total.toString() + "\$";
        loadingEarn = false;
      });
    } else {
      setState(() {
        filterEarn = "0";
        loadingEarn = false;
      });
    }
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
        from = selectedFromDate.toString().substring(0, 10);
      });
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
        to = selectedToDate.toString().substring(0, 10);
      });
  }
}
