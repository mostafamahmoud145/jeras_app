import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/promoCode.dart';
import '../../screens/promoCodesScreens/editPromoCodeScreen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';

class PromoListItem extends StatelessWidget {
  final PromoCode code;
  final theme;

  PromoListItem({required this.code, this.theme});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return InkWell(
      splashColor: Colors.red.withOpacity(0.6),
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => EditPromoCodeScreen(promoCode: code),
          ),
        );
      },
      child: Container(
        padding: EdgeInsets.all((kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppPadding.p20 : AppPadding.p10),
        decoration: BoxDecoration(
          color: AppColors.grey4,
          borderRadius: BorderRadius.circular(AppRadius.r25),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, "proCode"),
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.textLightGrey,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    Text(
                      code.code,
                      textAlign: TextAlign.start,
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black2,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ],
                ),
                InkWell(
                  onTap: () {
                    Clipboard.setData(ClipboardData(text: code.code));
                    showSnack(getTranslated(context, "copyDone"), context);
                  },
                  child: Icon(
                    Icons.copy,
                    size: AppSize.w18,
                    color: code.promoCodeStatus ? AppColors.green : AppColors.red,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h10 : AppSize.h2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "owner") + ": ",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.textLightGrey,
                    fontSize: AppFontsSizeManager.s15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  code.ownerName,
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black2,
                    fontSize: AppFontsSizeManager.s15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: AppConstants.letterSpacing0_3,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ?  AppSize.h10 : AppSize.h2,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "discount") + ": ",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.textLightGrey,
                    fontSize: AppFontsSizeManager.s15,
                    fontWeight: FontWeight.w400,
                  ),
                ),
                Text(
                  code.discount.toString() + "%",
                  textAlign: TextAlign.start,
                  overflow: TextOverflow.ellipsis,
                  maxLines: 1,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black2,
                    fontSize: AppFontsSizeManager.s15,
                    fontWeight: FontWeight.w400,
                    letterSpacing: AppConstants.letterSpacing0_3,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ?  AppSize.h10 : AppSize.h2,
            ),
            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h15 : AppSize.h5,
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  height: AppSize.h40,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_05
                      : size.width * AppSize.w0_2,
                  decoration: BoxDecoration(
                    color: AppColors.blue50,
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Center(
                    child: Text(
                      code.usedNumber.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h15 : AppSize.h5,
                ),
                Container(
                  height: AppSize.h40,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_5
                      : size.width * AppSize.w0_2,
                  decoration: BoxDecoration(
                    color: AppColors.pink50,
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Center(
                    child: Text(
                      code.promoCodeStatus.toString(),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
                SizedBox(
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h15 : AppSize.h5,
                ),
                Container(
                  height: AppSize.h40,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_05
                      : size.width * AppSize.w0_2,
                  decoration: BoxDecoration(
                    color: Colors.amber[100],
                    borderRadius: BorderRadius.circular(AppRadius.r20),
                  ),
                  child: Center(
                    child: Text(
                      code.type,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s13,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            SizedBox(
              height: AppSize.h6,
            ),
          ],
        ),
      ),
    );
  }

  void showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }
}
