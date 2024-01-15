import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/customTextField.dart';
import 'package:jeras/widget/default_text_widget.dart';

import '../Utils/styles.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';

class DialogWidget extends StatefulWidget {
  String title, conformText, cancelText, dialogType;
  String? hintText;
  TextEditingController? inputContoller;
  Function() confirmPress, cancelPress;

  DialogWidget(
      {Key? key,
      required this.title,
      required this.dialogType,
      required this.conformText,
      this.inputContoller,
      required this.cancelText,
      required this.confirmPress,
      required this.cancelPress,
      this.hintText})
      : super(key: key);

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return AlertDialog(
      backgroundColor: Colors.transparent,
      elevation: 5.0,
      //contentPadding: const EdgeInsets.only(left: AppPadding.p16, right: AppPadding.p16, top: AppPadding.p20, bottom: AppPadding.p10),
      content: Container(
        padding:
            EdgeInsets.symmetric(horizontal: size.width * AppSize.w0_05, vertical: AppPadding.p40),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r30),
          color: Colors.white,
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Align(
              alignment: AlignmentDirectional.topStart,
              child: SizedBox(
                height: size.height * AppSize.h0_01,
              ),
            ),
            InkWell(
              child: Image.asset(AssetsManager.exit),
              onTap: () {
                Navigator.pop(context);
              },
            ),
            SizedBox(
              height: size.height * AppSize.h0_03,
            ),
            Center(
                child: TextDefaultWidget(
                    title: widget.title,
                    fontSize: AppFontsSizeManager.s16,
                    color: AppColors.pink)),
            SizedBox(
              height: size.height * AppSize.h0_03,
            ),
            widget.dialogType == 'input'
                ? CustomTextFieldWidget(
                    controller: widget.inputContoller,
                    hint: widget.hintText,
                    hintStyle: Styles.getTextStyle(
                        color: AppColors.grey, fontSize: AppFontsSizeManager.s14),
                  )
                : SizedBox(),
            SizedBox(
              height: size.height * AppSize.h0_03,
            ),
            Padding(
              padding: EdgeInsets.symmetric(horizontal: AppPadding.p20),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                // mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  InkWell(
                    onTap: widget.confirmPress,
                    child: Container(
                      width: size.width * AppSize.h0_15,
                      height: size.height * AppSize.h0_04,
                      decoration: BoxDecoration(
                          color: AppColors.pink,
                          borderRadius: BorderRadius.circular(AppRadius.r5)),
                      child: Center(
                          child: TextDefaultWidget(title: widget.conformText)),
                    ),
                  ),
                  SizedBox(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w50 : AppSize.w10,
                  ),
                  InkWell(
                    onTap: widget.cancelPress,
                    child: Container(
                      width: size.width * AppSize.h0_15,
                      height: size.height * AppSize.h0_04,
                      decoration: BoxDecoration(
                          color: AppColors.pink,
                          borderRadius: BorderRadius.circular(AppRadius.r5)),
                      child: Center(
                          child: TextDefaultWidget(title: widget.cancelText)),
                    ),
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
