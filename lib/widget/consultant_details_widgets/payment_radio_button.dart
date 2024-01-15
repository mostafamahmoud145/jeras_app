import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/responsive.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';

class PaymentRadioButton extends StatelessWidget {
  const PaymentRadioButton(
      {Key? key,
        required this.isSelected,
        required this.function,
        required this.icons,
        this.text,
        this.endPadding= 0,
        this.endIconWidth= AppSize.w79,
        this.withBottomPadding= true,
        required this.endIcon})
      : super(key: key);

  final List<String> icons;
  final String endIcon;
  final String? text;
  final bool isSelected;
  final Function function;
  final double endIconWidth;
  final double endPadding;
  final bool withBottomPadding;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: withBottomPadding ? EdgeInsets.only(bottom: AppSize.h35.h,) : EdgeInsets.zero,
      child: Directionality(
        textDirection: TextDirection.ltr,
        child: InkWell(
          onTap: (){
            function();
          },
          child: Container(
            height: convertPtToPx(AppSize.h63).h,
            padding: EdgeInsetsDirectional.only(
                start: convertPtToPx(AppSize.h24).w,
                end: convertPtToPx(AppSize.h12).w,
            ),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
              border: Border.all(
                color: AppColors.grey6,
              ),
            ),
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Icon(
                  isSelected ? Icons.radio_button_checked : Icons.radio_button_off,
                  color: AppColors.linear2,
                ),
                SizedBox(width: AppSize.h10.w,),
                
                if(text!=null)
                  Expanded(
                    child: Row(
                      children: [
                                  
                        Expanded(
                          child: Text(
                            text!,
                            maxLines: 2,
                            textAlign:TextAlign.right,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              color: AppColors.linear2,
                              fontSize: AppFontsSizeManager.s21.sp,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontWeight: AppFontsWeightManager.semiBold,
                            ),
                          ),
                        ),
                          SizedBox(width: AppSize.w16.w,),
                        
                      ],
                    ),
                  ),
                if(text==null)
                  Expanded(
                    child: ListView.separated(
                        scrollDirection: Axis.horizontal,
                        itemBuilder: (context, index) => isSvg(icons[index])
                            ? SvgPicture.asset(
                          icons[index],
                          width: convertPtToPx(AppSize.w32).w,
                          //  height: AppSize.h32.h,
                        )
                            : Image.asset(
                          icons[index],
                          width: AppSize.w60.w,
                          //  height: AppSize.h32.h,
                        ),
                        separatorBuilder: (context, index) =>SizedBox(
                          width: AppSize.w8.w,
                        ),
                        itemCount: icons.length),
                  ),

                isSvg(endIcon)
                    ? SvgPicture.asset(
                  endIcon,
                  width: endIconWidth.w,
                  //  height: AppSize.h32.h,
                )
                    : Image.asset(
                  endIcon,
                  width: AppSize.w68.w,
                  //  height: AppSize.h32.h,
                ),

                SizedBox(width: endPadding,),
              ],
            ),
          ),
        ),
      ),
    );
  }

  bool isSvg(String path) => path.split('.').last == 'svg' ? true : false;
}
