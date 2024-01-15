import 'dart:html' as html;
import 'dart:ui' as ui;

import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';


class VideoWidget extends StatefulWidget {
  String link;
  String ? VideoAppid;

  VideoWidget({super.key, required this.link,this.VideoAppid});

  @override
  _VideoAppState createState() => _VideoAppState();
}

class _VideoAppState extends State<VideoWidget> {

  @override
  void initState() {

    // String videoid=widget.link.substring(widget.link.indexOf("=")+1,widget.link.length);
    //
    // 
    //




    // _controller.loadVideo( 'https://www.youtube.com/watch?v=EUHV_gSMWSI&ab_channel=%D9%85%D8%B9%D8%A7%D8%B0%D8%AD%D9%85%D9%88%D8%AF%D8%A9'
    // );



    //     _controller2 = VideoPlayerController.network('https://www.youtube.com/watch?v=EUHV_gSMWSI&ab_channel=%D9%85%D8%B9%D8%A7%D8%B0%D8%AD%D9%85%D9%88%D8%AF%D8%A9'
    // )
    //   ..initialize().then((_) {
    //     // Ensure the first frame is shown after the video is initialized, even before the play button has been pressed.
    //     setState(() {});
    //   });

    super.initState();
  }

  @override
  Widget build(BuildContext context) {

    // return  _controller2.value.isInitialized
    //     ? AspectRatio(
    //   aspectRatio: _controller2.value.aspectRatio,
    //   child: VideoPlayer(_controller2),
    // )
    //     : Container();

    return Iframe(widget.link
    );

  }




  @override
  void dispose() {

    super.dispose();
  }
}


class Iframe extends StatelessWidget {
  String Url;
  Iframe( this.Url ) {
    // ignore: undefined_prefixed_name
    ui.platformViewRegistry.registerViewFactory(Url, (int viewId) {
      var iframe = html.IFrameElement();
      iframe.src = this.Url.replaceAll('watch?v=', 'embed/');
      iframe.width=200.w.toString();
      iframe.height=300.h.toString();

      iframe.style.border='none';


      return iframe;
    });
  }
  @override
  Widget build(BuildContext context) {
    return Container(
        width: 200.w,
        height: 300.h,
        child: HtmlElementView(viewType: Url));
  }
}