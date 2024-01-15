import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:jeras/Utils/opentab.dart'
    if (dart.library.html) 'package:jeras/Utils/opentabWeb.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/TabButton.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/component/TextButton.dart';
import 'package:jeras/widget/component/tab_bar/custom_tab_bar.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../models/userPaymentHistory.dart';
import '../../widget/userPaymentHistoryListItem.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../Utils/helper.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';

class WalletScreen extends StatefulWidget {
  final GroceryUser? loggedUser;
  final String? tabid;
  final String? paydata;

  const WalletScreen({Key? key, this.loggedUser, this.tabid, this.paydata})
      : super(key: key);

  @override
  _WalletScreenState createState() => _WalletScreenState();
}

class _WalletScreenState extends State<WalletScreen>
    with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  late GroceryUser user;
  late Size size;
  bool load = false, showBalance = true, showHistory = false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false, showPayView = false;
  late GroceryUser searchUser;
  List<GroceryUser> users = [];
  late String to, amount, balance, theme = "light";
  int? _stackIndex;
  String initialUrl = '';
  String lang = '';

  @override
  void initState() {
    super.initState();
    _stackIndex = 1;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    accountBloc.stream.listen((state) {
      if (state is GetLoggedUserCompletedState) {
        user = state.user;
        if (mounted)
          setState(() {
            load = false;
          });
        if (user.photoUrl != "") if (mounted)
          setState(() {
            balance = user.balance.toString();
          });
      }
    });
    if (kIsWeb) {
      if (widget.tabid != null && widget.tabid!.isNotEmpty) {
        //&&widget.paydata!=null&&widget.paydata!.isNotEmpty){
        checkwithTab();
      }
    }
  }

  checkwithTab() async {
    FirebaseFunctions functions = FirebaseFunctions.instance;
    HttpsCallable callable = functions.httpsCallable("checkWithTab");
    final res =
        await callable.call({'tabid': widget.tabid, "tabdata": widget.paydata});

    if (res.data['status'] == "CAPTURED") {
      String? customerId = res.data['metadata']['customerId'];
      customerId = customerId != null ? customerId : "";

      FirebaseFirestore.instance
          .collection("Users")
          .doc(res.data['metadata']['consultUid'])
          .get()
          .then((value) {
        searchUser = GroceryUser.fromMap(value.data() as Map);

        FirebaseFirestore.instance
            .collection("Users")
            .doc(res.data['metadata']['userUid'])
            .get()
            .then((value) {
          user = GroceryUser.fromMap(value.data() as Map);

          updateDatabaseAfterAddingOrder(res.data['metadata']['userUid'],
              "tapCompany", ".", res.data['metadata']['price']);
        });
      });
      // package= consultPackage.fromHashMap(json.decode( res.data['metadata']['package']));
    } else {
      //callHuperPayWidget
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
        'phone': user == null ? " " : user.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "payStatus",
      });
      setState(() {
        //    showPayView = false;
        //   load = false;
      });
      Helper.ShowToastMessage(getTranslated(context, "failed"), true);
    }
    return res.data;
  }

  paywithTab() async {
    FirebaseFunctions functions = FirebaseFunctions.instance;
    HttpsCallable callable = functions.httpsCallable("payWithTab");
    final res = await callable.call({
      'tabid': widget.tabid,
      'price': amount,
      'packageId': null,
      'promoCodeId': null,
      'callPrice': 0,
      'userUid': user.uid,
      'consultUid': searchUser.uid,
      'userName': user.name,
      'paytype': 'wallet',
      'phoneNumber': user.phoneNumber,
      'description': "charge my wallet",
      'consultid': searchUser.uid,

      /* 'price':amount,
      'description':"charge my wallet",
      'customerId':user.uid,
      'userName':user.name,
      'paytype':'wallet',
      'phoneNumber':user.phoneNumber,
      'metadata':json.encode(<String,dynamic>{
        "putBalanceUserId":searchUser.uid
      })*/
      // 'consultid':widget.consoltantId,
      // 'package':json.encode( package?.tomap())
    });

    openTab.goPaymentPage(
        [res.data['transaction']['url'], '_self']); //<= find explanation below

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
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      backgroundColor: AppColors.white,
      body: Stack(children: <Widget>[
        Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p140.w
                          : AppPadding.p32.w,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p140.w
                          : AppPadding.p32.w,
                      top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p58.h
                          : AppPadding.p10,
                      bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p41.h
                          : AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      // import 'package:jeras/widget/custom_back_button.dart';
                    CustomBackButton(),
                    
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w34.w
                                  : AppSize.w21_3.w),
                      Text(
                        getTranslated(context, "wallet"),
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
                    color: AppColors.lightGrey,
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h0_1.h
                        : AppSize.h2.h,
                    width: size.width)),
            //walletdata
            Expanded(
              child: ListView(
                padding: EdgeInsets.only(
                  top: AppPadding.p21_3.h,
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppPadding.p279.w
                      : AppPadding.p32.w,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppPadding.p279.w
                      : AppPadding.p32.w,
                ),
                children: [
                  Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h268_3.h
                          : AppSize.h167_2.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w200.w
                          : AppSize.w124.w,
                      child: SvgPicture.asset(
                        AssetsManager.walletIconPath,
                      )),
                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h32.h
                        : AppSize.h42_6.h,
                  ),


                  //title
                  Padding(
                    padding: EdgeInsets.symmetric(
                        horizontal: size.width >= 500 ? AppPadding.p296.w : 0),
                    child: Text(
                      getTranslated(context, "addBalanceText"),
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 6,
                      style: TextStyle(
                          color: AppColors.black1,
                          fontWeight: AppFontsWeightManager.bold300,
                          fontFamily: size.width >= 500
                              ? getTranslated(context, "Ithralight")
                              : getTranslated(context, "Ithralight"),
                          fontStyle: FontStyle.normal,
                          fontSize: size.width >= 500
                              ? AppFontsSizeManager.s32.sp
                              : AppFontsSizeManager.s21_3.sp),
                    ),
                  ),

                  SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.h39.h
                        : AppSize.h32_6.h,
                  ),
                  //button slider
                  CustomTabBar(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h120.h
                          : AppSize.h58_6.h,
                      radius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppRadius.r32.r
                          : AppRadius.r16.r,
                      backgroundColor: AppColors.linear7,
                      buttons: [
                        //button x
                        TabButton(
                            onPress: () {
                              setState(() {
                                showBalance = true;
                                showHistory = false;
                              });
                            },
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w284.w
                                : AppSize.w233.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h85.h
                                : AppSize.h44.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r10.r
                                : AppRadius.r10_6.r,
                            ButtonColor: showBalance
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            Title: getTranslated(context, "addBalance"),
                            TextFont: size.width >= 500
                                ? getTranslated(context, "Ithra")
                                : getTranslated(context, "Ithra"),
                            TextSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s36.sp
                                : AppFontsSizeManager.s21_3.sp,
                            TextColor: showBalance
                                ? AppColors.white
                                : Theme.of(context).primaryColor),
                        // SizedBox(
                        //   width:
                        //       (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        //           ? AppSize.w286.w
                        //           : AppSize.w5.w,
                        // ),
                        //button y
                        TabButton(
                            onPress: () {
                              setState(() {
                                showHistory = true;
                                showBalance = false;
                              });
                            },
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w295.w
                                : AppSize.w233.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h85.h
                                : AppSize.h44.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r10.r
                                : AppRadius.r10_6.r,
                            ButtonColor: showHistory
                                ? Theme.of(context).primaryColor
                                : Colors.transparent,
                            Title: getTranslated(context, "paymentHistory"),
                            TextFont: size.width >= 500
                                ? getTranslated(context, "Ithra")
                                : getTranslated(context, "Ithra"),
                            TextSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s36.sp
                                : AppFontsSizeManager.s21_3.sp,
                            TextColor: showHistory
                                ? AppColors.white
                                : Theme.of(context).primaryColor),
                      ],
                      padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppPadding.p143.w
                            : AppPadding.p10_6.w,
                        right:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p143.w
                                : AppPadding.p10_6.w,
                      )),

                  showBalance ? balanceWidget(size) : SizedBox(),
                  showHistory ? historyWidget(size) : SizedBox(),
                ],
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
                      WebView(
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

  balanceWidget(Size size) {
    return Form(
      key: _formKey,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h56.h
                : AppSize.h32.h,
          ),
          //from

          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, "to"),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.normal,
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s32.sp
                      : AppFontsSizeManager.s21_3.sp,
                ),
              ),
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h32.h
                    : AppSize.h10_6.h,
              ),
              TextFormField(
                textAlign: TextAlign.start,
                validator: (String? val) {
                  if (val!.trim().isEmpty) {
                    return getTranslated(context, 'required');
                  }
                  return null;
                },
                onSaved: (val) {
                  to = val!;
                },
                enableInteractiveSelection: true,
                style: TextStyle(
                  color: AppColors.darkGrey4,
                  fontWeight: AppFontsWeightManager.bold300,
                  fontFamily: getTranslated(context, "Ithralight"),
                  fontStyle: FontStyle.normal,
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s32.sp
                      : AppFontsSizeManager.s21_3.sp,
                ),
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.phone,
                decoration: InputDecoration(
                  prefixIcon: Image.asset(
                    AssetsManager.phoneIcon,
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w48.w
                        : AppSize.h26.h,
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w48.w
                        : AppSize.w26.w,
                    color: AppColors.primaryColor,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p32.w
                              : AppPadding.p15.w,
                      vertical:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p28_5.h
                              : AppPadding.p5.h),
                  helperStyle: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.65),
                    fontWeight: AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  errorStyle: GoogleFonts.poppins(
                    fontSize:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s23.sp
                            : AppFontsSizeManager.s18_6.sp,
                    fontWeight: AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  hintStyle: TextStyle(
                    color: AppColors.darkGrey4,
                    fontWeight: AppFontsWeightManager.bold300,
                    fontFamily: getTranslated(context, "Ithralight"),
                    fontStyle: FontStyle.normal,
                    fontSize:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s24.sp
                            : AppFontsSizeManager.s21_3.sp,
                  ),
                  hintText: getTranslated(context, "enterPhone"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r10_6
                            : AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r10_6
                            : AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r10_6
                            : AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r10_6
                            : AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h54.h
                : AppSize.h21_3.h,
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                getTranslated(context, "amount"),
                textAlign: TextAlign.start,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithra"),
                  color: AppColors.primaryColor,
                  fontWeight: FontWeight.normal,
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s32.sp
                      : AppFontsSizeManager.s21_3.sp,
                ),
              ),
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h32.h
                    : AppSize.h10_6.h,
              ),
              TextFormField(
                textAlign: TextAlign.start,
                validator: (String? val) {
                  if (val!.trim().isEmpty) {
                    return getTranslated(context, 'required');
                  }
                  return null;
                },
                onSaved: (val) {
                  amount = val!;
                },
                enableInteractiveSelection: true,
                style: TextStyle(
                  color: AppColors.darkGrey4,
                  fontWeight: AppFontsWeightManager.bold300,
                  fontFamily: getTranslated(context, "Ithralight"),
                  fontStyle: FontStyle.normal,
                  fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppFontsSizeManager.s32.sp
                      : AppFontsSizeManager.s21_3.sp,
                ),
                minLines: 1,
                maxLines: 3,
                textInputAction: TextInputAction.done,
                keyboardType: TextInputType.number,
                textCapitalization: TextCapitalization.sentences,
                decoration: InputDecoration(
                  prefixIcon: Image.asset(
                    AssetsManager.moneySign,
                    width: (kIsWeb ||
                        size.width >=
                            AppConstants.kIsWebValue)
                        ? AppSize.w69_9.w
                        : AppSize.w26_6.w,
                    height: (kIsWeb ||
                        size.width >=
                            AppConstants.kIsWebValue)
                        ? AppSize.h63_4.h
                        : AppSize.h26_6.h,
                  ),
                  contentPadding: EdgeInsets.symmetric(
                      horizontal:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p28.h
                              : 15.0.w,
                      vertical:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p28_5.h
                              : AppPadding.p5.h),
                  helperStyle: GoogleFonts.poppins(
                    color: Colors.black.withOpacity(0.65),
                    fontWeight: AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  errorStyle: GoogleFonts.poppins(
                    fontSize:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s23.sp
                            : AppFontsSizeManager.s18_6.sp,
                    fontWeight: AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  hintStyle: TextStyle(
                    color: AppColors.darkGrey4,
                    fontWeight: AppFontsWeightManager.bold300,
                    fontFamily: getTranslated(context, "Ithralight"),
                    fontStyle: FontStyle.normal,
                    fontSize:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s32.sp
                            : AppFontsSizeManager.s21_3.sp,
                  ),
                  hintText: getTranslated(context, "enterAmount"),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r10_6
                            : AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                  errorBorder: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r12.r),
                    borderSide: BorderSide(color: AppColors.borderLightGrey),
                  ),
                ),
              ),
            ],
          ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h64.h
                : AppSize.h42_6.h,
          ),
          //done
          saving
              ? Center(child: CircularProgressIndicator())
              : Center(
                  child: TextButton1(
                      IconWidth: AppSize.w17_3.w,
                      IconHeight: AppSize.h21_6.h,
                      onPress: save,
                      Title: getTranslated(context, "addBalance"),
                      TextFont: getTranslated(context, "Ithra"),
                      TextSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s36.sp
                              : AppFontsSizeManager.s21_3.sp,
                      IconColor: AppColors.white,
                      TextColor: AppColors.white,
                      Height:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppSize.h100.h
                              : AppSize.h66_6.h,
                      ButtonRadius:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppRadius.r24.r
                              : AppRadius.r16.r,
                      GradientColor: AppColors.linear2,
                      GradientColor2: AppColors.linear1,
                      IconSpace:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppSize.w12.w
                              : AppSize.w16.w,
                      Icon: AssetsManager.whiteDownloadIconPath,
                      Direction: TextDirection.rtl,
                      Padding: AppPadding.p10_6.h,
                      Padding2: AppPadding.p16.w),
                ),
          SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h35.h
                : AppSize.h25.h,
          ),
        ],
      ),
    );
  }

  historyWidget(Size size) {
    return Column(
      children: [
        SizedBox(
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h56.h
              : 0,
          //AppSize.h37_3.h,
        ),
        PaginateFirestore(
          itemBuilderType: PaginateBuilderType.listView,
          shrinkWrap: true,
          separator: SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h40.h
                : AppSize.h21_3.h,
          ),
          physics: NeverScrollableScrollPhysics(),
          padding: EdgeInsets.only(

              bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p16.h
                  : AppPadding.p16.h,
              top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p16.h
                  : AppPadding.p37_3.h),
          //Change types accordingly
          itemBuilder: (context, documentSnapshot, index) {
            return UserPaymentHistoryListItem(
                history: UserPaymentHistory.fromMap(
                    documentSnapshot[index].data() as Map),
                theme: theme);
          },
          query: FirebaseFirestore.instance
              .collection(Paths.userPaymentHistory)
              .where('userUid', isEqualTo: widget.loggedUser!.uid)
              .orderBy('payDateValue', descending: true),
          isLive: true,
        ),
      ],
    );
  }

  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          saving = true;
        });
        //get userdata
        QuerySnapshot querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .where(
              'phoneNumber',
              isEqualTo: to,
            )
            .where(
              'userType',
              isEqualTo: "USER",
            )
            .get();

        for (var doc in querySnapshot.docs) {
          users.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if (users.length > 0) {
          setState(() {
            searchUser = users[0];
          });
          showAddingBalanceDialoge(
              size,
              getTranslated(context, "balanceTransfer"),
              getTranslated(context, "SureTransferAmount"));
        } else {
          cantAddingDialog(MediaQuery.of(context).size,
              getTranslated(context, "invalidNumbers"), false);
          setState(() {
            saving = false;
          });

          /*addingDialog(MediaQuery.of(context).size,
              getTranslated(context, "noUser"), false);
          setState(() {
            saving = false;
          });*/
        }
      } catch (e) {}
    }
  }

  cantAddingDialog(Size size, String data, bool status) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r21_3.r),
          ),
        ),
        elevation: 5.0,
        contentPadding: EdgeInsets.only(
            left: AppPadding.p21_3.w,
            right: AppPadding.p21_3.w,
            top: AppPadding.p26_5.h,
            bottom: AppPadding.p26_5.h),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              data,
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithralight'),
                fontSize: AppFontsSizeManager.s20_6.sp,
                color: AppColors.black4,
                letterSpacing: AppConstants.letterSpacing0_3,
                fontWeight: AppFontsWeightManager.bold300,
                fontStyle: FontStyle.normal,
              ),
              textAlign: TextAlign.center,
            ),
            SizedBox(
              height: AppSize.h25,
            ),
            Center(
              child: Container(
                width: AppSize.w312.w,
                height: AppSize.h56.h,
                //   alignment: Alignment.center,
                decoration: BoxDecoration(
                  color: AppColors.linear2,
                  borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                ),
                child: InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: Center(
                    child: Text(
                      getTranslated(context, 'Ok'),
                      style: TextStyle(
                        fontFamily: getTranslated(context, 'Ithra'),
                        fontSize: AppFontsSizeManager.s18_6.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
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

  addingDialog(Size size, String data, bool status) {
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
            SizedBox(
              height: AppSize.h5.h,
            ),
            Text(
              data,
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s15.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h40.h
                  : AppSize.h5.h,
            ),
            Center(
              child: Container(
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.width * AppSize.w0_1.w
                    : size.width * AppSize.w0_5.w,
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

  showAddingBalanceDialoge(Size size, String title, String msg) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(top: AppSize.h4_6.h, right: AppSize.w10_6.w),
              child: Column(
                children: [
                  Text(
                    title,
                    //getTranslated(context, "balanceTransfer"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s32.sp,
                      color: AppColors.linear2,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h36_6.h,
                  ),
                  Text(
                    // getTranslated(context, "SureTransferAmount")
                    msg + " ${amount}\$",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  Text(
                    getTranslated(context, "toPhone") + " ${to}",
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h42_6.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          Navigator.pop(context);
                          if (kIsWeb) {
                            paywithTab();
                          } else {
                            pay();
                          }
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          decoration: BoxDecoration(
                            color: AppColors.linear2,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'sure'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.white,
                                fontStyle: FontStyle.normal,
                                fontWeight: FontWeight.w700,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Spacer(),
                      //SizedBox(width: AppSize.w57_3.w),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10_6.r)),
                              border: Border.all(
                                color: AppColors.linear2,
                                width: AppSize.w1_5.w,
                              )),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'cancel'),
                              textAlign: TextAlign.center,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.linear2,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  pay() async {
    final uri = Uri.parse('https://api.tap.company/v2/charges');
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      //'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
      'Authorization': "Bearer sk_live_C7V9cpBMFWbt2ukjd3fRxIeD",
      'Connection': 'keep-alive',
      'Accept-Encoding': 'gzip, deflate, br'
    };
    Map<String, dynamic> body = {
      "amount": amount,
      "currency": "USD",
      "threeDSecure": true,
      "save_card": true,
      "description": "Test Description",
      "statement_descriptor": "Sample",
      "metadata": {"udf1": "test 1", "udf2": "test 2"},
      "reference": {"transaction": "txn_0001", "order": "ord_0001"},
      "receipt": {"email": false, "sms": true},
      "customer": {
        // "id": widget.loggedUser!.customerId != null
        //     ? widget.loggedUser!.customerId
        //     : '',
        "first_name": widget.loggedUser!.name,
        "middle_name": ".",
        "last_name": ".",
        "email": widget.loggedUser!.name! + "@jeras.com",
        "phone": {"country_code": "", "number": widget.loggedUser!.phoneNumber}
      },
      "merchant": {"id": ""},
      "source": {"id": "src_all"},
      "post": {"url": "http://your_website.com/post_url"},
      "redirect": {"url": "https://www.jeras.io/app/redirect_url"}
    };
    String jsonBody = json.encode(body);
    final encoding = Encoding.getByName('utf-8');
    var response = await post(
      uri,
      headers: headers,
      body: jsonBody,
      encoding: encoding,
    );
    String responseBody = response.body;
    var res = json.decode(responseBody);
    String url = res['transaction']['url'];
    setState(() {
      initialUrl = url;
      showPayView = true;
    });
  }

  payStatus(String chargeId) async {
    final uri = Uri.parse('https://api.tap.company/v2/charges/' + chargeId);
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
      //'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
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

    // String customerId = res['customer']['id'];
    // customerId = customerId != null ? customerId : "";
    //
    if (res['status'] == "CAPTURED") {
      //update userBalance
      dynamic balance = double.parse(amount.toString());
      if (searchUser.balance != null) {
        balance = searchUser.balance + balance;
        searchUser.balance = balance;
      }
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.loggedUser!.uid)
          .set({
        'customerId': widget.loggedUser!.customerId,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.userPaymentHistory)
          .doc(Uuid().v4())
          .set({
        'userUid': widget.loggedUser!.uid,
        'payType': "send",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue': DateTime.now().millisecondsSinceEpoch,
        'amount': amount,
        'otherData': {
          'uid': searchUser.uid,
          'name': searchUser.name,
          'image': searchUser.photoUrl,
          'phone': searchUser.phoneNumber,
        },
      });

      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(searchUser.uid)
          .set({
        'balance': balance,
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.userPaymentHistory)
          .doc(Uuid().v4())
          .set({
        'userUid': searchUser.uid,
        'payType': "receive",
        'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
        'payDateValue': Timestamp.now().millisecondsSinceEpoch,
        'amount': amount,
        'otherData': {
          'uid': widget.loggedUser!.uid,
          'name': widget.loggedUser!.name,
          'image': widget.loggedUser!.photoUrl,
          'phone': widget.loggedUser!.phoneNumber,
        },
      });
      addingDialog(MediaQuery.of(context).size,
          getTranslated(context, "addBalanceDoneSuccessfully"), true);
      if (widget.loggedUser!.phoneNumber == to)
        accountBloc.add(GetLoggedUserEvent());
      setState(() {
        showPayView = false;
        saving = false;
      });
      showSuccessAddingDialog(
        size,
        widget.loggedUser!.phoneNumber == to
            ? getTranslated(context, "addBalance")
            : getTranslated(context, "balanceTransfer"),
        widget.loggedUser!.phoneNumber == to
            ? getTranslated(context, "balanceAdded")
            : getTranslated(context, "balanceTransferred"),
      );
    } else {
      setState(() {
        showPayView = false;
        saving = false;
      });
      showSnakbar(getTranslated(context, "failed"), true);
    }
  }

  showSuccessAddingDialog(Size size, String title, String msg) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Column(
              children: [
                SizedBox(height: AppSize.h7_6.h),
                Text(
                  title,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s32.sp,
                    color: AppColors.linear2,
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w700,
                  ),
                ),
                SizedBox(height: AppSize.h33_3.h),
                Text(
                  msg + " ${amount}\$",
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithralight"),
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    color: AppColors.black4,
                    fontWeight: AppFontsWeightManager.bold300,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                Text(
                  widget.loggedUser!.phoneNumber == to
                      ? getTranslated(context, "toBalance")
                      : (getTranslated(context, "toPhone") +
                          " ${to} " +
                          getTranslated(context, "successfully")),
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithralight"),
                    fontSize: AppFontsSizeManager.s21_3.sp,
                    color: AppColors.black4,
                    fontWeight: AppFontsWeightManager.bold300,
                    fontStyle: FontStyle.normal,
                  ),
                ),
                SizedBox(
                  height: AppSize.h35_6.h,
                ),
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Container(
                    width: AppSize.w377_3.w,
                    height: AppSize.h56.h,
                    //   alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.linear2,
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                    ),
                    child: Center(
                      child: Text(
                        getTranslated(context, 'Ok'),
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s18_6.sp,
                          color: AppColors.white,
                          fontWeight: FontWeight.w700,
                          fontStyle: FontStyle.normal,
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
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

  Future<void> updateDatabaseAfterAddingOrder(
      String customerId, String s, String t, String mony) async {
    dynamic balance = double.parse(mony.toString());
    if (searchUser.balance != null) {
      balance = searchUser.balance + balance;
      searchUser.balance = balance;
    }
    await FirebaseFirestore.instance
        .collection(Paths.userPaymentHistory)
        .doc(Uuid().v4())
        .set({
      'userUid': user.uid,
      'payType': "send",
      'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
      'payDateValue': DateTime.now().millisecondsSinceEpoch,
      'amount': mony,
      'otherData': {
        'uid': searchUser.uid,
        'name': searchUser.name,
        'image': searchUser.photoUrl,
        'phone': searchUser.phoneNumber,
      },
    });

    await FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(searchUser.uid)
        .set({
      'balance': balance,
    }, SetOptions(merge: true));
    await FirebaseFirestore.instance
        .collection(Paths.userPaymentHistory)
        .doc(Uuid().v4())
        .set({
      'userUid': searchUser.uid,
      'payType': "receive",
      'payDate': Timestamp.now(), //FieldValue.serverTimestamp(),
      'payDateValue': Timestamp.now().millisecondsSinceEpoch,
      'amount': mony,
      'otherData': {
        'uid': user.uid,
        'name': user.name,
        'image': user.photoUrl,
        'phone': user.phoneNumber,
      },
    });
    addingDialog(MediaQuery.of(context).size,
        getTranslated(context, "addBalanceDoneSuccessfully"), true);
  }
}
