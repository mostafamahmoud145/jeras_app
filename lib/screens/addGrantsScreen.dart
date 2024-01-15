import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../controller/blocs/account_bloc/account_bloc.dart';
class AddGrantsScreen extends StatefulWidget {
  final GroceryUser loggedUser;
  const AddGrantsScreen({Key? key, required this.loggedUser}) : super(key: key);
  @override
  _AddGrantsScreenState createState() => _AddGrantsScreenState();
}

class _AddGrantsScreenState extends State<AddGrantsScreen>with SingleTickerProviderStateMixin {
  late AccountBloc accountBloc;
  late GroceryUser user;
  bool load=false,showBalance=true,showHistory=false;
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  bool saving=false,publicSpeaking=false,educationAndTeaching=false,advocacyWork=false;
  late GroceryUser searchUser;
  //var personalImage,personalIdImage,quranImage;
  var selectedPersonalImage,selectedPersonalImageId,selectedQueanImage;
  late String  name,country,phone,school,education,age,grantDate,langLevel,personalIdPhoto,personalPhoto,quranLevel,quranPhoto,referance,scienceLevel,theme;
  late List<dynamic>futureWork;
  @override
  void initState() {
    super.initState();
    accountBloc = BlocProvider.of<AccountBloc>(context);
     accountBloc.add(GetLoggedUserEvent());
    accountBloc.stream.listen((state) {
      if (state is GetAccountDetailsCompletedState) {
        user = state.user;
        if(mounted)
          setState(() {
            load=false;
          });
      }
    });
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
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body:
      Column(
        children: <Widget>[
          Container(
            width: size.width,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, top: 0.0, bottom: AppPadding.p16),
                child: Container(height: 80,
                  child:Row(
                    mainAxisAlignment: MainAxisAlignment.start,
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
                      Expanded(
                        child: Text(
                          getTranslated(context, "grantRequest"),
                          overflow: TextOverflow.ellipsis,
                          softWrap: true,
                          maxLines: 3,
                          style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                            color: theme=="light"?Colors.white:Colors.black,
                            fontSize: 20.0,
                            fontWeight: AppFontsWeightManager.semiBold,
                            letterSpacing: AppConstants.letterSpacing0_3,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: AppSize.w20,
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          SizedBox(height: 10,),
          Expanded(
            child: ListView(padding:const EdgeInsets.only(left: 10,right: 10),
                children: <Widget>[
                  widget.loggedUser.sendGrant!?SizedBox(height: 50,):SizedBox(height: 1,),
                  widget.loggedUser.sendGrant!? Center(
                    child: Text(
                      getTranslated(context, "grantAdded"),
                      textAlign:TextAlign.center,
                      overflow: TextOverflow.ellipsis,
                      softWrap: true,
                      maxLines: 3,
                      style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                        color: Colors.black,
                        fontSize: AppFontsSizeManager.s15,
                        fontWeight: AppFontsWeightManager.semiBold,
                        letterSpacing: AppConstants.letterSpacing0_3,
                      ),
                    ),
                  ):Form(
                    key: _formKey,
                    child: Padding(
                      padding: const EdgeInsets.all(10.0),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[

                          Center(
                            child: Container(height: AppSize.h35,width: size.width*.7,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                border: Border.all(color:  theme=="light"?Theme.of(context).primaryColor:Colors.black,width: 1),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context,"personalInformation"),
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.black,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                  ),),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              name=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.person_outline,color: AppColors.pink,),
                              labelText: getTranslated(context, "name"),
                              hintText:  getTranslated(context, "name"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              phone=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.phone,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.call,color:AppColors.pink),
                              labelText: getTranslated(context, "phoneNumber"),
                              hintText: "+966XXXXXXXXX",
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              country=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.language,color: AppColors.pink,),
                              labelText: getTranslated(context, "country"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              age=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.number,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.date_range,color: AppColors.pink,),
                              labelText: getTranslated(context, "age"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              school=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink,),
                              labelText: getTranslated(context, "school"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              education=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.cast_for_education,color: AppColors.pink,),
                              labelText: getTranslated(context, "education"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              referance=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            minLines: 1,
                            maxLines: 3,
                            textInputAction: TextInputAction.done,
                            keyboardType: TextInputType.text,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding:
                              EdgeInsets.symmetric(horizontal: AppPadding.p15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.file_copy_outlined,color: AppColors.pink,),
                              labelText: getTranslated(context, "referance"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          Text(
                            getTranslated(context,"personalPhoto"),
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s13,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          Center(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: size.width * 0.45,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.r20),
                                    color: theme=="light"?Colors.white:Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 0.0),
                                        blurRadius: 15.0,
                                        spreadRadius: 2.0,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r20),
                                    child: selectedPersonalImage == null
                                        ? Icon(
                                      Icons.image,
                                      size:AppSize.w50
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      child: Image.file(
                                        selectedPersonalImage,
                                      ),
                                    ),
                                  ),
                                ),
                                selectedPersonalImage != null
                                    ? Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r10),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.6),
                                        onTap: () {
                                          cropImage(context,"personalPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.edit,
                                            color:theme=="light"?Colors.white:Colors.black,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r10),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.6),
                                        onTap: () {
                                          cropImage(context,"personalPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          Text(
                            getTranslated(context,"personalPhotoId"),
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s13,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          Center(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: size.width * 0.45,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.r20),
                                    color: theme=="light"?Colors.white:Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 0.0),
                                        blurRadius: 15.0,
                                        spreadRadius: 2.0,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r20),
                                    child: selectedPersonalImageId == null
                                        ? Icon(
                                      Icons.image,
                                      size:AppSize.w50
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      child: Image.file(
                                        selectedPersonalImageId,
                                      ),
                                    ),
                                  ),
                                ),
                                selectedPersonalImageId != null
                                    ? Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r10),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.6),
                                        onTap: () {
                                          cropImage(context,"personalPhotoId");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.edit,
                                            color:theme=="light"?Colors.white:Colors.black,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r10),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.6),
                                        onTap: () {
                                          cropImage(context,"personalPhotoId");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: Container(height: AppSize.h35,width: size.width*.7,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                border: Border.all(color:  theme=="light"?Theme.of(context).primaryColor:Colors.black,width: 1),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context,"education"),
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.black,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                  ),),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              scienceLevel=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 150,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink),
                              labelText: getTranslated(context, "scienceLevel"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),

                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              langLevel=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 150,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink),
                              labelText: getTranslated(context, "langLevel"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          TextFormField(
                            textAlignVertical: TextAlignVertical.center,
                            validator: (String? val){
                              if (val!.trim().isEmpty) {
                                return getTranslated(context, 'required');
                              }
                              return null;
                            },
                            onSaved: (val) {
                              quranLevel=val!;
                            },
                            enableInteractiveSelection: true,
                            style: GoogleFonts.poppins(
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s14_5,
                              fontWeight: AppFontsWeightManager.bold500,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            textInputAction: TextInputAction.newline,
                            minLines: 3,
                            maxLines: 5,
                            maxLength: 150,
                            keyboardType: TextInputType.multiline,
                            textCapitalization: TextCapitalization.sentences,
                            decoration: InputDecoration(
                              contentPadding: EdgeInsets.symmetric(horizontal: 15.0,vertical: 15),
                              focusedBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: AppColors.pink, width: 1.0),
                              ),
                              enabledBorder: OutlineInputBorder(
                                borderSide: BorderSide(color: Colors.grey, width: 1.0),
                              ),
                              helperStyle: GoogleFonts.poppins(
                                color: Colors.black.withOpacity(0.65),
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              errorStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s13,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              hintStyle: GoogleFonts.poppins(
                                //color: AppColors.black54,
                                fontSize: AppFontsSizeManager.s14_5,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              prefixIcon: Icon(Icons.school,color: AppColors.pink),
                              labelText: getTranslated(context, "quranLevel"),
                              labelStyle: GoogleFonts.poppins(
                                fontSize: AppFontsSizeManager.s14_5,
                                color:theme=="light"?Colors.black:Colors.white,
                                fontWeight: AppFontsWeightManager.bold500,
                                letterSpacing: AppConstants.letterSpacing0_5,
                              ),
                              border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r12),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Text(
                            getTranslated(context,"quranPhoto"),
                            style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                              color: Colors.black,
                              fontSize: AppFontsSizeManager.s13,
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),),
                          SizedBox(
                            height: AppSize.h15,
                          ),
                          Center(
                            child: Stack(
                              children: <Widget>[
                                Container(
                                  height: size.width * 0.45,
                                  width: size.width * 0.7,
                                  decoration: BoxDecoration(
                                    borderRadius: BorderRadius.circular(AppRadius.r20),
                                    color: theme=="light"?Colors.white:Colors.transparent,
                                    boxShadow: [
                                      BoxShadow(
                                        offset: Offset(0, 0.0),
                                        blurRadius: 15.0,
                                        spreadRadius: 2.0,
                                        color: Colors.black.withOpacity(0.05),
                                      ),
                                    ],
                                  ),
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r20),
                                    child: selectedQueanImage == null
                                        ? Icon(
                                      Icons.image,
                                      size:AppSize.w50
                                    )
                                        : ClipRRect(
                                      borderRadius:
                                      BorderRadius.circular(20.0),
                                      child: Image.file(
                                        selectedQueanImage,
                                      ),
                                    ),
                                  ),
                                ),
                                selectedQueanImage != null
                                    ? Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r10),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.6),
                                        onTap: () {
                                          cropImage(context,"quranPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.edit,
                                            color:theme=="light"?Colors.white:Colors.black,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                )
                                    : Positioned(
                                  top: 10.0,
                                  right: 10.0,
                                  child: ClipRRect(
                                    borderRadius: BorderRadius.circular(AppRadius.r10),
                                    child: Material(
                                      color: Theme.of(context).primaryColor,
                                      child: InkWell(
                                        splashColor:
                                        Colors.white.withOpacity(0.6),
                                        onTap: () {
                                          cropImage(context,"quranPhoto");
                                        },
                                        child: Container(
                                          decoration: BoxDecoration(),
                                          width: 30.0,
                                          height: 30.0,
                                          child: Icon(
                                            Icons.add,
                                            color: Colors.white,
                                            size: 16.0,
                                          ),
                                        ),
                                      ),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Center(
                            child: Container(height: AppSize.h35,width: size.width*.7,
                              padding: const EdgeInsets.all(5),
                              decoration: BoxDecoration(
                                color:Colors.white,
                                borderRadius: BorderRadius.circular(35.0),
                                border: Border.all(color:  theme=="light"?Theme.of(context).primaryColor:Colors.black,width: 1),

                              ),child:  Center(
                                child: Text(
                                  getTranslated(context,"futureWork"),
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: Colors.black,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_5,
                                  ),),
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25,
                          ),
                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: publicSpeaking,
                                onChanged: (value) {
                                  setState(() {
                                    publicSpeaking = !publicSpeaking;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "publicSpeaking"),
                                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: AppFontsSizeManager.s15,
                                  color: Colors.black,

                                ),
                              ),
                            ],
                          ),

                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: educationAndTeaching,
                                onChanged: (value) {
                                  setState(() {
                                    educationAndTeaching = !educationAndTeaching;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "educationAndTeaching"),
                                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: AppFontsSizeManager.s15,
                                  color: Colors.black,

                                ),
                              ),
                            ],
                          ),

                          Row(mainAxisAlignment: MainAxisAlignment.start,
                            children: [
                              Checkbox(
                                value: advocacyWork,
                                onChanged: (value) {
                                  setState(() {
                                    advocacyWork = !advocacyWork;
                                  });
                                },
                              ),
                              Text(
                                getTranslated(context, "advocacyWork"),
                                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                  fontSize: AppFontsSizeManager.s15,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                          SizedBox(
                            height: 25.0,
                          ),

                          Container(
                            height: 45.0,
                            width: double.infinity,
                            padding:
                            const EdgeInsets.symmetric(horizontal: 0.0),
                            child: saving?Center(child: CircularProgressIndicator()):MaterialButton(
                              onPressed: () {
                                save();
                              },
                              color: Theme.of(context).primaryColor,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(AppRadius.r15.r),
                              ),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: <Widget>[

                                  Text(
                                    getTranslated(context, "save"),
                                    style: GoogleFonts.poppins(
                                      color:theme=="light"?Colors.white:Colors.black,
                                      fontSize: AppFontsSizeManager.s15,
                                      fontWeight: AppFontsWeightManager.semiBold,
                                      letterSpacing: AppConstants.letterSpacing0_3,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                          SizedBox(
                            height: 25.0,
                          ),
                        ],
                      ),
                    ),
                  ),
                ]),
          )


        ],
      ),
    );
  }
  Future cropImage(context,String type) async {
    var image = await ImagePicker().pickImage(source: ImageSource.gallery);
    File croppedFile =File(image!.path);

    if (croppedFile != null) {
      if(type=="personalPhoto")
        setState(() {
          selectedPersonalImage = croppedFile;
        });
      else if(type=="personalPhotoId")
        setState(() {
          selectedPersonalImageId = croppedFile;
        });
      else
        setState(() {
          selectedQueanImage = croppedFile;
        });

    } else {
      //not croppped

    }
  }
  save() async {

    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try{
        if(selectedQueanImage!=null&&selectedPersonalImageId!=null&&selectedPersonalImage!=null)
        {
          setState(() {
            saving=true;
          });
          if (selectedPersonalImage != null) {
            var uuid1 = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('grants/$uuid1');
            await storageReference.putFile(selectedPersonalImage);
            personalPhoto = await storageReference.getDownloadURL();
          }
          if (selectedPersonalImageId != null) {
            var uuid2 = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('grants/$uuid2');
            await storageReference.putFile(selectedPersonalImageId);
            personalIdPhoto = await storageReference.getDownloadURL();
          }
          if (selectedQueanImage != null) {
            var uuid3 = Uuid().v4();
            Reference storageReference = FirebaseStorage.instance
                .ref()
                .child('grants/$uuid3');
            await storageReference.putFile(selectedQueanImage);
            quranPhoto = await storageReference.getDownloadURL();
          }
          futureWork=[];
          if(publicSpeaking)
            futureWork.add("publicSpeaking");
          if(educationAndTeaching)
            futureWork.add("educationAndTeaching");
          if(advocacyWork)
            futureWork.add("advocacyWork");
          String grantId=Uuid().v4();
          await FirebaseFirestore.instance.collection(Paths.grantsPath)
              .doc(grantId)
              .set({
            "userUid":widget.loggedUser.uid,
            'grantId': grantId,
            'status':"new",
            'grantDate': Timestamp.now(),
            'name': name,
            'age':age,
            'country': country,
            'phone':phone,
            'education': education,
            'school':school,
            'langLevel': langLevel,
            'quranLevel':quranLevel,
            'scienceLevel': scienceLevel,
            'referance':referance,
            'personalPhoto': personalPhoto,
            'personalPhoto':personalPhoto,
            'personalIdPhoto': personalIdPhoto,
            'quranPhoto':quranPhoto,
            'futureWork':futureWork



          });
          await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.loggedUser.uid).set({
            'sendGrant':true,
          }, SetOptions(merge: true));
           accountBloc.add(GetLoggedUserEvent());
          setState(() {
            saving = false;
          });
          addingDialog(MediaQuery.of(context).size,true);
        }
        else
        {
          showSnakbar(getTranslated(context, "enterAll"), false);
        }

      }catch(e)
      {}
    }

  }
  addingDialog(Size size,bool status) {

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
        content: Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Text(
              getTranslated(context, "grants"),
              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s14_5,
                fontWeight: AppFontsWeightManager.semiBold,
                letterSpacing: AppConstants.letterSpacing0_3,
                 color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: AppSize.h15,
            ),

            Text(
              getTranslated(context, "grantAdded"),
              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s15,
                fontWeight: FontWeight.bold,
                letterSpacing: AppConstants.letterSpacing0_3,
                 color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: 5.0,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                       color: AppColors.black87,
                      fontSize: 13.5,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ), barrierDismissible: false,
      context: context,
    );
  }

  void showSnakbar(String s,bool status) {

    Fluttertoast.showToast(
        msg: s,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }
}
