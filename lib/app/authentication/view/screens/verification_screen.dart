import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jeras/app/authentication/controllers/verification_code_cubit/verification_code_cubit.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/methods/show_failed_snackbar.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/responsive_layout.dart';
import 'package:pinput/pinput.dart';
import '../../../../../localization/localization_methods.dart';
import '../widgets/load_text_field_shimmer.dart';
import '../../../../config/app_constat.dart';
import '../../../../config/app_fonts.dart';
import '../../../../config/app_values.dart';
import '../../../../config/assets_manager.dart';
import '../../../../widget/primary_button.dart';

class VerificationScreen extends StatelessWidget {
  static final _scaffoldKey = GlobalKey<ScaffoldState>();
  static final _key = GlobalKey<FormState>();
  late String smsCode;

  final PhoneNumber number;
  final String userType;
  final bool withApi;
  final String token;
  VerificationScreen({
    required this.number,
    required this.token,
    required this.userType,
    required this.withApi,
  });

  @override
  Widget build(BuildContext context) {
    String lang;
    lang = getTranslated(context, "lang");
    Size size = MediaQuery.of(context).size;
    return BlocProvider(
      create: (context) => VerificationCodeCubit()
        ..initData(
            token: token,
            userType: userType,
            withApi: withApi,
            number: number,
            context: context),
      child: Scaffold(
        key: _scaffoldKey,
        body: ResponsiveLayout(
          desktop: SingleChildScrollView(
            child: Form(
              key: _key,
              child: Column(
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        bottom: AppPadding.p8.h,
                        top: AppPadding.p48.h,
                        left: AppPadding.p140.w,
                        right: AppPadding.p140.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: AppSize.w80.w,
                            height: AppSize.h80.h,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r16.r),
                            ),
                            child: CustomBackButton()),
                        const SizedBox(width: AppSize.w10),
                      ],
                    ),
                  ),
                  Center(
                    child: Image.asset(
                      AssetsManager.verificationCode,
                      width: AppSize.w230_7.w,
                      height: AppSize.h209.h,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h68.h,
                  ),
                  SizedBox(
                    child: Text(
                      // cubit.load
                      //     ? getTranslated(context, "otpSending")
                      //     :
                      getTranslated(context, "otpSend"),
                      textAlign: TextAlign.center,
                      style: TextStyle(
                          color: AppColors.grey,
                          fontWeight: AppFontsWeightManager.normal,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize: AppFontsSizeManager.s32.sp),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h96.h,
                  ),
                  BlocConsumer<VerificationCodeCubit, VerificationCodeState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        VerificationCodeCubit cubit =
                            VerificationCodeCubit().get(context);

                        switch (cubit.load) {
                          case true:
                            return loadVerificationCode(context);
                          case false:
                            return Directionality(
                              textDirection: TextDirection.ltr,
                              child: Padding(
                                padding: EdgeInsets.only(right: AppSize.w44.w),
                                child: Container(
                                  height: 100.h,
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.p44.w,
                                      vertical: 0.0),
                                  child: Pinput(
                                    closeKeyboardWhenCompleted: true,
                                    onCompleted: (value) {
                                      if (value.isEmpty) {
                                        showFailedSnackBar(getTranslated(
                                            context, "optRequired"));
                                      } else if (value.length < 6) {
                                        showFailedSnackBar(getTranslated(
                                            context, "invalidOtp"));
                                      }
                                    },
                                    onSubmitted: (value) {
                                      if (value.isEmpty) {
                                        showFailedSnackBar(getTranslated(
                                            context, "optRequired"));
                                      } else if (value.length < 6) {
                                        showFailedSnackBar(getTranslated(
                                            context, "invalidOtp"));
                                      }
                                    },
                                    onChanged: (val) {
                                      smsCode = val;
                                      if (val.trim().length == 6) {
                                        cubit.verifyOTP(otpCode: val);
                                      }
                                    },
                                    androidSmsAutofillMethod:
                                        AndroidSmsAutofillMethod
                                            .smsRetrieverApi,
                                    length: 6,

                                    defaultPinTheme: PinTheme(
                                      width: AppSize.w90.w,
                                      padding: EdgeInsets.symmetric(
                                          horizontal: AppPadding.p5.w),
                                      margin: EdgeInsets.only(
                                          left: AppMargin.m44.w),
                                      textStyle: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight:
                                            AppFontsWeightManager.bold500,
                                        fontFamily: getTranslated(
                                            context, "Montserrat"),
                                        fontStyle: FontStyle.normal,
                                        fontSize: AppFontsSizeManager.s36.sp,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r16.r),
                                        border: Border.all(
                                          color: AppColors.primaryColor,
                                          width: 1,
                                        ),
                                      ),
                                    ),
                                    // androidSmsAutofillMethod:
                                    //     AndroidSmsAutofillMethod.smsRetrieverApi,
                                  ),
                                ),
                              ),
                            );
                        }
                      }),
                  SizedBox(
                    height: AppSize.h32.h,
                  ),
                  Container(
                    width: size.width >= 500 ? AppSize.w825.w : size.width,
                    height: AppSize.h40.h,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: <Widget>[
                        BlocConsumer<VerificationCodeCubit,
                                VerificationCodeState>(
                            listener: (context, state) {},
                            builder: (context, state) {
                              VerificationCodeCubit cubit =
                                  VerificationCodeCubit().get(context);

                              return cubit.time == 0
                                  ? MaterialButton(
                                      onPressed: () {
                                        cubit.resendOTP();
                                      },
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r15.r),
                                      ),
                                      child: Text(
                                        getTranslated(context, "resendOtp"),
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          color: AppColors.grey,
                                          fontSize: AppFontsSizeManager.s24.sp,
                                          fontWeight: FontWeight.w400,
                                        ),
                                      ),
                                    )
                                  : SizedBox();
                            }),
                        Spacer(),
                        Padding(
                          padding: const EdgeInsets.symmetric(
                              horizontal: AppPadding.p10),
                          child: BlocConsumer<VerificationCodeCubit,
                                  VerificationCodeState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                return Text(
                                  '${VerificationCodeCubit().get(context).time} sec',
                                  style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.grey,
                                    fontSize: AppFontsSizeManager.s24.sp,
                                    fontWeight: FontWeight.w400,
                                    letterSpacing:
                                        AppConstants.letterSpacing0_5,
                                  ),
                                );
                              }),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h135.h,
                  ),
                  BlocConsumer<VerificationCodeCubit, VerificationCodeState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        VerificationCodeCubit cubit =
                            VerificationCodeCubit().get(context);

                        switch (cubit.load) {
                          case true:
                            return Center(child: CircularProgressIndicator());
                          case false:
                            return Padding(
                              padding: const EdgeInsets.only(
                                  top: AppPadding.p20,
                                  bottom: AppPadding.p30,
                                  left: AppPadding.p20,
                                  right: AppPadding.p20),
                              child: Center(
                                child: PrimaryButton(
                                  colors: true,
                                  width: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.w556.w
                                      : AppSize.w378.r,
                                  height: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.h100.h
                                      : AppSize.h81.r,
                                  buttonRadius: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppRadius.r16.r
                                      : AppRadius.r25.r,
                                  textSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s36.sp
                                      : AppFontsSizeManager.s20.sp,
                                  onPress: () {
                                    if (smsCode.trim().length == 6) {
                                      cubit.verifyOTP(otpCode: smsCode);
                                    } else {
                                      showFailedSnackBar(
                                          getTranslated(context, "invalidOtp"));
                                    }
                                  },
                                  text: getTranslated(context, "activate"),
                                ),
                              ),
                            );
                        }
                      }),
                  SizedBox(
                    height: AppSize.h15,
                  ),
                ],
              ),
            ),
          ),
          mobile: SingleChildScrollView(
            child: Padding(
              padding: EdgeInsets.only(
                  right: AppPadding.p32.w,
                  left: AppPadding.p32.w,
                  top: AppPadding.p42_6.h),
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                child: Column(
                  children: <Widget>[
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: AppSize.w50_6.r,
                            height: AppSize.h50_6.r,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r10_6.r),
                            ),
                            child: CustomBackButton()),
                        SizedBox(width: AppSize.w10.w),
                      ],
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                          bottom: AppPadding.p85_3.h, top: AppPadding.p66_6.h),
                      child: Center(
                        child: Image.asset(
                          AssetsManager.verificationCode,
                          width: AppSize.w224.r,
                          height: AppSize.h193_5.r,
                        ),
                      ),
                    ),
                    Padding(
                      padding: EdgeInsets.only(
                        bottom: AppPadding.p44.h,
                        left: AppPadding.p54_6.w,
                        right: AppPadding.p54_6.w,
                      ),
                      child: Text(
                        // cubit.load
                        //     ? getTranslated(context, "otpSending")
                        //     :
                        getTranslated(context, "otpSend"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                            color: AppColors.darkGrey3,
                            fontWeight: AppFontsWeightManager.bold100,
                            fontFamily: getTranslated(context, "Ithra"),
                            fontStyle: FontStyle.normal,
                            fontSize: AppFontsSizeManager.s26_6.sp),
                      ),
                    ),

                    BlocConsumer<VerificationCodeCubit, VerificationCodeState>(
                        listener: (context, state) {},
                        builder: (context, state) {
                          VerificationCodeCubit cubit =
                              VerificationCodeCubit().get(context);
                          switch (cubit.load) {
                            case true:
                              return loadVerificationCode(context);
                            case false:
                              return Directionality(
                                textDirection: TextDirection.ltr,
                                child: Container(
                                  padding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.p16.w),
                                  width: double.infinity,
                                  // color: Colors.red,
                                  height: AppSize.h72.r,
                                  // padding: EdgeInsets.symmetric(
                                  //     horizontal: AppPadding.p25.w,
                                  //     vertical: 0.0),
                                  child: Pinput(
                                    closeKeyboardWhenCompleted: true,
                                    onCompleted: (value) {
                                      if (value.isEmpty) {
                                        showFailedSnackBar(getTranslated(
                                            context, "optRequired"));
                                      } else if (value.length < 6) {
                                        showFailedSnackBar(getTranslated(
                                            context, "invalidOtp"));
                                      }
                                    },
                                    onSubmitted: (value) {
                                      if (value.isEmpty) {
                                        showFailedSnackBar(getTranslated(
                                            context, "optRequired"));
                                      } else if (value.length < 6) {
                                        showFailedSnackBar(getTranslated(
                                            context, "invalidOtp"));
                                      }
                                    },
                                    onChanged: (val) {
                                      smsCode = val;
                                      if (val.trim().length == 6) {
                                        cubit.verifyOTP(otpCode: val);
                                      }
                                    },
                                    androidSmsAutofillMethod:
                                        AndroidSmsAutofillMethod
                                            .smsRetrieverApi,
                                    length: 6,

                                    defaultPinTheme: PinTheme(
                                      width: AppSize.w60.r,
                                      height: AppSize.h72.h,
                                      margin: EdgeInsets.symmetric(
                                          horizontal: AppPadding.p6.w),
                                      textStyle: TextStyle(
                                        color: AppColors.primaryColor,
                                        fontWeight:
                                            AppFontsWeightManager.bold600,
                                        fontFamily: getTranslated(
                                            context, "Montserrat"),
                                        fontStyle: FontStyle.normal,
                                        fontSize: AppFontsSizeManager.s34_6.sp,
                                      ),
                                      decoration: BoxDecoration(
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r10_6.r),
                                        border: Border.all(
                                          color: AppColors.grey3,
                                          width: AppSize.w1.w,
                                        ),
                                      ),
                                    ),
                                    // androidSmsAutofillMethod:
                                    //     AndroidSmsAutofillMethod.smsRetrieverApi,
                                  ),
                                ),
                              );
                          }
                        }),
                    SizedBox(
                      height: AppSize.h21_3.h,
                    ),
                    Container(
                      width: size.width >= 500
                          ? size.width * AppSize.w0_3
                          : size.width,
                      height: AppSize.h40.h,
                      padding: EdgeInsets.only(left: AppPadding.p28.w),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: <Widget>[
                          BlocConsumer<VerificationCodeCubit,
                                  VerificationCodeState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                VerificationCodeCubit cubit =
                                    VerificationCodeCubit().get(context);

                                return cubit.time == 0
                                    ? InkWell(
                                        onTap: () {
                                          cubit.resendOTP();
                                        },
                                        // shape: RoundedRectangleBorder(
                                        //   borderRadius: BorderRadius.circular(
                                        //       AppRadius.r15.r),
                                        // ),
                                        child: Text(
                                          getTranslated(context, "resendOtp"),
                                          style: TextStyle(
                                            fontFamily: getTranslated(
                                                context, "Ithralight"),
                                            color: AppColors.lightGrey1,
                                            fontSize:
                                                AppFontsSizeManager.s16.sp,
                                          ),
                                        ),
                                      )
                                    : SizedBox();
                              }),
                          BlocConsumer<VerificationCodeCubit,
                                  VerificationCodeState>(
                              listener: (context, state) {},
                              builder: (context, state) {
                                return Text(
                                  '${VerificationCodeCubit().get(context).time}sec',
                                  style: TextStyle(
                                    fontFamily:
                                        getTranslated(context, "Ithralight"),
                                    color: AppColors.grey,
                                    fontSize: AppFontsSizeManager.s16.sp,
                                    // fontWeight: FontWeight.w400,
                                    letterSpacing:
                                        AppConstants.letterSpacing0_5,
                                  ),
                                );
                              }),
                        ],
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h160.h,
                    ),

                    BlocConsumer<VerificationCodeCubit, VerificationCodeState>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        VerificationCodeCubit cubit =
                            VerificationCodeCubit().get(context);

                        switch (cubit.load) {
                          case true:
                            return Center(child: CircularProgressIndicator());
                          case false:
                            return Center(
                              child: PrimaryButton(
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w556.w
                                    : AppSize.w390_6.r,
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h100.h
                                    : AppSize.h66_6.r,
                                buttonRadius: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppRadius.r16.r
                                    : AppRadius.r16.r,
                                textSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s36.sp
                                    : AppFontsSizeManager.s21_3.sp,
                                onPress: () {
                                  if (smsCode.trim().length == 6) {
                                    cubit.verifyOTP(otpCode: smsCode);
                                  } else {
                                    showFailedSnackBar(
                                        getTranslated(context, "invalidOtp"));
                                  }
                                },
                                text: getTranslated(context, "activate"),
                              ),
                            );
                        }
                      },
                    ),
                    Spacer()
                    // SizedBox(
                    //   height: AppSize.h194.h,
                    // ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
