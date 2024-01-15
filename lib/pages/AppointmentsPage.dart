import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/TabButton.dart';
import 'package:jeras/widget/component/tab_bar/custom_tab_bar.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../widget/userAppointmentWiget.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_constat.dart';
import '../config/colors_file.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';

class AppointmentsPage extends StatefulWidget {
  @override
  _AppointmentsPageState createState() => _AppointmentsPageState();
}

class _AppointmentsPageState extends State<AppointmentsPage>
    with AutomaticKeepAliveClientMixin<AppointmentsPage> {
  late AccountBloc accountBloc;
  GroceryUser? user;
  bool fixed = true, wait = false, closed = false;
  bool active = false;
  late Query query;

  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.add(GetLoggedUserEvent());
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: BlocBuilder(
        bloc: accountBloc,
        builder: (context, state) {
          if (state is GetLoggedUserInProgressState) {
            print('<<<<<<<<<<<1>>>>>>>>>>>>>');
            return Center(child: CircularProgressIndicator());
          } else if (state is GetLoggedUserCompletedState) {
            print('<<<<<<<<<<<<2>>>>>>>>>>>>');
            user = state.user;
            query = FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .where('user.uid', isEqualTo: user!.uid)
                .where('appointmentStatus', isEqualTo: "open")
                .orderBy('secondValue', descending: true);
            //appointment data o
            return Column(
              children: <Widget>[
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? SizedBox(height: AppSize.h20.h)
                    : SizedBox(height: AppSize.h24.h),
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? Divider(
                        height: AppSize.h1.h,
                        color: AppColors.grey4,
                      )
                    : SizedBox(),
                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? SizedBox(height: AppSize.h42_6.h)
                    : SizedBox(),
                //button sl

                Center(
                  child: user == null
                      ? SizedBox()

                      ///---- TabBar ----///
                      : CustomTabBar(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w1362.w
                                  : AppSize.w509_3.w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h120.h
                                  : AppSize.w72.h,
                          radius:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppRadius.r30.r
                                  : AppRadius.r25.r,
                          backgroundColor: AppColors.linear2,
                          buttons: [
                            //button x
                            TabButton(
                                onPress: () {
                                  setState(() {
                                    fixed = true;
                                    wait = false;
                                    closed = false;
                                  });
                                },
                                Width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w225.w
                                    : AppSize.w244.w,
                                Height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h79.h
                                    : AppSize.h50_6.h,
                                ButtonRadius: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppRadius.r10.r
                                    : AppRadius.r10_6.r,
                                ButtonColor:
                                    fixed ? AppColors.shadoColor : null,
                                Title: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? getTranslated(context, "fixed")
                                    : getTranslated(context, "futureAppoint"),
                                TextFont: size.width >= 500
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(context, "Ithra"),
                                TextSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? 27.sp
                                    : AppFontsSizeManager.s21_3.sp,
                                TextColor:
                                    fixed ? AppColors.white : AppColors.pink),
                            //button y
                            TabButton(
                                onPress: () {
                                  setState(() {
                                    wait = false;
                                    fixed = false;
                                    closed = true;
                                  });
                                },
                                Width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w225.w
                                    : AppSize.w244.w,
                                Height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h79.h
                                    : AppSize.h50_6.h,
                                ButtonRadius: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppRadius.r10.r
                                    : AppRadius.r10_6.r,
                                ButtonColor:
                                    closed ? AppColors.shadoColor : null,
                                Title: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? getTranslated(context, "closed")
                                    : getTranslated(context, "doneAppoint"),
                                TextFont: size.width >= 500
                                    ? getTranslated(context, "Ithra")
                                    : getTranslated(context, "Ithra"),
                                TextSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s26_6.sp
                                    : AppFontsSizeManager.s21_3.sp,
                                TextColor:
                                    closed ? AppColors.white : AppColors.pink),
                          ],
                          padding: (kIsWeb ||
                                  size.width >= AppConstants.kIsWebValue)
                              ? EdgeInsets.symmetric(
                                  horizontal: AppSize.w166.w,
                                  vertical: AppSize.h18.h)
                              : EdgeInsets.all((kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 20
                                  : AppPadding.p10_6.r)),
                ),
                SizedBox(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h69_8.h
                      : AppSize.h21_3.h,
                ),
                //accepted appointments
                fixed
                    ? Expanded(
                        child: PaginateFirestore(
                          //key: ValueKey(query),
                          itemBuilderType: PaginateBuilderType.gridView,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                                  crossAxisCount: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 2
                                      : 1,
                                  crossAxisSpacing: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 50
                                      : 0,
                                  mainAxisSpacing: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 50
                                      : AppSize.h32.h,
                                  mainAxisExtent: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? (AppSize.h400.h)
                                      : AppSize.h205.h),
                          padding: EdgeInsets.only(
                              left: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppSize.w0_17
                                  : AppPadding.p32.w,
                              right: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * .17
                                  : AppPadding.p32.w,
                              bottom: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppPadding.p16
                                  : 0,
                              top: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppPadding.p16
                                  : 0),
                          //Change types accordingly
                          itemBuilder: (context, documentSnapshot, index) {
                            return UserAppointmentWiget(
                              appointment: AppAppointments.fromMap(
                                  documentSnapshot[index].data() as Map),
                              loggedUser: user!,
                            );
                          },
                          query: FirebaseFirestore.instance
                              .collection(Paths.appAppointments)
                              .where('user.uid', isEqualTo: user!.uid)
                              .where('appointmentStatus', isEqualTo: "open")
                              .orderBy('secondValue', descending: true),
                          isLive: true,
                          onEmpty: Text(
                            getTranslated(context, 'noAppointmentYet'),
                            style: TextStyle(
                                color: const Color(0xffc7c6c6),
                                fontWeight: AppFontsWeightManager.bold300,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontStyle: FontStyle.normal,
                                fontSize: AppFontsSizeManager.s20.sp),
                          ),
                          onError: (e) => Text(e.toString()),
                        ),
                      )
                    : SizedBox(),
                //r appointments
                closed
                    ? Expanded(
                        child: PaginateFirestore(
                          //key: ValueKey(query),
                          itemBuilderType: PaginateBuilderType.gridView,
                          gridDelegate:
                              SliverGridDelegateWithFixedCrossAxisCount(
                            crossAxisCount: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 2
                                : 1,
                            crossAxisSpacing: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 50
                                : 0,
                            mainAxisSpacing: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 50
                                : AppSize.h32.h,
                            mainAxisExtent: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? (AppSize.h400.h)
                                : AppSize.h205.h,
                          ),
                          padding: EdgeInsets.only(
                              left: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppPadding.p0_17
                                  : AppPadding.p32.w,
                              right: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppPadding.p0_17
                                  : AppPadding.p32.w,
                              bottom: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppPadding.p16
                                  : 0,
                              top: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppPadding.p16
                                  : 0),
                          //Change types accordingly
                          itemBuilder: (context, documentSnapshot, index) {
                            return UserAppointmentWiget(
                              done: true,
                              appointment: AppAppointments.fromMap(
                                  documentSnapshot[index].data() as Map),
                              loggedUser: user!,
                            );
                          },
                          query: FirebaseFirestore.instance
                              .collection(Paths.appAppointments)
                              .where('user.uid', isEqualTo: user!.uid)
                              .where('appointmentStatus', isEqualTo: "closed")
                              .orderBy('secondValue', descending: true),
                          isLive: true,
                          onEmpty: Text(
                            getTranslated(context, 'noAppointmentYet'),
                            style: TextStyle(
                                color: const Color(0xffc7c6c6),
                                fontWeight: AppFontsWeightManager.bold300,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontStyle: FontStyle.normal,
                                fontSize: AppFontsSizeManager.s20.sp),
                          ),
                          onError: (e) => Text(e.toString()),
                        ),
                      )
                    : SizedBox()
              ],
            );
          } else {
            print('<<<<<<<<<<<<<<<3>>>>>>>>>>>>>>>');
            return Center(child: CircularProgressIndicator());
          }
        },
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
