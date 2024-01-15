// import 'package:firebase_auth/firebase_auth.dart';
// import 'package:firebase_database/firebase_database.dart';
// import 'package:flutter/foundation.dart';
// import 'package:flutter/material.dart';
// import 'package:jeras/widget/responsive.dart';
// import 'package:permission_handler/permission_handler.dart';
// import 'package:shimmer/shimmer.dart';
//
// import '../../localization/localization_methods.dart';
// import '../../models/AppAppointments.dart';
// import '../../models/user.dart';
// import 'call_sample.dart';
//
// class checkPermissionWidget extends StatefulWidget{
//
//   final String host;
//   bool  ?iscaller=false;
//   bool ?acceptNotfi=false;
//   AppAppointments ? appointment;
//   GroceryUser  ? loggedUser ;
//
//   String ? CallerId ="";
//   String ? ReciverId="";
//
//   bool ? isVideo=true;
//   bool ? normalCall=true;
//
//
//   checkPermissionWidget({required this.host,this.iscaller,this
//       .acceptNotfi,this.appointment,this.loggedUser,this.isVideo,this.normalCall,this.CallerId,this.ReciverId});
//
//
//   @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//    return checkPermissionWidgetSate();
//   }
//
// }
//
// class checkPermissionWidgetSate extends State<checkPermissionWidget>{
//
//
//   var size;
//
//   bool cameraGranted=true;
//   bool micGranted=true;
//
//   Widget ShimmerLoad(){
//     return  Stack(
//       children: [
//         // Positioned(
//         //     left: 10,
//         //     top: 10,
//         //     child:
//         //     Container(
//         //       width: 150,
//         //       height: 150,
//         //       child: RTCVideoView( _localRenderer!),
//         //     )
//         // ),
//         Align(child:
//         Container(padding: EdgeInsets.symmetric(vertical: 50),
//           child:Column( mainAxisAlignment: MainAxisAlignment.spaceBetween,
//             mainAxisSize: MainAxisSize.max,
//             children: [
//               Column(
//                 children: [
//                   Stack(children: [
//                     Shimmer.fromColors(
//                         period: Duration(milliseconds: 800),
//                         baseColor: Colors.grey.withOpacity(0.6),
//                         highlightColor: Colors.black.withOpacity(0.6),
//                         child: Container(
//                           height: 100,
//                           width: 100,
//                           padding: const EdgeInsets.all(8.0),
//                           margin: const EdgeInsets.symmetric(
//                             horizontal: 20.0,
//                           ),
//                           decoration: BoxDecoration(
//                             shape: BoxShape.circle,
//                             color: Colors.black.withOpacity(0.2),
//                           ),
//                         ))
//
//
//                   ],),
//                   SizedBox(width:size.width*.20 ,height: 10,),
//
//                   Shimmer.fromColors(
//                       period: Duration(milliseconds: 800),
//                       baseColor: Colors.grey.withOpacity(0.6),
//                       highlightColor: Colors.black.withOpacity(0.6),
//                       child: Container(
//                         height: 50,
//                         width: kIsWeb && MediaQuery.of(context).size.width > 400
//                             ? MediaQuery.of(context).size.width * .3
//                             : MediaQuery.of(context).size.width * .8,
//                         padding: const EdgeInsets.all(8.0),
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 20.0,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(AppRadius.r15.r),
//                         ),
//                       )),
//                   SizedBox(width:size.width*.20 ,height: 10,),
//
//                   Shimmer.fromColors(
//                       period: Duration(milliseconds: 800),
//                       baseColor: Colors.grey.withOpacity(0.6),
//                       highlightColor: Colors.black.withOpacity(0.6),
//                       child: Container(
//                         height: 50,
//                         width: kIsWeb && MediaQuery.of(context).size.width > 400
//                             ? MediaQuery.of(context).size.width * .3
//                             : MediaQuery.of(context).size.width * .8,
//                         padding: const EdgeInsets.all(8.0),
//                         margin: const EdgeInsets.symmetric(
//                           horizontal: 20.0,
//                         ),
//                         decoration: BoxDecoration(
//                           color: Colors.black.withOpacity(0.2),
//                           borderRadius: BorderRadius.circular(AppRadius.r15.r),
//                         ),
//                       ))                ],
//               ),
//               SizedBox(),
//               Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 crossAxisAlignment: CrossAxisAlignment.center,
//                 children: [
//
//                   Shimmer.fromColors(
//                       period: Duration(milliseconds: 800),
//                       baseColor: Colors.grey.withOpacity(0.6),
//                       highlightColor: Colors.black.withOpacity(0.6),
//                       child:  Container(
//                         height: 60,width: 100,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.withOpacity(0.6),
//                           borderRadius: BorderRadius.circular(30.0),
//
//                         ),
//                       ))
//
//                   ,
//
//                   SizedBox(width:size.width*.20 ,height: 10,),
//                   Shimmer.fromColors(
//                       period: Duration(milliseconds: 800),
//                       baseColor: Colors.grey.withOpacity(0.6),
//                       highlightColor: Colors.black.withOpacity(0.6),
//                       child:  Container(
//                         height: 60,width: 100,
//                         decoration: BoxDecoration(
//                           color: Colors.grey.withOpacity(0.6),
//                           borderRadius: BorderRadius.circular(30.0),
//
//                         ),
//                       )),
//                   SizedBox(width:size.width*.20 ,height: 10,),
//
//                 ],
//               )
//
//             ],) ,)
//
//
//
//
//
//
//           ,)
//
//       ],
//
//     ) ;
//   }
//   Future<void> requstCallPermissions() async {
//
//
//
//     {
//       var cameraStatus=  await  Permission.camera.request();
//
//
//       if (cameraStatus.isGranted) {
//
//
//
//         var  MicStatus=   await  Permission.microphone.request();
//
//
//         if(MicStatus.isGranted){
//
//           cameraGranted=true;
//           micGranted=true;
//
//
//           FirebaseDatabase.instance.ref('userCallState').child( FirebaseAuth.instance.currentUser!.uid).child('callState').set('oncall').then((value) =>
//               Future(() =>
//               // Navigator.of(context).pushReplacement(MaterialPageRoute(builder: (con) =>
//               //     CallSample(host: widget.host, iscaller: false,
//               //       isVideo: true,normalCall: true,CallerId: widget.CallerId
//               //       ,ReciverId: widget.ReciverId,)
//               // ))
//
//           )
//           );
//         }
//         else  if(!MicStatus.isGranted){
//           micGranted=false;
//           cameraGranted=false;
//
//           setState(() {
//
//           });
//         }
//
//
//
//
//
//
//
//       }
//
//       else if(!cameraStatus.isGranted){
//         cameraGranted=false;
//         micGranted=false;
// setState(() {
//
// });
//
//       }
//
//
//
//
//
//
//
//     }
//
//
//     // else{
//     //   await  Permission.microphone.request();
//     //   var MicStatus = await Permission.microphone.status;
//     //
//     //
//     //   if(MicStatus.isGranted){
//     //
//     //     checkCallPermissions?.call(call_permision.micGranted,call_permision.micGranted);
//     //
//     //
//     //
//     //   } else if(!MicStatus.isGranted){
//     //     checkCallPermissions?.call(call_permision.micdined,call_permision.micdined);
//     //
//     //   }
//     // }
//
//
//
//
//   }
//
//
//   @override
//   Widget build(BuildContext context) {
//     size=MediaQuery.of(context).size;
//     return WillPopScope(onWillPop: ()async => true,
//         child:
//         Scaffold(
//             backgroundColor: Color.fromRGBO(247, 247, 247,1),
//             extendBodyBehindAppBar: true,
//             body: !micGranted &&!cameraGranted?
//             endWidget("camera_micPermissions")
//                 :ShimmerLoad()
//
//
//
//
//
//         ));
//
//   }
//
//   endWidget(String _text){return
//     Container(
//       child: Column(mainAxisAlignment: MainAxisAlignment.center,crossAxisAlignment: CrossAxisAlignment.center,
//         children: [
//           Container(
//               height: 70,
//               width: 70,
//               decoration: BoxDecoration(
//                 boxShadow: [
//                   BoxShadow(
//                       color: const Color(0x33ae9cce),
//                       offset: Offset(0, 6),
//                       blurRadius: 12,
//                       spreadRadius: 0)
//                 ],
//                 color: Colors.white,
//                 border: Border.all(
//                   width: 6,
//                   color: Colors.white,
//                 ),
//                 shape: BoxShape.circle,
//               ),
//               child: Image.asset(
//                 AssetsManager.whiteJerasLogoIconPath,
//                 width: 65,
//                 height: 65,
//               )
//           ),
//           SizedBox(height: size.height*.15,),
//           Center(child: text(getTranslated(context, _text),13,Color.fromRGBO(32, 32 ,32,1),FontWeight.w500)),
//           SizedBox(height: size.height*.15,),
//           Center(child: closeWidget())
//         ],
//       ),
//     );}
//
//
//   @override
//   void initState() {
//     super.initState();
//
//     requstCallPermissions();
//   }
//
//   Widget closeWidget(){
//     return  InkWell(onTap: (){
//
//
//     }, child:
//     Container(
//       height: 40,width: 200,
//       decoration: BoxDecoration(
//         color: Colors.green,
//         borderRadius: BorderRadius.circular(AppRadius.r20),
//
//       ),
//       child: Center(
//         child: text(getTranslated(context, "Ok"),15,Colors.white,FontWeight.w300),
//       ),
//     ),
//     );
//   }
//
//   Widget text(String text,double size,Color color,FontWeight weight){
//     return Text(
//       text,
//       textAlign: TextAlign.center,
//       style: TextStyle(
//           fontFamily:"Ithra",// 'Montserrat',
//           fontSize: size,
//           color: color,
//           fontWeight: weight),
//     );
//   }
//
//
// }