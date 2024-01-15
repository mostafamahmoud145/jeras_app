import 'dart:developer';
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/api/api.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/VideoPlayerWidget.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/jerasDialogWidget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:jeras/widget/videoListDialog.dart';
import 'package:jeras/widget/videoWidget.dart';
import 'package:path/path.dart' as p;
import 'package:uuid/uuid.dart';
import 'package:video_player/video_player.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../widget/processing_dialog.dart';
import '../config/app_constat.dart';
import '../config/paths.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
import '../controller/blocs/replace_video_bloc/cubit.dart';
import '../controller/blocs/replace_video_bloc/state.dart';
import '../services/app_flyer_service.dart';
import '../widget/component/IconButton.dart';
import '../widget/component/TextFormFieldWidget.dart';
import '../widget/firebase_video_player_widget.dart';

class AccountScreen extends StatefulWidget {
  GroceryUser user;
  Video consultVideo;
  String? consultUid;
  bool? check;

  AccountScreen(
      {Key? key,
      required this.user,
      required this.consultVideo,
      this.check,
      this.consultUid})
      : super(key: key);

  @override
  _AccountScreenState createState() => _AccountScreenState();
}

class _AccountScreenState extends State<AccountScreen> {
  Video videoo = Video();
  PlatformFile? pickedfile;
  File? mainVidFile;
  File? firstVidFile;
  File? secondVidFile;
  File? file;
  String? id = Uuid().v4();

  UploadTask? task;
  late QuerySnapshot querySnapshot1;
  late AccountBloc accountBloc;
  bool profileCompleted = false,
      saving = false,
      dataSave = false,
      showCheck = false;
  final _scaffoldKey = GlobalKey<ScaffoldState>();
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  TimeOfDay selectedTime = TimeOfDay.now();
  late String interests = "",
      workDays = "",
      from,
      to,
      theme = "light",
      price,
      downloadurl = '';
  late TextEditingController daysController,
      langController,
      typeController,
      fromController,
      toController,
      interestsController;

  TextEditingController locationArController = TextEditingController();
  TextEditingController locationEnController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  TextEditingController bioLinkController = TextEditingController();

  bool monday = false,
      tuesday = false,
      wednesday = false,
      thursday = false,
      friday = false,
      saturday = false,
      sunday = false,
      first = true;

  late List<WorkTimes> workTimes;
  List<dynamic> daysValue = [];
  double videoDuration = 0;
  double currentDuration = 0;
  WorkTimes _workTime = new WorkTimes();
  var image;
  Uint8List? selectedProfileImage;
  late Size size;
  bool deleting = false;
  String lang = "";
  late VideoPlayerController videoPlayerController;
  late VideoPlayerController firstVideoPlayerController;

  String selectedFile = '';
  XFile? newFile;
  Uint8List? selectedImageInBytes;
  List<Uint8List> pickedImagesInBytes = [];

  bool arabic = false, french = false, english = false;

  TextEditingController nameArController = TextEditingController();
  TextEditingController nameEnController = TextEditingController();
  TextEditingController nameFrController = TextEditingController();

  TextEditingController bioArController = TextEditingController();
  TextEditingController bioEnController = TextEditingController();
  TextEditingController bioFrController = TextEditingController();

  late String nameAr;
  late String nameEn;
  late String nameFr;
  late String bioAr;
  late String bioEn;
  late String bioFr;

  late List<dynamic> searchAr;
  late List<dynamic> searchEn;
  late List<dynamic> searchFr;

  bool langOpen = false;
  bool packagesOpen = false;
  bool accountTypeOpen = false;
  bool workDaysOpen = false;
  bool chatPackageOpen = false;
  File? videoUrl;
  bool load = true;
  List<Video> list = [];

  VideoPlayerController? _controller;
  VideoPlayerController? replaceVidController;
  VideoPlayerController? firstVidController;
  VideoPlayerController? replaceFirstVidController;
  VideoPlayerController? secondVidController;
  VideoPlayerController? replaceSecondVidController;
  final ImagePicker _picker = ImagePicker();

  bool replaceVideo = false;
  bool _replaceFirstVideo = false;
  bool _replaceSecondVideo = false;
  XFile? mainVideo;
  XFile? picFirstVideo;
  XFile? picSecondVideo;
  String? newVideoPath;
  XFile? picRepFirstVideo;
  XFile? picRepSecVideo;
  XFile? picRepMainVideo;
  bool replaceYoutubeVideo = true;

  @override
  void dispose() {
    VideoCubit.get(context).replaceVidController!.pause();

    _controller!.dispose();
    videoPlayerController.dispose();
    if (replaceVidController != null) {
      replaceVidController!.dispose();
    }

    super.dispose();
  }

  String? vidLink1;
  String? vidLink2;

  List<String> vidLinks = [];

  Future<Map<String, dynamic>?> getFirstLinkForConsultUid() async {
    // Reference to the collection
    CollectionReference videoList =
        FirebaseFirestore.instance.collection("VideoList");

    try {
      // Query the collection for a specific consultUid
      log("UID:   ${widget.user.uid.toString()}");
      var querySnapshot =
          await videoList.where('consultUid', isEqualTo: widget.user.uid).get();
      for (var doc in querySnapshot.docs) {
        // Do something with each document
        Map<String, dynamic> x = doc.data() as Map<String, dynamic>;
        print("Docccccc: ${doc.data()}");
        print("Linkkkkkk: ${x["link"]}");
        vidLinks.add(x["link"]);
      }
      print("List Length : ${vidLinks.length}");
      setState(() {});
    } catch (e) {
      print("Error getting document: $e");
      return null; // Return null if there's an error
    }
  }

  @override
  void initState() {
    super.initState();
    replaceYoutubeVideo = widget.check ?? false;
    if (replaceYoutubeVideo == true) {
      VideoCubit.get(context).replaceVidController!.play();
      picRepMainVideo = VideoCubit.get(context).picRepMainVideo;
    }
    getFirstLinkForConsultUid();

    print("SECONDVISEOO${vidLinks.length}");
    print("USERID${widget.user.uid}");
    if (widget.user.link != null) {
      videoPlayerController =
          VideoPlayerController.network(widget.user.link.toString());
      videoPlayerController.initialize().then((_) {
        setState(() {
          videoDuration =
              videoPlayerController.value.duration.inMilliseconds.toDouble();
        });
      });

      videoPlayerController.addListener(() {});
    }
    if (widget.user.link != null) {
      _controller = VideoPlayerController.network(widget.user.link.toString());
      _controller!.initialize().then((_) {
        setState(() {
          videoDuration = _controller!.value.duration.inMilliseconds.toDouble();
        });
      });

      _controller!.addListener(() {});
    }

    if (vidLinks.isNotEmpty) {
      firstVideoPlayerController =
          VideoPlayerController.network(vidLinks[0].toString());
      firstVideoPlayerController.initialize().then((_) {
        setState(() {
          videoDuration = firstVideoPlayerController
              .value.duration.inMilliseconds
              .toDouble();
        });
      });

      firstVideoPlayerController.addListener(() {});
    }
    nameAr = widget.user.name!;
    nameEn = widget.user.nameEn!;
    nameFr = widget.user.nameFr!;

    bioAr = widget.user.bio!;
    bioEn = widget.user.bioEn!;
    bioFr = widget.user.bioFr!;

    searchAr = widget.user.searchIndex ?? [];
    searchEn = widget.user.searchIndexEn ?? [];
    searchFr = widget.user.searchIndexFr ?? [];

    nameArController.text = nameAr;
    nameEnController.text = nameEn;
    nameFrController.text = nameFr;

    bioArController.text = bioAr;
    bioEnController.text = bioEn;
    bioFrController.text = bioFr;

    profileCompleted = widget.user.profileCompleted!;
    price = widget.user.price!;
    daysController = TextEditingController();
    langController = TextEditingController();
    typeController = TextEditingController();
    fromController = TextEditingController();
    toController = TextEditingController();
    if (widget.user.workTimes!.length > 0) {
      _workTime = widget.user.workTimes![0];
      if (_workTime.from != null) {
        from = _workTime.from!;
        int fromvalue = int.parse(_workTime.from!);
        if (fromvalue == 12)
          fromController.text = "12 ${getTranslated(context, 'pm')}";
        else if (fromvalue == 0)
          fromController.text = "12 ${getTranslated(context, 'am')}";
        else if (fromvalue > 12)
          fromController.text = (fromvalue - 12).toString() + " PM";
        else
          fromController.text = fromvalue.toString() + " AM";
      }
      if (_workTime.to != null) {
        to = _workTime.to!;
        int toValue = int.parse(_workTime.to!);
        if (toValue == 12)
          toController.text = "12 PM";
        else if (toValue == 0)
          toController.text = "12 AM";
        else if (toValue > 12)
          toController.text = (toValue - 12).toString() + " PM";
        else
          toController.text = toValue.toString() + " AM";
      }
    }
    locationArController.text = widget.user.location!;
    locationEnController.text = widget.user.locationEn!;
    priceController.text = widget.user.price!;
    accountBloc = BlocProvider.of<AccountBloc>(context);
    accountBloc.stream.listen((state) {
      if (state is GetLoggedUserCompletedState) {
        if (mounted && dataSave) {
          dataSave = false;
          Navigator.pushNamedAndRemoveUntil(
            context,
            '/home',
            (route) => false,
          );
        }
      }
      if (state is UpdateAccountDetailsInProgressState) {
        //show dialog
        if (mounted) showUpdatingDialog();
      }
      if (state is UpdateAccountDetailsFailedState) {
        //show error
        showSnack(getTranslated(context, "error"), context);
      }
      if (state is UpdateAccountDetailsCompletedState) {
        if (mounted) {
          accountBloc.add(GetLoggedUserEvent());
        }
      }
    });
    WidgetsBinding.instance.addPostFrameCallback((_) => change());
  }

  // defualtLangUser() {
  //   if (widget.user.userLang == "ar" &&
  //       widget.user.languages!.contains("ar") == false) {
  //     widget.user.languages!.add("ar");
  //     arabic = true;
  //   } else if (widget.user.userLang == "en" &&
  //       widget.user.languages!.contains("en") == false) {
  //     widget.user.languages!.add("en");
  //     english = true;
  //   }
  // }

  change() {
    if (widget.user.languages!.length > 0) {
      if (widget.user.languages!.contains(getTranslated(context, 'ar'))) {
        arabic = true;
        lang = "" + getTranslated(context, 'ar');
      }
      if (widget.user.languages!.contains(getTranslated(context, 'en'))) {
        english = true;
        lang = " / " + getTranslated(context, 'en');
      }
      if (widget.user.languages!.contains(getTranslated(context, 'fr'))) {
        french = true;
        lang = " / " + getTranslated(context, 'fr');
      }
    }
    setState(() {
      langController = TextEditingController(text: lang);
    });
  }

  sendMassageDialoge2(
      BuildContext context, Size size, FilePickerResult result, dynamic file) {
    String name = p.basename(file.path);
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Column(
          children: <Widget>[
            Padding(
              padding:
                  EdgeInsets.only(right: AppSize.w10_6.w, top: AppSize.h10_6.h),
              child: Column(
                children: [
                  Padding(
                    padding: EdgeInsets.only(bottom: AppSize.h24.h),
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: <Widget>[
                        Stack(children: [
                          if (videoPlayerController != null) ...[
                            AspectRatio(
                              aspectRatio:
                                  videoPlayerController!.value.aspectRatio,
                              child: InkWell(
                                  onTap: () {
                                    setState(() {
                                      videoPlayerController!.value.isPlaying
                                          ? videoPlayerController!.pause()
                                          : videoPlayerController!.play();
                                    });
                                    print('now');
                                    print(videoPlayerController!.value.isPlaying
                                        .toString());
                                  },
                                  child: VideoPlayer(videoPlayerController!)),
                            ),
                          ]
                        ]),
                      ],
                    ),
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

  File? video;

  ///--------------------------<<<Select Video From Mobile && Web>>>----------------------------///

  Future selectFile() async {
    if (widget.user.link == null) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        allowMultiple: false,
      );

      if (result == null) return;
      final res = result.files.single.path!;
      file = File(res);
      setState(() {
        //showVideoPlayer2(context, file!);
      });
    } else {
      File file2 = File(widget.user.link!);
      setState(() {
        //showVideoPlayer2(context, file2);
      });
    }
  }

  Future uploadfile() async {
    if (file == null) return;
    final filename = p.basename(file!.path);
    final destination = 'consultVideos/$filename';
    task = APIs.uploadTask(destination, file!);
    if (task == null) return print('error');
    final snap = await task!.whenComplete(() {});
    final url = await snap.ref.getDownloadURL();
    setState(() {
      downloadurl = url.toString();
    });

    print('Link:$downloadurl');
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
                                    getTranslated(context, 'yes'),
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
                                width: 1.5.w,
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

  @override
  void didChangeDependencies() {
    if (widget.user.languages!.length > 0) {
      if (widget.user.languages!.contains("ar")) {
        arabic = true;
        lang = "  " + getTranslated(context, 'ar');
      }
      if (widget.user.languages!.contains("en")) {
        english = true;
        lang = " / " + getTranslated(context, 'en');
      }
      if (widget.user.languages!.contains("fr")) {
        french = true;
        lang = " / " + getTranslated(context, 'fr');
      }
    }
    if (first && widget.user.workDays!.length > 0) {
      first = false;
      if (widget.user.workDays!.contains("1")) {
        workDays = workDays + getTranslated(context, "monday") + " / ";
        monday = true;
      }
      if (widget.user.workDays!.contains("2")) {
        workDays = workDays + getTranslated(context, "tuesday") + " / ";
        tuesday = true;
      }
      if (widget.user.workDays!.contains("3")) {
        workDays = workDays + getTranslated(context, "wednesday") + " / ";
        wednesday = true;
      }
      if (widget.user.workDays!.contains("4")) {
        workDays = workDays + getTranslated(context, "thursday") + " / ";
        thursday = true;
      }
      if (widget.user.workDays!.contains("5")) {
        workDays = workDays + getTranslated(context, "friday") + " / ";
        friday = true;
      }
      if (widget.user.workDays!.contains("6")) {
        workDays = workDays + getTranslated(context, "saturday") + " / ";
        saturday = true;
      }
      if (widget.user.workDays!.contains("7")) {
        workDays = workDays + getTranslated(context, "sunday") + " / ";
        sunday = true;
      }
      setState(() {
        daysController.text = workDays;
        //langController = TextEditingController(text: lang);
        // langController.text = lang;
      });
    }

    super.didChangeDependencies();
  }

  void showSnack(String text, BuildContext context) {
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

  @override
  Widget build(BuildContext context) {
    size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      key: _scaffoldKey,
      backgroundColor: AppColors.white,
      body: WillPopScope(
        onWillPop: () async {
          VideoCubit.get(context).replaceVidController!.dispose();
          Navigator.pop(context);
          return await false;
        },
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: <Widget>[
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h140.h
                          : AppPadding.p20,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h140.h
                          : AppPadding.p20,
                      top: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppSize.h85.h
                          : AppPadding.p10,
                      bottom: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? AppPadding.p41.h
                          : AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(),
                      SizedBox(
                          width:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h34.h
                                  : AppSize.w21_3.w),
                      Text(
                        getTranslated(context, "account"),
                        style: TextStyle(
                          fontFamily:
                              getTranslated(context, "NotoKufiArabic-SemiBold"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s36.sp
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
                    width: size.width)),
            Expanded(
              child: ListView(
                padding: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                    ? EdgeInsets.symmetric(
                        horizontal: AppPadding.p140.w, vertical: AppSize.h56.h)
                    : EdgeInsets.symmetric(
                        horizontal: AppPadding.p20.w,
                        vertical: AppPadding.p20.h),
                children: [
                  Form(
                    key: _formKey,
                    child: Padding(
                      padding:
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? EdgeInsets.all(0)
                              : EdgeInsets.all(0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.center,
                        children: <Widget>[
                          Center(
                            child: InkWell(
                              onTap: () {
                                cropImage(context);
                              },
                              child: Container(
                                height: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.h160.h
                                    : AppSize.h93.h,
                                width: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppSize.w160.w
                                    : AppSize.h93.w,
                                decoration: BoxDecoration(
                                  shape: BoxShape.circle,
                                  color: Colors.white,
                                  border: Border.all(
                                      color: Colors.white,
                                      width: AppSize.w0_5.w),
                                  // boxShadow: [
                                  //   BoxShadow(
                                  //       offset: Offset(0, 5.0),
                                  //       blurRadius: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  //           ? 17
                                  //           : 5.0,
                                  //       spreadRadius: 1.0,
                                  //       color:
                                  //           Color.fromRGBO(123, 108, 150, 0.1)),
                                  // ],
                                ),
                                child: widget.user.photoUrl == null &&
                                        selectedProfileImage == null
                                    ? Image.asset(
                                        AssetsManager.whiteJerasLogoIconPath,
                                        fit: BoxFit.fill,
                                        height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                            ? AppSize.h248.h
                                            : AppSize.h93.h,
                                        width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                            ? AppSize.w248.w
                                            : AppSize.h93.w)
                                    : selectedProfileImage != null
                                        ? ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r35.r),
                                            child: Image.memory(
                                                selectedProfileImage!,
                                                fit: BoxFit.fill,
                                                height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                                    ? AppSize.h120.h
                                                    : AppSize.h93.h,
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants.kIsWebValue)
                                                    ? AppSize.w120.w
                                                    : AppSize.h93.w))
                                        : ClipRRect(
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r35.r),
                                            child: FadeInImage.assetNetwork(
                                              placeholder: AssetsManager
                                                  .iconPersonIconPath,
                                              placeholderScale: 0.5,
                                              imageErrorBuilder: (context,
                                                      error, stackTrace) =>
                                                  Icon(
                                                Icons.person,
                                                color: AppColors.black,
                                                size: AppSize.w50,
                                              ),
                                              image: widget.user.photoUrl!,
                                              fit: BoxFit.cover,
                                              fadeInDuration: Duration(
                                                  milliseconds: AppConstants
                                                      .milliseconds250),
                                              fadeInCurve: Curves.easeInOut,
                                              fadeOutDuration: Duration(
                                                  milliseconds: AppConstants
                                                      .milliseconds150),
                                              fadeOutCurve: Curves.easeInOut,
                                            ),
                                          ),
                              ),
                            ),
                          ),
                          SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h32.h
                                  : AppSize.h10.h),
                          Center(
                            child: Padding(
                              padding: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? EdgeInsets.all(0)
                                  : EdgeInsets.only(
                                      left: AppPadding.p20,
                                      right: AppPadding.p20),
                              child: Text(
                                getTranslated(context, "lang") == "ar"
                                    ? widget.user.name!
                                    : getTranslated(context, "lang") == "en"
                                        ? widget.user.nameEn!
                                        : widget.user.nameFr!,
                                maxLines: 1,
                                textAlign: TextAlign.center,
                                overflow: TextOverflow.clip,
                                style: TextStyle(
                                  fontWeight: FontWeight.w400,
                                  fontFamily: getTranslated(
                                      context, "NotoKufiArabic-SemiBold"),
                                  fontStyle: FontStyle.normal,
                                  fontSize: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppFontsSizeManager.s48.sp
                                      : AppFontsSizeManager.s26_6.sp,
                                  color: AppColors.black1,
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h32.h
                                : AppSize.h5.h,
                          ),
                          Center(
                            child: TextDefaultWidget(
                              title: getTranslated(context, "welcomeBack"),
                              fontFamily: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? getTranslated(context, "Ithralight")
                                  : getTranslated(
                                      context, "NotoKufiArabic-SemiBold"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s32.sp
                                  : AppFontsSizeManager.s24.sp,
                              color: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppColors.grey
                                  : AppColors.pink,
                              fontWeight: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsWeightManager.bold100
                                  : FontWeight.w500,
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h56.h
                                : AppSize.h42.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p10_6.w),
                            child: Container(
                              child: InputDecorator(
                                expands: false,
                                decoration: InputDecoration(
                                  contentPadding: EdgeInsets.symmetric(
                                      horizontal: 20.w,
                                      vertical: 21.h), // <-- SEE HERE
                                  labelText:
                                      getTranslated(context, "languages"),
                                  labelStyle: TextStyle(
                                    fontFamily: getTranslated(
                                        context, 'NotoKufiArabic-SemiBold'),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s32.sp
                                        : AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.linear8,
                                    fontWeight: FontWeight.bold,
                                  ),
                                  enabledBorder: new OutlineInputBorder(
                                    borderSide: BorderSide(
                                        width: AppSize.w0_5.w,
                                        color: AppColors.grey3),
                                    borderRadius: BorderRadius.circular(
                                        AppRadius.r10_6.r),
                                  ),
                                ),
                                child: Column(
                                  children: [
                                    Row(
                                      mainAxisAlignment:
                                          MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          langController.text,
                                          style: TextStyle(
                                            fontFamily: getTranslated(context,
                                                'NotoKufiArabic-Regular'),
                                            fontSize:
                                                AppFontsSizeManager.s21_3.sp,
                                            color: AppColors.darkGrey,
                                            fontWeight: FontWeight.w300,
                                          ),
                                        ),
                                        InkWell(
                                            onTap: () {
                                              setState(() {
                                                langOpen = !langOpen;
                                              });
                                            },
                                            child: Icon(
                                              langOpen
                                                  ? Icons.keyboard_arrow_up
                                                  : Icons.keyboard_arrow_down,
                                              color: AppColors.linear2,
                                            )),
                                      ],
                                    ),
                                    langOpen
                                        ? _showLang(context, size)
                                        : SizedBox(),
                                  ],
                                ),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h86.h
                                : AppSize.h42_6.h,
                          ),

                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    arabic
                                        ? Column(children: [
                                            SizedBox(
                                              width: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppSize.w808.w
                                                  : AppSize.w509.w,
                                              height: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppSize.h80.h
                                                  : AppSize.h72.h,
                                              child: TextFormFieldWidget(
                                                keyboardType:
                                                    TextInputType.text,
                                                labelFont: getTranslated(
                                                    context,
                                                    'NotoKufiArabic-SemiBold'),
                                                font: getTranslated(context,
                                                    'NotoKufiArabic-Regular'),
                                                name: getTranslated(
                                                    context, "nameAr"),
                                                controller: nameArController,
                                                obscureText: false,
                                              ),
                                            ),
                                          ])
                                        : SizedBox(),
                                    english
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w808.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h80.h
                                                    : AppSize.h72.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "nameEn"),
                                                  controller: nameEnController,
                                                  obscureText: false,
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    french
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w808.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h80.h
                                                    : AppSize.h72.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "nameFr"),
                                                  controller: nameEnController,
                                                  obscureText: false,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h42_6.h),
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                )
                              : Column(
                                  children: [
                                    arabic
                                        ? Column(
                                            children: [
                                              SizedBox(
                                                width: AppSize.w509.w,
                                                height: AppSize.h72.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "nameAr"),
                                                  controller: nameArController,
                                                  obscureText: false,
                                                ),
                                              ),
                                              SizedBox(height: AppSize.h42_6.h),
                                            ],
                                          )
                                        : SizedBox(),
                                    english
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w1085.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h95.h
                                                    : AppSize.h72.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "nameEn"),
                                                  controller: nameEnController,
                                                  obscureText: false,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h42_6.h),
                                            ],
                                          )
                                        : SizedBox(),
                                    french
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w1085.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h95.h
                                                    : AppSize.h72.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "nameFr"),
                                                  controller: nameEnController,
                                                  obscureText: false,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h42_6.h),
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                ),

                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.w86.w
                                : 0,
                          ),
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w808.w
                                          : AppSize.w509.w,
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h80.h
                                          : AppSize.h72.h,
                                      child: TextFormFieldWidget(
                                        keyboardType: TextInputType.text,
                                        labelFont: getTranslated(
                                            context, 'NotoKufiArabic-SemiBold'),
                                        font: getTranslated(
                                            context, 'NotoKufiArabic-Regular'),
                                        name: getTranslated(
                                            context, "locationAr"),
                                        controller: locationArController,
                                        obscureText: false,
                                      ),
                                    ),
                                    Container(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w808.w
                                          : AppSize.w509.w,
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h80.h
                                          : AppSize.h72.h,
                                      child: TextFormFieldWidget(
                                        keyboardType: TextInputType.text,
                                        labelFont: getTranslated(
                                            context, 'NotoKufiArabic-SemiBold'),
                                        font: getTranslated(
                                            context, 'NotoKufiArabic-Regular'),
                                        name: getTranslated(
                                            context, "locationEn"),
                                        controller: locationEnController,
                                        obscureText: false,
                                      ),
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    arabic
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w1085.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h95.h
                                                    : AppSize.h72.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "locationAr"),
                                                  controller:
                                                      locationArController,
                                                  obscureText: false,
                                                ),
                                              ),
                                              SizedBox(
                                                height: AppSize.h42.h,
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    english
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w1085.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h95.h
                                                    : AppSize.h72.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.text,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "locationEn"),
                                                  controller:
                                                      locationEnController,
                                                  obscureText: false,
                                                ),
                                              ),
                                              SizedBox(
                                                height: AppSize.h42.h,
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                ),
                          //
                          // SizedBox(
                          //     height: (kIsWeb ||
                          //             size.width >= AppConstants.kIsWebValue)
                          //         ? AppSize.h86.h
                          //         : AppSize.h42_6.h),

                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    arabic
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w808.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h228.h
                                                    : AppSize.h153_3.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "bioAr"),
                                                  controller: bioArController,
                                                  obscureText: false,
                                                  lines: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h36.h),
                                            ],
                                          )
                                        : SizedBox(),
                                    english
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w808.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h228.h
                                                    : AppSize.h153_3.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "bioEn"),
                                                  controller: bioEnController,
                                                  obscureText: false,
                                                  lines: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : 0.h),
                                            ],
                                          )
                                        : SizedBox(),
                                    french
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w808.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h228.h
                                                    : AppSize.h153_3.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "bioFr"),
                                                  controller: bioFrController,
                                                  obscureText: false,
                                                  lines: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h42_6.h),
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                )
                              : Column(
                                  children: [
                                    arabic
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w1085.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h230.h
                                                    : AppSize.h153_3.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "bioAr"),
                                                  controller: bioArController,
                                                  obscureText: false,
                                                  lines: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h42.h),
                                            ],
                                          )
                                        : SizedBox(),
                                    english
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w1085.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h230.h
                                                    : AppSize.h153_3.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "bioEn"),
                                                  controller: bioEnController,
                                                  obscureText: false,
                                                  lines: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h42_6.h),
                                            ],
                                          )
                                        : SizedBox(),
                                    french
                                        ? Column(
                                            children: [
                                              Container(
                                                width: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.w1085.w
                                                    : AppSize.w509.w,
                                                height: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppSize.h230.h
                                                    : AppSize.h153_3.h,
                                                child: TextFormFieldWidget(
                                                  keyboardType:
                                                      TextInputType.multiline,
                                                  labelFont: getTranslated(
                                                      context,
                                                      'NotoKufiArabic-SemiBold'),
                                                  font: getTranslated(context,
                                                      'NotoKufiArabic-Regular'),
                                                  name: getTranslated(
                                                      context, "bioFr"),
                                                  controller: bioFrController,
                                                  obscureText: false,
                                                  lines: 5,
                                                ),
                                              ),
                                              SizedBox(
                                                  height: (kIsWeb ||
                                                          size.width >=
                                                              AppConstants
                                                                  .kIsWebValue)
                                                      ? AppSize.h64_5.h
                                                      : AppSize.h42.h),
                                            ],
                                          )
                                        : SizedBox(),
                                  ],
                                ),

                          // tabbedText("lang", getTranslated(context, "languages"),
                          //     langController),

                          SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h48.h
                                  : 0),
                          //           Row(
                          //             mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          //             children: [
                          //               //SizedBox(),
                          //               //------
                          //               /*await showDialog(
                          //             barrierDismissible: false,
                          //             context: context,
                          //             builder: (context) {
                          //               return VideoDialog(
                          //                 consultUid: widget.user.uid!,
                          //               );
                          //             },
                          //           );
                          // //--------*/
                          //               getTitle(size, getTranslated(context, "bioLink")),
                          //               //     IconButton(
                          //               //         onPressed: selectFile,
                          //               //       icon: Icon(
                          //               //         Icons.video_call_outlined,
                          //               //         color: AppColors.pink,
                          //               //         size: AppSize.w32,
                          //               //       ),
                          //               //     ),
                          //               //   ],
                          //               // ),
                          //
                          //               IconButton(
                          //                 onPressed: () async {
                          //                   //------
                          //                   await showDialog(
                          //                     barrierDismissible: false,
                          //                     context: context,
                          //                     builder: (context) {
                          //                       return VideoDialog(
                          //                         consultUid: widget.user.uid!,
                          //                       );
                          //                     },
                          //                   );
                          //                   //--------
                          //                 },
                          //                 icon: Icon(
                          //                   Icons.video_call_outlined,
                          //                   color: AppColors.pink,
                          //                   size: 32.0,
                          //                 ),
                          //               ),
                          //             ],
                          //           ),
                          // SizedBox(height: AppPadding.p32.h,),
                          // Padding(
                          //   padding: EdgeInsets.only(
                          //       // top: (kIsWeb || size.width >= 500) ? 0 : 0,
                          //       // bottom: (kIsWeb || size.width >= 500) ? 40 : 0
                          //       ),
                          //   child: SizedBox(
                          //     height: 153.3.h,
                          //     child: Theme(
                          //       data: new ThemeData(
                          //         primaryColor: Colors.redAccent,
                          //         primaryColorDark: Colors.red,
                          //       ),
                          //       child: TextFormField(
                          //           style: TextStyle(
                          //             fontFamily: getTranslated(context, "Ithra"),
                          //             fontSize: (kIsWeb || size.width >= 500)
                          //                 ? 18.sp
                          //                 : 18.6.sp,
                          //             color: Colors.black.withOpacity(0.6),
                          //           ),
                          //           cursorColor: AppColors.pink,
                          //           initialValue: widget.user.link,
                          //           maxLines: 3,
                          //           keyboardType: TextInputType.multiline,
                          //           /* validator: (String? val) {
                          //             if (val!.trim().isEmpty) {
                          //               return getTranslated(context, 'required');
                          //             }
                          //             return null;
                          //           },*/
                          //           onSaved: (val) {
                          //             if (val!.trim().isEmpty)
                          //               widget.user.link = null;
                          //             else
                          //               widget.user.link = val;
                          //           },
                          //           enableInteractiveSelection: true,
                          //           decoration: inputDecoration("link")),
                          //     ),
                          //   ),
                          // ),

                          ///////////////////////////////////////////
                          //////////////////UPLOAD_VIDEO////////////////////

                          // Center(
                          //   child: InkWell(
                          //     onTap: () async {
                          //       if (kIsWeb) {
                          //         final snackBar = SnackBar(
                          //           content: Center(
                          //             child: Text(
                          //               getTranslated(context, "uploadMobOnly"),
                          //               style: TextStyle(
                          //                 color: AppColors.white,
                          //                 fontSize: AppFontsSizeManager.s21.sp,
                          //                 fontWeight: FontWeight.w600,
                          //               ),
                          //             ),
                          //           ),
                          //           backgroundColor: AppColors.linear1,
                          //         );
                          //         ScaffoldMessenger.of(context)
                          //             .showSnackBar(snackBar);
                          //       } else {
                          //         await FirebaseFirestore.instance
                          //             .collection(Paths.usersPath)
                          //             .doc(widget.user.uid)
                          //             .get()
                          //             .then((value) {
                          //           GroceryUser newUser = GroceryUser.fromMap(
                          //               value.data() as Map<dynamic, dynamic>);
                          //           widget.user = newUser;
                          //         });
                          //         selectFile();
                          //       }
                          //     },
                          //     child: Container(
                          //       width: (kIsWeb ||
                          //               size.width >= AppConstants.kIsWebValue)
                          //           ? AppSize.w650.w
                          //           : AppSize.w524.w,
                          //       height: (kIsWeb ||
                          //               size.width >= AppConstants.kIsWebValue)
                          //           ? AppSize.h105.h
                          //           : AppSize.h66_6.h,
                          //       decoration: BoxDecoration(
                          //           borderRadius: BorderRadius.circular((kIsWeb ||
                          //                   size.width >=
                          //                       AppConstants.kIsWebValue)
                          //               ? AppRadius.r22.r
                          //               : AppRadius.r12.r),
                          //           gradient: LinearGradient(
                          //             begin: Alignment.topCenter,
                          //             end: Alignment.bottomCenter,
                          //             colors: [
                          //               AppColors.linear1,
                          //               AppColors.linear2,
                          //               AppColors.linear2,
                          //             ],
                          //           )),
                          //       child: Center(
                          //         child: Text(
                          //           getTranslated(context, 'uploadVid'),
                          //           style: TextStyle(
                          //             fontFamily: getTranslated(context, "Ithra"),
                          //             color: AppColors.white,
                          //             fontSize: (kIsWeb ||
                          //                     size.width >=
                          //                         AppConstants.kIsWebValue)
                          //                 ? AppFontsSizeManager.s36.sp
                          //                 : AppFontsSizeManager.s21_3.sp,
                          //             letterSpacing:
                          //                 AppConstants.letterSpacing0_5,
                          //           ),
                          //         ),
                          //       ),
                          //     ),
                          //   ),
                          // ),

                          ///--->Upload Main Video<---///
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p18.w),
                            child: Row(
                              children: [
                                Text(
                                  getTranslated(context, "uploadMainVidTxt"),
                                  style: TextStyle(
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s32.sp
                                        : AppFontsSizeManager.s21_3.sp,
                                    fontFamily: getTranslated(
                                        context, "NotoKufiArabic-SemiBold"),
                                    color: AppColors.linear8,
                                  ),
                                ),
                                SizedBox(
                                  width: (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? AppSize.w500
                                      : 0,
                                ),
                                Text(
                                  (kIsWeb ||
                                          size.width >=
                                              AppConstants.kIsWebValue)
                                      ? getTranslated(
                                          context, "uploadSecondaryVidTxt")
                                      : "",
                                  style: TextStyle(
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s32.sp
                                        : AppFontsSizeManager.s21_3.sp,
                                    fontFamily: getTranslated(
                                        context, "NotoKufiArabic-SemiBold"),
                                    color: AppColors.linear8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h28.h
                                : AppSize.h21_3.h,
                          ),
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    (widget.user.link != null)
                                        ? Stack(
                                            children: [
                                              replaceVideo
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius
                                                                  .r10_6.r),
                                                      child: Container(
                                                        width: AppSize.w808.w,
                                                        height: AppSize.h386.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r24
                                                                          .r),
                                                        ),
                                                        child: AspectRatio(
                                                          aspectRatio:
                                                              replaceVidController!
                                                                  .value
                                                                  .aspectRatio,
                                                          child: VideoPlayer(
                                                              replaceVidController!),
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius
                                                                  .r10_6.r),
                                                      child: Container(
                                                        width: AppSize.w808.w,
                                                        height: AppSize.h386.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r24
                                                                          .r),
                                                        ),
                                                        child: !widget
                                                                .user.link!
                                                                .contains(
                                                                    'firebase')
                                                            ? VideoWidget(
                                                                link: widget
                                                                    .user.link!,
                                                                VideoAppid: widget
                                                                    .user.link!
                                                                    .toString()
                                                                    .substring(
                                                                        widget.user!.link.toString().indexOf("=") +
                                                                            1,
                                                                        widget
                                                                            .user!
                                                                            .link
                                                                            .toString()
                                                                            .length),
                                                              )
                                                            : videoPlayerController
                                                                    .value
                                                                    .isInitialized
                                                                ? InkWell(
                                                                    onTap: () {
                                                                      setState(
                                                                          () {
                                                                        videoPlayerController.value.isPlaying
                                                                            ? videoPlayerController.pause()
                                                                            : videoPlayerController.play();
                                                                      });
                                                                    },
                                                                    child:
                                                                        AspectRatio(
                                                                      aspectRatio: videoPlayerController
                                                                          .value
                                                                          .aspectRatio,
                                                                      child: VideoPlayer(
                                                                          videoPlayerController),
                                                                    ))
                                                                : Container(
                                                                    height: 200,
                                                                    color: AppColors
                                                                        .black,
                                                                    child:
                                                                        Center(
                                                                      child:
                                                                          CircularProgressIndicator(),
                                                                    ),
                                                                  ),
                                                      ),
                                                    ),
                                              // Container(
                                              //   color: AppColors.primaryColor,
                                              //   constraints: BoxConstraints(maxHeight: 300),
                                              //   child: videoPlayerController.value.isInitialized
                                              //       ? InkWell(
                                              //     onTap: () {
                                              //       setState(() {
                                              //         videoPlayerController.value.isPlaying
                                              //             ? videoPlayerController.pause()
                                              //             : videoPlayerController.play();
                                              //       });
                                              //     },
                                              //     child: AspectRatio(
                                              //       aspectRatio: videoPlayerController.value.aspectRatio,
                                              //       child: VideoPlayer(videoPlayerController),
                                              //     ),
                                              //   )
                                              //       : Container(
                                              //     height: 200,
                                              //     color: AppColors.white,
                                              //     child:  Center(
                                              //       child: Text(
                                              //         '',
                                              //         style: TextStyle(
                                              //           color: AppColors.black,
                                              //           fontSize: AppFontsSizeManager.s21.sp,
                                              //           fontWeight: FontWeight.w600,
                                              //         ),
                                              //       ),
                                              //     ),
                                              //   ),
                                              // ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppPadding.p10_6.r,
                                                    vertical:
                                                        AppPadding.p10_6.r),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      width: AppSize.w89.w,
                                                      height: AppSize.h42_6.h,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r5_3
                                                                        .r),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            AppPadding.p8.r),
                                                        child: Row(
                                                          children: [
                                                            InkWell(
                                                              child: SvgPicture
                                                                  .asset(
                                                                AssetsManager
                                                                    .editIconPath,
                                                                height: AppSize
                                                                    .h26_6.h,
                                                                width: AppSize
                                                                    .w30_6.w,
                                                              ),
                                                              onTap: () {
                                                                setState(() {
                                                                  _replaceVideo();

                                                                  replaceVideo =
                                                                      true;
                                                                });
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  AppSize.w8.w,
                                                            ),
                                                            InkWell(
                                                              child: SvgPicture
                                                                  .asset(
                                                                AssetsManager
                                                                    .delete1IconPath,
                                                                height: AppSize
                                                                    .h26_6.h,
                                                                width: AppSize
                                                                    .w30_6.w,
                                                              ),
                                                              onTap: () {
                                                                deleteVideo();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    _controller != null &&
                                            _controller!.value.isInitialized &&
                                            widget.user.link == null
                                        ? Stack(
                                            children: [
                                              replaceVideo
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius
                                                                  .r10_6.r),
                                                      child: Container(
                                                        width: AppSize.w509_3.w,
                                                        height:
                                                            AppSize.h162_6.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r13
                                                                          .r),
                                                        ),
                                                        child: AspectRatio(
                                                          aspectRatio:
                                                              replaceVidController!
                                                                  .value
                                                                  .aspectRatio,
                                                          child: VideoPlayer(
                                                              replaceVidController!),
                                                        ),
                                                      ),
                                                    )
                                                  : ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius
                                                                  .r10_6.r),
                                                      child: Container(
                                                        width: AppSize.w509_3.w,
                                                        height:
                                                            AppSize.h162_6.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r13
                                                                          .r),
                                                        ),
                                                        child: AspectRatio(
                                                          aspectRatio:
                                                              _controller!.value
                                                                  .aspectRatio,
                                                          child: VideoPlayer(
                                                              _controller!),
                                                        ),
                                                      ),
                                                    ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppPadding.p10_6.r,
                                                    vertical:
                                                        AppPadding.p10_6.r),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Container(
                                                      width: AppSize.w89.w,
                                                      height: AppSize.h42_6.h,
                                                      decoration: BoxDecoration(
                                                        color: AppColors.black,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r5_3
                                                                        .r),
                                                      ),
                                                      child: Padding(
                                                        padding: EdgeInsets.all(
                                                            AppPadding.p8.r),
                                                        child: Row(
                                                          children: [
                                                            InkWell(
                                                              child: SvgPicture
                                                                  .asset(
                                                                AssetsManager
                                                                    .editIconPath,
                                                                height: AppSize
                                                                    .h26_6.h,
                                                                width: AppSize
                                                                    .w30_6.w,
                                                              ),
                                                              onTap: () {
                                                                setState(() {
                                                                  _replaceVideo();

                                                                  replaceVideo =
                                                                      true;
                                                                });
                                                              },
                                                            ),
                                                            SizedBox(
                                                              width:
                                                                  AppSize.w8.w,
                                                            ),
                                                            InkWell(
                                                              child: SvgPicture
                                                                  .asset(
                                                                AssetsManager
                                                                    .delete1IconPath,
                                                                height: AppSize
                                                                    .h26_6.h,
                                                                width: AppSize
                                                                    .w30_6.w,
                                                              ),
                                                              onTap: () {
                                                                deleteVideo();
                                                              },
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    _controller == null &&
                                            widget.user.link == null
                                        ? Container(
                                            width: AppSize.w808.w,
                                            height: AppSize.h386.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.r24.r),
                                              border: Border.all(
                                                color: AppColors.grey2,
                                                width: AppSize.w0_5.w,
                                              ),
                                            ),
                                            child: Center(
                                              child: InkWell(
                                                onTap: () async {
                                                  if (kIsWeb) {
                                                    final snackBar = SnackBar(
                                                      content: Center(
                                                        child: Text(
                                                          getTranslated(context,
                                                              "uploadMobOnly"),
                                                          style: TextStyle(
                                                            color:
                                                                AppColors.white,
                                                            fontSize:
                                                                AppFontsSizeManager
                                                                    .s21.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          AppColors.linear1,
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  } else {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            Paths.usersPath)
                                                        .doc(widget.user.uid)
                                                        .get()
                                                        .then((value) {
                                                      GroceryUser newUser =
                                                          GroceryUser.fromMap(
                                                              value.data()
                                                                  as Map<
                                                                      dynamic,
                                                                      dynamic>);
                                                      widget.user = newUser;
                                                    });
                                                    _pickVideo();
                                                    print("video>>>${video}");
                                                  }
                                                },
                                                child: SvgPicture.asset(
                                                  AssetsManager.video1IconPath,
                                                  width: AppSize.w36.w,
                                                  height: AppSize.h36.h,
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      height: AppSize.h21_3.h,
                                    ),

                                    ///--->Upload Secondary Video<---///

                                    //if(widget.user.link!=null)
                                    Column(
                                      children: [
                                        Row(
                                          children: [
                                            (widget.consultVideo.link != null)
                                                ? Stack(
                                                    children: [
                                                      _replaceFirstVideo
                                                          ? Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    replaceFirstVidController!
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    replaceFirstVidController!),
                                                              ),
                                                            )
                                                          : Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child: !widget
                                                                      .consultVideo
                                                                      .link!
                                                                      .contains(
                                                                          'firebase')
                                                                  ? Container(
                                                                      width: AppSize
                                                                          .w244
                                                                          .r,
                                                                      height: AppSize
                                                                          .h244
                                                                          .r,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                      ),
                                                                      child:
                                                                          VideoWidget(
                                                                        link: widget
                                                                            .consultVideo
                                                                            .link!,
                                                                        VideoAppid: widget
                                                                            .consultVideo
                                                                            .link!
                                                                            .toString()
                                                                            .substring(widget.consultVideo.link.toString().indexOf("=") + 1,
                                                                                widget.consultVideo.link.toString().length),
                                                                      ),
                                                                    )
                                                                  : videoPlayerController
                                                                          .value
                                                                          .isInitialized
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              videoPlayerController.value.isPlaying ? videoPlayerController.pause() : videoPlayerController.play();
                                                                            });
                                                                          },
                                                                          child:
                                                                              AspectRatio(
                                                                            aspectRatio:
                                                                                videoPlayerController.value.aspectRatio,
                                                                            child:
                                                                                VideoPlayer(videoPlayerController),
                                                                          ))
                                                                      : Container(
                                                                          height:
                                                                              200,
                                                                          color:
                                                                              AppColors.white,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          ),
                                                                        ),
                                                            ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r,
                                                                vertical:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  AppSize.w89.w,
                                                              height: AppSize
                                                                  .h42_6.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r5_3
                                                                            .r),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        AppPadding
                                                                            .p8
                                                                            .r),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .editIconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        replaceFirstVideo();
                                                                        setState(
                                                                            () {
                                                                          _replaceFirstVideo =
                                                                              true;
                                                                        });
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          AppSize
                                                                              .w8
                                                                              .w,
                                                                    ),
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .delete1IconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        deleteVideo();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            firstVidController != null &&
                                                    firstVidController!
                                                        .value.isInitialized &&
                                                    widget.consultVideo.link ==
                                                        null
                                                ? Stack(
                                                    children: [
                                                      _replaceFirstVideo
                                                          ? Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    replaceFirstVidController!
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    replaceFirstVidController!),
                                                              ),
                                                            )
                                                          : Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    firstVidController!
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    firstVidController!),
                                                              ),
                                                            ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r,
                                                                vertical:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  AppSize.w89.w,
                                                              height: AppSize
                                                                  .h42_6.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r5_3
                                                                            .r),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        AppPadding
                                                                            .p8
                                                                            .r),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .editIconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        replaceFirstVideo();
                                                                        setState(
                                                                            () {
                                                                          _replaceFirstVideo =
                                                                              true;
                                                                        });
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          AppSize
                                                                              .w8
                                                                              .w,
                                                                    ),
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .delete1IconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        deleteVideo();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            firstVidController == null &&
                                                    widget.consultVideo.link ==
                                                        null
                                                ? Container(
                                                    width: AppSize.w394.w,
                                                    height: AppSize.h386.h,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.r13.r),
                                                      border: Border.all(
                                                        color: AppColors.grey2,
                                                        width: AppSize.w0_5.w,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () async {
                                                          if (kIsWeb) {
                                                            final snackBar =
                                                                SnackBar(
                                                              content: Center(
                                                                child: Text(
                                                                  getTranslated(
                                                                      context,
                                                                      "uploadMobOnly"),
                                                                  style:
                                                                      TextStyle(
                                                                    color: AppColors
                                                                        .white,
                                                                    fontSize:
                                                                        AppFontsSizeManager
                                                                            .s21
                                                                            .sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .linear1,
                                                            );
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(Paths
                                                                    .usersPath)
                                                                .doc(widget
                                                                    .user.uid)
                                                                .get()
                                                                .then((value) {
                                                              GroceryUser
                                                                  newUser =
                                                                  GroceryUser.fromMap(value
                                                                          .data()
                                                                      as Map<
                                                                          dynamic,
                                                                          dynamic>);
                                                              widget.user =
                                                                  newUser;
                                                            });
                                                            pickFirstVideo();
                                                            print(
                                                                "video>>>${video}");
                                                          }
                                                        },
                                                        child: SvgPicture.asset(
                                                          AssetsManager
                                                              .video1IconPath,
                                                          width: AppSize.w36.w,
                                                          height: AppSize.h36.h,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                            SizedBox(
                                              width: AppSize.w21_3.w,
                                            ),
                                            (widget.consultVideo.link != null)
                                                ? Stack(
                                                    children: [
                                                      _replaceSecondVideo
                                                          ? Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    replaceSecondVidController!
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    replaceSecondVidController!),
                                                              ),
                                                            )
                                                          : Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child: !widget
                                                                      .consultVideo
                                                                      .link!
                                                                      .contains(
                                                                          'firebase')
                                                                  ? Container(
                                                                      width: AppSize
                                                                          .w509_3
                                                                          .w,
                                                                      height: AppSize
                                                                          .h162_6
                                                                          .h,
                                                                      decoration:
                                                                          BoxDecoration(
                                                                        borderRadius: BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                      ),
                                                                      child:
                                                                          VideoWidget(
                                                                        link: widget
                                                                            .consultVideo
                                                                            .link!,
                                                                        VideoAppid: widget
                                                                            .consultVideo
                                                                            .link!
                                                                            .toString()
                                                                            .substring(widget.consultVideo.link.toString().indexOf("=") + 1,
                                                                                widget.consultVideo.link.toString().length),
                                                                      ),
                                                                    )
                                                                  : videoPlayerController
                                                                          .value
                                                                          .isInitialized
                                                                      ? InkWell(
                                                                          onTap:
                                                                              () {
                                                                            setState(() {
                                                                              videoPlayerController.value.isPlaying ? videoPlayerController.pause() : videoPlayerController.play();
                                                                            });
                                                                          },
                                                                          child:
                                                                              AspectRatio(
                                                                            aspectRatio:
                                                                                videoPlayerController.value.aspectRatio,
                                                                            child:
                                                                                VideoPlayer(videoPlayerController),
                                                                          ))
                                                                      : Container(
                                                                          height:
                                                                              200,
                                                                          color:
                                                                              AppColors.white,
                                                                          child:
                                                                              Center(
                                                                            child:
                                                                                CircularProgressIndicator(),
                                                                          ),
                                                                        ),
                                                            ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r,
                                                                vertical:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  AppSize.w89.w,
                                                              height: AppSize
                                                                  .h42_6.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r5_3
                                                                            .r),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        AppPadding
                                                                            .p8
                                                                            .r),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .editIconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        replaceSecondVideo();
                                                                        setState(
                                                                            () {
                                                                          _replaceSecondVideo =
                                                                              true;
                                                                        });
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          AppSize
                                                                              .w8
                                                                              .w,
                                                                    ),
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .delete1IconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        deleteVideo();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            secondVidController != null &&
                                                    secondVidController!
                                                        .value.isInitialized &&
                                                    widget.consultVideo.link ==
                                                        null
                                                ? Stack(
                                                    children: [
                                                      _replaceSecondVideo
                                                          ? Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    replaceSecondVidController!
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    replaceSecondVidController!),
                                                              ),
                                                            )
                                                          : Container(
                                                              width: AppSize
                                                                  .w244.r,
                                                              height: AppSize
                                                                  .h244.r,
                                                              decoration:
                                                                  BoxDecoration(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                              ),
                                                              child:
                                                                  AspectRatio(
                                                                aspectRatio:
                                                                    secondVidController!
                                                                        .value
                                                                        .aspectRatio,
                                                                child: VideoPlayer(
                                                                    secondVidController!),
                                                              ),
                                                            ),
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r,
                                                                vertical:
                                                                    AppPadding
                                                                        .p10_6
                                                                        .r),
                                                        child: Row(
                                                          mainAxisAlignment:
                                                              MainAxisAlignment
                                                                  .end,
                                                          children: [
                                                            Container(
                                                              width:
                                                                  AppSize.w89.w,
                                                              height: AppSize
                                                                  .h42_6.h,
                                                              decoration:
                                                                  BoxDecoration(
                                                                color: AppColors
                                                                    .black,
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r5_3
                                                                            .r),
                                                              ),
                                                              child: Padding(
                                                                padding:
                                                                    EdgeInsets.all(
                                                                        AppPadding
                                                                            .p8
                                                                            .r),
                                                                child: Row(
                                                                  children: [
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .editIconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        replaceSecondVideo();
                                                                        setState(
                                                                            () {
                                                                          _replaceSecondVideo =
                                                                              true;
                                                                        });
                                                                      },
                                                                    ),
                                                                    SizedBox(
                                                                      width:
                                                                          AppSize
                                                                              .w8
                                                                              .w,
                                                                    ),
                                                                    InkWell(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .delete1IconPath,
                                                                        height: AppSize
                                                                            .h26_6
                                                                            .h,
                                                                        width: AppSize
                                                                            .w30_6
                                                                            .w,
                                                                      ),
                                                                      onTap:
                                                                          () {
                                                                        deleteVideo();
                                                                      },
                                                                    ),
                                                                  ],
                                                                ),
                                                              ),
                                                            ),
                                                          ],
                                                        ),
                                                      ),
                                                    ],
                                                  )
                                                : SizedBox(),
                                            secondVidController == null &&
                                                    widget.consultVideo.link ==
                                                        null
                                                ? Container(
                                                    width: AppSize.w394.w,
                                                    height: AppSize.h386.h,
                                                    decoration: BoxDecoration(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius.r13.r),
                                                      border: Border.all(
                                                        color: AppColors.grey2,
                                                        width: AppSize.w0_5.w,
                                                      ),
                                                    ),
                                                    child: Center(
                                                      child: InkWell(
                                                        onTap: () async {
                                                          if (kIsWeb) {
                                                            final snackBar =
                                                                SnackBar(
                                                              content: Center(
                                                                child: Text(
                                                                  getTranslated(
                                                                      context,
                                                                      "uploadMobOnly"),
                                                                  style:
                                                                      TextStyle(
                                                                    color: AppColors
                                                                        .white,
                                                                    fontSize:
                                                                        AppFontsSizeManager
                                                                            .s21
                                                                            .sp,
                                                                    fontWeight:
                                                                        FontWeight
                                                                            .w600,
                                                                  ),
                                                                ),
                                                              ),
                                                              backgroundColor:
                                                                  AppColors
                                                                      .linear1,
                                                            );
                                                            ScaffoldMessenger
                                                                    .of(context)
                                                                .showSnackBar(
                                                                    snackBar);
                                                          } else {
                                                            await FirebaseFirestore
                                                                .instance
                                                                .collection(Paths
                                                                    .usersPath)
                                                                .doc(widget
                                                                    .user.uid)
                                                                .get()
                                                                .then((value) {
                                                              GroceryUser
                                                                  newUser =
                                                                  GroceryUser.fromMap(value
                                                                          .data()
                                                                      as Map<
                                                                          dynamic,
                                                                          dynamic>);
                                                              widget.user =
                                                                  newUser;
                                                            });
                                                            pickSecondVideo();
                                                            print(
                                                                "video>>>${video}");
                                                          }
                                                        },
                                                        child: SvgPicture.asset(
                                                          AssetsManager
                                                              .video1IconPath,
                                                          width: AppSize.w36.w,
                                                          height: AppSize.h36.h,
                                                        ),
                                                      ),
                                                    ),
                                                  )
                                                : SizedBox(),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ],
                                )
                              : Column(
                                  children: [
                                    (widget.user.link != null)
                                        ? Stack(
                                            children: [
                                              VideoCubit.get(context)
                                                      .replaceVideo
                                                  ? ClipRRect(
                                                      borderRadius:
                                                          BorderRadius.circular(
                                                              AppRadius
                                                                  .r10_6.r),
                                                      child: Container(
                                                        width: AppSize.w509_3.w,
                                                        height:
                                                            AppSize.h162_6.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r13
                                                                          .r),
                                                        ),
                                                        child: VideoCubit.get(
                                                                        context)
                                                                    .replaceVidController ==
                                                                null
                                                            ? Center(
                                                                heightFactor: 1,
                                                                widthFactor: 1,
                                                                child: SizedBox(
                                                                  width: 16,
                                                                  height: 16,
                                                                  child:
                                                                      CircularProgressIndicator(
                                                                    color: AppColors
                                                                        .primaryColor,
                                                                  ),
                                                                ),
                                                              )
                                                            : AspectRatio(
                                                                aspectRatio: VideoCubit
                                                                        .get(
                                                                            context)
                                                                    .replaceVidController!
                                                                    .value
                                                                    .aspectRatio,
                                                                child: VideoPlayer(
                                                                    VideoCubit.get(
                                                                            context)
                                                                        .replaceVidController!),
                                                              ),
                                                      ),
                                                    )
                                                  : Padding(
                                                      padding: EdgeInsets.only(
                                                          right:
                                                              AppPadding.p16.w,
                                                          left:
                                                              AppPadding.p6.w),
                                                      child: InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            videoPlayerController
                                                                    .value
                                                                    .isPlaying
                                                                ? videoPlayerController
                                                                    .pause()
                                                                : videoPlayerController
                                                                    .play();
                                                          });
                                                        },
                                                        child: ClipRRect(
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r13
                                                                          .r),
                                                          child: Container(
                                                            width: AppSize
                                                                .w509_3.w,
                                                            height: AppSize
                                                                .h162_6.h,
                                                            decoration:
                                                                BoxDecoration(
                                                              borderRadius:
                                                                  BorderRadius
                                                                      .circular(
                                                                          AppRadius
                                                                              .r13
                                                                              .r),
                                                            ),
                                                            child: !widget
                                                                    .user.link!
                                                                    .contains(
                                                                        'firebase')
                                                                ? Container(
                                                                    height:
                                                                        162.h,
                                                                    child:
                                                                        VideoWidget(
                                                                      link: widget
                                                                          .user
                                                                          .link!,
                                                                      VideoAppid: widget
                                                                          .user
                                                                          .link!
                                                                          .toString()
                                                                          .substring(
                                                                              widget.user!.link.toString().indexOf("=") + 1,
                                                                              widget.user!.link.toString().length),
                                                                    ),
                                                                  )
                                                                : videoPlayerController
                                                                        .value
                                                                        .isInitialized
                                                                    ? InkWell(
                                                                        onTap:
                                                                            () {
                                                                          setState(
                                                                              () {
                                                                            videoPlayerController.value.isPlaying
                                                                                ? videoPlayerController.pause()
                                                                                : videoPlayerController.play();
                                                                          });
                                                                        },
                                                                        child:
                                                                            AspectRatio(
                                                                          aspectRatio: videoPlayerController
                                                                              .value
                                                                              .aspectRatio,
                                                                          child:
                                                                              VideoPlayer(videoPlayerController),
                                                                        ))
                                                                    : Container(
                                                                        height:
                                                                            200,
                                                                        color: AppColors
                                                                            .black,
                                                                        child:
                                                                            Center(
                                                                          child:
                                                                              CircularProgressIndicator(),
                                                                        ),
                                                                      ),
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                              Padding(
                                                padding: EdgeInsets.symmetric(
                                                    horizontal:
                                                        AppPadding.p10_6.r,
                                                    vertical:
                                                        AppPadding.p10_6.r),
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment.end,
                                                  children: [
                                                    Padding(
                                                      padding:
                                                          EdgeInsets.symmetric(
                                                              horizontal:
                                                                  AppPadding
                                                                      .p12.w),
                                                      child: Container(
                                                        width: AppSize.w89.w,
                                                        height: AppSize.h42_6.h,
                                                        decoration:
                                                            BoxDecoration(
                                                          color:
                                                              AppColors.white,
                                                          borderRadius:
                                                              BorderRadius
                                                                  .circular(
                                                                      AppRadius
                                                                          .r5_3
                                                                          .r),
                                                        ),
                                                        child: Padding(
                                                          padding:
                                                              EdgeInsets.all(
                                                                  AppPadding
                                                                      .p8.r),
                                                          child: Row(
                                                            children: [
                                                              InkWell(
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  AssetsManager
                                                                      .editIconPath,
                                                                  height:
                                                                      AppSize
                                                                          .h26_6
                                                                          .h,
                                                                  width: AppSize
                                                                      .w30_6.w,
                                                                ),
                                                                onTap: () {
                                                                  _replaceVideo();
                                                                },
                                                              ),
                                                              SizedBox(
                                                                width: AppSize
                                                                    .w8.w,
                                                              ),
                                                              InkWell(
                                                                child:
                                                                    SvgPicture
                                                                        .asset(
                                                                  AssetsManager
                                                                      .delete1IconPath,
                                                                  height:
                                                                      AppSize
                                                                          .h26_6
                                                                          .h,
                                                                  width: AppSize
                                                                      .w30_6.w,
                                                                ),
                                                                onTap: () {
                                                                  deleteVideo();
                                                                },
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    ),
                                                  ],
                                                ),
                                              ),
                                            ],
                                          )
                                        : SizedBox(),
                                    _controller != null &&
                                            _controller!.value.isInitialized &&
                                            widget.user.link == null
                                        ? Padding(
                                            padding: EdgeInsets.only(
                                                right: AppPadding.p12.w),
                                            child: Stack(
                                              children: [
                                                replaceVideo
                                                    ? ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r10_6
                                                                        .r),
                                                        child: Container(
                                                          width:
                                                              AppSize.w509_3.w,
                                                          height:
                                                              AppSize.h162_6.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                          ),
                                                          child:
                                                              replaceVidController ==
                                                                      null
                                                                  ? Center(
                                                                      heightFactor:
                                                                          1,
                                                                      widthFactor:
                                                                          1,
                                                                      child:
                                                                          SizedBox(
                                                                        width:
                                                                            16,
                                                                        height:
                                                                            16,
                                                                        child:
                                                                            CircularProgressIndicator(
                                                                          color:
                                                                              AppColors.primaryColor,
                                                                        ),
                                                                      ),
                                                                    )
                                                                  : AspectRatio(
                                                                      aspectRatio: replaceVidController!
                                                                          .value
                                                                          .aspectRatio,
                                                                      child: VideoPlayer(
                                                                          replaceVidController!),
                                                                    ),
                                                        ),
                                                      )
                                                    : ClipRRect(
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r10_6
                                                                        .r),
                                                        child: Container(
                                                          width:
                                                              AppSize.w509_3.w,
                                                          height:
                                                              AppSize.h162_6.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                          ),
                                                          child: AspectRatio(
                                                            aspectRatio:
                                                                _controller!
                                                                    .value
                                                                    .aspectRatio,
                                                            child: VideoPlayer(
                                                                _controller!),
                                                          ),
                                                        ),
                                                      ),
                                                Padding(
                                                  padding: EdgeInsets.symmetric(
                                                      horizontal:
                                                          AppPadding.p10_6.r,
                                                      vertical:
                                                          AppPadding.p10_6.r),
                                                  child: Row(
                                                    mainAxisAlignment:
                                                        MainAxisAlignment.end,
                                                    children: [
                                                      Padding(
                                                        padding: EdgeInsets
                                                            .symmetric(
                                                                horizontal:
                                                                    AppPadding
                                                                        .p16.w),
                                                        child: Container(
                                                          width: AppSize.w89.w,
                                                          height:
                                                              AppSize.h42_6.h,
                                                          decoration:
                                                              BoxDecoration(
                                                            color:
                                                                AppColors.white,
                                                            borderRadius:
                                                                BorderRadius
                                                                    .circular(
                                                                        AppRadius
                                                                            .r5_3
                                                                            .r),
                                                          ),
                                                          child: Padding(
                                                            padding:
                                                                EdgeInsets.all(
                                                                    AppPadding
                                                                        .p8.r),
                                                            child: Row(
                                                              children: [
                                                                InkWell(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AssetsManager
                                                                        .editIconPath,
                                                                    height:
                                                                        AppSize
                                                                            .h26_6
                                                                            .h,
                                                                    width: AppSize
                                                                        .w30_6
                                                                        .w,
                                                                  ),
                                                                  onTap: () {
                                                                    setState(
                                                                        () {
                                                                      _replaceVideo();

                                                                      replaceVideo =
                                                                          true;
                                                                    });
                                                                  },
                                                                ),
                                                                SizedBox(
                                                                  width: AppSize
                                                                      .w8.w,
                                                                ),
                                                                InkWell(
                                                                  child:
                                                                      SvgPicture
                                                                          .asset(
                                                                    AssetsManager
                                                                        .delete1IconPath,
                                                                    height:
                                                                        AppSize
                                                                            .h26_6
                                                                            .h,
                                                                    width: AppSize
                                                                        .w30_6
                                                                        .w,
                                                                  ),
                                                                  onTap: () {
                                                                    deleteVideo();
                                                                  },
                                                                ),
                                                              ],
                                                            ),
                                                          ),
                                                        ),
                                                      ),
                                                    ],
                                                  ),
                                                ),
                                              ],
                                            ),
                                          )
                                        : SizedBox(),
                                    _controller == null &&
                                            widget.user.link == null
                                        ? Container(
                                            width: AppSize.w509_3.w,
                                            height: AppSize.h162_6.h,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(
                                                      AppRadius.r13.r),
                                              border: Border.all(
                                                color: AppColors.grey2,
                                                width: AppSize.w0_5.w,
                                              ),
                                            ),
                                            child: Center(
                                              child: InkWell(
                                                onTap: () async {
                                                  if (kIsWeb) {
                                                    final snackBar = SnackBar(
                                                      content: Center(
                                                        child: Text(
                                                          getTranslated(context,
                                                              "uploadMobOnly"),
                                                          style: TextStyle(
                                                            color:
                                                                AppColors.white,
                                                            fontSize:
                                                                AppFontsSizeManager
                                                                    .s21.sp,
                                                            fontWeight:
                                                                FontWeight.w600,
                                                          ),
                                                        ),
                                                      ),
                                                      backgroundColor:
                                                          AppColors.linear1,
                                                    );
                                                    ScaffoldMessenger.of(
                                                            context)
                                                        .showSnackBar(snackBar);
                                                  } else {
                                                    await FirebaseFirestore
                                                        .instance
                                                        .collection(
                                                            Paths.usersPath)
                                                        .doc(widget.user.uid)
                                                        .get()
                                                        .then((value) {
                                                      GroceryUser newUser =
                                                          GroceryUser.fromMap(
                                                              value.data()
                                                                  as Map<
                                                                      dynamic,
                                                                      dynamic>);
                                                      widget.user = newUser;
                                                    });
                                                    _pickVideo();
                                                    print("video>>>${video}");
                                                  }
                                                },
                                                child: SvgPicture.asset(
                                                  AssetsManager.video1IconPath,
                                                  width: AppSize.w36.w,
                                                  height: AppSize.h36.h,
                                                ),
                                              ),
                                            ),
                                          )
                                        : SizedBox(),
                                    SizedBox(
                                      height: AppSize.h21_3.h,
                                    ),

                                    ///--->Upload Secondary Video<---///

                                    Column(
                                      children: [
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: AppPadding.p18.w),
                                          child: Row(
                                            children: [
                                              Text(
                                                getTranslated(context,
                                                    "uploadSecondaryVidTxt"),
                                                style: TextStyle(
                                                  fontSize: AppFontsSizeManager
                                                      .s21_3.sp,
                                                  fontFamily: getTranslated(
                                                      context,
                                                      "NotoKufiArabic-SemiBold"),
                                                  color: AppColors.linear8,
                                                ),
                                              ),
                                            ],
                                          ),
                                        ),
                                        SizedBox(
                                          height: AppSize.h21_3.h,
                                        ),
                                        Padding(
                                          padding: EdgeInsets.symmetric(
                                              horizontal: AppPadding.p12.w),
                                          child: Row(
                                            children: [
                                              (vidLinks.isNotEmpty)
                                                  ? Stack(
                                                      children: [
                                                        _replaceFirstVideo
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r10_6
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.r,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                  ),
                                                                  child: replaceFirstVidController ==
                                                                          null
                                                                      ? Center(
                                                                          heightFactor:
                                                                              1,
                                                                          widthFactor:
                                                                              1,
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                16,
                                                                            height:
                                                                                16,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              color: AppColors.primaryColor,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : AspectRatio(
                                                                          aspectRatio: replaceFirstVidController!
                                                                              .value
                                                                              .aspectRatio,
                                                                          child:
                                                                              VideoPlayer(replaceFirstVidController!),
                                                                        ),
                                                                ),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.w,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  child: vidLinks
                                                                          .isNotEmpty
                                                                      ? vidLinks[0]
                                                                              .contains('firebase')
                                                                          ? FirebaseVideoPlayerWidget(
                                                                              vidLinks[0].toString(),
                                                                            )
                                                                          : SizedBox(
                                                                              height: AppSize.h244.h,
                                                                              child: VideoWidget(
                                                                                link: vidLinks[0].toString(),
                                                                                VideoAppid: vidLinks[0].toString().substring(vidLinks[0].toString().indexOf("=") + 1, vidLinks[0].toString().length),
                                                                              ),
                                                                            )
                                                                      : SizedBox(),
                                                                ),
                                                              ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r,
                                                                  vertical:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                width: AppSize
                                                                    .w89.w,
                                                                height: AppSize
                                                                    .h42_6.h,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppRadius
                                                                              .r5_3
                                                                              .r),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(
                                                                      AppPadding
                                                                          .p8
                                                                          .r),
                                                                  child: Row(
                                                                    children: [
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .editIconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          replaceFirstVideo();
                                                                          setState(
                                                                              () {
                                                                            _replaceFirstVideo =
                                                                                true;
                                                                          });
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width: AppSize
                                                                            .w8
                                                                            .w,
                                                                      ),
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .delete1IconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          deleteFirstVideo();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                              firstVidController != null &&
                                                      firstVidController!.value
                                                          .isInitialized &&
                                                      vidLinks.isEmpty
                                                  ? Stack(
                                                      children: [
                                                        _replaceFirstVideo
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r10_6
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.r,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                  ),
                                                                  child:
                                                                      AspectRatio(
                                                                    aspectRatio:
                                                                        replaceFirstVidController!
                                                                            .value
                                                                            .aspectRatio,
                                                                    child: VideoPlayer(
                                                                        replaceFirstVidController!),
                                                                  ),
                                                                ),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r10_6
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.r,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                  ),
                                                                  child:
                                                                      AspectRatio(
                                                                    aspectRatio:
                                                                        firstVidController!
                                                                            .value
                                                                            .aspectRatio,
                                                                    child: VideoPlayer(
                                                                        firstVidController!),
                                                                  ),
                                                                ),
                                                              ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r,
                                                                  vertical:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                width: AppSize
                                                                    .w89.w,
                                                                height: AppSize
                                                                    .h42_6.h,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppRadius
                                                                              .r5_3
                                                                              .r),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(
                                                                      AppPadding
                                                                          .p8
                                                                          .r),
                                                                  child: Row(
                                                                    children: [
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .editIconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          replaceFirstVideo();
                                                                          setState(
                                                                              () {
                                                                            _replaceFirstVideo =
                                                                                true;
                                                                          });
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width: AppSize
                                                                            .w8
                                                                            .w,
                                                                      ),
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .delete1IconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          deleteFirstVideo();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                              firstVidController == null &&
                                                      vidLinks.isEmpty
                                                  ? Container(
                                                      width: AppSize.w244.r,
                                                      height: AppSize.h244.r,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            widget.user.link ==
                                                                    null
                                                                ? AppColors
                                                                    .buttonBack
                                                                : AppColors
                                                                    .white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r13.r),
                                                        border: Border.all(
                                                          color:
                                                              AppColors.grey2,
                                                          width: AppSize.w0_5.w,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: InkWell(
                                                          onTap: widget.user
                                                                      .link !=
                                                                  null
                                                              ? () async {
                                                                  if (kIsWeb) {
                                                                    final snackBar =
                                                                        SnackBar(
                                                                      content:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          getTranslated(
                                                                              context,
                                                                              "uploadMobOnly"),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AppColors.white,
                                                                            fontSize:
                                                                                AppFontsSizeManager.s21.sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .linear1,
                                                                    );
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                            snackBar);
                                                                  } else {
                                                                    pickFirstVideo();
                                                                    print(
                                                                        "video>>>${video}");
                                                                  }
                                                                }
                                                              : null,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              widget.user.link ==
                                                                          null &&
                                                                      vidLinks
                                                                          .isEmpty
                                                                  ? Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .video1IconPath,
                                                                          width: AppSize
                                                                              .w36
                                                                              .w,
                                                                          height: AppSize
                                                                              .h36
                                                                              .h,
                                                                        ),
                                                                        SizedBox(
                                                                          height: AppSize
                                                                              .h13_3
                                                                              .h,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: AppPadding.p13_3.w),
                                                                          child:
                                                                              Text(
                                                                            getTranslated(context,
                                                                                'uploadTxt'),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: AppColors.grey1,
                                                                              fontSize: AppFontsSizeManager.s18.sp,
                                                                              fontFamily: getTranslated(context, "NotoKufiArabic-Regular"),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Center(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .video1IconPath,
                                                                        width: AppSize
                                                                            .w36
                                                                            .w,
                                                                        height: AppSize
                                                                            .h36
                                                                            .h,
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),

                                              //
                                              SizedBox(
                                                width: AppSize.w21_3.w,
                                              ),
                                              //

                                              vidLinks.length > 1
                                                  ? Stack(
                                                      children: [
                                                        _replaceSecondVideo
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r10_6
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.r,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                  ),
                                                                  child: replaceSecondVidController ==
                                                                          null
                                                                      ? Center(
                                                                          heightFactor:
                                                                              1,
                                                                          widthFactor:
                                                                              1,
                                                                          child:
                                                                              SizedBox(
                                                                            width:
                                                                                16,
                                                                            height:
                                                                                16,
                                                                            child:
                                                                                CircularProgressIndicator(
                                                                              color: AppColors.primaryColor,
                                                                            ),
                                                                          ),
                                                                        )
                                                                      : AspectRatio(
                                                                          aspectRatio: replaceSecondVidController!
                                                                              .value
                                                                              .aspectRatio,
                                                                          child:
                                                                              VideoPlayer(replaceSecondVidController!),
                                                                        ),
                                                                ),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r13
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.w,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  child: vidLinks
                                                                          .isNotEmpty
                                                                      ? vidLinks[1]
                                                                              .contains('firebase')
                                                                          ? FirebaseVideoPlayerWidget(
                                                                              vidLinks[1].toString(),
                                                                            )
                                                                          : SizedBox(
                                                                              height: AppSize.h244.h,
                                                                              child: VideoWidget(
                                                                                link: vidLinks[1].toString(),
                                                                                VideoAppid: vidLinks[1].toString().substring(vidLinks[1].toString().indexOf("=") + 1, vidLinks[1].toString().length),
                                                                              ),
                                                                            )
                                                                      : SizedBox(),
                                                                ),
                                                              ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r,
                                                                  vertical:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                width: AppSize
                                                                    .w89.w,
                                                                height: AppSize
                                                                    .h42_6.h,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppRadius
                                                                              .r5_3
                                                                              .r),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(
                                                                      AppPadding
                                                                          .p8
                                                                          .r),
                                                                  child: Row(
                                                                    children: [
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .editIconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          replaceSecondVideo();
                                                                          setState(
                                                                              () {
                                                                            _replaceSecondVideo =
                                                                                true;
                                                                          });
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width: AppSize
                                                                            .w8
                                                                            .w,
                                                                      ),
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .delete1IconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          deleteSecondVideo();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                              secondVidController != null &&
                                                          secondVidController!
                                                              .value
                                                              .isInitialized &&
                                                          vidLinks.isEmpty ||
                                                      secondVidController !=
                                                              null &&
                                                          secondVidController!
                                                              .value
                                                              .isInitialized &&
                                                          vidLinks.length > 0
                                                  ? Stack(
                                                      children: [
                                                        _replaceSecondVideo
                                                            ? ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r10_6
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.r,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                  ),
                                                                  child:
                                                                      AspectRatio(
                                                                    aspectRatio:
                                                                        replaceSecondVidController!
                                                                            .value
                                                                            .aspectRatio,
                                                                    child: VideoPlayer(
                                                                        replaceSecondVidController!),
                                                                  ),
                                                                ),
                                                              )
                                                            : ClipRRect(
                                                                borderRadius:
                                                                    BorderRadius.circular(
                                                                        AppRadius
                                                                            .r10_6
                                                                            .r),
                                                                child:
                                                                    Container(
                                                                  width: AppSize
                                                                      .w244.r,
                                                                  height:
                                                                      AppSize
                                                                          .h244
                                                                          .r,
                                                                  decoration:
                                                                      BoxDecoration(
                                                                    borderRadius:
                                                                        BorderRadius.circular(AppRadius
                                                                            .r13
                                                                            .r),
                                                                  ),
                                                                  child:
                                                                      AspectRatio(
                                                                    aspectRatio:
                                                                        secondVidController!
                                                                            .value
                                                                            .aspectRatio,
                                                                    child: VideoPlayer(
                                                                        secondVidController!),
                                                                  ),
                                                                ),
                                                              ),
                                                        Padding(
                                                          padding: EdgeInsets
                                                              .symmetric(
                                                                  horizontal:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r,
                                                                  vertical:
                                                                      AppPadding
                                                                          .p10_6
                                                                          .r),
                                                          child: Row(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .end,
                                                            children: [
                                                              Container(
                                                                width: AppSize
                                                                    .w89.w,
                                                                height: AppSize
                                                                    .h42_6.h,
                                                                decoration:
                                                                    BoxDecoration(
                                                                  color:
                                                                      AppColors
                                                                          .white,
                                                                  borderRadius:
                                                                      BorderRadius.circular(
                                                                          AppRadius
                                                                              .r5_3
                                                                              .r),
                                                                ),
                                                                child: Padding(
                                                                  padding: EdgeInsets.all(
                                                                      AppPadding
                                                                          .p8
                                                                          .r),
                                                                  child: Row(
                                                                    children: [
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .editIconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          replaceSecondVideo();
                                                                          setState(
                                                                              () {
                                                                            _replaceSecondVideo =
                                                                                true;
                                                                          });
                                                                        },
                                                                      ),
                                                                      SizedBox(
                                                                        width: AppSize
                                                                            .w8
                                                                            .w,
                                                                      ),
                                                                      InkWell(
                                                                        child: SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .delete1IconPath,
                                                                          height: AppSize
                                                                              .h26_6
                                                                              .h,
                                                                          width: AppSize
                                                                              .w30_6
                                                                              .w,
                                                                        ),
                                                                        onTap:
                                                                            () {
                                                                          deleteSecondVideo();
                                                                        },
                                                                      ),
                                                                    ],
                                                                  ),
                                                                ),
                                                              ),
                                                            ],
                                                          ),
                                                        ),
                                                      ],
                                                    )
                                                  : SizedBox(),
                                              secondVidController == null &&
                                                          vidLinks.isEmpty ||
                                                      secondVidController ==
                                                              null &&
                                                          vidLinks.length > 0
                                                  ? Container(
                                                      width: AppSize.w244.r,
                                                      height: AppSize.h244.r,
                                                      decoration: BoxDecoration(
                                                        color:
                                                            widget.user.link ==
                                                                    null
                                                                ? AppColors
                                                                    .buttonBack
                                                                : AppColors
                                                                    .white,
                                                        borderRadius:
                                                            BorderRadius
                                                                .circular(
                                                                    AppRadius
                                                                        .r13.r),
                                                        border: Border.all(
                                                          color:
                                                              AppColors.grey2,
                                                          width: AppSize.w0_5.w,
                                                        ),
                                                      ),
                                                      child: Center(
                                                        child: InkWell(
                                                          onTap: widget.user
                                                                      .link !=
                                                                  null
                                                              ? () async {
                                                                  if (kIsWeb) {
                                                                    final snackBar =
                                                                        SnackBar(
                                                                      content:
                                                                          Center(
                                                                        child:
                                                                            Text(
                                                                          getTranslated(
                                                                              context,
                                                                              "uploadMobOnly"),
                                                                          style:
                                                                              TextStyle(
                                                                            color:
                                                                                AppColors.white,
                                                                            fontSize:
                                                                                AppFontsSizeManager.s21.sp,
                                                                            fontWeight:
                                                                                FontWeight.w600,
                                                                          ),
                                                                        ),
                                                                      ),
                                                                      backgroundColor:
                                                                          AppColors
                                                                              .linear1,
                                                                    );
                                                                    ScaffoldMessenger.of(
                                                                            context)
                                                                        .showSnackBar(
                                                                            snackBar);
                                                                  } else {
                                                                    pickSecondVideo();
                                                                    print(
                                                                        "video>>>${video}");
                                                                  }
                                                                }
                                                              : null,
                                                          child: Column(
                                                            mainAxisAlignment:
                                                                MainAxisAlignment
                                                                    .center,
                                                            children: [
                                                              widget.user.link ==
                                                                          null &&
                                                                      vidLinks
                                                                          .isEmpty
                                                                  ? Column(
                                                                      mainAxisAlignment:
                                                                          MainAxisAlignment
                                                                              .center,
                                                                      children: [
                                                                        SvgPicture
                                                                            .asset(
                                                                          AssetsManager
                                                                              .video1IconPath,
                                                                          width: AppSize
                                                                              .w36
                                                                              .w,
                                                                          height: AppSize
                                                                              .h36
                                                                              .h,
                                                                        ),
                                                                        SizedBox(
                                                                          height: AppSize
                                                                              .h13_3
                                                                              .h,
                                                                        ),
                                                                        Padding(
                                                                          padding:
                                                                              EdgeInsets.symmetric(horizontal: AppPadding.p13_3.w),
                                                                          child:
                                                                              Text(
                                                                            getTranslated(context,
                                                                                'uploadTxt'),
                                                                            textAlign:
                                                                                TextAlign.center,
                                                                            style:
                                                                                TextStyle(
                                                                              color: AppColors.grey1,
                                                                              fontSize: AppFontsSizeManager.s18.sp,
                                                                              fontFamily: getTranslated(context, "NotoKufiArabic-Regular"),
                                                                            ),
                                                                          ),
                                                                        ),
                                                                      ],
                                                                    )
                                                                  : Center(
                                                                      child: SvgPicture
                                                                          .asset(
                                                                        AssetsManager
                                                                            .video1IconPath,
                                                                        width: AppSize
                                                                            .w36
                                                                            .w,
                                                                        height: AppSize
                                                                            .h36
                                                                            .h,
                                                                      ),
                                                                    ),
                                                            ],
                                                          ),
                                                        ),
                                                      ),
                                                    )
                                                  : SizedBox(),
                                            ],
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),

                          SizedBox(
                              height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.h86.h
                                  : AppSize.h42_6.h),
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Container(
                                      width: kIsWeb
                                          ? AppSize.w808.w
                                          : AppSize.w509.w,
                                      height: kIsWeb
                                          ? AppSize.h80.h
                                          : AppSize.h72.h,
                                      child: TextFormFieldWidget(
                                        keyboardType: TextInputType.number,
                                        labelFont: getTranslated(
                                            context, 'NotoKufiArabic-SemiBold'),
                                        Height: kIsWeb
                                            ? AppSize.h95.h
                                            : AppSize.h72.h,
                                        name: getTranslated(
                                            context, "thePriceLessonTxt"),
                                        controller: priceController,
                                        numbers: true,
                                        obscureText: false,
                                      ),
                                    ),
                                    Container(
                                      width: AppSize.w808.w,
                                      // padding: const EdgeInsets.symmetric(
                                      //   horizontal: AppPadding.p15,
                                      // ),

                                      decoration: BoxDecoration(
                                          color: AppColors.white,
                                          //border: Border(color: AppColors.darkGrey, width: 1.w),

                                          borderRadius:
                                              new BorderRadius.circular(15.r)),
                                      child: InputDecorator(
                                        decoration: InputDecoration(
                                          contentPadding: EdgeInsets.symmetric(
                                              horizontal: AppSize.w20.w,
                                              vertical: AppSize
                                                  .h21.h), // <-- SEE HERE

                                          labelText: getTranslated(
                                              context, "timeOfWork"),
                                          labelStyle: TextStyle(
                                            fontFamily: lang == "ar"
                                                ? getTranslated(
                                                    context, "Ithra")
                                                : getTranslated(
                                                    context, "Montserratbold"),
                                            fontSize:
                                                AppFontsSizeManager.s32.sp,
                                            color: AppColors.pink,
                                            fontWeight: FontWeight.bold,
                                          ),
                                          enabledBorder: new OutlineInputBorder(
                                            borderSide: BorderSide(
                                                width: AppSize.w0_5.w,
                                                color: AppColors.warmGrey),
                                            borderRadius: BorderRadius.circular(
                                                AppRadius.r10_6.r),
                                          ),
                                        ),
                                        child: Column(
                                          children: [
                                            Container(
                                              child: InkWell(
                                                onTap: () {
                                                  setState(() {
                                                    workDaysOpen =
                                                        !workDaysOpen;
                                                  });
                                                },
                                                child: Row(
                                                  mainAxisAlignment:
                                                      MainAxisAlignment
                                                          .spaceBetween,
                                                  children: [
                                                    Expanded(
                                                      child: Text(
                                                        daysController.text,
                                                        maxLines: 1,
                                                        overflow: TextOverflow
                                                            .ellipsis,
                                                        style: TextStyle(
                                                          fontFamily: getTranslated(
                                                              context,
                                                              'NotoKufiArabic-Regular'),
                                                          fontSize:
                                                              AppFontsSizeManager
                                                                  .s32.sp,
                                                          color: AppColors
                                                              .darkGrey,
                                                          fontWeight:
                                                              FontWeight.w300,
                                                        ),
                                                      ),
                                                    ),
                                                    InkWell(
                                                        onTap: () {
                                                          setState(() {
                                                            workDaysOpen =
                                                                !workDaysOpen;
                                                          });
                                                        },
                                                        child: Icon(
                                                          workDaysOpen
                                                              ? Icons
                                                                  .keyboard_arrow_up
                                                              : Icons
                                                                  .keyboard_arrow_down,
                                                          color:
                                                              AppColors.linear2,
                                                        )),
                                                  ],
                                                ),
                                              ),
                                              height: AppSize.h32.h,
                                            ),

                                            // TextFormField(
                                            //   controller: daysController,
                                            //   onTap: () {
                                            //     setState(() {
                                            //       workDaysOpen = !workDaysOpen;
                                            //     });
                                            //   },
                                            //   textAlignVertical: TextAlignVertical.center,
                                            //   validator: (String? val) {
                                            //     if (val!.trim().isEmpty) {
                                            //       return 'This field is required';
                                            //     }
                                            //     return null;
                                            //   },
                                            //   readOnly: true,
                                            //   enableInteractiveSelection: true,
                                            //   style: style(size),
                                            //   maxLines: 1,
                                            //   textInputAction: TextInputAction.newline,
                                            //   keyboardType: TextInputType.multiline,
                                            //   decoration: InputDecoration(
                                            //     suffixIcon: Icon(
                                            //       workDaysOpen
                                            //           ? Icons.keyboard_arrow_up
                                            //           : Icons.keyboard_arrow_down,
                                            //       color: AppColors.linear2,
                                            //     ),
                                            //     contentPadding: EdgeInsets.all(AppPadding.p10),
                                            //     errorStyle: style(size),
                                            //     hintStyle: style(size),
                                            //     labelText: getTranslated(context, "timeOfWork"),
                                            //     labelStyle: TextStyle(
                                            //       fontFamily: getTranslated(context, 'Ithra'),
                                            //       fontSize: AppFontsSizeManager.s21_3.sp,
                                            //       color: AppColors.pink,
                                            //       fontWeight: FontWeight.bold,
                                            //     ),
                                            //     enabledBorder: new OutlineInputBorder(
                                            //       borderSide: BorderSide(
                                            //           width: AppSize.w0_5.w,
                                            //           color: AppColors.warmGrey),
                                            //       borderRadius:
                                            //           BorderRadius.circular(AppRadius.r10_6.r),
                                            //     ),
                                            //     focusedBorder: new OutlineInputBorder(
                                            //       borderSide: BorderSide(
                                            //           width: AppSize.w0_5.w,
                                            //           color: AppColors.warmPurple4),
                                            //       borderRadius:
                                            //           BorderRadius.circular(AppRadius.r10_6.r),
                                            //     ),
                                            //     border: OutlineInputBorder(
                                            //       borderSide:
                                            //           BorderSide(color: AppColors.greyDark),
                                            //       borderRadius:
                                            //           BorderRadius.circular(AppRadius.r10_6.r),
                                            //     ),
                                            //   ),
                                            // ),
                                            SizedBox(
                                              height: AppSize.h10.h,
                                            ),
                                            workDaysOpen
                                                ? _show(context, size)
                                                : SizedBox(),
                                          ],
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Column(children: [
                                  Container(
                                    width: kIsWeb
                                        ? AppSize.w1085.w
                                        : AppSize.w509.w,
                                    height:
                                        kIsWeb ? AppSize.h95.h : AppSize.h72.h,
                                    child: TextFormFieldWidget(
                                      keyboardType: TextInputType.number,
                                      labelFont: getTranslated(
                                          context, 'NotoKufiArabic-SemiBold'),
                                      Height: kIsWeb
                                          ? AppSize.h95.h
                                          : AppSize.h72.h,
                                      name: getTranslated(
                                          context, "thePriceLessonTxt"),
                                      controller: priceController,
                                      numbers: true,
                                      obscureText: false,
                                    ),
                                  ),
                                  SizedBox(
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h64_5.h
                                          : AppSize.h42_6.h),
                                  Container(
                                    width: AppSize.w509.w,
                                    // padding: const EdgeInsets.symmetric(
                                    //   horizontal: AppPadding.p15,
                                    // ),

                                    decoration: BoxDecoration(
                                        color: AppColors.white,
                                        //border: Border(color: AppColors.darkGrey, width: 1.w),

                                        borderRadius:
                                            new BorderRadius.circular(15.r)),
                                    child: InputDecorator(
                                      decoration: InputDecoration(
                                        contentPadding: EdgeInsets.symmetric(
                                            horizontal: AppSize.w20.w,
                                            vertical:
                                                AppSize.h21.h), // <-- SEE HERE

                                        labelText: getTranslated(
                                            context, "timeOfWork"),
                                        labelStyle: TextStyle(
                                          fontFamily: lang == "ar"
                                              ? getTranslated(context, "Ithra")
                                              : getTranslated(
                                                  context, "Montserratbold"),
                                          fontSize:
                                              AppFontsSizeManager.s21_3.sp,
                                          color: AppColors.pink,
                                          fontWeight: FontWeight.bold,
                                        ),
                                        enabledBorder: new OutlineInputBorder(
                                          borderSide: BorderSide(
                                              width: AppSize.w0_5.w,
                                              color: AppColors.warmGrey),
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r10_6.r),
                                        ),
                                      ),
                                      child: Column(
                                        children: [
                                          Container(
                                            child: InkWell(
                                              onTap: () {
                                                setState(() {
                                                  workDaysOpen = !workDaysOpen;
                                                });
                                              },
                                              child: Row(
                                                mainAxisAlignment:
                                                    MainAxisAlignment
                                                        .spaceBetween,
                                                children: [
                                                  Expanded(
                                                    child: Text(
                                                      daysController.text,
                                                      maxLines: 1,
                                                      overflow:
                                                          TextOverflow.ellipsis,
                                                      style: TextStyle(
                                                        fontFamily: getTranslated(
                                                            context,
                                                            'NotoKufiArabic-Regular'),
                                                        fontSize:
                                                            AppFontsSizeManager
                                                                .s21_3.sp,
                                                        color:
                                                            AppColors.darkGrey,
                                                        fontWeight:
                                                            FontWeight.w300,
                                                      ),
                                                    ),
                                                  ),
                                                  InkWell(
                                                      onTap: () {
                                                        setState(() {
                                                          workDaysOpen =
                                                              !workDaysOpen;
                                                        });
                                                      },
                                                      child: Icon(
                                                        workDaysOpen
                                                            ? Icons
                                                                .keyboard_arrow_up
                                                            : Icons
                                                                .keyboard_arrow_down,
                                                        color:
                                                            AppColors.linear2,
                                                      )),
                                                ],
                                              ),
                                            ),
                                            height: AppSize.h32.h,
                                          ),

                                          // TextFormField(
                                          //   controller: daysController,
                                          //   onTap: () {
                                          //     setState(() {
                                          //       workDaysOpen = !workDaysOpen;
                                          //     });
                                          //   },
                                          //   textAlignVertical: TextAlignVertical.center,
                                          //   validator: (String? val) {
                                          //     if (val!.trim().isEmpty) {
                                          //       return 'This field is required';
                                          //     }
                                          //     return null;
                                          //   },
                                          //   readOnly: true,
                                          //   enableInteractiveSelection: true,
                                          //   style: style(size),
                                          //   maxLines: 1,
                                          //   textInputAction: TextInputAction.newline,
                                          //   keyboardType: TextInputType.multiline,
                                          //   decoration: InputDecoration(
                                          //     suffixIcon: Icon(
                                          //       workDaysOpen
                                          //           ? Icons.keyboard_arrow_up
                                          //           : Icons.keyboard_arrow_down,
                                          //       color: AppColors.linear2,
                                          //     ),
                                          //     contentPadding: EdgeInsets.all(AppPadding.p10),
                                          //     errorStyle: style(size),
                                          //     hintStyle: style(size),
                                          //     labelText: getTranslated(context, "timeOfWork"),
                                          //     labelStyle: TextStyle(
                                          //       fontFamily: getTranslated(context, 'Ithra'),
                                          //       fontSize: AppFontsSizeManager.s21_3.sp,
                                          //       color: AppColors.pink,
                                          //       fontWeight: FontWeight.bold,
                                          //     ),
                                          //     enabledBorder: new OutlineInputBorder(
                                          //       borderSide: BorderSide(
                                          //           width: AppSize.w0_5.w,
                                          //           color: AppColors.warmGrey),
                                          //       borderRadius:
                                          //           BorderRadius.circular(AppRadius.r10_6.r),
                                          //     ),
                                          //     focusedBorder: new OutlineInputBorder(
                                          //       borderSide: BorderSide(
                                          //           width: AppSize.w0_5.w,
                                          //           color: AppColors.warmPurple4),
                                          //       borderRadius:
                                          //           BorderRadius.circular(AppRadius.r10_6.r),
                                          //     ),
                                          //     border: OutlineInputBorder(
                                          //       borderSide:
                                          //           BorderSide(color: AppColors.greyDark),
                                          //       borderRadius:
                                          //           BorderRadius.circular(AppRadius.r10_6.r),
                                          //     ),
                                          //   ),
                                          // ),
                                          SizedBox(
                                            height: AppSize.h10.h,
                                          ),
                                          workDaysOpen
                                              ? _show(context, size)
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ),
                                ]),

                          SizedBox(
                            height: AppSize.h48.h,
                          ),
                          Padding(
                            padding: EdgeInsets.symmetric(
                                horizontal: AppPadding.p18.w),
                            child: Row(
                              children: [
                                Text(
                                  getTranslated(context, "worksTimeTxt"),
                                  style: TextStyle(
                                    fontFamily: getTranslated(
                                        context, "NotoKufiArabic-SemiBold"),
                                    fontSize: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s32.sp
                                        : AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.linear8,
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h26_6.h,
                          ),
                          (kIsWeb || size.width >= AppConstants.kIsWebValue)
                              ? Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      getTranslated(context, "from"),
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, "NotoKufiArabic-SemiBold"),
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s32.sp
                                            : AppFontsSizeManager.s21_3.sp,
                                        color: AppColors.pink,
                                      ),
                                    ),
                                    SizedBox(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w24.w
                                          : AppSize.w21_3.w,
                                    ),
                                    // SizedBox(
                                    //     width: (kIsWeb ||
                                    //             size.width >=
                                    //                 AppConstants.kIsWebValue)
                                    //         ? AppSize.w32.w
                                    //         : AppSize.w21_3.w),
                                    Container(
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h80.h
                                          : AppSize.h53_3.h,
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w300.h
                                          : AppSize.h194.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                        border: Border.all(
                                            color: AppColors.grey,
                                            width: AppSize.w1.w),
                                      ),
                                      child: Center(
                                        child: Center(
                                          child: TextFormField(
                                            onTap: () {
                                              _selectTimeFrom(context);
                                            },
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            textAlign: TextAlign.center,
                                            readOnly: true,
                                            style: TextStyle(
                                              fontFamily: getTranslated(context,
                                                  "NotoKufiArabic-Regular"),
                                              color: AppColors.pink,
                                              fontSize:
                                                  AppFontsSizeManager.s32.sp,
                                            ),
                                            validator: (String? val) {
                                              if (val!.trim().isEmpty) {
                                                return getTranslated(
                                                    context, 'required');
                                              }
                                              return null;
                                            },
                                            cursorColor: AppColors.black,
                                            controller: fromController,
                                            keyboardType: TextInputType.name,
                                            decoration: new InputDecoration(
                                              hintStyle: TextStyle(
                                                color: AppColors.grey,
                                                fontFamily: getTranslated(
                                                    context,
                                                    "NotoKufiArabic-Regular"),
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppFontsSizeManager.s32.sp
                                                    : AppFontsSizeManager
                                                        .s18_6.sp,
                                                fontWeight:
                                                    AppFontsWeightManager
                                                        .semiBold,
                                                letterSpacing: AppConstants
                                                    .letterSpacing0_5,
                                              ),
                                              hintText: getTranslated(
                                                  context, 'from'),
                                              isCollapsed: true,
                                              contentPadding: EdgeInsets.zero,
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w30.w
                                          : AppSize.w21_3.w,
                                    ),
                                    Text(
                                      getTranslated(context, "to"),
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, "NotoKufiArabic-SemiBold"),
                                        color: AppColors.pink,
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s32.sp
                                            : AppFontsSizeManager.s21_3.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing:
                                            AppConstants.letterSpacing0_5,
                                      ),
                                    ),
                                    SizedBox(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w24.w
                                          : AppSize.w21_3.w,
                                    ),
                                    Container(
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h80.h
                                          : AppSize.h53_3.h,
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w298.h
                                          : AppSize.h186.h,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                        border: Border.all(
                                            color: AppColors.grey,
                                            width: AppSize.w1.w),
                                      ),
                                      child: Center(
                                        child: TextFormField(
                                          onTap: () {
                                            _selectTimeTo(context);
                                          },
                                          textAlign: TextAlign.center,
                                          validator: (String? val) {
                                            if (val!.trim().isEmpty) {
                                              return getTranslated(
                                                  context, 'required');
                                            }
                                            return null;
                                          },
                                          /* onSaved: (val) {
                                  to=val;
                                                                    },*/
                                          readOnly: true,
                                          style: TextStyle(
                                            fontFamily: getTranslated(context,
                                                "NotoKufiArabic-Regular"),
                                            color: AppColors.pink,
                                            fontSize:
                                                AppFontsSizeManager.s32.sp,
                                          ),
                                          cursorColor: AppColors.black,
                                          controller: toController,
                                          keyboardType: TextInputType.name,
                                          decoration: new InputDecoration(
                                            isCollapsed: true,
                                            contentPadding: EdgeInsets.zero,
                                            hintStyle: TextStyle(
                                              color: AppColors.grey,
                                              fontFamily: getTranslated(context,
                                                  "NotoKufiArabic-Regular"),
                                              fontSize: (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppFontsSizeManager.s32.sp
                                                  : AppFontsSizeManager
                                                      .s18_6.sp,
                                              fontWeight: AppFontsWeightManager
                                                  .semiBold,
                                              letterSpacing:
                                                  AppConstants.letterSpacing0_5,
                                            ),
                                            hintText:
                                                getTranslated(context, 'to'),
                                            border: InputBorder.none,
                                            focusedBorder: InputBorder.none,
                                            enabledBorder: InputBorder.none,
                                            errorBorder: InputBorder.none,
                                            disabledBorder: InputBorder.none,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                )
                              : Row(
                                  //mainAxisAlignment: MainAxisAlignment.spaceBetween,

                                  children: [
                                    Text(
                                      getTranslated(context, "from"),
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, "NotoKufiArabic-SemiBold"),
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s32.sp
                                            : AppFontsSizeManager.s21_3.sp,
                                        color: AppColors.pink,
                                      ),
                                    ),
                                    SizedBox(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w24.w
                                          : AppSize.w21_3.w,
                                    ),
                                    // SizedBox(
                                    //     width: (kIsWeb ||
                                    //             size.width >=
                                    //                 AppConstants.kIsWebValue)
                                    //         ? AppSize.w32.w
                                    //         : AppSize.w21_3.w),
                                    Container(
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h80.h
                                          : AppSize.h53_3.h,
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w300.h
                                          : AppSize.h194.w,
                                      decoration: BoxDecoration(
                                        color: AppColors.white,
                                        borderRadius: BorderRadius.circular(
                                            AppRadius.r5_3.r),
                                        border: Border.all(
                                            color: AppColors.grey,
                                            width: AppSize.w1.w),
                                      ),
                                      child: Center(
                                        child: Center(
                                          child: TextFormField(
                                            onTap: () {
                                              _selectTimeFrom(context);
                                            },
                                            textAlignVertical:
                                                TextAlignVertical.center,
                                            textAlign: TextAlign.center,
                                            readOnly: true,
                                            style: TextStyle(
                                              fontFamily: getTranslated(context,
                                                  "NotoKufiArabic-Regular"),
                                              color: AppColors.pink,
                                              fontSize:
                                                  AppFontsSizeManager.s18_6.sp,
                                            ),
                                            validator: (String? val) {
                                              if (val!.trim().isEmpty) {
                                                return getTranslated(
                                                    context, 'required');
                                              }
                                              return null;
                                            },
                                            cursorColor: AppColors.black,
                                            controller: fromController,
                                            keyboardType: TextInputType.name,
                                            decoration: new InputDecoration(
                                              hintStyle: TextStyle(
                                                color: AppColors.grey,
                                                fontFamily: getTranslated(
                                                    context,
                                                    "NotoKufiArabic-Regular"),
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppFontsSizeManager.s28.sp
                                                    : AppFontsSizeManager
                                                        .s18_6.sp,
                                                fontWeight:
                                                    AppFontsWeightManager
                                                        .semiBold,
                                                letterSpacing: AppConstants
                                                    .letterSpacing0_5,
                                              ),
                                              hintText: getTranslated(
                                                  context, 'from'),
                                              isCollapsed: true,
                                              contentPadding: EdgeInsets.zero,
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                    SizedBox(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w30.w
                                          : AppSize.w21_3.w,
                                    ),
                                    Text(
                                      getTranslated(context, "to"),
                                      style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, "NotoKufiArabic-SemiBold"),
                                        color: AppColors.pink,
                                        fontSize: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppFontsSizeManager.s32.sp
                                            : AppFontsSizeManager.s21_3.sp,
                                        fontWeight: FontWeight.bold,
                                        letterSpacing:
                                            AppConstants.letterSpacing0_5,
                                      ),
                                    ),
                                    SizedBox(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w24.w
                                          : AppSize.w21_3.w,
                                    ),
                                    Expanded(
                                      child: Container(
                                        height: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.h80.h
                                            : AppSize.h53_3.h,
                                        width: (kIsWeb ||
                                                size.width >=
                                                    AppConstants.kIsWebValue)
                                            ? AppSize.w298.h
                                            : AppSize.h186.h,
                                        decoration: BoxDecoration(
                                          color: AppColors.white,
                                          borderRadius: BorderRadius.circular(
                                              AppRadius.r5_3.r),
                                          border: Border.all(
                                              color: AppColors.grey,
                                              width: AppSize.w1.w),
                                        ),
                                        child: Center(
                                          child: TextFormField(
                                            onTap: () {
                                              _selectTimeTo(context);
                                            },
                                            textAlign: TextAlign.center,
                                            validator: (String? val) {
                                              if (val!.trim().isEmpty) {
                                                return getTranslated(
                                                    context, 'required');
                                              }
                                              return null;
                                            },
                                            /* onSaved: (val) {
                                    to=val;
                                                                      },*/
                                            readOnly: true,
                                            style: TextStyle(
                                              fontFamily: getTranslated(context,
                                                  "NotoKufiArabic-Regular"),
                                              color: AppColors.pink,
                                              fontSize:
                                                  AppFontsSizeManager.s18_6.sp,
                                            ),
                                            cursorColor: AppColors.black,
                                            controller: toController,
                                            keyboardType: TextInputType.name,
                                            decoration: new InputDecoration(
                                              isCollapsed: true,
                                              contentPadding: EdgeInsets.zero,
                                              hintStyle: TextStyle(
                                                color: AppColors.grey,
                                                fontFamily: getTranslated(
                                                    context,
                                                    "NotoKufiArabic-Regular"),
                                                fontSize: (kIsWeb ||
                                                        size.width >=
                                                            AppConstants
                                                                .kIsWebValue)
                                                    ? AppFontsSizeManager.s28.sp
                                                    : AppFontsSizeManager
                                                        .s18_6.sp,
                                                fontWeight:
                                                    AppFontsWeightManager
                                                        .semiBold,
                                                letterSpacing: AppConstants
                                                    .letterSpacing0_5,
                                              ),
                                              hintText:
                                                  getTranslated(context, 'to'),
                                              border: InputBorder.none,
                                              focusedBorder: InputBorder.none,
                                              enabledBorder: InputBorder.none,
                                              errorBorder: InputBorder.none,
                                              disabledBorder: InputBorder.none,
                                            ),
                                          ),
                                        ),
                                      ),
                                    ),
                                  ],
                                ),

                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h64.h
                                : AppSize.h42.h,
                          ),
                          Padding(
                            padding: EdgeInsets.only(
                              right: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 0.h
                                  : 0,
                            ),
                            child: InkWell(
                              onTap: () {
                                showDeleteConfimationDialog(size);
                              },
                              child: Row(
                                children: [
                                  Icon(
                                    Icons.delete_outline,
                                    color: AppColors.red,
                                    size: (kIsWeb ||
                                            size.width >=
                                                AppConstants.kIsWebValue)
                                        ? AppFontsSizeManager.s48.sp
                                        : AppFontsSizeManager.s32.sp,
                                  ),
                                  SizedBox(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w16.w
                                          : AppSize.w12.w),
                                  Text(
                                    getTranslated(context, "deleteAccount"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                        fontFamily: getTranslated(
                                            context, "NotoKufiArabic-SemiBold"),
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
                          // SizedBox(
                          //   height: AppSize.h32,
                          // ),
                          // Center(
                          //   child: saving
                          //       ? CircularProgressIndicator()
                          //       : InkWell(
                          //           onTap: () {
                          //             AppFlyerService().inviteFriends(
                          //               FirebaseAuth.instance.currentUser?.uid ?? '',
                          //               nameArController.text,
                          //             );
                          //           },
                          //           child: Container(
                          //             width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          //                 ? AppSize.w650.w
                          //                 : AppSize.w524.w,
                          //             height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          //                 ? AppSize.h105.h
                          //                 : AppSize.h66_6.h,
                          //             decoration: BoxDecoration(
                          //                 borderRadius: BorderRadius.circular(
                          //                     (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          //                         ? AppRadius.r22.r
                          //                         : AppRadius.r12.r),
                          //                 gradient: LinearGradient(
                          //                   begin: Alignment.topCenter,
                          //                   end: Alignment.bottomCenter,
                          //                   colors: [
                          //                     AppColors.linear1,
                          //                     AppColors.linear2,
                          //                     AppColors.linear2,
                          //                   ],
                          //                 )),
                          //             child: Center(
                          //               child: Text(
                          //                 "Invite Friend",
                          //                 style: TextStyle(
                          //                   fontFamily: getTranslated(context, "Ithra"),
                          //                   color: AppColors.white,
                          //                   fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          //                       ? AppFontsSizeManager.s36.sp
                          //                       : AppFontsSizeManager.s21_3.sp,
                          //                   letterSpacing: AppConstants.letterSpacing0_5,
                          //                 ),
                          //               ),
                          //             ),
                          //           ),
                          //         ),
                          // ),
                          SizedBox(
                            height: (kIsWeb ||
                                    size.width >= AppConstants.kIsWebValue)
                                ? AppSize.h64.w
                                : AppSize.h32.h,
                          ),
                          Center(
                            child: saving
                                ? CircularProgressIndicator()
                                : InkWell(
                                    onTap: () {
                                      save();
                                      //function();
                                    },
                                    child: Container(
                                      width: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.w1085.w
                                          : AppSize.w509.w,
                                      height: (kIsWeb ||
                                              size.width >=
                                                  AppConstants.kIsWebValue)
                                          ? AppSize.h100.h
                                          : AppSize.h66_6.h,
                                      decoration: BoxDecoration(
                                          borderRadius: BorderRadius.circular(
                                              (kIsWeb ||
                                                      size.width >=
                                                          AppConstants
                                                              .kIsWebValue)
                                                  ? AppRadius.r12.r
                                                  : AppRadius.r12.r),
                                          gradient: LinearGradient(
                                            begin: Alignment.topCenter,
                                            end: Alignment.bottomCenter,
                                            colors: [
                                              AppColors.gradiant2,
                                              AppColors.linear8,
                                            ],
                                          )),
                                      child: Center(
                                        child: Text(
                                          getTranslated(
                                              context, "saveAndContinue"),
                                          style: TextStyle(
                                            fontFamily: getTranslated(context,
                                                "NotoKufiArabic-SemiBold"),
                                            color: AppColors.white,
                                            fontSize: (kIsWeb ||
                                                    size.width >=
                                                        AppConstants
                                                            .kIsWebValue)
                                                ? AppFontsSizeManager.s36.sp
                                                : AppFontsSizeManager.s21_3.sp,
                                            letterSpacing:
                                                AppConstants.letterSpacing0_5,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                          ),

                          SizedBox(
                            height: AppSize.h40.h,
                          ),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  void showVideoPlayer2(parentContext, File videoUrl) async {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: VideoPlayerWidget(videoUrl, widget.user),
      ),
      barrierDismissible: false,
      context: parentContext,
    );
  }

  Widget getTitle(Size size, String title) {
    return Padding(
      padding: const EdgeInsets.only(top: AppPadding.p5),
      child: Center(
        child: Center(
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
                fontWeight: FontWeight.bold),
          ),
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

  InputDecoration inputDecoration(String value) {
    return InputDecoration(
        fillColor: AppColors.white,
        hintText: (value == "link"
            ? "https://www.youtuyoutubebe.com/watch?v=xxxxxxx"
            : ""),
        hintStyle: TextStyle(
          fontFamily: getTranslated(context, "Ithra"),
          fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
              ? AppFontsSizeManager.s18.sp
              : AppFontsSizeManager.s18_6.sp,
          color: AppColors.greyShade300,
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r15.r),
          borderSide: BorderSide(
            color: AppColors.greyShade300,
          ),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppRadius.r15.r),
          borderSide: BorderSide(
            color: AppColors.greyShade300,
            width: AppSize.w1.w,
          ),
        ));
  }

  /*Future<void> function() async {
    querySnapshot1 = await FirebaseFirestore.instance
        .collection(Paths.usersPath)
         .where("userType", isEqualTo: "CONSULTANT")
        .where('accountStatus', isEqualTo: "Active")
       // .where('phoneNumber', isEqualTo: '+201227002323')
        .get();
    if (querySnapshot1.docs.length > 0) {
      print("Length = ${querySnapshot1.docs.length}");
      for (int i = 0; i < querySnapshot1.docs.length; i++) {
        var nameAr =
            await GroceryUser.fromMap(querySnapshot1.docs[i].data() as Map)
                .name;
        var nameEn =
            await GroceryUser.fromMap(querySnapshot1.docs[i].data() as Map)
                .nameEn;
        String? uid =
            await GroceryUser.fromMap(querySnapshot1.docs[i].data() as Map).uid;

        print("name $i =$nameAr");

        if (nameAr != null) {
          await nameCutting(nameAr, uid!, "ar");
        }
        if (nameEn != null) {
          await nameCutting(nameEn, uid!, "en");
        }
      }
    }
  }*/

  nameCutting(String name, String langName) async {
    // print("Method 1");
    List<String> indexList = [];
    for (int y = 1;
        y <= name.replaceAll('.', '').trimLeft().trimRight().length;
        y++) {
      /*print("M1=${name
          .replaceAll('.', '')
          .trimLeft()
          .trimRight()
          .substring(0, y)
          .toLowerCase()}");*/

      indexList.add(name
          .replaceAll('.', '')
          .trimLeft()
          .trimRight()
          .substring(0, y)
          .toLowerCase());
    }

    // print("Method 2");
    List<String> splitName = name.split(' ');

    List<String> nameList = [];

    for (int i = 1; i < splitName.length; i++) {
      String name1 = splitName[i];

      for (int x = i + 1; x < splitName.length; x++) {
        name1 = name1 + " " + splitName[x];
        indexList.add(name1);
        // print("M2=${name1}");
      }
      // print("M2-2=${name1}");
      nameList.add(name1);
    }

    // print("nnnnnnnnn = ${nameList}");

    // print("Method 3");
    for (int v = 0; v < nameList.length; v++) {
      for (int z = 1;
          z <= nameList[v].replaceAll('.', '').trimLeft().trimRight().length;
          z++) {
        // print(
        //     "M3=${nameList[v].replaceAll('.', '').trimLeft().trimRight().substring(0, z).toLowerCase()}");
        indexList.add(nameList[v]
            .replaceAll('.', '')
            .trimLeft()
            .trimRight()
            .substring(0, z)
            .toLowerCase());
      }
    }

    if (langName == "ar")
      setState(() {
        searchAr = indexList;
      });
    else if (langName == "en")
      setState(() {
        searchEn = indexList;
      });
    else if (langName == "fr")
      setState(() {
        searchFr = indexList;
      });

    /*  if (langName == "ar")
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(uid)
          .set({
        'searchIndex': indexList,
      }, SetOptions(merge: true));
    else if (langName == "en")
      await FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(uid)
          .set({
        'searchIndexEn': indexList,
      }, SetOptions(merge: true));*/
  }

  save() async {
    setState(() {
      saving = true;
    });
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      if (arabic) {
        setState(() {
          nameAr = nameArController.text;
          bioAr = bioArController.text;
        });
      } else {
        setState(() {
          nameAr = "";
          bioAr = "";
        });
      }

      if (english) {
        setState(() {
          nameEn = nameEnController.text;
          bioEn = bioEnController.text;
        });
      } else {
        setState(() {
          nameEn = "";
          bioEn = "";
        });
      }
      if (french) {
        setState(() {
          nameFr = nameFrController.text;
          bioFr = bioFrController.text;
        });
      } else {
        setState(() {
          nameFr = "";
          bioFr = "";
        });
      }

      await nameCutting(nameAr, "ar");
      await nameCutting(nameEn, "en");
      await nameCutting(nameFr, "fr");

      widget.user.name = nameAr;
      widget.user.nameEn = nameEn;
      widget.user.nameFr = nameFr;
      widget.user.bio = bioAr;
      widget.user.bioEn = bioEn;
      widget.user.bioFr = bioFr;
      widget.user.searchIndex = searchAr;
      widget.user.searchIndexEn = searchEn;
      widget.user.searchIndexFr = searchFr;

      widget.user.consultType = "jeras";
      //============packages
      if (priceController.text != price) {
        widget.user.price = int.parse(priceController.text).toString();
        var querySnapshot = await FirebaseFirestore.instance
            .collection(Paths.packagesPath)
            .where('consultUid', isEqualTo: widget.user.uid)
            .get();

        if (querySnapshot.docs.length > 0) {
          for (var doc in querySnapshot.docs) {
            FirebaseFirestore.instance
                .collection(Paths.packagesPath)
                .doc(doc.id)
                .delete();
          }
          var packageId0 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId0)
              .set({
            'price': double.parse(priceController.text.toString()),
            'discount': 0,
            'callNum': 1,
            'consultUid': widget.user.uid,
            'Id': packageId0,
            'active': true,
          }, SetOptions(merge: true));

          var packageId1 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId1)
              .set({
            'price': 3 * double.parse(priceController.text),
            'discount': 0,
            'callNum': 3,
            'consultUid': widget.user.uid,
            'Id': packageId1,
            'active': true,
          }, SetOptions(merge: true));

          var packageId2 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId2)
              .set({
            'price': 5 * double.parse(priceController.text),
            'discount': 0,
            'callNum': 5,
            'consultUid': widget.user.uid,
            'Id': packageId2,
            'active': true,
          }, SetOptions(merge: true));
          var packageId3 = Uuid().v4();
          await FirebaseFirestore.instance
              .collection(Paths.packagesPath)
              .doc(packageId3)
              .set({
            'price': 10 * double.parse(priceController.text),
            'discount': 0,
            'callNum': 10,
            'consultUid': widget.user.uid,
            'Id': packageId3,
            'active': true,
          }, SetOptions(merge: true));
        }

        //==================
      }
      widget.user.price = priceController.text;
      //times
      var datenow = DateTime.now();
      _workTime.from = from;
      _workTime.to = to;
      widget.user.workTimes!.clear();
      widget.user.workTimes!.add(_workTime);
      widget.user.fromUtc = DateTime(
              datenow.year, datenow.month, datenow.day, int.parse(from), 0, 0)
          .toUtc()
          .toString();
      widget.user.toUtc = DateTime(
              datenow.year, datenow.month, datenow.day, int.parse(to), 0, 0)
          .toUtc()
          .toString();
      //---------

      widget.user.location = locationArController.text;
      widget.user.locationEn = locationEnController.text;

      widget.user.profileCompleted = true;
      widget.user.userLang = getTranslated(context, 'lang');
      if (widget.user.order == null) widget.user.order = 0;
      //

      if (widget.user.link == null && mainVideo != null) {
        print("vid 1");
        uploadVideo(File(mainVideo!.path));
      }
      if (widget.user.link != null && picRepMainVideo != null) {
        print("vid 2");
        updateFile(File(picRepMainVideo!.path));
      }
      if (widget.user.link != null &&
          vidLinks.isEmpty &&
          picFirstVideo != null) {
        uploadFirstVideo(File(picFirstVideo!.path));
        print("vid 3");

        print("First Video Path${picFirstVideo!.path}");
      }
      if (vidLinks.length > 1 && picSecondVideo != null) {
        uploadSecondVideo(File(picSecondVideo!.path));
        print("vid 4");

        print("Second Video Path${picSecondVideo!.path}");
      }
      if (vidLinks.length == 1 && picRepFirstVideo != null) {
        updateFirstVideo(File(picRepFirstVideo!.path));
        print("vid 5");
      }
      if (vidLinks.length == 2 && picRepSecVideo != null) {
        updateSecondVideo(File(picRepSecVideo!.path));
        print("vid 6");
      }

      //=============

      setState(() {
        dataSave = true;
      });
      if (selectedProfileImage != null) {
        accountBloc.add(UpdateAccountDetailsEvent(
            user: widget.user, profileImage: selectedProfileImage));
      } else {
        accountBloc.add(UpdateAccountDetailsEvent(user: widget.user));
      }
    }
    setState(() {
      saving = false;
    });
  }

  _selectTimeFrom(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.from == null
          ? selectedTime
          : TimeOfDay(
              hour: int.parse(widget.user.workTimes![0].from!), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null) {
      setState(() {
        from = timeOfDay.hour.toString();
        if (timeOfDay.hour == 12)
          fromController.text = "12 ${getTranslated(context, "pm")}";
        else if (timeOfDay.hour == 0)
          fromController.text = "12 ${getTranslated(context, "am")}";
        else if (timeOfDay.hour > 12)
          fromController.text =
              (timeOfDay.hour - 12).toString() + getTranslated(context, "pm");
        else
          fromController.text =
              timeOfDay.hour.toString() + getTranslated(context, "am");
      });
    }
  }

  _selectTimeTo(BuildContext context) async {
    final TimeOfDay? timeOfDay = await showTimePicker(
      context: context,
      initialTime: _workTime.to == null
          ? selectedTime
          : TimeOfDay(
              hour: int.parse(widget.user.workTimes![0].to!), minute: 0),
      initialEntryMode: TimePickerEntryMode.dial,
    );
    if (timeOfDay != null) {
      setState(() {
        to = timeOfDay.hour.toString();
        if (timeOfDay.hour == 12)
          toController.text = "12 ${getTranslated(context, "pm")}";
        else if (timeOfDay.hour == 0)
          toController.text = "12 ${getTranslated(context, "am")}";
        else if (timeOfDay.hour > 12)
          toController.text =
              (timeOfDay.hour - 12).toString() + getTranslated(context, "pm");
        else
          toController.text =
              timeOfDay.hour.toString() + getTranslated(context, "am");
      });
    }
  }

  // void _show(BuildContext ctx, double size, double height) {
  //   showModalBottomSheet(
  //     elevation: 10,
  //     backgroundColor: Colors.transparent,
  //     context: ctx,
  //     builder: (ctx) => Container(
  //       height: height * AppSize.h0_8,
  //       width: size,
  //       padding: const EdgeInsets.symmetric(
  //           horizontal: AppPadding.p15, vertical: 0.0),
  //       decoration: BoxDecoration(
  //           color: AppColors.white,
  //           borderRadius: new BorderRadius.only(
  //             topLeft: Radius.circular(AppRadius.r40.r),
  //             topRight: Radius.circular(AppRadius.r40.r),
  //           )),
  //       child: Padding(
  //           padding: const EdgeInsets.all(AppPadding.p20),
  //           child: StatefulBuilder(builder: (context, setState) {
  //             return SingleChildScrollView(
  //               child: Column(
  //                 mainAxisAlignment: MainAxisAlignment.start,
  //                 children: [
  //                   Text(
  //                     getTranslated(context, "workDays"),
  //                     style: TextStyle(
  //                       fontFamily: getTranslated(context, "Ithra"),
  //                       fontSize: AppFontsSizeManager.s18.sp,
  //                       fontWeight: FontWeight.bold,
  //                       letterSpacing: AppConstants.letterSpacing0_3,
  //                       color: theme == "light"
  //                           ? Theme.of(context).primaryColor
  //                           : AppColors.black,
  //                     ),
  //                   ),
  //                   SizedBox(
  //                     height: AppSize.h5.h,
  //                   ),
  //                   Row(
  //                     children: [
  //                       Checkbox(
  //                         value: monday,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             monday = value!; //!monday;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         getTranslated(context, "monday"),
  //                         style: TextStyle(
  //                           fontFamily: getTranslated(context, "Ithra"),
  //                           fontSize: AppFontsSizeManager.s15.sp,
  //                           fontWeight: AppFontsWeightManager.bold500,
  //                           color: theme == "light"
  //                               ? Theme.of(context).primaryColor
  //                               : AppColors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Checkbox(
  //                         value: tuesday,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             tuesday = !tuesday;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         getTranslated(context, "tuesday"),
  //                         style: TextStyle(
  //                           fontFamily: getTranslated(context, "Ithra"),
  //                           fontSize: AppFontsSizeManager.s15.sp,
  //                           fontWeight: AppFontsWeightManager.bold500,
  //                           color: theme == "light"
  //                               ? Theme.of(context).primaryColor
  //                               : AppColors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Checkbox(
  //                         value: wednesday,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             wednesday = !wednesday;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         getTranslated(context, "wednesday"),
  //                         style: TextStyle(
  //                           fontFamily: getTranslated(context, "Ithra"),
  //                           fontSize: AppFontsSizeManager.s15.sp,
  //                           fontWeight: AppFontsWeightManager.bold500,
  //                           color: theme == "light"
  //                               ? Theme.of(context).primaryColor
  //                               : AppColors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Checkbox(
  //                         value: thursday,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             thursday = !thursday;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         getTranslated(context, "thursday"),
  //                         style: TextStyle(
  //                           fontFamily: getTranslated(context, "Ithra"),
  //                           fontSize: AppFontsSizeManager.s15.sp,
  //                           fontWeight: AppFontsWeightManager.bold500,
  //                           color: theme == "light"
  //                               ? Theme.of(context).primaryColor
  //                               : AppColors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Checkbox(
  //                         value: friday,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             friday = !friday;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         getTranslated(context, "friday"),
  //                         style: TextStyle(
  //                           fontFamily: getTranslated(context, "Ithra"),
  //                           fontSize: AppFontsSizeManager.s15.sp,
  //                           fontWeight: AppFontsWeightManager.bold500,
  //                           color: theme == "light"
  //                               ? Theme.of(context).primaryColor
  //                               : AppColors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Checkbox(
  //                         value: saturday,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             saturday = !saturday;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         getTranslated(context, "saturday"),
  //                         style: TextStyle(
  //                           fontFamily: getTranslated(context, "Ithra"),
  //                           fontSize: AppFontsSizeManager.s15.sp,
  //                           fontWeight: AppFontsWeightManager.bold500,
  //                           color: theme == "light"
  //                               ? Theme.of(context).primaryColor
  //                               : AppColors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Row(
  //                     children: [
  //                       Checkbox(
  //                         value: sunday,
  //                         onChanged: (value) {
  //                           setState(() {
  //                             sunday = !sunday;
  //                           });
  //                         },
  //                       ),
  //                       Text(
  //                         getTranslated(context, "sunday"),
  //                         style: TextStyle(
  //                           fontFamily: getTranslated(context, "Ithra"),
  //                           fontSize: AppFontsSizeManager.s15.sp,
  //                           fontWeight: AppFontsWeightManager.bold500,
  //                           color: theme == "light"
  //                               ? Theme.of(context).primaryColor
  //                               : Colors.black,
  //                         ),
  //                       ),
  //                     ],
  //                   ),
  //                   Center(
  //                     child: SizedBox(
  //                       height: AppSize.h35.h,
  //                       width: size * AppSize.w0_5,
  //                       child: MaterialButton(
  //                         onPressed: () {
  //                           workDays = "";
  //                           daysValue.clear;
  //                           widget.user.workDays!.clear();
  //                           if (monday) {
  //                             workDays = workDays +
  //                                 getTranslated(context, "monday") +
  //                                 ",";
  //                             daysValue.add("1");
  //                           }
  //                           if (tuesday) {
  //                             workDays = workDays +
  //                                 getTranslated(context, "tuesday") +
  //                                 ",";
  //                             daysValue.add("2");
  //                           }
  //                           if (wednesday) {
  //                             workDays = workDays +
  //                                 getTranslated(context, "wednesday") +
  //                                 ",";
  //                             daysValue.add("3");
  //                           }
  //                           if (thursday) {
  //                             workDays = workDays +
  //                                 getTranslated(context, "thursday") +
  //                                 ",";
  //                             daysValue.add("4");
  //                           }
  //                           if (friday) {
  //                             workDays = workDays +
  //                                 getTranslated(context, "friday") +
  //                                 ",";
  //                             daysValue.add("5");
  //                           }
  //                           if (saturday) {
  //                             workDays = workDays +
  //                                 getTranslated(context, "saturday") +
  //                                 ",";
  //                             daysValue.add("6");
  //                           }
  //                           if (sunday) {
  //                             workDays = workDays +
  //                                 getTranslated(context, "sunday") +
  //                                 ",";
  //                             daysValue.add("7");
  //                           }
  //                           setState(() {
  //                             daysController.text = workDays;
  //                             widget.user.workDays = daysValue;
  //                           });
  //                           Navigator.pop(context);
  //                         },
  //                         color: Theme.of(context).primaryColor,
  //                         shape: RoundedRectangleBorder(
  //                           borderRadius:
  //                               BorderRadius.circular(AppRadius.r25.r),
  //                         ),
  //                         child: Text(
  //                           getTranslated(context, "done"),
  //                           style: TextStyle(
  //                             fontFamily: getTranslated(context, "Ithra"),
  //                             color: Colors.white,
  //                             fontSize: AppFontsSizeManager.s14_5.sp,
  //                             fontWeight: AppFontsWeightManager.bold500,
  //                             letterSpacing: AppConstants.letterSpacing0_3,
  //                           ),
  //                         ),
  //                       ),
  //                     ),
  //                   ),
  //                 ],
  //               ),
  //             );
  //           })),
  //     ),
  //   );
  // }

  void showInterests(BuildContext ctx, size) {
    showModalBottomSheet(
      elevation: 10,
      backgroundColor: Colors.transparent,
      context: ctx,
      builder: (ctx) => Container(
        height: size.height * .8.h,
        width: size.width.w,
        padding:
            EdgeInsets.symmetric(horizontal: AppPadding.p15.w, vertical: 0.0.h),
        decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: new BorderRadius.only(
              topLeft: Radius.circular(AppRadius.r40.r),
              topRight: Radius.circular(AppRadius.r40.r),
            )),
        child: Padding(
            padding: const EdgeInsets.all(AppPadding.p20),
            child: StatefulBuilder(builder: (context, setState) {
              return SingleChildScrollView(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    Text(
                      getTranslated(context, "interests"),
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, "NotoKufiArabic-Regular"),
                        fontSize: AppFontsSizeManager.s18.sp,
                        fontWeight: FontWeight.bold,
                        letterSpacing: AppConstants.letterSpacing0_3,
                        color: Theme.of(context).primaryColor,
                      ),
                    ),
                    SizedBox(
                      height: AppSize.h5.h,
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: monday,
                          onChanged: (value) {
                            setState(() {
                              monday = value!;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "monday"),
                          style: TextStyle(
                            fontFamily: getTranslated(
                                context, "NotoKufiArabic-Regular"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: tuesday,
                          onChanged: (value) {
                            setState(() {
                              tuesday = !tuesday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "tuesday"),
                          style: TextStyle(
                            fontFamily: getTranslated(
                                context, "NotoKufiArabic-Regular"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: wednesday,
                          onChanged: (value) {
                            setState(() {
                              wednesday = !wednesday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "wednesday"),
                          style: TextStyle(
                            fontFamily: getTranslated(
                                context, "NotoKufiArabic-Regular"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: thursday,
                          onChanged: (value) {
                            setState(() {
                              thursday = !thursday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "thursday"),
                          style: TextStyle(
                            fontFamily: getTranslated(
                                context, "NotoKufiArabic-Regular"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: friday,
                          onChanged: (value) {
                            setState(() {
                              friday = !friday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "friday"),
                          style: TextStyle(
                            fontFamily: getTranslated(
                                context, "NotoKufiArabic-Regular"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: saturday,
                          onChanged: (value) {
                            setState(() {
                              saturday = !saturday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "saturday"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Row(
                      children: [
                        Checkbox(
                          value: sunday,
                          onChanged: (value) {
                            setState(() {
                              sunday = !sunday;
                            });
                          },
                        ),
                        Text(
                          getTranslated(context, "sunday"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s15.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            color: theme == "light"
                                ? Theme.of(context).primaryColor
                                : AppColors.black,
                          ),
                        ),
                      ],
                    ),
                    Center(
                      child: SizedBox(
                        height: 35.h,
                        width: size.width * 0.5.w,
                        child: MaterialButton(
                          onPressed: () {
                            workDays = "";
                            daysValue.clear;
                            widget.user.workDays!.clear();
                            if (monday) {
                              workDays = workDays +
                                  getTranslated(context, "monday") +
                                  ",";
                              daysValue.add("1");
                            }
                            if (tuesday) {
                              workDays = workDays +
                                  getTranslated(context, "tuesday") +
                                  ",";
                              daysValue.add("2");
                            }
                            if (wednesday) {
                              workDays = workDays +
                                  getTranslated(context, "wednesday") +
                                  ",";
                              daysValue.add("3");
                            }
                            if (thursday) {
                              workDays = workDays +
                                  getTranslated(context, "thursday") +
                                  ",";
                              daysValue.add("4");
                            }
                            if (friday) {
                              workDays = workDays +
                                  getTranslated(context, "friday") +
                                  ",";
                              daysValue.add("5");
                            }
                            if (saturday) {
                              workDays = workDays +
                                  getTranslated(context, "saturday") +
                                  ",";
                              daysValue.add("6");
                            }
                            if (sunday) {
                              workDays = workDays +
                                  getTranslated(context, "sunday") +
                                  ",";
                              daysValue.add("7");
                            }
                            setState(() {
                              daysController.text = workDays;
                              widget.user.workDays = daysValue;
                            });
                            Navigator.pop(context);
                          },
                          color: Theme.of(context).primaryColor,
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(25.0.r),
                          ),
                          child: Text(
                            getTranslated(context, "done"),
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              color: AppColors.white,
                              fontSize: AppFontsSizeManager.s14_5.sp,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_3,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              );
            })),
      ),
    );
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

  tabbedText(String type, String name, TextEditingController controller) {
    return Container(
      width: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.w1085.w
          : AppSize.w509.w,
      height: (kIsWeb || size.width >= AppConstants.kIsWebValue)
          ? AppSize.h95.h
          : AppSize.h53_3.h,
      child: TextFormField(
        controller: controller,
        onTap: () {
          if (type == "lang") _showLang(context, size);
          /*else if (type == "account")
            _showTypes(context, size);
          else
            _show(context, size);*/
        },
        textAlignVertical: TextAlignVertical.center,
        validator: (String? val) {
          if (val!.trim().isEmpty) {
            return 'This field is required';
          }
          return null;
        },
        readOnly: true,
        enableInteractiveSelection: true,
        style: style(size),
        maxLines: 1,
        textInputAction: TextInputAction.newline,
        keyboardType: TextInputType.multiline,
        decoration: InputDecoration(
          contentPadding: EdgeInsets.all(AppPadding.p10),
          errorStyle: style(size),
          hintStyle: style(size),
          labelText: name,
          labelStyle: TextStyle(
              fontFamily: getTranslated(context, "Ithra"),
              fontSize: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                  ? AppFontsSizeManager.s32.sp
                  : AppFontsSizeManager.s21_3.sp,
              color: AppColors.pink,
              fontWeight: FontWeight.bold),
          enabledBorder: new OutlineInputBorder(
            borderSide:
                BorderSide(width: AppSize.w0_5.w, color: AppColors.warmGrey),
            borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
          ),
          focusedBorder: new OutlineInputBorder(
            borderSide:
                BorderSide(width: AppSize.w0_5.w, color: AppColors.warmPurple4),
            borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
          ),
          border: OutlineInputBorder(
            borderSide: BorderSide(color: AppColors.greyDark),
            borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
          ),
        ),
      ),
    );
  }

  TextStyle style(Size size) {
    return TextStyle(
        fontFamily: getTranslated(context, 'Ithralight'),
        fontSize: AppFontsSizeManager.s21_3.sp,
        color: AppColors.darkGrey,
        fontWeight: FontWeight.normal);
  }

  _showLang(BuildContext ctx, size) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        SizedBox(
          height: AppSize.h16.h,
        ),
        Container(
          width: AppSize.w473.w,
          height: AppSize.h1_5.h,
          color: AppColors.grey2,
        ),
        SizedBox(
          height: AppSize.h22.h,
        ),
        Container(
          height: AppSize.h32.h,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.start,
            children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: AppSize.w3.w, color: AppColors.linear2),
                ),
                checkColor: AppColors.linear2,
                activeColor: AppColors.white,
                value: arabic,
                onChanged: (value) {
                  setState(() {
                    arabic = !arabic;
                    updateLang();
                  });
                  if (!isLangEmpty()) {
                    setState(() {
                      arabic = !arabic;
                      updateLang();
                    });
                    showSnack(getTranslated(context, "chooseLangTxt"), context);
                  }
                },
              ),
              Text(
                getTranslated(context, "ar"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Ithralight"),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  fontWeight: FontWeight.w200,
                  color: theme == "light"
                      ? AppColors.darkGrey
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        Container(
          height: AppSize.h32.h,
          child: Row(
            children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: AppSize.w3.w, color: AppColors.linear2),
                ),
                checkColor: AppColors.linear2,
                activeColor: AppColors.white,
                value: english,
                onChanged: (value) {
                  setState(() {
                    english = !english;
                    updateLang();
                  });
                  if (!isLangEmpty()) {
                    setState(() {
                      english = !english;
                      updateLang();
                    });
                    showSnack(getTranslated(context, "chooseLangTxt"), context);
                  }
                },
              ),
              Text(
                getTranslated(context, "en"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Montserrat"),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  fontWeight: FontWeight.w200,
                  color: theme == "light"
                      ? AppColors.darkGrey
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
        Container(
          height: AppSize.h32.h,
          child: Row(
            children: [
              Checkbox(
                side: MaterialStateBorderSide.resolveWith(
                  (states) =>
                      BorderSide(width: AppSize.w3.w, color: AppColors.linear2),
                ),
                checkColor: AppColors.linear2,
                activeColor: AppColors.white,
                value: french,
                onChanged: (value) {
                  setState(() {
                    french = !french;
                    updateLang();
                  });
                  if (!isLangEmpty()) {
                    setState(() {
                      french = !french;
                      updateLang();
                    });
                    showSnack(getTranslated(context, "chooseLangTxt"), context);
                  }
                },
              ),
              Text(
                getTranslated(context, "fr"),
                style: TextStyle(
                  fontFamily: getTranslated(context, "Montserrat"),
                  fontSize: AppFontsSizeManager.s21_3.sp,
                  fontWeight: FontWeight.w200,
                  color: theme == "light"
                      ? AppColors.darkGrey
                      : AppColors.pureBlack,
                ),
              ),
            ],
          ),
        ),
        SizedBox(
          height: AppSize.h21_3.h,
        ),
      ],
    );
  }

  Widget _show(BuildContext ctx, size) {
    return StatefulBuilder(builder: (context, setState) {
      return SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.start,
          children: [
            SizedBox(
              height: AppSize.h16.h,
            ),
            Container(
              width: AppSize.w473.w,
              height: AppSize.h1_5.h,
              color: AppColors.grey3,
            ),
            SizedBox(
              height: AppSize.h22.h,
            ),
            // Text(
            //   getTranslated(context, "workDays"),
            //   style: TextStyle(
            //     fontFamily: getTranslated(context, 'Ithra'),
            //     fontSize: AppFontsSizeManager.s18.sp,
            //     fontWeight: FontWeight.bold,
            //     letterSpacing: 0.3,
            //     color: theme == "light"
            //         ? Theme.of(context).primaryColor
            //         : AppColors.pureBlack,
            //   ),
            // ),
            // SizedBox(
            //   height: AppSize.h5,
            // ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: monday,
                    onChanged: (value) {
                      setState(() {
                        monday = !monday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          monday = !monday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(
                    getTranslated(context, "monday"),
                    style: TextStyle(
                      fontFamily:
                          getTranslated(context, 'NotoKufiArabic-Regular'),
                      fontWeight: FontWeight.w500,
                      fontSize: AppFontsSizeManager.s21_3.sp,
                      color: theme == "light"
                          ? AppColors.darkGrey
                          : AppColors.pureBlack,
                    ),
                  ),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: tuesday,
                    onChanged: (value) {
                      setState(() {
                        tuesday = !tuesday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          tuesday = !tuesday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "tuesday"),
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, 'NotoKufiArabic-Regular'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: wednesday,
                    onChanged: (value) {
                      setState(() {
                        wednesday = !wednesday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          wednesday = !wednesday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "wednesday"),
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, 'NotoKufiArabic-Regular'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: thursday,
                    onChanged: (value) {
                      setState(() {
                        thursday = !thursday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          thursday = !thursday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "thursday"),
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, 'NotoKufiArabic-Regular'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: friday,
                    onChanged: (value) {
                      setState(() {
                        friday = !friday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          friday = !friday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "friday"),
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, 'NotoKufiArabic-Regular'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: saturday,
                    onChanged: (value) {
                      setState(() {
                        saturday = !saturday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          saturday = !saturday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "saturday"),
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, 'NotoKufiArabic-Regular'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            SizedBox(
              height: AppSize.h21_3.h,
            ),
            Container(
              height: AppSize.h32.h,
              child: Row(
                children: [
                  Checkbox(
                    side: MaterialStateBorderSide.resolveWith(
                      (states) => BorderSide(
                          width: AppSize.w3.w, color: AppColors.linear2),
                    ),
                    checkColor: AppColors.linear2,
                    activeColor: AppColors.white,
                    value: sunday,
                    onChanged: (value) {
                      setState(() {
                        sunday = !sunday;
                        updateDays();
                      });
                      if (!isDaysEmpty()) {
                        setState(() {
                          sunday = !sunday;
                          updateDays();
                        });
                        showSnack(getTranslated(context, "chooseWorkDaysTxt"),
                            context);
                      }
                    },
                  ),
                  Text(getTranslated(context, "sunday"),
                      style: TextStyle(
                        fontFamily:
                            getTranslated(context, 'NotoKufiArabic-Regular'),
                        fontWeight: FontWeight.w500,
                        fontSize: AppFontsSizeManager.s21_3.sp,
                        color: theme == "light"
                            ? AppColors.darkGrey
                            : AppColors.pureBlack,
                      )),
                ],
              ),
            ),
            // Center(
            //   child: SizedBox(
            //     height: AppSize.h35.h,
            //     width: size.width * AppSize.w0_5.w,
            //     child: MaterialButton(
            //       onPressed: () {
            //         workDays = "";
            //         daysValue.clear;
            //         widget.user.workDays!.clear();
            //         if (monday) {
            //           workDays = workDays +
            //               getTranslated(context, "monday") +
            //               ",";
            //           daysValue.add("1");
            //         }
            //         if (tuesday) {
            //           workDays = workDays +
            //               getTranslated(context, "tuesday") +
            //               ",";
            //           daysValue.add("2");
            //         }
            //         if (wednesday) {
            //           workDays = workDays +
            //               getTranslated(context, "wednesday") +
            //               ",";
            //           daysValue.add("3");
            //         }
            //         if (thursday) {
            //           workDays = workDays +
            //               getTranslated(context, "thursday") +
            //               ",";
            //           daysValue.add("4");
            //         }
            //         if (friday) {
            //           workDays = workDays +
            //               getTranslated(context, "friday") +
            //               ",";
            //           daysValue.add("5");
            //         }
            //         if (saturday) {
            //           workDays = workDays +
            //               getTranslated(context, "saturday") +
            //               ",";
            //           daysValue.add("6");
            //         }
            //         if (sunday) {
            //           workDays = workDays +
            //               getTranslated(context, "sunday") +
            //               ",";
            //           daysValue.add("7");
            //         }
            //         setState(() {
            //           daysController.text = workDays;
            //           widget.user.workDays = daysValue;
            //         });
            //         Navigator.pop(context);
            //       },
            //       color: Theme.of(context).primaryColor,
            //       shape: RoundedRectangleBorder(
            //         borderRadius:
            //             BorderRadius.circular(AppRadius.r25.r),
            //       ),
            //       child: Text(
            //         getTranslated(context, "done"),
            //         style: TextStyle(
            //           fontFamily: getTranslated(context, "Ithra"),
            //           color: AppColors.white,
            //           fontSize: AppFontsSizeManager.s14_5.sp,
            //           letterSpacing: 0.3,
            //         ),
            //       ),
            //     ),
            //   ),
            // ),
          ],
        ),
      );
    });
  }

  bool isLangEmpty() {
    if (arabic || english || french) {
      return true;
    } else {
      return false;
    }
  }

  updateLang() {
    lang = "";
    widget.user.languages!.clear();
    if (arabic) {
      lang = lang + "" + getTranslated(context, 'ar');
      widget.user.languages!.add(getTranslated(context, 'ar'));
    }
    if (english) {
      lang = lang + " / " + getTranslated(context, 'en');
      widget.user.languages!.add(getTranslated(context, 'en'));
    }
    if (french) {
      lang = lang + " / " + getTranslated(context, 'fr');
      widget.user.languages!.add(getTranslated(context, 'fr'));
    }
    setState(() {
      langController.text = lang;
    });
  }

  updateDays() {
    workDays = "";
    daysValue.clear;
    widget.user.workDays!.clear();
    if (monday) {
      workDays = workDays + getTranslated(context, "monday") + "/";
      daysValue.add("1");
    }
    if (tuesday) {
      workDays = workDays + getTranslated(context, "tuesday") + "/";
      daysValue.add("2");
    }
    if (wednesday) {
      workDays = workDays + getTranslated(context, "wednesday") + "/";
      daysValue.add("3");
    }
    if (thursday) {
      workDays = workDays + getTranslated(context, "thursday") + "/";
      daysValue.add("4");
    }
    if (friday) {
      workDays = workDays + getTranslated(context, "friday") + "/";
      daysValue.add("5");
    }
    if (saturday) {
      workDays = workDays + getTranslated(context, "saturday") + "/";
      daysValue.add("6");
    }
    if (sunday) {
      workDays = workDays + getTranslated(context, "sunday") + "/";
      daysValue.add("7");
    }
    setState(() {
      daysController.text = workDays;
      widget.user.workDays = daysValue;
    });
  }

  bool isDaysEmpty() {
    if (monday ||
        tuesday ||
        wednesday ||
        thursday ||
        friday ||
        saturday ||
        sunday) {
      return true;
    } else {
      return false;
    }
  }

  Future<void> _pickVideo() async {
    mainVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (mainVideo != null) {
      _controller = VideoPlayerController.file(File(mainVideo!.path))
        ..initialize().then((_) {
          setState(() {});
          _controller!.play();
        });
    }
  }

  Future<void> _replaceVideo() async {
    picRepMainVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (picRepMainVideo != null) {
      VideoCubit.get(context).replaceVidController =
          VideoPlayerController.file(File(picRepMainVideo!.path))
            ..initialize().then((_) {
              //VideoCubit.get(context).replaceVidController!.play();
              VideoCubit.get(context)
                ..changeState(
                  context,
                  widget.user,
                  widget.consultVideo,
                  widget.consultUid,
                  picRepMainVideo!,
                );
            });
      // return picFirstVideo!.path;
    }
  }

  pickFirstVideo() async {
    picFirstVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (picFirstVideo != null) {
      firstVidController = VideoPlayerController.file(File(picFirstVideo!.path))
        ..initialize().then((_) {
          setState(() {});
          firstVidController!.play();
        });
      // return picFirstVideo!.path;
    }
  }

  Future<void> replaceFirstVideo() async {
    picRepFirstVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (picRepFirstVideo != null) {
      replaceFirstVidController =
          VideoPlayerController.file(File(picRepFirstVideo!.path))
            ..initialize().then((_) {
              setState(() {});
              replaceFirstVidController!.play();
            });
      // return picFirstVideo!.path;
    }
  }

  Future<void> pickSecondVideo() async {
    picSecondVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (picSecondVideo != null) {
      secondVidController =
          VideoPlayerController.file(File(picSecondVideo!.path))
            ..initialize().then((_) {
              setState(() {});
              secondVidController!.play();
            });
    }
  }

  Future<void> replaceSecondVideo() async {
    picRepSecVideo = await _picker.pickVideo(source: ImageSource.gallery);
    if (picRepSecVideo != null) {
      replaceSecondVidController =
          VideoPlayerController.file(File(picRepSecVideo!.path))
            ..initialize().then((_) {
              setState(() {});
              replaceSecondVidController!.play();
            });
      // return picFirstVideo!.path;
    }
  }

  void deleteVideo() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.user.uid);
    await docRef.get().then((value) async {
      Map data = value.data() as Map;
      print(data['link']);
      if (data['link'].toString().isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(widget.user.uid)
            .set({
          'link': null,
        }, SetOptions(merge: true));
        widget.user.link = null;
        Navigator.pop(context);
        final snackBar = SnackBar(
          content: Center(
            child: Text(
              getTranslated(context, 'YourVideoIsDeletedSuccessfully'),
              style: TextStyle(
                color: AppColors.white,
                fontSize: AppFontsSizeManager.s21.sp,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          backgroundColor: AppColors.linear1,
        );
        ScaffoldMessenger.of(context).showSnackBar(snackBar);
      }
    });
    print('Delete successful');
  }

  void deleteFirstVideo() async {
// Reference to the Firestore collection
    CollectionReference videoList =
        FirebaseFirestore.instance.collection('VideoList');

    try {
      // Query to find documents with the matching consultUid
      QuerySnapshot querySnapshot =
          await videoList.where('consultUid', isEqualTo: widget.user.uid).get();

      // Check if the query returns any documents
      if (querySnapshot.docs.isEmpty) {
        print('No matching documents.');
        return;
      }

      // Deleting each document found
      for (QueryDocumentSnapshot doc in querySnapshot.docs) {
        await videoList.doc(doc.id).delete();
        vidLinks = [];
        Navigator.pop(context);
      }
    } catch (e) {
      print("Error deleting videos: $e");
    }
  }

  void deleteSecondVideo() async {
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.videoPath)
        .doc(widget.user.uid);
    await docRef.get().then((value) async {
      Map data = value.data() as Map;
      print(data['link']);
      if (data['link'].toString().isNotEmpty) {
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(widget.user.uid)
            .set({
          'link': null,
        }, SetOptions(merge: true));
      }
    });
    Navigator.pop(context);
    print('Delete successful');
  }

  void uploadVideo(File file) async {
    var fileName = p.basename(mainVideo!.path);
    var storageRef =
        FirebaseStorage.instance.ref().child("consultVideos/$fileName");

    try {
      await storageRef.putFile(file);

      downloadurl = await storageRef.getDownloadURL();
      print("Video uploaded. Download URL: $downloadurl");

      DocumentReference _documentReference = FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.user.uid);
      DocumentSnapshot documentSnapshot = await _documentReference.get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      if (data['link'] == null) {
        await _documentReference.set({
          'link': downloadurl,
        }, SetOptions(merge: true));
      }
      Navigator.pop(context);

      final snackBar = SnackBar(
        content: Center(
          child: Text(
            getTranslated(context, "YourVideoIsUploadedSuccessfully"),
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppFontsSizeManager.s21.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: AppColors.linear1,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print("Error uploading the video: $e");
    }
  }

  Future updateFile(File file) async {
    final filename = p.basename(file!.path);
    final destination = 'consultVideos/$filename';
    task = APIs.uploadTask(destination, file!);
    if (task == null) return print('error');
    final snap = await task!.whenComplete(() {});
    final url = await snap.ref.getDownloadURL();
    downloadurl = url.toString();

    print('Link:$downloadurl');
    print('Update successful');
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.user.uid);
    await docRef.get().then((value) async {
      Map data = value.data() as Map;
      print(data['link']);
      if (data['link'] != null) {
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(widget.user.uid)
            .set({
          'link': downloadurl,
        }, SetOptions(merge: true));
      }
    });
  }

  void uploadFirstVideo(File file) async {
    print("upload 1");
    var fileName = p.basename(picFirstVideo!.path);
    var storageRef =
        FirebaseStorage.instance.ref().child("consultVideos/$fileName");
    print("upload 2");

    try {
      print("upload 3");

      await storageRef.putFile(file);

      downloadurl = await storageRef.getDownloadURL();
      print("Video uploaded. Download URL: $downloadurl");

      id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.videoPath).doc(id).set(
        {
          'link': downloadurl,
          'id': id,
          'consultUid': widget.user.uid,
        },
      );
      print("IDDD>>${id}");

      Navigator.pop(context);

      final snackBar = SnackBar(
        content: Center(
          child: Text(
            getTranslated(context, "YourVideoIsUploadedSuccessfully"),
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppFontsSizeManager.s21.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: AppColors.linear1,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print("Error uploading the video: $e");
    }
  }

  void uploadSecondVideo(File file) async {
    print("upload 1");
    var fileName = p.basename(picSecondVideo!.path);
    var storageRef =
        FirebaseStorage.instance.ref().child("consultVideos/$fileName");
    print("upload 2");

    try {
      print("upload 3");

      await storageRef.putFile(file);

      downloadurl = await storageRef.getDownloadURL();
      print("Video uploaded. Download URL: $downloadurl");

      String? id = Uuid().v4();
      await FirebaseFirestore.instance.collection(Paths.videoPath).doc(id).set(
        {
          'link': downloadurl,
          'id': id,
          'consultUid': widget.user.uid,
        },
      );
      print("IDDD>>${id}");

      Navigator.pop(context);

      final snackBar = SnackBar(
        content: Center(
          child: Text(
            getTranslated(context, "YourVideoIsUploadedSuccessfully"),
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppFontsSizeManager.s21.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: AppColors.linear1,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print("Error uploading the video: $e");
    }
  }

  Future<Map<String, dynamic>?> getFirstLinkForConsultUid2() async {
    // Reference to the collection
    CollectionReference videoList =
        FirebaseFirestore.instance.collection("VideoList");

    try {
      // Query the collection for a specific consultUid
      log("UID:   ${widget.user.uid.toString()}");
      var querySnapshot =
          await videoList.where('consultUid', isEqualTo: widget.user.uid).get();
      for (var doc in querySnapshot.docs) {
        // Do something with each document
        Map<String, dynamic> x = doc.data() as Map<String, dynamic>;
        print("Docccccc: ${doc.data()}");
        print("Linkkkkkk: ${x["link"]}");
        vidLinks.add(x["link"]);
      }
      print("List Length : ${vidLinks.length}");
      setState(() {});
    } catch (e) {
      print("Error getting document: $e");
      return null; // Return null if there's an error
    }
  }

  Future updateFirstVideo(File file) async {
    print("update>1");
    final filename = p.basename(file.path);
    final destination = 'consultVideos/$filename';
    task = APIs.uploadTask(destination, file);
    if (task == null) return print('error');
    final snap = await task!.whenComplete(() {});
    final url = await snap.ref.getDownloadURL();
    downloadurl = url.toString();
    try {
      // Reference to the Firestore collection
      var collectionRef =
          FirebaseFirestore.instance.collection(Paths.videoPath);

      // Query for the documents with the matching consultUid
      var querySnapshot = await collectionRef
          .where('consultUid', isEqualTo: widget.user.uid)
          .get();
      if (querySnapshot.docs.isNotEmpty) {
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> x = doc.data() as Map<String, dynamic>;
          vidLinks.add(x["link"]);

          await doc.reference.update({'link': downloadurl});
          print("update>7");
          print(newVideoPath);
          Navigator.pop(context);
        }
        print('Video link updated successfully.');
      } else {
        print('No matching documents found.');
      }
    } catch (e) {
      print('Error updating video link: $e');
    }
  }

  Future updateSecondVideo(File file) async {
    print("update>1");
    final filename = p.basename(file.path);
    final destination = 'consultVideos/$filename';
    task = APIs.uploadTask(destination, file);
    if (task == null) return print('error');
    final snap = await task!.whenComplete(() {});
    final url = await snap.ref.getDownloadURL();
    downloadurl = url.toString();
    try {
      // Reference to the Firestore collection
      var collectionRef =
          FirebaseFirestore.instance.collection(Paths.videoPath);
      print("update>2");
      // Query for the documents with the matching consultUid
      var querySnapshot = await collectionRef
          .where('consultUid', isEqualTo: widget.user.uid)
          .get();
      print("update>3");
      // Check if the query is not empty
      if (querySnapshot.docs.isNotEmpty) {
        print("update>4");
        // Assuming you want to update all matching documents
        for (var doc in querySnapshot.docs) {
          Map<String, dynamic> x = doc.data() as Map<String, dynamic>;
          vidLinks.add(x["link"]);
          print("update>5");
          // Update the video link for each document
          print("update>6");
          // replaceFirstVidController =
          //     VideoPlayerController.file(File(newVideoPath!));
          await doc.reference.update({'link': downloadurl});
          print("update>7");
          print(newVideoPath);
          Navigator.pop(context);
        }
        print('Video link updated successfully.');
      } else {
        print('No matching documents found.');
      }
    } catch (e) {
      print('Error updating video link: $e');
    }
  }

  Widget uploadSecondaryVideos() {
    return Container(
      width: AppSize.w244.r,
      height: AppSize.h244.r,
      decoration: BoxDecoration(
        color:
            widget.user.link == null ? AppColors.buttonBack : AppColors.white,
        borderRadius: BorderRadius.circular(AppRadius.r13.r),
        border: Border.all(
          color: AppColors.grey2,
          width: AppSize.w0_5.w,
        ),
      ),
      child: Center(
        child: InkWell(
          onTap: widget.user.link != null
              ? () async {
                  if (kIsWeb) {
                    final snackBar = SnackBar(
                      content: Center(
                        child: Text(
                          getTranslated(context, "uploadMobOnly"),
                          style: TextStyle(
                            color: AppColors.white,
                            fontSize: AppFontsSizeManager.s21.sp,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                      backgroundColor: AppColors.linear1,
                    );
                    ScaffoldMessenger.of(context).showSnackBar(snackBar);
                  } else {
                    pickSecondVideo();
                  }
                }
              : null,
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              widget.user.link == null
                  ? Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        SvgPicture.asset(
                          AssetsManager.video1IconPath,
                          width: AppSize.w36.w,
                          height: AppSize.h36.h,
                        ),
                        SizedBox(
                          height: AppSize.h13_3.h,
                        ),
                        Padding(
                          padding: EdgeInsets.symmetric(
                              horizontal: AppPadding.p13_3.w),
                          child: Text(
                            getTranslated(context, 'uploadTxt'),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                              color: AppColors.grey1,
                              fontSize: AppFontsSizeManager.s18.sp,
                              fontFamily: getTranslated(
                                  context, "NotoKufiArabic-Regular"),
                            ),
                          ),
                        ),
                      ],
                    )
                  : Center(
                      child: SvgPicture.asset(
                        AssetsManager.video1IconPath,
                        width: AppSize.w36.w,
                        height: AppSize.h36.h,
                      ),
                    ),
            ],
          ),
        ),
      ),
    );
  }
}
