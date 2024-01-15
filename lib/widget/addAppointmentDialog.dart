import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/svg.dart';
import 'package:hijri/hijri_calendar.dart';
import 'package:intl/intl.dart';
import 'package:jeras/hijri_picker.dart';
import 'package:jeras/widget/primary_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../enums/payment_types.dart';
import '../localization/localization_methods.dart';
import '../methods/convert_pt_to_px.dart';
import '../models/consultDays.dart';
import '../models/consultPackage.dart';
import '../models/order.dart';
import '../models/promoCode.dart';
import 'component/TextButton.dart';
import 'consultant_details_widgets/custom_stepper.dart';
import 'consultant_details_widgets/error_message.dart';
import 'consultant_details_widgets/load_times_shimmer.dart';
import 'consultant_details_widgets/order_details_line.dart';
import 'consultant_details_widgets/payment_radio_button.dart';
import 'dialogs/custom_text_dialog.dart';
import 'jerasDialogWidget.dart';

class AddAppointmentDialog extends StatefulWidget {
  final GroceryUser loggedUser;
  final GroceryUser consultant;
  final int localFrom;
  final int localTo;
  consultPackage package;
  Function({
    required DateTime date,
    // required int currentNumber,
    required int selectedCard,
    // required String consultType,
    required String time,
    required List<dynamic> todayAppointmentList,
    required PaymentTypes paymentType,
    required double totalPrice,
  }) getData;

  AddAppointmentDialog({
    required this.loggedUser,
    required this.consultant,
    required this.package,
    required this.localFrom,
    required this.localTo,
    required this.getData,
    required this.backFromBooking,
  });

  Function({
  required bool backFromBooking,
  }) backFromBooking;

  @override
  _AddAppointmentDialogState createState() => _AddAppointmentDialogState();
}

class _AddAppointmentDialogState extends State<AddAppointmentDialog> {
  final TextEditingController controller = TextEditingController();
  int selectedCard = -1;
  bool hijri = false,
      gregorian = true,
      loadDates = false,
      dateSelected = true,
      dateUnSelect = false;
  String time = DateFormat('yyyy-MM-dd').format(DateTime.now()), dateText = "";
  String?
      displayedTime; //= DateFormat('yyyy-MM-dd').format(DateTime.now()).toString();
  late DateTime selectedDate = DateTime.now(), date;
  List<String> todayAppointmentList = [];
  int currentPage = 0;
  String? promoCodeId;
  PromoCode? promo;
  dynamic discount = 0;
  bool valid = false, checkPromo = false;
  String? selectedTime;
  PaymentTypes? paymentType;
  late String userImage, userName, lang = "ar", theme = "light";
  bool showDayError= false;


  @override
  void initState() {
    super.initState();
    // getDate();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: EdgeInsets.symmetric(horizontal: convertPtToPx(AppSize.w24).w),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          CustomStepper(
            progress: currentPage,
            width: size.width,
          ),
          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),

          pages(size)[currentPage],

          SizedBox(
            height: convertPtToPx(AppSize.h32).h,
          ),

          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              InkWell(
                onTap: () {
                  if (currentPage > 0) {
                    setState(() {
                      currentPage--;
                    });
                  } else {
                    widget.backFromBooking(backFromBooking: true);
                  }
                },
                child: Container(
                  height: convertPtToPx(AppSize.h50).h,
                  width: convertPtToPx(AppSize.h50).h,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r8).r),
                    border:
                    Border.all(color: AppColors.pink, width: convertPtToPx(AppRadius.r1).r),
                  ),
                  child: Icon(
                    Icons.arrow_back_sharp,
                    size: AppSize.w40.r,
                    color: AppColors.pink,
                  ),
                ),
              ),
              PrimaryButton(
                text: currentPage == (pages(size).length - 1)
                    ? getTranslated(context, "payment")
                    : getTranslated(context, "next"),
                width:convertPtToPx( AppSize.w183).w,
                height: convertPtToPx(AppSize.h50).h,
                buttonRadius: convertPtToPx(AppRadius.r8).r,
                textSize: AppFontsSizeManager.s21_3.sp,
                color: AppColors.pink,
                onPress: () async {
                  if (currentPage == 0) {
                    if (displayedTime == null) {
                      /// show select day text.
                      setState(() {
                        showDayError = true;
                      });
                    } else if (todayAppointmentList.isEmpty || selectedCard < 0) {
                      customTextDialog(
                          context: context,
                          okFunction: () {
                            Navigator.pop(context);
                          },
                          buttonText: getTranslated(context, 'Ok'),

                          /// change this text
                          text: getTranslated(context, 'timeNotSelected'),
                          textSize: AppFontsSizeManager.s24);
                    } else {
                      setState(() {
                        currentPage++;
                      });
                    }
                  } else {
                    if (currentPage < (pages(size).length - 1)) {
                      setState(() {
                        currentPage++;
                      });
                    } else {

                      if (paymentType == null) {
                        customTextDialog(
                            context: context,
                            text:
                                getTranslated(context, 'chosePaymentMethod'),
                            buttonText: getTranslated(context, 'Ok'),
                            okFunction: () {
                              Navigator.pop(context);
                            });
                      } else {
                        widget.getData(
                          date: DateTime.parse(
                              todayAppointmentList[selectedCard]),
                          selectedCard: selectedCard,
                          time: time,
                          todayAppointmentList: todayAppointmentList,
                          paymentType: paymentType!,
                          totalPrice: widget.package.price -
                              ((discount * widget.package.price) / 100),
                        );
                      }
                    }
                  }
                },
              ),
            ],
          ),

          SizedBox(
            height: convertPtToPx(AppSize.h42).h,
          ),

        ],
      ),
    );
  }

  List<Widget> pages(Size size) =>
      [availableDays(size), orderDetailsWidget(size)];

  Widget availableDays(Size size) => Column(
    mainAxisSize: MainAxisSize.min,
    children: [
      Container(
        padding: EdgeInsets.symmetric(
            vertical: convertPtToPx(AppPadding.p24).h,
            horizontal: convertPtToPx(AppPadding.p16).w),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius:
            BorderRadius.circular(convertPtToPx(AppRadius.r12).r),
          border: Border.all(color: AppColors.grey2, width: convertPtToPx(AppRadius.r1).r)
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Text(
              getTranslated(context, "selectSuitableDay"),
              style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                fontSize: AppFontsSizeManager.s14_5,
                fontWeight: AppFontsWeightManager.semiBold,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: AppColors.black,
              ),
            ),
            SizedBox(
              height: convertPtToPx(AppSize.h24).h,
            ),

            Container(
              padding: EdgeInsets.all(convertPtToPx(AppPadding.p8).w),
              decoration: BoxDecoration(
                color: AppColors.grey4,
                borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r12).r),
              ),


              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(
                    child: InkWell(
                      splashColor: AppColors.green.withOpacity(0.6),
                      onTap: () {
                        setState(() {
                          displayedTime =
                              DateFormat('yyyy-MM-dd').format(DateTime.now());
                          selectedDate = DateTime.now();
                          time = DateFormat('yyyy-MM-dd').format(DateTime.now());
                          gregorian = true;
                          hijri = false;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppSize.h40
                            : convertPtToPx(AppSize.h38).h,
                        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppSize.w0_1
                            : size.width * AppSize.w0_3,
                        decoration: BoxDecoration(
                          color: gregorian
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.r5),
                        ),
                        child: Text(
                          getTranslated(context, "gregorian"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontWeight: AppFontsWeightManager.semiBold,
                            color: gregorian
                                ? AppColors.white
                                : Theme.of(context).primaryColor,
                            fontSize: (kIsWeb || size.width >= 500)
                                ? AppFontsSizeManager.s15.sp
                                : convertPtToPx(AppFontsSizeManager.s16).sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: AppSize.w15.w,
                  ), 
                  Expanded(
                    child: InkWell(
                      splashColor: AppColors.green.withOpacity(0.6),
                      onTap: () {
                        setState(() {
                          displayedTime = HijriCalendar.now().toString();
                    
                          ///
                          selectedDate = DateTime.now();
                          time = DateFormat('yyyy-MM-dd').format(DateTime.now());
                          gregorian = false;
                          hijri = true;
                        });
                      },
                      child: Container(
                        alignment: Alignment.center,
                        height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppSize.h40
                            : convertPtToPx(AppSize.h38).h,
                        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppSize.w0_1
                            : size.width * AppSize.w0_3,
                        decoration: BoxDecoration(
                          color: hijri
                              ? Theme.of(context).primaryColor
                              : Colors.transparent,
                          borderRadius: BorderRadius.circular(AppRadius.r5),
                        ),
                        child: Text(
                          getTranslated(context, "hijri"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontWeight: AppFontsWeightManager.semiBold,
                            color: hijri
                                ? AppColors.white
                                : Theme.of(context).primaryColor,
                            fontSize: (kIsWeb || size.width >= 500)
                                ? AppFontsSizeManager.s15.sp
                                : convertPtToPx(AppFontsSizeManager.s16).sp,
                          ),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),

            SizedBox(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h20.h
                  : convertPtToPx(AppSize.h24).h,
            ),

            Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h45.h
                  : convertPtToPx(AppSize.h51).h,
              width: double.infinity,
              decoration: BoxDecoration(
                color: AppColors.grey4,
                borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r8).r),
              ),
              child: Padding(
                padding: EdgeInsets.symmetric(horizontal: convertPtToPx(AppPadding.p16).w,),
                child: InkWell(
                  splashColor: AppColors.white.withOpacity(0.6),
                  onTap: () async {
                    if (hijri)
                      _selectHijriDate(context);
                    else
                      _selectDate(context);
                  },
                  child: Row(
                    children: [
                      Text(
                        displayedTime ?? getTranslated(context, 'selectDay'),
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          color: Theme.of(context).primaryColor,
                          fontWeight: AppFontsWeightManager.semiBold,
                          fontSize: (kIsWeb || size.width >= 500)
                              ? AppFontsSizeManager.s18.sp
                              : convertPtToPx(AppFontsSizeManager.s16).sp,
                        ),
                      ),
                      Spacer(),
                      SvgPicture.asset(
                        AssetsManager.calendarClockIconPath,
                        height: convertPtToPx(AppSize.w24).r,
                        width: convertPtToPx(AppSize.w24).r,
                      ),

                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
      /// error message when the user does not select the day.
      ///
      if (showDayError && loadDates == false)
        ErrorMessage(errorMessage: getTranslated(context, 'selectSuitableDay'), buttomPadding: 0.0,),

      /// Available Hours
      AvailableHours(),
    ],
  );

  Widget AvailableHours() => (loadDates == false )
      ? Padding(
    padding: EdgeInsets.only(
      top: convertPtToPx(AppSize.h24).h,
    ),
    child: Container(
      //height: convertPtToPx(AppSize.h182).h,
      padding: EdgeInsets.symmetric(
          horizontal: convertPtToPx(AppPadding.p16).w,
          vertical: convertPtToPx(AppPadding.p24).h),
      decoration: BoxDecoration(
          color: Colors.white,
          borderRadius:
          BorderRadius.circular(convertPtToPx(AppRadius.r12).r),
          border: Border.all(color: AppColors.grey2, width: convertPtToPx(AppRadius.r1).r)
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            getTranslated(context, "selectTime"),
            style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                color: AppColors.grey_dark,
                fontWeight: AppFontsWeightManager.bold,
                fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                fontStyle: FontStyle.normal,
                letterSpacing: convertPtToPx(-0.41)),
          ),
          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),

          Text(
            getTranslated(context, "selectTimeNote"),
            style: TextStyle(
                fontFamily: getTranslated(context, 'Ithra'),
                color: AppColors.grey1,
                fontWeight: AppFontsWeightManager.regular,
                fontSize: convertPtToPx(AppFontsSizeManager.s12).sp,
                fontStyle: FontStyle.normal,
                letterSpacing: convertPtToPx(-0.41)),
          ),
          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),

          Container(
            height: convertPtToPx(AppSize.h45).h,
            padding: EdgeInsets.symmetric(
              horizontal: convertPtToPx(AppSize.w16).w,
            ),
            decoration: BoxDecoration(
                borderRadius:
                BorderRadius.circular(convertPtToPx(AppRadius.r8).r),
                color: todayAppointmentList.isEmpty ? AppColors.grey4 : AppColors.lightPink
              ),
            child: DropdownButtonHideUnderline(
              child: DropdownButton<String>(
                value: selectedTime,
                borderRadius: BorderRadius.circular(AppRadius.r5_3.r),
                isExpanded: true,
                menuMaxHeight: AppSize.h356.h,
                hint: Text(
                  getTranslated(context, 'selectAppointment'),
                  style: TextStyle(
                      fontFamily: getTranslated(context, 'Ithra'),
                      color: AppColors.grey,
                      fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                      fontWeight: AppFontsWeightManager.bold),
                ),
                icon: Image.asset(
                  AssetsManager.arrowLeft,
                  height: AppSize.h21_3.h,
                  width: AppSize.w21_3.w,
                  color: todayAppointmentList.isEmpty ? AppColors.grey : AppColors.pink,
                ),
                elevation: 16,
                style: TextStyle(
                    fontFamily: getTranslated(context, 'Ithra'),
                    color: AppColors.pink,
                    fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                    fontWeight: AppFontsWeightManager.bold),
                onChanged: (value) {
                  setState(() {
                    selectedTime = value;
                    selectedCard = todayAppointmentList.indexOf(value!);
                  });
                },
                items: todayAppointmentList.map((String value) {
                  return DropdownMenuItem<String>(
                    value: value,
                    child: Text(
                      convertTime(value, context),
                      style: TextStyle(
                          fontFamily: getTranslated(context, 'Ithra'),
                          color: AppColors.pink,
                          fontSize:
                          convertPtToPx(AppFontsSizeManager.s16).sp,
                          fontWeight: AppFontsWeightManager.bold),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    ),
  )
      : LoadTimesShimmer(height: AppSize.h181_3,);


  Widget orderDetailsWidget(Size size) {
    return Container(
      padding: EdgeInsets.all(convertPtToPx(AppRadius.r16).w),
      decoration: BoxDecoration(
        color: AppColors.lightGrey8,
        borderRadius: BorderRadius.circular(
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? 16.r
                : convertPtToPx(AppRadius.r12).r),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.package.discount == null || widget.package.discount == 0)
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: EdgeInsets.symmetric(
                      horizontal: convertPtToPx(AppRadius.r8).w,
                      // vertical: convertPtToPx(AppRadius.r10).h,
                  ),

                  height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? AppSize.h110.h
                      : convertPtToPx(AppSize.h52).h,
                  // width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  //     ? AppSize.w904.w
                  //     : AppSize.w421.w,
                  decoration: BoxDecoration(
                    color: AppColors.white,
                    borderRadius: BorderRadius.circular(
                        (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? 16.r
                            : 5.r),
                    boxShadow: [
                      BoxShadow(
                          color: const Color(0x1cae9cce),
                          offset: Offset(0, 3),
                          blurRadius: 11,
                          spreadRadius: 0)
                    ],
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: TextFormField(
                          controller: controller,
                          keyboardType: TextInputType.text,
                          textAlign: TextAlign.start,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                          enableInteractiveSelection: true,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithralight"),
                            fontSize:
                                (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s32.sp
                                    : convertPtToPx(AppFontsSizeManager.s14).sp,
                            color: AppColors.primaryColor,
                            letterSpacing: AppConstants.letterSpacing0_5,
                            fontWeight: AppFontsWeightManager.regular,
                          ),
                          textAlignVertical: TextAlignVertical.center,
                          decoration: InputDecoration(
                            prefixIcon: Padding(
                              padding: EdgeInsets.all((kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 6
                                  : 12),
                              child: SvgPicture.asset(
                                  AssetsManager.discountIconPath,
                                  fit: BoxFit.cover,
                                  color: AppColors.primaryColor),
                            ),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "enterPromoCode"),
                            hintStyle: TextStyle(
                              fontWeight: AppFontsWeightManager.regular,
                              fontFamily: getTranslated(context, "Ithralight"),
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : convertPtToPx(AppFontsSizeManager.s14).sp,
                              color: AppColors.primaryColor,
                            ),
                            counterStyle: TextStyle(
                              fontFamily: getTranslated(context, "Ithralight"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : convertPtToPx(AppFontsSizeManager.s14).sp,
                              color: AppColors.primaryColor,
                              fontWeight: AppFontsWeightManager.regular,
                            ),
                          ),
                          onChanged: (text) {
                            if (text.length < 5) {
                              setState(() {
                                promo = null;
                                promoCodeId = "";
                                checkPromo = false;
                                valid = false;
                                discount = 0;
                              });
                            }
                            if (text.length == 0) {
                              setState(() {
                                // promo = null;
                                promoCodeId = "";
                                checkPromo = false;
                                valid = false;
                                discount = 0;
                              });
                            }
                          },
                        ),
                      ),
                      InkWell(
                        onTap: () {
                          calculateDiscount();
                        },
                        child: Container(
                          alignment: Alignment.center,
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w217.w
                                  : convertPtToPx(AppSize.w159).w,
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h65.h
                                  : convertPtToPx(AppSize.h32).h,
                          decoration: BoxDecoration(
                              color: discount > 0
                                  ? AppColors.lightGreenColor
                                  : AppColors.primaryColor,
                              borderRadius:
                                  BorderRadius.circular(AppRadius.r6_5.r)),
                          child: Text(
                            discount > 0
                                ? getTranslated(context, "activated")
                                : getTranslated(context, "activate"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              fontFamily: getTranslated(context, 'Ithra'),
                              color: discount > 0
                                  ? AppColors.darkGreen
                                  : AppColors.white,
                              fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                              fontWeight: AppFontsWeightManager.semiBold,
                              fontStyle: FontStyle.normal,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),


                  Padding(
                    padding: EdgeInsets.only(top: convertPtToPx(AppSize.h12).h),
                    child: Text(
                      getTranslated(context, "proText") + ' ' + '${discount > 0 ? (discount.toString() + "%") : ''}',
                      maxLines: 3,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      style: TextStyle(
                        fontWeight: AppFontsWeightManager.bold300,
                        fontFamily: getTranslated(context, "Ithra"),
                        fontStyle: FontStyle.normal,
                        fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s31.sp
                            : AppFontsSizeManager.s14.sp,
                        color: AppColors.grey,
                      ),
                    ),
                  ),
              ],
            ),

          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),

          Container(
            padding: EdgeInsets.all(convertPtToPx(AppPadding.p16).w),
            decoration: BoxDecoration(
              color: AppColors.white,
              borderRadius: BorderRadius.circular(convertPtToPx(AppRadius.r13).r),
                border: Border.all(color: AppColors.grey2, width: convertPtToPx(AppRadius.r1).r)
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  getTranslated(context, "orderDetails"),
                  style: TextStyle(
                    color: AppColors.primaryColor,
                    fontWeight: AppFontsWeightManager.semiBold,
                    fontSize: convertPtToPx(AppFontsSizeManager.s14).sp,
                    fontFamily: getTranslated(context, "Ithra"),
                  ),
                ),

                Center(
                  child: Container(
                    margin: EdgeInsets.only(
                      top: convertPtToPx(AppSize.h7).h,
                      bottom: convertPtToPx(AppSize.h8).h
                    ),
                      color: AppColors.lightGrey,
                      height: AppSize.h1.h,
                      width: AppSize.w410.w),
                ),

                /// Call numbers.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "packageCall"),
                  value: '${widget.package.callNum}',
                ),

                /// The appointment.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "theAppointment"),
                  value: '$displayedTime - ${selectedTime == null ? '' : convertTime(selectedTime!, context)}',
                ),

                /// Package price.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "packagePrice"),
                  value:
                      '${((widget.package.price * 100) / (100 - widget.package.discount)).toStringAsFixed(2)} \$', //'${widget.package.price} \$',
                ),

                /// discount.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "discount2"),
                  value: widget.package.discount == null ||
                          widget.package.discount == 0
                      ? '- ${((discount * widget.package.price) / 100).toStringAsFixed(2)} \$'
                      : '- ${(widget.package.discount).toStringAsFixed(2)}',
                ),

                /// package price after discount.
                ///
                OrderDetailsLine(
                  header: getTranslated(context, "packagePriceAfter"),
                  value:
                      '${(widget.package.price - ((discount * widget.package.price) / 100)).toStringAsFixed(2)} \$',
                ),

                Container(
                    margin: EdgeInsets.only(
                        top: convertPtToPx(AppSize.h3).h,
                        bottom: convertPtToPx(AppSize.h8).h
                    ),
                    color: AppColors.lightGrey,
                    height: AppSize.h1.h,
                    width: double.infinity),


                OrderDetailsLine(
                  header: getTranslated(context, "totalAmount"),
                  value:
                      '${(widget.package.price - ((discount * widget.package.price) / 100)).toStringAsFixed(2)} \$',
                  headerColor: AppColors.primaryColor,
                  valueColor: AppColors.primaryColor,
                ),
              ],
            ),
          ),
          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),
          Align(
            alignment: AlignmentDirectional.centerStart,
            child: Text(
              getTranslated(context, 'paymentWay'),
              style: TextStyle(
                color: AppColors.primaryColor,
                fontSize: convertPtToPx(AppFontsSizeManager.s16).sp,
                fontFamily: getTranslated(context, "Ithra"),
                fontWeight: AppFontsWeightManager.semiBold,
              ),
            ),
          ),

          SizedBox(
            height: convertPtToPx(AppSize.h24).h,
          ),

          if (checkBalance())
            PaymentRadioButton(
              icons: [],
              text: getTranslated(context, 'payFromBalance'),

              isSelected: paymentType == PaymentTypes.balance ? true : false,
              endIcon: AssetsManager.walletIcon,
              endIconWidth: AppSize.w40,
              endPadding: AppSize.w12.w,
              function: () {
                setState(() {
                  paymentType = PaymentTypes.balance;
                });
              },
            ),
          if (!kIsWeb)
            PaymentRadioButton(
              icons: kIsWeb
                  ? [
                      AssetsManager.googlePayLogo,
                      AssetsManager.applePayLogo,
                      AssetsManager.kareemPaymentLogo,
                      AssetsManager.mastercard,
                      AssetsManager.visa,
                      AssetsManager.amPay,
                    ]
                  : [
                      Platform.isAndroid
                          ? AssetsManager.googlePayLogo
                          : AssetsManager.applePayLogo,
                      AssetsManager.kareemPaymentLogo,
                      AssetsManager.mastercard,
                      AssetsManager.visa,
                      AssetsManager.amPay,
                    ],
              isSelected: paymentType == PaymentTypes.tapCompany ? true : false,
              endIcon: AssetsManager.oTap,
              function: () {
                setState(() {
                  paymentType = PaymentTypes.tapCompany;
                });
              },
            ),
          PaymentRadioButton(
            icons: [
              AssetsManager.mastercard,
              AssetsManager.visa,
            ],
            withBottomPadding: false,
            isSelected: paymentType == PaymentTypes.stripe ? true : false,
            endIcon: AssetsManager.stripeLogo,
            function: () {
              setState(() {
                paymentType = PaymentTypes.stripe;
              });
            },
          ),
        ],
      ),
    );
  }

  calculateDiscount() async {
    setState(() {
      checkPromo = true;
    });
    if (controller.text != "") {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.promoPath)
          .where('promoCodeStatus', isEqualTo: true)
          .where('code', isEqualTo: controller.text)
          .limit(1)
          .get();
      var codes = List<PromoCode>.from(
        querySnapshot.docs.map(
          (snapshot) => PromoCode.fromMap(snapshot.data() as Map),
        ),
      );
      if (codes.length > 0) {
        print("promo3");
        print(codes[0].type);
        bool isPrimary = (codes[0].type == "primary" &&
            codes[0].promoCodeStatus &&
            widget.loggedUser.promoList != null &&
            widget.loggedUser.promoList!.contains(codes[0].promoCodeId) ==
                false);
        if ((codes[0].type == "default" && codes[0].promoCodeStatus) ||
            isPrimary) print(isPrimary);
        if ((codes[0].type == "default" && codes[0].promoCodeStatus) ||
            isPrimary)
          setState(() {
            print("valid");
            promo = codes[0];
            promoCodeId = promo!.promoCodeId;
            checkPromo = false;
            valid = true;
            discount = promo!.discount;
          });
        else
          setState(() {
            print("promo4");
            promoCodeId = "";
            checkPromo = false;
            valid = false;
            discount = 0;
          });
      } else {
        setState(() {
          print("promo4");
          // promo = null;
          promoCodeId = "";
          checkPromo = false;
          valid = false;
          discount = 0;
        });
      }
    }
  }

  //-----------

  NavigatePop() {
    Navigator.pop(context);
    Navigator.pop(context, true);
  }

  getDate() async {
    try {
      if (DateTime(selectedDate.year, selectedDate.month, selectedDate.day)
              .isBefore(DateTime(DateTime.now().year, DateTime.now().month,
                  DateTime.now().day)) ||
          (!widget.consultant.workDays!
              .contains(selectedDate.weekday.toString()))) {
        setState(() {
          loadDates = false;
          todayAppointmentList = [];
          dateText = getTranslated(context, "selectData");
        });
      } else {

        DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
            .collection(Paths.consultDaysPath)
            .doc(time + "-" + widget.consultant.uid!)
            .get();
        if (documentSnapshot.exists) {
          ConsultDays consultDays =
              ConsultDays.fromMap(documentSnapshot.data() as Map);
          List<String> appointmentList = [];

          for (int start = 0;
              start < consultDays.todayAppointmentList.length;
              start++) {
            if (DateTime.parse(consultDays.todayAppointmentList[start])
                .toLocal()
                .isAfter(DateTime.now())) {
              appointmentList.add(consultDays.todayAppointmentList[start]);
            }
          }
          print('================l $todayAppointmentList');

          setState(() {
            loadDates = false;
            todayAppointmentList = appointmentList;
            if (todayAppointmentList.length == 0){
              dateText = getTranslated(context, "noAppointment");
            }else{
              selectedTime= todayAppointmentList.first;
              selectedCard= 0;
            }
          });
        } else {
          print('================l exist');

          var from = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, widget.localFrom);
          var to = DateTime(selectedDate.year, selectedDate.month,
              selectedDate.day, widget.localTo);

          /// ttt is difference between start and end time of the teacher.
          var ttt = (to.difference(from).inHours).round();
          if (ttt <= 0) {
            to = DateTime(
                selectedDate.year, selectedDate.month, selectedDate.day, 24);
            ttt = (to.difference(from).inHours).round();
          }
          List<String> appointmentList = [];
          //var lessonTime=10;
          var lessonMintes = 60;
          for (int start = 0; start < ttt; start++) {
            if (from.add(Duration(hours: start)).isAfter(DateTime.now())) {
              var value = from.add(Duration(hours: start)).toUtc().toString();
              appointmentList.add(value);
            }
          }
          print('================l exist $todayAppointmentList');

          await FirebaseFirestore.instance
              .collection(Paths.consultDaysPath)
              .doc(time + "-" + widget.consultant.uid!)
              .set({
            'id': time + "-" + widget.consultant.uid!,
            'day': time,
            'date': DateTime(
                    selectedDate.year, selectedDate.month, selectedDate.day)
                .millisecondsSinceEpoch,
            'consultUid': widget.consultant.uid,
            'todayAppointmentList': appointmentList,
          });
          setState(() {
            loadDates = false;
            todayAppointmentList = appointmentList;
            selectedTime = todayAppointmentList.first;
            selectedCard = 0;
          });
        }
      }
    } catch (e) {
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone':
            widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "getDate",
      });
    }
  }

  Future<void> _selectDate(BuildContext context) async {
    try {
      final DateTime? picked = await showDatePicker(
          context: context,
          initialDate: selectedDate,
          firstDate: DateTime(2015, 8),
          lastDate: DateTime(2101));
      if (picked != null && picked != selectedDate) {
        setState(() {
          selectedDate = picked;
          time = DateFormat('yyyy-MM-dd').format(picked);
          displayedTime = time;
          loadDates = true;
          todayAppointmentList = [];
          dateText = getTranslated(context, "load");
          showDayError= false;
        });
        getDate();
      }
    } catch (e) {
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone':
            widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "_selectDate",
      });
    }
  }

  Future<Null> _selectHijriDate(BuildContext context) async {
    try {
      final HijriCalendar? picked = await showHijriDatePicker(
        context: context,
        initialDate: new HijriCalendar.now(),
        lastDate: new HijriCalendar()
          ..hYear = 1445
          ..hMonth = 9
          ..hDay = 25,
        firstDate: new HijriCalendar()
          ..hYear = 1438
          ..hMonth = 12
          ..hDay = 25,
        initialDatePickerMode: DatePickerMode.day,
      );
      if (picked != null) {
        setState(() {
          selectedDate = HijriCalendar()
              .hijriToGregorian(picked.hYear, picked.hMonth, picked.hDay);
          time = DateFormat('yyyy-MM-dd').format(selectedDate);
          displayedTime = picked.toString();
          loadDates = true;
          todayAppointmentList = [];
          dateText = getTranslated(context, "load");
          showDayError= false;
        });
        getDate();
      }
    } catch (e) {
      String id = Uuid().v4();
      await FirebaseFirestore.instance
          .collection(Paths.errorLogPath)
          .doc(id)
          .set({
        'timestamp': Timestamp.now(),
        'id': id,
        'seen': false,
        'desc': e.toString(),
        'phone':
            widget.loggedUser == null ? " " : widget.loggedUser.phoneNumber,
        'screen': "ConsultantDetailsScreen",
        'function': "_selectHijriDate",
      });
    }
  }

  bool checkBalance() {
    if (double.parse(widget.loggedUser.balance.toString()) >=
        widget.package.price - ((discount * widget.package.price) / 100)) {
      return true;
    }
    return false;
  }
}


String convertTime(String value, BuildContext context) {
  String minues = "00";
  String? finalTime;

  if (DateTime.parse(value).toLocal().minute != 0)
    minues = DateTime.parse(value).toLocal().minute.toString();
  if (DateTime.parse(value).toLocal().hour > 12)
    finalTime = ((DateTime.parse(value).toLocal().hour) - 12).toString() +
        ":" +
        minues +
        ' ' +
        getTranslated(context, 'pm');
  else if (DateTime.parse(value).toLocal().hour == 12)
    finalTime = ((DateTime.parse(value).toLocal().hour)).toString() +
        ":" +
        minues +
        ' ' +
        getTranslated(context, 'pm');
  else
    finalTime = DateTime.parse(value).toLocal().hour.toString() +
        ":" +
        minues +
        ' ' +
        getTranslated(context, 'am');

  return finalTime;
}