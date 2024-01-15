import 'package:flutter/cupertino.dart';
import 'package:webview_flutter/webview_flutter.dart';

class loadwebView extends StatelessWidget{
  String ? Url;
  Function (int progress)? onProgress;
  Function (String url)? onPageStarted;
  Function (String  finish) ?onPageFinished;
  Function (NavigationRequest request) ? onNavigationRequest;

  loadwebView({this.Url,this.onProgress,this.onPageStarted,this.onPageFinished,this.onNavigationRequest});

    @override
  Widget build(BuildContext context) {
    // TODO: implement build
   return Container();
  }

}
