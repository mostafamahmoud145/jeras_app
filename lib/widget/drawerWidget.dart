import 'package:checkbox_grouped/checkbox_grouped.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_svg/svg.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/localization/language_constants.dart';
import 'package:jeras/screens/course/addCourseScreen.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/custom_outlined_button.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../screens/question/questionScreens.dart';
import '../Utils/helper.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../controller/blocs/program_bloc/program_bloc.dart';
import '../main.dart';
import '../models/user.dart';
import '../screens/DevelopTechSupport/allDevelopSupport.dart';
import '../screens/aboutUsScreen.dart';
import '../screens/account_screen.dart';
import '../screens/addFakeReview.dart';
import '../screens/chatScreen.dart';
import '../screens/consultPaymentHistoryScreen.dart';
import '../screens/course/courseIsSupervisorScreen.dart';
import '../screens/invoice/allInvoicesScreen.dart';
import '../screens/job/jobOffersScreen.dart';
import '../screens/job/jobPublishedScreen.dart';
import '../screens/myOrderScreen.dart';
import '../screens/objectionScreen.dart';
import '../screens/promoCodesScreens/allPromoCodesScreen.dart';
import '../screens/push_notifications_screens/AllSendedNotification.dart';
import '../screens/reviews_screen.dart';
import '../screens/suggestionScreen.dart';
import '../screens/technicalAppointment/allAppointmentScreen.dart';
import '../screens/userAccountScreen.dart';
import '../screens/walletScreen.dart';
import 'jerasDialogWidget.dart';

class DrawerWidget extends StatefulWidget {
  const DrawerWidget(this.scaffoldKey);
  final GlobalKey<ScaffoldState> scaffoldKey;
  @override
  _DrawerWidgetState createState() => _DrawerWidgetState();
}

class _DrawerWidgetState extends State<DrawerWidget>
    with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  late ProgramBloc programBloc;
  GroceryUser user = GroceryUser();
  bool load = false, loadUser = true, wrongNumber = false, changeLang = false;
  late bool isSigningOut;
  TextEditingController searchController = new TextEditingController();
  late String userImage, userName, lang = "ar", theme = "light";
  late User currentUser;
  Video video = Video();

  int jobOffers = 0;
  String selectedLang = " ";
  static LinearGradient get gradiant => LinearGradient(
        begin: Alignment(-0.026087120175361633, 0.5),
        end: Alignment(1.0575249195098877, 0.5),
        colors: [
          AppColors.linear1,
          AppColors.linear2,
        ],
      );

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    programBloc = BlocProvider.of<ProgramBloc>(context);
    accountBloc.stream.listen((state) {
      if (state is GetLoggedUserCompletedState) {
        user = state.user;
        if (user.userType == "CONSULTANT") Helper.checkJob(user);
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    return Drawer(
        backgroundColor: AppColors.white,
        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
            ? AppSize.w1228.w
            : size.width * AppSize.w0_75,
        child: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            if (state is GetLoggedUserInProgressState) {
              return Center(child: CircularProgressIndicator());
            } else if (state is GetLoggedUserCompletedState) {
              user = state.user;
              return Container(
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        blurRadius: 38,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_4
                      : size.width * AppSize.w0_7,
                  child: loggedUserDrawer(size));
            } else {
              return Container(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_4
                      : size.width * AppSize.w0_7,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    boxShadow: [
                      BoxShadow(
                        color: Color.fromRGBO(0, 0, 0, 0.16),
                        blurRadius: 38,
                        spreadRadius: 10,
                      )
                    ],
                  ),
                  child: notLoggedUserDrawer(size));
            }
          },
        ));
  }

  Widget loggedUserDrawer(Size size) {
    return ListView(
      shrinkWrap: true,
      children: <Widget>[
        Padding(
          padding: EdgeInsets.only(
              top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p40
                  : AppPadding.p20.h,
              right: AppPadding.p32.w,
              left: AppPadding.p32.w),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? () async {
                        showLangDialog(size);
                      }
                    : () async {
                        showLangDialogMob(size);
                      },
                child: SvgPicture.asset(
                  lang == "ar"
                      ? AssetsManager.langIconPath
                      : AssetsManager.langIconPath,
                  width: AppSize.w32.w,
                  height: AppSize.h32.w,
                ),
              ),
              SizedBox(
                width: AppSize.w10_6.w,
              ),
              Text(
                getTranslated(context, "lang"),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(147, 147, 147, 1),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s28.sp
                        : AppFontsSizeManager.s22_6.sp,
                    fontFamily: lang == "ar"
                        ? getTranslated(context, "Montserratbold")
                        : getTranslated(context, "Ithra")),
              ),
              Spacer(),
              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? Container(
                      width: AppSize.w75.w,
                      height: AppSize.h75.h,
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r25.r),
                      ),
                      child: CustomBackButton())
                  : InkWell(
                      onTap: () {
                        Navigator.pop(context);
                        ;
                      },
                      child: Container(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w75.w
                                : AppSize.w50_6.r,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h75.h
                                : AppSize.h50_6.r,
                        decoration: BoxDecoration(
                          color: AppColors.white,
                          borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r16.r
                                : AppRadius.r10_6.r,
                          ),
                          border: CustomOulinedButton.outlineBorder(),
                        ),
                        child: Icon(
                          Icons.close, color: AppColors.primaryColor,
                          // size:AppSize.h21_3.h
                        ),
                      ),
                    )
            ],
          ),
        ),
        SizedBox(
            height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppSize.h20.h
                : AppSize.h30.h),
        Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p32.w),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(
                children: [
                  InkWell(
                    splashColor: Colors.white.withOpacity(0.6),
                    onTap: () {
                      Video video = new Video();

                      if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                        widget.scaffoldKey.currentState!.openEndDrawer();
                      } else {
                        widget.scaffoldKey.currentState!.openDrawer();
                      }
                      if (user.isDeveloper!)
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                AllDevelopTechScreen(loggedUser: user),
                          ),
                        );
                      else if (user.userType != "CONSULTANT")
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => UserAccountScreen(
                                user: user, firstLogged: false),
                          ),
                        );
                      else if (user.userType == "CONSULTANT")
                        Navigator.push(
                          context,
                          MaterialPageRoute(
                            builder: (context) => AccountScreen(
                              user: user,
                              consultVideo: video,
                              consultUid: user.uid,
                            ), // firstLogged: false),
                          ),
                        );
                      else {
                        Navigator.pushNamed(context, '/Register_Type');
                      }
                    },
                    child: Stack(
                      children: [
                        Container(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h138.h
                                  : AppSize.h86_6.r,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w138.w
                                  : AppSize.w86_6.r,
                          decoration: BoxDecoration(
                            boxShadow: [
                              BoxShadow(
                                  color: const Color(0x33ae9cce),
                                  offset: Offset(0, 6),
                                  blurRadius: 12,
                                  spreadRadius: 0)
                            ],
                            color: Colors.white,
                            shape: BoxShape.circle,
                          ),
                          child: user.photoUrl == null
                              ? Image.asset(
                                  AssetsManager.whiteJerasLogoIconPath,
                                  width: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.w138.w
                                      : AppSize.w86_6.r,
                                  height: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.h138.h
                                      : AppSize.h86_6.r,
                                )
                              : ClipRRect(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r100.r),
                                  child: FadeInImage.assetNetwork(
                                    placeholder:
                                        AssetsManager.whiteJerasLogoIconPath,
                                    //placeholderScale: 0.5,
                                    imageErrorBuilder:
                                        (context, error, stackTrace) =>
                                            Image.asset(
                                      AssetsManager.whiteJerasLogoIconPath,
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w100.w
                                          : AppSize.w50.w,
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h100.h
                                          : AppSize.h50.h,
                                    ),
                                    image: user.photoUrl!,
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
                        /* Positioned(
                                top: 7,
                                left: 0,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.darkGreen,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),*/
                      ],
                    ),
                  ),
                ],
              ),
              SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h20_5.h
                      : AppSize.h10_6.h),
              user.name != null && user.userType == "CONSULTANT"
                  ? Text(
                      getTranslated(context, "lang") == "ar"
                          ? user.name!
                          : getTranslated(context, "lang") == "en"
                              ? user.nameEn!
                              : user.nameFr!,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: (kIsWeb || size.width >= 500)
                            ? FontWeight.w600
                            : FontWeight.w300,
                        fontFamily: getTranslated(context, "Ithra"),
                        fontStyle: FontStyle.normal,
                        fontSize: (kIsWeb || size.width >= 500)
                            ? AppFontsSizeManager.s27.sp
                            : AppFontsSizeManager.s21_3.sp,
                        color: AppColors.black1,
                      ),
                    )
                  : Text(
                      user.name!,
                      maxLines: 1,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight: (kIsWeb || size.width >= 500)
                            ? FontWeight.w600
                            : null,
                        fontFamily: getTranslated(context, "Ithra"),
                        fontStyle: FontStyle.normal,
                        fontSize: (kIsWeb || size.width >= 500)
                            ? AppFontsSizeManager.s27.sp
                            : AppFontsSizeManager.s21_3.sp,
                        color: AppColors.black1,
                      ),
                    ),
            ],
          ),
        ),
        SizedBox(
            height:
                (kIsWeb || size.width >= 500) ? AppSize.h15.h : AppSize.h32.h),
        Padding(
          padding: EdgeInsets.only(
              right: AppPadding.p32.w,
              left: AppPadding.p32.w,
              bottom: AppPadding.p5.h),
          child: user.userType == "SUPPORT"
              ? Column(
                  children: [
                    SizedBox(
                      height: AppSize.h5.h,
                    ),
                    Text(
                      getTranslated(context, "searchByMobile"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s18.sp,
                        color: AppColors.pink,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h5.h,
                    ),
                    TextField(
                      textAlignVertical: TextAlignVertical.center,
                      controller: searchController,
                      enableInteractiveSelection: true,
                      onChanged: (text) {
                        setState(() {
                          wrongNumber = false;
                        });
                      },
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s18.sp,
                        color: AppColors.black,
                      ),
                      textInputAction: TextInputAction.done,
                      keyboardType: TextInputType.phone,
                      decoration: InputDecoration(
                        fillColor:
                            theme == "light" ? Colors.white : Color(0xff3f3f3f),
                        filled: true,
                        contentPadding: EdgeInsets.symmetric(horizontal: 5.0),
                        helperStyle: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: Colors.black.withOpacity(0.65),
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        errorStyle: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s13,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        hintStyle: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: AppColors.black54,
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        prefixIcon: Icon(Icons.search),
                        prefixStyle: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        suffixIcon: InkWell(
                            child: Icon(Icons.send_rounded, size: 18),
                            onTap: () async {
                              setState(() {
                                load = true;
                              });
                              bool checkNumber = await Helper.initiateSearch(
                                  context, searchController.text, user);
                              if (!checkNumber) {
                                setState(() {
                                  wrongNumber = true;
                                });
                              }
                              setState(() {
                                load = false;
                              });
                            }),
                        // labelText: getTranslated(context, "phoneNumber"),
                        labelStyle: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r20),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: 5.0,
                    ),
                    load ? CircularProgressIndicator() : SizedBox(),
                    SizedBox(
                      height: 5,
                    ),
                    wrongNumber
                        ? Text(
                            getTranslated(context, "noUser"),
                            style: GoogleFonts.elMessiri(
                              color: AppColors.red,
                              fontSize: AppFontsSizeManager.s14,
                              fontWeight: AppFontsWeightManager.semiBold,
                            ),
                          )
                        : SizedBox(),
                  ],
                )
              : Wrap(
                  //mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Container(
                      child: Text(
                        getTranslated(context, "balance"),
                        maxLines: 1,
                        textAlign: TextAlign.center,
                        overflow: TextOverflow.clip,
                        style: TextStyle(
                          fontWeight:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsWeightManager.normal
                                  : AppFontsWeightManager.normal,
                          fontFamily:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Montserrat")
                                  : getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s27.sp
                                  : AppFontsSizeManager.s18_6.sp,
                          color: Color.fromRGBO(147, 147, 147, 1),
                        ),
                      ),
                    ),
                    SizedBox(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w5.w
                                : AppSize.w10_6.w),
                    Text(
                      double.parse(user.balance.toString()).toStringAsFixed(2) +
                          "\$",
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsWeightManager.normal
                                : null,
                        fontFamily: getTranslated(context, "Ithra"),
                        fontStyle: FontStyle.normal,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s27.sp
                                : AppFontsSizeManager.s18_6.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                    SizedBox(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w30.w
                                : AppSize.w44.w),
                    Text(
                      getTranslated(context, "orderNum"),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsWeightManager.normal
                                : AppFontsWeightManager.bold300,
                        fontFamily:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? getTranslated(context, "Montserrat")
                                : getTranslated(context, "Ithra"),
                        fontStyle: FontStyle.normal,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s27.sp
                                : AppFontsSizeManager.s18_6.sp,
                        color: AppColors.grey1,
                      ),
                    ),
                    SizedBox(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w5.w
                                : AppSize.w10_6.w),
                    Text(
                      user.ordersNumbers.toString(),
                      maxLines: 1,
                      textAlign: TextAlign.center,
                      overflow: TextOverflow.clip,
                      style: TextStyle(
                        fontWeight:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsWeightManager.normal
                                : AppFontsWeightManager.bold400,
                        fontFamily:
                            getTranslated(context, "Montserratsemibold"),
                        fontStyle: FontStyle.normal,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s27.sp
                                : AppFontsSizeManager.s18_6.sp,
                        color: AppColors.primaryColor,
                      ),
                    ),
                  ],
                ),
        ),
        Divider(color: AppColors.shadowborder, thickness: .3),
        InkWell(
          onTap: () {
            Video video = new Video();

            if (widget.scaffoldKey.currentState!.isDrawerOpen) {
              widget.scaffoldKey.currentState!.openEndDrawer();
            } else {
              widget.scaffoldKey.currentState!.openDrawer();
            }
            if (user.userType != "CONSULTANT")
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      UserAccountScreen(user: user, firstLogged: false),
                ),
              );
            else if (user.userType == "CONSULTANT")
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AccountScreen(
                    user: user,
                    consultVideo: video,
                    consultUid: user.uid,
                  ), //firstLogged: false),
                ),
              );
            else {
              Navigator.pushNamed(context, '/Register_Type');
            }
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "account"),
            image: AssetsManager.personIconPath,
          ),
        ),
        InkWell(
          onTap: () {
            if (widget.scaffoldKey.currentState!.isDrawerOpen) {
              widget.scaffoldKey.currentState!.openEndDrawer();
            } else {
              widget.scaffoldKey.currentState!.openDrawer();
            }
            if (user.userType != "CONSULTANT")
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobPublishedListScreen(user: user),
                ),
              );
            else
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => JobsOffersScreen(user: user),
                ),
              );
          },
          child: DrawerItem(
            context,
            title: getTranslated(
                context,
                user.userType == "CONSULTANT"
                    ? "jobAvaliable"
                    : "jobPublished"),
            image: (user.userType != "CONSULTANT")
                ? AssetsManager.searchIconDrawer
                : AssetsManager.zoomInIconPath,
          ),
        ),
        if (user.userType == "CONSULTANT" && user.isSupervisor == true)
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCourseScreen(),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "addCourse"),
              image: AssetsManager.addOutlineIconPath,
            ),
          ),
        if (user.userType == "CONSULTANT" && user.isSupervisor == true)
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CourseIsProgramScreen(loggedUser: user),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "courses"),
              icon: Icons.add_chart_outlined,
            ),
          ),
        if (user.userType == "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllInvoicesScreen(),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "invoices"),
              icon: Icons.wysiwyg_rounded,
            ),
          ),
        if (user.userType == "USER")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => WalletScreen(
                    loggedUser: user,
                  ),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "wallet"),
              image: AssetsManager.emptyWalletIconPath,
            ),
          ),
        if (user.userType == "CONSULTANT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ConsultPaymentHistoryScreen(
                    user: user,
                  ),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "paymentHistory"),
              image: AssetsManager.wallet2IconPath,
            ),
          ),
        if (user.userType != "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatScreen(
                    user: user,
                  ),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "chat"),
              image: AssetsManager.chat2IconPath,
            ),
          ),
        if (user.userType == "CONSULTANT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (context) => MyOrdersScreen(
                      user: user,
                      loggedType: user.userType,
                      fromSupport: false,
                    ),
                  ));
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "orders"),
              icon: Icons.list_alt_rounded,
            ),
          ),
        if (user.userType == "CONSULTANT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ReviewScreens(
                    consult: user,
                    reviewLength: 1,
                  ),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "Reviews"),
              image: AssetsManager.outlineStarIconPath,
            ),
          ),
        if (user.userType == "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllDevelopTechScreen(loggedUser: user),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "developNotes"),
              icon: Icons.check,
            ),
          ),
        if (user.userType == "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ObjectionScreen(
                    loggedUser: user,
                  ),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "objections"),
              icon: Icons.warning,
            ),
          ),
        if (user.userType == "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => AllAppointmentsScreen(
                            loggedUser: user,
                          )));
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "appointments"),
              icon: Icons.calendar_today_rounded,
            ),
          ),
        if (user.userType == "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllPromoCodeScreen(),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "proCodes"),
              icon: Icons.card_giftcard,
            ),
          ),
        if (user.userType == "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AllSendedNotificationSreen(),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "notification"),
              icon: Icons.notifications_none_sharp,
            ),
          ),
        if (user.userType == "SUPPORT")
          InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddFakeReviewScreen(user: user),
                ),
              );
            },
            child: DrawerItem(
              context,
              title: getTranslated(context, "addReview"),
              icon: Icons.add_circle_outline,
            ),
          ),
        InkWell(
          onTap: () {
            if (widget.scaffoldKey.currentState!.isDrawerOpen) {
              widget.scaffoldKey.currentState!.openEndDrawer();
            } else {
              widget.scaffoldKey.currentState!.openDrawer();
            }
            Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SuggestionScreen(loggedUser: user),
                ));
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "suggestions"),
            image: AssetsManager.lumpIconPath,
          ),
        ),
        InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionScreen(user: user),
                ),
              );
            },
            child: DrawerItem(context,
                title: getTranslated(context, "FAQs"),
                image: AssetsManager.deviceMessageIconPath)),
        InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => QuestionScreen(user: user),
                ),
              );
            },
            child: DrawerItem(context,
                title: getTranslated(context, "settings"),
                image: AssetsManager.settingIcon)),
        InkWell(
            onTap: () {
              if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                widget.scaffoldKey.currentState!.openEndDrawer();
              } else {
                widget.scaffoldKey.currentState!.openDrawer();
              }
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AboutUsScreen(),
                ),
              );
            },
            child: DrawerItem(context,
                title: getTranslated(context, "aboutUs"),
                image: AssetsManager.peopleIconPath)),
        InkWell(
            onTap: () {
              Helper.openwhatsapp();
            },
            child: DrawerItem(context,
                title: getTranslated(context, "contacts"),
                image: AssetsManager.whatsappIconPath)),
        InkWell(
          onTap: () {
            Helper.inviteAFriend();
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "share"),
            image: AssetsManager.shareIconPath,
          ),
        ),
        InkWell(
            onTap: () {
              showSignoutConfimationDialog(size);
            },
            child: DrawerItem(context,
                title: getTranslated(context, "logout"),
                image: AssetsManager.logoutIconPath)),
        SizedBox(height: AppSize.h50),
      ],
    );
  }

  Widget notLoggedUserDrawer(Size size) {
    return ListView(
      shrinkWrap: true,
      padding: const EdgeInsets.only(
          left: AppPadding.p10, right: AppPadding.p10, top: AppPadding.p20),
      children: <Widget>[
        if (kIsWeb || size.width >= AppConstants.kIsWebValue)
          SizedBox(height: AppSize.h30.h),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.p20),
          child: Row(
            //mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                iconSize: AppSize.w20,
                onPressed: () async {
                  showLangDialog(size);
                },
                icon: SvgPicture.asset(
                  lang == "ar"
                      ? AssetsManager.langIconPath
                      : AssetsManager.langIconPath,
                  width: AppSize.w25,
                  height: AppSize.h25,
                ),
              ),
              Text(
                getTranslated(context, "lang"),
                style: TextStyle(
                    fontWeight: FontWeight.w700,
                    color: Color.fromRGBO(147, 147, 147, 1),
                    fontSize: (kIsWeb || size.width >= 500) ? 28.sp : 16.sp,
                    fontFamily: lang == "ar"
                        ? getTranslated(context, "Montserratbold")
                        : getTranslated(context, "Ithra")),
              ),
              Spacer(),
              IconButton1(
                onPress: () {
                  Navigator.pop(context);
                },
                Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w80.w
                    : AppSize.w50_6.w,
                Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w80.h
                    : AppSize.w50_6.h,
                ButtonRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppRadius.r16.r
                    : AppRadius.r10_6.r,
                IconWidth: 22.w,
                IconHeight: 20.h,
                IconColor: Theme.of(context).primaryColor,
                Icon: '${AppConstants.iconsPath}cancel-svgrepo-com.svg',
                ButtonBackground: AppColors.white,
              ),
            ],
          ),
        ),
        SizedBox(height: AppSize.h10.h),
        Center(
          child: InkWell(
            splashColor: Colors.white.withOpacity(0.6),
            onTap: () {
              Navigator.pushNamed(context, '/Register_Type');
            },
            child: Container(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w100
                    : AppSize.w50,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.h100
                    : AppSize.h50,
                decoration: BoxDecoration(
                  boxShadow: [
                    BoxShadow(
                        color: Colors.white,
                        offset: Offset(0, 6),
                        blurRadius: 17,
                        spreadRadius: 0)
                  ],
                  color: Colors.white.withOpacity(0.08),
                  border: Border.all(
                    width: AppSize.w6.w,
                    color: Colors.white,
                  ),
                  shape: BoxShape.circle,
                ),
                child: Image.asset(
                  AssetsManager.whiteJerasLogoIconPath,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w100
                      : AppSize.w50,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h100
                      : AppSize.h50,
                )),
          ),
        ),
        Center(
          child: Text(
            getTranslated(context, "welcomeBack"),
            style: TextStyle(
              fontFamily: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? getTranslated(context, "Montserrat")
                  : getTranslated(context, "Ithra"),
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s27
                  : AppFontsSizeManager.s12,
              fontWeight: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? FontWeight.w600
                  : FontWeight.normal,
              color: AppColors.grey,
            ),
          ),
        ),
        SizedBox(
          height: AppSize.h70,
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/Register_Type');
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "suggestions"),
            image: AssetsManager.lumpIconPath,
          ),
        ),
        InkWell(
          onTap: () {
            String url = "https://www.jeras.io/?lang=ar";
            launchUrl(Uri.parse(url));
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "aboutUs"),
            image: AssetsManager.accountTreeIconPath,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/Register_Type');
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "contacts"),
            image: AssetsManager.whatsappIconPath,
          ),
        ),
        InkWell(
          onTap: () {
            Helper.inviteAFriend();
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "share"),
            image: AssetsManager.shareIconPath,
          ),
        ),
        InkWell(
          onTap: () {
            Navigator.pushNamed(context, '/Register_Type');
          },
          child: DrawerItem(
            context,
            title: getTranslated(context, "login"),
            image: AssetsManager.logoutIconPath,
          ),
        ),
      ],
    );
  }

  showSignoutConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    AssetsManager.moveCloseIconPath,
                    width: AppSize.w32.w,
                    height: AppSize.h32.h,
                  ),
                ),
                SizedBox(width: AppSize.w140.w),
                Padding(
                  padding: EdgeInsets.only(top: AppSize.h10_6.h),
                  child: Center(
                    child: SvgPicture.asset(
                      AssetsManager.logoutIconPath,
                      width: AppSize.w53_5.r,
                      height: AppSize.h53_5.r,
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h26.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "logout"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s26_6.sp,
                      color: AppColors.linear2,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSize.h26.h),
                  Text(
                    getTranslated(context, "doYouNeedToLogout"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h32.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          if (widget.scaffoldKey.currentState!.isDrawerOpen) {
                            widget.scaffoldKey.currentState!.openEndDrawer();
                          } else {
                            widget.scaffoldKey.currentState!.openDrawer();
                          }
                          await FirebaseFirestore.instance
                              .collection(Paths.usersPath)
                              .doc(user.uid)
                              .set({
                            'tokenId': "",
                          }, SetOptions(merge: true));
                          FirebaseAuth.instance.signOut();
                          accountBloc.add(GetLoggedUserEvent());
                          Navigator.pop(context);
                          Navigator.pushNamedAndRemoveUntil(
                            context,
                            '/RegisterTypeScreen',
                            (route) => false,
                          );
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                            color: AppColors.linear2,
                            borderRadius:
                                BorderRadius.circular(AppRadius.r10_6.r),
                          ),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'yes'),
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
                      SizedBox(width: AppSize.w57_3.w),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10_6.r)),
                              border: Border.all(
                                color: AppColors.linear2,
                                width: 1.5.w,
                              )),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'no'),
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

  showLangDialog(Size size) {
    GroupController controller =
        GroupController(initSelectedItem: [getTranslated(context, "lang")]);
    return showDialog(
      builder: (context) => Container(
        child: JerasDialogWidget(
          dialogContent: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              SizedBox(
                height: AppSize.h30.h,
              ),
              Container(
                height: AppSize.h200.h,
                width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? AppSize.w478.w
                    : size.width * 0.95.w,
                child: SimpleGroupedCheckbox<String>(
                  ///
                  controller: controller,
                  onItemSelected: (data) {
                    setState(() {
                      selectedLang = data;
                    });
                  },
                  itemsTitle: [
                    getTranslated(context, 'ar'),
                    getTranslated(context, 'en'),
                    getTranslated(context, 'fr'),
                  ],
                  values: ["ar", "en", "fr"],
                  groupStyle: GroupStyle(
                      activeColor: AppColors.linear2,
                      itemTitleStyle: TextStyle(
                        fontSize: AppFontsSizeManager.s26_6.sp,
                        fontFamily: getTranslated(context, 'Ithra'),
                      )),
                  // checkFirstElement: false,
                ),
              ),
              SizedBox(
                height: AppSize.h53_3.h,
              ),
              Center(
                child: Container(
                  height: AppSize.h66_6.h,
                  width: AppSize.w342_6.w,
                  decoration: BoxDecoration(
                    gradient: gradiant,
                    borderRadius:
                        BorderRadius.all(Radius.circular(AppRadius.r20.r)),
                  ),
                  child: MaterialButton(
                    onPressed: () {
                      if (selectedLang == 'ar')
                        changelanguage("ar", "AR");
                      else if (selectedLang == 'en')
                        changelanguage("en", "US");
                      else if (selectedLang == 'fr')
                        changelanguage("fr", "FR");
                      else
                        Navigator.pop(context);
                    },

                    // color: AppColors.linear2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                    ),
                    child: Text(
                      getTranslated(context, "save"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.white,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: AppSize.h10.h,
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  showLangDialogMob(Size size) {
    GroupController controller =
        GroupController(initSelectedItem: [getTranslated(context, "lang")]);
    return showDialog(
      builder: (context) => Container(
        // width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
        //     ? AppSize.w200.w
        //     : null,
        child: JerasDialogWidget(
          padReight: AppPadding.p32.w,
          padLeft: AppPadding.p32.w,
          dialogContent: Column(
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: lang == "ar"
                    ? MainAxisAlignment.start
                    : MainAxisAlignment.end,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Spacer(),
                  InkWell(
                    onTap: () {
                      Navigator.pop(context);
                    },
                    child: SvgPicture.asset(
                      AssetsManager.moveCloseIconPath,
                      width: AppSize.w32.w,
                      height: AppSize.h32.h,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: AppSize.h21_3.h,
              ),
              Text(
                getTranslated(context, "chooseLang"),
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontFamily: getTranslated(context, 'Ithra'),
                  fontSize: AppFontsSizeManager.s32.sp,
                  color: AppColors.black1,
                  fontWeight: AppFontsWeightManager.bold,
                  fontStyle: FontStyle.normal,
                ),
              ),
              SizedBox(
                height: AppSize.h48.h,
              ),
              Container(
                height: AppPadding.p212.h,
                width: size.width,
                child: SimpleGroupedCheckbox<String>(
                  ///
                  controller: controller,
                  onItemSelected: (data) {
                    setState(() {
                      selectedLang = data;
                    });
                  },
                  itemsTitle: [
                    getTranslated(context, 'ar'),
                    getTranslated(context, 'en'),
                    getTranslated(context, 'fr'),
                  ],
                  values: ["ar", "en", "fr"],
                  groupStyle: GroupStyle(
                      activeColor: AppColors.linear2,
                      itemTitleStyle: TextStyle(
                        fontSize: AppFontsSizeManager.s26_6.sp,
                        fontFamily: getTranslated(context, 'Ithra'),
                      )),
                  //checkFirstElement: false,
                ),
              ),
              SizedBox(
                height: AppSize.h46_6.h,
              ),
              Center(
                child: Container(
                  height: AppSize.h53_3.h,
                  width: AppSize.w312.w,
                  child: MaterialButton(
                    onPressed: () {
                      if (selectedLang == " ") {
                        selectedLang = getTranslated(context, "lang");
                      }
                      if (selectedLang == 'ar')
                        changelanguage("ar", "AR");
                      else if (selectedLang == 'en')
                        changelanguage("en", "US");
                      else if (selectedLang == 'fr')
                        changelanguage("fr", "FR");
                      else
                        Navigator.pop(context);

                      print(selectedLang);
                    },
                    color: AppColors.linear2,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
                    ),
                    child: Text(
                      getTranslated(context, "changelange"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.white,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        fontWeight: FontWeight.w700,
                        fontStyle: FontStyle.normal,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ),
                ),
              ),
              SizedBox(
                height: AppSize.h37_3.h,
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  changelanguage(String lang, String code) async {
    setState(() {
      changeLang = true;
    });
    await setLocale(lang);
    Locale _temp = Locale(lang, code);
    if (FirebaseAuth.instance.currentUser != null) {
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(user.uid)
          .set({
        'userLang': lang,
        'languages':
            user.userType == AppConstants.consultant ? user.languages : [lang],
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance
          .collection(Paths.supportListPath)
          .doc(user.supportListId)
          .set({
        'userLang': lang,
      }, SetOptions(merge: true));
      accountBloc.add(GetLoggedUserEvent());
    }
    MyApp.setLocale(context, _temp);
    setState(() {
      changeLang = false;
    });
    Navigator.pop(context);
  }
}

Widget DrawerItem(BuildContext context,
    {String? image, IconData? icon, required String title, isIcon}) {
  return Column(
    children: [
      //SizedBox(height: kIsWeb||(MediaQuery.of(context).size.width >= 500)?10:1,),

      ListTile(
        contentPadding: kIsWeb || (MediaQuery.of(context).size.width >= 500)
            ? EdgeInsets.symmetric(horizontal: AppPadding.p75.w)
            : null,
        leading: icon != null
            ? Icon(
                icon,
                color: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                    ? AppColors.grey
                    : AppColors.pink,
                size: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                    ? AppSize.w55.r
                    : AppSize.w32.r,
              )
            : SvgPicture.asset(
                image!,
                width: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                    ? AppSize.w55.r
                    : AppSize.w32.r,
                height: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                    ? AppSize.h55.r
                    : AppSize.h32.r,
              ),
        title: TextDefaultWidget(
          title: kIsWeb || (MediaQuery.of(context).size.width >= 500)
              ? "    " + title
              : title,
          fontFamily: getTranslated(context, "Ithralight"),
          // fontWeight: FontWeight.w600,
          fontSize: kIsWeb || (MediaQuery.of(context).size.width >= 500)
              ? AppFontsSizeManager.s27.sp
              : AppFontsSizeManager.s21_3.sp,
          color: AppColors.black4,
        ),
        trailing: Icon(
          Icons.arrow_forward_ios,
          color: AppColors.borderLightGrey,
          size: kIsWeb || (MediaQuery.of(context).size.width >= 500)
              ? AppSize.w27.r
              : AppSize.w25.r,
        ),
      ),
      //SizedBox(height: kIsWeb||(MediaQuery.of(context).size.width >= 500)?10:1,),
      Divider(color: AppColors.shadowborder, thickness: .2),
    ],
  );
}
