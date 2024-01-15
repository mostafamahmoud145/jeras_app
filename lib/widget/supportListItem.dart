import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';

import '../../localization/localization_methods.dart';
import '../../models/SupportList.dart';
import '../../models/user.dart';
import '../../screens/supportMessagesScreen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';

class SupportListItem extends StatelessWidget {
  final Size size;
  final SupportList item;
  final GroceryUser user;
  final String theme;

  const SupportListItem({
    required this.size,
    required this.item,
    required this.user,
    required this.theme,
    //@required this.index,
    //@required this.notificationList,
  });

  void showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    if (item.supportMessageNum == null) {}
    return GestureDetector(
      onTap: () {
        (item.openingStatus && user.userType == "SUPPORT")
            ? showSnack(getTranslated(context, "otherSupport"), context)
            : Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SupportMessageScreen(
                    item: item,
                    user: user,
                    theme: theme,
                  ),
                ),
              );
      },
      child: Container(
        width: size.width,
        // padding: const EdgeInsets.only(  left: 5.0, right: 5.0, bottom: 10.0, top: 10.0),
        decoration: BoxDecoration(
          color: Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.r12.r),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h97.h
                  : AppSize.h60.h,
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w198.w
                  : AppSize.w60.w,
              decoration:
                  BoxDecoration(shape: BoxShape.circle, color: AppColors.pink),
              child: Center(
                child: SvgPicture.asset(
                  AssetsManager.whiteHeadphonesIconPath,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w50.w
                      : AppSize.w30_6.w,
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h56_9.h
                      : AppSize.h34_9.h,
                ),
              ),
            ),
            SizedBox(
              width: AppSize.w5.w,
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                // name
                Container(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w1148.w
                      : AppSize.w196.w,
                  child: Text(
                    user.userType == "SUPPORT"
                        ? item.userName == "-1"
                            ? item.owner
                            : item.userName.toString()
                        : '${getTranslated(context, "supportTeam")}',
                    style: TextStyle(
                      fontFamily:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? getTranslated(context, "Ithralight")
                              : getTranslated(context, "Ithra"),
                      fontSize:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppFontsSizeManager.s34.sp
                              : AppFontsSizeManager.s18_6.sp,
                      color: AppColors.black1,
                      //fontWeight: FontWeight.bold,
                      //letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ),
                //subtitle
                Container(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w1148.w
                      : AppSize.w196.w,
                  child: item.lastMessage == null
                      ? SizedBox()
                      : (item.lastMessage != "imageFile" &&
                              item.lastMessage != "voiceFile")
                          ? Text(
                              item.lastMessage,
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s19.sp
                                    : AppFontsSizeManager.s16.sp,
                                color: AppColors.greyColor,
                                fontWeight: FontWeight.w400,
                                letterSpacing: AppConstants.letterSpacing0_3,
                              ),
                            )
                          : Row(
                              children: [
                                Icon(
                                  Icons.file_copy_outlined,
                                  size: AppSize.w15,
                                  color: theme == "light"
                                      ? Colors.black.withOpacity(0.6)
                                      : AppColors.white.withOpacity(0.6),
                                ),
                                SizedBox(width: AppSize.w3.w),
                                Text(
                                  getTranslated(context, "attatchment"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: AppFontsSizeManager.s13.sp,
                                    color: theme == "light"
                                        ? Colors.black.withOpacity(0.6)
                                        : AppColors.white,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing:
                                        AppConstants.letterSpacing0_3,
                                  ),
                                ),
                              ],
                            ),
                ),
              ],
            ),
            //time
            Spacer(),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.start,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                (user.userType == "SUPPORT" &&
                        item.supportMessageNum != null &&
                        item.supportMessageNum > 0)
                    ? Container(
                        height: AppSize.h20.h,
                        width: AppSize.w20.w,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          //border: Border.all(width: 1, color: Colors.red)
                        ),
                        child: Center(
                          child: Text(
                            user.userType == "SUPPORT"
                                ? '${item.supportMessageNum.toString()}'
                                : '${item.userMessageNum.toString()}',
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize: AppFontsSizeManager.s10.sp,
                              color: theme == "light"
                                  ? AppColors.white
                                  : AppColors.black,
                              fontWeight: FontWeight.w400,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ),
                      )
                    : (user.userType != "SUPPORT" &&
                            item.supportMessageNum != null &&
                            item.userMessageNum > 0)
                        ? Container(
                            height: AppSize.h20.h,
                            width: AppSize.w20.w,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: AppColors.green,
                              //border: Border.all(width: 1, color: Colors.red)
                            ),
                            child: Center(
                              child: Text(
                                user.userType == "SUPPORT"
                                    ? '${item.supportMessageNum.toString()}'
                                    : '${item.userMessageNum.toString()}',
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: 10.0.sp,
                                  color: theme == "light"
                                      ? AppColors.white
                                      : AppColors.black,
                                  fontWeight: FontWeight.w400,
                                  letterSpacing: AppConstants.letterSpacing0_3,
                                ),
                              ),
                            ),
                          )
                        : SizedBox(),
                Text(
                  // date,
                  item.messageTime != null
                      ? '${dateFormat.format(item.messageTime.toDate())}'
                      : '..',
                  style: TextStyle(
                    fontFamily:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? getTranslated(context, "Montserratmedium")
                            : getTranslated(context, "Montserrat"),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 23.sp
                        : 13.3.sp,
                    color: AppColors.greyColor,
                    fontWeight: FontWeight.w400,
                    letterSpacing: AppConstants.letterSpacing0_3,
                  ),
                ),
              ],
            ),
            /* Padding(
              padding: const EdgeInsets.only(left: AppPadding.p5, right: AppPadding.p5),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.max,
                children: <Widget>[
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    mainAxisSize: MainAxisSize.max,
                    children: [
                      Container(
                        width: size.width * .5,
                        child: Text(
                          user.userType == "SUPPORT"
                              ? item.userName == "-1"
                              ? item.owner
                              : item.userName.toString()
                              : '${getTranslated(context, "supportTeam")}',
                          style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                            fontSize: 15,
                            color: AppAppColors.black,
                            //fontWeight: FontWeight.bold,
                            //letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
                      Text(
                        // date,
                        item.messageTime != null
                            ? '${dateFormat.format(item.messageTime.toDate())}'
                            : '..',
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s13,
                          color: AppColors.grey,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width: size.width * .6,
                        child: item.lastMessage == null
                            ? SizedBox()
                            : (item.lastMessage != "imageFile" &&
                            item.lastMessage != "voiceFile")
                            ? Text(
                          item.lastMessage,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                            fontSize: 11.0,
                            color: AppColors.grey,
                            fontWeight: FontWeight.w400,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        )
                            : Row(
                          children: [
                            Icon(
                              Icons.file_copy_outlined,
                              size: 15,
                              color: theme == "light"
                                  ?Colors.black.withOpacity(0.6)
                                  : AppColors.white.withOpacity(0.6),
                            ),
                            SizedBox(width: 3),
                            Text(
                              getTranslated(context, "attatchment"),
                              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s13,
                                color: theme == "light"
                                    ? Colors.black.withOpacity(0.6)
                                    : AppColors.white,
                                fontWeight: FontWeight.w400,
                                letterSpacing: AppConstants.letterSpacing0_3,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(
                        width: 2,
                      ),
                      (user.userType == "SUPPORT" &&item.supportMessageNum!=null&&
                          item.supportMessageNum > 0)
                          ? Container(
                        height: AppSize.h20,
                        width: AppSize.w20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          //border: Border.all(width: 1, color: Colors.red)
                        ),
                        child: Center(
                          child: Text(
                            user.userType == "SUPPORT"
                                ? '${item.supportMessageNum.toString()}'
                                : '${item.userMessageNum.toString()}',
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 10.0,
                              color: theme == "light"
                                  ? AppColors.white
                                  : AppColors.black,
                              fontWeight: FontWeight.w400,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ),
                      )
                          : (user.userType != "SUPPORT" &&item.supportMessageNum!=null&&
                          item.userMessageNum > 0)
                          ? Container(
                        height: AppSize.h20,
                        width: AppSize.w20,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          color: Colors.green,
                          //border: Border.all(width: 1, color: Colors.red)
                        ),
                        child: Center(
                          child: Text(
                            user.userType == "SUPPORT"
                                ? '${item.supportMessageNum.toString()}'
                                : '${item.userMessageNum.toString()}',
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 10.0,
                              color: theme == "light"
                                  ? AppColors.white
                                  : AppColors.black,
                              fontWeight: FontWeight.w400,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ),
                      )
                          : SizedBox(),
                    ],
                  ),
                ],
              ),
            ),*/
          ],
        ),
      ),
    );
  }
}
