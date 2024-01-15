import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:video_player/video_player.dart';

class FirebaseVideoPlayerWidget extends StatefulWidget {
  String? link;

  FirebaseVideoPlayerWidget(this.link);
  @override
  _VideoPlayerWidgetState createState() => _VideoPlayerWidgetState();
}

class _VideoPlayerWidgetState extends State<FirebaseVideoPlayerWidget> {
  late VideoPlayerController videoPlayerController;
  double videoDuration = 0;
  double currentDuration = 0;

  @override
  void initState() {
    super.initState();
    print("Vid Link from widget : ${widget.link}");
    videoPlayerController = VideoPlayerController.network(widget.link!);
    videoPlayerController.initialize().then((_) {
      setState(() {
        videoDuration =
            videoPlayerController.value.duration.inMilliseconds.toDouble();
      });
    });

    videoPlayerController.addListener(() {
      setState(() {
        currentDuration =
            videoPlayerController.value.position.inMilliseconds.toDouble();
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return videoPlayerController.value.isInitialized
        ? InkWell(
            onTap: () {
              setState(() {
                videoPlayerController.value.isPlaying
                    ? videoPlayerController.pause()
                    : videoPlayerController.play();
              });
            },
            child: AspectRatio(
              aspectRatio: videoPlayerController.value.aspectRatio,
              child: VideoPlayer(videoPlayerController),
            ),
          )
        : Container(
            height: 200,
            color: AppColors.white,
            child: Center(
              child: Text(
                '',
                style: TextStyle(
                  color: AppColors.black,
                  fontSize: AppFontsSizeManager.s21.sp,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          );
  }

  @override
  void dispose() {
    videoPlayerController.dispose();
    super.dispose();
  }
}
