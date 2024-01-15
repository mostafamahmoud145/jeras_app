import 'dart:developer';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_shadow.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/component/TextButton.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/dialogs/custom_text_dialog.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/custom_back_button.dart';
import '../../localization/localization_methods.dart';
import '../../models/interests.dart';
import '../../models/user.dart';
import '../../widget/processing_dialog.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../services/app_flyer_service.dart';
import '../widget/component/TextFormFieldWidget.dart';
import 'PrivacyScreen/privacyscreen.dart';

class UserAccountScreen extends StatefulWidget {
  final GroceryUser user;
  final bool firstLogged;
  final bool firstNameOnly;

  const UserAccountScreen({
    Key? key,
    required this.user,
    this.firstNameOnly= false,
    required this.firstLogged,
  }) : super(key: key);

  @override
  _UserAccountScreenState createState() => _UserAccountScreenState();
}

class _UserAccountScreenState extends State<UserAccountScreen> {
  TextEditingController nameController = TextEditingController();
  TextEditingController ageController = TextEditingController();
  TextEditingController educationLevelController = TextEditingController();

  late AccountBloc accountBloc;

  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay selectedTime = TimeOfDay.now();
  String? name, userName, bio, age, education;
  late ScrollController scrollController;
  var image;
  Uint8List? selectedProfileImage;
  bool profileCompleted = false,
      dataSave = false,
      sendReq = false,
      loadInterests = true,
      _inter = false;
  late Size size;
  bool deleting = false;
  String? dropdownTypeValue;
  String lang = "";
  List<KeyValueModel> _typeArray = [
    KeyValueModel(key: 0, value: "اقل من ١٠ سنوات"),
    KeyValueModel(key: 1, value: "يتراوح من ١٠ الي ١٥ سنة"),
    KeyValueModel(key: 2, value: "اكبر من ١٥ سنة"),
  ];
  List<Interests> interestList = [], selectedInterestList = [];

  @override
  void initState() {

    super.initState();

    if(widget.firstNameOnly){
        WidgetsFlutterBinding.ensureInitialized().addPostFrameCallback((timeStamp) {
          customTextDialog(
            context: context,
            text: getTranslated(context, 'updateName'),
            buttonText: getTranslated(context, 'Ok'),
            okFunction: (){
              Navigator.pop(context);
            },
          );
        });
    }
    nameController.text = widget.user.name!;
    ageController.text = widget.user.age ?? '';
    educationLevelController.text = widget.user.education!;

    accountBloc = BlocProvider.of<AccountBloc>(context);
    if (widget.user.ageValue != null) {
      dropdownTypeValue = widget.user.ageValue.toString();
    }

    accountBloc.stream.listen((state) {
      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        if (mounted) showUpdatingDialog();
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        if (mounted) showSnack(getTranslated(context, "error"), context, false);
      }
      if (state is UpdateAccountDetailsCompletedState) {
        if (mounted && dataSave) {
          dataSave = false;
          accountBloc.add(GetLoggedUserEvent());
          if (widget.firstLogged == true) {
            Navigator.pushAndRemoveUntil(
                context,
                MaterialPageRoute(
                    builder: (context) => PrivacyScreen(
                          user: widget.user,
                        )),
                (route) => false);
          } else {
            Navigator.pushNamedAndRemoveUntil(
              context,
              '/home',
              (route) => false,
            );
          }
          //selectedProfileImage=null;

          // Navigator.pop(context);
          // accountBloc.add(GetAccountDetailsEvent(widget.user.uid));
        }
      }
    });
  }


  void didChangeDependencies() {
    getInterests();
    super.didChangeDependencies();
  }

  getInterests() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.interestsPath)
          .where('lang', isEqualTo: getTranslated(context, "lang"))
          .where('active', isEqualTo: true)
          .orderBy('order', descending: false)
          .get();
      var list = List<Interests>.from(
        querySnapshot.docs.map(
          (snapshot) => Interests.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        interestList = list;
        loadInterests = false;
      });
      /* _items = interestList
          .map((animal) => MultiSelectItem<Interests>(animal, animal.arName))
          .toList();*/
    } catch (e) {
      setState(() {
        loadInterests = false;
      });
    }
  }

  showDeleteConfimationDialog(Size size) {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                InkWell(
                  onTap: () {
                    Navigator.pop(context);
                  },
                  child: SvgPicture.asset(
                    AssetsManager.blackCloseIconPath,
                    width: AppSize.w32.w,
                    height: AppSize.h32.h,
                  ),
                ),
                SizedBox(width: AppSize.w132.w),
                Padding(
                  padding: EdgeInsets.only(top: AppSize.h10_6.h),
                  child: SvgPicture.asset(
                    AssetsManager.delete1IconPath,
                    width: AppSize.w53_5.r,
                    height: AppSize.h53_5.r,
                  ),
                ),
              ],
            ),
            SizedBox(height: AppSize.h21_3.h),
            Padding(
              padding: EdgeInsets.only(right: AppPadding.p10_6.w),
              child: Column(
                children: [
                  Text(
                    getTranslated(context, "deleteAccount"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s26_6.sp,
                      color: AppColors.black4,
                      fontStyle: FontStyle.normal,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                  SizedBox(height: AppSize.h15_3.h),
                  Text(
                    getTranslated(context, "DoYouWantDeleteAccount"),
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      fontFamily: getTranslated(context, "Ithralight"),
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: AppColors.black4,
                      fontWeight: AppFontsWeightManager.bold300,
                      fontStyle: FontStyle.normal,
                    ),
                  ),
                  SizedBox(
                    height: AppSize.h26.h,
                  ),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisSize: MainAxisSize.max,
                    children: <Widget>[
                      deleting
                          ? CircularProgressIndicator()
                          : InkWell(
                              onTap: () async {
                                setState(() {
                                  deleting = true;
                                });
                                await FirebaseFirestore.instance
                                    .collection(Paths.supportListPath)
                                    .doc(widget.user.supportListId)
                                    .delete();
                                await FirebaseFirestore.instance
                                    .collection(Paths.usersPath)
                                    .doc(widget.user.uid)
                                    .delete();
                                AppFlyerService().clear();
                                FirebaseAuth.instance.signOut();
                                setState(() {
                                  deleting = false;
                                });
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/RegisterTypeScreen',
                                  (route) => false,
                                );

                                await FirebaseFirestore.instance
                                    .collection(Paths.usersPath)
                                    .doc(widget.user.uid)
                                    .delete();
                                AppFlyerService().clear();
                                FirebaseAuth.instance.signOut();
                                setState(() {
                                  deleting = false;
                                });
                                Navigator.pushNamedAndRemoveUntil(
                                  context,
                                  '/home',
                                  (route) => false,
                                );
                              },
                              child: Container(
                                width: AppSize.w160.w,
                                height: AppSize.h56.h,
                                //   alignment: Alignment.center,
                                decoration: BoxDecoration(
                                  color: AppColors.red1,
                                  borderRadius:
                                      BorderRadius.circular(AppRadius.r10_6.r),
                                ),
                                child: Center(
                                  child: Text(
                                    getTranslated(context, "yes"),
                                    style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      fontSize: AppFontsSizeManager.s15.sp,
                                      color: AppColors.white,
                                    ),
                                  ),
                                ),
                              ),
                            ),
                      Spacer(),
                      //SizedBox(width: AppSize.w57_3.w),
                      InkWell(
                        onTap: () {
                          Navigator.pop(context);
                        },
                        child: Container(
                          width: AppSize.w160.w,
                          height: AppSize.h56.h,
                          //   alignment: Alignment.center,
                          decoration: BoxDecoration(
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r10_6.r)),
                              border: Border.all(
                                color: AppColors.red1,
                                width: AppSize.w1_5.w,
                              )),
                          child: Center(
                            child: Text(
                              getTranslated(context, 'no'),
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s18_6.sp,
                                color: AppColors.red1,
                                fontWeight: FontWeight.w700,
                                fontStyle: FontStyle.normal,
                              ),
                            ),
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
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  void showSnack(String text, BuildContext context, bool status) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
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

  void ShowToastMessage(String s, bool status) {
    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16.sp);
  }

  Future cropImage(context) async {
    image = await ImagePicker().pickImage(source: ImageSource.gallery);

//    File croppedFile = File(image.path);

    Uint8List ime = await image!.readAsBytes();

    if (ime != null) {
      //
      setState(() {
        selectedProfileImage = ime;
      });
      // signupBloc.add(PickedProfilePictureEvent(file: croppedFile));
    } else {
      //not croppped
    }
  }

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    _typeArray = [
      KeyValueModel(key: 0, value: getTranslated(context, "age0")),
      KeyValueModel(key: 1, value: getTranslated(context, "age1")),
      KeyValueModel(key: 2, value: getTranslated(context, "age2")),
    ];
    return Scaffold(
      key: _scaffoldKey,
      body: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? 0
                        : AppPadding.p20,
                    right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p140.w
                        : AppPadding.p20,
                    top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p58.h
                        : AppPadding.p10,
                    bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppPadding.p41.h
                        : AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [CustomBackButton(),
                 
                    SizedBox(width: AppSize.w34.w),
                    Text(
                      getTranslated(context, "account"),
                      style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s34.sp
                                : AppFontsSizeManager.s21_3.sp,
                        fontWeight: FontWeight.bold,
                        color: AppColors.black1,
                      ),
                    ),
                  ],
                ),
              ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h1.h,
                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width
                      : AppSize.w1640.w)),
          //profiledata

          Expanded(
            child: ListView(
              padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? EdgeInsets.symmetric(
                      horizontal:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? AppPadding.p418.w
                              : size.width * AppPadding.p0_35,
                      vertical: 0)
                  : EdgeInsets.all(AppPadding.p20),
              children: [
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(
                        height: AppSize.h20.h,
                      ),
                      Center(
                        child: InkWell(
                          onTap: () {
                            cropImage(context);
                          },
                          child: ((widget.user.photoUrl == null ||widget.user.photoUrl!.isEmpty ) &&
                                  selectedProfileImage == null)
                              ? Image.asset(AssetsManager.whiteJerasLogoIconPath,
                                  fit: BoxFit.fill,
                                  height:
                                      (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                          ? AppSize.h170.h
                                          : AppSize.h93_3.h,
                                  width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                      ? AppSize.w170.w
                                      : AppSize.w93_3.w)
                              : selectedProfileImage != null
                                  ? ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.r35.r),
                                      child: Image.memory(selectedProfileImage!,
                                          fit: BoxFit.fill,
                                          height: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.h170.h
                                              : AppSize.h93_3.h,
                                          width: (kIsWeb ||
                                                  size.width >= AppConstants.kIsWebValue)
                                              ? AppSize.w170.w
                                              : AppSize.w93_3.w))
                                  : ClipRRect(
                                      borderRadius: BorderRadius.circular(
                                          AppRadius.r35.r),
                                      child: FadeInImage.assetNetwork(
                                        placeholder:
                                            AssetsManager.iconPersonIconPath,
                                        placeholderScale: 0.5,
                                        imageErrorBuilder:
                                            (context, error, stackTrace) =>
                                                Icon(
                                          Icons.person,
                                          color: AppColors.black,
                                          size: (kIsWeb ||
                                                  size.width >=
                                                      AppConstants.kIsWebValue)
                                              ? AppSize.w170.w
                                              : AppSize.w50,
                                        ),
                                        image: widget.user.photoUrl!,
                                        fit: BoxFit.cover,
                                        fadeInDuration: Duration(
                                            milliseconds:
                                                AppConstants.milliseconds250),
                                        fadeInCurve: Curves.easeInOut,
                                        fadeOutDuration: Duration(
                                            milliseconds:
                                                AppConstants.milliseconds150),
                                        fadeOutCurve: Curves.easeInOut,
                                      ),
                                    ),
                        ),
                      ),
                      SizedBox(
                          height:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h38.h
                                  : AppSize.h10.h),
                      (widget.user.name != null && widget.user.name != "")
                          ? Center(
                              child: Padding(
                                padding: const EdgeInsets.only(
                                    left: AppPadding.p20,
                                    right: AppPadding.p20),
                                child: Text(
                                  widget.user.name!,
                                  maxLines: 1,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.clip,
                                  style: TextStyle(
                                    fontWeight: FontWeight.w400,
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontStyle: FontStyle.normal,
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s36.sp
                                        : AppFontsSizeManager.s26_6.sp,
                                    color: AppColors.black1,
                                  ),
                                ),
                              ),
                            )
                          : SizedBox(),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h24.h
                                : AppSize.h5.h,
                      ),
                      Center(
                        child: TextDefaultWidget(
                          title: getTranslated(context, "welcomeBack"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s34.sp
                                  : AppFontsSizeManager.s24.sp,
                          fontFamily:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Ithralight")
                                  : getTranslated(context, "Ithra"),
                          color: AppColors.pink,
                        ),
                      ),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p72.h
                                : AppSize.h25.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 0
                                : AppPadding.p10,
                            bottom: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p30
                                : AppPadding.p10),
                        child: Theme(
                          data: new ThemeData(
                            primaryColor: AppColors.redAccent,
                            primaryColorDark: AppColors.red,
                          ),
                          child: TextFormFieldWidget(
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w1085.w
                                : AppSize.w509.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h95.h
                                : AppSize.h72.h,
                            controller: nameController,
                            name: getTranslated(
                              context,
                              "name",
                            ),
                            keyboardType: TextInputType.text,
                            validator: (value){

                              if(value!.trim().isEmpty){
                                return getTranslated(context, 'required');
                              }else {
                                List<String> names= value.trim().split(' ');
                                if(names.length<2){
                                  return getTranslated(context, 'enterTwoNames');
                                }
                              }
                              return null;
                            },
                          ),
                        ),
                      ),
                      getTitle(size, getTranslated(context, "age")),
                      SizedBox(
                          height: (kIsWeb || size.width >= 500) ? 0.h : 10.h),

                      Container(
                          height: (kIsWeb || size.width >= 500)
                              ? AppSize.h85.h
                              : AppSize.h60.h,
                          width: AppSize.w1085.w,
                          decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.primaryColor,
                                width: AppSize.w0_7,
                              ),
                              borderRadius: BorderRadius.all(
                                  Radius.circular(AppRadius.r15.r))),
                          child: Padding(
                            padding: const EdgeInsets.only(
                                left: AppPadding.p10, right: AppPadding.p10),
                            child: DropdownButton<String>(
                              hint: Text(
                                getTranslated(context, "ageCat"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: (kIsWeb || size.width >= 500)
                                        ? AppFontsSizeManager.s32
                                        : AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.grey,
                                    fontWeight: FontWeight.normal),
                              ),
                              underline: Container(),
                              isExpanded: true,
                              value: dropdownTypeValue,
                              icon: Icon(Icons.keyboard_arrow_down,
                                  color: (kIsWeb || size.width >= 500)
                                      ? AppColors.grey
                                      : AppColors.black),
                              iconSize: (kIsWeb || size.width >= 500)
                                  ? AppSize.w32.w
                                  : AppSize.w24,
                              elevation: 16,
                              style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: (kIsWeb || size.width >= 500)
                                    ? AppFontsSizeManager.s32
                                    : AppFontsSizeManager.s21_3.sp,
                                color: Colors.black.withOpacity(0.6),
                              ),
                              items: _typeArray
                                  .map((data) => DropdownMenuItem<String>(
                                      child: Text(
                                        data.value.toString(),
                                        style: TextStyle(
                                          fontFamily:
                                              getTranslated(context, "Ithra"),
                                          fontSize: (kIsWeb ||
                                                  size.width >= 500)
                                              ? AppFontsSizeManager.s32
                                              : AppFontsSizeManager.s21_3.sp,
                                          color: (kIsWeb || size.width >= 500)
                                              ? AppColors.grey2
                                              : Colors.black.withOpacity(0.6),
                                        ),
                                      ),
                                      value: data.key.toString() //data.key,
                                      ))
                                  .toList(),
                              onChanged: (String? value) {
                                setState(() {
                                  dropdownTypeValue = value;
                                  widget.user.age =
                                      _typeArray[int.parse(value!)].value;
                                  widget.user.ageValue =
                                      _typeArray[int.parse(value)].key;
                                });
                              },
                            ),
                          )),
                      SizedBox(
                          height: (kIsWeb || size.width >= 500) ? 0.h : 10.h),
                      sendReq
                          ? Center(
                              child: Text(
                              getTranslated(context, "required"),
                              style: GoogleFonts.poppins(
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s18.sp
                                    : AppFontsSizeManager.s13.sp,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                color: AppColors.red,
                              ),
                            ))
                          : SizedBox(),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 0
                                : AppSize.h10.h,
                      ),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h75.h
                                : AppSize.h5.h,
                      ),
                      Padding(
                        padding: EdgeInsets.only(
                            top: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? 0
                                : AppPadding.p10,
                            bottom: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppPadding.p108.h
                                : AppPadding.p10),
                        child: Theme(
                          data: new ThemeData(
                            primaryColor: AppColors.redAccent,
                            primaryColorDark: AppColors.red,
                          ),
                          child: TextFormFieldWidget(
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w1085.w
                                : AppSize.w509.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h95.h
                                : AppSize.h72.h,
                            controller: educationLevelController,
                            name: getTranslated(
                              context,
                              "education",
                            ),
                            hintText: getTranslated(
                              context,
                              "studente",
                            ),
                            validator: (value){

                              if(value!.trim().isEmpty){
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                          ),
                        ),
                      ),

                      Center(
                          child: getTitle(
                              size, getTranslated(context, "interests"))),
                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h72.h
                                : AppSize.h15.h,
                      ),
                      _inter
                          ? Center(
                              child: Text(
                              getTranslated(context, "required"),
                              style: GoogleFonts.poppins(
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s18.sp
                                    : AppFontsSizeManager.s13.sp,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_3,
                                color: AppColors.red,
                              ),
                            ))
                          : SizedBox(),
                      loadInterests
                          ? Center(
                              child: CircularProgressIndicator(
                              color: AppColors.pink,
                            )
                            )
                          : Container(
                              //key: _formKey,
                              // height: AppSize.h876.h,
                              child: MediaQuery.removePadding(
                                context: context,
                                removeTop: true,
                                removeBottom: true,
                                child: GridView.count(
                                  crossAxisCount: 3,
                                  shrinkWrap: true,
                                  physics: NeverScrollableScrollPhysics(),
                                  mainAxisSpacing: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.h35.h
                                      : AppSize.h10.h,
                                  crossAxisSpacing: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.w70
                                      : AppSize.w10.w,
                                  childAspectRatio: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? 1.2
                                      : (149.r / 146.r),
                                  children: interestList
                                      .map(
                                        (Item) => ItemList(Item),
                                      )
                                      .toList(),
                                ),
                              ),
                            ),
                      SizedBox(
                        height: AppSize.h80_5.h,
                      ),
                      Container(
                        child: TextFormField(
                          validator: (String? val) {
                            if (val!.trim().isEmpty) {
                              return getTranslated(context, 'required');
                            }
                            return null;
                          },
                          maxLines: 7,
                          maxLength:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 3000
                                  : 300,
                          style: TextStyle(
                            fontFamily: size.width >= 500
                                ? getTranslated(context, "Ithralight")
                                : getTranslated(context, "Ithralight"),
                            fontSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s18.sp
                                : AppFontsSizeManager.s14.sp,
                            color: AppColors.grey,
                          ),
                          cursorColor: Colors.black,
                          initialValue: widget.user.bio,
                          keyboardType: TextInputType.multiline,
                          inputFormatters: [FilteringTextInputFormatter.deny(RegExp(r'[0-9]'))],
                          onSaved: (val) {
                            widget.user.bio = val;
                          },
                          decoration: InputDecoration(
                            label: Text(
                              getTranslated(context, "bio"),
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s32.sp
                                      : AppFontsSizeManager.s21_3.sp,
                                  color: AppColors.pink,
                                  fontWeight: FontWeight.normal),
                            ),
                            errorStyle: TextStyle(
                                fontFamily: getTranslated(
                                    context, "Ithra"), // 'Montserrat',
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? 32
                                    : 21.3.sp,
                                color: AppColors.red,
                                fontWeight: FontWeight.normal),
                            counterStyle: TextStyle(
                              color: Colors.grey,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s18.sp
                                  : AppFontsSizeManager.s14.sp,
                            ),
                            hintStyle: TextStyle(
                              fontFamily: size.width >= 500
                                  ? getTranslated(context, "Ithralight")
                                  : getTranslated(context, "Ithralight"),
                              color: Colors.grey,
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s18.sp
                                  : AppFontsSizeManager.s14.sp,
                              fontWeight: AppFontsWeightManager.semiBold,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            hintText: getTranslated(context, "bio"),
                            enabledBorder: new OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: .5,
                                  color: Color.fromRGBO(158, 158, 158, 1)),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            focusedBorder: new OutlineInputBorder(
                              borderSide: BorderSide(
                                  width: .5, color: AppColors.primaryColor),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            border: OutlineInputBorder(
                              borderSide: BorderSide(
                                  color: Color.fromRGBO(158, 158, 158, 1)),
                              borderRadius: BorderRadius.circular(7.0),
                            ),
                            //  hintText: sLabel
                          ),
                        ),
                      ),
                      SizedBox(
                        height: AppSize.h16.h,
                      ),
                      Container(
                        margin: EdgeInsets.symmetric(vertical: AppMargin.m10),
                        child: InkWell(
                          onTap: () {
                            showDeleteConfimationDialog(size);
                          },
                          child: Row(
                            children: [
                              SvgPicture.asset(
                                AssetsManager.delete1IconPath,
                                color: AppColors.red,
                                width: AppSize.w48.r,
                                height: AppSize.h48.r,
                              ),
                              Text(
                                getTranslated(context, "deleteAccount"),
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s34.sp
                                        : AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.black,
                                    fontWeight: FontWeight.w300),
                              ),
                            ],
                          ),
                        ),
                      ),

                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h75.h
                                : AppSize.h16.h,
                      ),
                      Center(
                        child: TextButton1(
                            onPress: () {
                              if (_formKey.currentState!.validate()) {
                                save();
                              }
                            },
                            Title: getTranslated(context, "saveAndContinue"),
                            TextFont: getTranslated(context, "Ithra"),
                            TextSize: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppFontsSizeManager.s36.sp
                                : AppFontsSizeManager.s21_3.sp,
                            TextColor: AppColors.white,
                            Width: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w947.w
                                : AppSize.w390.w,
                            Height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h100.h
                                : AppSize.h66_6.h,
                            ButtonRadius: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppRadius.r24.r
                                : AppRadius.r16.r,
                            GradientColor: AppColors.primaryColor,
                            GradientColor2: AppColors.linear4,
                            Padding: AppPadding.p18_6.h,
                            Padding2: AppPadding.p16.w),
                      ),

                      SizedBox(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h83.h
                                : AppSize.h16.h,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // }),
        ],
      ),
    );
  }

  Widget getTitle(Size size, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppPadding.p5),
      child: Text(
        title,
        textAlign: TextAlign.center,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(
            fontFamily: getTranslated(context, "Ithra"),
            fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? AppFontsSizeManager.s32.sp
                : AppFontsSizeManager.s21_3.sp,
            color: AppColors.pink,
            fontWeight: FontWeight.normal),
      ),
    );
  }


  save() async {
    if (dropdownTypeValue == null) {
      setState(() {
        sendReq = true;
      });
    } else if (widget.user.interestListIds == null ||
        widget.user.interestListIds!.length == 0) {
      setState(() {
        _inter = true;
      });
    } else if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try {
        setState(() {
          sendReq = false;
          _inter = false;
        });
        List<String> indexList = [];
        for (int y = 1;
            y <= nameController.text.trimLeft().trimRight().length;
            y++) {
          indexList.add(nameController.text
              .trimLeft()
              .trimRight()
              .substring(0, y)
              .toLowerCase());
        }

        widget.user.searchIndex = indexList;

        widget.user.profileCompleted = true;
        widget.user.name = nameController.text.trim();
        widget.user.education = educationLevelController.text.trim();
        widget.user.userLang = getTranslated(context, 'lang');
        setState(() {
          dataSave = true;
        });
        if (selectedProfileImage != null) {
          accountBloc.add(UpdateAccountDetailsEvent(
              user: widget.user, profileImage: selectedProfileImage));
        } else {
          accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
        }
      } catch (e) {}
    } else {}
  }

  Widget ItemList(Interests item) {
    String lang = getTranslated(context, "lang");
    return InkWell(
      onTap: () {
        if (widget.user.interestListIds!.contains(item.interestId))
          setState(() {
            widget.user.interestListIds!.remove(item.interestId);
          });
        else
          setState(() {
            widget.user.interestListIds!.add(item.interestId);
          });
      },
      child: Container(
        margin: EdgeInsets.all(AppMargin.m6),
        decoration: BoxDecoration(
            boxShadow: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? [AppShadow.greyshadow]
                : null,
            color: widget.user.interestListIds!.contains(item.interestId)
                ? AppColors.shadoColor
                : AppColors.white,
            borderRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? BorderRadius.circular(AppRadius.r40.r)
                : BorderRadius.circular(AppRadius.r10_6.r)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Spacer(flex: 2)
                : SizedBox(),
            Container(
              height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.h55.h
                  : AppSize.h33.h,
              width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppSize.w55.w
                  : AppSize.w33.w,
              child: item.icon!.isEmpty
                  ? Image.asset(
                      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h55.h
                          : null,
                      AssetsManager.whiteJerasLogoIconPath,
                    )
                  : Container(
                      child: Image.network(
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h55.h
                                : null,
                        item.icon!,
                        scale: 0.5,
                        color: widget.user.interestListIds!
                                .contains(item.interestId)
                            ? AppColors.lightGrey5
                            : AppColors.shadoColor,
                      ),
                    ),
            ),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Spacer(flex: 1)
                : SizedBox(),
            Stack(
              children: <Widget>[
                Text(
                  lang == "ar" ? item.arName : item.enName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : AppFontsSizeManager.s17.sp,
                    fontWeight: AppFontsWeightManager.bold300,
                    foreground: Paint()
                      ..style = PaintingStyle.stroke
                      ..strokeWidth = 0.2
                      ..color =
                          widget.user.interestListIds!.contains(item.interestId)
                              ? AppColors.lightGrey5
                              : AppColors.shadoColor,
                  ),
                ),
                // Solid text as fill.
                Text(
                  lang == "ar" ? item.arName : item.enName,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color:
                        widget.user.interestListIds!.contains(item.interestId)
                            ? AppColors.lightGrey5
                            : AppColors.shadoColor,
                    fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                        ? AppFontsSizeManager.s32.sp
                        : AppFontsSizeManager.s17.sp,
                    fontWeight: AppFontsWeightManager.bold300,
                  ),
                ),
              ],
            ),
            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                ? Spacer(flex: 2)
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  BoxShadow shadow() {
    return BoxShadow(
      color: AppColors.lightGrey,
      blurRadius: 2.0,
      spreadRadius: 0.0,
      offset: Offset(0.0, 1.0), // shadow direction: bottom right
    );
  }
}
