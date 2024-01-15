// import 'package:flutter/material.dart';
// import 'package:flutter_webrtc/flutter_webrtc.dart';
// import 'package:jeras/blocs/test_web_rtc/signaling.dart';
//
//
// class TestWebRTCScreen extends StatelessWidget {
//   // This widget is the root of your application.
//   @override
//   Widget build(BuildContext context) {
//     return MaterialApp(
//       title: 'Flutter Demo',
//       theme: ThemeData(
//         primarySwatch: Colors.blue,
//       ),
//       home: MyHomePage(),
//     );
//   }
// }
//
// class MyHomePage extends StatefulWidget {
//   MyHomePage({Key? key}) : super(key: key);
//
//   @override
//   _MyHomePageState createState() => _MyHomePageState();
// }
//
// class _MyHomePageState extends State<MyHomePage> {
//   Signaling signaling = Signaling();
//   RTCVideoRenderer _localRenderer = RTCVideoRenderer();
//   RTCVideoRenderer _remoteRenderer = RTCVideoRenderer();
//   String? roomId;
//   TextEditingController textEditingController = TextEditingController(text: '');
//
//   @override
//   void initState() {
//     _localRenderer.initialize();
//     _remoteRenderer.initialize();
//
//     print('==================r $_localRenderer');
//     print('==================r $_remoteRenderer');
//     signaling.onAddRemoteStream = ((stream) {
//       _remoteRenderer.srcObject = stream;
//       setState(() {});
//     });
//
//     super.initState();
//   }
//
//   @override
//   void dispose() {
//     _localRenderer.dispose();
//     _remoteRenderer.dispose();
//     super.dispose();
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     return Scaffold(
//       appBar: AppBar(
//         title: Text("Welcome to Flutter Explained - WebRTC"),
//       ),
//       body: Column(
//         children: [
//           SizedBox(height: 8),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   signaling.openUserMedia(_localRenderer, _remoteRenderer);
//                 },
//                 child: Text("Open camera & microphone"),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   roomId = await signaling.createRoom(_remoteRenderer);
//                   textEditingController.text = roomId!;
//                   print('=================room $roomId');
//                   setState(() {});
//                 },
//                 child: Text("Create room"),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   // Add roomId
//                   signaling.joinRoom(
//                     textEditingController.text.trim(),
//                     _remoteRenderer,
//                   );
//                 },
//                 child: Text("Join room"),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () {
//                   signaling.hangUp(_localRenderer);
//                 },
//                 child: Text("Hangup"),
//               )
//             ],
//           ),
//           SizedBox(height: 8),
//           Expanded(
//             child: Padding(
//               padding: const EdgeInsets.all(8.0),
//               child: Row(
//                 mainAxisAlignment: MainAxisAlignment.center,
//                 children: [
//                   Expanded(child: Container(
//                       padding: EdgeInsets.all(20),
//                       color: Colors.green,
//                       child: RTCVideoView(_localRenderer, mirror: true))),
//                   SizedBox(width: 20,),
//                   Expanded(child: Container(
//                       padding: EdgeInsets.all(20),
//                       color: Colors.red,
//                       child: RTCVideoView(_remoteRenderer))),
//                 ],
//               ),
//             ),
//           ),
//
//           SizedBox(height: 18),
//           Row(
//             mainAxisAlignment: MainAxisAlignment.center,
//             children: [
//               ElevatedButton(
//                 onPressed: () {
//                   signaling.closeMic(_localRenderer);
//                 },
//                 child: Text("Close Mic"),
//               ),
//               SizedBox(
//                 width: 8,
//               ),
//               ElevatedButton(
//                 onPressed: () async {
//                   signaling.openUserMedia(_localRenderer, _remoteRenderer, cameraOpen: true,);
//                 },
//                 child: Text("Open Camera"),
//               ),
//             ],
//           ),
//           SizedBox(height: 18),
//
//           Padding(
//             padding: const EdgeInsets.all(8.0),
//             child: Row(
//               mainAxisAlignment: MainAxisAlignment.center,
//               children: [
//                 Text("Join the following Room: "),
//                 Flexible(
//                   child: TextFormField(
//                     controller: textEditingController,
//                   ),
//                 )
//               ],
//             ),
//           ),
//           SizedBox(height: 8)
//         ],
//       ),
//     );
//   }
// }