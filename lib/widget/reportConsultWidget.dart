import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:package_info_plus/package_info_plus.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/paths.dart';
import '../models/setting.dart';

class ReportConsultWidget extends StatefulWidget {
  final GroceryUser? loggedUser;
  final GroceryUser consult;
  ReportConsultWidget({this.loggedUser, required this.consult});

  @override
  _ReportConsultWidgetState createState() => _ReportConsultWidgetState();
}

class _ReportConsultWidgetState extends State<ReportConsultWidget>
    with SingleTickerProviderStateMixin {
  bool appReview = false, load = true, adding = false;

  @override
  void initState() {
    //if(Platform.isAndroid)
    getSetting();
    super.initState();
  }

  getSetting() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.settingPath)
        .doc("pzBqiphy5o2kkzJgWUT7");
    final DocumentSnapshot taxDocumentSnapshot = await docRef.get();
    bool appReviewSetting =
        Setting.fromMap(taxDocumentSnapshot.data() as Map).appReview;
    var androidBuildNumber =
        Setting.fromMap(taxDocumentSnapshot.data() as Map).androidBuildNumber;
    PackageInfo packageInfo = await PackageInfo.fromPlatform();
    if (int.parse(packageInfo.buildNumber) > androidBuildNumber &&
        appReviewSetting) {
      setState(() {
        appReview = true;
      });
    }
    setState(() {
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return (load || appReview == false) ? SizedBox() : reportWidget(size);
  }

  BoxShadow shadow() {
    return BoxShadow(
      color: AppColors.lightGrey,
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: Offset(0.0, 1.0), // shadow direction: bottom right
    );
  }

  Widget reportWidget(Size size) {
    return InkWell(
      onTap: () {
        if (widget.loggedUser == null)
          Navigator.pushNamed(context, '/Register_Type');
        else
          addReport();
      },
      child: Center(
        child: adding
            ? CircularProgressIndicator()
            : Column(
                children: [
                  SizedBox(
                    height: AppSize.h20.h,
                  ),
                  Container(
                    height: AppSize.h40.h,
                    width: size.width * AppSize.w0_75,
                    padding: EdgeInsets.all(AppPadding.p5),
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(AppRadius.r35),
                        gradient: LinearGradient(
                          begin: Alignment.centerLeft,
                          end: Alignment.centerRight,
                          colors: [
                            AppColors.darkRed,
                            AppColors.lightRed,
                          ],
                        )),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Icon(
                          Icons.report,
                          color: AppColors.white,
                          size: AppSize.w20,
                        ),
                        SizedBox(
                          width: AppSize.w2.w,
                        ),
                        Text(
                          getTranslated(context, "badContent"),
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.white,
                            fontSize: AppFontsSizeManager.s15,
                            fontWeight: FontWeight.w400,
                          ),
                        ),
                      ],
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h10.h,
                  ),
                ],
              ),
      ),
    );
  }

  Future<void> addReport() async {
    setState(() {
      adding = true;
    });
    String reportId = Uuid().v4();
    await FirebaseFirestore.instance
        .collection(Paths.reportPath)
        .doc(reportId)
        .set({
      'time': Timestamp.now(),
      'report': "bad content",
      'consultName': widget.consult.name,
      'consultPhone': widget.consult.phoneNumber,
      'consultUid': widget.consult.uid,
      'id': reportId,
      'name': widget.loggedUser != null ? widget.loggedUser!.name : " ",
      'phone': widget.loggedUser != null ? widget.loggedUser!.phoneNumber : " ",
      'status': "new",
      'uid': widget.loggedUser != null ? widget.loggedUser!.uid : " ",
    }).then((value) {
      setState(() {
        adding = false;
      });
      appointmentDialog(MediaQuery.of(context).size);
    });
  }

  appointmentDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(AppRadius.r15),
          ),
        ),
        elevation: 5.0,
        contentPadding: const EdgeInsets.only(
            left: AppPadding.p16,
            right: AppPadding.p16,
            top: AppPadding.p20,
            bottom: AppPadding.p10),
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Icon(
              Icons.report,
              color: AppColors.red,
              size: AppSize.w30,
            ),
            SizedBox(
              height: AppSize.h15.h,
            ),
            Text(
              getTranslated(context, "reportSend"),
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s11,
                fontWeight: AppFontsWeightManager.bold300,
                color: AppColors.black,
              ),
            ),
            SizedBox(
              height: AppSize.h10.h,
            ),
            Center(
              child: Container(
                width: size.width * AppSize.w0_4,
                height: AppSize.h40.h,
                decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(AppRadius.r5),
                    gradient: LinearGradient(
                      begin: Alignment.centerLeft,
                      end: Alignment.centerRight,
                      colors: [AppColors.pink, AppColors.brown],
                    )),
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.white,
                      fontSize: AppFontsSizeManager.s16,
                      fontWeight: FontWeight.w400,
                    ),
                  ),
                ),
              ),
            ),
            SizedBox(
              height: AppSize.h10.h,
            ),
          ],
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }
}
