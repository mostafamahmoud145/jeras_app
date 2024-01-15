import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/widget/responsive.dart';

import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../models/chat.dart';
import '../screens/chatDetailScreen.dart';

class ChatListItem extends StatelessWidget {
  final Size size;
  final Chat item;
  final GroceryUser user;

  const ChatListItem({
    required this.size,
    required this.item,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    String photoUrl;
    if (user.userType == "USER")
      photoUrl = item.consult.image!;
    else
      photoUrl = item.user.image!;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => ChatDetailScreen(
              item: item,
              user: user,
              theme: 'light',
            ),
          ),
        );
      },
      child: Column(
        children: [
          Container(
            width: size.width,
            padding: EdgeInsets.only(
                left: AppPadding.p5.r,
                right: AppPadding.p5.r,
                bottom: AppPadding.p10.r,
                top: AppPadding.p10.r),
            decoration: BoxDecoration(
              color: Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.r12),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h80.h
                      : AppSize.h50,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.w80.w
                      : AppSize.w50,
                  decoration: BoxDecoration(
                    border:
                        Border.all(color: AppColors.white, width: AppSize.w0_5),
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                  child: photoUrl.isEmpty
                      ? Center(
                          child: Image.asset(
                            AssetsManager.whiteJerasLogoIconPath,
                            //width:  (kIsWeb||size.width >= 500)
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h80.h
                                : AppSize.h50,
                          ),
                        )
                      : ClipRRect(
                          borderRadius: BorderRadius.circular(AppRadius.r100),
                          child: FadeInImage.assetNetwork(
                            placeholder: AssetsManager.lodeGif,
                            placeholderScale: 0.5,
                            imageErrorBuilder: (context, error, stackTrace) =>
                                Image.asset(
                                    AssetsManager.whiteJerasLogoIconPath,
                                    width: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.w80.w
                                        : AppSize.w50,
                                    height: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.h80.h
                                        : AppSize.h50,
                                    fit: BoxFit.fill),
                            image: photoUrl,
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
                Expanded(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: AppPadding.p5.w, right: AppPadding.p5.w),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      mainAxisAlignment: MainAxisAlignment.start,
                      mainAxisSize: MainAxisSize.max,
                      children: <Widget>[
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          mainAxisSize: MainAxisSize.max,
                          children: [
                            Expanded(
                              child: Container(
  
                                child: Text(
                                  user.userType == "USER"
                                      ? item.consult.name!
                                      : item.user.name!,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontWeight: FontWeight.w100,
                                    fontSize: (kIsWeb ||
                                            size.width >= AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s25
                                        : AppFontsSizeManager.s18_6.sp,
                                    color: AppColors.black,
                                  ),
                                ),
                              ),
                            ),
                            Text(
                              // date,
                              item.messageTime != null
                                  ? '${dateFormat.format(item.messageTime.toDate())}'
                                  : '..',
                              style: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Montserratmedium"),
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s20
                                    : AppFontsSizeManager.s16.sp,
                                color: AppColors.grey,
                                fontWeight: FontWeight.normal,
                                letterSpacing: AppConstants.letterSpacing0_3,
                              ),
                            ),
                          ],
                        ),
                    SizedBox(
                      height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppSize.w0_5
                                  :  AppSize.w10_6.h,
                    ),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? size.width * AppSize.w0_5
                                  : size.width * AppSize.w0_6,
                              child: item.lastMessage == null
                                  ? SizedBox()
                                  : (item.lastMessage != "imageFile" &&
                                          item.lastMessage != "voiceFile")
                                      ? Text(
                                          item.lastMessage,
                                          maxLines: 1,
                                          overflow: TextOverflow.ellipsis,
                                          style: TextStyle(
                                              fontFamily: getTranslated(
                                                  context, "Ithralight"),
                                              fontSize: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppFontsSizeManager.s20
                                                  : AppFontsSizeManager.s16.sp,
                                              color: AppColors.grey,
                                              fontWeight: FontWeight.normal),
                                        )
                                      : Row(
                                          children: [
                                            Icon(Icons.file_copy_outlined,
                                                size: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w20
                                                    : AppSize.w15,
                                                color: Colors.white
                                                    .withOpacity(0.6)),
                                            Text(
                                              getTranslated(
                                                  context, "attatchment"),
                                              style: TextStyle(
                                                fontFamily: getTranslated(
                                                    context, "Ithra"),
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppFontsSizeManager.s20
                                                    : AppFontsSizeManager.s10,
                                                color: AppColors.white,
                                                fontWeight: FontWeight.normal,
                                              ),
                                            ),
                                          ],
                                        ),
                            ),
                            SizedBox(
                              width: AppSize.w2,
                            ),
                            (user.userType == "CONSULTANT" &&
                                    item.consultMessageNum > 0)
                                ? Container(
                                    height: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.h40
                                        : AppSize.h20,
                                    width: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppSize.w40
                                        : AppSize.w20,
                                    decoration: BoxDecoration(
                                      shape: BoxShape.circle,
                                      color: Colors.green,
                                      //border: Border.all(width: 1, color: Colors.red)
                                    ),
                                    child: Center(
                                      child: Text(
                                        user.userType == "CONSULTANT"
                                            ? '${item.consultMessageNum.toString()}'
                                            : '${item.userMessageNum.toString()}',
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontSize: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppFontsSizeManager.s20
                                              : AppFontsSizeManager.s10,
                                          color: AppColors.white,
                                          fontWeight: FontWeight.normal,
                                        ),
                                      ),
                                    ),
                                  )
                                : (user.userType != "CONSULTANT" &&
                                        item.userMessageNum > 0)
                                    ? Container(
                                        height: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h40
                                            : AppSize.h20,
                                        width: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.w40
                                            : AppSize.w20,
                                        decoration: BoxDecoration(
                                          shape: BoxShape.circle,
                                          color: Colors.green,
                                          //border: Border.all(width: 1, color: Colors.red)
                                        ),
                                        child: Center(
                                          child: Text(
                                            user.userType == "CONSULTANT"
                                                ? '${item.consultMessageNum.toString()}'
                                                : '${item.userMessageNum.toString()}',
                                            style: TextStyle(
                                              fontFamily:
                                                  getTranslated(context, "Ithra"),
                                              fontSize: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppFontsSizeManager.s20
                                                  : AppFontsSizeManager.s10,
                                              color: AppColors.white,
                                              fontWeight: FontWeight.normal,
                                              letterSpacing:
                                                  AppConstants.letterSpacing0_3,
                                            ),
                                          ),
                                        ),
                                      )
                                    : SizedBox(),
                          ],
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),
          SizedBox(
            height: AppSize.h10,
          ),
        ],
      ),
    );
  }
}
