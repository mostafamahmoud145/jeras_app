import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/app_constat.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/user.dart';
import '../../widget/custom_back_button.dart';
import '../../widget/techAppointmentWidget.dart';

class UserAppointmentsScreen extends StatefulWidget {
  final GroceryUser user;
  final GroceryUser loggedUser;

  const UserAppointmentsScreen(
      {Key? key, required this.user, required this.loggedUser})
      : super(key: key);

  @override
  _UserAppointmentsScreenState createState() => _UserAppointmentsScreenState();
}

class _UserAppointmentsScreenState extends State<UserAppointmentsScreen>
    with SingleTickerProviderStateMixin {
  String theme = "light";

  @override
  void initState() {
    super.initState();
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
                  padding: EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(color:AppColors.black),
                      const SizedBox(width: AppSize.w10),
                      Text(
                        getTranslated(context, "appointments"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight: AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s31.sp : AppFontsSizeManager.s15.sp,
                          color: AppColors.black2,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          SizedBox(
            height: AppSize.h30,
          ),
          Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              separator: SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h40 : AppSize.h20,
              ),
              padding: EdgeInsets.only(
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p16,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_3 : AppPadding.p16,
                  bottom: AppPadding.p16,
                  top: AppPadding.p16),
              //Change types accordingly

              //Change types accordingly
              itemBuilder: (context, documentSnapshot, index) {
                return TechAppointmentWiget(
                    appointment: AppAppointments.fromMap(
                        documentSnapshot[index].data() as Map),
                    loggedUser: widget.loggedUser,
                    theme: theme);
              },
              query: widget.user.userType == "USER"
                  ? FirebaseFirestore.instance
                      .collection(Paths.appAppointments)
                      .where('user.uid', isEqualTo: widget.user.uid)
                      .orderBy('secondValue', descending: true)
                  : FirebaseFirestore.instance
                      .collection(Paths.appAppointments)
                      .where('consult.uid', isEqualTo: widget.user.uid)
                      .orderBy('secondValue', descending: true),
              isLive: true,
            ),
          )
        ],
      ),
    );
  }
}
