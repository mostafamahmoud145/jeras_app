import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/svg.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/widget/load_widget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/responsive_layout.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../widget/historyAppointmentWidget.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../Utils/helper.dart';
import '../config/app_constat.dart';
import '../config/assets_manager.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../methods/convert_pt_to_px.dart';

class CallHistoryPage extends StatefulWidget {
  @override
  _CallHistoryPageState createState() => _CallHistoryPageState();
}

class _CallHistoryPageState extends State<CallHistoryPage>
    with AutomaticKeepAliveClientMixin<CallHistoryPage> {
  final TextEditingController searchController = new TextEditingController();

  late AccountBloc accountBloc;
  GroceryUser? user;
  late bool load;
  DateTime selectedDate = DateTime.now();
  bool avaliable = false;
  bool filter = false;
  late String time;
  late Query filterQuery;
  String lang = "";
    String?
      displayedTime;
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
    filterQuery = FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .where('consult.uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
        .where('appointmentStatus', isEqualTo: "closed")
        .orderBy('secondValue', descending: true);
    load = true;
    time = "التصفية بحسب التاريخ";
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return ResponsiveLayout(
      desktop: Scaffold(
        body: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            if (state is GetLoggedUserInProgressState) {
              return Center(child: LoadWidget());
            } else if (state is GetLoggedUserCompletedState) {
              user = state.user;
              avaliable = Helper.checkAvaliable(user!);
              return Column(
                children: <Widget>[
                  //header
                  Padding(
                    padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_25
                            : AppPadding.p16,
                        right:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppPadding.p0_25
                                : AppPadding.p16,
                        top: AppPadding.p30,
                        bottom: AppPadding.p20),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          children: [
                            Container(
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w31.w
                                  : AppSize.w20.w,
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h32.h
                                  : AppSize.h20.h,
                              decoration: BoxDecoration(
                                color: avaliable
                                    ? AppColors.darkGreen
                                    : AppColors.red,
                                shape: BoxShape.circle,
                              ),
                            ),
                            SizedBox(
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w16.w
                                    : AppSize.w16.w),
                            Text(
                              avaliable
                                  ? getTranslated(context, 'available')
                                  : getTranslated(context, 'notAvailable'),
                              style: TextStyle(
                                fontWeight: AppFontsWeightManager.bold300,
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                fontStyle: FontStyle.normal,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? 34.sp
                                    : 18.6.sp,
                                color: AppColors.black1,
                              ),
                            ),
                            Spacer(),
                            Container(
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.all(Radius.circular(
                                    (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppRadius.r25.r
                                        : AppRadius.r12.r)),
                                color: Colors.white,
                                boxShadow: [
                                  BoxShadow(
                                      color: const Color(0x0d202020),
                                      offset: Offset(0, 2),
                                      blurRadius: 9,
                                      spreadRadius: 0)
                                ],
                              ),
                              padding: EdgeInsets.only(left: 10),
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w597.w
                                  : AppSize.w329.w,
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h91.h
                                  : AppSize.h40.h,
                              child: TextFormField(
                                // textAlignVertical: TextAlignVertical.center,
                                decoration: InputDecoration(
                                  border: InputBorder.none,
                                  errorBorder: InputBorder.none,
                                  enabledBorder: InputBorder.none,
                                  focusedBorder: InputBorder.none,
                                  disabledBorder: InputBorder.none,
                                  focusedErrorBorder: InputBorder.none,
                                  hintText:
                                      getTranslated(context, 'filterByHistory'),
                                  hintStyle: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontStyle: FontStyle.normal,
                                    fontSize: checkIfWeb(context)
                                        ? AppFontsSizeManager.s34.sp
                                        : AppFontsSizeManager.s18_6.sp,
                                    color: AppColors.primaryColor,
                                  ),
                                  contentPadding:
                                      EdgeInsets.symmetric(horizontal: 10.w),
                                  suffixIcon: Center(
                                    child: SvgPicture.asset(
                                      AssetsManager.filterIconPath,
                                      width: AppSize.w34.w,
                                      height: AppSize.h34.h,
                                    ),
                                  ),
                                  suffixIconConstraints: BoxConstraints(
                                    maxHeight: AppSize.h48,
                                    maxWidth: AppSize.w48,
                                  ),
                                ),
                                style: TextStyle(
                                  fontWeight: FontWeight.bold,
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontStyle: FontStyle.normal,
                                  fontSize: checkIfWeb(context)
                                      ? AppFontsSizeManager.s34.sp
                                      : AppFontsSizeManager.s18_6.sp,
                                  color: AppColors.primaryColor,
                                ),
                              ),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.white.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        filterQuery = FirebaseFirestore.instance
                            .collection(Paths.appAppointments)
                            .where('consult.uid', isEqualTo: user!.uid)
                            .where('appointmentStatus', isEqualTo: "closed")
                            .orderBy('secondValue', descending: true);
                        time = getTranslated(context, "filter");
                      });
                    },
                    child: Center(
                      child: Text(
                        getTranslated(context, "allAppointment"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s26_6.sp,
                          color: AppColors.black1,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h10.h,
                  ),
                  //card
                  Expanded(
                    child: PaginateFirestore(
                      key: ValueKey(filterQuery),
                      itemBuilderType: PaginateBuilderType.listView,
                      separator: SizedBox(
                        height: AppSize.h20.h,
                      ),
                      padding: EdgeInsets.only(
                          left:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppPadding.p0_25
                                  : AppPadding.p16,
                          right:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppPadding.p0_25
                                  : AppPadding.p16,
                          bottom: AppPadding.p16,
                          top: AppPadding.p16),
                      //Change types accordingly
                      itemBuilder: (context, documentSnapshot, index) {
                        return CallHistoryWidget(
                          appointment: AppAppointments.fromMap(
                              documentSnapshot[index].data() as Map),
                          loggedUser: user!,
                          theme: "light",
                        );
                      },
                      query: filterQuery,
                      isLive: true,
                    ),
                  )
                ],
              );
            } else {
              return Center(child: LoadWidget());
            }
          },
        ),
      ),
      mobile: Scaffold(
        body: BlocBuilder(
          bloc: accountBloc,
          builder: (context, state) {
            if (state is GetLoggedUserInProgressState) {
              return Center(child: LoadWidget());
            } else if (state is GetLoggedUserCompletedState) {
              user = state.user;
              avaliable = Helper.checkAvaliable(user!);
              return Column(
                children: <Widget>[
                  //header
                  Padding(
                    padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_25
                            : AppPadding.p16,
                        right:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppPadding.p0_25
                                : AppPadding.p16,
                        top: AppPadding.p10,
                        bottom: AppPadding.p20),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            CircleAvatar(
                              backgroundColor: avaliable
                                  ? AppColors.darkGreen
                                  : AppColors.red,
                              radius: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r14.r
                                  : convertPtToPx(AppRadius.r8.r),
                            ),
                            SizedBox(
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w16.w
                                  : convertPtToPx(AppSize.w8.w),
                            ),
                            Text(
                              avaliable
                                  ? getTranslated(context, 'available')
                                  : getTranslated(context, 'notAvailable'),
                              style: TextStyle(
                                fontWeight: AppFontsWeightManager.bold300,
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                fontStyle: FontStyle.normal,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s34.sp
                                    : AppFontsSizeManager.s18_6.sp,
                                color: AppColors.black1,
                              ),
                            ),
                          ],
                        ),
                        Container(
                          alignment: Alignment.center,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.all(
                                Radius.circular(AppRadius.r12.r)),
                            color: Color.fromRGBO(247, 247, 247, 1.0),
                          ),
                          padding: EdgeInsets.only(left: AppPadding.p10),
                          width: lang == "fr"
                              ? AppSize.w330.w
                              : size.width * AppSize.w0_60,
                          child: TextFormField(
                            textAlign: TextAlign.center,
                            textAlignVertical: TextAlignVertical.center,
                            decoration: InputDecoration(
                              
                              border: InputBorder.none,
                              errorBorder: InputBorder.none,
                              enabledBorder: InputBorder.none,
                              focusedBorder: InputBorder.none,
                              disabledBorder: InputBorder.none,
                              focusedErrorBorder: InputBorder.none,
                              hintText:
                                  getTranslated(context, 'filterByHistory'),
                              hintStyle: TextStyle(
                                fontWeight: FontWeight.bold,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontStyle: FontStyle.normal,
                                fontSize: checkIfWeb(context)
                                    ? AppFontsSizeManager.s34.sp
                                    : AppFontsSizeManager.s18_6.sp,
                                color: AppColors.primaryColor,
                              ),
                              contentPadding: EdgeInsets.symmetric(
                                  horizontal: AppPadding.p20.w),
                              suffixIcon: IconButton(
                              onPressed: () {
                               _selectDate(context);
 
                              },

                              icon: SvgPicture.asset(
                                    AssetsManager.filterIconPath,
                                    width: checkIfWeb(context)
                                        ? AppSize.w48.w
                                        : convertPtToPx(AppSize.w26.w),
                                  
                                ),
                              ),
                            ),
                            style: TextStyle(
                              fontWeight: FontWeight.bold,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              fontSize: checkIfWeb(context)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s18_6.sp,
                              color: AppColors.primaryColor,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                  InkWell(
                    splashColor: Colors.white.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        filterQuery = FirebaseFirestore.instance
                            .collection(Paths.appAppointments)
                            .where('consult.uid', isEqualTo: user!.uid)
                            .where('appointmentStatus', isEqualTo: "closed")
                            .orderBy('secondValue', descending: true);
                        time = getTranslated(context, "filter");
                      });
                    },
                    child: Center(
                      child: Text(
                        getTranslated(context, "allAppointment"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s26_6.sp,
                          color: AppColors.black1,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h10.h,
                  ),
                  //card
                  Expanded(
                    child: PaginateFirestore(
                      key: ValueKey(filterQuery),
                      itemBuilderType: PaginateBuilderType.listView,
                      separator: SizedBox(
                        height: AppSize.h20.h,
                      ),
                      padding: EdgeInsets.only(
                          left:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppSize.w0_25
                                  : convertPtToPx(AppSize.w25.w),
                          right:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppSize.w0_25
                                  : convertPtToPx(AppSize.w25.w),
                          bottom: AppPadding.p16,
                          top: AppPadding.p16),
                      //Change types accordingly
                      itemBuilder: (context, documentSnapshot, index) {
                        return CallHistoryWidget(
                          appointment: AppAppointments.fromMap(
                              documentSnapshot[index].data() as Map),
                          loggedUser: user!,
                          theme: "light",
                        );
                      },
                      query: filterQuery,
                      isLive: true,
                    ),
                  )
                ],
              );
            } else {
              return Center(child: LoadWidget());
            }
          },
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;


  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          time = DateFormat('yyyy-MM-dd').format(picked);
          displayedTime = time;
      //     // loadDates = true;
      //     // todayAppointmentList = [];
      //     // dateText = getTranslated(context, "load");
        });
      }
    } catch (e) {
    
    }
  }
}
