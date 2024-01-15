import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:jeras/FireStorePagnation/paginate_firestore.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/models/courses.dart';
import 'package:jeras/models/user.dart';
import 'package:jeras/widget/courseItem.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/drawerWidget.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/app_constat.dart';
import '../../config/assets_manager.dart';
import '../../controller/blocs/account_bloc/account_bloc.dart';
import '../../controller/blocs/program_bloc/program_bloc.dart';
import '../../widget/component/IconButton.dart';
import '../../widget/component/textWidget.dart';
import '../../widget/custom_back_button.dart';
import 'addCourseScreen.dart';

class CourseIsProgramScreen extends StatefulWidget {
  final GroceryUser? loggedUser;

  const CourseIsProgramScreen({this.loggedUser}) : super();

  @override
  _BannerPageState createState() => _BannerPageState();
}

class _BannerPageState extends State<CourseIsProgramScreen>
    with AutomaticKeepAliveClientMixin {
  bool load = false;
  late String theme, lang;
  late bool enable = false;

  late AccountBloc accountBloc;

  @override
  void initState() {
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      body: Column(
        children: <Widget>[
          ///app bar
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.only(
                  left: AppPadding.p20, right: AppPadding.p20, top: AppPadding.p10, bottom: AppPadding.p10),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Container(
                    width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w75.r : AppSize.w45.r,
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h75.r : AppSize.h45.r,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(
                          (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r25.r : AppRadius.r13.r),
                    ),
                    child: IconButton1(
                      onPress: Navigator.of(context).pop,
                      Width:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.w97.w
                          : AppSize.w50.w,
                      Height:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h97.h
                          : AppSize.h50.h,
                      ButtonRadius: AppRadius.r10_6.r,
                      IconWidth: AppSize.w22.w,
                      IconHeight: AppSize.h20.h,
                      IconColor: Theme.of(context).primaryColor,
                      Icon:lang=="ar"? AssetsManager.whiteArrowRight:AssetsManager.whiteArrowLeft,
                      ButtonBackground: AppColors.white,
                    ),
                  ),                   SizedBox(
                    width: AppSize.w10.w,
                  ),
                  Text(
                    getTranslated(context, "courses"),
                    textAlign: TextAlign.left,
                    style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                            ? AppFontsSizeManager.s34.sp
                            : convertPtToPx(AppFontsSizeManager.s16.sp),
                        color: Colors.black.withOpacity(0.8),
                        fontWeight: FontWeight.bold),
                  ),
                  Spacer(),
                  addWidget("0"),
                ],
              ),
            ),
          ),
          Divider(
            color:AppColors.greyShade300,
          ),

          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppSize.w0_25.w : AppSize.w10.w,
                  vertical: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.height * AppSize.h0_05.h
                      : AppSize.h10.h),
              // padding: EdgeInsets.all((kIsWeb||size.width >= AppConstants.kIsWebValue)

              children: [
                PaginateFirestore(
                  shrinkWrap: true,
                  onEmpty: Column(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      SizedBox(
                        height: size.height * AppSize.h0_1.h,
                      ),
                      TextWidget(
                        text: getTranslated(context, "noCoursesAvaliable"),
                        color: AppColors.lightGrey2,
                        size: AppFontsSizeManager.s17.sp,
                        weight: FontWeight.w500,
                        align: TextAlign.center,
                      ),
                    ],
                  ),
                  physics: const NeverScrollableScrollPhysics(),
                  itemBuilderType: PaginateBuilderType.gridView,
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                      crossAxisCount: 1,
                      crossAxisSpacing: 20,
                      mainAxisSpacing: 30,
                      //mainAxisExtent: (kIsWeb||size.width >= AppConstants.kIsWebValue)

                      childAspectRatio:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 2 : 1.5),
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20, right: AppPadding.p20, bottom: AppPadding.p16, top: AppPadding.p1),
                  itemBuilder: (context, documentSnapshot, index) {
                    return CourseItem(
                      course: Courses.fromMap(
                          documentSnapshot[index].data() as Map),
                      loggedUser: widget.loggedUser,
                    );
                  },
                  query: FirebaseFirestore.instance.collection('Courses'),
                  isLive: true,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget addWidget(String place) {
    return place == "0"
        ? InkWell(
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddCourseScreen(),
                ),
              );
            },
            child: Icon(
              Icons.add_circle_outline,
              color: AppColors.primaryColor,
              size: convertPtToPx(AppSize.w24.w),
            ),
          )
        : Column(
            children: [
              SizedBox(
                height: AppSize.h348.h,
              ),
              InkWell(
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => AddCourseScreen(),
                    ),
                  );
                },
                child: Icon(
                  Icons.add_circle_outline,
                  color: AppColors.shadoColor,
                  size: checkIfWeb(context) ? AppSize.w56 : convertPtToPx(AppSize.w45),
                ),
              ),
              SizedBox(
                height: AppSize.h12.h,
              ),
              TextDefaultWidget(
                title: getTranslated(context, "noCourses"),
                color: AppColors.textLightGrey,
              )
            ],
          );
  }

  Widget buildee(BuildContext context) {
    super.build(context);
  final _scaffoldKey = GlobalKey<ScaffoldState>();
    return Scaffold(
      drawer: DrawerWidget(_scaffoldKey ),
      body: SafeArea(
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppPadding.p38.w),
          child: BlocBuilder<ProgramBloc, ProgramState>(
            buildWhen: (previous, current) {
              return current is getAllCoursesInProgramEvent;
            },
            builder: (context, state) {
              if (state is getAllCoursesInProgramState)
                return Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    SizedBox(
                      height: AppSize.h44.h,
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomBackButton(),
                        SizedBox(width: AppSize.w10.w),
                        TextDefaultWidget(
                            title: getTranslated(context, "courses"),
                            fontSize: AppFontsSizeManager.s15,
                            color: Colors.black.withOpacity(0.6),
                            fontWeight: FontWeight.bold),
                        Spacer(),
                        state.allCourses.length > 0
                            ? InkWell(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (context) => AddCourseScreen(),
                                    ),
                                  );
                                },
                                child: Icon(
                                  Icons.add_circle_outline,
                                  color: AppColors.shadoColor,
                                  size: AppSize.w20,
                                ),
                              )
                            : SizedBox(),
                      ],
                    ),
                    SizedBox(height: AppSize.h30.h),
                    state.allCourses.length == 0
                        ? Center(
                            child: Column(
                              children: [
                                SizedBox(
                                  height: AppSize.h348.h,
                                ),
                                InkWell(
                                  onTap: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => AddCourseScreen(),
                                      ),
                                    );
                                  },
                                  child: Icon(
                                    Icons.add_circle_outline,
                                    color: AppColors.shadoColor,
                                    size: AppSize.w45,
                                  ),
                                ),
                                SizedBox(
                                  height: AppSize.h12.h,
                                ),
                                TextDefaultWidget(
                                  title: getTranslated(context, "noCourses"),
                                  color: AppColors.textLightGrey,
                                )
                              ],
                            ),
                          )
                        : state.allCourses.length == 0
                            ? SizedBox()
                            : SizedBox(
                                height: AppSize.h95.h,
                              ),
                    Expanded(
                      child: ListView.builder(
                          itemCount: state.allCourses.length,
                          itemBuilder: (context, index) {
                            return CourseItem(
                              course: state.allCourses[index],
                              userType: "supervisor",
                            );
                          }),
                    )
                  ],
                );
              else if (state is ProgramLoading)
                return Center(child: CircularProgressIndicator());
              else if (state is ProgramErrorState)
                return Text("error ${state}");
              else
                return SizedBox();
            },
          ),
        ),
      ),
    );
  }

  @override
  bool get wantKeepAlive => true;
}
