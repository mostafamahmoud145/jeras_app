import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl/intl.dart';

import '../../localization/localization_methods.dart';
import '../../models/DevelopTechSupport.dart';
import '../../models/user.dart';
import '../../screens/DevelopTechSupport/developMessageScreen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';

class DevelopListItem extends StatelessWidget {
  final Size size;
  final DevelopTechSupport item;
  final GroceryUser user;
  final String theme;

  const DevelopListItem({
    required this.size,
    required this.item,
    required this.user,
    required this.theme,
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

    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => DevelopMessageScreen(
              develop: item,
              user: user,
            ),
          ),
        );
      },
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only(
            left: AppPadding.p5,
            right: AppPadding.p5,
            bottom: AppPadding.p10,
            top: AppPadding.p10),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.r12),
        ),
        child: Row(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Icon(
              Icons.lightbulb_outline_rounded,
              size: AppSize.w40,
              color: AppColors.black2,
            ),
            Padding(
              padding: const EdgeInsets.only(
                  left: AppPadding.p5, right: AppPadding.p5),
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
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppSize.w0_4
                                : size.width * AppSize.w0_5,
                        child: Text(
                          item.userName,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s14_5,
                            color: AppColors.black2,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ),
                      Text(
                        // date,
                        item.sendTime != null
                            ? '${dateFormat.format(item.sendTime.toDate())}'
                            : '..',
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s13,
                          color: AppColors.black2,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ],
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      Container(
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? size.width * AppSize.w0_4
                                : size.width * AppSize.w0_6,
                        child: item.title == null
                            ? SizedBox()
                            : (item.title != "imageFile" &&
                                    item.title != "voiceFile")
                                ? Text(
                                    item.title,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      fontSize: AppFontsSizeManager.s13,
                                      color: AppColors.black2,
                                      fontWeight: FontWeight.w400,
                                    ),
                                  )
                                : Row(
                                    children: [
                                      Icon(
                                        Icons.file_copy_outlined,
                                        size: AppSize.w15,
                                        color: theme == "light"
                                            ? Colors.white.withOpacity(0.6)
                                            : Colors.black.withOpacity(0.6),
                                      ),
                                      Text(
                                        getTranslated(context, "attatchment"),
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontSize: AppFontsSizeManager.s13,
                                          color: AppColors.black2,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    ],
                                  ),
                      ),
                      SizedBox(
                        width: AppSize.w2,
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
