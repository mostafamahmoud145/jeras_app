import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:timeago/timeago.dart' as timeago;

import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/AppAppointments.dart';
import '../../models/chat.dart';
import '../../models/user.dart';
import '../../models/user_notification.dart';
import '../../screens/AppointmentChatScreen.dart';
import '../../screens/addReviewScreen.dart';
import '../../screens/generalNotificationScreen.dart';
import '../../screens/home_screen.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_shadow.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../models/job.dart';
import '../models/user_notification.dart' as prefix;
import '../screens/addObjectionScreen.dart';
import '../screens/chatDetailScreen.dart';
import '../screens/job/JobDetailsScreen.dart';
import '../screens/marketPlaceScreen.dart';
import '../screens/payInfoScreen.dart';

class NotificationItem extends StatelessWidget {
  final Size size;
  final UserNotification userNotification;
  final int index;
  final List<prefix.Notification> notificationList;
  final String theme;

  const NotificationItem({
    required this.size,
    required this.userNotification,
    required this.index,
    required this.notificationList,
    required this.theme,
  });

//   @override
// <<<<<<< HEAD
//   State<NotificationItem> createState() => _NotificationItemState();

// my_custom_messages.dart
// class MyCustomMessages implements LookupMessages {
//   @override
//   String prefixAgo() => 'jkl';
//   @override
//   String prefixFromNow() => '';
//   @override
//   String suffixAgo() => '';
//   @override
//   String suffixFromNow() => '';
//   @override
//   String lessThanOneMinute(int seconds) => 'الآن';
//   @override
//   String aboutAMinute(int minutes) => '${minutes}m';
//   @override
//   String minutes(int minutes) => '${minutes}m';
//   @override
//   String aboutAnHour(int minutes) => '${minutes}m';
//   @override
//   String hours(int hours) => '${hours}h';
//   @override
//   String aDay(int hours) => '${hours}h';
//   @override
//   String days(int days) => '${days}d';
//   @override
//   String aboutAMonth(int days) => '${days}d';
//   @override
//   String months(int months) => '${months}mo';
//   @override
//   String aboutAYear(int year) => '${year}y';
//   @override
//   String years(int years) => '${years}y';
//   @override
//   String wordSeparator() => ' ';
// }

// class _NotificationItemState extends State<NotificationItem> {
  // @override
  // void initState() {
  //   super.initState();

  //   // Override "en" locale messages with custom messages that are more precise and short
  //   timeago.setLocaleMessages('en', MyCustomMessages());
  // }

  @override
  Widget build(BuildContext context) {
    return InkWell(
      splashColor: Colors.white.withOpacity(0.8),
      onTap: () async {
        try {
          if (notificationList[index].notificationType ==
              "Review_Notification") {
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection(Paths.consultReviewsPath)
                .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where('appointmentId',
                    isEqualTo: notificationList[index].appointmentId)
                .get();
            if (querySnapshot.size > 0) {
              showSnack(getTranslated(context, "ratedbefor"), context);
            } else
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddReviewScreen(
                      consultId: notificationList[index].consultUid!,
                      userId: notificationList[index].userUid!,
                      isCourse: false,
                      appointmentId: notificationList[index].appointmentId!),
                ),
              );
          } else if (notificationList[index].notificationType ==
              "CourseReview_Notification") {
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection(Paths.consultReviewsPath)
                .where('uid', isEqualTo: FirebaseAuth.instance.currentUser!.uid)
                .where('appointmentId',
                    isEqualTo: notificationList[index].appointmentId)
                .get();
            if (querySnapshot.size > 0) {
              showSnack(getTranslated(context, "ratedbefor"), context);
            } else
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AddReviewScreen(
                    consultId: notificationList[index].consultUid!,
                    userId: notificationList[index].userUid!,
                    courseId: notificationList[index].courseId!,
                    appointmentId: notificationList[index].appointmentId!,
                    isCourse: true,
                  ),
                ),
              );
          } else if (notificationList[index].notificationType ==
              "closeLesson_Notification") {
            /*
            QuerySnapshot querySnapshot = await FirebaseFirestore.instance
                .collection(Paths.consultReviewsPath)
                .where( 'uid', isEqualTo: FirebaseAuth.instance.currentUser.uid )
                .where( 'appointmentId', isEqualTo: notificationList[index].appointmentId )
                .get();
            if(querySnapshot.size>0)
            {
              showSnack(getTranslated(context, "ratedbefor"),context);
            }
            else*/
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => AddObjectionScreen(
                    consultId: notificationList[index].consultUid!,
                    userId: notificationList[index].userUid!,
                    appointmentId: notificationList[index].appointmentId!),
              ),
            );
          } else if (notificationList[index].notificationType ==
                  "Appointment_Notification" &&
              notificationList[index].type == "consult")
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  notificationPage: 0,
                ),
              ),
            );
          else if (notificationList[index].notificationType ==
                  "Appointment_Notification" &&
              notificationList[index].type == "user")
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  notificationPage: 1,
                ),
              ),
            );
          else if (notificationList[index].notificationType ==
              "TechnicalSupport")
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => HomeScreen(
                  notificationPage: 2,
                ),
              ),
            );
          else if (notificationList[index].notificationType == "Chat") {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(notificationList[index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user = GroceryUser.fromMap(documentSnapshot.data() as Map);

            DocumentReference docRef2 = FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .doc(notificationList[index].appointmentId);
            final DocumentSnapshot documentSnapshot2 = await docRef2.get();
            var appointment =
                AppAppointments.fromMap(documentSnapshot2.data() as Map);
            if (appointment.appointmentStatus != "closed" &&
                appointment.appointmentStatus != "cancel")
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => AppointmentChatScreen(
                      appointment: appointment, user: user),
                ),
              );
            else if (appointment.appointmentStatus != "closed")
              showSnack(getTranslated(context, "appointmentClosed"), context);
            else
              showSnack(getTranslated(context, "appointmentCanceled"), context);
          } else if (notificationList[index].notificationType == "freeChat") {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(notificationList[index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user = GroceryUser.fromMap(documentSnapshot.data() as Map);

            DocumentReference docRef2 = FirebaseFirestore.instance
                .collection("Chat")
                .doc(notificationList[index].chatId);
            final DocumentSnapshot documentSnapshot2 = await docRef2.get();
            var item = Chat.fromMap(documentSnapshot2.data() as Map);
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => ChatDetailScreen(
                  item: item,
                  user: user,
                  theme: 'light',
                ),
              ),
            );
          } else if (notificationList[index].notificationType == "Calling") {
            /*DocumentReference docRef = FirebaseFirestore.instance.collection(Paths.usersPath).doc(notificationList[index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user= GroceryUser.fromMap(documentSnapshot);
*/
            DocumentReference docRef2 = FirebaseFirestore.instance
                .collection(Paths.appAppointments)
                .doc(notificationList[index].appointmentId);
            final DocumentSnapshot documentSnapshot2 = await docRef2.get();
            var appointment =
                AppAppointments.fromMap(documentSnapshot2.data() as Map);
            /* if (appointment.appointmentStatus != "closed" &&
                appointment.appointmentStatus != "cancel" &&
                appointment.allowCall)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) =>
                      VideoCallScreen(
                          appointment: appointment,
                          user: null,
                          appointmentId: appointment.appointmentId,
                          consultName: appointment.consult.name

                      ),
                ),
              );
            else*/
            if (appointment.appointmentStatus != "closed")
              showSnack(getTranslated(context, "appointmentClosed"), context);
            else
              showSnack(getTranslated(context, "appointmentCanceled"), context);
          } else if (notificationList[index].notificationType == "Account") {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(notificationList[index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user = GroceryUser.fromMap(documentSnapshot.data() as Map);

            if (user.allowEditPayinfo!)
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => payInfoScreen(
                    consultId: notificationList[index].userUid!,
                  ),
                ),
              );
            else
              showSnack(getTranslated(context, "contactSupport"), context);
          } else if (notificationList[index].notificationType ==
              "Marketplace") {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => MarketplaceScreen(
                  link: notificationList[index].link!,
                ),
              ),
            );
          } else if (notificationList[index].notificationType == "Jobs") {
            DocumentReference docRef = FirebaseFirestore.instance
                .collection(Paths.usersPath)
                .doc(notificationList[index].userUid);
            final DocumentSnapshot documentSnapshot = await docRef.get();
            var user = GroceryUser.fromMap(documentSnapshot.data() as Map);

            DocumentReference docRef2 = FirebaseFirestore.instance
                .collection(Paths.jobsPath)
                .doc(notificationList[index].appointmentId);

            final DocumentSnapshot documentSnapshot2 = await docRef2.get();
            var job = Job.fromMap(documentSnapshot2.data() as Map);

            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) =>
                    JobDetailsScreen(job: job, loggedUser: user),
              ),
            );
          } else
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GeneralNotificationScreen(
                    title: notificationList[index].notificationTitle!,
                    body: notificationList[index].notificationBody!,
                    image: notificationList[index].image,
                    link: notificationList[index].link

                    //user: user
                    ),
              ),
            );
        } catch (e) {}
      },
      child: Container(
        width: size.width,
        padding: const EdgeInsets.only(
            left: AppPadding.p10,
            right: AppPadding.p10,
            bottom: AppPadding.p10,
            top: AppPadding.p10),
        decoration: BoxDecoration(
          color: AppColors.white,
          boxShadow: [AppShadow.primaryShadow],
          borderRadius: BorderRadius.circular(AppRadius.r10_6.r),
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisAlignment: MainAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Row(
              children: [
                Container(
                    padding: EdgeInsets.all(AppPadding.p15),
                    decoration: BoxDecoration(
                      color: AppColors.grey1,
                      shape: BoxShape.circle,
                    ),
                    child: Center(
                      child: Image.asset(
                        AssetsManager.whiteJerasLogoIconPath,
                        width:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 50.w
                                : 25.w,
                        height:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                ? 50.h
                                : 25.h,
                      ),
                    )),
                SizedBox(width: 5.h),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Stack(
                        children: <Widget>[
                          //old dex
                          /*
                          Text(
                            notificationList[index].notificationTitle!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize: (kIsWeb||size.width >= 500)
?16.sp:13.0.sp,
                              fontWeight:AppFontsWeightManager.bold300,
                              foreground: Paint()
                                ..style = PaintingStyle.stroke
                                ..strokeWidth = 0.5
                                ..color = Color.fromRGBO(32, 32, 32,1),
                            ),
                          ),*/
                          // Solid text as fill.
                          //name
                          Text(
                            notificationList[index].notificationTitle!,
                            textAlign: TextAlign.start,
                            style: TextStyle(
                              fontFamily: getTranslated(context, "Ithra"),
                              fontSize: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s20.sp
                                  : AppFontsSizeManager.s17.sp,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      Text(
                        '${notificationList[index].notificationBody}',
                        // overflow: TextOverflow.ellipsis,
                        //softWrap: true,
                        //maxLines: 3,
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? 17.sp
                                  : 14.sp,
                          color: AppColors.black4,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                      Text(
                        '${timeago.format(notificationList[index].timestamp!.toDate(), locale: 'ar')}',
                        style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize:
                              (kIsWeb || size.width >= AppConstants.kIsWebValue)
                                  ? AppFontsSizeManager.s16.sp
                                  : AppFontsSizeManager.s13.sp,
                          color: AppColors.darkGrey3,
                          fontWeight: FontWeight.normal,
                        ),
                      ),
                    ],
                  ),
                ),
                SizedBox(width: AppSize.w5.w),
              ],
            ),

            // Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
            //   children: [
            //     Expanded(
            //       child: Text(
            //         notificationList[index].notificationTitle!,
            //         // '${notificationList[index].notificationTitle}',
            //         overflow: TextOverflow.ellipsis,
            //         style: TextStyle(fontFamily: getTranslated(context, "Ithra"), fontSize: AppFontsSizeManager.s14_5,
            //           color: AppColors.grey,
            //           fontWeight: FontWeight.normal,),
            //       ),
            //     ),
            //     Text(
            //       '${dateFormat.format(
            //           notificationList[index].timestamp!.toDate())}',
            //       style: TextStyle(fontFamily: getTranslated(context, "Ithra"), fontSize: 10.0,
            //         color: AppColors.grey,
            //         fontWeight: FontWeight.normal,),

            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 5.0,
            // ),
            // Row(
            //   children: [
            //     Expanded(
            //       child: Text(
            //         '${notificationList[index].notificationBody}',
            //         overflow: TextOverflow.ellipsis,
            //         softWrap: true,
            //         maxLines: 2,
            //         style: TextStyle(fontFamily: getTranslated(context, "Ithra"), fontSize: 13.5,
            //           color: AppColors.grey,
            //           fontWeight: FontWeight.normal,),
            //       ),
            //     ),
            //   ],
            // ),
            // SizedBox(
            //   height: 10.0,
            // ),
          ],
        ),
      ),
    );
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
}
