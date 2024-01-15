import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/paths.dart';
import 'package:jeras/controller/blocs/account_bloc/account_bloc.dart';
import 'package:jeras/models/consultPackage.dart';
import 'package:jeras/models/order.dart';
import 'package:jeras/models/promoCode.dart';
import 'package:jeras/widget/component/TextButton.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../api/dynamicLink.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../screens/ConsultantDetailsScreen.dart';

class ConsultantListItem extends StatefulWidget {
  final GroceryUser? loggedUser;
  final GroceryUser consult;
  String lang;
  final String theme;
  double? heightCard;

  ConsultantListItem(
      {required this.consult,
      this.heightCard,
      this.loggedUser,
      required this.theme,
      required this.lang});

  @override
  _ConsultantListItemState createState() => _ConsultantListItemState();
}

enum DataState { loading, error, data }

class _ConsultantListItemState extends State<ConsultantListItem>
    with SingleTickerProviderStateMixin {
  share() async {
    try {
      setState(() {
        sharing = true;
      });

      String userUrl =
          "https://jerasnew.web.app/conslultant?consultant_id=${widget.consult.uid}";

      String url = await dynamicLinks.shareConsultantByDynamicLink(
          userUrl, context, widget.consult);
      Share.share(url); //${dynamicLink.shortUrl.toString()}
      setState(() {
        sharing = false;
      });
    } catch (e) {}
  }

  bool sharing = false;

  GroceryUser? user;
  int currentNumber = 0;
  late AccountBloc accountBloc;
  List<consultPackage> packages = [];
  bool fristinit = true;
  late dynamic callsValue;
  DataState currentState = DataState.loading;

  late int reviewLength = 0, localFrom, localTo;
  bool first = true,
      showPayView = false,
      load = false,
      valid = false,
      checkPromo = false,
      loadReviews = true,
      loadPackage = true,
      fromBalance = false;

  bool chating = false, selected = false;

  late String initialUrl = '', userImage, orderId, userName = "dreamUser";
  consultPackage? package;
  Orders? order;
  bool loadScreen = true;
  PromoCode? promo;
  String? promoCodeId;
  dynamic price, discount = 0;
  late Size size;
  GroceryUser? consultant;
  String? theme;
  int callNum = 0;

  bool loadVIdeoList = true;
  List<Video> list = [];

  String lang = "";
  bool showBookingSection = false;

  //late toolTipBloc tipBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;
/*    String openOrderNum = "";
    if (widget.consult.openOrders > 0)
      openOrderNum = widget.consult.openOrders.toString() + "/5";
    else
      openOrderNum = "0/5";*/

    if (widget.consult.workDays!.contains(dayNow)) {
      int localFrom = DateTime.parse(widget.consult.fromUtc!).toLocal().hour;
      int localTo = DateTime.parse(widget.consult.toUtc!).toLocal().hour;
      if (localTo == 0) localTo = 24;
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }

    return GestureDetector(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              settings: RouteSettings(
                  name: 'conslultant?consultant_id=${widget.consult.uid}',
                  arguments: {"consultant_id": widget.consult.uid}),
              builder: (context) => ConsultantDetailsScreen(
                consoltantId: '${widget.consult.uid}',
              ),
            ),
          );
        },
        child: Container(
          width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.w295.w
              : AppSize.w216.w,
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h220.h
              : widget.heightCard ?? AppSize.h253.h,
          decoration: BoxDecoration(
            color: AppColors.grey4,
            borderRadius: BorderRadius.circular(
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppRadius.r50.r
                    : AppRadius.r21_3.r),
          ),
          child: Padding(
            padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? EdgeInsets.only(
                    top: AppSize.h36_5.h,
                    bottom: AppSize.h30.h,
                    left: AppSize.w10.w,
                    right: AppSize.w10.w)
                : EdgeInsets.only(
                    top: AppSize.h16.h,
                    bottom: AppSize.h16.h,
                    left: AppSize.w10_6.w,
                    right: AppSize.w16.w),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                //dollar sign
                Row(
                  // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Expanded(
                      child: Text(
                        widget.consult.price! + "\$",
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        maxLines: 1,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Montserratbold"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s20.sp
                                  : AppFontsSizeManager.s18_6.sp,
                          fontWeight: FontWeight.bold,
                          color: AppColors.shadoColor,
                        ),
                      ),
                    ),
                    SizedBox(width: AppSize.w13_3.w),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        //image
                        widget.consult.photoUrl!.isEmpty
                            ? CircleAvatar(
                                backgroundImage: AssetImage(
                                  AssetsManager.whiteJerasLogoIconPath,
                                ),
                              )
                            : ClipRRect(
                                borderRadius: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? BorderRadius.circular(AppRadius.r500.r)
                                    : BorderRadius.circular(AppRadius.r500.r),
                                child: FadeInImage.assetNetwork(
                                  width: AppSize.w73_3.r,
                                  height: AppSize.h73_3.r,
                                  placeholder: AssetsManager.lodeGif,
                                  placeholderScale: 0.5,
                                  imageErrorBuilder: (context, error,
                                          stackTrace) =>
                                      Image.asset(
                                          AssetsManager.whiteJerasLogoIconPath,
                                          width: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.w73_3.r
                                              : AppSize.w73_3.r,
                                          height: (kIsWeb ||
                                                  size.height >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.h73_3.r
                                              : AppSize.h73_3.r,
                                          fit: BoxFit.fill),
                                  image: widget.consult.photoUrl!,
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
                        //avail icon
                        Positioned(
                          top: 7.h,
                          left: 2.w,
                          child: Container(
                            width: AppSize.w10_6.r,
                            height: AppSize.h10_6.r,
                            decoration: BoxDecoration(
                              color:
                                  avaliable ? Color(0xffa5d752) : AppColors.red,
                              shape: BoxShape.circle,
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(width: AppSize.w21_3.w),
                    Expanded(
                      child: sharing
                          ? Container(
                              height: AppSize.h34_6.r,
                              width: AppSize.w34_6.r,
                              child: CircularProgressIndicator())
                          : InkWell(
                              onTap: () async {
                                share();
                              },
                              child: Column(
                                children: [
                                  //new
                                  Container(
                                    height: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.h18.h
                                        : AppSize.h34_6.r,
                                    width: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.w18.w
                                        : AppSize.w34_6.r,
                                    decoration: BoxDecoration(
                                      color: Color.fromRGBO(255, 255, 255, 1),
                                      borderRadius: BorderRadius.circular(
                                          (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppRadius.r25.r
                                              : AppRadius.r50.r),

                                      // boxShadow: [
                                      //   BoxShadow(
                                      //     color: Color.fromRGBO(123, 108, 150, 0.18),
                                      //     blurRadius: 8.0,
                                      //     spreadRadius: 0.0,
                                      //     offset: Offset(0.0, 1.0),
                                      //   )
                                      // ],
                                    ),
                                    child: Center(
                                      child: SvgPicture.asset(
                                        AssetsManager.ShareIconPath,
                                        width: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.w20.r
                                            : AppSize.w21_3.w,
                                        height: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h20.r
                                            : AppSize.h21_3.h,
                                      ),
                                    ),
                                  ),
                                  //new
                                  (widget.consult.consultType == "perfect" &&
                                          widget.consult.isGlorified!)
                                      ? Container(
                                          height: AppSize.h21.h,
                                          margin: EdgeInsets.only(
                                              top: AppMargin.m5),
                                          width: AppSize.w21.w,
                                          child:
                                              Image.asset(AssetsManager.mojeez))
                                      : SizedBox(),
                                ],
                              ),
                            ),
                    ),
                  ],
                ),
                SizedBox(height: AppSize.h10_6.h),
                //name
                Text(
                  getTranslated(context, "lang") == "ar"
                      ? widget.consult.name!
                      : widget.consult.nameEn!,
                  maxLines: 1,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    color: const Color(0xff202020),
                    fontWeight: AppFontsWeightManager.semiBold,
                    fontFamily: getTranslated(context, "Ithra"),
                    fontStyle: FontStyle.normal,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s19.sp
                        : AppFontsSizeManager.s16.sp,
                  ),
                ),
                SizedBox(height: AppSize.h2_6.h),
                //call number data
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //new
                          Text(
                            widget.consult.rating == 0
                                ? 0.toString()
                                : widget.consult.rating.toString(),
                            style: TextStyle(
                              color: AppColors.black2,
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily:
                                  getTranslated(context, "Montserratmedium"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s11.sp
                                  : AppFontsSizeManager.s18_6.sp,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(
                            width: AppSize.w2_6.w,
                          ),
                          SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 1,
                            rating: 1,
                            size: AppSize.w21_3.r,
                            color: AppColors.yellow,
                            borderColor: AppColors.yellow,
                            spacing: 1.0,
                          ),
                          SizedBox(width: AppSize.w36.w),
                          Text(
                            widget.consult.ordersNumbers == null
                                ? '0'
                                : widget.consult.ordersNumbers! < 100
                                    ? widget.consult.ordersNumbers.toString()
                                    : widget.consult.ordersNumbers! < 1000
                                        ? "+100"
                                        : "+1000",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              color: AppColors.black2,
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily:
                                  getTranslated(context, "Montserratmedium"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s11.sp
                                  : AppFontsSizeManager.s18_6.sp,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(width: AppSize.w2_6.w),
                          SvgPicture.asset(
                            AssetsManager.phPhoneCall,
                            width: AppSize.w21_3.w,
                            height: AppSize.h21_3.h,
                          ),
                        ],
                      )
                    : Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          //new
                          SvgPicture.asset(
                            AssetsManager.phPhoneCall,
                            width: AppSize.w21_3.w,
                            height: AppSize.h21_3.h,
                          ),
                          SizedBox(width: 1.w),
                          Text(
                            widget.consult.ordersNumbers == null
                                ? '0'
                                : widget.consult.ordersNumbers! < 100
                                    ? widget.consult.ordersNumbers.toString()
                                    : widget.consult.ordersNumbers! < 1000
                                        ? "+100"
                                        : "+1000",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              color: AppColors.black2,
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily:
                                  getTranslated(context, "Montserratmedium"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s20.sp
                                  : AppFontsSizeManager.s18_6.sp,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                          SizedBox(width: AppSize.w36.w),
                          SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 1,
                            rating: 1,
                            size: AppSize.w21_3.r,
                            color: AppColors.yellow,
                            borderColor: AppColors.yellow,
                            spacing: 1.0,
                          ),

                          Text(
                            widget.consult.rating == 0
                                ? 0.toString()
                                : widget.consult.rating.toString(),
                            style: TextStyle(
                              color: AppColors.black2,
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily:
                                  getTranslated(context, "Montserratmedium"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s20.sp
                                  : AppFontsSizeManager.s18_6.sp,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ],
                      ),
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? SvgPicture.asset(
                        AssetsManager.locationIconPath,
                        width: AppSize.w16.w,
                        height: AppSize.h16.h,
                      )
                    : Padding(
                        padding: EdgeInsets.symmetric(vertical: AppSize.h1_3.h),
                        child: SvgPicture.asset(
                          AssetsManager.locationIconPath,
                          width: AppSize.w16.w,
                          height: AppSize.h16.h,
                        ),
                      ),
                Text(
                  getTranslated(context, "lang") == "ar"
                      ? widget.consult.location!
                      : widget.consult.locationEn!,
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? getTranslated(context, "Montserrat")
                            : getTranslated(context, "Ithralight"),
                    color: AppColors.black1,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s13.sp
                        : AppFontsSizeManager.s16.sp,
                    fontWeight: AppFontsWeightManager.bold400,
                  ),
                ),
                SizedBox(height: AppSize.h8.h),
                TextButton1(
                  onPress: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        settings: RouteSettings(
                            name:
                                'conslultant?consultant_id=${widget.consult.uid}',
                            arguments: {"consultant_id": widget.consult.uid}),
                        builder: (context) => ConsultantDetailsScreen(
                          consoltantId: '${widget.consult.uid}',
                        ),
                      ),
                    );
                  },
                  Title: getTranslated(context, "ShowProfileInfo"),
                  Width: (kIsWeb || size.width >= 500)
                      ? AppSize.w233.w
                      : AppSize.w148.w,
                  Height: (kIsWeb || size.width >= 500)
                      ? AppSize.h45.h
                      : AppSize.h36.h,
                  ButtonRadius: (kIsWeb || size.width >= 500)
                      ? AppRadius.r8.r
                      : AppRadius.r5_3.r,
                  TextSize: (kIsWeb || size.width >= 500)
                      ? AppFontsSizeManager.s20.sp
                      : AppFontsSizeManager.s13_3.sp,
                  TextFont: getTranslated(context, 'Ithra'),
                  TextColor: AppColors.primaryColor,
                  ButtonBackground: AppColors.buttonBack,
                  // Padding: AppPadding.p4.h,
                ),
                // )
              ],
            ),
          ),
        ));
    // ConditionalBuilder(
    //   condition: load,
    //   builder: (context) => Center(
    //     child: CircularProgressIndicator(),
    //   ),
    //   fallback: (context) => currentState == DataState.error
    //       ? Center(child: Text("Error occurred"))
    //       : currentNumber == null
    //           ? Text("No data available")
    //           :
    // );
  }
}
