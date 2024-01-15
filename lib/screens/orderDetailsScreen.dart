import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/order.dart';
import '../../models/promoCode.dart';
import '../../models/user.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../models/consultPackage.dart';
import '../models/consultReview.dart';

class OrderDetails extends StatefulWidget {
  final Orders order;
  final String? type;
  final bool? fromSupport;

  const OrderDetails(
      {Key? key, required this.order, this.type, this.fromSupport})
      : super(key: key);

  @override
  _OrderDetailsState createState() => _OrderDetailsState();
}

class _OrderDetailsState extends State<OrderDetails> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  consultPackage? package;
  PromoCode? promo;
  ConsultReview? review;
  bool loadPackage = true,
      loadPromo = true,
      loadAppointments = true,
      loadReview = true;
  DateFormat dateFormat = DateFormat('dd/MM/yy');

  //List<AppAppointments> appointmentList = [];
  var appointmentList = [];

  bool cancel = false;
  String theme = "light";

  @override
  void initState() {
    super.initState();
    getPackageDetails();

    if (widget.order.consultType == "vocal")
      getOrderAppointment();
    else
      getOrderForEverAppointment();
    if (widget.order.promoCodeId != null)
      getPromoDetails();
    else
      loadPromo = false;
  }

  Future<void> getPackageDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .doc(widget.order.packageId)
          .get();
      setState(() {
        package = consultPackage.fromMap(documentSnapshot.data() as Map);
        loadPackage = false;
      });
    } catch (e) {}
  }

  Future<void> getPromoDetails() async {
    try {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(widget.order.promoCodeId)
          .get();
      setState(() {
        promo = PromoCode.fromMap(documentSnapshot.data() as Map);
        loadPromo = false;
      });
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: AppPadding.p20,
                    right: AppPadding.p20,
                    top: AppPadding.p10,
                    bottom: AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomBackButton(),
                        SizedBox(width: AppSize.w21_3.w),
                        Text(
                          getTranslated(context, "details"),
                          textAlign: TextAlign.left,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black1,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s34.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    (widget.fromSupport! &&
                            widget.order.orderStatus != "closed" &&
                            widget.order.orderStatus != "cancel")
                        ? cancel
                            ? CircularProgressIndicator()
                            : InkWell(
                                splashColor: AppColors.white.withOpacity(0.5),
                                onTap: () async {
                                  cancelDialog(size);
                                },
                                child: Container(
                                  height: AppSize.h35.h,
                                  width: size.width * AppSize.w0_3,
                                  padding: const EdgeInsets.all(AppPadding.p5),
                                  decoration: BoxDecoration(
                                    color: AppColors.red,
                                    borderRadius:
                                        BorderRadius.circular(AppRadius.r35.r),
                                  ),
                                  child: Center(
                                    child: Text(
                                      getTranslated(context, "cancel"),
                                      style: GoogleFonts.elMessiri(
                                          color: theme == "light"
                                              ? AppColors.white
                                              : AppColors.black,
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppFontsSizeManager.s25.sp
                                              : AppFontsSizeManager.s16.sp,
                                          fontWeight: FontWeight.w300),
                                    ),
                                  ),
                                ),
                              )
                        : SizedBox(),
                  ],
                ),
              ))),

          Divider(
            color: AppColors.greyShade300,
          ),

          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h50.h
                : AppSize.h24.h,
          ),
          // change from here this is body of screen
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppPadding.p0_3
                      : AppPadding.p30.w,
                  // vertical: AppPadding.p10
                  ),
              children: [
                //d.c
                orderDetail(size),
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h54_6.h
                      : convertPtToPx(AppSize.h24.h),
                ),
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          // consultDetail(size,getTranslated(context, "consultDetails"),widget.order.consult.name!,widget.order.consult.phone!),
                          // consultDetail(size,getTranslated(context, "clientDetails"),widget.order.user.name!,widget.order.user.phone!),
                          consultDetail(
                              size,
                              getTranslated(context, "consultDetails"),
                              widget.order.consult.name!,
                              widget.order.consult.image!,
                              widget.order.consult.phone!),
                          consultDetail(
                              size,
                              getTranslated(context, "clientDetails"),
                              widget.order.user.name!,
                              widget.order.user.image!,
                              widget.order.user.phone!),
                        ],
                      )
                    : Row(
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          //d
                          // consultDetail(size,getTranslated(context, "consultDetails"),widget.order.consult.name!,widget.order.consult.phone!),
                          Expanded(
                            child: consultDetail(
                                size,
                                getTranslated(context, "consultDetails"),
                                widget.order.consult.name!,
                                widget.order.consult.image!,
                                widget.order.consult.phone!),
                          ),
                          SizedBox(
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w50.w
                                : AppSize.w21_3.w,
                          ),
                          Expanded(
                            child: consultDetail(
                                size,
                                getTranslated(context, "clientDetails"),
                                widget.order.user.name!,
                                widget.order.user.image!,
                                widget.order.user.phone!),
                          )
                        ],
                      ),

                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h54_6.h
                      : convertPtToPx(AppSize.h24.h),
                ),

                ///--------course data-----
                if (widget.order.course != null) courseDetail(size),

                if (widget.order.course != null)
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h50.h
                        : AppSize.h20.h,
                  ),
                //----------------------------
                packageDetail(size),

                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h54_6.h
                      : convertPtToPx(AppSize.h24.h),
                ),
                proCodeDetail(size),

                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h54_6.h
                      : convertPtToPx(AppSize.h24.h),
                ),
                appointmentsDetail(size),
                SizedBox(
                  height: AppSize.h40.h,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  title(Size size, String title) {
    return Padding(
        padding:
            const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              fontFamily: getTranslated(context, "Ithra"),
              color: AppColors.primaryColor,
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s32.sp
                  : convertPtToPx(AppFontsSizeManager.s16.sp),
              fontWeight: FontWeight.bold,
              letterSpacing: AppConstants.letterSpacing0_3,
            ),
          ),
        ));
  }

  rowData(Size size, String text, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          text,
          style: TextStyle(
            color: AppColors.primaryColor.withOpacity(0.9),
            fontSize: checkIfWeb(context)
                ? AppFontsSizeManager.s28.sp
                : convertPtToPx(AppFontsSizeManager.s16.sp),
            fontWeight: FontWeight.normal,
            fontFamily: getTranslated(context, "Ithralight"),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            color: AppColors.blackColor,
            fontSize: checkIfWeb(context)
                ? AppFontsSizeManager.s28.sp
                : convertPtToPx(AppFontsSizeManager.s16.sp),
            fontWeight: FontWeight.normal,
            fontFamily: getTranslated(context, "Ithralight"),
          ),
        ),
      ],
    );
  }

  orderDetail(Size size) {
    return Container(
      padding: EdgeInsets.only(
        top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppPadding.p30
            : AppPadding.p32_5,
        bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppPadding.p30
            : AppPadding.p22_6,
      ),
      decoration: decoration(size),
      child: Padding(
        padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.h),
        child: Column(
          children: [
            title(size, getTranslated(context, "orderDetails")),
            SizedBox(
              height: checkIfWeb(context)
                  ? AppSize.h43.h
                  : convertPtToPx(AppSize.h16.h),
            ),
            rowData(
                size,
                getTranslated(context, "price"),
                widget.order.price == null
                    ? "0"
                    : double.parse(widget.order.price.toString())
                            .toStringAsFixed(3) +
                        "\$"),
            SizedBox(
              height: checkIfWeb(context)
                  ? AppSize.h25.h
                  : convertPtToPx(AppSize.h8.h),
            ),
            rowData(
              size,
              getTranslated(context, "callprice"),
              double.parse(widget.order.callPrice.toString())
                      .toStringAsFixed(3) +
                  "\$",
            ),
            SizedBox(
              height: checkIfWeb(context)
                  ? AppSize.h25.h
                  : convertPtToPx(AppSize.h8.h),
            ),
            rowData(
              size,
              getTranslated(context, "packageCall"),
              widget.order.packageCallNum.toString(),
            ),
            SizedBox(
              height: checkIfWeb(context)
                  ? AppSize.h25.h
                  : convertPtToPx(AppSize.h8.h),
            ),
            rowData(
              size,
              getTranslated(context, "answeredCall"),
              widget.order.answeredCallNum.toString(),
            ),
            SizedBox(
              height: checkIfWeb(context)
                  ? AppSize.h25.h
                  : convertPtToPx(AppSize.h8.h),
            ),
            rowData(
              size,
              getTranslated(context, "remainingCall"),
              widget.order.remainingCallNum.toString(),
            ),
            SizedBox(
              height: checkIfWeb(context)
                  ? AppSize.h25.h
                  : convertPtToPx(AppSize.h8.h),
            ),
            rowData(
              size,
              getTranslated(context, "status"),
              widget.order.orderStatus,
            ),
          ],
        ),
      ),
    );
  }

  consultDetail(
      Size size, String _title, String name, String image, String phone) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p30
                : AppPadding.p10),
        decoration: decoration(size),
        child: Column(
          children: [
            title(size, _title),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h50.h
                  : AppSize.h20.h,
            ),
            //image err
            Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h95.h
                  : convertPtToPx(AppSize.h50.h),
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w95.w
                  : convertPtToPx(AppSize.w50.w),
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.white, width: AppSize.w1.w),
                shape: BoxShape.circle,
                color: AppColors.grey4,
              ),
              child: image.isEmpty
                  ? Icon(
                      Icons.person_outline_outlined,
                      color: AppColors.primaryColor,
                      size: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w90.w
                          : convertPtToPx(AppSize.w45.w),
                    )
                  : ClipRRect(
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r36.r
                              : AppRadius.r12.r),
                      child: FadeInImage.assetNetwork(
                        placeholder: AssetsManager.iconPersonIconPath,
                        placeholderScale: 0.5,
                        imageErrorBuilder: (context, error, stackTrace) => Icon(
                          Icons.person_outline_outlined,
                          color: AppColors.pink2,
                          size: AppSize.w15.r,
                        ),
                        image: widget.order.consult.image!,
                        fit: BoxFit.cover,
                        fadeInDuration: Duration(
                            milliseconds: AppConstants.milliseconds250),
                        fadeInCurve: Curves.easeInOut,
                        fadeOutDuration: Duration(
                            milliseconds: AppConstants.milliseconds150),
                        fadeOutCurve: Curves.easeInOut,
                      ),
                    ),
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h30.h
                  : AppSize.h10.h,
            ),
            Text(
              name,
              textAlign: TextAlign.start,
              overflow: TextOverflow.ellipsis,
              maxLines: 1,
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                color: AppColors.blackColor,
                fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppFontsSizeManager.s32.sp
                    : convertPtToPx(AppFontsSizeManager.s14.sp),
                fontWeight: FontWeight.bold,
                letterSpacing: AppConstants.letterSpacing0_3,
              ),
            ),

            // SizedBox(
            //   height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ?AppSize.h30.h:10.h,
            // ),
            // Text(
            //   phone,
            //   textAlign: TextAlign.start,
            //   overflow: TextOverflow.ellipsis,
            //   maxLines: 1,
            //   style: TextStyle(
            //     fontFamily: getTranslated(context, "Ithra"),
            //     color: AppColors.greyColor,
            //     fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)? 28.0.sp: convertPtToPx(14.0.sp),
            //     fontWeight: FontWeight.normal,
            //     letterSpacing: AppConstants.letterSpacing0_3,
            //   ),
            // ),
          ],
        ),
      ),
    );
  }

  packageDetail(Size size) {
    return Center(
      child: Container(
        
        padding: EdgeInsets.symmetric(
           horizontal:  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p30
                : AppPadding.p10),
        decoration: decoration(size),
        child: Column(
          children: [
            SizedBox(height: AppSize.h16.h,),
            title(size, getTranslated(context, "package")),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h30.h
                  : AppSize.h8.h,
            ),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: AppPadding.p30.w, ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    children: [
                      Text(
                        getTranslated(context, "call"),
                        style: TextStyle(
                            color: theme == "light"
                                ? AppColors.primaryColor
                                : AppColors.white,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s28.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                            fontWeight: FontWeight.bold,
                            fontFamily: getTranslated(context, "Ithra")),
                      ),
                      SizedBox(
                  height: AppSize.h8.h
                ),
                      Text(
                        (package == null || package!.callNum == null)
                            ? "0"
                            : package!.callNum.toString(),
                        style: TextStyle(
                            color: theme == "light"
                                ? AppColors.blackColor
                                : AppColors.white,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s28.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                            fontWeight: AppFontsWeightManager.bold500,
                            fontFamily: getTranslated(context, "Ithra")),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        getTranslated(context, "discount"),
                        style: TextStyle(
                            color: theme == "light"
                                ? AppColors.primaryColor
                                : AppColors.white,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s28.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                            fontWeight: FontWeight.bold,
                            fontFamily: getTranslated(context, "Ithra")),
                      ),
                       SizedBox(
                  height: AppSize.h8.h
                ),
                      Text(
                        (package == null || package!.discount == null)
                            ? "0%"
                            : package!.discount.toString() + "%",
                        style: TextStyle(
                            color: theme == "light"
                                ? AppColors.blackColor
                                : AppColors.white,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s28.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                            fontWeight: AppFontsWeightManager.bold500,
                            fontFamily: getTranslated(context, "Ithra")),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Text(
                        getTranslated(context, "price"),
                        style: TextStyle(
                            color: theme == "light"
                                ? AppColors.primaryColor
                                : AppColors.white,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s28.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                            fontWeight: FontWeight.bold,
                            fontFamily: getTranslated(context, "Ithra")),
                      ),
                      SizedBox(
                  height: AppSize.h8.h
                ),
                      Text(
                        (package == null || package!.price == null)
                            ? "0"
                            : package!.price.toString() + "\$",
                        style: TextStyle(
                            color: theme == "light"
                                ? AppColors.blackColor
                                : AppColors.white,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s28.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                            fontWeight: AppFontsWeightManager.bold500,
                            fontFamily: getTranslated(context, "Ithra")),
                      ),
                    ],
                  )
                ],
              ),
            ),
        SizedBox(height: AppSize.h16.h,),
          ],
        ),
      ),
    );
  }

  courseDetail(Size size) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p30
                : AppPadding.p10),
        decoration: decoration(size),
        child: Column(
          children: [
            title(size, getTranslated(context, "courseDetails")),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h30.h
                  : AppSize.h10.h,
            ),
            Column(
              children: [
                Container(
                  height: AppSize.h50.h,
                  width: AppSize.w50.w,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.white, width: AppSize.w1.w),
                    shape: BoxShape.circle,
                    color: theme == "light" ? AppColors.pink : AppColors.white,
                  ),
                  child: widget.order.course!.image.isEmpty
                      ? Icon(
                          Icons.person,
                          color: AppColors.white,
                          size: AppSize.w40,
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r100.r),
                          child: FadeInImage.assetNetwork(
                            placeholder: AssetsManager.iconPersonIconPath,
                            placeholderScale: 0.5,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Icon(
                              Icons.person,
                              color: AppColors.black,
                              size: AppSize.w50,
                            ),
                            image: widget.order.course!.image,
                            fit: BoxFit.cover,
                            fadeInDuration: Duration(
                                milliseconds: AppConstants.milliseconds250),
                            fadeInCurve: Curves.easeInOut,
                            fadeOutDuration: Duration(
                                milliseconds: AppConstants.milliseconds150),
                            fadeOutCurve: Curves.easeInOut,
                          ),
                        ),
                ),
                Text(
                  widget.order.course!.name,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.greydark,
                    fontSize: AppFontsSizeManager.s15.sp,
                    fontWeight: AppFontsWeightManager.semiBold,
                    letterSpacing: AppConstants.letterSpacing0_3,
                  ),
                ),
                SizedBox(
                  height: AppSize.h10.h,
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  proCodeDetail(Size size) {
    return Center(
      child: Container(
        height: AppSize.h74.h,
        padding: EdgeInsets.all(
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppPadding.p30
                : AppPadding.p12),
        decoration: decoration(size),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            if (widget.order.promoCodeId == null)
              Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    SvgPicture.asset(
                      '${AppConstants.iconsPath}discount.svg',
                      width: checkIfWeb(context)
                          ? AppSize.w48.w
                          : convertPtToPx(AppSize.w24.w),
                    ),
                    SizedBox(
                      width: AppSize.h12.h,
                    ),
                    Text(
                      "${getTranslated(context, "proCodes")}:",
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: theme == "light"
                            ? AppColors.primaryColor
                            : AppColors.white,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : convertPtToPx(AppFontsSizeManager.s16.sp),
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(
                      width: AppSize.h32.h,
                    ),
                    Text(
                      getTranslated(context, "noDiscountCode"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s15.sp,
                        fontWeight: FontWeight.normal,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ]),
            widget.order.promoCodeId != null
                ? loadPromo
                    ? Center(child: CircularProgressIndicator())
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            '${AppConstants.iconsPath}discount.svg',
                            width: checkIfWeb(context)
                                ? AppSize.w48.w
                                : convertPtToPx(AppSize.w24.w),
                          ),
                          Text(
                            getTranslated(context, "proCodes"),
                            style: TextStyle(
                              color: theme == "light"
                                  ? AppColors.primaryColor
                                  : AppColors.white,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : convertPtToPx(AppFontsSizeManager.s16.sp),
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                          Text(
                            promo!.code.toString(),
                            style: TextStyle(
                              color: theme == "light"
                                  ? AppColors.blackColor
                                  : AppColors.white,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : convertPtToPx(AppFontsSizeManager.s16.sp),
                              fontWeight: AppFontsWeightManager.bold500,
                            ),
                          ),
                        ],
                      )
                : SizedBox()
          ],
        ),
      ),
    );
  }

  appointmentsDetail(Size size) {
    return Center(
      child: Container(
        padding: EdgeInsets.all(
            (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 30 : 10),
        decoration: decoration(size),
        child: Column(
          children: [
            title(size, getTranslated(context, "appointments")),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h30.h
                  : AppSize.h10.h,
            ),
            if (loadAppointments == false && appointmentList.length == 0)
              Center(
                child: Text(
                  getTranslated(context, "noDate"),
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black,
                    fontSize: AppFontsSizeManager.s15.sp,
                    fontWeight: FontWeight.normal,
                    letterSpacing: AppConstants.letterSpacing0_3,
                  ),
                ),
              )
            else
              ListView.separated(
                itemCount: appointmentList.length,
                shrinkWrap: true,
                physics: NeverScrollableScrollPhysics(),
                padding: const EdgeInsets.all(0),
                itemBuilder: (context, index) {
                  return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          SvgPicture.asset(
                            AssetsManager.calendarClockIconPath,
                            color: AppColors.primaryColor,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w28.w
                                : convertPtToPx(AppSize.w18.h),
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h28.h
                                : convertPtToPx(AppSize.w18.w),
                          ),
                          SizedBox(
                            width: AppSize.w10.w,
                          ),
                          Text(
                            widget.order.consultType == "vocal"
                                ? '${dateFormat.format(appointmentList[index].appointmentTimestamp.toDate())}'
                                : appointmentList[index].date.year.toString() +
                                    "/" +
                                    appointmentList[index]
                                        .date
                                        .month
                                        .toString() +
                                    "/" +
                                    appointmentList[index].date.day.toString(),
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.blackColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : convertPtToPx(AppFontsSizeManager.s14.sp),
                                fontWeight: FontWeight.normal),
                          ),
                          SizedBox(
                            width: AppSize.w20.w,
                          ),
                          Icon(
                            Icons.access_time,
                            color: AppColors.primaryColor,
                            size: checkIfWeb(context)
                                ? AppSize.w28.w
                                : convertPtToPx(AppSize.w20.w),
                          ),
                          SizedBox(
                            width: AppSize.w8.w,
                          ),
                          Text(
                            appointmentList[index].time.hour.toString() +
                                ":" +
                                appointmentList[index].time.minute.toString() +
                                "${appointmentList[index].time.hour > 12 ? "PM" : "AM"}",
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: AppColors.blackColor,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : convertPtToPx(AppFontsSizeManager.s14.sp),
                                fontWeight: FontWeight.normal),
                          ),
                        ],
                      ),
                      Container(
                        padding: EdgeInsets.all(AppPadding.p2),
                        decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius: BorderRadius.circular((kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r3.r
                                : AppRadius.r4.r),
                            border: Border.all(color: AppColors.pink)),
                        child: Text(
                          appointmentList[index].appointmentStatus,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.primaryColor,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s28.sp
                                : convertPtToPx(AppFontsSizeManager.s12.sp),
                            //fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),

                      // appointmentList[index]
                      //     .appointmentStatus ==
                      //     "closed"
                      //     ? InkWell(
                      //   splashColor: AppColors.white
                      //       .withOpacity(0.6),
                      //   onTap: () {
                      //     showReview(
                      //         size,
                      //         appointmentList[index]
                      //             .appointmentId);
                      //   },
                      //   child: Icon(
                      //     //c
                      //     Icons.star,
                      //     color: AppColors.yellow,
                      //     size: 19,
                      //
                      //   ),
                      // )
                      //     : SizedBox(
                      //   width: AppSize.w10.w,
                      // ),
                    ],
                  );
                },
                separatorBuilder: (BuildContext context, int index) {
                  return Padding(
                    padding: EdgeInsets.symmetric(vertical: AppPadding.p8.h),
                    child: Divider(
                      color: AppColors.greyShade300,
                    ),
                  );
                },
              )
          ],
        ),
      ),
    );
  }

  cancelDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15.r),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            top: AppPadding.p20,
            bottom: AppPadding.p10),
        content: Container(
          color: AppColors.white,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Text(
                getTranslated(context, "cancel"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s14_5.sp,
                  fontWeight: AppFontsWeightManager.semiBold,
                  letterSpacing: AppConstants.letterSpacing0_3,
                  color: AppColors.black87,
                ),
              ),
              SizedBox(
                height: AppSize.h15.h,
              ),
              Text(
                getTranslated(context, "cancelOrder"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  fontSize: AppFontsSizeManager.s14.sp,
                  fontWeight: AppFontsWeightManager.bold500,
                  letterSpacing: AppConstants.letterSpacing0_3,
                  color: AppColors.black87,
                ),
              ),
              SizedBox(
                height: AppSize.h5.h,
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Container(
                    width: AppSize.w50.w,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: Text(
                        getTranslated(context, 'no'),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: AppColors.black87,
                          fontSize: AppFontsSizeManager.s13_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ),
                  ),
                  Container(
                    width: AppSize.w50.w,
                    child: MaterialButton(
                      padding: const EdgeInsets.all(0.0),
                      onPressed: () async {
                        cancelOrder();
                        //
                      },
                      child: Text(
                        getTranslated(context, 'yes'),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: AppColors.red1,
                          fontSize: AppFontsSizeManager.s13_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  cancelOrder() async {
    Navigator.pop(context);
    setState(() {
      cancel = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .where(
          'uid',
          isEqualTo: widget.order.user.uid,
        )
        .limit(1)
        .get();
    if (querySnapshot.docs.length != 0 &&
        widget.order.orderStatus != "cancel") {
      var userSearch = GroceryUser.fromMap(querySnapshot.docs[0].data() as Map);
      var price = 0.0;
      if (widget.order.consultType == "vocal" ||
          widget.order.consultType == "glorified") {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .where(
              'orderId',
              isEqualTo: widget.order.orderId,
            )
            .where(
              'appointmentStatus',
              isEqualTo: "closed",
            )
            .get()
            .then((value) async {
          if (value.docs.length > 0) {
            if (mounted)
              setState(() {
                price = (widget.order.packageCallNum - value.docs.length) *
                    widget.order.callPrice;
              });
          } else {
            if (mounted)
              setState(() {
                price = (widget.order.packageCallNum) * widget.order.callPrice;
              });
          }
        }).catchError((err) {});
      } else {
        await FirebaseFirestore.instance
            .collection(Paths.forEverAppointmentsPath)
            .where(
              'orderId',
              isEqualTo: widget.order.orderId,
            )
            .get()
            .then((value) async {
          if (value.docs.length > 0) {
            setState(() {
              price = (widget.order.packageCallNum - value.docs.length) *
                  widget.order.callPrice;
            });
          } else {
            setState(() {
              price = (widget.order.packageCallNum) * widget.order.callPrice;
            });
          }
        }).catchError((err) {});
      }

      dynamic balance = double.parse(price.toString());
      if (userSearch.balance != null) {
        balance = userSearch.balance + balance;
        userSearch.balance = balance;
      }
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(userSearch.uid)
          .set({
        'balance': balance,
      }, SetOptions(merge: true));
      //update payment history
      await FirebaseFirestore.instance
          .collection(Paths.userPaymentHistory)
          .doc(Uuid().v4())
          .set({
        'userUid': userSearch.uid,
        'payType': "refund",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue': Timestamp.now().millisecondsSinceEpoch,
        'amount': price.toString(),
        'otherData': {
          'uid': "fuHfYYjTmRf7rjkyIhxrqp1pPJ32",
          'name': "jeras Application",
          'image': "",
          'phone': "..",
        },
      });
      //cancel order
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .doc(widget.order.orderId)
          .set({
        'orderStatus': "cancel",
      }, SetOptions(merge: true));
      //cancel allAppontment
      var querySnapshot2 = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where('orderId', isEqualTo: widget.order.orderId)
          .where('appointmentStatus', whereIn: ['new', 'open']).get();
      for (var doc in querySnapshot2.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.appAppointments)
            .doc(doc.id)
            .set({
          'appointmentStatus': 'cancel',
        }, SetOptions(merge: true));
      }
    }
    //update consult open order number
    if (widget.order.consultType == "jeras" ||
        widget.order.consultType == "perfect") {
      //get consult
      DocumentReference docRef = FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.order.consult.uid);
      final DocumentSnapshot documentSnapshot = await docRef.get();
      var consult = GroceryUser.fromMap(documentSnapshot.data() as Map);

      //get appointment time to remove time
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where('orderId', isEqualTo: widget.order.orderId)
          .get();
      var allAppointment = List<AppAppointments>.from(
        querySnapshot.docs.map(
          (snapshot) => AppAppointments.fromMap(snapshot.data() as Map),
        ),
      );
      if (allAppointment.length > 0)
        consult.consultOpenAppointmentDates!.removeWhere((element) =>
            element ==
            (allAppointment[0].time.hour.toString() +
                ":" +
                allAppointment[0].time.minute.toString()));
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.order.consult.uid)
          .set({
        'openOrders': FieldValue.increment(-1),
        'consultOpenAppointmentDates': consult.consultOpenAppointmentDates,
      }, SetOptions(merge: true));
    } else
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.order.consult.uid)
          .set({
        'openOrders': FieldValue.increment(-1),
      }, SetOptions(merge: true));

    setState(() {
      cancel = false;
      widget.order.orderStatus = "cancel";
    });
  }

  void showNoNotifSnack(String text, bool status) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
  }

  Future<void> getOrderAppointment() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .where('orderId', isEqualTo: widget.order.orderId)
          .get();
      if (querySnapshot.docs.length > 0) {
        setState(() {
          appointmentList = List<AppAppointments>.from(
            querySnapshot.docs.map(
              (snapshot) => AppAppointments.fromMap(snapshot.data() as Map),
            ),
          );
          loadAppointments = false;
        });
      } else
        setState(() {
          appointmentList = [];
          loadAppointments = false;
        });
    } catch (e) {}
  }

  Future<void> getOrderForEverAppointment() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.forEverAppointmentsPath)
          .where('orderId', isEqualTo: widget.order.orderId)
          .get();
      if (querySnapshot.docs.length > 0) {
        setState(() {
          appointmentList = List<ForEverAppointments>.from(
            querySnapshot.docs.map(
              (snapshot) => ForEverAppointments.fromMap(snapshot.data() as Map),
            ),
          );
          loadAppointments = false;
        });
      } else
        setState(() {
          appointmentList = [];
          loadAppointments = false;
        });
    } catch (e) {}
  }

  decoration(Size size) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: BorderRadius.circular(
          (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 35.r : 16.r),
      border: Border.all(color: Color.fromRGBO(211, 211, 211, 1), width: 1),
      // boxShadow: [
      //   BoxShadow(
      //       color: Color.fromRGBO(158, 158, 158, 0.2),
      //       offset: Offset(
      //           0, (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 2 : 7),
      //       blurRadius:
      //           (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 34 : 13,
      //       spreadRadius: 0)
      // ],
    );
  }

  showReview(Size size, String appointmentId) async {
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection(Paths.consultReviewsPath)
        .where('appointmentId', isEqualTo: appointmentId)
        .get();
    if (querySnapshot.docs.length > 0) {
      setState(() {
        review = List<ConsultReview>.from(
          querySnapshot.docs.map(
            (snapshot) => ConsultReview.fromMap(snapshot.data() as Map),
          ),
        )[0];
        loadReview = false;
      });
    } else
      setState(() {
        // review = null;
        loadReview = false;
      });

    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15.r),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            top: AppPadding.p20,
            bottom: AppPadding.p10),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              getTranslated(context, "Reviews"),
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s15.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: AppColors.black87,
              ),
            ),
            (loadReview == true)
                ? Center(child: CircularProgressIndicator())
                : (loadReview == false && review != null)
                    ? Container(
                        //height: 90,width: size.width,
                        padding: const EdgeInsets.only(
                            left: AppPadding.p10,
                            right: AppPadding.p10,
                            top: AppPadding.p10),
                        color: theme == "light"
                            ? AppColors.white
                            : AppColors.black,
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Container(
                              height: AppSize.h50.h,
                              width: AppSize.w50.w,
                              decoration: BoxDecoration(
                                border: Border.all(
                                    color: AppColors.black,
                                    width: AppSize.w2.w),
                                shape: BoxShape.circle,
                                color: theme == "light"
                                    ? AppColors.white
                                    : AppColors.black,
                              ),
                              child: review!.image!.isEmpty
                                  ? Icon(
                                      Icons.person,
                                      color: AppColors.black,
                                      size: AppSize.w45,
                                    )
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.r100.r),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            AssetsManager.iconPersonIconPath,
                                        placeholderScale: 0.5,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.person,
                                          color: AppColors.black,
                                          size: AppSize.w45,
                                        ),
                                        image: review!.image!,
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
                            Padding(
                              padding: const EdgeInsets.only(
                                  left: AppPadding.p2, right: AppPadding.p2),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.start,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    review!.name,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13.sp,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                  ),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      Icon(
                                        Icons.star,
                                        size: AppSize.w13,
                                        color: AppColors.orange,
                                      ),
                                      Text(
                                        review!.rating.toStringAsFixed(1),
                                        textAlign: TextAlign.start,
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: Theme.of(context).primaryColor,
                                          fontSize: AppFontsSizeManager.s15.sp,
                                          fontWeight:
                                              AppFontsWeightManager.semiBold,
                                        ),
                                      ),
                                    ],
                                  ),
                                  Text(
                                    review!.review!,
                                    maxLines: 3,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: Theme.of(context).primaryColor,
                                      fontSize: AppFontsSizeManager.s13.sp,
                                      fontWeight: FontWeight.normal,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ))
                    : Center(
                        child: Text(
                          getTranslated(context, "noReviews"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black87,
                            fontSize: AppFontsSizeManager.s14.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
            SizedBox(
              height: AppSize.h15.h,
            ),
            Center(
              child: Container(
                width: size.width * AppSize.w0_5.w,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r25.r),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.black87,
                      fontSize: AppFontsSizeManager.s13_5.sp,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ),
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
