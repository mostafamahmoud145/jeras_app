import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../screens/addFakeAppointment.dart';
import '../../widget/forEverWidget.dart';
import '../../widget/techAppointmentWidget.dart';

class AllAppointmentsScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const AllAppointmentsScreen({Key? key, required this.loggedUser})
      : super(key: key);

  @override
  _AllAppointmentsScreenState createState() => _AllAppointmentsScreenState();
}

class _AllAppointmentsScreenState extends State<AllAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  bool load = false, today = true, all = false, filter = false, forEver = false;
  DateTime selectedFromDate = DateTime.now();
  DateTime selectedToDate = DateTime.now();
  bool showResult = false;
  late String from, to;
  late Query filterQuery;

  @override
  void initState() {
    super.initState();
    from = "From";
    to = "To";
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          IconButton1(
                            onPress: Navigator.of(context).pop,
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w97.w
                                : AppSize.w50_6.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h97.h
                                : AppSize.h50.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r24.r
                                : AppRadius.r10_6.r,
                            IconWidth: AppSize.w32.w,
                            IconHeight: AppSize.h32.h,
                            IconColor: Theme.of(context).primaryColor,
                            Icon:
                                AssetsManager.blackArrowRightIconPath,
                            ButtonBackground: AppColors.white,
                          ),
                          SizedBox(width: AppSize.w10.w),
                          Text(
                            getTranslated(context, "appointments"),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: AppFontsWeightManager.bold300,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s31.sp
                                  : AppFontsSizeManager.s15.sp,
                              color: AppColors.black2,
                            ),
                          ),
                        ],
                      ),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50.r),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.6),
                            onTap: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => AddAppointmentScreen(),
                                ),
                              );
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: AppSize.w38.w,
                              height: AppSize.h35.h,
                              child: Icon(
                                Icons.add_circle_outline,
                                color: AppColors.black,
                                size: AppSize.w24,
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Center(
              child: Padding(
            padding: EdgeInsets.symmetric(
                horizontal:
                    (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_25 : AppPadding.p20.w,
                vertical: AppPadding.p20.h),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        today = true;
                        all = false;
                        forEver = false;
                        filter = false;
                        showResult = false;
                      });
                    },
                    child: Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h60.h : AppSize.h40.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * .1
                          : size.width * AppSize.w0_25,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: today
                            ? Theme.of(context).primaryColor
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r30.r : AppRadius.r20.r),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, "today"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: today
                                ? AppColors.white
                                : Theme.of(context).primaryColor,
                            fontSize:
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25.sp : AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold300,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: AppSize.w5.w,
                  ),
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        all = true;
                        today = false;
                        filter = false;
                        forEver = false;
                        showResult = false;
                      });
                    },
                    child: Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h60.h : AppSize.h40.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_1
                          : size.width * AppSize.w0_25,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color:
                            all ? Theme.of(context).primaryColor : AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r30.r : AppRadius.r20.r),
                      ),
                      child: Center(
                        child: Text(
                          getTranslated(context, "all"),
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: all
                                ? AppColors.white
                                : Theme.of(context).primaryColor,
                            fontSize:
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25.sp : AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold300,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: AppSize.w5.w,
                  ),
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        today = false;
                        all = false;
                        forEver = true;
                        //showResult=true;
                      });
                    },
                    child: Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h60.h : AppSize.h40.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_1
                          : size.width * AppSize.w0_25,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: forEver
                            ? Theme.of(context).primaryColor
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r30.r : AppRadius.r20.r),
                      ),
                      child: Center(
                        child: Text(
                          "forever",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: forEver
                                ? AppColors.white
                                : Theme.of(context).primaryColor,
                            fontSize:
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s25.sp : AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold300,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
                    ),
                  ),
                ]),
          )),
          SizedBox(
            height: AppSize.h10.h,
          ),
          today
              ? Expanded(
                  child: PaginateFirestore(
                    itemBuilderType: PaginateBuilderType.listView,
                    separator: SizedBox(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h40.h : AppSize.h20.h,
                    ),
                    padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_3
                            : AppPadding.p16,
                        right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_3
                            : AppPadding.p16,
                        bottom: AppPadding.p16,
                        top: AppPadding.p16),
                    //Change types accordingly
                    itemBuilder: (context, documentSnapshot, index) {
                      return TechAppointmentWiget(
                          appointment: AppAppointments.fromMap(
                              documentSnapshot[index].data() as Map),
                          theme: "light",
                          loggedUser: widget.loggedUser);
                    },
                    query: FirebaseFirestore.instance
                        .collection(Paths.appAppointments)
                        .where('date.month', isEqualTo: DateTime.now().month)
                        .where('date.day', isEqualTo: DateTime.now().day)
                        .where('date.year', isEqualTo: DateTime.now().year)
                        .orderBy('secondValue', descending: true),
                    // to fetch real-time data
                    isLive: true,
                  ),
                )
              : SizedBox(),
          all
              ? Expanded(
                  child: PaginateFirestore(
                    itemBuilderType: PaginateBuilderType.listView,
                    separator: SizedBox(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h40.h : AppSize.h20.h,
                    ),
                    padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_3
                            : AppPadding.p16,
                        right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_3
                            : AppPadding.p16,
                        bottom: AppPadding.p16,
                        top: AppPadding.p16),
                    //Change types accordinglyange types accordingly
                    itemBuilder: (context, documentSnapshot, index) {
                      return TechAppointmentWiget(
                          appointment: AppAppointments.fromMap(
                              documentSnapshot[index].data() as Map),
                          theme: "light",
                          loggedUser: widget.loggedUser);
                    },
                    query: FirebaseFirestore.instance
                        .collection(Paths.appAppointments)
                        .orderBy('secondValue', descending: true),
                    // to fetch real-time data
                    isLive: true,
                  ),
                )
              : SizedBox(),
          forEver
              ? Expanded(
                  child: PaginateFirestore(
                    itemBuilderType: PaginateBuilderType.listView,
                    separator: SizedBox(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h40.h : AppSize.h20.h,
                    ),
                    padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_3
                            : AppPadding.p16,
                        right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? size.width * AppPadding.p0_3
                            : AppPadding.p16,
                        bottom: AppPadding.p16,
                        top: AppPadding.p16),
                    //Change types accordingly//Change types accordingly
                    itemBuilder: (context, documentSnapshot, index) {
                      return ForEverWidget(
                          appointment: ForEverAppointments.fromMap(
                              documentSnapshot[index].data() as Map),
                          theme: "light",
                          loggedUser: widget.loggedUser);
                    },
                    query: FirebaseFirestore.instance
                        .collection(Paths.forEverAppointmentsPath)
                        .orderBy('timestamp', descending: true),
                    // to fetch real-time data
                    isLive: true,
                  ),
                )
              : SizedBox(),
          filter
              ? Column(
                  children: [
                    SizedBox(
                      height: AppSize.h5.h,
                    ),
                    Center(
                      child: Text(
                        getTranslated(context, "filter"),
                        style: GoogleFonts.poppins(
                           color: AppColors.black87,
                          fontSize: AppFontsSizeManager.s18.sp,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h15.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        InkWell(
                          splashColor: Colors.white.withOpacity(0.6),
                          onTap: () {
                            _selectFromDate(context);
                          },
                          child: Container(
                            height: AppSize.h40.h,
                            width: size.width * AppSize.w0_4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color:AppColors.purple,
                                //                   <--- border color
                                width: AppSize.w1.w,
                              ),
                              color:AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.r20.r),
                            ),
                            child: Center(
                              child: Text(
                                from,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.grey,
                                  fontSize: AppFontsSizeManager.s13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                        SizedBox(
                           width: AppSize.w5.w,
                        ),
                        InkWell(
                          splashColor: Colors.white.withOpacity(0.6),
                          onTap: () {
                            _selectToDate(context);
                          },
                          child: Container(
                            height: AppSize.h40.h,
                            width: size.width * AppSize.w0_4,
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.purple,
                                //                   <--- border color
                                width: AppSize.w1.w,
                              ),
                              color: AppColors.white,
                              borderRadius: BorderRadius.circular(AppRadius.r20.r),
                            ),
                            child: Center(
                              child: Text(
                                to,
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.grey,
                                  fontSize: AppFontsSizeManager.s13.sp,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    SizedBox(
                      height: AppSize.h25.h,
                    ),
                    Container(
                      height: AppSize.h40.h,
                      child: MaterialButton(
                        onPressed: () {
                          setState(() {
                            filterQuery = FirebaseFirestore.instance
                                .collection(Paths.appAppointments)
                                .where('timeValue',
                                    isGreaterThanOrEqualTo:
                                        selectedFromDate.millisecondsSinceEpoch)
                                .where('timeValue',
                                    isLessThanOrEqualTo:
                                        selectedToDate.millisecondsSinceEpoch)
                                .orderBy('timeValue', descending: true);
                          });
                          showResult = true;
                        },
                        color: Theme.of(context).primaryColor,
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.r15.r),
                        ),
                        child: Text(
                          getTranslated(context, "results"),
                          style: GoogleFonts.poppins(
                            color: AppColors.white,
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.semiBold,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h15.h,
                    ),
                  ],
                )
              : SizedBox(),
          showResult
              ? Expanded(
                  child: PaginateFirestore(
                    key: ValueKey(filterQuery),
                    itemBuilderType: PaginateBuilderType.listView,
                    padding: const EdgeInsets.only(
                        left: AppPadding.p16,
                        right: AppPadding.p16,
                        bottom: AppPadding.p16,
                        top: AppPadding.p16),
                    //Change types accordingly
                    itemBuilder: (context, documentSnapshot, index) {
                      return TechAppointmentWiget(
                          appointment: AppAppointments.fromMap(
                              documentSnapshot[index].data() as Map),
                          theme: "light",
                          loggedUser: widget.loggedUser);
                    },

                    query: filterQuery,
                    isLive: true,
                  ),
                )
              : SizedBox(),
        ],
      ),
    );
  }

  Future<void> _selectFromDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedFromDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedFromDate)
      setState(() {
        selectedFromDate = picked;
        from = selectedFromDate.toString().substring(0, 10);
      });
  }

  Future<void> _selectToDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
        context: context,
        initialDate: selectedToDate,
        firstDate: DateTime(2015, 8),
        lastDate: DateTime(2101));
    if (picked != null && picked != selectedToDate)
      setState(() {
        selectedToDate = picked;
        to = selectedToDate.toString().substring(0, 10);
      });
  }
}
