/*

import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:http/http.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:uuid/uuid.dart';

import '../../models/payInfo.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
class PayInfo2Screen extends StatefulWidget {
  final String consultUid;


  const PayInfo2Screen({Key? key, required this.consultUid}) : super(key: key);
  @override
  _PayInfo2ScreenState createState() => _PayInfo2ScreenState();
}

class _PayInfo2ScreenState extends State<PayInfo2Screen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  Map<dynamic, dynamic> adminMap = Map();
  var image;
  var selectedImage;
  bool isAdding=false,load=true;
  PayInfo consult=new PayInfo();
  late GroceryUser user;
  @override
  void initState() {
    super.initState();
    getConsultDetails();


  }
  Future<void> getConsultDetails() async {
    DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).get();
    PayInfo currentUser = PayInfo.fromMap(documentSnapshot.data() as Map);

    DocumentSnapshot documentSnapshotUser = await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultUid).get();
    GroceryUser userData = GroceryUser.fromMap(documentSnapshotUser.data() as Map);
    setState(() {
      consult=currentUser;
      user=userData;
      load=false;
    });

  }




  save() async {
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      setState(() {
        isAdding=true;
      });
      await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).set({
        'id':widget.consultUid,
        'businessNameAr': consult.businessNameAr,
        'businessNameEn': consult.businessNameEn,
        'entityNameAr': consult.entityNameAr,
        'entityNameEn': consult.entityNameEn,
        'email': consult.email,
        'iban': consult.iban,
        'brandNameAr': "غراس",
        'brandNameEn': "jeras",
      }, SetOptions(merge: true));
     addBusiness();

    }

  }


  void showSnack(String text, BuildContext context) {
    Fluttertoast.showToast(
        msg: text,
        toastLength: Toast.LENGTH_SHORT,
        gravity: ToastGravity.BOTTOM,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16);
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding( padding: const EdgeInsets.only(
                      left: 10.0, right: 10.0, top: 0.0, bottom: 6.0),
                    child: Row(mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        Container(
                          height: AppSize.h35,
                          width: AppSize.w35,

                          child: Center(
                            child: IconButton(
                              onPressed: () {

                                Navigator.pop(context);
                              },
                              icon: Image.asset(
                                AssetsManager.rightArrowIconPath,
                                width: 30,
                                height: 30,
                              ),
                            ),
                          ),
                        ),
                        Text(
                          getTranslated(context, "paymentInfo"),
                          textAlign:TextAlign.left,
                          style: TextStyle(fontFamily: getTranslated(context, "Ithra"),fontSize: AppFontsSizeManager.s16,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
                        ),



                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey, height: 2, width: size.width * .9)),

          Padding(
            padding: const EdgeInsets.only(left: 20,right: 20,top: 20,bottom: 5),
            child: Container(
              padding: const EdgeInsets.only(left: 20,right: 20,top: 5,bottom: 5),
              decoration: BoxDecoration(
                border: Border.all( color: AppColors.pink, width: 1, ),
                borderRadius: BorderRadius.circular(AppRadius.r10),
              ),
              child: Text(
                getTranslated(context, "step2"),
                textAlign:TextAlign.left,
                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),fontSize: 11.0,color:Colors.black.withOpacity(0.8), fontWeight: FontWeight.bold),
              ),
            ),
          ),
          load?CircularProgressIndicator():Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(
                horizontal: 16.0,
                vertical: 16.0,
              ),
              children: <Widget>[
                Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      SizedBox(height: 10,),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        initialValue: consult.businessNameAr,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.businessNameAr=val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
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
                           color: AppColors.black54,
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.perm_identity),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: getTranslated(context,"businessNameAr"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.businessNameEn,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.businessNameEn=val;

                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
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
                           color: AppColors.black54,
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.person),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: getTranslated(context,"businessNameEn"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.entityNameAr,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.entityNameAr=val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
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
                           color: AppColors.black54,
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.home_repair_service_outlined),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: getTranslated(context,"entityNameAr"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.entityNameEn,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.entityNameEn=val;

                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
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
                           color: AppColors.black54,
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.home_repair_service),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: getTranslated(context,"entityNameEn"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.email,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, "required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.email=val;
                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.text,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
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
                           color: AppColors.black54,
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.alternate_email_outlined),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: getTranslated(context,"email"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
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
                        initialValue: consult.iban,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context,"required");
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consult.iban=val;

                        },
                        enableInteractiveSelection: true,
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          color: Colors.black,
                          fontSize: 12,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.name,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
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
                           color: AppColors.black54,
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          prefixIcon: Icon(Icons.comment_bank_rounded),
                          prefixStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          labelText: "IBAN",//getTranslated(context,"iban"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.r12),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0,
                      ),
                      isAdding?Center(child: CircularProgressIndicator()):Container(
                        height: 45.0,
                        width: double.infinity,
                        padding: const EdgeInsets.symmetric(horizontal: 0.0),
                        child: MaterialButton(
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
                                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                  color: Colors.white,
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
              ],
            ),
          ),
        ],
      ),
    );
  }
  addBusiness() async {
    String responseBody="";
    try{

      final uri = Uri.parse('https://api.tap.company/v2/business');
      final headers = {
        'Content-Type': 'application/json',
         'Accept': 'application/json',
        //'Authorization':"Bearer sk_test_EDqvMW8yPOZuLlStr0iX3GVb",
        'Authorization':"Bearer sk_live_by1n4NowKfd6ipjPYZhl3Vms",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      Map<String, dynamic> body ={
        "name": {
            "en": consult.businessNameEn,
            "ar": consult.businessNameAr
            },
        "type": "ind",
        "entity": {
            "legal_name": {
            "en":consult.entityNameEn,
            "ar": consult.entityNameAr
            },
        "country": user.countryISOCode,
        "bank_account": {
        "iban": consult.iban
        }
        },
        "contact_person": {
        "name": {
            "title": "Mr",
            "first": consult.fullName!.split(" ")[0],
            "middle":consult.fullName!.split(" ")[1],
            "last": consult.fullName!.split(" ")[2],
          },
        "contact_info": {
        "primary": {
        "email": consult.email,
        "phone": {
        "country_code":user.countryCode!.replaceAll("+", "").trim(),
        "number": user.phoneNumber!.replaceAll(user.countryCode!, "").trim(),
        }
        }
        },
        },
        "brands": [
        {
        "name": {
        "en": "jeras",
        "ar": "غراس"
        },
        "sector": [
        "Media",
        ],
        "website": "https://www.flexwares.company/",
        "social": [
        "https://twitter.com/flexwares",
        "https://www.linkedin.com/company/flexwares/"
        ],

        }
        ],
        "post": {
        "url": "http://flexwares.company/post_url"
        },
        "metadata": {
        "mtd": "metadata"
        }
        };
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
       responseBody = response.body;
      var res = json.decode(responseBody);
      consult.businessId=res['id'];
      consult.entityId=res['entity']['id'];
      await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).set({
        'businessId':consult.businessId,
        'entityId': consult.entityId,
      }, SetOptions(merge: true));
      addDestination();
    }catch(e){
      
      errorLog("addBusiness",responseBody);
      setState(() {
        isAdding=false;
      });
      //showSnack(getTranslated(context, "failed"),context);
      showSnack(responseBody.toString(),context);
    }

  }
  addDestination() async {
   String  responseBody="";
    try{

      final uri = Uri.parse('https://api.tap.company/v2/destination');
      final headers = {
        'Content-Type': 'application/json',
        // 'Accept': 'application/json',
        //'Authorization':"Bearer sk_test_EDqvMW8yPOZuLlStr0iX3GVb",
        'Authorization':"Bearer sk_live_by1n4NowKfd6ipjPYZhl3Vms",
        'Connection':'keep-alive',
        'Accept-Encoding':'gzip, deflate, br'
      };
      Map<String, dynamic> body ={
        "display_name": consult.businessNameEn,
        "business_id": consult.businessId,
        "business_entity_id": consult.entityId,
        "bank_account": {
          "iban": consult.iban
        }
      };
      String jsonBody = json.encode(body);
      final encoding = Encoding.getByName('utf-8');
      var response = await post(
        uri,
        headers: headers,
        body: jsonBody,
        encoding: encoding,
      );
       responseBody = response.body;
      var res = json.decode(responseBody);
      await FirebaseFirestore.instance.collection(Paths.payInfoPath).doc(widget.consultUid).set({
        'destinationId':res['id'],
      }, SetOptions(merge: true));
      await FirebaseFirestore.instance.collection(Paths.usersPath).doc(widget.consultUid).set({
        'destinationId':res['id'],
      }, SetOptions(merge: true));
      setState(() {
        isAdding=false;
      });
      Navigator.pop(context);
      Navigator.pop(context);
    }catch(e){
      
      errorLog("addDestination",responseBody.toString());
      setState(() {
        isAdding=false;
      });
      showSnack(e.toString(),context);
    }

  }
  errorLog(String function,String error)async {
    String id = Uuid().v4();
    await FirebaseFirestore.instance.collection(Paths.errorLogPath)
        .doc(id)
        .set({
      'timestamp': Timestamp.now(),
      'id': id,
      'seen': false,
      'desc': error,
      'phone': user == null ? "phone" : user.phoneNumber,
      'screen': "payInfo2",
      'function': function,
    });
  }
}*/
