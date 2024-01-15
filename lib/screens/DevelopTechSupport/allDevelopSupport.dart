import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/DevelopTechSupport.dart';
import '../../models/user.dart';
import '../../widget/developListItem.dart';

class AllDevelopTechScreen extends StatefulWidget {
  final GroceryUser loggedUser;

  const AllDevelopTechScreen({Key? key, required this.loggedUser})
      : super(key: key);

  @override
  _AllDevelopTechScreenState createState() => _AllDevelopTechScreenState();
}

class _AllDevelopTechScreenState extends State<AllDevelopTechScreen>
    with SingleTickerProviderStateMixin {
  bool load = false,
      _new = true,
      _open = false,
      _done = false,
      _closed = false,
      saving = false,
      showText = false;
  final TextEditingController titleController = new TextEditingController();
  late Query query;
  String theme = "light";

  @override
  void initState() {
    super.initState();
    query = FirebaseFirestore.instance
        .collection(Paths.developTechSupportPath)
        .where('status', isEqualTo: "new")
        .orderBy('sendTime', descending: true);
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
                                : AppSize.w50.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h97.h
                                : AppSize.h50_6.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r24.r
                                : AppRadius.r10_6.r,
                            IconWidth: AppSize.w32.r,
                            IconHeight: AppSize.h32.r,
                            IconColor: Theme.of(context).primaryColor,
                            Icon: AssetsManager.blackArrowRightIconPath,
                            ButtonBackground: AppColors.white,
                          ),
                          SizedBox(width: AppSize.w10.w),
                          Text(
                            getTranslated(context, "development"),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                              fontWeight: AppFontsWeightManager.bold300,
                              fontFamily: getTranslated(context, "Ithra"),
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
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
                              addDialog(size);
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
                horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? size.width * AppSize.w0_2
                    : AppSize.w20.w),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  InkWell(
                    splashColor: Colors.green.withOpacity(0.6),
                    onTap: () {
                      setState(() {
                        _new = true;
                        _open = false;
                        _done = false;
                        _closed = false;
                      });
                    },
                    child: Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h60.h
                          : AppSize.h40.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_1
                          : size.width * AppSize.w0_20,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: _new
                            ? theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r30.r
                                : AppRadius.r20.r),
                      ),
                      child: Center(
                        child: Text(
                          "New",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: _new
                                ? theme == "light"
                                    ? AppColors.white
                                    : AppColors.white
                                : theme == "light"
                                    ? Theme.of(context).primaryColor
                                    : AppColors.black,
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: FontWeight.bold,
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
                        _new = false;
                        _open = true;
                        _done = false;
                        _closed = false;
                      });
                    },
                    child: Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h60.h
                          : AppSize.h40.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_1
                          : size.width * AppSize.w0_20,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: _open
                            ? theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r30.r
                                : AppRadius.r20.r),
                      ),
                      child: Center(
                        child: Text(
                          "Open",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: _open
                                ? theme == "light"
                                    ? AppColors.white
                                    : AppColors.white
                                : theme == "light"
                                    ? Theme.of(context).primaryColor
                                    : AppColors.black,
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: FontWeight.bold,
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
                        _new = false;
                        _open = false;
                        _done = true;
                        _closed = false;
                      });
                    },
                    child: Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h60.h
                          : AppSize.h40.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_1
                          : size.width * AppSize.w0_20,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: _done
                            ? theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r30.r
                                : AppRadius.r20.r),
                      ),
                      child: Center(
                        child: Text(
                          "Done",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: _done
                                ? theme == "light"
                                    ? AppColors.white
                                    : AppColors.white
                                : theme == "light"
                                    ? Theme.of(context).primaryColor
                                    : AppColors.black,
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: FontWeight.bold,
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
                        _new = false;
                        _open = false;
                        _done = false;
                        _closed = true;
                      });
                    },
                    child: Container(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h60.h
                          : AppSize.h40.h,
                      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppSize.w0_1
                          : size.width * AppSize.w0_20,
                      padding: const EdgeInsets.all(AppPadding.p5),
                      decoration: BoxDecoration(
                        color: _closed
                            ? theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black
                            : AppColors.white,
                        borderRadius: BorderRadius.circular(
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r30.r
                                : AppRadius.r20.r),
                      ),
                      child: Center(
                        child: Text(
                          "Closed",
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: _closed
                                ? theme == "light"
                                    ? AppColors.white
                                    : AppColors.white
                                : theme == "light"
                                    ? Theme.of(context).primaryColor
                                    : AppColors.black,
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: FontWeight.bold,
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
          _new ? listWidget(size, "new") : SizedBox(),
          _open ? listWidget(size, "open") : SizedBox(),
          _done ? listWidget(size, "done") : SizedBox(),
          _closed ? listWidget(size, "closed") : SizedBox(),
        ],
      ),
    );
  }

  listWidget(Size size, String status) {
    return Expanded(
      child: PaginateFirestore(
        itemBuilderType: PaginateBuilderType.listView,
        padding: EdgeInsets.only(
          left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppSize.w0_2
              : AppSize.w20,
          right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppSize.w0_2
              : AppSize.w20,
          bottom: 20.0,
          top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? size.width * AppSize.w0_05
              : AppSize.w20,
        ),
        //Change types accordingly
        itemBuilder: (context, documentSnapshot, index) {
          return DevelopListItem(
              size: size,
              item: DevelopTechSupport.fromMap(
                  documentSnapshot[index].data() as Map),
              theme: theme,
              user: widget.loggedUser);
        },
        separator: SizedBox(
          height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppSize.h40.h
              : AppSize.h20.h,
        ),
        query: FirebaseFirestore.instance
            .collection(Paths.developTechSupportPath)
            .where('status', isEqualTo: status)
            .orderBy('sendTime', descending: true),
        // to fetch real-time data
        isLive: true,
      ),
    );
  }

  addDialog(Size size) {
    return showDialog(
      builder: (context) => AlertDialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.all(
              Radius.circular(AppRadius.r15.r),
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
                SizedBox(
                  height: AppSize.h15.h,
                ),
                Text(
                  getTranslated(context, "developNotes"),
                  style: GoogleFonts.poppins(
                    color: AppColors.black,
                    fontSize: AppFontsSizeManager.s13.sp,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                SizedBox(
                  height: AppSize.h15.h,
                ),
                Container(
                  width: size.width * AppSize.w0_6,
                  height: AppSize.h55.h,
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.p10, vertical: AppPadding.p10),
                  decoration: BoxDecoration(
                    color: Colors.black.withOpacity(0.03),
                    borderRadius: BorderRadius.circular(AppRadius.r15.r),
                  ),
                  child: TextFormField(
                    controller: titleController,
                    keyboardType: TextInputType.text,
                    textCapitalization: TextCapitalization.sentences,
                    textInputAction: TextInputAction.done,
                    enableInteractiveSelection: false,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s14.sp,
                      color: AppColors.black87,
                      letterSpacing: AppConstants.letterSpacing0_5,
                      fontWeight: AppFontsWeightManager.bold500,
                    ),
                    decoration: InputDecoration(
                      contentPadding:
                          EdgeInsets.symmetric(horizontal: 5.0, vertical: 8.0),
                      border: InputBorder.none,
                      hintText: getTranslated(context, "title"),
                      hintStyle: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: 14.0.sp,
                        color: AppColors.black54,
                        letterSpacing: AppConstants.letterSpacing0_5,
                        fontWeight: FontWeight.w400,
                      ),
                      counterStyle: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s12.sp,
                        color: AppColors.black54,
                        letterSpacing: AppConstants.letterSpacing0_5,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                  ),
                ),
                showText
                    ? Text(
                        getTranslated(context, "required"),
                        style: GoogleFonts.poppins(
                          color: AppColors.red,
                          fontSize: AppFontsSizeManager.s13.sp,
                          fontWeight: AppFontsWeightManager.semiBold,
                        ),
                      )
                    : SizedBox(),
                SizedBox(
                  height: AppFontsSizeManager.s10.sp,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    Container(
                      width: AppSize.w50.w,
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
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            color: AppColors.black87,
                            fontSize: AppFontsSizeManager.s13_5.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w10.w,
                    ),
                    saving
                        ? CircularProgressIndicator()
                        : Container(
                            width: AppSize.w50.w,
                            child: MaterialButton(
                              padding: const EdgeInsets.all(0.0),
                              onPressed: () async {
                                if (titleController.text == "")
                                  setState(() {
                                    showText = true;
                                  });
                                else {
                                  setState(() {
                                    showText = false;
                                    saving = true;
                                  });
                                  String developListId = Uuid().v4();
                                  await FirebaseFirestore.instance
                                      .collection(Paths.developTechSupportPath)
                                      .doc(developListId)
                                      .set({
                                    'developTechSupportId': developListId,
                                    'status': "new",
                                    'sendTime': FieldValue.serverTimestamp(),
                                    'owner': widget.loggedUser.userType,
                                    'userUid': widget.loggedUser.uid,
                                    'userName': widget.loggedUser.name,
                                    'title': titleController.text,
                                  });
                                  setState(() {
                                    saving = false;
                                  });
                                  Navigator.pop(context);
                                }
                              },
                              child: Text(
                                getTranslated(context, 'save'),
                                style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  color: AppColors.red1,
                                  fontSize: AppFontsSizeManager.s13_5.sp,
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
          })),
      barrierDismissible: false,
      context: context,
    );
  }
}
