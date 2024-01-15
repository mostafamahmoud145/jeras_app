import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../config/colors_file.dart';
import '../screens/YoutubePlayerDemoScreen.dart';

class VideoWidget extends StatefulWidget {
  final String link;
  String? VideoAppid;

  VideoWidget({required this.link, this.VideoAppid});

  @override
  _VideoWidgetState createState() => _VideoWidgetState();
}

class _VideoWidgetState extends State<VideoWidget>
    with SingleTickerProviderStateMixin {
  YoutubePlayerController? _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.link
          .replaceAll("https://www.youtube.com/watch?v=", "")
          .trim()
          .replaceAll("https://www.youtube.com/shorts/", "")
          .trim(),
      flags: const YoutubePlayerFlags(
        mute: false,
        autoPlay: false,
        disableDragSeek: false,
        loop: false,
        isLive: false,
        forceHD: false,
        enableCaption: false,
      ),
    );
  }

  @override
  void dispose() {
    _controller!.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
      onExitFullScreen: () {
        SystemChrome.setPreferredOrientations(DeviceOrientation.values);
      },
      player: YoutubePlayer(
        controller: _controller!,
        showVideoProgressIndicator: true,
        progressIndicatorColor: AppColors.pink,
        bottomActions: [
          CurrentPosition(),
          ProgressBar(isExpanded: true),
          RemainingDuration(),
          // FullScreenButton(),
        ],
        topActions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.fit_screen,
              color: AppColors.white,
              size: 25.0,
            ),
            onPressed: () async {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) =>
                        YoutubePlayerDemoScreen(link: widget.link, desc: " ")),
              );
            },
          ),
          (widget.link != "")
              ? Expanded(
                  child: Text(
                    _controller!.metadata.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18.0,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              : SizedBox(),
        ],
      ),
      builder: (context, player) => Stack(
        children: [
          Column(
            children: [
              Center(
                child: ClipRRect(
                    borderRadius: BorderRadius.all(Radius.circular(18.r)),
                    child: Container(height: 244.h, child: player)),
              ),
            ],
          ),
          // Positioned(
          //   //padding:  EdgeInsets.symmetric(vertical: size.height * .1),
          //   top: 10,
          //   left: 10,
          //   child: Column(
          //     children: [
          //       IconButton(
          //           padding: EdgeInsets.zero,
          //           icon: Container(
          //               width: 30,
          //               height: 30,
          //               decoration: BoxDecoration(
          //                   borderRadius: BorderRadius.circular(40),
          //                   border: Border.all(
          //                       color: const Color(0xadffffff), width: 1),
          //                   color: Colors.white.withOpacity(.2)),
          //               child: Center(
          //                 child: Icon(
          //                   Icons.favorite,
          //                   size: 17,
          //                   color: AppColors.red,
          //                 ),
          //               )),
          //           onPressed: () {
          //             //TODO:: add favorite functionality
          //           }),
          //     ],
          //   ),
          // )
        ],
      ),
    );
  }
}
