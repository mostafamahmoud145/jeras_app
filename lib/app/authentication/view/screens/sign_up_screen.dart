import 'package:conditional_builder_null_safety/conditional_builder_null_safety.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:intl_phone_number_input/intl_phone_number_input.dart';
import 'package:jeras/app/authentication/controllers/sign_up_cubit/signup_cubit.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/responsive_layout.dart';
import '../../../../../localization/localization_methods.dart';
import '../../../../../screens/privecy_screen.dart';
import '../../../../config/app_constat.dart';
import '../../../../config/app_fonts.dart';
import '../../../../config/app_values.dart';
import '../../../../config/colors_file.dart';
import '../../../../methods/get_phone_without_country_code.dart';
import '../../../../methods/show_failed_snackbar.dart';
import '../../../../widget/custom_back_button.dart';
import '../../../../widget/primary_button.dart';

class SignUpScreen extends StatelessWidget {
  final String userType;

  SignUpScreen({Key? key, required this.userType}) : super(key: key);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final TextEditingController controller = TextEditingController();
  static final GlobalKey<FormState> _key = GlobalKey<FormState>();

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignupCubit(),
      child: Scaffold(
          key: _scaffoldKey,
          body: ResponsiveLayout(
            desktop: SingleChildScrollView(
                child: Form(
              key: _key,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: <Widget>[
                  Padding(
                    padding: EdgeInsets.only(
                        top: AppPadding.p48.h,
                        left: AppPadding.p140.w,
                        right: AppPadding.p140.w),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                            width: AppSize.w75.w,
                            height: AppSize.h75.h,
                            decoration: BoxDecoration(
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r25.r),
                            ),
                            child: CustomBackButton()),
                        SizedBox(width: AppSize.w10.w),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h8.h,
                  ),
                  Center(
                    child: Image.asset(
                      AssetsManager.verificationCode,
                      width: AppSize.w250.w,
                      height: AppSize.h226.h,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h68.h,
                  ),
                  Center(
                    child: SizedBox(
                      //AppSize.w560.w,
                      child: Text(
                        getTranslated(context, "loginText"),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontWeight: AppFontsWeightManager.normal,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize: AppFontsSizeManager.s29.sp,
                          color: AppColors.grey2,
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h84.h,
                  ), //p
                  BlocConsumer<SignupCubit, SignupStates>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        SignupCubit cubit = SignupCubit().get(context);
                        return Center(
                          child: Directionality(
                            textDirection: TextDirection.rtl,
                            child: Center(
                              child: Container(
                                //margin: EdgeInsets.symmetric(horizontal: size.width * .31),
                                //padding: EdgeInsets.symmetric( horizontal: 30,  ),
                                padding: EdgeInsets.symmetric(
                                    horizontal: AppPadding.p64.w,
                                    vertical: AppPadding.p5.h),
                                height: AppSize.h120.h,
                                width: AppSize.w947.w,
                                decoration: BoxDecoration(
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r70.r),
                                  color: AppColors.grey4,
                                ),
                                child: InternationalPhoneNumberInput(
                                  searchBoxDecoration: InputDecoration(
                                    counterStyle: TextStyle(
                                      height: double.minPositive,
                                    ),
                                    counterText: "",
                                    filled: true,
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: AppPadding.p20,
                                        right: AppPadding.p5),
                                    helperStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: Colors.black.withOpacity(0.65),
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                    hintStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: AppColors.grey,
                                      fontSize: AppFontsSizeManager.s32.sp,
                                      fontWeight: AppFontsWeightManager.normal,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                    hintText:
                                        getTranslated(context, 'enterMobile'),
                                  ),
                                  textAlignVertical: TextAlignVertical.top,
                                  inputDecoration: InputDecoration(
                                    icon: Padding(
                                      padding: EdgeInsets.only(
                                          left: AppPadding.p52.w,
                                          right: AppPadding.p23.w),
                                      child: SizedBox(
                                        height: AppSize.h20.h,
                                        child: VerticalDivider(
                                          width: AppSize.w1.w,
                                          color: AppColors.borderLightGrey,
                                        ),
                                      ),
                                    ),
                                    counterStyle: TextStyle(
                                      height: double.minPositive,
                                    ),
                                    counterText: "",
                                    focusedBorder: InputBorder.none,
                                    enabledBorder: InputBorder.none,
                                    contentPadding: EdgeInsets.only(
                                        left: AppPadding.p5,
                                        right: AppPadding.p5),
                                    helperStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: AppColors.grey,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                    hintStyle: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      color: AppColors.grey,
                                      fontSize: AppFontsSizeManager.s32.sp,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_5,
                                    ),
                                    hintText:
                                        getTranslated(context, 'enterMobile'),
                                  ),
                                  onInputChanged: (PhoneNumber number) {
                                    cubit.onChangePhoneNumber(number);
                                  },
                                  onInputValidated: (bool value) {},
                                  locale: getTranslated(context, 'lang'),
                                  selectorConfig: SelectorConfig(
                                    trailingSpace: false,
                                    selectorType: PhoneInputSelectorType.DIALOG,
                                  ),
                                  ignoreBlank: false,
                                  autoValidateMode: AutovalidateMode.disabled,
                                  selectorTextStyle: TextStyle(
                                    color: Colors.grey,
                                    fontWeight: AppFontsWeightManager.bold500,
                                    fontFamily:
                                        getTranslated(context, "Montserrat"),
                                    fontStyle: FontStyle.normal,
                                    fontSize: AppFontsSizeManager.s21.sp,
                                  ),
                                  initialValue: cubit.number,
                                  textFieldController: controller,
                                  formatInput: false,
                                  keyboardType: TextInputType.numberWithOptions(
                                      signed: true, decimal: true),
                                  inputBorder: InputBorder.none,
                                  onSaved: (PhoneNumber number) {},
                                ),
                              ),
                            ),
                          ),
                        );
                      }),
                  SizedBox(
                    height: AppSize.h88.h,
                  ),
                  BlocConsumer<SignupCubit, SignupStates>(
                      listener: (context, state) {},
                      builder: (context, state) {
                        SignupCubit cubit = SignupCubit().get(context);
                        return ConditionalBuilder(
                          condition: state is LoginLoadingState ||
                              state is GenerateOTPLoadingState,
                          builder: (context) => Center(
                            child: CircularProgressIndicator(),
                          ),
                          fallback: (context) => Center(
                            child: Padding(
                              padding: EdgeInsets.only(
                                  left: AppPadding.p20, right: AppPadding.p20),
                              child: PrimaryButton(
                                colors: true,
                                width: AppSize.w556.w,
                                onPress: () {
                                  if (cubit.number.phoneNumber == null) {
                                    showFailedSnackBar(
                                        getTranslated(context, "enterAll"));
                                  } else {
                                    String phoneNum =
                                        getPhoneWithoutCountryCode(
                                            cubit.number.phoneNumber!,
                                            cubit.number.dialCode!);
                                    if (phoneNum.trim().isEmpty) {
                                      showFailedSnackBar(
                                          getTranslated(context, "enterAll"));
                                    } else {
                                      cubit.login(
                                          context: context, userType: userType);
                                    }
                                  }
                                },
                                text: getTranslated(context, "sendCode"),
                                textSize: AppFontsSizeManager.s36.sp,
                                height: AppSize.h100.h,
                                buttonRadius: AppRadius.r16.r,
                              ),
                            ),
                          ),
                        );
                      }),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.end,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(
                            top: AppPadding.p56,
                            left: AppPadding.p20,
                            right: AppPadding.p20),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.end,
                          children: [
                            Text(
                              getTranslated(context, "registerNote1"),
                              style: TextStyle(
                                color: AppColors.primaryColor,
                                fontWeight: AppFontsWeightManager.normal,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontStyle: FontStyle.normal,
                                fontSize: AppFontsSizeManager.s24.sp,
                              ),
                            ),
                            SizedBox(
                              height: AppSize.h8.h,
                            ),
                            Column(
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                InkWell(
                                  splashColor: Colors.blue.withOpacity(0.6),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) =>
                                            PrivecyScreen(), //TermScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    getTranslated(context, "registerNote2"),
                                    style: TextStyle(
                                        color: AppColors.shadoColor,
                                        fontWeight:
                                            AppFontsWeightManager.normal,
                                        fontFamily:
                                            getTranslated(context, "Ithra"),
                                        fontStyle: FontStyle.normal,
                                        fontSize: AppFontsSizeManager.s24.sp),
                                  ),
                                ),
                                InkWell(
                                  splashColor: Colors.blue.withOpacity(0.6),
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => PrivecyScreen(),
                                      ),
                                    );
                                  },
                                  child: Text(
                                    getTranslated(context, "registerNote3"),
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      fontWeight: AppFontsWeightManager.normal,
                                      decorationColor: AppColors.shadoColor,
                                      decorationThickness: 1,
                                      color: AppColors.pink,
                                      fontSize: AppFontsSizeManager.s24.sp,
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            )),
            mobile: SingleChildScrollView(
                child: Padding(
              padding: EdgeInsets.only(
                  top: AppPadding.p42_6.h,
                  left: AppPadding.p32.w,
                  right: AppPadding.p32.w),
              child: Container(
                height: MediaQuery.sizeOf(context).height,
                child: Form(
                  key: _key,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: <Widget>[
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                              width: AppSize.w50_6.r,
                              height: AppSize.h50_6.r,
                              decoration: BoxDecoration(
                                borderRadius:
                                    BorderRadius.circular(AppRadius.r13.r),
                              ),
                              child: CustomBackButton()),
                        ],
                      ),
                      SizedBox(
                        height: AppSize.h66_6.h,
                      ),
                      Center(
                        child: Image.asset(
                          AssetsManager.verificationCode,
                          width: AppSize.w224.r,
                          height: AppSize.h193_5.r,
                        ),
                      ),
                      Center(
                        child: Padding(
                          padding: EdgeInsets.only(
                              right: AppPadding.p60.w,
                              left: AppPadding.p60.w,
                              top: AppSize.h86_6.h,
                              bottom: AppSize.h114_6.h),
                          child: Text(
                            getTranslated(context, "loginText"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              fontSize: AppFontsSizeManager.s24.sp,
                              color: AppColors.darkGrey3,
                            ),
                          ),
                        ),
                      ),
                      BlocConsumer<SignupCubit, SignupStates>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            SignupCubit cubit = SignupCubit().get(context);
                            return Center(
                              child: Directionality(
                                textDirection: TextDirection.rtl,
                                child: Center(
                                  child: Container(
                                    //margin: EdgeInsets.symmetric(horizontal: size.width * .31),
                                    //padding: EdgeInsets.symmetric( horizontal: 30,  ),
                                    padding: EdgeInsets.symmetric(
                                      horizontal: AppPadding.p20.w,
                                    ),
                                    height: AppSize.h74_6.r,
                                    width: AppSize.w558.w,
                                    decoration: BoxDecoration(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.r40.r),
                                      color: AppColors.grey4,
                                    ),
                                    child: Theme(
                                      data: ThemeData(
                                        dialogTheme: DialogTheme(
                                          titleTextStyle: TextStyle(
                                            fontFamily:
                                                getTranslated(context, "Ithra"),
                                          ),
                                          backgroundColor: AppColors.white,
                                          shape: RoundedRectangleBorder(
                                            borderRadius: BorderRadius.all(
                                                Radius.circular(AppRadius
                                                    .r22)), // Border radius
                                          ),
                                          // Your desired color
                                        ),
                                      ),
                                      child: InternationalPhoneNumberInput(
                                        initialValue: cubit.number,
                                        searchBoxDecoration: InputDecoration(
                                          counterStyle: TextStyle(
                                            height: double.minPositive,
                                          ),
                                          counterText: "",
                                          filled: true,
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                              left: AppPadding.p16_6.w,
                                              right: AppPadding.p16_6.w),
                                          helperStyle: TextStyle(
                                            fontFamily:
                                                getTranslated(context, "Ithra"),
                                            color:
                                                Colors.black.withOpacity(0.65),
                                            letterSpacing:
                                                AppConstants.letterSpacing0_5,
                                          ),
                                          hintStyle: TextStyle(
                                            fontFamily:
                                                getTranslated(context, "Ithra"),
                                            color: AppColors.red,
                                            fontWeight:
                                                AppFontsWeightManager.bold100,
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            letterSpacing:
                                                AppConstants.letterSpacing0_5,
                                          ),
                                          hintText: getTranslated(
                                              context, 'enterMobile'),
                                        ),
                                        textAlignVertical:
                                            TextAlignVertical.top,
                                        inputDecoration: InputDecoration(
                                          icon: SizedBox(
                                            height: AppSize.h33_3.h,
                                            child: VerticalDivider(
                                              width: AppSize.w6.w,
                                              color: AppColors.linear1,
                                            ),
                                          ),
                                          counterStyle: TextStyle(
                                            height: double.minPositive,
                                          ),
                                          counterText: "",
                                          focusedBorder: InputBorder.none,
                                          enabledBorder: InputBorder.none,
                                          contentPadding: EdgeInsets.only(
                                            bottom: AppPadding.p10.h,
                                          ),
                                          helperStyle: TextStyle(
                                            fontFamily:
                                                getTranslated(context, "Ithra"),
                                            color: Colors.grey,
                                            letterSpacing:
                                                AppConstants.letterSpacing0_5,
                                          ),
                                          hintStyle: TextStyle(
                                            fontFamily: getTranslated(
                                                context, "Ithralight"),
                                            color: AppColors.lightGrey1,
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            letterSpacing:
                                                AppConstants.letterSpacing1,
                                          ),
                                          hintText: getTranslated(
                                              context, 'enterMobile'),
                                        ),
                                        onInputChanged: (PhoneNumber number) {
                                          cubit.onChangePhoneNumber(number);
                                        },
                                        onInputValidated: (bool value) {},
                                        locale: getTranslated(context, 'lang'),
                                        selectorConfig: SelectorConfig(
                                          trailingSpace: false,
                                          selectorType:
                                              PhoneInputSelectorType.DIALOG,
                                        ),
                                        ignoreBlank: false,
                                        autoValidateMode:
                                            AutovalidateMode.disabled,
                                        selectorTextStyle: TextStyle(
                                          color: Colors.grey,
                                          fontWeight:
                                              AppFontsWeightManager.bold500,
                                          fontFamily: getTranslated(
                                              context, "Montserrat"),
                                          fontStyle: FontStyle.normal,
                                          fontSize: AppFontsSizeManager.s21.sp,
                                        ),
                                        textFieldController: controller,
                                        formatInput: false,
                                        keyboardType:
                                            TextInputType.numberWithOptions(
                                                signed: true, decimal: true),
                                        inputBorder: InputBorder.none,
                                        onSaved: (PhoneNumber number) {},
                                      ),
                                    ),
                                  ),
                                ),
                              ),
                            );
                          }),
                      SizedBox(
                        height: AppSize.h160.h,
                      ),
                      BlocConsumer<SignupCubit, SignupStates>(
                          listener: (context, state) {},
                          builder: (context, state) {
                            SignupCubit cubit = SignupCubit().get(context);

                            return ConditionalBuilder(
                              condition: state is LoginLoadingState ||
                                  state is GenerateOTPLoadingState,
                              builder: (context) => Center(
                                child: CircularProgressIndicator(),
                              ),
                              fallback: (context) => Center(
                                child: Padding(
                                  padding: EdgeInsets.only(
                                    bottom: AppPadding.p72.h,
                                  ),
                                  child: PrimaryButton(
                                    width: AppSize.w390_6.r,
                                    height: AppSize.h66_6.r,
                                    onPress: () {
                                      if (cubit.number.phoneNumber == null) {
                                        showFailedSnackBar(
                                            getTranslated(context, "enterAll"));
                                      } else {
                                        String phoneNum =
                                            getPhoneWithoutCountryCode(
                                                cubit.number.phoneNumber!,
                                                cubit.number.dialCode!);
                                        if (phoneNum.trim().isEmpty) {
                                          showFailedSnackBar(getTranslated(
                                              context, "enterAll"));
                                        } else {
                                          cubit.login(
                                              context: context,
                                              userType: userType);
                                        }
                                      }
                                    },
                                    text: getTranslated(context, "sendCode"),
                                    textSize: AppFontsSizeManager.s20.sp,
                                    buttonRadius: AppRadius.r19.r,
                                  ),
                                ),
                              ),
                            );
                          }),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisAlignment: MainAxisAlignment.end,
                        children: [
                          Column(
                            mainAxisAlignment: MainAxisAlignment.end,
                            children: [
                              Text(
                                getTranslated(context, "registerNote1"),
                                style: TextStyle(
                                  color: AppColors.grey1,
                                  fontWeight: AppFontsWeightManager.bold300,
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontStyle: FontStyle.normal,
                                  fontSize: AppFontsSizeManager.s18_6.sp,
                                ),
                              ),
                              SizedBox(
                                height: AppSize.h8.h,
                              ),
                              InkWell(
                                splashColor: Colors.blue.withOpacity(0.6),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) =>
                                          PrivecyScreen(), //TermScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  getTranslated(context, "registerNote2"),
                                  style: TextStyle(
                                      color: AppColors.primaryColor,
                                      //fontWeight: AppFontsWeightManager.bold600,
                                      fontFamily:
                                          getTranslated(context, "Ithralight"),
                                      fontStyle: FontStyle.normal,
                                      fontSize: AppFontsSizeManager.s18_6.sp),
                                ),
                              ),
                              SizedBox(
                                height: AppSize.h1.h,
                              ),
                              InkWell(
                                splashColor: Colors.blue.withOpacity(0.6),
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => PrivecyScreen(),
                                    ),
                                  );
                                },
                                child: Text(
                                  getTranslated(context, "registerNote3"),
                                  style: TextStyle(
                                    // fontWeight: AppFontsWeightManager.bold600,
                                    fontFamily:
                                        getTranslated(context, "Ithralight"),
                                    decorationColor: AppColors.primaryColor,
                                    decorationThickness: 1,
                                    color: AppColors.primaryColor,
                                    fontSize: AppFontsSizeManager.s18_6.sp,
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Spacer(
                        flex: 2,
                      ),
                    ],
                  ),
                ),
              ),
            )),
          )),
    );
  }
}
