import 'dart:convert';
import 'dart:io';
import 'dart:math';
import 'package:jeras/api/dynamicLink.dart';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_analytics/firebase_analytics.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:http/http.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:jeras/Utils/opentab.dart'
    if (dart.library.html) 'package:jeras/Utils/opentabWeb.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_shadow.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/screens/userAccountScreen.dart';
import 'package:jeras/widget/component/TextButton.dart';
import 'package:jeras/widget/firebase_video_player_widget.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/stripe_payment_bottom_sheet.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/consultPackage.dart';
import '../../models/order.dart';
import '../../models/promoCode.dart';
import '../../models/user.dart';
import '../../widget/addAppointmentDialog.dart';
import '../Utils/helper.dart';
import '../config/app_constat.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../enums/payment_types.dart';
import '../methods/convert_pt_to_px.dart';
import '../models/chat.dart';
import '../pages/AppointmentsPage.dart';
import '../services/app_flyer_service.dart';
import '../widget/component/IconButton.dart';
import '../widget/consultDetailHeaderWidget.dart';
import '../widget/consultTimeWidget.dart';
import '../widget/default_text_widget.dart';
import '../widget/dialogs/custom_text_dialog.dart';
import '../widget/interestWidget.dart';
import '../widget/jerasDialogWidget.dart';
import '../widget/playListWidget.dart';
import '../widget/reportConsultWidget.dart';
import '../widget/responsive_layout.dart';
import '../widget/reviewWidget.dart';
import '../widget/userOrdersDialog.dart';
import '../widget/videoWidget.dart'
    if (dart.library.html) '../widget/youtubeplayer.dart';
import 'all_consultant_videos_screen.dart';
import 'chatDetailScreen.dart';

class ConsultantDetailsScreen extends StatefulWidget {
  final String consoltantId;
  final String? tabid;
  final String? paydata;

  const ConsultantDetailsScreen(
      {Key? key, required this.consoltantId, this.tabid, this.paydata})
      : super(key: key);

  @override
  _ConsultantDetailsScreenState createState() =>
      _ConsultantDetailsScreenState();
}

class _ConsultantDetailsScreenState extends State<ConsultantDetailsScreen>
    with SingleTickerProviderStateMixin {
  final _scaffoldKey = GlobalKey<ScaffoldState>();

  final TextEditingController controller = TextEditingController();
  final TextEditingController searchController = new TextEditingController();
  GroceryUser? user;
  int currentNumber = 0;
  late AccountBloc accountBloc;
  List<consultPackage> packages = [];
  bool fristinit = true;
  late dynamic callsValue;

  late int reviewLength = 0, localFrom, localTo;
  bool first = true,
      showPayView = false,
      load = false,
      valid = false,
      checkPromo = false,
      loadReviews = true,
      loadPackage = true,
      fromBalance = false;
  bool chating = false, sharing = false, selected = false;
  int _stackIndex = 1;
  late String initialUrl = '', userImage, orderId2, userName = "dreamUser";
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
  ScrollController _scrollController = new ScrollController();
  String lang = "";
  bool showBookingSection = false;
  int _selectedDateCard = -1;
  String? _time;
  List<dynamic> _todayAppointmentList = [];
  DateTime? _selectedDate;
  // WebViewController webViewController = WebViewController();

  @override
  void initState() {
    super.initState();

    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetConsultInfoEvent(widget.consoltantId));

    accountBloc.stream.listen((state) {
      if (state is getConsultantInfoCompletedState) {
        user = state.user;
        //
        consultant = state.consultant;
        localFrom = DateTime.parse(consultant!.fromUtc!).toLocal().hour;
        localTo = DateTime.parse(consultant!.toUtc!).toLocal().hour;
        if (localTo == 0) localTo = 24;
        loadScreen = false;
      }
      getNumber();
    });
    getConsultPackages();
    cleanConsultDays();
    if (widget.tabid != null && widget.tabid!.isNotEmpty) {
      //&&widget.paydata!=null&&widget.paydata!.isNotEmpty){
      checkwithTab();
    }
  }

  void scrollToFooter() {
    _scrollController.animateTo(
      _scrollController.position.maxScrollExtent,
      duration: Duration(milliseconds: 500),
      curve: Curves.easeInOut,
    );
  }

  void getDataFromDialog({
    required DateTime date,
    required int selectedCard,
    required String time,
    required List<dynamic> todayAppointmentList,
    required PaymentTypes paymentType,
    required double totalPrice,
  }) {
    this.price = totalPrice;
    this.currentNumber = currentNumber;
    this._selectedDateCard = selectedCard;
    this._time = time;
    this._todayAppointmentList = todayAppointmentList;
    this._selectedDate = date;

    switch (paymentType) {
      case PaymentTypes.balance:
        customTextDialog(
          text: getTranslated(context, 'payFromBalanceNote'),
          buttonText: getTranslated(context, 'Ok'),
          context: context,
          okFunction: () async {
            Navigator.pop(context);
            try {
              payFromBalance(totalPrice);
            } catch (e) {
              customTextDialog(
                context: context,
                buttonText: getTranslated(context, 'Ok'),
                text: 'error',
                okFunction: () {
                  Navigator.pop(context);
                },
              );
              print('error from pay');
            }
            // Navigator.pop(context);
          },
        );
        break;

      case PaymentTypes.stripe:
        stripePayment(amount: totalPrice.toString(), context: context);

        break;

      case PaymentTypes.tapCompany:
        pay();
        break;
    }
  }

  void backFromBooking({
    required bool backFromBooking,
  }) {
    if (backFromBooking == true) {
      setState(() {
        showBookingSection = false;
        package = null;
      });
    }
  }

  Future<void> payFromBalance(double price) async {
    try {
      setState(() {
        showBookingSection = false;
      });

      var newBalance = double.parse(user!.balance.toString()) - price;
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user!.uid)
          .set({
        'balance': newBalance,
      }, SetOptions(merge: true));

      fromBalance = true;
      user!.balance = newBalance;

      updateDatabaseAfterAddingOrder(user!.customerId, "userBalance", '.',
          totalPrice: price);
    } catch (e) {
      print(e.toString());
      customTextDialog(
          context: context,
          text: getTranslated(context, 'failed'),
          buttonText: getTranslated(context, 'Ok'),
          okFunction: () {
            Navigator.pop(context);
          });
    }
  }

  addEvent(String eventName, Map eventValues) async {
    if (eventName == "af_content_view") {
      await FirebaseAnalytics.instance.logSelectItem(
        itemListId: consultant!.uid,
        itemListName: consultant!.name,
      );
    } else if (eventName == "af_purchase")
      await FirebaseAnalytics.instance.logPurchase(
          currency: "USD",
          value: double.parse(price.toString()),
          affiliation: consultant!.uid,
          transactionId: orderId2);
  }

  @override
  void dispose() {
    super.dispose();
  }

  Future<void> getNumber() async {
    try {
      if (mounted)
        setState(() {
          load = true;
        });
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where(
            'user.uid',
            isEqualTo: user!.uid,
          )
          .where(
            'consult.uid',
            isEqualTo: consultant!.uid,
          )
          .where('orderStatus',
              isEqualTo: (consultant!.consultType == "perfect" ||
                      consultant!.consultType == "jeras")
                  ? 'completed'
                  : 'open')
          .get()
          .then((value) async {
        if (value.docs.length > 0) {
          var order2 = Orders.fromMap(value.docs[0].data());
          if (mounted)
            setState(() {
              order = order2;
            });
          if (consultant!.consultType == "vocal" ||
              consultant!.consultType == "glorified") {
            await FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .where(
                  'orderId',
                  isEqualTo: order!.orderId,
                )
                .get()
                .then((value) async {
              if (value.docs.length > 0) {
                if (mounted)
                  setState(() {
                    currentNumber = order!.packageCallNum - value.docs.length;
                  });
              } else {
                if (mounted)
                  setState(() {
                    currentNumber = order!.packageCallNum;
                  });
              }
            }).catchError((err) {
              errorLog("getNumber1", err.toString());
              //setState(() {
              load = false;
              //});
            });
          } else {
            await FirebaseFirestore.instance
                .collection(Paths.forEverAppointmentsPath)
                .where(
                  'orderId',
                  isEqualTo: order!.orderId,
                )
                .get()
                .then((value) async {
              if (value.docs.length > 0) {
                if (mounted)
                  setState(() {
                    currentNumber = order!.packageCallNum - value.docs.length;
                  });
              } else {
                if (mounted)
                  setState(() {
                    currentNumber = order!.packageCallNum;
                  });
              }
            }).catchError((err) {
              errorLog("getNumber1", err.toString());
              if (mounted)
                setState(() {
                  load = false;
                });
            });
          }
        } else {
          if (mounted)
            setState(() {
              currentNumber = 0;
              // order=null;
            });
        }
        if (mounted)
          setState(() {
            load = false;
          });
      }).catchError((err) {
        errorLog("getNumbererr", err.toString());
        if (mounted)
          setState(() {
            load = false;
          });
      });
    } catch (e) {
      errorLog("getNumbererrerr", e.toString());
      if (mounted)
        setState(() {
          load = false;
          currentNumber = 0;
          //order=null;
        });
    }
  }

  errorLog(String function, String error) async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': user == null ? " " : user!.phoneNumber,
      'screen': "ConsultantDetailsScreen",
      'function': function,
    });
  }

  getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .where('consultUid', isEqualTo: widget.consoltantId)
          .where('active', isEqualTo: true)
          .orderBy("callNum", descending: false)
          .get();

      var packageList = List<consultPackage>.from(
        querySnapshot.docs.map(
          (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
        ),
      );

      setState(() {
        packages = packageList;
        loadPackage = false;
      });
    } catch (e) {
      setState(() {
        loadPackage = false;
      });
      errorLog("getConsultPackages", e.toString());
    }
  }

  BoxShadow shadow() {
    return BoxShadow(
      color: AppColors.lightGrey,
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: Offset(0.0, 1.0), // shadow direction: bottom right
    );
  }

  _onSelected(int index) {
    setState(() {
      package = packages[index];
      callNum = packages[index].callNum;
      calculateDiscount();
    });
  }

  innearDecoration() {
    return BoxDecoration(
      border: Border.all(
        width: AppSize.w0_5.w,
        color: AppColors.textLightGrey,
      ),
      borderRadius: BorderRadius.circular(AppRadius.r25.r),
    );
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    String x = AssetsManager.selectSupportCenterIconPath;

    return Scaffold(
        key: _scaffoldKey,
        backgroundColor: AppColors.white,
        body: loadScreen
            ? Center(
                child: CircularProgressIndicator(),
              )
            : bodyWidget());
  }

  Widget bodyWidget() {
    return ResponsiveLayout(
      desktop: Stack(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //header
            ConsultDetailHeaderWidget(
              loggedUser: user,
              consultant: consultant!,
            ),

            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(
                child: Padding(
                  padding: EdgeInsets.only(
                      top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h53.h
                          : size.height * AppPadding.p0_04,
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w174.w
                          : size.width * AppPadding.p0_06,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w174.w
                          : size.width * AppPadding.p0_06),
                  child: ResponsiveLayout(
                    desktop: SingleChildScrollView(
                      controller: _scrollController,
                      physics: AlwaysScrollableScrollPhysics(),
                      child: Column(
                        // physics: AlwaysScrollableScrollPhysics(),
                        children: [
                          //change
                          Padding(
                            padding: EdgeInsets.only(
                              top: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 0
                                  : size.height * AppPadding.p0_1,
                              bottom: AppSize.h140.h,
                            ),
                            child: Row(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    chating
                                        ? CircularProgressIndicator()
                                        : chatButton(),
                                    SizedBox(
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h23.h
                                          : AppSize.h25.h,
                                    ),
                                    consultant!.openOrders < 5
                                        ? registerWidget()
                                        : SizedBox(),
                                  ],
                                ),
                                Row(
                                  mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Column(
                                      crossAxisAlignment:
                                          CrossAxisAlignment.start,
                                      mainAxisAlignment:
                                          MainAxisAlignment.start,
                                      children: [
                                        //name
                                        TextDefaultWidget(
                                          title:
                                              getTranslated(context, "lang") ==
                                                      "ar"
                                                  ? consultant!.name!
                                                  : consultant!.nameEn!,
                                          maxLines: 2,
                                          fontFamily: getTranslated(
                                              context, "Montserrat"),
                                          fontWeight:
                                              AppFontsWeightManager.semiBold,
                                          fontSize: AppFontsSizeManager.s33.sp *
                                              1.5.sp,
                                          color: AppColors.black,
                                        ),

                                        //details
                                        Padding(
                                          padding: const EdgeInsets.only(
                                              top: AppPadding.p10),
                                          child: Row(
                                            mainAxisAlignment:
                                                MainAxisAlignment.center,
                                            children: [
                                              TextDefaultWidget(
                                                title: consultant!.price
                                                        .toString() +
                                                    "\$",
                                                fontFamily: getTranslated(
                                                    context, "Montserrat"),
                                                fontWeight:
                                                    AppFontsWeightManager
                                                        .normal,
                                                fontSize:
                                                    AppFontsSizeManager.s22.sp,
                                                color: AppColors.black,
                                              ),
                                              SizedBox(width: AppSize.w22.w),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SvgPicture.asset(
                                                    AssetsManager.phoneCall,
                                                    width: 24.5 * 1.5.r,
                                                    height: 24.6 * 1.5.r,
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  TextDefaultWidget(
                                                    title: consultant!
                                                                .ordersNumbers ==
                                                            null
                                                        ? '0'
                                                        : consultant!
                                                                    .ordersNumbers! <
                                                                100
                                                            ? consultant!
                                                                .ordersNumbers
                                                                .toString()
                                                            : consultant!
                                                                        .ordersNumbers! <
                                                                    1000
                                                                ? "+100"
                                                                : "+1000",
                                                    fontFamily: getTranslated(
                                                        context, "Montserrat"),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 22 * 1.5.sp,
                                                    color: AppColors.black,
                                                  ),
                                                ],
                                              ),
                                              SizedBox(width: AppSize.h25.w),
                                              Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.center,
                                                crossAxisAlignment:
                                                    CrossAxisAlignment.center,
                                                children: [
                                                  SmoothStarRating(
                                                    allowHalfRating: true,
                                                    starCount: 1,
                                                    rating: 1,
                                                    size: 25.0 * 1.5.r,
                                                    color: AppColors.yellow,
                                                    borderColor:
                                                        AppColors.yellow,
                                                    spacing: 1.0,
                                                  ),
                                                  SizedBox(width: 2.w),
                                                  TextDefaultWidget(
                                                    title:
                                                        consultant!.rating == 0
                                                            ? 0.toString()
                                                            : consultant!.rating
                                                                .toString(),
                                                    fontFamily: getTranslated(
                                                        context, "Montserrat"),
                                                    fontWeight: FontWeight.w400,
                                                    fontSize: 23 * 1.5.sp,
                                                    color: AppColors.black,
                                                  ),
                                                ],
                                              ),
                                            ],
                                          ),
                                        ),

                                        SizedBox(height: AppSize.h10.h),
                                        Row(
                                          children: [
                                            Text(
                                              getTranslated(context, "lang") ==
                                                      "ar"
                                                  ? consultant!.location!
                                                  : consultant!.locationEn!,
                                              textAlign: TextAlign.center,
                                              overflow: TextOverflow.ellipsis,
                                              maxLines: 1,
                                              style: TextStyle(
                                                fontFamily: getTranslated(
                                                    context, "Ithra"),
                                                fontSize: 19.0 * 1.5.sp,
                                                color: AppColors.grey,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                            Icon(
                                              Icons.location_on_outlined,
                                              color: Theme.of(context)
                                                  .primaryColor,
                                              size: 21 * 1.5.r,
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                    SizedBox(
                                      width: AppSize.w35.w,
                                    ),
                                    consultImage(140.r),
                                  ],
                                ),
                              ],
                            ),
                          ),

                          //video
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.end,
                            children: [
                              Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Container(
                                      width: AppSize.w631.w,
                                      child: _ReadMoreText(
                                          consultant: consultant!)),
                                  Spacer(),
                                  Padding(
                                    padding: EdgeInsets.symmetric(
                                        horizontal: size.width * .05.w),
                                    child: consultant!.link != null
                                        ? Container(
                                            width: size.width * .3.w,
                                            height: AppSize.h230_6.h,
                                            child: consultant!.link!
                                                    .contains('firebase')
                                                ? FirebaseVideoPlayerWidget(
                                                    consultant!.link,
                                                  )
                                                : VideoWidget(
                                                    link: consultant!.link
                                                        .toString(),
                                                    VideoAppid: consultant!.link
                                                        .toString()
                                                        .substring(
                                                            consultant!.link
                                                                    .toString()
                                                                    .indexOf(
                                                                        "=") +
                                                                1,
                                                            consultant!.link
                                                                .toString()
                                                                .length),
                                                  ))
                                        : SizedBox(),
                                  ),
                                ],
                              ),
                              SizedBox(
                                height: AppSize.h25.h,
                              ),
                              Padding(
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p140.w),
                                child: Text(
                                  getTranslated(context, "videosAboutTxt") +
                                      "${consultant!.name}",
                                  style: TextStyle(
                                    fontSize: AppFontsSizeManager.s24.sp,
                                    color: AppColors.black,
                                    fontFamily: getTranslated(
                                        context, "NotoKufiArabic-SemiBold"),
                                  ),
                                ),
                              )
                            ],
                          ),

                          //
                          ReportConsultWidget(
                            consult: consultant!,
                            loggedUser: user,
                          ),
                          SizedBox(
                            height: AppSize.h120.h,
                          ),

                          //
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Container(
                                width: AppSize.w702.w, // AppSize.w612.w,
                                height: AppSize.h494.h,
                                child: ConsultTimeWidget(
                                  consultant: consultant!,
                                ),
                              ),
                              SizedBox(
                                width: AppSize.w180.w,
                              ),
                              Container(
                                  width: AppSize.w664.w,
                                  height: AppSize.h494.h,
                                  child: ReviewWidget(consultant: consultant!)),
                            ],
                          ),

                          SizedBox(
                            height: AppSize.h120.h,
                          ),
                          packageWidget(size),
                          SizedBox(
                            height: size.height * AppSize.h0_07,
                          ),

                          /// pay button for mobile.
                          ///
                          showBookingSection ? SizedBox() : payButton(size),

                          if (showBookingSection)
                            AddAppointmentDialog(
                              loggedUser: user!,
                              consultant: consultant!,
                              localFrom: localFrom,
                              localTo: localTo,
                              package: package!,
                              getData: getDataFromDialog,
                              backFromBooking: backFromBooking,
                            ),
                        ],
                      ),
                    ),
                    mobile: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      children: [
                        InterestWidget(
                            interestListIds: consultant!.interestListIds!),
                        //name
                        Padding(
                          padding: EdgeInsets.only(
                              left: size.width * AppPadding.p0_20,
                              right: size.width * AppPadding.p0_20,
                              top: 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              consultImage(70),
                              //name
                              TextDefaultWidget(
                                title: getTranslated(context, "lang") == "ar"
                                    ? consultant!.name!
                                    : consultant!.nameEn!,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontWeight: AppFontsWeightManager.semiBold,
                                fontSize: 14 * 1.5.sp,
                                color: AppColors.black,
                              ),
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceEvenly,
                                children: [
                                  //dollar
                                  Container(
                                    padding: EdgeInsets.all(2),
                                    width: 50.w,
                                    decoration: innearDecoration(),
                                    child: Center(
                                      child: TextDefaultWidget(
                                        title:
                                            consultant!.price.toString() + "\$",
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        fontWeight: FontWeight.bold,
                                        fontSize: 12 * 1.5.sp,
                                        color: AppColors.black,
                                      ),
                                    ),
                                  ),
                                  //const SizedBox(width: 10),
                                  //call number
                                  Container(
                                    //padding: EdgeInsets.all(2), p
                                    width: AppSize.w65.w,
                                    decoration: innearDecoration(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        TextDefaultWidget(
                                          title: consultant!.ordersNumbers ==
                                                  null
                                              ? '0'
                                              : consultant!.ordersNumbers! < 100
                                                  ? consultant!.ordersNumbers
                                                      .toString()
                                                  : consultant!.ordersNumbers! <
                                                          1000
                                                      ? "+100"
                                                      : "+1000",
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12 * 1.5.sp,
                                          color: AppColors.black,
                                        ),
                                        SizedBox(width: 2.w),
                                        SvgPicture.asset(
                                          AssetsManager.phoneCall,
                                          width: 13 * 1.5.r,
                                          height: 13 * 1.5.r,
                                        ),
                                      ],
                                    ),
                                  ),
                                  //const SizedBox(width: 10),
                                  //star numbers
                                  Container(
                                    //padding: EdgeInsets.all(2), p

                                    width: AppSize.w50_6.w,
                                    decoration: innearDecoration(),
                                    child: Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SmoothStarRating(
                                          allowHalfRating: true,
                                          starCount: 1,
                                          rating: 1,
                                          size: 13.0 * 1.5.r,
                                          color: AppColors.yellow,
                                          borderColor: AppColors.yellow,
                                          spacing: 1.0,
                                        ),
                                        SizedBox(width: 2.w),
                                        TextDefaultWidget(
                                          title: consultant!.rating == 0
                                              ? 0.toString()
                                              : consultant!.rating.toString(),
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontWeight: FontWeight.bold,
                                          fontSize: 12 * 1.5.sp,
                                          color: AppColors.black,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                              SizedBox(height: 10.h),
                              //location
                              Icon(
                                Icons.location_on_outlined,
                                color: Theme.of(context).primaryColor,
                                size: 12.4 * 1.5.r,
                              ),
                              TextDefaultWidget(
                                title: getTranslated(context, "lang") == "ar"
                                    ? consultant!.location!
                                    : consultant!.locationEn!,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontWeight: FontWeight.normal,
                                fontSize: 12 * 1.5.sp,
                                color: AppColors.black,
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        //contact button
                        Center(
                            child: chating
                                ? CircularProgressIndicator()
                                : chatButton()),
                        consultant!.openOrders < 5
                            ? SizedBox(
                                height: 20.h,
                              )
                            : SizedBox(),
                        //
                        consultant!.openOrders < 5
                            ? registerWidget()
                            : SizedBox(),
                        SizedBox(
                          height: 20.h,
                        ),
                        if (consultant!.link != null)
                          //video
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: size.width * .05.w),
                            child: consultant!.link != null
                                ? Container(
                                    width: size.width * .3.w,
                                    child: VideoWidget(
                                      link: consultant!.link.toString(),
                                      VideoAppid: consultant!.link
                                          .toString()
                                          .substring(
                                              consultant!.link
                                                      .toString()
                                                      .indexOf("=") +
                                                  1,
                                              consultant!.link
                                                  .toString()
                                                  .length),
                                    ))
                                : SizedBox(),
                          ),
                        //title
                        _ReadMoreText(consultant: consultant!),
                        ReportConsultWidget(
                          consult: consultant!,
                          loggedUser: user,
                        ),
                        PlatListWidget(
                          consultantUid: consultant!.uid.toString(),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        //review
                        ReviewWidget(consultant: consultant!),
                        SizedBox(
                          height: 20.h,
                        ),
                        ConsultTimeWidget(
                          consultant: consultant!,
                        ),
                        SizedBox(
                          height: 30.h,
                        ),
                        packageWidget(size),
                        SizedBox(
                          height: 20.h,
                        ),
                        payButton(size),
                        SizedBox(
                          height: AppSize.h40.h,
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        showPayView
            ? Positioned(
                child: Scaffold(
                  backgroundColor: AppColors.white,
                  body: IndexedStack(
                    index: _stackIndex,
                    children: <Widget>[
                      kIsWeb
                          ? Container()
                          : WebView(
                              initialUrl: initialUrl,
                              navigationDelegate: (NavigationRequest request) {
                                if (request.url.startsWith(
                                    "https://www.jeras.io/app/redirect_url")) {
                                  setState(() {
                                    _stackIndex = 1;
                                    showPayView = false;
                                    var str = request.url;
                                    const start = "tap_id=";
                                    final startIndex = str.indexOf(start);

                                    String charge = str.substring(
                                        startIndex + start.length, str.length);
                                    payStatus(charge);
                                  });
                                  return NavigationDecision.prevent;
                                }
                                return NavigationDecision.navigate;
                              },
                              javascriptMode: JavascriptMode.unrestricted,
                              gestureNavigationEnabled: true,
                              initialMediaPlaybackPolicy:
                                  AutoMediaPlaybackPolicy.always_allow,
                              onPageFinished: (url) {
                                //showSnakbar(url, true);
                                setState(() => _stackIndex = 0);
                              },
                            ),
                      Center(child: Text('Loading  ...')),
                      Center(child: Text('order ...'))
                    ],
                  ),
                ),
              )
            : Container()
      ]),
      mobile: Stack(children: <Widget>[
        Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: <Widget>[
            //header
            ConsultDetailHeaderWidget(
              loggedUser: user,
              consultant: consultant!,
            ),
            MediaQuery.removePadding(
              context: context,
              removeTop: true,
              child: Expanded(
                child: ResponsiveLayout(
                  desktop: Padding(
                    padding: EdgeInsets.only(
                        top: 6.h,
                        left: size.width * AppSize.w0_06,
                        right: size.width * AppSize.w0_06),
                    child: ListView(
                      physics: AlwaysScrollableScrollPhysics(),
                      controller: _scrollController,
                      children: [
                        InterestWidget(
                            interestListIds: consultant!.interestListIds!),
                        //change
                        Padding(
                          padding: EdgeInsets.only(
                            top: size.height * .1,
                            bottom: size.height * .03,
                          ),
                          child: Row(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                children: [
                                  chating
                                      ? CircularProgressIndicator()
                                      : chatButton(),
                                  SizedBox(
                                    height: AppSize.h10.h,
                                  ),
                                  consultant!.openOrders < 5
                                      ? registerWidget()
                                      : SizedBox(),
                                ],
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.start,
                                children: [
                                  Column(
                                    crossAxisAlignment:
                                        CrossAxisAlignment.start,
                                    mainAxisAlignment: MainAxisAlignment.start,
                                    children: [
                                      TextDefaultWidget(
                                        title: getTranslated(context, "lang") ==
                                                "ar"
                                            ? consultant!.name!
                                            : consultant!.nameEn!,
                                        fontFamily: getTranslated(
                                            context, "Montserrat"),
                                        fontWeight:
                                            AppFontsWeightManager.semiBold,
                                        fontSize: 33 * 1.5.sp,
                                        color: AppColors.black,
                                      ),
                                      Padding(
                                        padding: const EdgeInsets.only(top: 10),
                                        child: Row(
                                          mainAxisAlignment:
                                              MainAxisAlignment.center,
                                          children: [
                                            TextDefaultWidget(
                                              title:
                                                  consultant!.price.toString() +
                                                      "\$",
                                              fontFamily: getTranslated(
                                                  context, "Montserrat"),
                                              fontWeight: AppFontsWeightManager
                                                  .semiBold,
                                              fontSize: 22 * 1.5.sp,
                                              color: AppColors.black,
                                            ),
                                            SizedBox(width: AppSize.w10.w),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SvgPicture.asset(
                                                  AssetsManager.phoneCall,
                                                  width: 24.5 * 1.5.r,
                                                  height: 24.6 * 1.5.r,
                                                ),
                                                SizedBox(width: 2.w),
                                                TextDefaultWidget(
                                                  title: consultant!
                                                              .ordersNumbers ==
                                                          null
                                                      ? '0'
                                                      : consultant!
                                                                  .ordersNumbers! <
                                                              100
                                                          ? consultant!
                                                              .ordersNumbers
                                                              .toString()
                                                          : consultant!
                                                                      .ordersNumbers! <
                                                                  1000
                                                              ? "+100"
                                                              : "+1000",
                                                  fontFamily: getTranslated(
                                                      context, "Montserrat"),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 22 * 1.5.sp,
                                                  color: AppColors.black,
                                                ),
                                              ],
                                            ),
                                            SizedBox(width: AppSize.w10.w),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment.center,
                                              crossAxisAlignment:
                                                  CrossAxisAlignment.center,
                                              children: [
                                                SmoothStarRating(
                                                  allowHalfRating: true,
                                                  starCount: 1,
                                                  rating: 1,
                                                  size: 25.0 * 1.5.r,
                                                  color: AppColors.yellow,
                                                  borderColor: AppColors.yellow,
                                                  spacing: 1.0,
                                                ),
                                                SizedBox(width: 2.w),
                                                TextDefaultWidget(
                                                  title: consultant!.rating == 0
                                                      ? 0.toString()
                                                      : consultant!.rating
                                                          .toString(),
                                                  fontFamily: getTranslated(
                                                      context, "Montserrat"),
                                                  fontWeight: FontWeight.w400,
                                                  fontSize: 23 * 1.5.sp,
                                                  color: AppColors.black,
                                                ),
                                              ],
                                            ),
                                          ],
                                        ),
                                      ),
                                      SizedBox(height: 10.h),
                                      Row(
                                        children: [
                                          Icon(
                                            Icons.location_on_outlined,
                                            color:
                                                Theme.of(context).primaryColor,
                                            size: 21 * 1.5.r,
                                          ),
                                          Text(
                                            getTranslated(context, "lang") ==
                                                    "ar"
                                                ? consultant!.location!
                                                : consultant!.locationEn!,
                                            textAlign: TextAlign.center,
                                            overflow: TextOverflow.ellipsis,
                                            maxLines: 1,
                                            style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, "Ithra"),
                                              fontSize: 19.0 * 1.5.sp,
                                              color: AppColors.black2,
                                              fontWeight: FontWeight.normal,
                                            ),
                                          ),
                                        ],
                                      ),
                                    ],
                                  ),
                                  consultImage(140),
                                ],
                              ),
                            ],
                          ),
                        ),
                        SizedBox(
                          height: AppSize.h40.h,
                        ),
                        //video
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                                width: size.width * .5,
                                child: _ReadMoreText(consultant: consultant!)),
                            consultant!.link != null
                                ? Container(
                                    width: size.width * .3,
                                    child: VideoWidget(
                                      link: consultant!.link.toString(),
                                      VideoAppid: consultant!.link
                                          .toString()
                                          .substring(
                                              consultant!.link
                                                      .toString()
                                                      .indexOf("=") +
                                                  1,
                                              consultant!.link
                                                  .toString()
                                                  .length),
                                    ))
                                : SizedBox(),
                          ],
                        ),

                        //
                        ReportConsultWidget(
                          consult: consultant!,
                          loggedUser: user,
                        ),
                        Center(
                          child: PlatListWidget(
                            consultantUid: consultant!.uid.toString(),
                          ),
                        ),
                        SizedBox(
                          height: 20.h,
                        ),
                        //
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Container(
                              width: 400.w,
                              height: 281.h,
                              child: ConsultTimeWidget(
                                consultant: consultant!,
                              ),
                            ),
                            SizedBox(
                              height: 20.h,
                            ),
                            Container(
                                width: 400.w,
                                height: 297.h,
                                child: ReviewWidget(consultant: consultant!)),
                          ],
                        ),

                        SizedBox(
                          height: size.height * .1,
                        ),
                        packageWidget(size),
                        SizedBox(
                          height: size.height * .07,
                        ),
                        payButton(size),
                        SizedBox(
                          height: AppSize.h40.h,
                        ),
                      ],
                    ),
                  ),

                  ///=====================================================================
                  mobile: SingleChildScrollView(
                    controller: _scrollController,
                    physics: AlwaysScrollableScrollPhysics(),
                    child: Column(
                      children: [
                        //name
                        Padding(
                          padding: EdgeInsets.only(
                              left: convertPtToPx(AppPadding.p24).w,
                              right: convertPtToPx(AppPadding.p24).w,
                              top: convertPtToPx(AppPadding.p16).h),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.center,
                            mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              SizedBox(height: 10.h),
                              Row(
                                mainAxisAlignment:
                                    MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  SizedBox(
                                    width: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.w75.r
                                        : AppSize.w50_6.r,
                                    height: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.h75.r
                                        : AppSize.h50_6.r,
                                  ),
                                  consultImage(AppSize.h106_6.h),
                                  InkWell(
                                    onTap: () {
                                      share();
                                    },
                                    child: Container(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w75.r
                                          : convertPtToPx(AppSize.h38).w,
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h75.r
                                          : convertPtToPx(AppSize.h38).w,
                                      padding: EdgeInsets.all(
                                          convertPtToPx(AppPadding.p7).r),
                                      decoration: BoxDecoration(
                                          color: AppColors.grey7,
                                          borderRadius: BorderRadius.circular(
                                              convertPtToPx(AppRadius.r4).r)),
                                      child: SvgPicture.asset(
                                          AssetsManager.shareIconPath),
                                    ),
                                  ),
                                ],
                              ),
                              //name
                              SizedBox(height: AppSize.h10_6.h),
                              TextDefaultWidget(
                                title: getTranslated(context, "lang") == "ar"
                                    ? consultant!.name!
                                    : consultant!.nameEn!,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontWeight: AppFontsWeightManager.semiBold,
                                fontSize: 14 * 1.5.sp,
                                color: AppColors.black,
                              ),
                              SizedBox(height: convertPtToPx(AppSize.h8).h),

                              Row(
                                // mainAxisAlignment:
                                // MainAxisAlignment.spaceBetween,
                                children: [
                                  //call number
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SvgPicture.asset(
                                          AssetsManager.phoneCall,
                                          width: convertPtToPx(AppSize.w24).r,
                                          height: convertPtToPx(AppSize.w24).r,
                                        ),
                                        SizedBox(
                                            height:
                                                convertPtToPx(AppSize.h5).h),
                                        TextDefaultWidget(
                                          title: consultant!.ordersNumbers ==
                                                  null
                                              ? '0'
                                              : consultant!.ordersNumbers! < 100
                                                  ? consultant!.ordersNumbers
                                                      .toString()
                                                  : consultant!.ordersNumbers! <
                                                          1000
                                                      ? "100+"
                                                      : "1000+",
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontWeight:
                                              AppFontsWeightManager.regular,
                                          fontSize: convertPtToPx(
                                                  AppFontsSizeManager.s14)
                                              .sp,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: convertPtToPx(AppPadding.p16).w),

                                  //dollar
                                  Expanded(
                                    child: Column(
                                      children: [
                                        SvgPicture.asset(
                                          AssetsManager.dollar,
                                          width: convertPtToPx(AppSize.w19).r,
                                          height: convertPtToPx(AppSize.w18).r,
                                        ),
                                        SizedBox(
                                            height:
                                                convertPtToPx(AppSize.h5).h),
                                        TextDefaultWidget(
                                          title: consultant!.price.toString() +
                                              "\$",
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontWeight:
                                              AppFontsWeightManager.regular,
                                          fontSize: convertPtToPx(
                                                  AppFontsSizeManager.s14)
                                              .sp,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: convertPtToPx(AppPadding.p16).w),

                                  //star numbers
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      crossAxisAlignment:
                                          CrossAxisAlignment.center,
                                      children: [
                                        SmoothStarRating(
                                          allowHalfRating: true,
                                          starCount: 1,
                                          rating: 1,
                                          size: convertPtToPx(AppSize.w24).r,
                                          color: AppColors.yellow,
                                          borderColor: AppColors.yellow,
                                          spacing: 1.0,
                                        ),
                                        SizedBox(
                                            height:
                                                convertPtToPx(AppSize.h5).h),
                                        TextDefaultWidget(
                                          title: consultant!.rating == 0
                                              ? 0.toString()
                                              : consultant!.rating.toString(),
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontWeight:
                                              AppFontsWeightManager.regular,
                                          fontSize: convertPtToPx(
                                                  AppFontsSizeManager.s14)
                                              .sp,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                  SizedBox(
                                      width: convertPtToPx(AppPadding.p16).w),

                                  //location
                                  Expanded(
                                    child: Column(
                                      mainAxisAlignment:
                                          MainAxisAlignment.center,
                                      children: [
                                        Icon(
                                          Icons.location_on_outlined,
                                          color: Theme.of(context).primaryColor,
                                          size: convertPtToPx(AppSize.w24).r,
                                        ),
                                        SizedBox(
                                            height:
                                                convertPtToPx(AppSize.h5).h),
                                        TextDefaultWidget(
                                          title:
                                              getTranslated(context, "lang") ==
                                                      "ar"
                                                  ? consultant!.location!
                                                  : consultant!.locationEn!,
                                          fontFamily: getTranslated(
                                              context, "Ithralight"),
                                          fontWeight:
                                              AppFontsWeightManager.regular,
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? 12 * 1.5.sp
                                              : convertPtToPx(
                                                      AppFontsSizeManager.s14)
                                                  .sp,
                                          color: AppColors.black1,
                                        ),
                                      ],
                                    ),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),

                        SizedBox(
                          height: convertPtToPx(AppSize.h40).h,
                        ),

                        if (!showBookingSection)
                          Column(
                            children: [
                              //contact button
                              Center(
                                  child: chating
                                      ? CircularProgressIndicator()
                                      : chatButton()),
                              consultant!.openOrders < 5
                                  ? SizedBox(
                                      height: 20.h,
                                    )
                                  : SizedBox(),
                              //
                              consultant!.openOrders < 5
                                  ? registerWidget()
                                  : SizedBox(),
                              SizedBox(
                                height: AppSize.h32.h,
                              ),
                              if (consultant!.link != null)
                                //video

                                //
                                Container(
                                  width: AppSize.w509_3.w,
                                  height: AppSize.h328.h,
                                  decoration: BoxDecoration(
                                      color: AppColors.grey4,
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.r10_6.r)),
                                  child: Column(
                                    children: [
                                      SizedBox(
                                        height: AppSize.h21_3.h,
                                      ),
                                      Padding(
                                        padding: EdgeInsets.symmetric(
                                            horizontal: size.width * .05.w),
                                        child: consultant!.link != null
                                            ? Container(
                                                width: AppSize.w466_6.w,
                                                height: AppSize.h230.h,
                                                child: consultant!.link!
                                                        .contains('firebase')
                                                    ? FirebaseVideoPlayerWidget(
                                                        consultant!.link,
                                                      )
                                                    : VideoWidget(
                                                        link: consultant!.link
                                                            .toString(),
                                                        VideoAppid: consultant!
                                                            .link
                                                            .toString()
                                                            .substring(
                                                                consultant!.link
                                                                        .toString()
                                                                        .indexOf(
                                                                            "=") +
                                                                    1,
                                                                consultant!.link
                                                                    .toString()
                                                                    .length),
                                                      ))
                                            : SizedBox(),
                                      ),
                                      SizedBox(
                                        height: AppSize.h21_3.h,
                                      ),
                                      consultant!.link != null
                                          ? Padding(
                                              padding: EdgeInsets.symmetric(
                                                  horizontal:
                                                      size.width * .05.w),
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment.end,
                                                children: [
                                                  InkWell(
                                                    onTap: () {
                                                      Navigator.push(
                                                          context,
                                                          MaterialPageRoute(
                                                              builder: (context) =>
                                                                  AllConsultantVideosScreen(
                                                                    consultant:
                                                                        consultant!,
                                                                  )));
                                                    },
                                                    child: Container(
                                                      width: AppSize.w230.w,
                                                      height: AppSize.h33_3.h,
                                                      decoration: BoxDecoration(
                                                        color: AppColors
                                                            .primaryLight,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r5_3
                                                                        .r),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .w,
                                                                vertical:
                                                                    AppPadding
                                                                        .p6.h),
                                                        child: Row(
                                                          children: [
                                                            Expanded(
                                                              child: Text(
                                                                getTranslated(
                                                                    context,
                                                                    "moreVidTxt"),
                                                                style:
                                                                    TextStyle(
                                                                  color: AppColors
                                                                      .linear8,
                                                                  fontSize:
                                                                      AppFontsSizeManager
                                                                          .s16
                                                                          .sp,
                                                                  fontFamily:
                                                                      getTranslated(
                                                                          context,
                                                                          "NotoKufiArabic-Regular"),
                                                                ),
                                                              ),
                                                            ),
                                                            SizedBox(
                                                              width: AppSize
                                                                  .w13_3.w,
                                                            ),
                                                            SvgPicture.asset(
                                                              AssetsManager
                                                                  .iosArrowLeftIconPath,
                                                              height: AppSize
                                                                  .h13_3.h,
                                                              width: AppSize
                                                                  .w8_2.w,
                                                              color: AppColors
                                                                  .linear8,
                                                            )
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ),
                                                ],
                                              ),
                                            )
                                          : SizedBox(),
                                    ],
                                  ),
                                ),
                              //   //     ? Container(
                              //   //         width: double.infinity,
                              //   //         child: VideoWidget(
                              //   //           link: consultant!.link.toString(),
                              //   //           VideoAppid: consultant!.link.toString().substring(
                              //   //               consultant!.link.toString().indexOf("=") + 1,
                              //   //               consultant!.link.toString().length),
                              //   //         ))
                              //   //     : SizedBox(),
                              SizedBox(height: AppSize.h25.h),

                              //title
                              _ReadMoreText(consultant: consultant!),
                              ReportConsultWidget(
                                consult: consultant!,
                                loggedUser: user,
                              ),

                              SizedBox(
                                height: 20.h,
                              ),
                              //review
                              ReviewWidget(consultant: consultant!),
                              SizedBox(
                                height: 56.h,
                              ),
                              ConsultTimeWidget(
                                consultant: consultant!,
                              ),

                              ///packages for mobile.
                              packageWidget(size),

                              /// pay button for mobile.
                              ///
                              payButton(size),
                            ],
                          ),

                        // SizedBox(
                        //   height:AppSize.h25.h,
                        // ),

                        if (showBookingSection)
                          AddAppointmentDialog(
                            loggedUser: user!,
                            consultant: consultant!,
                            localFrom: localFrom,
                            localTo: localTo,
                            package: package!,
                            getData: getDataFromDialog,
                            backFromBooking: backFromBooking,
                          ),
                      ],
                    ),
                  ),
                ),
              ),
            )
          ],
        ),
        showPayView
            ? Positioned(
                child: Scaffold(
                  backgroundColor: AppColors.white,
                  body: IndexedStack(
                    index: _stackIndex,
                    children: <Widget>[
                      kIsWeb
                          ? Container()
                          : WebView(
                              initialUrl: initialUrl,
                              navigationDelegate: (NavigationRequest request) {
                                if (request.url.startsWith(
                                    "https://www.jeras.io/app/redirect_url")) {
                                  setState(() {
                                    _stackIndex = 1;
                                    showPayView = false;
                                    var str = request.url;
                                    const start = "tap_id=";
                                    final startIndex = str.indexOf(start);

                                    String charge = str.substring(
                                        startIndex + start.length, str.length);
                                    payStatus(charge);
                                  });
                                  return NavigationDecision.prevent;
                                }
                                return NavigationDecision.navigate;
                              },
                              javascriptMode: JavascriptMode.unrestricted,
                              gestureNavigationEnabled: true,
                              initialMediaPlaybackPolicy:
                                  AutoMediaPlaybackPolicy.always_allow,
                              onPageFinished: (url) {
                                //showSnakbar(url, true);
                                setState(() => _stackIndex = 0);
                              },
                            ),
                      Center(child: Text('Loading  ...')),
                      Center(child: Text('order ...'))
                    ],
                  ),
                ),
              )
            : Container()
      ]),
    );
  }

  consultImage(double sizeValue) {
    return Container(
      height: sizeValue,
      width: sizeValue,
      decoration: BoxDecoration(
        border: Border.all(color: AppColors.white, width: 2.w),
        boxShadow: [
          BoxShadow(
              color: const Color(0x1a7b6c96),
              offset: Offset(0, 5),
              blurRadius: 17,
              spreadRadius: 0)
        ],
        shape: BoxShape.circle,
        color: AppColors.white,
      ),
      child: Container(
        height: sizeValue.r,
        width: sizeValue.r,
        decoration: BoxDecoration(
          border: Border.all(color: AppColors.white, width: 5.w),
          shape: BoxShape.circle,
          color: AppColors.white,
        ),
        child: consultant!.photoUrl!.isEmpty
            ? Image.asset(
                AssetsManager.whiteJerasLogoIconPath,
                width: sizeValue.r,
                height: sizeValue.r,
                fit: BoxFit.fill,
              )
            : ClipRRect(
                borderRadius: BorderRadius.circular(100.0.r),
                child: FadeInImage.assetNetwork(
                  placeholder: AssetsManager.lodeGif,
                  placeholderScale: 0.5,
                  imageErrorBuilder: (context, error, stackTrace) =>
                      Image.asset(AssetsManager.whiteJerasLogoIconPath,
                          width: sizeValue.r,
                          height: sizeValue.r,
                          fit: BoxFit.fill),
                  image: consultant!.photoUrl!,
                  fit: BoxFit.cover,
                  fadeInDuration:
                      Duration(milliseconds: AppConstants.milliseconds250),
                  fadeInCurve: Curves.easeInOut,
                  fadeOutDuration:
                      Duration(milliseconds: AppConstants.milliseconds150),
                  fadeOutCurve: Curves.easeInOut,
                ),
              ),
      ),
    );
  }

  packageWidget(Size size) {
    return Column(
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h113.h
                  : AppSize.h48.h,
              //pb width change 96 to 126
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 316.w
                  : lang == "ar"
                      ? AppSize.w156.w
                      : AppSize.w180,
              decoration: BoxDecoration(
                boxShadow: [
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppShadow.greyshadow
                      : AppShadow.fabshadow
                ],
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppRadius.r30.r
                        : AppRadius.r5_3.r),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    getTranslated(context, "Packages"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.primaryColor,
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? 32.sp
                              : 21.sp,
                      fontWeight: FontWeight.normal,
                    ),
                  ),
                  SizedBox(
                    width: AppSize.w5.w,
                  ),
                  SvgPicture.asset(AssetsManager.roundCheckIconPath,
                      color: AppColors.primaryColor),
                ],
              ),
            ),
            SizedBox(
              width: AppSize.w10.w,
            )
          ],
        ),
        SizedBox(
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h71.h
              : AppSize.h21_3.h,
        ),
        loadPackage ? Center(child: CircularProgressIndicator()) : SizedBox(),
        (loadPackage == false && packages.length == 0)
            ? Padding(
                padding: EdgeInsets.symmetric(vertical: 8.0.h),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Image.asset(
                        'assets/images/credit_card.png',
                        width: size.width * 0.6,
                      ),
                      SizedBox(
                        height: 15.0.h,
                      ),
                      Text(
                        getTranslated(context, "noPackages"),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: AppColors.grey,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 20.sp
                                  : 21.0.sp,
                          fontWeight: AppFontsWeightManager.semiBold,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ],
                  ),
                ),
              )
            : SizedBox(),
        (loadPackage == false && packages.length > 0)
            ?
            // GridView.count(
            //   crossAxisCount: 3,
            //   children: List.generate(
            //       packages.length,
            //           (index) => Column(
            //             crossAxisAlignment: CrossAxisAlignment.center,
            //             mainAxisAlignment: MainAxisAlignment.center,
            //             children: [
            //               Text(
            //                 packages[index].price.toString() + "\$",
            //                 style: TextStyle(
            //                     color: AppColors.pink,
            //                     fontWeight: AppFontsWeightManager.bold500,
            //                     fontFamily: getTranslated(context, "Montserrat"),
            //                     fontStyle: FontStyle.normal,
            //                     fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            //                         ? 33.sp
            //                         : 18.0.sp),
            //               ),
            //               Container(
            //                 width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            //                     ? size.width * .1
            //                     : size.width * .3,
            //                 child: Text(
            //                   'callsValue',
            //                   //index==0?getTranslated(context, "oneCall"):callsValue,
            //                   textAlign: TextAlign.center,
            //                   style: TextStyle(
            //                       fontWeight:AppFontsWeightManager.bold300,
            //                       fontFamily: getTranslated(context, "Ithra"),
            //                       fontStyle: FontStyle.normal,
            //                       //pb size from 18 to 17
            //                       fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            //                           ? 27.sp
            //                           : 17.0.sp),
            //                 ),
            //               ),
            //             ],
            //           ),
            //   ),
            // )
            WrappedCard(
                onSelectItem: _onSelected,
                length: packages.length,
                builder: (context, index) {
                  String callsValue = getTranslated(context, "calls");
                  if (index == 0 && consultant!.consultType == "vocal")
                    callsValue = getTranslated(context, "oneCall") +
                        getTranslated(context, "vocalTime");
                  else if (index == 0 && consultant!.consultType != "glorified")
                    callsValue = getTranslated(context, "oneCall") +
                        getTranslated(context, "60Minutes");
                  else if (packages[index].callNum == 10)
                    callsValue = "10" + getTranslated(context, "call");
                  else if (packages[index].callNum == 26)
                    callsValue = getTranslated(context, "month");
                  else if (packages[index].callNum == 78)
                    callsValue = "3" + getTranslated(context, "months");
                  else if (packages[index].callNum == 156)
                    callsValue = "6" + getTranslated(context, "months");
                  else if (packages[index].callNum == 3)
                    callsValue = "3" + getTranslated(context, "calls");
                  else if (packages[index].callNum == 6)
                    callsValue = "6" + getTranslated(context, "calls");
                  else
                    callsValue = packages[index].callNum.toString() +
                        getTranslated(context, "calls");
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        packages[index].price.toString() + "\$",
                        style: TextStyle(
                            color: AppColors.pink,
                            fontWeight: AppFontsWeightManager.bold500,
                            fontFamily: getTranslated(context, "Montserrat"),
                            fontStyle: FontStyle.normal,
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 33.sp
                                : 18.0.sp),
                      ),
                      Container(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * .1
                                : size.width * .3,
                        child: Text(
                          callsValue,
                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                          //index==0?getTranslated(context, "oneCall"):callsValue,
                          textAlign: TextAlign.center,

                          style: TextStyle(
                              fontWeight: AppFontsWeightManager.bold300,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              //pb size from 18 to 17
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 27.sp
                                  : 17.0.sp),
                        ),
                      ),
                    ],
                  );
                },
              )
            : SizedBox(),
      ],
    );
  }

  payButton(Size size) {
    return Column(
      children: [
        SizedBox(
          height: AppSize.h25.h,
        ),
        (consultant!.consultType != "vocal")
            ? PrimaryButton(
                text: getTranslated(context, "StartYourReservation"),
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w1010.w
                    : AppSize.w357.w,
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h133.h
                    : AppSize.h57.h,
                textSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppFontsSizeManager.s36
                    : AppFontsSizeManager.s16.sp,
                buttonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppRadius.r28.r
                    : AppRadius.r10.r,
                onPress: () async {
                  if (user == null) {
                    Navigator.pushNamed(context, '/Register_Type');
                  } else if (user?.profileCompleted == false)
                    changeTypeDialog(size);
                  else if (package == null)
                    Helper.ShowToastMessage(
                        getTranslated(context, 'selectPackage'), false);
                  else if (consultant!.openOrders >= 5)
                    Helper.ShowToastMessage(
                        getTranslated(context, 'completed'), false);
                  else {
                    setState(() {
                      showBookingSection = true;
                    });
                  }
                },
              )
            : SizedBox(),
        SizedBox(
          height: AppSize.h25.h,
        ),
      ],
    );
  }

  share() async {
    try {
      setState(() {
        sharing = true;
      });
      String userUrl =
          "https://jerasnew.web.app/conslultant?consultant_id=${consultant!.uid}";
      String url = await dynamicLinks.shareConsultantByDynamicLink(
          userUrl, context, consultant);
      Share.share(url); //${dynamicLink.shortUrl.toString()}
      setState(() {
        sharing = false;
      });
    } catch (e) {}
  }

  calculateDiscount() async {
    setState(() {
      checkPromo = true;
    });
    if (controller.text != "") {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: true)
          .where('code', isEqualTo: controller.text)
          .limit(1)
          .get();
      var codes = List<PromoCode>.from(
        querySnapshot.docs.map(
          (snapshot) => PromoCode.fromMap(snapshot.data() as Map),
        ),
      );
      if (codes.length > 0) {
        print("promo3");
        print(codes[0].type);
        bool isPrimary = (codes[0].type == "primary" &&
            codes[0].promoCodeStatus &&
            user!.promoList != null &&
            user!.promoList!.contains(codes[0].promoCodeId) == false);
        if ((codes[0].type == "default" && codes[0].promoCodeStatus) ||
            isPrimary) print(isPrimary);
        if ((codes[0].type == "default" && codes[0].promoCodeStatus) ||
            isPrimary)
          setState(() {
            print("valid");
            promo = codes[0];
            promoCodeId = promo!.promoCodeId;
            checkPromo = false;
            valid = true;
            discount = promo!.discount;
          });
        else
          setState(() {
            print("promo4");
            promoCodeId = "";
            checkPromo = false;
            valid = false;
            discount = 0;
          });
      } else {
        setState(() {
          print("promo4");
          // promo = null;
          promoCodeId = "";
          checkPromo = false;
          valid = false;
          discount = 0;
        });
      }
    }
  }

  paywithTab() async {
    FirebaseFunctions functions = FirebaseFunctions.instance;
    HttpsCallable callable = functions.httpsCallable("payWithTab");
    String description = user!.phoneNumber!;
    final res = await callable.call({
      'tabid': widget.tabid,
      'price': price.toString(),
      //(double.parse(price.toString()) +(double.parse(price.toString()) * 5) / 100).toString(),
      'packageId': package!.Id,
      'promoCodeId': promoCodeId,
      'callPrice': double.parse(price.toString()) / package!.callNum,
      'userUid': user!.uid,
      'consultUid': consultant!.uid,
      'userName': user?.name,
      'paytype': 'consult',
      'phoneNumber': user?.phoneNumber,
      'description': description,
      'consultid': widget.consoltantId,
      'localFrom': localFrom,
      'localTo': localTo,
    });

    openTab.goPaymentPage(
        [res.data['transaction']['url'], '_self']); //<= find explanation below
    return res.data;
  }

  checkwithTab() async {
    try {
      FirebaseFunctions functions = FirebaseFunctions.instance;
      HttpsCallable callable = functions.httpsCallable("checkWithTab");
      final res = await callable.call({
        'consultid': widget.consoltantId,
        'tabid': widget.tabid,
        //"tabdata":widget.paydata
      });

      if (res.data['status'] == "CAPTURED") {
        if (res.data['metadata']['promoCodeId'] != null) {
          var promoData = await FirebaseFirestore.instance
              .collection("PromoCode")
              .doc(res.data['metadata']['promoCodeId'])
              .get();
          promo = PromoCode.fromMap(promoData.data() as Map);
        }
        var packagedata = await FirebaseFirestore.instance
            .collection("consultPackage")
            .doc(res.data['metadata']['packageId'])
            .get();
        package = consultPackage.fromMap(packagedata.data() as Map);

        var consdata = await FirebaseFirestore.instance
            .collection("Users")
            .doc(res.data['metadata']['consultUid'])
            .get();
        consultant = GroceryUser.fromMap(consdata.data() as Map);

        var userdata = await FirebaseFirestore.instance
            .collection("Users")
            .doc(res.data['metadata']['userUid'])
            .get();
        user = GroceryUser.fromMap(userdata.data() as Map);
        localFrom = int.parse(res.data['metadata']['localFrom']);
        localTo = int.parse(res.data['metadata']['localTo']);
        currentNumber = package!.callNum;
        updateDatabaseAfterAddingOrdertabweb(
          res.data['metadata']['price'],
          res.data['metadata']['callPrice'],
          res.data['metadata']['promoCodeId'],
        );
      } else {
        //--------add details event
        // Map eventValues = {
        //   "af_success": false,
        //   "af_achievement_id": res['status'],
        // };
        // addEvent(eventName, eventValues);
        // await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        //   "success": false,
        //   "reason": res['status'],
        //   "userUid": user!.uid
        // });
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
          showPayView = false;
          load = false;
        });
        Helper.ShowToastMessage(getTranslated(context, "failed"), true);
      }
      return res.data;
    } catch (e) {
      throw e;
    }
  }

  pay() async {
    try {
      if (user != null && user!.name != null) userName = user!.name!;
      String description = "رسوم الخدمة (5%)";
      final uri = Uri.parse('https://api.tap.company/v2/charges');
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        //'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
        'Authorization': "Bearer sk_live_C7V9cpBMFWbt2ukjd3fRxIeD",
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
      };
      Map<String, dynamic> body = {
        "amount": double.parse(price.toString()) +
            ((double.parse(price.toString()) * 5) / 100),
        "currency": "USD",
        "threeDSecure": true,
        "save_card": true,
        "description": description,
        "statement_descriptor": "مؤسسة  محور النقطة",
        "metadata": {
          "udf1": "مؤسسة  محور النقطة",
          "udf2": "مؤسسة  محور النقطة"
        },
        "reference": {"transaction": "txn_0001", "order": "ord_0001"},
        "receipt": {"email": false, "sms": true},
        "customer": {
          "id": user!.customerId != null ? user!.customerId : '',
          "first_name": userName,
          "middle_name": ".",
          "last_name": ".",
          "email": userName + "@jeras.com",
          "phone": {"country_code": "", "number": user!.phoneNumber}
        },
        "merchant": {"id": ""},
        "source": {"id": "src_all"},
        "post": {"url": "http://your_website.com/post_url"},
        "redirect": {"url": "https://www.jeras.io/app/redirect_url"}
      };
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await http.post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
      String responseBody = response.body;
      var res = json.decode(responseBody);
      String url = res['transaction']['url'];

      // Navigator.pop(context);
      setState(() {
        initialUrl = url;
        // webViewController.loadRequest(Uri.parse(initialUrl));

        showPayView = true;
      });
    } catch (e) {
      errorLog("pay", e.toString());
      await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        "success": "false",
        "reason": e.toString(),
        "userUid": user!.uid
      });
      setState(() {
        showPayView = false;
        load = false;
      });
      Helper.ShowToastMessage(getTranslated(context, "failed"), true);
      // showDialog(
      //     context: context,
      //     builder: (context) => ShowDialog(
      //       contentText: 'otherPay',
      //       noFunction: () {
      //         setState(() {
      //           load = false;
      //         });
      //         Navigator.pop(context);
      //       },
      //       yesFunction: () async {
      //         Navigator.pop(context);
      //         setState(() {
      //           load = true;
      //           fromBalance = false;
      //         });
      //         stripePayment(
      //             amount: price,
      //             context: context);
      //         // pay();
      //       },
      //     ));
    }
  }

  Future<void> stripePayment(
      {required String amount, required BuildContext context}) async {
    try {
      print("stripePayment1");
      print(amount.toString());

      final isPaymentSuccessful = await showModalBottomSheet<bool>(
        isScrollControlled: true,
        context: context,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.only(
              topLeft: Radius.circular(30.0), topRight: Radius.circular(30.0)),
        ),
        builder: (context) {
          return StripePaymentBottomSheet(
            loggedUser: user!,
            price: double.parse(amount),
            productName: package!.Id!,
            productDesc: '${package!.callNum} -- ${package!.Id}',
          );
        },
      );

      if (isPaymentSuccessful != null && isPaymentSuccessful) {
        // تم الدفع بنجاح
        Helper.ShowToastMessage("Payment is successful", false);
        print("stripePayment4");
        updateDatabaseAfterAddingOrder(user!.customerId, "stripe ", ".",
            totalPrice: price);
      } else {
        // لم يتم الدفع أو حدث خطأ
        print("stripeerror");
      }
    } catch (errorr) {
      print("stripeerror");
      print("error in stripe is ${errorr.toString()}");
      Helper.ShowToastMessage('An error occured $errorr', true);
      setState(() {
        load = false;
      });
    }
  }

  payStatus(String chargeId) async {
    try {
      final uri = Uri.parse('https://api.tap.company/v2/charges/' + chargeId);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        // 'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
        'Authorization': "Bearer sk_live_C7V9cpBMFWbt2ukjd3fRxIeD",
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br'
      };
      var response = await get(
        uri,
        headers: headers,
      );
      String responseBody = response.body;
      var res = json.decode(responseBody);

      if (res['status'] == "CAPTURED") {
        String? customerId = res['customer']['id'];
        customerId = customerId != null ? customerId : "";
        updateDatabaseAfterAddingOrder(customerId, "tapCompany", ".",
            totalPrice: price);
      } else {
        //callHuperPayWidget
        //--------add details event
        String eventName = "af_add_payment_info";
        Map eventValues = {
          "af_success": false,
          "af_achievement_id": res['status'],
        };
        addEvent(eventName, eventValues);
        await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
          "success": "false",
          "reason": res['status'],
          "userUid": user!.uid
        });
        String id = Uuid().v4();
        await FirebaseFirestore.instance
            .collection(Paths.errorLogPath)
            .doc(id)
            .set({
          'timestamp': Timestamp.now(),
          'id': id,
          'seen': false,
          'desc': res['status'],
          'phone': user == null ? " " : user!.phoneNumber,
          'screen': "ConsultantDetailsScreen",
          'function': "payStatus",
        });
        setState(() {
          showPayView = false;
          load = false;
        });
        Helper.ShowToastMessage(getTranslated(context, "failed"), true);
        // showDialog(
        //     context: context,
        //     builder: (context) => ShowDialog(
        //       contentText: 'otherPay',
        //       noFunction: () {
        //         setState(() {
        //           load = false;
        //         });
        //         Navigator.pop(context);
        //       },
        //       yesFunction: () {
        //         Navigator.pop(context);
        //         setState(() {
        //           load = true;
        //           fromBalance = false;
        //         });
        //         stripePayment(
        //             amount: price,
        //             context: context);
        //         // pay();
        //       },
        //     ));
      }
    } catch (e) {
      errorLog("payStatus", e.toString());
      await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        "success": "false",
        "reason": e.toString(),
        "userUid": user!.uid
      });
      setState(() {
        showPayView = false;
        load = false;
      });
      Helper.ShowToastMessage(getTranslated(context, "failed"), true);
      // showDialog(
      //     context: context,
      //     builder: (context) => ShowDialog(
      //       contentText: 'otherPay',
      //       noFunction: () {
      //         setState(() {
      //           load = false;
      //         });
      //         Navigator.pop(context);
      //       },
      //       yesFunction: () {
      //         Navigator.pop(context);
      //         setState(() {
      //           load = true;
      //           fromBalance = false;
      //         });
      //         stripePayment(
      //             amount: price,
      //             context: context);
      //         // pay();
      //       },
      //     ));
    }
  }

  Future<String> getDeviceType() async {
    String deviceType = 'Unknown';
    try {
      if (kIsWeb) {
        deviceType = 'Web';
      } else {
        if (Platform.isAndroid) {
          deviceType = 'Android';
        } else if (Platform.isIOS) {
          deviceType = 'iOS';
        }
      }
    } on PlatformException {
      deviceType = 'Unknown';
    }
    return deviceType;
  }

  updateDatabaseAfterAddingOrder(
      String? customerId, String payWith, String chargeId,
      {required double totalPrice}) async {
    String orderId = Uuid().v4();
    orderId2 = orderId;
    DateTime dateValue = DateTime.now();
    // dynamic callPrice = double.parse(amount.toString()) / package!.callNum;

    // dynamic callPrice = double.parse(price.toString()) / package!.callNum;
    dynamic callPrice = totalPrice / package!.callNum;
    await FirebaseFirestore.instance
        .collection(Paths.ordersPath)
        .doc(orderId)
        .set({
      'orderStatus': 'completed',
      'consultType': "jeras",
      'orderId': orderId,
      'chargeId': chargeId,
      'date': {
        'day': dateValue.day,
        'month': dateValue.month,
        'year': dateValue.year,
      },
      'utcTime': dateValue.toUtc().toString(),
      'orderTimestamp': Timestamp.now(),
      'deviceType': await getDeviceType(),
      'orderTimeValue': DateTime(dateValue.year, dateValue.month, dateValue.day)
          .millisecondsSinceEpoch,
      'packageId': package!.Id,
      'promoCodeId': promoCodeId,
      'remainingCallNum': package!.callNum,
      //(consultant.consultType=="perfect"||consultant.consultType=="jeras")?0:package.callNum,
      'packageCallNum': package!.callNum,
      'answeredCallNum': 0,
      'callPrice': callPrice,
      "payWith": payWith,
      "platform": kIsWeb
          ? "Web"
          : Platform.isIOS
              ? "iOS"
              : "Android",
      'price': (double.parse(price.toString()) +
              ((double.parse(price.toString()) * 5) / 100))
          .toString(),
      // 'price': callPrice,
      'consult': {
        'uid': consultant!.uid,
        'name': consultant!.name,
        'image': consultant!.photoUrl,
        'phone': consultant!.phoneNumber,
        'countryCode': consultant!.countryCode,
        'countryISOCode': consultant!.countryISOCode,
      },
      'user': {
        'uid': user!.uid,
        'name': user!.name,
        'image': user!.photoUrl,
        'phone': user!.phoneNumber,
        'countryCode': user!.countryCode,
        'countryISOCode': user!.countryISOCode,
      },
    });

    //update consult order numbers
    currentNumber = package!.callNum;
    // getNumber();

    print('==================app after add order');

    /// Add appointment.
    ///
    await addAppointment(
        date: _selectedDate!,
        loggedUser: user!,
        consultant: consultant!,
        orderId: orderId,
        currentNumber: currentNumber,
        selectedCard: _selectedDateCard,
        consultType: consultant!.consultType!,
        callPrice: callPrice,
        time: _time!,
        context: context,
        todayAppointmentList: _todayAppointmentList);

    print('===============app after put appointment');
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(consultant!.uid)
        .set({
      'openOrders': consultant!.openOrders + 1,
    }, SetOptions(merge: true));

    //update user order numbers
    if (user!.ordersNumbers == null || user!.ordersNumbers! < 1)
      await FirebaseFirestore.instance
          .collection(Paths.appAnalysisPath)
          .doc("TgWCp3B22sbkl0Nm3wLx")
          .set({
        'buyedMagadUsers': FieldValue.increment(1),
      }, SetOptions(merge: true));
    int userOrdersNumbers = 1;
    dynamic payedBalance = double.parse(price.toString());
    if (user!.ordersNumbers != null)
      userOrdersNumbers = user!.ordersNumbers! + 1;
    if (user!.payedBalance != null)
      payedBalance = user!.payedBalance + payedBalance;

    if (promo != null && promo!.type == "primary")
      user!.promoList!.add(promo!.promoCodeId);

    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(user!.uid)
        .set({
      'ordersNumbers': userOrdersNumbers,
      'payedBalance': payedBalance,
      'customerId': customerId,
      'preferredPaymentMethod': "tapCompany",
      'promoList': user!.promoList,
    }, SetOptions(merge: true));

    /**
     * APPS FLYER REWARD LOGIC
     */
    if (user?.userType != "CONSULTANT") {
      await AppFlyerService().updatePurchaseStatusOfUser(
        userId: user?.uid ?? '',
        amount: double.parse(price.toString()),
        orderId: orderId,
        payWith: payWith,
        percentage: '10%',
        purchasedAt: dateValue,
      );
    }
    /**
     *
     */

//======update number of use of promocode
    if (promo != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(promo!.promoCodeId)
          .get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      int usedNumber = data['usedNumber'];
      await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(promo!.promoCodeId)
          .set({
        'usedNumber': usedNumber + 1,
      }, SetOptions(merge: true));
    }

    //======update number of use of promocode
    if (promo != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(promo!.promoCodeId)
          .get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      int usedNumber = data['usedNumber'];
      await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(promo!.promoCodeId)
          .set({
        'usedNumber': usedNumber + 1,
      }, SetOptions(merge: true));
    }
    //--------add details event
    String eventName = "af_add_payment_info";
    Map eventValues = {
      "af_success": true,
      "af_achievement_id": "success",
    };
    addEvent(eventName, eventValues);
    await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
      "success": "true",
      "reason": "success",
      "userUid": user!.uid
    });
    //-----------
    eventName = "af_purchase";
    eventValues = {
      "af_revenue": price.toString(),
      "af_price": price.toString(),
      "af_content_id": consultant!.uid,
      "af_order_id": orderId,
      "af_currency": "USD",
    };
    addEvent(eventName, eventValues);

    //--------add details event

    /*addEvent(eventName, eventValues);
      await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
        "success": true,
        "reason": "success",
        "userUid": user!.uid
      });*/
    //-----------
    /* eventName = "af_purchase";
      eventValues = {
        "af_revenue": price.toString(),
        "af_price": price.toString(),
        "af_content_id": consultant!.uid,
        "af_order_id": orderId,
        "af_currency": "USD",
      };
      addEvent(eventName, eventValues);*/
    // showAddAppointmentDialog(orderId, callPrice, callNum);
  }

  Future<void> addAppointment({
    required DateTime date,
    required GroceryUser loggedUser,
    required GroceryUser consultant,
    required String orderId,
    required int currentNumber,
    required int selectedCard,
    required String consultType,
    required double callPrice,
    required String time,
    required BuildContext context,
    required List<dynamic> todayAppointmentList,
  }) async {
    try {
      date = date.toUtc();
      String appointmentId = Uuid().v4();
      print('==============app before set appointment');

      await FirebaseFirestore.instance
          .collection(Paths.appAppointments)
          .doc(appointmentId)
          .set({
        'appointmentId': appointmentId,
        'appointmentStatus': 'open',
        'consultType': consultType,
        'remainingCallNum': currentNumber,
        'type': 'valid',
        'lessonTime': 10,
        'allowCall': false,
        'timestamp': DateTime.now().toUtc(),
        'timeValue':
            DateTime(date.year, date.month, date.day).millisecondsSinceEpoch,
        'secondValue': DateTime(date.year, date.month, date.day, date.hour,
                date.minute, date.second, date.millisecond)
            .millisecondsSinceEpoch,
        'appointmentTimestamp': DateTime(date.year, date.month, date.day,
            date.hour, date.minute, date.second, date.millisecond),
        'utcTime': date.toString(),
        'consultChat': 0,
        'userChat': 0,
        'callCost': 0.0,
        'isUtc': true,
        'orderId': orderId,
        'callPrice': callPrice,
        'consult': {
          'uid': consultant.uid,
          'name': consultant.name,
          'image': consultant.photoUrl,
          'phone': consultant.phoneNumber,
          'countryCode': consultant.countryCode,
          'countryISOCode': consultant.countryISOCode,
        },
        'user': {
          'uid': user!.uid,
          'name': user!.name,
          'image': user!.photoUrl,
          'phone': user!.phoneNumber,
          'countryCode': user!.countryCode,
          'countryISOCode': user!.countryISOCode,
        },
        'date': {
          'day': date.day,
          'month': date.month,
          'year': date.year,
        },
        'time': {
          'hour': date.hour,
          'minute': date.minute,
        },
      });

      print('===========app after add appointment $appointmentId');
      print('===========order $orderId');
//========================
      todayAppointmentList.removeAt(selectedCard);
      await FirebaseFirestore.instance
          .collection(Paths.consultDaysPath)
          .doc(time + "-" + consultant.uid!)
          .set({
        'todayAppointmentList': todayAppointmentList,
      }, SetOptions(merge: true));
      setState(() {
        selectedCard = -1;
      });
      // Navigator.pop(context);
      showAddedAppointmentDialog(
          size: MediaQuery.of(context).size, date: date, context: context);
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
        'payUrl': '',
        'phone': user == null ? " " : user!.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "addAppointment",
      });
    }
  }

  updateDatabaseAfterAddingOrdertabweb(
    String? price,
    String? callPrice,
    String? promoCodeId,
  ) async {
    String orderId = Uuid().v4();
    orderId2 = orderId;
    DateTime dateValue = DateTime.now();
    await FirebaseFirestore.instance
        .collection(Paths.ordersPath)
        .doc(orderId)
        .set({
      'orderStatus': 'completed',
      'consultType': "jeras",
      'orderId': orderId,
      'chargeId': widget.tabid,
      'date': {
        'day': dateValue.day,
        'month': dateValue.month,
        'year': dateValue.year,
      },
      'utcTime': dateValue.toUtc().toString(),
      'orderTimestamp': Timestamp.now(),
      'deviceType': await getDeviceType(),
      'orderTimeValue': DateTime(dateValue.year, dateValue.month, dateValue.day)
          .millisecondsSinceEpoch,
      'packageId': package!.Id,
      'promoCodeId': promoCodeId,
      'remainingCallNum': package!.callNum,
      'packageCallNum': package!.callNum,
      'answeredCallNum': 0,
      'callPrice': double.parse(callPrice.toString()),
      "payWith": 'tapCompany',
      "platform": "Web",
      'price': price,
      'consult': {
        'uid': consultant!.uid,
        'name': consultant!.name,
        'image': consultant!.photoUrl,
        'phone': consultant!.phoneNumber,
        'countryCode': consultant!.countryCode,
        'countryISOCode': consultant!.countryISOCode,
      },
      'user': {
        'uid': user!.uid!,
        'name': user!.name,
        'image': user!.photoUrl,
        'phone': user!.phoneNumber,
        'countryCode': user!.countryCode,
        'countryISOCode': user!.countryISOCode,
      },
    });
    currentNumber = package!.callNum;
    //update consult order numbers
    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(consultant!.uid)
        .set({
      'openOrders': consultant!.openOrders + 1,
    }, SetOptions(merge: true));

    //update user order numbers
    if (user!.ordersNumbers == null || user!.ordersNumbers! < 1)
      await FirebaseFirestore.instance
          .collection(Paths.appAnalysisPath)
          .doc("TgWCp3B22sbkl0Nm3wLx")
          .set({
        'buyedMagadUsers': FieldValue.increment(1),
      }, SetOptions(merge: true));
    int userOrdersNumbers = 1;
    dynamic payedBalance = double.parse(price.toString());
    if (user!.ordersNumbers != null)
      userOrdersNumbers = user!.ordersNumbers! + 1;
    if (user!.payedBalance != null)
      payedBalance = user!.payedBalance + payedBalance;

    if (promo != null && promo!.type == "primary")
      user!.promoList!.add(promo!.promoCodeId);

    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(user!.uid)
        .set({
      'ordersNumbers': userOrdersNumbers,
      'payedBalance': payedBalance,
      'preferredPaymentMethod': "tapCompany",
      'promoList': user!.promoList,
    }, SetOptions(merge: true));

//======update number of use of promocode
    if (promo != null) {
      DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(promo!.promoCodeId)
          .get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;
      int usedNumber = data['usedNumber'];
      await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .doc(promo!.promoCodeId)
          .set({
        'usedNumber': usedNumber + 1,
      }, SetOptions(merge: true));
    }
    //--------add details event
    String eventName = "af_add_payment_info";
    Map eventValues = {
      "af_success": true,
      "af_achievement_id": "success",
    };
    addEvent(eventName, eventValues);
    await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
      "success": "true",
      "reason": "success",
      "userUid": user!.uid
    });
    //-----------
    eventName = "af_purchase";
    eventValues = {
      "af_revenue": price.toString(),
      "af_price": price.toString(),
      "af_content_id": consultant!.uid,
      "af_order_id": orderId,
      "af_currency": "USD",
    };
    addEvent(eventName, eventValues);
    // showAddAppointmentDialog(orderId, callPrice, callNum);
  }

  // showAddAppointmentDialog(
  //     String _orderId, dynamic callPrice, dynamic callNum) async {
  //   bool isProceeded = false;
  //   await showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) {
  //       return AddAppointmentDialog(
  //         loggedUser: user!,
  //         consultant: consultant!,
  //         package: package!,
  //         getData: getDataFromDialog,
  //         //callPrice: callPrice,
  //         //orderId: _orderId,
  //         localFrom: localFrom,
  //         localTo: localTo,
  //         //callNum: callNum,
  //         // currentNumber: (consultant!.consultType == "perfect" ||
  //         //         consultant!.consultType == "jeras")
  //         //     ? currentNumber
  //         //     : currentNumber - 1,
  //       );
  //     },
  //   );
  //   if (isProceeded) {
  //     // accountBloc.add(GetConsultInfoEvent(widget.consoltantId));
  //     setState(() {
  //       load = false;
  //     });
  //   }
  // }

  // showUserOrdersDialog() async {
  //   await showDialog(
  //     barrierDismissible: false,
  //     context: context,
  //     builder: (context) {
  //       return UserOrdersDialog(
  //         loggedUserUid: user!.uid!,
  //         consultUid: consultant!.uid!,
  //       );
  //     },
  //   );
  // }

  cleanConsultDays() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.consultDaysPath)
          .where('date',
              isLessThan: DateTime(DateTime.now().year, DateTime.now().month,
                      DateTime.now().day)
                  .millisecondsSinceEpoch)
          .where('consultUid', isEqualTo: widget.consoltantId)
          .get();
      for (var doc in querySnapshot.docs) {
        await FirebaseFirestore.instance
            .collection(Paths.consultDaysPath)
            .doc(doc.id)
            .delete();
      }
    } catch (e) {}
  }

  Widget registerWidget() {
    lang = getTranslated(context, "lang");

    return ResponsiveLayout(
      desktop: InkWell(
        onTap: () async {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h70.h
                  : 50.6.h,
              //width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 531.w : 50.6.w,
              padding: EdgeInsets.only(
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w21.w
                      : 3.4,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w21.w
                      : 10),
              decoration: BoxDecoration(
                color: AppColors.grey4,
                borderRadius: BorderRadius.circular(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppRadius.r10.r
                        : 5.r),
                boxShadow: [shadow()],
              ),
              child: Row(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        AssetsManager.remainOrder,
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h26.h
                                : AppSize.w16_6.w,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h20.h
                                : AppSize.h13.h,
                      ),
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w11_3.w
                                  : AppSize.w5.w),
                      Text(
                        getTranslated(context, 'remain') + ' ',
                        style: TextStyle(
                          color: AppColors.black2,
                          fontWeight: AppFontsWeightManager.bold100,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 22.sp
                                  : 14.sp,
                        ),
                      ),
                      Text(
                        (5 - consultant!.openOrders).toString() + " ",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: AppFontsWeightManager.bold100,
                          fontFamily: getTranslated(context, "Montserrat"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 22.sp
                                  : 14.sp,
                        ),
                      ),
                      Text(
                        getTranslated(context, 'cunsoltantStudents'),
                        style: TextStyle(
                          color: AppColors.black2,
                          fontWeight: AppFontsWeightManager.bold100,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s22.sp
                                  : AppFontsSizeManager.s14.sp,
                        ),
                      ),
                    ],
                  ),
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? SizedBox()
                      : SizedBox(
                          width: AppSize.w81.w,
                        ),
                  (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? SizedBox()
                      : TextButton1(
                          onPress: () {},
                          Padding2: AppPadding.p10.w,
                          Title: getTranslated(context, "confirmNow"),
                          Height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h42.h
                                  : AppSize.h40.h,
                          ButtonRadius:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r4.r
                                  : AppRadius.r4.r,
                          TextSize: kIsWeb ||
                                  (MediaQuery.of(context).size.width >= 500)
                              ? AppFontsSizeManager.s22.sp
                              : AppFontsSizeManager.s13.sp,
                          TextFont: getTranslated(context, "Ithra"),
                          TextColor: AppColors.white,
                          ButtonBackground: AppColors.primaryColor,
                          BoxShadow1: [shadow()],
                        ),
                ],
              ),
            ),
            Row(
              children: [
                SizedBox(
                  width: AppSize.w14.w,
                ),
                TextButton1(
                  onPress: () {},
                  Padding2: AppPadding.p10.w,
                  Title: getTranslated(context, "confirmNow"),
                  Width: AppSize.w123.w,
                  Height: AppSize.h63.h,
                  ButtonRadius: AppRadius.r10.r,
                  TextSize: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                      ? AppFontsSizeManager.s21.sp
                      : AppFontsSizeManager.s13.sp,
                  TextFont: getTranslated(context, "Ithra"),
                  TextColor: AppColors.white,
                  ButtonBackground: AppColors.red1,
                  BoxShadow1: [shadow()],
                ),
              ],
            )
          ],
        ),
      ),
      mobile: InkWell(
        onTap: () async {
          _scrollController.jumpTo(_scrollController.position.maxScrollExtent);
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 63.h
                  : AppSize.h60.h,
              width: lang == "ar" ? 390.w : 450.w,
              padding: EdgeInsets.only(
                  left: 3.4,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? 10.r
                      : 0),
              decoration: BoxDecoration(
                color: AppColors.grey4,
                borderRadius: BorderRadius.circular(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 10.r
                        : 5.r),
                boxShadow: [shadow()],
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Image.asset(
                        AssetsManager.remainOrder,
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 20.w
                                : AppSize.w33.w,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 20.h
                                : AppSize.h33.h,
                      ),
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 5.w
                                  : AppSize.w16.w),
                      Text(
                        getTranslated(context, 'remain') + ' ',
                        style: TextStyle(
                          color: AppColors.black2,
                          fontWeight: AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 22.sp
                                  : 16.sp,
                        ),
                      ),
                      Text(
                        (5 - consultant!.openOrders).round().toString() + " ",
                        style: TextStyle(
                          color: Theme.of(context).primaryColor,
                          fontWeight: FontWeight.w400,
                          fontFamily: getTranslated(context, "Montserrat"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 22.sp
                                  : 18.sp,
                        ),
                      ),
                      Text(
                        getTranslated(context, 'cunsoltantStudents'),
                        style: TextStyle(
                          color: AppColors.black2,
                          fontWeight: AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 22.sp
                                  : 16.sp,
                        ),
                      ),
                    ],
                  ),
                  TextButton1(
                    onPress: () {
                      scrollToFooter();
                    },
                    Padding2: 14.r,
                    Title: getTranslated(context, "confirmNow"),
                    Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h63_5.h
                        : AppSize.h40.h,
                    Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? null
                        : AppSize.w101_3.w,
                    ButtonRadius:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r10.r
                            : AppRadius.r5_3.r,
                    TextSize:
                        kIsWeb || (MediaQuery.of(context).size.width >= 500)
                            ? AppFontsSizeManager.s21.sp
                            : AppFontsSizeManager.s16.sp,
                    TextFont: getTranslated(context, "Ithra"),
                    TextColor: AppColors.white,
                    ButtonBackground: AppColors.primaryColor,
                    BoxShadow1: [shadow()],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget chatButton() {
    Chat chatItem;
    return InkWell(
      onTap: () async {
        if (user != null) {
          setState(() {
            chating = true;
          });
          QuerySnapshot querySnapshot = await FirebaseFirestore.instance
              .collection("Chat")
              .where(
                'user.uid',
                isEqualTo: user!.uid,
              )
              .where(
                'consult.uid',
                isEqualTo: consultant!.uid,
              )
              .limit(1)
              .get();
          // select or creat chat
          if (querySnapshot.docs.length != 0) {
            chatItem = Chat.fromMap(querySnapshot.docs[0].data() as Map);
          } else {
            //create chat
            String chatId = Uuid().v4();
            await FirebaseFirestore.instance
                .collection("Chat")
                .doc(chatId)
                .set({
              'chatId': chatId,
              'chatStatus': false,
              'messageTime': FieldValue.serverTimestamp(),
              'owner': "USER",
              'consult': {
                'uid': consultant!.uid,
                'name': consultant!.name,
                'image': consultant!.photoUrl,
                'phone': consultant!.phoneNumber,
                'countryCode': consultant!.countryCode,
                'countryISOCode': consultant!.countryISOCode,
              },
              'user': {
                'uid': user!.uid,
                'name': user!.name,
                'image': user!.photoUrl,
                'phone': user!.phoneNumber,
                'countryCode': user!.countryCode,
                'countryISOCode': user!.countryISOCode,
              },
              'userMessageNum': 0,
              'consultMessageNum': 0,
              'lastMessage': " ",
            });

            var documentSnapshot = await FirebaseFirestore.instance
                .collection("Chat")
                .doc(chatId)
                .get();
            chatItem = Chat.fromMap(documentSnapshot.data() as Map);
          }
          setState(() {
            chating = false;
          });
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => ChatDetailScreen(
                item: chatItem,
                user: user!,
                theme: 'light',
              ),
            ),
          );
        } else {
          setState(() {
            chating = false;
          });
          Navigator.pushNamed(context, '/Register_Type');
        }
      },
      child: Container(
        height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppSize.h62.h
            : AppSize.h60.h,
        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppSize.w318.w
            : AppSize.w390.w,
        padding:
            EdgeInsets.only(left: AppPadding.p10.w, right: AppPadding.p10.w),
        decoration: BoxDecoration(
          color: AppColors.primaryColor,
          borderRadius: BorderRadius.circular(
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppRadius.r10.r
                  : AppRadius.r10_6.r),
          boxShadow: [shadow()],
        ),
        child: Center(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Container(
                child: SvgPicture.asset(
                  AssetsManager.whiteChatIconPath,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w16_6.r
                      : AppSize.w24.r,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w16_6.r
                      : AppSize.w24.r,
                ),
              ),
              SizedBox(
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w10_5
                    : AppSize.w15.w,
              ),
              TextDefaultWidget(
                title: getTranslated(context, "freeChat"),
                fontFamily: getTranslated(context, "Ithra"),
                fontWeight: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                    ? AppFontsWeightManager.normal
                    : AppFontsWeightManager.bold300,
                fontSize: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                    ? AppFontsSizeManager.s17.sp
                    : AppFontsSizeManager.s21_3.sp,
                color: AppColors.white,
              ),
            ],
          ),
        ),
      ),
    );
  }

  changeTypeDialog(Size size) {
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
        content: StatefulBuilder(
          builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                SizedBox(
                  height: AppSize.h15.h,
                ),
                Center(
                  child: Text(
                    getTranslated(context, "attention"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s14.sp,
                      fontWeight: AppFontsWeightManager.bold300,
                      color: AppColors.white,
                    ),
                  ),
                ),
                SizedBox(
                  height: AppSize.h15.h,
                ),
                Text(
                  getTranslated(context, "confirmChangeType"),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s14.sp,
                    fontWeight: AppFontsWeightManager.bold300,
                    color: AppColors.black,
                  ),
                ),
                SizedBox(
                  height: AppSize.h15.h,
                ),
                Padding(
                  padding: const EdgeInsets.all(AppPadding.p15),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          Navigator.pop(context);
                        },
                        child: Container(
                          height: AppSize.h35.h,
                          width: AppSize.w50.w,
                          padding: const EdgeInsets.all(AppPadding.p2),
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "no"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.black,
                                  fontSize: AppFontsSizeManager.s11.sp,
                                  fontWeight: FontWeight.w500),
                            ),
                          ),
                        ),
                      ),
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => UserAccountScreen(
                                  user: user!, firstLogged: false),
                            ),
                          );
                        },
                        child: Container(
                          height: AppSize.h35.h,
                          width: AppSize.w50.w,
                          padding: const EdgeInsets.all(AppPadding.p2),
                          decoration: BoxDecoration(
                            color: AppColors.lightPink,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "yes"),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                color: Colors.black,
                                fontSize: AppFontsSizeManager.s11.sp,
                                fontWeight: AppFontsWeightManager.bold500,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            );
          },
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}

class WrappedCard extends StatefulWidget {
  const WrappedCard(
      {super.key,
      required this.builder,
      required this.length,
      required this.onSelectItem});

  final int length;

  final Widget Function(BuildContext context, int index) builder;

  final Function(int index) onSelectItem;

  @override
  State<WrappedCard> createState() => _WrappedCardState();
}

class _WrappedCardState extends State<WrappedCard> {
  int _selectedIndex = -1;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Wrap(
      alignment: WrapAlignment.center,
      children: [
        for (int index = 0; index < widget.length; index++)
          InkWell(
            onTap: () {
              widget.onSelectItem(index);
              _selectedIndex = index;
              setState(() {});
            },
            child: Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 249.r
                  : 129.r,
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? 258.r
                  : 133.r,
              margin: EdgeInsets.symmetric(
                  horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? 30
                      : 10,
                  vertical: 5),

              decoration: BoxDecoration(
                color: AppColors.white,
                borderRadius: BorderRadius.circular(
                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 8 : 8),
                border: Border.all(
                    color: _selectedIndex == index
                        ? Colors.transparent
                        : Color.fromRGBO(123, 108, 150, 1),
                    width: .5.w),
                boxShadow: [
                  if (_selectedIndex == index)
                    BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.15),
                        offset: Offset(0, 4),
                        blurRadius: 19,
                        spreadRadius: 0)
                ],
              ),
              child: Stack(
                children: [
                  widget.builder(context, index),
                  if (_selectedIndex == index)
                    Positioned(
                      child: Container(
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Theme.of(context).primaryColor,
                        ),
                        child: Icon(
                          Icons.check,
                          size: AppSize.w15,
                          color: AppColors.white,
                        ),
                      ),
                    ),
                ],
              ),
              // Column(
              //   mainAxisAlignment: MainAxisAlignment.spaceBetween,
              //   children: [

              // Container(
              //   width: size.width * .41,
              //   child: Text(
              //     callsValue, //index==0?getTranslated(context, "oneCall"):callsValue,
              //     style: TextStyle(
              //       fontFamily: getTranslated(context, "Ithra"),
              //       color: _selectedIndex == index
              //           ? AppColors.pink
              //           : AppColors.grey,
              //       fontSize: AppFontsSizeManager.s13,
              //       fontWeight: AppFontsWeightManager.bold500,
              //     ),
              //   ),
              // ),
              // Container(
              //   height: 40,
              //   width: size.width * .3,
              //   padding: const EdgeInsets.all(5),
              //   decoration: BoxDecoration(
              //     //color: Theme.of(context).primaryColor,
              //     borderRadius: BorderRadius.circular(25.0),
              //   ),
              //   child: Center(
              //     child: Text(
              //       packages[index].price.toString() + "\$",
              //       style: TextStyle(
              //         fontFamily: getTranslated(context, "Ithra"),
              //         color: _selectedIndex == index
              //             ? AppColors.pink
              //             : AppColors.grey,
              //         fontSize: AppFontsSizeManager.s13,
              //         fontWeight: FontWeight.normal,
              //         letterSpacing: AppConstants.letterSpacing0_5,
              //       ),
              //     ),
              //   ),
              // )

              //   ],
              // ),
            ),
          ),
      ],
    );
  }
}

class _ReadMoreText extends StatefulWidget {
  const _ReadMoreText({
    required this.consultant,
  });

  final GroceryUser consultant;

  @override
  State<_ReadMoreText> createState() => _ReadMoreTextState();
}

class _ReadMoreTextState extends State<_ReadMoreText> {
  bool _isExpanded = false;

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: kIsWeb || (MediaQuery.of(context).size.width >= 500)
          ? CrossAxisAlignment.start
          : CrossAxisAlignment.center,
      children: [
        Text(
          !_isExpanded
              ? getTranslated(context, "lang") == "ar"
                  ? (widget.consultant.bio!.substring(
                      0,
                      widget.consultant.bio!.length < 100
                          ? widget.consultant.bio!.length
                          : 100))
                  : widget.consultant.bioEn!.substring(
                      0,
                      widget.consultant.bioEn!.length < 100
                          ? widget.consultant.bioEn!.length
                          : 100)
              : getTranslated(context, "lang") == "ar"
                  ? widget.consultant.bio!
                  : widget.consultant.bioEn!,
          maxLines: _isExpanded ? 1000 : 3,
          textAlign: kIsWeb || (MediaQuery.of(context).size.width >= 500)
              ? TextAlign.start
              : TextAlign.center,
          overflow: TextOverflow.ellipsis,
          style: TextStyle(
            fontFamily: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                ? getTranslated(context, "Ithralight")
                : getTranslated(context, "Ithra"),
            fontWeight: AppFontsWeightManager.bold300,
            fontSize: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                ? 26.sp
                : 17.0.sp,
            color: AppColors.textLightGrey,
          ),
        ),
        IconButton(
          onPressed: () {
            setState(() {
              _isExpanded = !_isExpanded;
            });
          },
          icon: Transform.rotate(
            angle: _isExpanded ? pi : 0,
            child: SvgPicture.asset(
              AssetsManager.downIconPath,
              height: AppSize.h25.h,
              width: AppSize.w20.w,
            ),
          ),
        ),
      ],
    );
  }
}

showAddedAppointmentDialog(
    {required Size size,
    required DateTime date,
    required BuildContext context}) {
  return showDialog(
    builder: (context) => JerasDialogWidget(
      dialogContent: Column(
        children: <Widget>[
          Column(
            children: [
              SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h62.h
                      : AppSize.h4_6.h),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppPadding.p173.w
                            : 0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "confirm"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s40.sp
                                : AppFontsSizeManager.s21_3.sp,
                        color: AppColors.linear2,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    SizedBox(
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w32.w
                          : AppSize.w13_3.w,
                    ),
                    SvgPicture.asset(
                      AssetsManager.roundCheckIconPath,
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h44.h
                          : AppSize.h26_6.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w44.w
                          : AppSize.w26_6.w,
                    ),
                  ],
                ),
              ),
              SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h54_4.h
                      : AppSize.h21_3.h),
              Padding(
                padding: EdgeInsets.only(
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p144.w
                        : AppPadding.p32.w,
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p144.w
                        : 0),
                child: Row(
                  children: [
                    Text(
                      getTranslated(context, "theAppointment") + ": ",
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : AppFontsSizeManager.s18_6.sp,
                      ),
                    ),
                    Text(
                      // date.toString(),
                      // DateTime.parse(date.toString()).toLocal().toString(),
                      '${new DateFormat('MMM d, h:mm a').format(DateTime.parse(date.toString()).toLocal())}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithralight'),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s32.sp
                                : AppFontsSizeManager.s18_6.sp,
                        color:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppColors.black
                                : AppColors.linear2,
                        fontStyle: FontStyle.normal,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h64.h
                    : AppSize.h32.h,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppPadding.p32.w
                            : 0),
                child: Row(
                  children: [
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.push(
                              context,
                              MaterialPageRoute(
                                  builder: (context) => AppointmentsPage()));
                        },
                        child: Container(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w320.w
                                  : AppSize.w132.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h90.h
                                  : AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.linear2,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, "navigateToAppointment"),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s18_6.sp,
                                color: AppColors.white,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: (size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w70_5.w
                          : AppSize.w25.w,
                    ),
                    Expanded(
                      child: InkWell(
                        onTap: () {
                          Navigator.pop(context);
                          Navigator.pop(context, true);
                        },
                        child: Container(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w320.w
                                  : AppSize.w132.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h90.h
                                  : AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.white,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                            border: Border.all(
                              color: AppColors.linear2,
                            ),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'Ok'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, 'Ithra'),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : AppFontsSizeManager.s18_6.sp,
                                color: AppColors.linear2,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h74.h
                    : 0,
              )
            ],
          ),
        ],
      ),
    ),
    barrierDismissible: false,
    context: context,
  );
}
