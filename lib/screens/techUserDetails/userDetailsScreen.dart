import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/app_constat.dart';
import '../../config/app_fonts.dart';
import '../../config/app_values.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/SupportList.dart';
import '../../models/consultPackage.dart';
import '../../models/user.dart';
import '../../screens/techUserDetails/userAppointmentScreen.dart';
import '../../widget/component/textWidget.dart';
import '../../widget/custom_back_button.dart';
import '../myOrderScreen.dart';
import '../supportMessagesScreen.dart';

class UserDetailsScreen extends StatefulWidget {
  final GroceryUser user;
  final GroceryUser loggedUser;

  const UserDetailsScreen(
      {Key? key, required this.user, required this.loggedUser})
      : super(key: key);

  @override
  _UserDetailsScreenState createState() => _UserDetailsScreenState();
}

class _UserDetailsScreenState extends State<UserDetailsScreen> {
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  late int localFrom, localTo;
  late String languages = "",
      workDays = "",
      workDaysValue = "",
      from = "",
      to = "",
      lang = "",
      theme = "light";
  final TextEditingController callNumController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final TextEditingController discountController = TextEditingController();
  final TextEditingController displayController = TextEditingController();

  final TextEditingController searchController = new TextEditingController();
  List<consultPackage> packages = [];
  bool first = true,
      saving = false,
      load = false,
      activeValue = false,
      activeUser = false;
  late consultPackage package;
  bool avaliable = false, delete = false, chating = false;

  @override
  void initState() {
    super.initState();
    if (widget.user.userType == "CONSULTANT") getConsultPackages();

    String dayNow = DateTime.now().weekday.toString();
    int timeNow = DateTime.now().hour;
    if (widget.user.workDays!.contains(dayNow)) {
      if (widget.user.fromUtc != null && widget.user.toUtc != null) {
        localFrom = DateTime.parse(widget.user.fromUtc!).toLocal().hour;
        localTo = DateTime.parse(widget.user.toUtc!).toLocal().hour;
        if (localFrom <= timeNow && localTo > timeNow) {
          avaliable = true;
        }
        if (widget.user.workTimes!.length > 0) {
          if (localFrom == 12)
            from = "12 PM";
          else if (localFrom == 0)
            from = "12 AM";
          else if (localFrom > 12)
            from = ((localFrom) - 12).toString() + " PM";
          else
            from = (localFrom).toString() + " AM";
        }
        if (widget.user.workTimes!.length > 0) {
          if (localTo == 12)
            to = "12 PM";
          else if (localTo == 0)
            to = "12 AM";
          else if (localTo > 12)
            to = ((localTo) - 12).toString() + " PM";
          else
            to = (localTo).toString() + " AM";
        }
      }
    }
  }

  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }

  Future<void> getConsultPackages() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.packagesPath)
          .where(
            'consultUid',
            isEqualTo: widget.user.uid,
          )
          .orderBy("callNum", descending: false)
          .get();
      if (querySnapshot.docs.length > 0) {
        setState(() {
          packages = List<consultPackage>.from(
            querySnapshot.docs.map(
              (snapshot) => consultPackage.fromMap(snapshot.data() as Map),
            ),
          );
        });
      } else
        setState(() {
          packages = [];
        });
    } catch (e) {}
  }

  @override
  void dispose() {
    super.dispose();

    searchController.dispose();
    priceController.dispose();
    discountController.dispose();
    callNumController.dispose();
  }

  void showSnakbar(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  @override
  Widget build(BuildContext context) {
    String dayNow = DateTime.now().weekday.toString();
    int timeNow = DateTime.now().hour;
    if (widget.user.workDays!.contains(dayNow)) {
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }
    lang = getTranslated(context, "lang");

    if (first && widget.user.workDays!.length > 0) {
      workDays = "";
      if (widget.user.workDays!.contains("1")) {
        workDays = workDays + getTranslated(context, "monday") + ",";
      }
      if (widget.user.workDays!.contains("2")) {
        workDays = workDays + getTranslated(context, "tuesday") + ",";
      }
      if (widget.user.workDays!.contains("3")) {
        workDays = workDays + getTranslated(context, "wednesday") + ",";
      }
      if (widget.user.workDays!.contains("4")) {
        workDays = workDays + getTranslated(context, "thursday") + ",";
      }
      if (widget.user.workDays!.contains("5")) {
        workDays = workDays + getTranslated(context, "friday") + ",";
      }
      if (widget.user.workDays!.contains("6")) {
        workDays = workDays + getTranslated(context, "saturday") + ",";
      }
      if (widget.user.workDays!.contains("7")) {
        workDays = workDays + getTranslated(context, "sunday") + ",";
      }
      setState(() {
        workDaysValue = "";
        workDaysValue = workDays;
        first = false;
      });
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        children: <Widget>[
          innerHeaderWidget(size),
          Expanded(
            child: ListView(
              padding: EdgeInsets.symmetric(
                  horizontal:
                      (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * .3 : 10,
                  vertical: 10),
              physics: AlwaysScrollableScrollPhysics(),
              children: [
                consultDataWidget(size),
                SizedBox(
                  height: 30,
                ),
                if (widget.user.userType == "CONSULTANT")
                  consultBioWidget(
                      size, getTranslated(context, "bioAr"), widget.user.bio!),
                if (widget.user.userType == "CONSULTANT")
                  SizedBox(
                    height: 30,
                  ),
                if (widget.user.userType == "CONSULTANT")
                  consultBioWidget(size, getTranslated(context, "bioEn"),
                      widget.user.bioEn!),
                if (widget.user.userType == "CONSULTANT")
                  SizedBox(
                    height: 30,
                  ),

                if (widget.user.userType == "CONSULTANT")
                  consultTimeWidget(size),
                if (widget.user.userType == "CONSULTANT")
                  SizedBox(
                    height: 30,
                  ),
                //00000000
                //if(widget.user.userType=="CONSULTANT")
                // ConsultPackagesWidget(consultId: widget.user.uid,),
                SizedBox(
                  height: 30,
                ),
                navigateRow("orders", size),
                SizedBox(
                  height: AppSize.h20,
                ),
                navigateRow("appointments", size),
                SizedBox(
                  height: AppSize.h20,
                ),
              ],
            ),
          )
        ],
      ),
    );
  }

  Widget innerHeaderWidget(Size size) {
    return Container(
        width: size.width,
        child: SafeArea(
          child: Padding(
            padding: EdgeInsets.only(
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
                    CustomBackButton(color:AppColors.black),
                    const SizedBox(width: 10),
                    Text(
                      getTranslated(context, "details"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                        fontWeight: AppFontsWeightManager.bold300,
                        fontFamily: getTranslated(context, "Ithra"),
                        fontStyle: FontStyle.normal,
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 31.sp : 15.0.sp,
                        color: AppColors.black2,
                      ),
                    ),
                  ],
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.end,
                  children: [
                    /*     IconButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                user: widget.user,
                                details: true,
                              ),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/applicationIcons/chat-square-dots@3x.png',
                          width: 16,
                          height: 16,

                        ),
                      ),*/
                    SizedBox(width: 10),
                    chating
                        ? CircularProgressIndicator()
                        : IconButton(
                            onPressed: () async {
                              startChat();
                            },
                            icon: SvgPicture.asset(
                              AssetsManager.chat2IconPath,
                              width: AppSize.w30,
                              height: AppSize.h30,
                            ),
                          ),
                    SizedBox(width: AppSize.w10),
                    (widget.loggedUser == null &&
                            widget.user.accountStatus == "NotActive")
                        ? delete
                            ? CircularProgressIndicator()
                            : IconButton(
                                onPressed: () async {
                                  deleteUserDialog(size);
                                },
                                icon: Icon(
                                  Icons.delete_outline,
                                  color: AppColors.red,
                                  size: AppSize.w24,
                                ),
                              )
                        : SizedBox(),
                  ],
                ),
              ],
            ),
          ),
        ));
    Container(
        width: size.width,
        child: SafeArea(
            child: Padding(
          padding: const EdgeInsets.only(
              left: 10.0, right: 10.0, top: 10.0, bottom: 10.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Container(
                    height: AppSize.h35,
                    width: AppSize.w35,
                    child: Center(
                      child: IconButton(
                        onPressed: () {
                          Navigator.pop(context);
                        },
                        icon: Icon(
                          Icons.arrow_back_ios,
                          size: 20,
                          color: Color.fromRGBO(174, 156, 206, 1),
                        ),
                      ),
                    ),
                  ),
                  SizedBox(
                    width: AppSize.w5.w,
                  ),
                  TextWidget(
                    text: getTranslated(context, "details"),
                    color: AppColors.black4,
                    weight: FontWeight.w600,
                    size: 17,
                    align: TextAlign.start,
                    family: getTranslated(context, "Montserrat"),
                  ),
                ],
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  /*     IconButton(
                        onPressed: () async {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => ChatScreen(
                                user: widget.user,
                                details: true,
                              ),
                            ),
                          );
                        },
                        icon: Image.asset(
                          'assets/applicationIcons/chat-square-dots@3x.png',
                          width: 16,
                          height: 16,

                        ),
                      ),*/
                  SizedBox(width: 10),
                  chating
                      ? CircularProgressIndicator()
                      : IconButton(
                          onPressed: () async {
                            startChat();
                          },
                          icon: Image.asset(
                            'assets/applicationIcons/chat-icon.png',
                            width: 30,
                            height: 30,
                          ),
                        ),
                  SizedBox(width: 10),
                  (widget.loggedUser == null &&
                          widget.user.accountStatus == "NotActive")
                      ? delete
                          ? CircularProgressIndicator()
                          : IconButton(
                              onPressed: () async {
                                deleteUserDialog(size);
                              },
                              icon: Icon(
                                Icons.delete_outline,
                                color: AppColors.red,
                                size: AppSize.w24,
                              ),
                            )
                      : SizedBox(),
                ],
              ),
            ],
          ),
        )));
  }

  Widget consultDataWidget(size) {
    return InkWell(
      onTap: () {
        Clipboard.setData(ClipboardData(text: widget.user.phoneNumber!));
        Fluttertoast.showToast(
            msg: "phone number coped ",
            toastLength: Toast.LENGTH_SHORT,
            backgroundColor: AppColors.green2,
            textColor: AppColors.white);
      },
      child: Container(
        padding: const EdgeInsets.all(AppRadius.r30),
        decoration: decoration(),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Padding(
              padding: const EdgeInsets.only(
                  top: AppPadding.p1,
                  left: AppPadding.p5,
                  right: AppPadding.p5),
              child: Stack(
                children: <Widget>[
                  Container(
                    height: AppSize.h50,
                    width: AppSize.w50,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      color: Colors.white,
                    ),
                    child: widget.user.photoUrl!.isEmpty
                        ? Icon(
                            Icons.person,
                            color: Colors.grey[400],
                            size: AppSize.w25,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.r100),
                            child: FadeInImage.assetNetwork(
                              placeholder: AssetsManager.iconPersonIconPath,
                              placeholderScale: 0.5,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  Icon(
                                Icons.person,
                                color: Colors.grey[400],
                                size: AppSize.w25,
                              ),
                              image: widget.user.photoUrl!,
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
                  Positioned(
                    left: 1,
                    top: 5.0,
                    child: Container(
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        border: Border.all(
                          color: Colors.white,
                          width: AppSize.w1,
                        ),
                        color: avaliable ? AppColors.green : Colors.red,
                      ),
                      width: AppSize.w10,
                      height: AppSize.h10,
                    ),
                  ),
                ],
              ),
            ),
            Expanded(
              flex: 2,
              child: Column(
                mainAxisAlignment: MainAxisAlignment.start,
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextWidget(
                    text: widget.user.name!,
                    color: AppColors.black4,
                    weight: FontWeight.w600,
                    size: AppFontsSizeManager.s15,
                    align: TextAlign.start,
                    family: getTranslated(context, "Montserrat"),
                  ),
                  TextWidget(
                    text: widget.user.nameEn!,
                    color: AppColors.black4,
                    weight: FontWeight.w600,
                    size: AppFontsSizeManager.s15,
                    align: TextAlign.start,
                    family: getTranslated(context, "Montserrat"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      TextWidget(
                        text: widget.user.phoneNumber!,
                        color: Color.fromRGBO(147, 147, 147, 1),
                        weight: FontWeight.w400,
                        size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 10,
                        align: TextAlign.start,
                        family: getTranslated(context, "Montserrat"),
                      ),
                      SizedBox(
                        width: AppSize.w5.w,
                      ),
                      Icon(
                        Icons.copy,
                        color: Theme.of(context).primaryColor,
                        size: AppFontsSizeManager.s15,
                      ),
                    ],
                  ),
                  TextWidget(
                    text:
                        widget.user.location! + " / " + widget.user.locationEn!,
                    color: Color.fromRGBO(147, 147, 147, 1),
                    weight: FontWeight.w400,
                    size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 10,
                    align: TextAlign.start,
                    family: getTranslated(context, "Montserrat"),
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: widget.user.ordersNumbers.toString(),
                            color: AppColors.black4,
                            weight: FontWeight.w600,
                            size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 10,
                            align: TextAlign.start,
                            family: getTranslated(context, "Montserrat"),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Image.asset(
                            AssetsManager.greenCall,
                            width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w14 : AppSize.w8,
                            height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h14 : AppSize.h8,
                          ),
                        ],
                      ),
                      SizedBox(
                        width: AppSize.w20,
                      ),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          TextWidget(
                            text: widget.user.rating.toStringAsFixed(1),
                            color: AppColors.black4,
                            weight: FontWeight.w600,
                            size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 10,
                            align: TextAlign.start,
                            family: getTranslated(context, "Montserrat"),
                          ),
                          SizedBox(
                            width: 3,
                          ),
                          Icon(
                            Icons.star,
                            color: AppColors.yellow,
                            size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 10.0,
                          ),
                        ],
                      ),
                    ],
                  ),
                ],
              ),
            ),
            Visibility(
              visible: widget.user.userType == "CONSULTANT",
              child: TextWidget(
                text: widget.user.price! + "\$",
                color: AppColors.primaryColor,
                weight: FontWeight.w600,
                size: AppFontsSizeManager.s13,
                align: TextAlign.start,
                family: getTranslated(context, "Montserrat"),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget consultBioWidget(size, String tx1, String tx2) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p30),
      decoration: decoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            text: tx1,
            color: AppColors.primaryColor,
            weight: FontWeight.w600,
            size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 12,
            align: TextAlign.start,
            family: getTranslated(context, "Montserrat"),
          ),
          SizedBox(
            height: AppSize.h10,
          ),
          SingleLineTextWidget(
            text: tx2 == null ? ".." : tx2,
            color: AppColors.black4,
            weight: FontWeight.w400,
            size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 12,
            align: TextAlign.start,
            family: getTranslated(context, "Montserrat"),
            lines: "20",
          ),
        ],
      ),
    );
  }

  Widget consultTimeWidget(size) {
    return Container(
      padding: const EdgeInsets.all(AppPadding.p30),
      decoration: decoration(),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          TextWidget(
            text: getTranslated(context, "timeOfWork"),
            color: AppColors.primaryColor,
            weight: FontWeight.w600,
            size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s15 : AppFontsSizeManager.s12,
            align: TextAlign.start,
            family: getTranslated(context, "Montserrat"),
          ),
          SizedBox(
            height: AppSize.h10,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Image.asset(
               AssetsManager.calendarClockIconPath,
                width: AppSize.w12,
                height: AppSize.h13,
              ),
              SizedBox(
                width: AppSize.w5,
              ),
              Expanded(
                child: TextWidget(
                  text: workDaysValue,
                  color: AppColors.black4,
                  weight: FontWeight.w400,
                  size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 12,
                  align: TextAlign.start,
                  family: getTranslated(context, "Montserrat"),
                ),
              ),
            ],
          ),
          SizedBox(
            height: AppSize.h20,
          ),
          Row(
            mainAxisAlignment: MainAxisAlignment.start,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              // Icon( Icons.update,size:30,  color: Theme.of(context).primaryColor,),
              Image.asset(
                AssetsManager.clockIconPath,
                width: AppSize.w12,
                height: AppSize.h12,
              ),
              SizedBox(
                width: AppSize.w5,
              ),
              TextWidget(
                text: from + "  -  " + to,
                color: AppColors.black4,
                weight: FontWeight.w400,
                size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 15 : 12,
                align: TextAlign.start,
                family: getTranslated(context, "Montserrat"),
              ),
            ],
          ),
        ],
      ),
    );
  }

  BoxDecoration decoration() {
    return BoxDecoration(
      color: AppColors.lightGrey6,
      borderRadius: BorderRadius.circular(AppRadius.r31),
    );
  }

  Widget navigateRow(String name, Size size) {
    return InkWell(
      onTap: () {
        if (name == "orders")
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => MyOrdersScreen(
                user: widget.user,
                loggedType: widget.user.userType!,
                fromSupport: true,
              ),
            ),
          );
        else if (name == "appointments")
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => UserAppointmentsScreen(
                  user: widget.user, loggedUser: widget.loggedUser),
            ),
          );
      },
      child: Container(
        height: AppSize.h60,
        decoration: BoxDecoration(
          color: AppColors.lightGrey6,
          borderRadius: BorderRadius.circular(AppRadius.r31),
        ),
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.p20),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              TextWidget(
                text: getTranslated(context, name),
                color: AppColors.black4,
                weight: FontWeight.w400,
                size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s15 : AppFontsSizeManager.s12,
                align: TextAlign.start,
                family: getTranslated(context, "Montserrat"),
              ),
              Icon(Icons.arrow_forward_sharp,
                  size: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w25 : AppSize.w20,
                  color: AppColors.linear4),
            ],
          ),
        ),
      ),
    );
  }

  startChat() async {
    setState(() {
      chating = true;
    });
    QuerySnapshot querySnapshot = await FirebaseFirestore.instance
        .collection("SupportList")
        .where(
          'userUid',
          isEqualTo: widget.user.uid,
        )
        .limit(1)
        .get();
    if (querySnapshot.docs.length != 0) {
      var item = SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      setState(() {
        load = false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
            item: item,
            user: widget.loggedUser,
            theme: 'light',
          ),
        ),
      );
      setState(() {
        chating = false;
      });
    } else {
      setState(() {
        chating = false;
      });
    }
  }

  deleteUserDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r20),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16,
              right: AppPadding.p16,
              top: AppPadding.p20,
              bottom: AppPadding.p10),
          content: StatefulBuilder(builder: (context, setState) {
            return Column(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              crossAxisAlignment: CrossAxisAlignment.center,
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      getTranslated(context, "deleteAccount"),
                      style: GoogleFonts.cairo(
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight: AppFontsWeightManager.semiBold,
                        letterSpacing: AppConstants.letterSpacing0_3,
                         color: AppColors.black87,
                      ),
                    ),
                  ],
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      InkWell(
                        onTap: () async {
                          delete = true;
                          await FirebaseFirestore.instance
                              .collection(Paths.usersPath)
                              .doc(widget.user.uid)
                              .delete();
                          await FirebaseFirestore.instance
                              .collection(Paths.appAnalysisPath)
                              .doc("TgWCp3B22sbkl0Nm3wLx")
                              .set({
                            'allUsers': FieldValue.increment(-1),
                            'notActiveConsult': FieldValue.increment(-1),
                          }, SetOptions(merge: true));
                          Navigator.pop(context);
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Text(
                              getTranslated(context, "yes"),
                              style: GoogleFonts.cairo(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.semiBold,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                      SizedBox(width: AppSize.w100),
                      InkWell(
                        onTap: () {
                          Navigator.of(context).pop();
                        },
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            Text(
                              getTranslated(context, "no"),
                              style: GoogleFonts.cairo(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.semiBold,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                color: Colors.lightBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p5,
                      right: AppPadding.p5,
                      top: AppPadding.p5,
                      bottom: AppPadding.p10),
                  child: Container(
                    width: size.width,
                    height: AppSize.h0_5,
                    color: AppColors.lightGrey1,
                  ),
                ),
              ],
            );
          })),
      barrierDismissible: false,
      context: context,
    );
  }

/* @override
  Widget build(BuildContext context) {

    lang=getTranslated(context, "lang");

    if(widget.user.userType=="CONSULTANT"&&first&&widget.user.workDays!.length>0) {
      workDays="";
      if(widget.user.workDays!.contains("1"))
      {
        workDays=workDays+getTranslated(context,"monday")+",";
      }
      if(widget.user.workDays!.contains("2"))
      {
        workDays=workDays+getTranslated(context,"tuesday")+",";
      }
      if(widget.user.workDays!.contains("3"))
      {
        workDays=workDays+getTranslated(context,"wednesday")+",";
      }
      if(widget.user.workDays!.contains("4"))
      {
        workDays=workDays+getTranslated(context,"thursday")+",";
      }
      if(widget.user.workDays!.contains("5"))
      {
        workDays=workDays+getTranslated(context,"friday")+",";
      }
      if(widget.user.workDays!.contains("6"))
      {
        workDays=workDays+getTranslated(context,"saturday")+",";
      }
      if(widget.user.workDays!.contains("7"))
      {
        workDays=workDays+getTranslated(context,"sunday")+",";
      }
      setState(() {
        workDaysValue="";
        workDaysValue=workDays;
        first=false;
      });
    }
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      key:_scaffoldKey,
      body: Stack(children: <Widget>[
        Column(
          children: <Widget>[
            Container(
              width: size.width,
              height: 200,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.only(
                  bottomLeft: Radius.circular(0.0),
                  bottomRight: Radius.circular(0.0),
                ),
              ),
              child: Padding(
                padding:  EdgeInsets.only(
                    right: lang=="ar"?16:10.0, left:lang=="ar"?10.0:16.0, top: 5.0, bottom: 16.0),
                child: Container(width: size.width,height: 100,
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.6),
                            onTap: () {
                              Navigator.pop(context);
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: AppSize.w38.w,
                              height: AppSize.h35.h,
                              child: Icon(
                                Icons.arrow_back,
                                color: theme=="light"?Colors.white:Colors.black,
                                size: AppSize.w24,
                              ),
                            ),
                          ),
                        ),
                      ),
                      Text(
                        getTranslated(context, "details"),
                        style: GoogleFonts.poppins(
                          color: theme=="light"?Colors.white:Colors.black,
                          fontSize: 19.0,
                          fontWeight: AppFontsWeightManager.semiBold,
                        ),
                      ),
                      chating?CircularProgressIndicator():ClipRRect(
                        borderRadius: BorderRadius.circular(AppRadius.r50),
                        child: Material(
                          color: Colors.transparent,
                          child: InkWell(
                            splashColor: Colors.white.withOpacity(0.6),
                            onTap: () {
                               startChat();
                            },
                            child: Container(
                              decoration: BoxDecoration(
                                color: Colors.transparent,
                              ),
                              width: AppSize.w38.w,
                              height: AppSize.h35.h,
                              child: Icon(
                                Icons.chat_outlined,
                                color: theme=="light"?Colors.white:Colors.black,
                                size: AppSize.w24,
                              ),
                            ),
                          ),
                        ),
                      ),

                    ],
                  ),
                ),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: ListView(physics:  AlwaysScrollableScrollPhysics(),children: [
                  SizedBox(height: 40,),
                  Center(
                    child: Container(height: 200,width: size.width*.9,
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25.0),
                        border: Border.all(color: Colors.white,width: 2),
                        boxShadow: [
                          BoxShadow(
                            offset: Offset(0, 0.0),
                            blurRadius: 5.0,
                            spreadRadius: 1.0,
                            color:AppColors.black.withOpacity(0.6),
                          ),
                        ],
                      ),child:Column(
                        children: [
                          Container(height: 50,
                            decoration: BoxDecoration(
                              color: Theme.of(context).primaryColor,
                              borderRadius: BorderRadius.circular(25.0),

                            ),
                            child: Padding(
                              padding: const EdgeInsets.only(left: 10,right: 10),
                              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "bio"),
                                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                      color: theme=="light"?Colors.white:Colors.black,
                                      fontSize: AppFontsSizeManager.s15,
                                      fontWeight: FontWeight.bold,
                                      letterSpacing: AppConstants.letterSpacing0_3,
                                    ),
                                  ),
                                  SizedBox(),

                                ],
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Text(
                                widget.user.bio==null?"...": widget.user.bio!,
                                textAlign: TextAlign.start,
                                overflow: TextOverflow.ellipsis,
                                softWrap: false,
                                maxLines: 4,
                                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                  color:theme=="light"? Theme.of(context).primaryColor:Colors.black,
                                  fontSize: 14.0,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),),
                  ),
                   widget.user.userType=="USER"?SizedBox():Column(children: [
                          SizedBox(height: AppSize.h20,),
                          Center(
                            child: Container(height: AppSize.h35,width: size.width*.5,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                borderRadius: BorderRadius.circular(35.0),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context, "timeOfWork"),
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: theme=="light"?Colors.white:Colors.black,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                  ),),
                              ),
                            ),
                          ),
                          SizedBox(height: AppSize.h20,),
                          Row(mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.center,children: [
                            //Icon( Icons.calendar_today_outlined,size:30,  color: Theme.of(context).primaryColor,),
                            Image.asset(theme=="light"?
                            'assets/applicationapplicationIcons/Iconly-Two-tone-Calendar-1.png':'assets/applicationapplicationIcons/Iconly-Two-tone-Calendar.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox( width: AppSize.w5.w,),
                            Container(height: 70,width: size.width*.8,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(30.0),

                              ),child:  Center(
                                child: Text(
                                  workDaysValue,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                  ),),
                              ),
                            ),
                          ],),
                          SizedBox(height: AppSize.h20,),
                          Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,crossAxisAlignment:CrossAxisAlignment.center,children: [
                            // Icon( Icons.update,size:30,  color: Theme.of(context).primaryColor,),
                            Image.asset(theme=="light"?
                            'assets/applicationapplicationIcons/Iconly-Two-tone-TimeCircle.png':'assets/applicationapplicationIcons/whiteTime.png',
                              width: 30,
                              height: 30,
                            ),
                            SizedBox( width: AppSize.w5.w,),
                            Container(height: AppSize.h35,width: size.width*.3,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(30.0),

                              ),child:  Center(
                                child:  Text(
                                  from,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                  ),),
                              ),
                            ),
                            Container(height: AppSize.h35,width: size.width*.3,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color: AppColors.grey,
                                borderRadius: BorderRadius.circular(30.0),

                              ),child:  Center(
                                child:Text(
                                  to,
                                  textAlign: TextAlign.center,
                                  maxLines: 3,
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                  ),),
                              ),
                            ),
                            SizedBox( width: AppSize.w5.w,),
                          ],),
                          SizedBox(height: 30,),
                          Center(
                              child:  Container(width: size.width*.9,
                                decoration: BoxDecoration(
                                  color: Colors.white,
                                  borderRadius: BorderRadius.circular(25.0),
                                  border: Border.all(color: Colors.white,width: 2),
                                  boxShadow: [
                                    BoxShadow(
                                      offset: Offset(0, 0.0),
                                      blurRadius: 5.0,
                                      spreadRadius: 1.0,
                                      color:AppColors.black.withOpacity(0.6),
                                    ),
                                  ],
                                ),
                                child: Column(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Container(height: 50,
                                      decoration: BoxDecoration(
                                        color: Theme.of(context).primaryColor,
                                        borderRadius: BorderRadius.circular(25.0),

                                      ),
                                      child: Padding(
                                        padding: const EdgeInsets.only(left: 10,right: 10),
                                        child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                          crossAxisAlignment: CrossAxisAlignment.center,
                                          children: [
                                            Text(
                                              getTranslated(context, "allPackages"),
                                              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                                color: theme=="light"?Colors.white:Colors.black,
                                                fontSize: AppFontsSizeManager.s15,
                                                fontWeight: FontWeight.bold,
                                                letterSpacing: AppConstants.letterSpacing0_3,
                                              ),
                                            ),
                                            IconButton(
                                              onPressed: () {
                                                package=new consultPackage();
                                                package.Id=Uuid().v4();
                                                package.price=0;
                                                package.discount=0;
                                                package.callNum=0;
                                                package.active=true;
                                                package.consultUid=widget.user.uid!;
                                                packageDialog(size, package);
                                              },
                                              icon: Icon(
                                                Icons.add_circle_outline,
                                                color: theme=="light"?Colors.white:Colors.black,
                                              ),
                                            ),

                                          ],
                                        ),
                                      ),
                                    ),
                                    SizedBox(height: 10,),
                                    Center(
                                      child:  packages.length==0? Text(
                                        getTranslated(context, "noPackages"),
                                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                           color: AppColors.black87,
                                          fontSize: 14.0,
                                          fontWeight: AppFontsWeightManager.bold500,
                                          letterSpacing: AppConstants.letterSpacing0_3,
                                        ),
                                      ):ListView.separated(
                                        itemCount: packages.length,
                                        shrinkWrap: true,
                                        physics: NeverScrollableScrollPhysics(),
                                        padding: const EdgeInsets.all(0),
                                        itemBuilder: (context, index) {

                                          return InkWell(
                                            splashColor:
                                            Colors.red.withOpacity(0.6),
                                            onTap: () {
                                              packageDialog(size,packages[index]);
                                            },
                                            child: Container(height: 50,width: size.width,
                                                padding: const EdgeInsets.only(left: 10,right: 10),
                                                decoration: BoxDecoration(
                                                  color: AppColors.grey,
                                                  borderRadius: BorderRadius.circular(25.0),
                                                  border: Border.all(color:  Colors.grey.shade500,width: 2),

                                                ),child: Row(mainAxisAlignment:MainAxisAlignment.spaceBetween,children: [
                                                  Container(width: size.width*.25,
                                                    child: Text(
                                                      packages[index].callNum.toString()+getTranslated(context, "calls"),
                                                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                                        color: theme=="light"?Theme.of(context).primaryColor:Colors.black,
                                                        fontSize: AppFontsSizeManager.s15,
                                                        fontWeight: FontWeight.bold,
                                                      ),),
                                                  ),
                                                  Container(height: 25,width: size.width*.25,
                                                    //padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Colors.lightGreen,
                                                      borderRadius: BorderRadius.circular(25.0),

                                                    ),child:Center(
                                                      child: Text(
                                                        packages[index].discount.toString()+"%"+getTranslated(context, "discount"),
                                                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                                          color:AppColors.black,
                                                          fontSize: AppFontsSizeManager.s13,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: AppConstants.letterSpacing0_5,
                                                        ),),
                                                    ),),
                                                  Container(height: AppSize.h35,width: size.width*.25,
                                                    padding: const EdgeInsets.all(5),
                                                    decoration: BoxDecoration(
                                                      color: Theme.of(context).primaryColor,
                                                      borderRadius: BorderRadius.circular(25.0),

                                                    ),child:Center(
                                                      child: Text(
                                                        packages[index].price.toString()+"\$",
                                                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                                          color: theme=="light"?Colors.white:Colors.black,
                                                          fontSize: AppFontsSizeManager.s13,
                                                          fontWeight: FontWeight.bold,
                                                          letterSpacing: AppConstants.letterSpacing0_5,
                                                        ),),
                                                    ),)
                                                ],)
                                            ),
                                          );
                                        },
                                        separatorBuilder:
                                            (BuildContext context, int index) {
                                          return SizedBox(
                                            height: 8.0,
                                          );
                                        },
                                      ),
                                    )],
                                ),
                              )),
                        ],),

                  SizedBox(height: AppSize.h20,),
                  Container(height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(25.0),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            getTranslated(context, "allOrders"),
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: AppFontsSizeManager.s15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                          IconButton(
                            onPressed: () {//YASSS
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => MyOrdersScreen(user:widget.user,loggedType:widget.user.userType!,fromSupport: true, ), ),  );
                            },
                            icon: Icon(
                              Icons.arrow_forward,
                              color: theme=="light"?Colors.white:Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: AppSize.h20,),
                  Container(height: 50,
                    decoration: BoxDecoration(
                      color: Theme.of(context).primaryColor,
                      borderRadius: BorderRadius.circular(25.0),

                    ),
                    child: Padding(
                      padding: const EdgeInsets.only(left: 10,right: 10),
                      child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: [
                          Text(
                            getTranslated(context, "appointments"),
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: AppFontsSizeManager.s15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                          IconButton(
                            onPressed: () {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) => UserAppointmentsScreen(user:widget.user,loggedUser:widget.loggedUser ), ),  );

                            },
                            icon: Icon(
                              Icons.arrow_forward,
                              color: theme=="light"?Colors.white:Colors.black,
                            ),
                          ),

                        ],
                      ),
                    ),
                  ),
                  SizedBox(height: 40,),

                ],),
              ),
            )


          ],
        ),
        Positioned(
          right: 0.0,
          top: 130.0,
          left: 0,
          child: Center(
            child:  Container(width: size.width*.9,
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                boxShadow: [
                  BoxShadow(
                    offset: Offset(0, 0.0),
                    blurRadius: 15.0,
                    spreadRadius: 2.0,
                    color:AppColors.black.withOpacity(0.6),
                  ),
                ],
                border: Border.all(color: Colors.white,width: 3),
                color: Theme.of(context).primaryColor,
                borderRadius: BorderRadius.circular(25.0),
              ),
              child: Column(
                children: [
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.only(top: 1),
                        child: Stack(
                          children: <Widget>[
                            Container(
                              height: 70,
                              width: 70,
                              decoration: BoxDecoration(
                                border: Border.all(color:AppColors.black,width: 3),
                                shape: BoxShape.circle,
                                color: Colors.white,
                              ),
                              child: widget.user.photoUrl!.isEmpty ?
                              Icon( Icons.person,color:Colors.black,size:AppSize.w50 )
                                  :ClipRRect(
                                borderRadius: BorderRadius.circular(100.0),
                                child: FadeInImage.assetNetwork(
                                  placeholder:
                                  'assets/applicationIcons/icon_person.png',
                                  placeholderScale: 0.5,
                                  imageErrorBuilder:(context, error, stackTrace) => Icon(
                                    Icons.person,color:Colors.black,
                                    size:AppSize.w50
                                  ),
                                  image: widget.user.photoUrl!,
                                  fit: BoxFit.cover,
                                  fadeInDuration:
                                  Duration(milliseconds: AppConstants.milliseconds250),
                                  fadeInCurve: Curves.easeInOut,
                                  fadeOutDuration:
                                  Duration(milliseconds: AppConstants.milliseconds150),
                                  fadeOutCurve: Curves.easeInOut,
                                ),
                              ),
                            ),
                            Positioned(
                              bottom: 5,
                              left: 5.0,
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(AppRadius.r50),
                                child: Material(
                                  color: Theme.of(context).primaryColor,
                                  child: InkWell(
                                    splashColor: Colors.white.withOpacity(0.6),
                                    onTap: () {

                                    },
                                    child: Container(
                                      decoration:  BoxDecoration(
                                        border: Border.all(color:AppColors.black,width: 2),
                                        shape: BoxShape.circle,
                                        color: avaliable?AppColors.brown:Colors.red,
                                      ),
                                      width: AppSize.w10,
                                      height: 10.0,

                                    ),
                                  ),
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                      Expanded(
                        flex:2,
                        child: Column(mainAxisAlignment: MainAxisAlignment.start,crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              widget.user.name!,
                              textAlign: TextAlign.start,
                              overflow: TextOverflow.ellipsis,
                              maxLines: 1,
                              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                color: theme=="light"?Colors.white:Colors.black,
                                fontSize: AppFontsSizeManager.s15,
                                fontWeight: AppFontsWeightManager.semiBold,
                                letterSpacing: AppConstants.letterSpacing0_3,
                              ),
                            ),
                            Row(mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Icon(
                                  Icons.mic_none,
                                  size: 15,
                                  color: theme=="light"?Colors.white:Colors.black,
                                ),
                                Text(
                                  languages,
                                  textAlign: TextAlign.start,
                                  overflow: TextOverflow.ellipsis,
                                  softWrap: false,
                                  maxLines: 1,
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: theme=="light"?Colors.white:Colors.black,
                                    fontSize: AppFontsSizeManager.s15,
                                    // fontWeight: AppFontsWeightManager.semiBold,
                                    letterSpacing: AppConstants.letterSpacing0_3,
                                  ),
                                ),
                              ],
                            ),

                            Row( mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Icon(
                                      Icons.star,
                                      size: 13,
                                      color: AppColors.yellow,
                                    ),
                                    Text(
                                      widget.user.rating==null?"0": widget.user.rating.toStringAsFixed(1),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                        color: theme=="light"?Colors.white:Colors.black,
                                        fontSize: AppFontsSizeManager.s13,
                                        fontWeight: AppFontsWeightManager.semiBold,
                                        letterSpacing: AppConstants.letterSpacing0_3,
                                      ),
                                    ),
                                  ],
                                ),
                                SizedBox(width: AppSize.w20,),
                                Row(mainAxisAlignment: MainAxisAlignment.start,
                                  children: [
                                    Image.asset(
                                      'assets/applicationapplicationIcons/greenCall2.png',
                                      width: 15,
                                      height: 15,
                                    ),


                                    Text(
                                      widget.user.ordersNumbers==null?"0":widget.user.ordersNumbers.toString(),
                                      textAlign: TextAlign.start,
                                      overflow: TextOverflow.ellipsis,
                                      softWrap: false,
                                      maxLines: 1,
                                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                        color: theme=="light"?Colors.white:Colors.black,
                                        fontSize: AppFontsSizeManager.s15,
                                        fontWeight: AppFontsWeightManager.semiBold,
                                        letterSpacing: AppConstants.letterSpacing0_3,
                                      ),
                                    )
                                  ],
                                ),
                              ],
                            ),
                          ],),
                      ),
                      Column(mainAxisAlignment: MainAxisAlignment.spaceBetween,crossAxisAlignment: CrossAxisAlignment.center,
                        mainAxisSize: MainAxisSize.max,
                        children: [
                          Text(
                            widget.user.price==null?'0':widget.user.price!+"\$",
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: AppFontsSizeManager.s15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                          SizedBox(height: 5,),
                          Text(
                            widget.user.consultType==null?" ":widget.user.consultType!,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            maxLines: 1,
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: theme=="light"?Colors.white:Colors.black,
                              fontSize: AppFontsSizeManager.s15,
                              fontWeight: FontWeight.bold,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ],),
                    ],
                  ),

                ],
              ),


            ),
          ),
        ),

      ]),
    );
  }
  void showNoNotifSnack(String text,bool status) {
    Fluttertoast.showToast(
        msg: getTranslated(context, "enterAll"),
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  showUpdatingDialog() {
    return showDialog(
      barrierDismissible: false,
      context: context,
      builder: (context) {
        return ProcessingDialog(
          message: getTranslated(context, "loading"),
        );
      },
    );
  }
  packageDialog(Size size,consultPackage selectedPackage) {
    callNumController.text=selectedPackage.callNum.toString();
    priceController.text=selectedPackage.price.toString();
    discountController.text=selectedPackage.discount.toString();
    activeValue=selectedPackage.active!;
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(15.0),
            ),
          ),
          elevation: 5.0,
          contentPadding: const EdgeInsets.only(
              left: AppPadding.p16, right: AppPadding.p16, top: AppPadding.p20, bottom: AppPadding.p10),
          content:StatefulBuilder(builder: (context, setState) {
            return
              Column(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                crossAxisAlignment: CrossAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      SizedBox( width: AppSize.w5.w,),
                      Text(
                        getTranslated(context, "edit"),
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s14_5,
                          fontWeight: AppFontsWeightManager.semiBold,
                          letterSpacing: AppConstants.letterSpacing0_3,
                           color: AppColors.black87,
                        ),
                      ),
                      InkWell( splashColor: Colors.white.withOpacity(0.6),
                        onTap: () async {
                          await FirebaseFirestore.instance.collection(
                              Paths.packagesPath).doc(selectedPackage.Id).delete();
                          getConsultPackages();
                          Navigator.pop(context);
                        },
                        child: Icon( Icons.delete,
                          color: AppColors.red,
                          size: AppSize.w24,),
                      )
                    ],
                  ),
                  SizedBox(
                    height: AppSize.h15,
                  ),

                  Row(
                    children: [
                      Container(width: size.width * .3,
                        child: Text(
                          getTranslated(context, "call"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      Container(width: size.width * .3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color:AppColors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(AppRadius.r15.r),
                        ),
                        child: TextFormField(
                          //initialValue: selectedPackage.callNum.toString(),
                          controller: callNumController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                         enableInteractiveSelection: true,
                          style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                            fontSize: 14.0,
                             color: AppColors.black87,
                            letterSpacing: AppConstants.letterSpacing0_5,
                            fontWeight: AppFontsWeightManager.bold500,
                          ),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "call"),
                            hintStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 14.0,
                             color: AppColors.black54,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: FontWeight.w400,
                            ),
                            counterStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 12.5,
                             color: AppColors.black54,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0,),

                  Row(
                    children: [
                      Container(width: size.width * .3,
                        child: Text(
                          getTranslated(context, "discount"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      Container(width: size.width * .3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color:AppColors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(AppRadius.r15.r),
                        ),
                        child: TextFormField(
                          //initialValue: selectedPackage.callNum.toString(),
                          controller: discountController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                         enableInteractiveSelection: true,
                          style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                            fontSize: 14.0,
                             color: AppColors.black87,
                            letterSpacing: AppConstants.letterSpacing0_5,
                            fontWeight: AppFontsWeightManager.bold500,
                          ),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "discount"),
                            hintStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 14.0,
                             color: AppColors.black54,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: FontWeight.w400,
                            ),
                            counterStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 12.5,
                             color: AppColors.black54,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 10.0,),

                  Row(
                    children: [
                      Container(width: size.width * .3,
                        child: Text(
                          getTranslated(context, "price"),
                          style: TextStyle(
                            color: Theme
                                .of(context)
                                .primaryColor,
                            fontSize: 18.0,
                            fontWeight: FontWeight.bold,
                          ),),
                      ),
                      Container(width: size.width * .3,
                        height: 40,
                        padding: const EdgeInsets.symmetric(
                            horizontal: 10.0, vertical: 10.0),
                        decoration: BoxDecoration(
                          color:AppColors.black.withOpacity(0.03),
                          borderRadius: BorderRadius.circular(AppRadius.r15.r),
                        ),
                        child: TextFormField(
                          //initialValue: selectedPackage.callNum.toString(),
                          controller: priceController,
                          keyboardType: TextInputType.number,
                          textCapitalization: TextCapitalization.sentences,
                          textInputAction: TextInputAction.done,
                         enableInteractiveSelection: true,
                          style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                            fontSize: 14.0,
                             color: AppColors.black87,
                            letterSpacing: AppConstants.letterSpacing0_5,
                            fontWeight: AppFontsWeightManager.bold500,
                          ),
                          decoration: InputDecoration(
                            contentPadding:
                            EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                            border: InputBorder.none,
                            hintText: getTranslated(context, "price"),
                            hintStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 14.0,
                             color: AppColors.black54,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: FontWeight.w400,
                            ),
                            counterStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              fontSize: 12.5,
                             color: AppColors.black54,
                              letterSpacing: AppConstants.letterSpacing0_5,
                              fontWeight: FontWeight.w400,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: 5.0,),
                  Row(
                    children: [
                      Checkbox(
                        value: activeValue,
                        onChanged: (value) {
                          setState(() {
                            activeValue = !activeValue;
                          });
                        },
                      ),
                      Text(
                        getTranslated(context, "active"),
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          fontSize: AppFontsSizeManager.s15,
                          fontWeight: AppFontsWeightManager.bold500,
                          color: Theme
                              .of(context)
                              .primaryColor,
                        ),
                      ),
                    ],
                  ),
                  SizedBox(height: AppSize.h15,),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      Container(
                        width: 50.0,
                        child: MaterialButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () {
                            setState(() {
                              load = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            getTranslated(context, 'cancel'),
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                               color: AppColors.black87,
                              fontSize: 13.5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ),
                      ),
                      SizedBox(width: 10,),
                      saving ? CircularProgressIndicator() : Container(
                        width: 50.0,
                        child: MaterialButton(
                          padding: const EdgeInsets.all(0.0),
                          onPressed: () async {
                            setState(() {
                              saving = true;
                            });
                            await FirebaseFirestore.instance.collection(
                                Paths.packagesPath).doc(selectedPackage.Id).set({
                              'price': int.parse(priceController.text),
                              'discount': int.parse(discountController.text),
                              'callNum': int.parse(callNumController.text),
                              'consultUid': widget.user.uid,
                              'Id': selectedPackage.Id,
                              'active': activeValue,
                            }, SetOptions(merge: true));
                            getConsultPackages();
                            setState(() {
                              saving = false;
                            });
                            Navigator.pop(context);
                          },
                          child: Text(
                            getTranslated(context, 'save'),
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.red1,
                              fontSize: 13.5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ],
              );
          })
      ), barrierDismissible: false,
      context: context,
    );
  }
  startChat() async
  {
    setState(() {
      chating=true;
    });
    QuerySnapshot querySnapshot = await  FirebaseFirestore.instance.collection("SupportList")
        .where( 'userUid', isEqualTo: widget.user.uid, ).limit(1).get();
    if(querySnapshot!=null&&querySnapshot.docs.length!=0)
    {
      var item=SupportList.fromMap(querySnapshot.docs[0].data() as Map);
      setState(() {
        load=false;
      });
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => SupportMessageScreen(
            item: item,
             user:widget.loggedUser, theme: 'light',), ),);
      setState(() {
        chating=false;
      });

    }
    else
    {
      setState(() {
        chating=false;
      });
    }
  }*/
}
