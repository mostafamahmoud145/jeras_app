

import 'package:flutter/material.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/responsive.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';

class OrderDetailsLine extends StatelessWidget {
  const OrderDetailsLine({Key? key,
    required this.header,
    required this.value,
    this.headerColor= AppColors.grey1,
    this.valueColor= AppColors.grey_dark,
  }) : super(key: key);

  final Color headerColor;
  final Color valueColor;
  final String header, value;
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppSize.w10.h),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(header,
            style: TextStyle(
                color: headerColor,
                fontWeight: AppFontsWeightManager.semiBold,
                fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                fontFamily: getTranslated(context, "Ithra"),
              letterSpacing: convertPtToPx(-0.5).sp,

            ),
          ),

          Expanded(
            child: Text(
              value,
              textAlign: TextAlign.end,
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
              style: TextStyle(
                color: valueColor,
                fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                fontFamily: getTranslated(context, "Montserrat"),
                fontWeight: AppFontsWeightManager.semiBold,
                letterSpacing: convertPtToPx(-0.5).sp,
              ),
            ),
          ),
        ],
      ),
    );
  }
}


