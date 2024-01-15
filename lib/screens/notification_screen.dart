import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/custom_back_button.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/user_notification.dart';
import '../../widget/notification_item.dart';
import '../config/app_constat.dart';
import '../config/colors_file.dart';
import '../controller/blocs/notification_bloc/notification_bloc.dart';
import '../models/user_notification.dart' as prefix;
import '../widget/component/IconButton.dart';

class NotificationScreen extends StatefulWidget {
  final UserNotification userNotification;

  const NotificationScreen({Key? key, required this.userNotification})
      : super(key: key);

  @override
  _NotificationScreenState createState() => _NotificationScreenState();
}

class _NotificationScreenState extends State<NotificationScreen>
    with SingleTickerProviderStateMixin {
  late NotificationBloc notificationBloc;
  bool isLoading = true;
  String theme = "light";
  String lang = "ar";

  @override
  void initState() {
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
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
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    List<prefix.Notification> notificationList =
        widget.userNotification.notifications.reversed.toList();
    return Scaffold(
      body: Column(
        children: <Widget>[
          //header section
          Container(
              width: size.width,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p35,
                    right: AppPadding.p35,
                    top: AppPadding.p40,
                    bottom: AppPadding.p15),
                child: Row(
                  children: [
                    CustomBackButton(),
                   
                    SizedBox(width: AppSize.w10.w),
                    Text(
                      getTranslated(context, "notification"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s31.sp
                                  : AppFontsSizeManager.s16.sp,
                          color: Colors.black.withOpacity(0.8),
                          fontWeight: FontWeight.w300),
                    ),
                    const Spacer(),
                    Builder(builder: (context) {
                      return InkWell(
                        splashColor: Colors.white.withOpacity(0.6),
                        onTap: () {
                          deleteAllNotificaton(size);
                        },
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.transparent,
                          ),
                          child: SvgPicture.asset(
                            AssetsManager.delete2IconPath,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w29_5.w
                                : AppSize.w22_1.w,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h34.h
                                : AppSize.h25.h,
                          ),
                        ),
                      );
                    }),
                  ],
                ),
              )),
          Center(
              child: Container(
                  color: AppColors.borderLightGrey,
                  height: AppSize.h0_5.h,
                  width: size.width)),
          //notification data
          Expanded(
            child: ListView.separated(
              padding: EdgeInsets.symmetric(
                horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.width * AppSize.w0_06
                    : AppSize.w20.w,
                vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.height * AppSize.h0_06
                    : AppSize.h25.h,
              ),
              itemBuilder: (context, index) {
                return NotificationItem(
                  size: size,
                  userNotification: widget.userNotification,
                  notificationList: notificationList,
                  index: index,
                  theme: theme,
                  
                );
              },
              separatorBuilder: (context, index) {
                return SizedBox(
                  height: AppSize.h20,
                );
              },
              itemCount: notificationList.length,
            ),
          ),
        ],
      ),
    );
  }

  deleteAllNotificaton(Size size) {
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
              ],
            ),
            SizedBox(height: AppSize.h33_3.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "DoYouWantDeleteAllNotifi"),
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
                          String userUid =
                              FirebaseAuth.instance.currentUser!.uid;
                          FirebaseFirestore.instance
                              .collection('UserNotifications')
                              .doc(userUid)
                              .delete();
                          //notificationBloc.add(GetAllNotificationsEvent(userUid));
                          Navigator.of(context)
                            ..pop()
                            ..pop();
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
                              getTranslated(context, 'delete'),
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
                              getTranslated(context, 'cancel'),
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
}
