import 'package:flutter/material.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/responsive.dart';

import '../../../config/app_constat.dart';
import '../../../config/app_fonts.dart';

class AppBar1 extends StatelessWidget {
  const AppBar1(
      {super.key,
      this.onPress,
      this.onPress2,
      this.widgetCenter,
        required this.widget1, required this.widget2,
      required this.widget3,required this.widget4,required this.widget5,
      });

  final Function()? onPress, onPress2;

  final Widget widget1, widget2 , widget3 , widget4,widget5;
  final Widget? widgetCenter;

  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.only(
        left:AppSize.w32.w,
        right: AppSize.w32.w,
        bottom: AppSize.h25_3.h,
       // top: size.height * .03,
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.max,
              children: <Widget>[
                //drawer section d
                widget1,
                // widgetCenter == null ? SizedBox() : widgetCenter!,
                widget2,
                // search section d
                widget3,
                 widget4,
                 widget5,
              ],
            ),
          ],
        ),
      ),
    );
  }
}
