import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../models/AppAppointments.dart';

class AddObjectionScreen extends StatefulWidget {
  final String consultId;
  final String userId;
  final String appointmentId;
  const AddObjectionScreen(
      {Key? key,
      required this.consultId,
      required this.userId,
      required this.appointmentId})
      : super(key: key);
  @override
  _AddObjectionScreenState createState() => _AddObjectionScreenState();
}

class _AddObjectionScreenState extends State<AddObjectionScreen> {
  final TextEditingController controller = TextEditingController();
   String theme = "light", des=" ";
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving = false, showDes = false;
  late GroceryUser user;
  bool load = true, adding = false;
  late AppAppointments _appointment;
  @override
  void dispose() {
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    getAppointment();
  }

  getAppointment() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
        .collection(Paths.appAppointments)
        .doc(widget.appointmentId)
        .get();
    setState(() {
      _appointment = AppAppointments.fromMap(documentSnapshot.data() as Map);
      load = false;
    });
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return WillPopScope(
      onWillPop: () async {
        return true;
      },
      child: Scaffold(
        body: Column(
          children: [

            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                      padding: const EdgeInsets.only( left: AppPadding.p20, right: AppPadding.p20, top: AppPadding.p10, bottom: AppPadding.p10),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          
                    CustomBackButton(),
                          // IconButton1(onPress: Navigator.of(context).pop, Width: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w97.w : AppSize.w50_6.w, Height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? 97.0.h : 50.6.h, ButtonRadius:(kIsWeb || size.width >= AppConstants.kIsWebValue) ?24.r: 10.6.r,IconWidth: 32.w,IconHeight: 32.h,IconColor: Theme.of(context).primaryColor,Icon:AssetsManager.blackArrowRightIconPath,ButtonBackground: AppColors.white,),
                          const SizedBox(width: 10),
                          Text(
                            getTranslated(context, "lessonClosed"),
                            textAlign: TextAlign.left,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: (kIsWeb||size.width >= 500)
?31:16.0,
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.w300),
                          ),
                        ],
                      ),
                    ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey, height: 1, width: size.width)),
            SizedBox(height: 50),
            load
                ? CircularProgressIndicator()
                : Expanded(
                    child: ListView(
                        padding:  EdgeInsets.symmetric(horizontal: (kIsWeb||size.width >= 500)
?size.width*.3:20),
                        children: <Widget>[
                          Form(
                            key: _formKey,
                            child: Padding(
                              padding: const EdgeInsets.all(10.0),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.center,
                                children: <Widget>[
                                  Center(
                                    child:  Container(
                                      height: 81,
                                      width: 81,
                                      decoration: BoxDecoration(
                                        border: Border.all( color: AppColors.grey, width: 1),
                                        shape: BoxShape.circle,
                                        color: AppColors.white,
                                      ),
                                      child: Container(
                                        height: 80,
                                        width: 80,
                                        decoration: BoxDecoration(
                                          border: Border.all(
                                              color: AppColors.white,
                                              width: 5),
                                          shape: BoxShape.circle,
                                          color: AppColors.white,
                                        ),
                                        child: _appointment
                                            .consult.image!.isEmpty
                                            ? Image.asset(
                                          AssetsManager.whiteJerasLogoIconPath,
                                          width: 80,
                                          height: 80,
                                          fit: BoxFit.fill,
                                        )
                                            : ClipRRect(
                                          borderRadius:
                                          BorderRadius.circular(
                                              100.0),
                                          child: FadeInImage
                                              .assetNetwork(
                                            placeholder:
                                            AssetsManager.lodeGif,
                                            placeholderScale: 0.5,
                                            imageErrorBuilder: (context,
                                                error,
                                                stackTrace) =>
                                                Image.asset(
                                                    AssetsManager.whiteJerasLogoIconPath,
                                                    width: 80,
                                                    height: 80,
                                                    fit: BoxFit.fill),
                                            image: _appointment
                                                .consult.image!,
                                            fit: BoxFit.cover,
                                            fadeInDuration: Duration(
                                                milliseconds: AppConstants.milliseconds250),
                                            fadeInCurve:
                                            Curves.easeInOut,
                                            fadeOutDuration: Duration(
                                                milliseconds: AppConstants.milliseconds150),
                                            fadeOutCurve:
                                            Curves.easeInOut,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                  Text(
                                    _appointment.consult.name!,
                                    style: TextStyle(
                                      color: AppColors.pink,
                                      fontWeight: FontWeight.w400,
                                      fontFamily: getTranslated(context, "Montserrat"),
                                      fontStyle: FontStyle.normal,
                                      fontSize: (kIsWeb||size.width >= 500)
?31:14,
                                    ),
                                  ),
                                  SizedBox(
                                    height: 25.0,
                                  ),
                                  Text(
                                    getTranslated(context, "objectiosText"),
                                    textAlign: TextAlign.center,
                                    overflow: TextOverflow.ellipsis,
                                    softWrap: true,
                                    maxLines: 6,
                                    style: TextStyle(
                                        fontFamily: getTranslated(context, "Ithra"),
                                        fontWeight:AppFontsWeightManager.bold300,
                                        fontSize: (kIsWeb||size.width >= 500)
?28:11,
                                        color: Color(0xffa7a5a5)),
                                  ),
                                  SizedBox(
                                    height: 40.0,
                                  ),
                                  Text(
                                    getTranslated(context, "haveObjection"),
                                    textAlign: TextAlign.center,
                                    style: TextStyle(
                                      fontFamily: getTranslated(context, "Ithra"),
                                      fontSize: (kIsWeb||size.width >= 500)
?33:16.0,
                                      fontWeight: AppFontsWeightManager.bold500,
                                      color: Color(0xff202020),
                                    ),
                                  ),
                                  Padding(
                                    padding:  EdgeInsets.symmetric(horizontal: (kIsWeb||size.width >= 500)
?size.width*.05:20,
                                      vertical:  (kIsWeb||size.width >= 500)
?40:20
                                    ),
                                    child: Row(
                                      mainAxisAlignment:  MainAxisAlignment.spaceBetween,
                                      crossAxisAlignment:   CrossAxisAlignment.center,
                                      mainAxisSize: MainAxisSize.max,
                                      children: <Widget>[
                                        InkWell(
                                          onTap: () async {
                                            Navigator.pop(context);
                                            Navigator.pop(context);
                                          },
                                          child: Container(
                                            height: (kIsWeb||size.width >= 500)
?70:35,
                                            width: (kIsWeb||size.width >= 500)
?120:50,
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: AppColors.white,
                                              border: Border.all( color: Color(0xff7b6c96), width: 1),
                                              borderRadius: BorderRadius.circular((kIsWeb||size.width >= 500)
?30:15.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                getTranslated(context, "no"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                    fontFamily: getTranslated(context, "Ithra"),
                                                    color: AppColors.pink,
                                                    fontSize: (kIsWeb||size.width >= 500)
?28:11.0,
                                                    fontWeight: FontWeight.w300),
                                              ),
                                            ),
                                          ),
                                        ),
                                        InkWell(
                                          onTap: () async {
                                            setState(() {
                                              showDes = true;
                                            });
                                          },
                                          child: Container(
                                            height: (kIsWeb||size.width >= 500)
?70:35,
                                            width: (kIsWeb||size.width >= 500)
?120:50,
                                            padding: const EdgeInsets.all(2),
                                            decoration: BoxDecoration(
                                              color: AppColors.pink,
                                              borderRadius: BorderRadius.circular((kIsWeb||size.width >= 500)
?30:15.0),
                                            ),
                                            child: Center(
                                              child: Text(
                                                getTranslated(context, "yes"),
                                                textAlign: TextAlign.center,
                                                style: TextStyle(
                                                  fontFamily: getTranslated(context, "Ithra"),
                                                  color: Colors.white,
                                                  fontSize: (kIsWeb||size.width >= 500)
?28:11.0,
                                                  fontWeight:AppFontsWeightManager.bold300,
                                                ),
                                              ),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ),
                                  showDes
                                      ? Padding(
                                        padding:  EdgeInsets.symmetric(horizontal:  (kIsWeb||size.width >= 500)
?size.width*.05:20,
                                        vertical:  (kIsWeb||size.width >= 500)
?40:20),
                                        child: Container(
                                            height: 150,
                                            padding: const EdgeInsets.all(5),
                                            decoration: BoxDecoration(
                                              color: Colors.white,
                                              borderRadius:    BorderRadius.circular(35.0),
                                              border: Border.all(  color: AppColors.grey, width: 1),
                                            ),
                                            child: TextFormField(
                                              maxLines: 7,
                                              maxLength: 300,
                                              style: TextStyle(
                                                fontFamily: getTranslated(context, "Ithra"),
                                                fontSize: AppFontsSizeManager.s13,
                                                color: AppColors.grey,
                                              ),
                                              cursorColor: Colors.black,
                                              initialValue: des,
                                              keyboardType:
                                              TextInputType.multiline,
                                              validator: (String? val) {
                                                if (val!.trim().isEmpty) {
                                                  return getTranslated(
                                                      context, 'required');
                                                }
                                                return null;
                                              },
                                              onSaved: (val) {
                                                des = val!;
                                              },
                                              decoration: new InputDecoration(
                                                contentPadding: EdgeInsets.all( (kIsWeb||size.width >= 500)
?30:10),
                                                counterStyle: TextStyle(
                                                  color: Colors.grey,
                                                  fontSize:  (kIsWeb||size.width >= 500)
?26:13,
                                                ),
                                                hintStyle: TextStyle(
                                                  fontFamily: getTranslated(context, "Ithra"),
                                                  color: Colors.grey,
                                                  fontSize:  (kIsWeb||size.width >= 500)
?26:13,
                                                  fontWeight: AppFontsWeightManager.semiBold,
                                                  letterSpacing: AppConstants.letterSpacing0_5,
                                                ),
                                                hintText: getTranslated(
                                                    context, 'objections'),
                                                border: InputBorder.none,
                                                focusedBorder:
                                                InputBorder.none,
                                                enabledBorder:
                                                InputBorder.none,
                                                errorBorder: InputBorder.none,
                                                disabledBorder:
                                                InputBorder.none,

                                                //  hintText: sLabel
                                              ),
                                            ),
                                          ),
                                      )
                                      : SizedBox(),
                                  SizedBox(
                                    height: 20.0,
                                  ),
                                  showDes
                                      ? adding
                                          ? CircularProgressIndicator()
                                          : InkWell(
                                              onTap: () {
                                                save();
                                              },
                                              child: Container(
                                                height:  (kIsWeb||size.width >= 500)
?80:45.0,
                                                width:  (kIsWeb||size.width >= 500)
?size.width*.3:size.width * .6,
                                                decoration: BoxDecoration(
                                                    borderRadius:
                                                        BorderRadius.circular(
                                                            (kIsWeb||size.width >= 500)
?35:10.0),
                                                    gradient: LinearGradient(
                                                      begin:
                                                          Alignment.topCenter,
                                                      end: Alignment
                                                          .bottomCenter,
                                                      colors: [
                                                        AppColors.linear1,
                                                        AppColors.linear2,
                                                        AppColors.linear2,
                                                      ],
                                                    )),
                                                child: saving
                                                    ? Center(
                                                        child:
                                                            CircularProgressIndicator())
                                                    : Center(
                                                        child: Text(
                                                          getTranslated(
                                                              context, "save"),
                                                          style: TextStyle(
                                                            fontFamily: getTranslated(context, "Ithra"),
                                                            color: Colors.white,
                                                            fontSize:  (kIsWeb||size.width >= 500)
?30:18.0,
                                                            letterSpacing: AppConstants.letterSpacing0_5,
                                                          ),
                                                        ),
                                                      ),
                                              ),
                                            )
                                      : SizedBox(),
                                  SizedBox(
                                    height: 25.0,
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ]),
                  ),
          ],
        ),
      ),
    );
  }

  Future<void> save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();

      setState(() {
        adding = true;
      });
      String objectionId = Uuid().v4();
      try {
        await FirebaseFirestore.instance
            .collection(Paths.objectionsPath)
            .doc(objectionId)
            .set({
          'objectionId': objectionId,
          'appointmentId': _appointment.appointmentId,
          'consult': {
            'uid': _appointment.consult.uid,
            'name': _appointment.consult.name,
            'image': _appointment.consult.image,
            'phone': _appointment.consult.phone,
            'countryCode': _appointment.consult.countryCode,
            'countryISOCode': _appointment.consult.countryISOCode,
          },
          'user': {
            'uid': _appointment.user.uid,
            'name': _appointment.user.name,
            'image': _appointment.user.image,
            'phone': _appointment.user.phone,
            'countryCode': _appointment.user.countryCode,
            'countryISOCode': _appointment.user.countryISOCode,
          },
          'objection': des,
          'timestamp': Timestamp.now(),
          'objectionStatus': false,
        });
        setState(() {
          adding = false;
        });
        Navigator.pop(context);
      } catch (e) {
        
      }
    }
  }
}
