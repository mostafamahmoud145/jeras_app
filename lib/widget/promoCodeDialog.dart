// import 'dart:convert';
// import 'dart:io';
//
// import 'package:cloud_firestore/cloud_firestore.dart';
// import 'package:cloud_functions/cloud_functions.dart';
// import 'package:firebase_analytics/firebase_analytics.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart';
// import 'package:jeras/Utils/opentab.dart'if (dart.library.html) 'package:jeras/Utils/opentabWeb.dart';
// import 'package:jeras/Utils/styles.dart';
// import 'package:jeras/models/order.dart';
// import 'package:jeras/widget/loadwebView.dart'  if (dart.library.html) 'package:jeras/widget/loadwebViewnon.dart';
// import 'package:jeras/widget/responsive.dart';
// import 'package:uuid/uuid.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
// import '../Utils/helper.dart';
// import '../config/colors_file.dart';
// import '../config/paths.dart';
// import '../localization/localization_methods.dart';
// import '../models/courses.dart';
// import '../models/promoCode.dart';
// import '../models/user.dart';
// import 'addAppointmentDialog.dart';
// import 'button_widget.dart';
// import 'customTextField.dart';
//
// class promoCodeDialog extends StatefulWidget {
//   GroceryUser user;
//   GroceryUser consultant;
//   Courses course;
//   promoCodeDialog(
//       {Key? key,
//       required this.user,
//       required this.consultant,
//       required this.course})
//       : super(key: key);
//
//   @override
//   State<promoCodeDialog> createState() => _promoCodeDialogState();
// }
//
// class _promoCodeDialogState extends State<promoCodeDialog> {
//   @override
//   TextEditingController promoController = TextEditingController();
//   PromoCode? promo;
//   String? promoCodeId;
//
//   late int localFrom, localTo;
//   String userName = "dreamUser", initialUrl = "";
//   double coursePrice = 0, callPrice = 0,priceAfterDiscount = 0, priceAfterFees = 0;
//   int discount = 0;
//   bool showPayView = false, load = false, valid = false, appointment = false;
//  // WebViewController controller = WebViewController();
//
//   @override
//   void initState() {
//     localFrom = DateTime.parse(widget.consultant.fromUtc!).toLocal().hour;
//     localTo = DateTime.parse(widget.consultant.toUtc!).toLocal().hour;
//     if (localTo == 0) localTo = 24;
//     super.initState();
//     // controller..setJavaScriptMode(JavaScriptMode.unrestricted)
//     //   ..setBackgroundColor(const Color(0x00000000))
//     //   ..setNavigationDelegate(
//     //     NavigationDelegate(
//     //       onProgress: (int progress) {
//     //         // Update loading bar.
//     //       },
//     //       onPageStarted: (String url) {},
//     //       onPageFinished: (finish) {
//     //        //  setState(() {
//     //        // //   isLoading = false;
//     //        //  });
//     //        //
//     //         },
//     //       onWebResourceError: (WebResourceError error) {},
//     //       onNavigationRequest: (NavigationRequest request) {
//     //
//     //         if (request.url
//     //             .startsWith("https://www.jeras.io/app/redirect_url")) {
//     //
//     //           setState(() {
//     //             showPayView = false;
//     //             var str = request.url;
//     //             const start = "tap_id=";
//     //             final startIndex = str.indexOf(start);
//     //
//     //             String charge =
//     //             str.substring(startIndex + start.length, str.length);
//     //
//     //             payStatus(charge);
//     //           });
//     //           return NavigationDecision.prevent;
//     //         }
//     //         return NavigationDecision.navigate;
//     //       },
//     //     ),
//     //   )
//     //   ..loadRequest(Uri.parse(initialUrl));
//
//   }
//
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//
//     return
//
//       showPayView
//          ?  Container(color: Colors.white,
//            child: loadwebView(Url: initialUrl,onProgress: (int progress){
//
//       },onPageFinished: (String finish){
//         // setState(() => _stackIndex = 0
//         //
//         // );
//
//       },onNavigationRequest: (NavigationRequest request){
//         if (request.url.startsWith(
//               "https://www.jeras.io/app/redirect_url")) {
//             setState(() {
//              // _stackIndex = 1;
//               showPayView = false;
//               var str = request.url;
//               const start = "tap_id=";
//               final startIndex = str.indexOf(start);
//
//               String charge = str.substring(
//                   startIndex + start.length, str.length);
//               payStatus(charge);
//             });
//             return NavigationDecision.prevent;
//         }
//       },),
//          )
//
//       //WebViewWidget(controller: controller,
//         //
//         //   )
//        :
//
//     AlertDialog(
//             scrollable: true,
//             shape: RoundedRectangleBorder(
//               borderRadius: BorderRadius.all(
//                 Radius.circular(45.0),
//               ),
//             ),
//             elevation: 5.0,
//             contentPadding: EdgeInsets.all(0),
//             content: Container(
//               height: size.height * 0.4,
//               width: (kIsWeb||size.width >= 500)
// ?size.width*.4:size.width,
//               decoration: BoxDecoration(
//                 color: Colors.white,
//                 borderRadius: BorderRadius.circular((kIsWeb||size.width >= 500)
// ?30.r:20.r),
//               ),
//               constraints: BoxConstraints.loose(size),
//               child: SingleChildScrollView(
//                 padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 20.0),
//                 scrollDirection: Axis.vertical,
//                 child: Column(
//                   mainAxisSize: MainAxisSize.min,
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: <Widget>[
//                     Center(
//                       child: Text(getTranslated(context, "ask_proCode"),
//                           style: Styles.getTextStyle(
//                               color: AppColors.pink,
//                               fontSize: 14,
//                               fontWeight: FontWeight.w600)),
//                     ),
//                     SizedBox(
//                       height: 20.0,
//                     ),
//                     Row(mainAxisAlignment: MainAxisAlignment.center,
//                       children: [
//                         CustomTextFieldWidget(
//                           width: (kIsWeb||size.width >= 500)
// ?size.width*.25:size.width * .5,
//                           borderRadiusValue: 25,
//                           backGroundColor: AppColors.white,
//                           iscenter: true,
//                           borderColor: AppColors.warmGrey.withOpacity(.1),
//                           hint: getTranslated(context, "enterPromoCode"),
//                           onchange: (text) async {
//                             if (text.length == 5) {
//                               discount = await calculateDiscount();
//                               if (discount > 0) {
//                                 setState(() {
//                                   valid = true;
//                                 });
//                               }
//                             }
//                             if (text.length == 0) {
//                               setState(() {
//                                 // promo = null;
//                                 // promoCodeId="";
//                                 valid = false;
//                                 discount = 0;
//                               });
//                             }
//                           },
//                           controller: promoController,
//                         ),
//                         Icon(
//                           Icons.check_circle,
//                           color: valid ? Colors.green : AppColors.lightGrey,
//                           size: 20.0,
//                         ),
//                       ],
//                     ),
//                     SizedBox(
//                       height: 3,
//                     ),
//                     Center(
//                       child: Text(
//                         getTranslated(context, "proText") +
//                             discount.toString() +
//                             "%",
//                         maxLines: 3,
//                         overflow: TextOverflow.ellipsis,
//                         softWrap: true,
//                         textAlign: TextAlign.center,
//                         style: Styles.getTextStyle(
//                           fontSize: (kIsWeb||size.width >= 500)
// ?13:10.0,
//                           fontWeight: AppFontsWeightManager.bold500,
//                           color: Colors.grey,
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 50,
//                     ),
//                     Center(
//                       child: load ? Center(child: CircularProgressIndicator(),):Container(
//                         width:(kIsWeb||size.width >= 500)
// ?size.width*.15:size.width*.5,
//                         child: CustomButton(
//                             onTap: () async {
//                               setState(() {
//                                 load = true;
//                               });
//                               coursePrice = widget.course.lessonNum*double.parse(widget.consultant.price!);
//                               priceAfterDiscount = coursePrice - (coursePrice * (discount / 100));
//                               callPrice = priceAfterDiscount/widget.course.lessonNum;
//                               priceAfterFees = (priceAfterDiscount * (5 / 100) + priceAfterDiscount);
//
//                               if (double.parse(widget.user.balance.toString()) >=
//                                   priceAfterFees) {
//                                 var newBalance =
//                                     double.parse(widget.user.balance.toString()) -
//                                         priceAfterFees;
//                                 await FirebaseFirestore.instance
//                                     .collection(Paths.usersPath)
//                                     .doc(widget.user.uid)
//                                     .set({
//                                   'balance': newBalance,
//                                 }, SetOptions(merge: true));
//
//                                 setState(() {
//                                   //fromBalance=true;
//                                   widget.user.balance = newBalance;
//                                 });
//                                 updateDatabaseAfterAddingOrder(
//                                     payWith: "userBalance");
//
//                                 /*setState(() {
//                                   load = false;
//                                 });*/
//                               }
//                               else {
//
//                                 if(kIsWeb){
//                                   paywithTab();
//                                 }else{
//                                   pay();
//
//                                 }
//                                 /*setState(() {
//                                   load = false;
//                                 });*/
//                               }
//                             },
//                             title: getTranslated(context, "book_now"),
//                             radius: 5,
//                             //height: size.height * .06,
//                             verticalPadding: 10,
//                             textColor: AppColors.white,
//                             backgroundColor: AppColors.pink,
//                            // gradientColor1: AppColors.linear1,
//                              //gradientColor2: AppColors.linear2
//                         ),
//                       ),
//                     ),
//                     SizedBox(
//                       height: 50,
//                     ),
//                   ],
//                 ),
//               ),
//             ),
//           );
//   }
//
//   Future<int> calculateDiscount() async {
//     int disco = 0;
//     setState(() {
//       //checkPromo=true;
//     });
//     if (promoController.text != "") {
//       QuerySnapshot querySnapshot = await FirebaseFirestore.instance
//           .collection(Paths.promoPath)
//           .where('promoCodeStatus', isEqualTo: true)
//           .where('code', isEqualTo: promoController.text)
//           .limit(1)
//           .get();
//       var codes = List<PromoCode>.from(
//         querySnapshot.docs.map(
//           (snapshot) => PromoCode.fromMap(snapshot.data() as Map),
//         ),
//       );
//       if (codes.length > 0) {
//         bool isPrimary = (codes[0].type == "primary" &&
//             codes[0].promoCodeStatus
//             //&&_selectedIndex != null &&_selectedIndex==0
//             &&
//             widget.user.promoList != null &&
//             widget.user.promoList!.contains(codes[0].promoCodeId) == false);
//         if ((codes[0].type == "default" && codes[0].promoCodeStatus) ||
//             isPrimary)
//           setState(() {
//             promo = codes[0];
//             promoCodeId = promo!.promoCodeId;
//             // checkPromo=false;
//             valid = true;
//             disco = promo!.discount;
//           });
//         else
//           setState(() {
//             promoCodeId = "";
//             //checkPromo=false;
//             valid = false;
//             disco = 0;
//           });
//       } else {
//         setState(() {
//           // promo = null;
//           promoCodeId = "";
//           //checkPromo=false;
//           valid = false;
//           discount = 0;
//         });
//       }
//     }
//     return disco;
//   }
//
//   updateDatabaseAfterAddingOrder({required String payWith}) async {
//     try {
//       String orderId = Uuid().v4();
//       DateTime dateValue = DateTime.now();
//
//       await FirebaseFirestore.instance
//           .collection(Paths.ordersPath)
//           .doc(orderId)
//           .set({
//         'orderStatus': (widget.consultant.consultType == "perfect" ||
//                 widget.consultant.consultType == "jeras") ? 'completed' : 'open',
//         'consultType': "jeras",
//         'orderId': orderId,
//         'chargeId': "",
//         'date': {
//           'day': dateValue.day,
//           'month': dateValue.month,
//           'year': dateValue.year,
//         },
//         'utcTime': dateValue.toUtc().toString(),
//         'orderTimestamp': Timestamp.now(),
//         'orderTimeValue':
//             DateTime(dateValue.year, dateValue.month, dateValue.day)
//                 .millisecondsSinceEpoch,
//         'packageId': "",
//         'promoCodeId': promoCodeId,
//         'remainingCallNum': widget.course
//             .lessonNum, //(widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?0:package.callNum,
//         'packageCallNum': widget.course.lessonNum,
//         'answeredCallNum': 0,
//         'callPrice': callPrice,
//         "payWith": payWith,
//         "platform":kIsWeb?"Web": Platform.isIOS ? "iOS" : "Android",
//         'price': priceAfterFees.toString(),
//         'consult': {
//           'uid': widget.consultant.uid,
//           'name': widget.consultant.name,
//           'image': widget.consultant.photoUrl,
//           'phone': widget.consultant.phoneNumber,
//           'countryCode': widget.consultant.countryCode,
//           'countryISOCode': widget.consultant.countryISOCode,
//         },
//         'user': {
//           'uid': widget.user.uid,
//           'name': widget.user.name,
//           'image': widget.user.photoUrl,
//           'phone': widget.user.phoneNumber,
//           'countryCode': widget.user.countryCode,
//           'countryISOCode': widget.user.countryISOCode,
//         },
//         'course': {
//           'courseId': "${widget.course.courseId}",
//           'courseName': "${widget.course.name}",
//           'courseImage': ".",
//         }
//       }).then((value) {
//       });
//
//       //currentNumber= course!.lessonNum;
//       // update consult order numbers
//       await FirebaseFirestore.instance
//           .collection(Paths.usersPath)
//           .doc(widget.consultant.uid)
//           .set({
//         'openOrders': widget.consultant.openOrders + 1,
//       }, SetOptions(merge: true));
//
//       //update user order numbers
//       if (widget.user.ordersNumbers == null || widget.user.ordersNumbers! < 1)
//         await FirebaseFirestore.instance
//             .collection(Paths.appAnalysisPath)
//             .doc("TgWCp3B22sbkl0Nm3wLx")
//             .set({
//           'buyedMagadUsers': FieldValue.increment(1),
//         }, SetOptions(merge: true));
//       int userOrdersNumbers = 1;
//       dynamic payedBalance = double.parse(coursePrice.toString());
//       if (widget.user.ordersNumbers != null)
//         userOrdersNumbers = widget.user.ordersNumbers! + 1;
//       if (widget.user.payedBalance != null)
//         payedBalance = widget.user.payedBalance + payedBalance;
//
//       if (promo != null && promo!.type == "primary")
//         widget.user.promoList!.add(promo!.promoCodeId);
//
//       await FirebaseFirestore.instance
//           .collection(Paths.usersPath)
//           .doc(widget.user.uid)
//           .set({
//         'ordersNumbers': userOrdersNumbers,
//         'payedBalance': payedBalance,
//         //'customerId':customerId,
//         'preferredPaymentMethod': "tapCompany",
//         'promoList': widget.user.promoList,
//       }, SetOptions(merge: true));
//       //  accountBloc.add(GetLoggedUserEvent());
// //======update number of use of promocode
//       if (promo != null) {
//         DocumentSnapshot documentSnapshot = await FirebaseFirestore.instance
//             .collection(Paths.promoPath)
//             .doc(promo!.promoCodeId)
//             .get();
//         Map<String, dynamic> data =
//             documentSnapshot.data() as Map<String, dynamic>;
//         int usedNumber = data['usedNumber'];
//         await FirebaseFirestore.instance
//             .collection(Paths.promoPath)
//             .doc(promo!.promoCodeId)
//             .set({
//           'usedNumber': usedNumber + 1,
//         }, SetOptions(merge: true));
//       }
//       //  --------add details event
//
//       //
//       // String eventName = "af_add_payment_info";
//       // Map eventValues = {
//       //   "af_success": true,
//       //   "af_achievement_id": "success",
//       // };
//       // Helper.addEvent(eventName, eventValues);
//       // await FirebaseAnalytics.instance.logEvent(name: "payInfo",parameters:{
//       //   "success": true,
//       //   "reason": "success",
//       //   "userUid":widget.user!.uid
//       // } );
//       //-----------
//       //
//       // eventName = "af_purchase";
//       // eventValues = {
//       //   "af_revenue": price.toString(),
//       //   "af_price": price.toString(),
//       //   "af_content_id": widget.consultant.uid,
//       //   "af_order_id": orderId,
//       //   "af_currency": "USD",
//       // };
//
//       // addEvent(eventName, eventValues);
//       Navigator.pop(context);
//       showAddAppointmentDialog(
//         orderId: orderId,
//         callPrice: callPrice,
//         localFrom: localFrom,
//         localTo: localTo,
//         remainingCalls: widget.course.lessonNum,
//       );
//     } catch (e) {
//
//       //errorLog("updateDatabaseAfterAddingOrder", e.toString());
//     }
//   }
//
//   pay() async {
//     try {
//       if (widget.user.name != null) userName = widget.user.name!;
//       String description = "رسوم الخدمة (5%)";
//       final uri = Uri.parse('https://api.tap.company/v2/charges');
//       final headers = {
//         'Content-Type': 'application/json',
//         // 'Accept': 'application/json',
//         //'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
//         'Authorization': "Bearer sk_live_C7V9cpBMFWbt2ukjd3fRxIeD",
//         'Connection': 'keep-alive',
//         'Accept-Encoding': 'gzip, deflate, br'
//       };
//       Map<String, dynamic> body = {
//         "amount": priceAfterFees,
//         "currency": "USD",
//         "threeDSecure": true,
//         "save_card": true,
//         "description": description,
//         "statement_descriptor": "مؤسسة  محور النقطة",
//         "metadata": {
//           "udf1": "مؤسسة  محور النقطة",
//           "udf2": "مؤسسة  محور النقطة"
//         },
//         "reference": {"transaction": "txn_0001", "order": "ord_0001"},
//         "receipt": {"email": false, "sms": true},
//         "customer": {
//        //   "id": widget.user.customerId != null ? widget.user.customerId : '',
//           "first_name": userName,
//           "middle_name": ".",
//           "last_name": ".",
//           "email": userName + "@jeras.com",
//           "phone": {"country_code": "", "number": widget.user.phoneNumber}
//         },
//         "merchant": {"id": ""},
//         "source": {"id": "src_all"},
//         "post": {"url": "http://your_website.com/post_url"},
//         "redirect": {"url": "https://www.jeras.io/app/redirect_url"}
//       };
//       String jsonBody = json.encode(body);
//       final encoding = Encoding.getByName('utf-8');
//       var response = await post(
//         uri,
//         headers: headers,
//         body: jsonBody,
//         encoding: encoding,
//       );
//       String responseBody = response.body;
//       var res = json.decode(responseBody);
//       String url = res['transaction']['url'];
//
//       // Navigator.pop(context);
//       setState(() {
//         initialUrl = url;
//         showPayView = true;
//       });
//     } catch (e) {
//
//       // errorLog("pay",e.toString());
//       await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
//         "success": "false",
//         "reason": e.toString(),
//         "userUid": widget.user.uid
//       });
//       setState(() {
//         showPayView = false;
//         // load=false;
//       });
//       Helper.ShowToastMessage(getTranslated(context, "failed"), true);
//     }
//   }
//
//   payStatus(String chargeId) async {
//     try {
//
//       final uri = Uri.parse('https://api.tap.company/v2/charges/' + chargeId);
//       final headers = {
//         'Content-Type': 'application/json',
//         'Accept': 'application/json',
//         //'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
//         'Authorization': "Bearer sk_live_C7V9cpBMFWbt2ukjd3fRxIeD",
//         'Connection': 'keep-alive',
//         'Accept-Encoding': 'gzip, deflate, br'
//       };
//       var response = await get(
//         uri,
//         headers: headers,
//       );
//       String responseBody = response.body;
//       var res = json.decode(responseBody);
//
//       if (res.toString().contains("status") && res['status'] == "CAPTURED") {
//         String? customerId = res['customer']['id'];
//         customerId = customerId != null ? customerId : "";
//         updateDatabaseAfterAddingOrder(payWith: "tapCompany");
//       } else {
//         //callHuperPayWidget
//         //--------add details event
//         String eventName = "af_add_payment_info";
//         Map eventValues = {
//           "af_success": false,
//           "af_achievement_id": res['status'],
//         };
//         Helper.addEvent(eventName, eventValues);
//         await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
//           "success": "false",
//           "reason": res['status'],
//           "userUid": widget.user.uid
//         });
//         String id = Uuid().v4();
//         await FirebaseFirestore.instance
//             .collection(Paths.errorLogPath)
//             .doc(id)
//             .set({
//           'timestamp': Timestamp.now().toString(),
//           'id': id,
//           'seen': false,
//           'desc': res['status'],
//           'phone': widget.user == null ? " " : widget.user.phoneNumber,
//           'screen': "ConsultantDetailsScreen",
//           'function': "payStatus",
//         });
//         setState(() {
//           showPayView = false;
//           load = false;
//         });
//         Helper.ShowToastMessage(getTranslated(context, "failed"), true);
//       }
//     } catch (e) {
//
//       await FirebaseAnalytics.instance.logEvent(name: "payInfo", parameters: {
//         "success": "false",
//         "reason": e.toString(),
//         "userUid": widget.user.uid
//       });
//       setState(() {
//         showPayView = false;
//         load = false;
//       });
//       Helper.ShowToastMessage(getTranslated(context, "failed"), true);
//     }
//   }
//
//
//   paywithTab() async {
//
//       FirebaseFunctions functions = FirebaseFunctions.instance;
//       HttpsCallable callable =   functions.httpsCallable("payWithTab");
//       String description = "رسوم الخدمة (5%)";
//
//       final res  = await callable.call({
//         'tabid':"widget.tabid",
//         'price':priceAfterFees.toString(),
//         'packageId': null,
//         'promoCodeId': promoCodeId,
//         'callPrice': callPrice,
//         'courseid':widget.course.courseId,
//         'userUid':widget.user.uid,
//         'consultUid':widget.consultant.uid,
//         'userName':widget.user.name,
//         'paytype':'course',
//         'phoneNumber':widget.user.phoneNumber,
//         'description':description,
//         'consultid':widget.consultant.uid,
//         'localFrom':localFrom,
//         'localTo':localTo,
//
//       });
//
//      /* final res  = await callable.call({
//         'price':priceAfterFees,
//         'description':description,
//         'customerId':widget.user?.customerId,
//         'userName':widget.user?.name,
//         'phoneNumber':widget.user?.phoneNumber,
//         'paytype':'course',
//         'consultid':widget.consultant.uid,
//         'courseid':widget.course.courseId,
//          'metadata':json.encode(<String,dynamic>{
//            'orderStatus': (widget.consultant.consultType == "perfect" ||
//                widget.consultant.consultType == "jeras") ? 'completed' : 'open',
//            'consultType': "jeras",
//            'orderId': orderId,
//            'openOrders': widget.consultant.openOrders + 1,
//            'ordersNumbers':widget.user.ordersNumbers,
//            'localFrom':localFrom,
//            'localTo':localTo,
//            'promo':promo!=null?promo!.tomap():'',
//            'packageId': "",
//            'promoCodeId': promoCodeId,
//            'remainingCallNum': widget.course
//                .lessonNum, //(widget.consultant.consultType=="perfect"||widget.consultant.consultType=="jeras")?0:package.callNum,
//            'packageCallNum': widget.course.lessonNum,
//            'answeredCallNum': 0,
//            'callPrice': callPrice,
//            "platform": kIsWeb?"Web": Platform.isIOS ? "iOS" : "Android",
//            'price': priceAfterFees.toString(),
//            'consult': {
//              'uid': widget.consultant.uid,
//              'name': widget.consultant.name,
//              'image': widget.consultant.photoUrl,
//              'phone': widget.consultant.phoneNumber,
//              'countryCode': widget.consultant.countryCode,
//              'countryISOCode': widget.consultant.countryISOCode,
//            },
//            'user': {
//              'uid': widget.user.uid,
//              'name': widget.user.name,
//              'image': widget.user.photoUrl,
//              'phone': widget.user.phoneNumber,
//              'countryCode': widget.user.countryCode,
//              'countryISOCode': widget.user.countryISOCode,
//            },
//            'course': {
//              'courseId': "${widget.course.courseId}",
//              'courseName': "${widget.course.name}",
//            }
//          })
//
//       });*/
//
//       openTab.goPaymentPage([res.data['transaction']['url'],'_self']);
//       return res.data;
//   }
//
//
//
//   showAddAppointmentDialog({
//       required String orderId,
//       required dynamic callPrice,
//       required int localFrom,
//       required int localTo,
//       required int remainingCalls}) async {
//     await showDialog(
//       barrierDismissible: false,
//       context: context,
//       builder: (context) {
//         return AddAppointmentDialog(
//             loggedUser: widget.user,
//             consultant: widget.consultant,
//             callPrice: callPrice,
//             orderId: orderId,
//             localFrom: localFrom,
//             localTo: localTo,
//             course: CourseOrder(id: widget.course.courseId,name: widget.course.name, image:  "."),
//             currentNumber: (widget.consultant.consultType == "perfect" ||
//                     widget.consultant.consultType == "jeras")
//                 ? remainingCalls
//                 : remainingCalls - 1);
//       },
//     );
//
//    /* if (isProceeded) {
//       setState(() {
//         load = false;
//       });
//     }*/
//   }
// }
