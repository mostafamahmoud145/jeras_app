import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:readmore/readmore.dart';

import '../../config/colors_file.dart';
import '../../models/consultReview.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';

class ConsultReviewWidget extends StatelessWidget {
  final ConsultReview review;
  ConsultReviewWidget({required this.review});

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        Align(
          child: Container(
              color: Colors.transparent,
              padding: EdgeInsets.only(
                  left: AppPadding.p10,
                  right: AppPadding.p10,
                  top: AppPadding.p10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    padding: EdgeInsets.all(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppPadding.p20
                            : AppPadding.p10),
                    decoration: BoxDecoration(
                      // border: Border.all(color: Colors.black,width: 2),
                      shape: BoxShape.circle,
                      color: AppColors.grey4,
                    ),
                    child: review.image!.isEmpty
                        ? SvgPicture.asset(
                            AssetsManager.personIconPath,
                            width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w20.w
                                : AppSize.w12.w,
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h20.h
                                : AppSize.h12.h,
                          )
                        : ClipRRect(
                            borderRadius:
                                BorderRadius.circular(AppRadius.r100.r),
                            child: FadeInImage.assetNetwork(
                              placeholder: AssetsManager.iconPersonIconPath,
                              placeholderScale: 0.5,
                              width: AppSize.w15.w,
                              height: AppSize.h15.h,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  SvgPicture.asset(
                                AssetsManager.personIconPath,
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w12.w
                                    : AppSize.w12.w,
                                height: AppSize.h12.h,
                              ),
                              image: review.image!,
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
                  SizedBox(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppSize.w24.w
                        : 0,
                  ),
                  Expanded(
                    flex: 2,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Padding(
                          padding: EdgeInsets.symmetric(horizontal: 5.w),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.spaceBetween,
                            children: [
                              Text(
                                review.name,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                  color: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppColors.black
                                      : Color(0xff3f3f3f),
                                  fontWeight: AppFontsWeightManager.bold300,
                                  fontFamily: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? getTranslated(context, "Ithralight")
                                      : getTranslated(context, "Ithra"),
                                  fontStyle: FontStyle.normal,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s32.sp
                                      : AppFontsSizeManager.s18_6.sp,
                                ),
                              ),
                              Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? Icon(
                                          Icons.star,
                                          size: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.w36.w
                                              : AppSize.w15,
                                          color: AppColors.yellow,
                                        )
                                      : Text(
                                          // '5',
                                          review.rating
                                              .toStringAsFixed(1),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? getTranslated(
                                                    context, "Montserratmedium")
                                                : getTranslated(
                                                    context, "Montserrat"),
                                            fontStyle: FontStyle.normal,
                                            fontSize: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppFontsSizeManager.s20.sp
                                                : AppFontsSizeManager.s12.sp,
                                            color: AppColors.shadoColor,
                                          ),
                                        ),
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? SizedBox(
                                          width: AppSize.w4.w,
                                        )
                                      : SizedBox(),
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? Text(
                                          review.rating
                                              .toStringAsFixed(1),
                                          textAlign: TextAlign.start,
                                          style: TextStyle(
                                            fontWeight: FontWeight.w400,
                                            fontFamily: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? getTranslated(
                                                    context, "Montserratmedium")
                                                : getTranslated(
                                                    context, "Montserrat"),
                                            fontStyle: FontStyle.normal,
                                            fontSize: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppFontsSizeManager.s28.sp
                                                : AppFontsSizeManager.s12.sp,
                                            color: AppColors.black,
                                          ),
                                        )
                                      : Icon(
                                          Icons.star,
                                          size: AppSize.w15,
                                          color: AppColors.yellow,
                                        )
                                ],
                              )
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.all(AppPadding.p5),
                          child: Container(
                            child: ReadMoreText(
                              review.review!,
                              trimLines: 1,
                              textAlign: TextAlign.start,
                              colorClickableText: AppColors.pink2,
                              trimMode: TrimMode.Line,
                              trimCollapsedText: 'Show more',
                              trimExpandedText: 'Show less',
                              moreStyle: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                color: Theme.of(context).primaryColor,
                                fontWeight: AppFontsWeightManager.bold300,
                                fontStyle: FontStyle.normal,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? 16.sp
                                    : 9.sp,
                              ),
                              lessStyle: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                color: Theme.of(context).primaryColor,
                                fontWeight: AppFontsWeightManager.bold300,
                                fontStyle: FontStyle.normal,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? 16.sp
                                    : 9.sp,
                              ),
                              style: TextStyle(
                                fontFamily:
                                    getTranslated(context, "Ithralight"),
                                color: Theme.of(context).primaryColor,
                                fontWeight: AppFontsWeightManager.bold300,
                                fontStyle: FontStyle.normal,
                                fontSize: 16.sp,
                              ),
                            ),
                          ),
                        ),
                        SizedBox(height: AppSize.h10.h),
                      ],
                    ),
                  ),
                ],
              )),
        ),
      ],
    );
  }
}
