
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/intl.dart';
import 'package:linkwell/linkwell.dart';

import '../../localization/localization_methods.dart';
import '../../models/generalNotifications.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';

class GeneralNotificationItem extends StatelessWidget {
  final GeneralNotifications item;

  const GeneralNotificationItem({
    required this.item,
  });

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd MMM yyyy, hh:mm a');
    return Column(
      children: [
        Container(
          width: size.width,
          padding: const EdgeInsets.only(
              left: AppPadding.p10, right: AppPadding.p10, bottom: AppPadding.p10, top: AppPadding.p10),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.04),
            borderRadius: BorderRadius.circular(AppRadius.r12),
          ),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                children: [
                  Text(
                    getTranslated(context, "title")+" : ",
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s14_5,
                       color: AppColors.black87,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                  Expanded(
                    child: Text(
                      item.title.toString(),
                      overflow: TextOverflow.ellipsis,
                      style: GoogleFonts.poppins(
                        fontSize: AppFontsSizeManager.s13,
                       color: AppColors.black54,
                        fontWeight: FontWeight.w400,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ),
                ],
              ),
              SizedBox(
                height:AppSize.h5,
              ),
              Row(
                children: [
                  Text(
                    getTranslated(context, "description")+" : ",
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s14_5,
                       color: AppColors.black87,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.only(top: AppPadding.p5),
                      child: LinkWell(
                        item.body.toString(),
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13,
                         color: AppColors.black54,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                        linkStyle: GoogleFonts.poppins(
                          fontSize: AppFontsSizeManager.s13,
                          color: Colors.blue,
                          fontWeight: FontWeight.w400,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ),
                  ),
                ],
              ),
              /* Text(
                item.body,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: GoogleFonts.poppins(
                  fontSize: 13.5,
                  color: Colors.black.withOpacity(0.7),
                  fontWeight: AppFontsWeightManager.bold500,
                  letterSpacing: AppConstants.letterSpacing0_3,
                ),
              ),*/
              SizedBox(
                height: AppSize.h5,
              ),
              Row(
                children: [
                  Text(
                    getTranslated(context, "sendTo") + " : ",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s13_5,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                  Text(
                    item.notificationType.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s13,
                     color: AppColors.black54,
                      fontWeight: FontWeight.w400,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: AppSize.h5,
              ),
              Row(
                children: [
                  Text(
                    getTranslated(context, "selectLanguage") + " : ",
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s13_5,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                  Text(
                    item.notificationLang.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s13,
                     color: AppColors.black54,
                      fontWeight: FontWeight.w400,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: AppSize.h5,
              ),
              Row(
                children: [
                  Text(
                    getTranslated(context, "selectCountry") + " : " ,
                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s13_5,
                      color: Colors.black.withOpacity(0.7),
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                  Text(
                    item.notificationCountry.toString(),
                    style: GoogleFonts.poppins(
                      fontSize: AppFontsSizeManager.s13,
                     color: AppColors.black54,
                      fontWeight: FontWeight.w400,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height:AppSize.h5,
              ),
              Text(
                '${dateFormat.format(item.notificationTimestamp!.toDate())}',
                style: GoogleFonts.poppins(
                  fontSize: AppFontsSizeManager.s13,
                  color: Colors.black.withOpacity(0.4),
                  fontWeight:AppFontsWeightManager.bold300,
                  letterSpacing: AppConstants.letterSpacing0_3,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSize.h15,
        )
      ],
    );
  }
}
