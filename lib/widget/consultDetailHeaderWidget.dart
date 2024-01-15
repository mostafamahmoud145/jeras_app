import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
// import 'package:firebase_dynamic_links/firebase_dynamic_links.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/api/dynamicLink.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:share_plus/share_plus.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../controller/blocs/notification_bloc/notification_bloc.dart';
import '../models/user_notification.dart';
import 'custom_back_button.dart';

class ConsultDetailHeaderWidget extends StatefulWidget {
  final GroceryUser? loggedUser;
  final GroceryUser consultant;

  ConsultDetailHeaderWidget({this.loggedUser, required this.consultant});

  @override
  _ConsultDetailHeaderWidgetState createState() =>
      _ConsultDetailHeaderWidgetState();
}

class _ConsultDetailHeaderWidgetState extends State<ConsultDetailHeaderWidget>
    with SingleTickerProviderStateMixin {
  final GlobalKey<ScaffoldState> _scaffoldKey = new GlobalKey<ScaffoldState>();

  bool selected = false, loadInterest = true, sharing = false;
  late NotificationBloc notificationBloc;
  late UserNotification userNotification;
  User? currentUser;
  GroceryUser? currentUser2;
  String? userImage, lang, userName;

  @override
  void initState() {
    super.initState();
    notificationBloc = BlocProvider.of<NotificationBloc>(context);
  }

  share() async {
    try {
      setState(() {
        sharing = true;
      });
      String userUrl =
          "https://jerasnew.web.app/conslultant?consultant_id=${widget.consultant.uid}";
      String url = await dynamicLinks.shareConsultantByDynamicLink(
          userUrl, context, widget.consultant);
      Share.share(url); //${dynamicLink.shortUrl.toString()}
      setState(() {
        sharing = false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Column(
      children: [
        Container(
          width: size.width,
          decoration: BoxDecoration(
            color: const Color.fromRGBO(255, 255, 255, 1),
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p140.w
                  : AppPadding.p32.w,
              right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p140.w
                  : AppPadding.p32.w,
              top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p69.h
                  : AppPadding.p64.h,
              bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppPadding.p42.h
                  : AppPadding.p16.h,
            ),
            child: Center(
              child: Row(
                // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  IconButton1(
                    onPress: Navigator.of(context).pop,
                    Width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w75.w
                        : AppSize.w50_6.w,
                    Height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w75.h
                        : AppSize.h50_6.h,
                    ButtonRadius:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppRadius.r16
                            : AppRadius.r10_6.r,
                    IconWidth:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppSize.w30.w
                            : AppSize.w32.w,
                    IconHeight:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppSize.h30.w
                            : AppSize.h32.h,
                    IconColor: Theme.of(context).primaryColor,
                    Icon: lang == "ar"
                        ? AssetsManager.whiteArrowRight
                        : AssetsManager.whiteArrowLeft,
                    ButtonBackground: AppColors.white,
                  ),
                  SizedBox(width: convertPtToPx(AppSize.w16).w),

                  /// Account details.
                  Text(
                    getTranslated(context, "accountDetails"),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppFontsSizeManager.s34.sp
                          : AppFontsSizeManager.s21_3.sp,
                      fontWeight: AppFontsWeightManager.semiBold,
                      color: AppColors.black1,
                    ),
                  ),

                ],
              ),
            ),
          ),
        ),

        Center(
            child: Container(
                color: AppColors.grey2, height: AppSize.h1, width: size.width)),
      ],
    );
  }

  BoxDecoration decoration(size) {
    return BoxDecoration(
      color: AppColors.white,
      borderRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? BorderRadius.circular(AppRadius.r30.r)
          : BorderRadius.circular(AppRadius.r8),
      boxShadow: [
        BoxShadow(
          color: Color.fromRGBO(123, 108, 150, 0.18),
          blurRadius: 8.0,
          spreadRadius: 0.0,
          offset: Offset(0.0, 1.0), // shadow direction: bottom right
        )
      ],
    );
  }

  Widget noNotificationWidget(size) {
    return Container(
      height: AppSize.h35,
      width: AppSize.w35,
      decoration: decoration(size),
      child: Center(
        child: ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.r50),
          child: Material(
            color: AppColors.white,
            child: InkWell(
              splashColor: Colors.white.withOpacity(0.6),
              onTap: () {
                Fluttertoast.showToast(
                    msg: getTranslated(context, "noNotification"),
                    toastLength: Toast.LENGTH_SHORT,
                    gravity: ToastGravity.BOTTOM,
                    backgroundColor: AppColors.red,
                    textColor: AppColors.white,
                    fontSize: AppFontsSizeManager.s16);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.white,
                ),
                width: AppSize.w25,
                height: AppSize.h25,
                child: SvgPicture.asset(
                  AssetsManager.notificationIconPath,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
