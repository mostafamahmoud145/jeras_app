// import 'package:flutter/material.dart';
// import 'package:flutter_colorpicker/flutter_colorpicker.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:jeras/widget/responsive.dart';
//
// import '../../blocs/web_rtc_bloc/signaling.dart';
// import '../../whiteBoaed/whiteboard.dart';
// import '../../widget/numberPicker/src/custom_number_picker.dart';
//
// class BoardScreen extends StatefulWidget {
//   final Signaling? signaling;
//   final RTCDataChannel? dataChannel;
//
//   const BoardScreen({Key? key, this.signaling, this.dataChannel}) : super(key: key);
//
//   @override
//   State<BoardScreen> createState() => _BoardScreenState();
// }
//
// class _BoardScreenState extends State<BoardScreen> {
//
//   @override
//   void initState() {
//     super.initState();
//   }
//   Color pickerColor = Color(0xff443a49);
//   Color currentColor = Color(0xff443a49);
//   WhiteBoardController _whiteBoardController = WhiteBoardController();
// bool earse=false;
//
// int widthvalue=5;
//
// bool scale=false;
//
//   @override
//   Widget build(BuildContext context) {
//     Size size = MediaQuery.of(context).size;
//     return  Scaffold(
//       body: Column(
//         children: <Widget>[
//           Container(
//             width: size.width,
//             height: 100,
//             decoration: BoxDecoration(
//               color: Theme.of(context).primaryColor,
//               borderRadius: BorderRadius.only(
//                 bottomLeft: Radius.circular(0.0),
//                 bottomRight: Radius.circular(0.0),
//               ),
//             ),
//             child: SafeArea(
//               bottom: false,
//               child: Padding(
//                 padding: const EdgeInsets.only(
//                     left: AppPadding.p16, right: AppPadding.p16, top: 0.0, bottom: AppPadding.p16),
//                 child: Row(
//                   mainAxisAlignment: MainAxisAlignment.spaceAround,
//                   crossAxisAlignment: CrossAxisAlignment.center,
//                   mainAxisSize: MainAxisSize.max,
//                   children: <Widget>[
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(AppRadius.r50),
//                       child: Material(
//                         color: Colors.transparent,
//                         child: InkWell(
//                           splashColor: Colors.white.withOpacity(0.6),
//                           onTap: () {
//                             Navigator.pop(context);
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.transparent,
//                             ),
//                             width: AppSize.w38.w,
//                             height: AppSize.h35.h,
//                             child: Icon(
//                               Icons.arrow_back,
//                               color: Colors.black,
//                               size: AppSize.w24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(AppRadius.r50),
//                       child: Material(
//                         color: Colors.blue,
//                         child: InkWell(
//                           splashColor: Colors.white.withOpacity(0.6),
//                           onTap: () {
//                             showColorsPicker();
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.transparent,
//                             ),
//                             width: AppSize.w38.w,
//                             height: AppSize.h35.h,
//                             child: Icon(
//                               Icons.color_lens,
//                               color: Colors.black,
//                               size: AppSize.w24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     // ClipRRect(
//                     //   borderRadius: BorderRadius.circular(AppRadius.r50),
//                     //   child: Material(
//                     //     color: Colors.blue,
//                     //     child: InkWell(
//                     //       splashColor: Colors.white.withOpacity(0.6),
//                     //       onTap: () {
//                     //         setState(() {
//                     //           _whiteBoardController.undo();
//                     //
//                     //         });
//                     //       },
//                     //       child: Container(
//                     //         decoration: BoxDecoration(
//                     //           color: Colors.transparent,
//                     //         ),
//                     //         width: AppSize.w38.w,
//                     //         height: AppSize.h35.h,
//                     //         child: Icon(
//                     //           Icons.undo,
//                     //           color: Colors.black,
//                     //           size: AppSize.w24,
//                     //         ),
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                     // ClipRRect(
//                     //   borderRadius: BorderRadius.circular(AppRadius.r50),
//                     //   child: Material(
//                     //     color: Colors.blue,
//                     //     child: InkWell(
//                     //       splashColor: Colors.white.withOpacity(0.6),
//                     //       onTap: () {
//                     //         setState(() {
//                     //           _whiteBoardController.redo();
//                     //
//                     //         });
//                     //       },
//                     //       child: Container(
//                     //         decoration: BoxDecoration(
//                     //           color: Colors.transparent,
//                     //         ),
//                     //         width: AppSize.w38.w,
//                     //         height: AppSize.h35.h,
//                     //         child: Icon(
//                     //           Icons.redo,
//                     //           color: Colors.black,
//                     //           size: AppSize.w24,
//                     //         ),
//                     //       ),
//                     //     ),
//                     //   ),
//                     // ),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(AppRadius.r50),
//                       child: Material(
//                         color: Colors.blue,
//                         child: InkWell(
//                           splashColor: Colors.white.withOpacity(0.6),
//                           onTap: () {
//                             setState(() {
//                               _whiteBoardController.clear();
//
//                             });
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.transparent,
//                             ),
//                             width: AppSize.w38.w,
//                             height: AppSize.h35.h,
//                             child: Icon(
//                               Icons.clear_all,
//                               color: Colors.black,
//                               size: AppSize.w24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(AppRadius.r50),
//                       child: Material(
//                         color: Colors.blue,
//                         child: InkWell(
//                           splashColor: Colors.white.withOpacity(0.6),
//                           onTap: () {
//                             setState(() {
//
//                               earse=earse==true?false:true;
//
//                             });
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.transparent,
//                             ),
//                             width: AppSize.w38.w,
//                             height: AppSize.h35.h,
//                             child: Icon(
//                               Icons.cleaning_services_rounded,
//                               color:earse? Colors.red:Colors.black,
//                               size: AppSize.w24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     ClipRRect(
//                       borderRadius: BorderRadius.circular(AppRadius.r50),
//                       child: Material(
//                         color: Colors.yellow,
//                         child: InkWell(
//                           splashColor: Colors.white.withOpacity(0.6),
//                           onTap: () {
//                             scale=scale==true?false:true;
//
//                             setState(() {
//
//                             });
//                           },
//                           child: Container(
//                             decoration: BoxDecoration(
//                               color: Colors.transparent,
//                             ),
//                             width: AppSize.w38.w,
//                             height: AppSize.h35.h,
//                             child: Icon(
//                               Icons.scale,
//                               color:scale? Colors.red:Colors.black,
//                               size: AppSize.w24,
//                             ),
//                           ),
//                         ),
//                       ),
//                     ),
//                     CustomNumberPicker(
//                       initialValue: 5,
//                       maxValue: 60,
//                       minValue: 3,
//                       step: 1,
//                       onValue: (value) {
//                         setState(() {
//                           widthvalue=value;
//                         });
//
//                       },
//                     )
//
//
//
//                   ],
//                 ),
//               ),
//             ),
//           ),
//           Container(
//             height: size.height-100 ,
//             child:  WhiteBoard(
//               signaling: widget.signaling,
//               dataChannel: widget.dataChannel,
//               scale:scale,
//               // background Color of white board
//               backgroundColor: AppColors.white,
//               // Controller for action on whiteboard
//               controller:_whiteBoardController ,
//               // Stroke width of freehand
//               strokeWidth: double.parse(widthvalue.toString()),
//               // Stroke color of freehand
//               strokeColor: currentColor,
//               // For Eraser mode
//               isErasing: earse,
//               // Save image
//               onConvertImage: (list){},
//               // Callback common for redo or undo
//               onRedoUndo: (t,m){},
//             ),
//           )
//
//
//         ],
//       ),
//     );
//   }
//
//   showColorsPicker(){
//     // create some values
//
// // ValueChanged<Color> callback
//     void changeColor(Color color) {
//       setState(() => pickerColor = color);
//     }
//
// // raise the [showDialog] widget
//     showDialog(
//       context: context,
//        builder: (BuildContext context) {
//
//         return  AlertDialog(
//           title: const Text('Pick a color!'),
//           content: SingleChildScrollView(
//             child: ColorPicker(
//               pickerColor: pickerColor,
//               onColorChanged: changeColor,
//             ),
//             // Use Material color picker:
//             //
//             // child: MaterialPicker(
//             //   pickerColor: pickerColor,
//             //   onColorChanged: changeColor,
//             //   showLabel: true, // only on portrait mode
//             // ),
//             //
//             // Use Block color picker:
//             //
//             // child: BlockPicker(
//             //   pickerColor: currentColor,
//             //   onColorChanged: changeColor,
//             // ),
//             //
//             // child: MultipleChoiceBlockPicker(
//             //   pickerColors: currentColors,
//             //   onColorsChanged: changeColors,
//             // ),
//           ),
//           actions: <Widget>[
//             ElevatedButton(
//               child: const Text('Got it'),
//               onPressed: () {
//                 setState(() => currentColor = pickerColor);
//                 Navigator.of(context).pop();
//               },
//             ),
//           ],
//         );
//        },
//     );
//   }
// }
