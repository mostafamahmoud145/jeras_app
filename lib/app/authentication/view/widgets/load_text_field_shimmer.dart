
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:shimmer/shimmer.dart';

import '../../../../config/app_constat.dart';
import '../../../../config/app_values.dart';

Widget loadVerificationCode(BuildContext context) {
  return Shimmer.fromColors(
      period: Duration(milliseconds: AppConstants.milliseconds800),
      baseColor: Colors.grey.withOpacity(0.6),
      highlightColor: Colors.black.withOpacity(0.6),
      child: Container(
        height: AppSize.h50.h,
        width: kIsWeb && MediaQuery.of(context).size.width > 400
            ? MediaQuery.of(context).size.width * AppSize.w0_3
            : MediaQuery.of(context).size.width * AppSize.w0_8,
        padding: const EdgeInsets.all(AppPadding.p8),
        margin: EdgeInsets.symmetric(
          horizontal: AppMargin.m20,
        ),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.2),
          borderRadius: BorderRadius.circular(AppRadius.r15.r),
        ),
      ));
}
