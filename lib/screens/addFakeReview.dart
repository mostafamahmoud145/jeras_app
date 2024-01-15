
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';
import 'package:uuid/uuid.dart';

import '../../config/paths.dart';
import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../../models/consultReview.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../widget/custom_back_button.dart';

class AddFakeReviewScreen extends StatefulWidget {
final GroceryUser user;

  const AddFakeReviewScreen({Key? key, required this.user}) : super(key: key);
  @override
  _AddFakeReviewScreenState createState() => _AddFakeReviewScreenState();
}

class _AddFakeReviewScreenState extends State<AddFakeReviewScreen>with SingleTickerProviderStateMixin {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController controller = TextEditingController();
  late GroceryUser consult;
  bool saving=false;
  late String userName,consultPhone;
  dynamic rating=0.0,consultRating=0.0;
  String name="....",image="",theme="light";
  @override
  void initState() {
    super.initState();
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
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                child: Padding(
                  padding:  EdgeInsets.only( left: AppPadding.p20, right: AppPadding.p20, top: AppPadding.p10, bottom: AppPadding.p10),
                  child:  Row(mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      CustomBackButton(color: Colors.black),
                       SizedBox(width: AppSize.w10.w),
                      Text('Add Fake Review',
                        textAlign: TextAlign.left,
                        style: TextStyle(
                          fontWeight:AppFontsWeightManager.bold300,
                          fontFamily: getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize: (kIsWeb||size.width >= 500)
?31.sp:15.0.sp,
                          color: AppColors.black2,
                        ),
                      ),
                    ],
                  ),
                ),
              )),
          Expanded(
            child: ListView(
              children: <Widget>[Form(
                key: _formKey,
                child: Padding(
                  padding:  EdgeInsets.only(
                      left: (kIsWeb||size.width >= 500)
?size.width*.3:16.0,
                      right: (kIsWeb||size.width >= 500)
?size.width*.3:16.0, bottom:AppPadding.p16, top: AppPadding.p16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[

                      SizedBox(
                        height: 25.0.h,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }
                          return null;
                        },
                        onSaved: (val) {
                          userName=val!;
                        },
                       enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            //color: AppColors.black54,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          //prefixIcon: Icon(Icons.title),
                          labelText: getTranslated(context, "userName"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.r12.r),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0.h,
                      ),
                      TextFormField(
                        textAlignVertical: TextAlignVertical.center,
                        validator: (String? val) {
                          if (val!.trim().isEmpty) {
                            return getTranslated(context, 'required');
                          }
                          return null;
                        },
                        onSaved: (val) {
                          consultPhone=val!;
                        },
                       enableInteractiveSelection: true,
                        style: GoogleFonts.poppins(
                          color: Colors.black,
                          fontSize: AppFontsSizeManager.s14_5.sp,
                          fontWeight: AppFontsWeightManager.bold500,
                          letterSpacing: AppConstants.letterSpacing0_5,
                        ),
                        minLines: 1,
                        maxLines: 3,
                        textInputAction: TextInputAction.done,
                        keyboardType: TextInputType.multiline,
                        textCapitalization: TextCapitalization.sentences,
                        decoration: InputDecoration(
                          contentPadding:
                          EdgeInsets.symmetric(horizontal: AppPadding.p15),
                          helperStyle: GoogleFonts.poppins(
                            color: Colors.black.withOpacity(0.65),
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          errorStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s13.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          hintStyle: GoogleFonts.poppins(
                            //color: AppColors.black54,
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          //prefixIcon: Icon(Icons.title),
                          labelText: getTranslated(context, "consultPhone"),
                          labelStyle: GoogleFonts.poppins(
                            fontSize: AppFontsSizeManager.s14_5.sp,
                            fontWeight: AppFontsWeightManager.bold500,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(AppRadius.r12.r),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 15.0.h,
                      ),
                      Center(
                        child: SmoothStarRating(
                          allowHalfRating: true,
                          onRatingChanged: (v) {
                            setState(() {
                              rating = v;
                            });
                          },
                          starCount: 5,
                          rating: rating,
                          size: 38.0,
                          color: Colors.orange.shade500,
                          borderColor: Colors.orange.shade500,
                          spacing: 1.0,
                        ),
                      ),
                      SizedBox(
                        height: 5.0.h,
                      ),
                      Padding(
                        padding: const EdgeInsets.all(AppPadding.p5),
                        child: TextFormField(
                          textAlignVertical: TextAlignVertical.center,
                          maxLines: 10,
                          controller: controller,

                          enableInteractiveSelection: true,
                          style: GoogleFonts.poppins(
                            color: Colors.black,
                            fontSize: 11.0.sp,
                            letterSpacing: AppConstants.letterSpacing0_5,
                          ),
                          textInputAction: TextInputAction.done,
                          keyboardType: TextInputType.multiline,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: Colors.grey[100],
                            enabledBorder: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(AppRadius.r10.r),
                              borderSide: BorderSide(
                                color:  Colors.grey.shade100,
                                width: 0.0,
                              ),
                            ),
                            /* border: OutlineInputBorder(
                                      borderRadius: BorderRadius.circular(AppRadius.r10),
                                      borderSide:  BorderSide(color: Colors.white ),
                                  ),*/
                            contentPadding: EdgeInsets.all(10),
                            helperStyle: GoogleFonts.poppins(
                              color: Colors.black.withOpacity(0.65),
                              letterSpacing: AppConstants.letterSpacing0_5,
                            ),
                            errorStyle: GoogleFonts.poppins(
                              fontSize: 11.0.sp,
                            ),
                            hintStyle: GoogleFonts.poppins(
                              color: Colors.grey,
                              fontSize: 11.sp,
                            ),
                            hintText: getTranslated(context,'rateConsult'),
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.h,
                      ),
                      Container(
                        height: 45.0.h,
                        width:(kIsWeb||size.width >= 500)
?size.width*.15: double.infinity,
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
                              Icon(
                                Icons.send,
                                color: theme=="light"?Colors.white:Colors.black,
                                size: 20.0,
                              ),
                              SizedBox(
                                width: 10.0.w,
                              ),
                              Text(
                                getTranslated(context, "save"),
                                style: GoogleFonts.poppins(
                                  color: theme=="light"?Colors.white:Colors.black,
                                  fontSize: 15.0.sp,
                                  fontWeight: AppFontsWeightManager.semiBold,
                                  letterSpacing: AppConstants.letterSpacing0_3,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                      SizedBox(
                        height: 25.0.h,
                      ),
                    ],
                  ),
                ),
              ),]
            ),
          ),
        ],
      ),
    );
  }

  save() async {
    List<GroceryUser> consults=[];
    if (_formKey.currentState!.validate()) {
      _formKey.currentState!.save();
      try{
        setState(() {
          saving=true;
        });
        //get consultdata
        QuerySnapshot querySnapshot2 = await  FirebaseFirestore.instance.collection(Paths.usersPath)
            .where( 'phoneNumber', isEqualTo: consultPhone, ).get();

        for (var doc in querySnapshot2.docs) {
          consults.add(GroceryUser.fromMap(doc.data() as Map));
        }
        if(consults.length>0)
          consult=consults[0];

        if(rating!=0.0) {
          String reviewId=Uuid().v4();
          await FirebaseFirestore.instance.collection(Paths.consultReviewsPath).doc(reviewId).set({
            'rating': double.parse((rating.toString())),
            'review': controller.text,
            'uid': widget.user.uid,
            'name': userName,
            'image': "",
            'consultUid': consult.uid,
            'appointmentId':Uuid().v4(),
            'reviewTime':Timestamp.now(),
            'consultName': consult.name,
            'consultImage': consult.photoUrl,
            'type':'fake'
          } );
          List<ConsultReview> reviews;
            QuerySnapshot snap = await FirebaseFirestore.instance
                .collection(Paths.consultReviewsPath)
                .where('consultUid', isEqualTo: consult.uid)
                .get();

            reviews = List<ConsultReview>.from(
              (snap.docs).map(
                    (e) => ConsultReview.fromMap(e.data() as Map),
              ),
            );
            double _rating=0;
            if (reviews.length > 0) {
              for (var review in reviews) {
                _rating = _rating + double.parse(review.rating.toString());
              }
              _rating = _rating / reviews.length;
              _rating=double.parse((_rating.toStringAsFixed(1)));
              await FirebaseFirestore.instance.collection(Paths.usersPath).doc(consult.uid).set({
                'rating': _rating,
                'reviewsCount':reviews.length,

              }, SetOptions(merge: true));
            }
          appointmentDialog(MediaQuery.of(context).size,"add done successfully",true);
        }
        else
        {
          appointmentDialog(MediaQuery.of(context).size,"something goes wrong",false);
        }
        setState(() {
          saving=false;
        });
      }catch(e)
      {}
    }

  }
  appointmentDialog(Size size,String data,bool status) {

    return showDialog(
      builder: (context) => AlertDialog(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(
            Radius.circular(15.0.r),
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
             " Fake review",
              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                fontSize: AppFontsSizeManager.s14_5.sp,
                fontWeight: AppFontsWeightManager.semiBold,
                letterSpacing: AppConstants.letterSpacing0_3,
                 color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: 15.0.h,
            ),
            Text(
              status?"Success":"Error",
              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                fontSize: 14.0.sp,
                fontWeight: AppFontsWeightManager.bold500,
                letterSpacing: AppConstants.letterSpacing0_3,
                color: status?Colors.black87:Colors.red,
              ),
            ),
            Text(
              data,
              style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                fontSize: 15.0.sp,
                fontWeight: FontWeight.bold,
                letterSpacing: AppConstants.letterSpacing0_3,
                 color: AppColors.black87,
              ),
            ),
            SizedBox(
              height: 5.0.h,
            ),
            Center(
              child: Container(
                width: size.width*.5,
                child: MaterialButton(
                  color: Theme.of(context).primaryColor,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(25.0.r),
                  ),
                  padding: const EdgeInsets.all(0.0),
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  child: Text(
                    getTranslated(context, 'Ok'),
                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                       color: AppColors.black87,
                      fontSize: 13.5.sp,
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
}
