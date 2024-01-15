// import 'package:flutter/cupertino.dart';
// import 'package:webview_flutter/webview_flutter.dart';
//
//
// class loadwebView extends StatefulWidget{
//
//   String ? Url;
//   Function (int progress)? onProgress;
//   Function (String url)? onPageStarted;
//   Function (String  finish) ?onPageFinished;
//   Function (NavigationRequest request) ? onNavigationRequest;
//
//
//   loadwebView({this.Url,this.onProgress,this.onPageStarted,this.onPageFinished,this.onNavigationRequest});
//
//     @override
//   State<StatefulWidget> createState() {
//     // TODO: implement createState
//    return   loadwebViewState();
//
//    }
//   }
//
//
// class loadwebViewState extends State<loadwebView>{
//  static WebViewController controller = WebViewController();
//
//
//  @override
//   void initState() {
// //
//  super.initState();
//
//    controller..setJavaScriptMode(JavaScriptMode.unrestricted)
//      ..setBackgroundColor(const Color(0x00000000))
//      ..setNavigationDelegate(
//        NavigationDelegate(
//          onProgress: (int progress) {
//            widget.onProgress!.call(progress);
//          },
//          onPageStarted: (String url) {},
//          onPageFinished: (finish) {
//            widget.onPageFinished!.call(finish);
//
//
//          },
//          onWebResourceError: (WebResourceError error) {},
//          onNavigationRequest: (NavigationRequest request) {
//            widget.onNavigationRequest!.call(request);
//            return NavigationDecision.navigate;
//          },
//        ),
//      )..loadRequest(Uri.parse(widget!.Url!));
//
//
//  }
//
//   @override
//   Widget build(BuildContext context) {
//
//     return  WebViewWidget(
//     controller: controller,
//
//     );
//
//   }
//
// }