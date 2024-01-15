import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:jeras/widget/default_text_widget.dart';
import 'package:jeras/widget/responsive.dart';

import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../localization/localization_methods.dart';
import '../models/user.dart';
import '../screens/ConsultantDetailsScreen.dart';

class UserListItem extends StatefulWidget {
  //final CourseConsult courseConsult;
  final GroceryUser groceryUser;
  final String uidCourse;

  UserListItem({required this.groceryUser, required this.uidCourse});

  @override
  State<UserListItem> createState() => _UserListItemState();
}

class _UserListItemState extends State<UserListItem> {
  bool delete = false;

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return GestureDetector(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            settings: RouteSettings(
                name: 'conslultant?consultant_id=${widget.groceryUser.uid}',
                arguments: {"consultant_id": widget.groceryUser.uid}),
            builder: (context) => ConsultantDetailsScreen(
              consoltantId: '${widget.groceryUser.uid}',
            ),
          ),
        );
      },
      child: Container(
        padding: const EdgeInsets.all(AppPadding.p1),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.r25),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                CircleAvatar(
                  radius: AppRadius.r25.r,
                  backgroundImage: NetworkImage(widget.groceryUser.photoUrl!),
                ),
                SizedBox(width: AppSize.w2.w),
                TextDefaultWidget(
                  title: widget.groceryUser.name.toString(),
                  color: AppColors.black1,
                  fontSize: (kIsWeb || size.width >= 500) ? AppFontsSizeManager.s20.sp : AppFontsSizeManager.s12.sp,
                )
              ],
            ),
            InkWell(
              splashColor: Colors.white.withOpacity(0.5),
              onTap: () async {
                deleteItem(size);
              },
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.transparent,
                ),
                width: AppSize.w35,
                height: AppSize.h35.h,
                child: Icon(
                  Icons.delete_outline,
                  color: AppColors.red,
                  size: AppSize.w20,
                ),
              ),
            )
          ],
        ),
      ),
    );
  }

  deleteItem(Size size) {
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
                      getTranslated(context, "deleteConsult"),
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
                  padding: EdgeInsets.only(
                      left: AppPadding.p20,
                      right: AppPadding.p20,
                      top: AppPadding.p10,
                      bottom: AppPadding.p10),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: <Widget>[
                      delete
                          ? CircularProgressIndicator()
                          : InkWell(
                              onTap: () async {
                                delete = true;

                                QuerySnapshot querySnapshot =
                                    await FirebaseFirestore.instance
                                        .collection(Paths.usersPath)
                                        .where(
                                          "uid",
                                          isEqualTo: widget.groceryUser.uid,
                                        )
                                        .get();

                                var courses = GroceryUser.fromMap(
                                        querySnapshot.docs[0].data() as Map)
                                    .courses;

                                courses!.remove(widget.uidCourse);

                                await FirebaseFirestore.instance
                                    .collection("Users")
                                    .doc(widget.groceryUser.uid)
                                    .set({
                                  'courses': courses,
                                }, SetOptions(merge: true));
                                delete = false;
                                Navigator.pop(context);
                              },
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    getTranslated(context, "yes"),
                                    style: GoogleFonts.cairo(
                                      fontSize: 13,
                                      fontWeight:
                                          AppFontsWeightManager.semiBold,
                                      letterSpacing:
                                          AppConstants.letterSpacing0_3,
                                      color: AppColors.lightBlue,
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
                                color: AppColors.lightBlue,
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
}
