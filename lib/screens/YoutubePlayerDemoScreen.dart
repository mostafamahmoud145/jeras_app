import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_svg/svg.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';
import '../localization/localization_methods.dart';

class YoutubePlayerDemoScreen extends StatefulWidget {
  final String link;
  final String desc;

  const YoutubePlayerDemoScreen(
      {Key? key, required this.link, required this.desc})
      : super(key: key);

  @override
  _YoutubePlayerDemoScreenState createState() =>
      _YoutubePlayerDemoScreenState();
}

class _YoutubePlayerDemoScreenState extends State<YoutubePlayerDemoScreen> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();
    _controller = YoutubePlayerController(
      initialVideoId: widget.link
          .replaceAll("https://www.youtube.com/watch?v=", "")
          .trim()
          .replaceAll("https://www.youtube.com/shorts/", "")
          .trim(),
      flags: YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return YoutubePlayerBuilder(
      player: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.blueAccent,
        topActions: <Widget>[
          IconButton(
            icon: const Icon(
              Icons.fit_screen,
              color: Colors.white,
              size: AppSize.w25,
            ),
            onPressed: () async {
              await launch(widget.link);
            },
          ),
          const SizedBox(width: 8.0),
          (widget.link != "")
              ? Expanded(
                  child: Text(
                    _controller.metadata.title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: AppFontsSizeManager.s18,
                    ),
                    overflow: TextOverflow.ellipsis,
                    maxLines: 1,
                  ),
                )
              : SizedBox(),
        ],
      ),
      builder: (context, player) => Scaffold(
        body: Column(
          children: [
            Container(
                width: size.width,
                child: SafeArea(
                    child: Padding(
                  padding: const EdgeInsets.only(
                      left: AppPadding.p10,
                      right: AppPadding.p10,
                      top: 0.0,
                      bottom: AppPadding.p6),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.start,
                    children: [
                      Container(
                        height: AppSize.h35,
                        width: AppSize.w35,
                        child: Center(
                          child: IconButton(
                            onPressed: () {
                              Navigator.pop(context);
                            },
                            icon: SvgPicture.asset(
                              AssetsManager.rightArrowIconPath,
                              width: AppSize.w30,
                              height: AppSize.h30,
                            ),
                          ),
                        ),
                      ),
                      Text(
                        getTranslated(context, "addMore"),
                        textAlign: TextAlign.left,
                        style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize: AppFontsSizeManager.s16,
                            color: Colors.black.withOpacity(0.8),
                            fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                ))),
            Center(
                child: Container(
                    color: AppColors.lightGrey,
                    height: AppSize.h2,
                    width: size.width * AppSize.w0_9)),
            Expanded(child: player),
            SizedBox(
              height: AppSize.h5,
            ),
            widget.desc != null
                ? Text(
                    widget.desc,
                    textAlign: TextAlign.center,
                    style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s12,
                        color: Colors.black.withOpacity(0.5)),
                  )
                : SizedBox(),
          ],
        ),
      ),
    );
  }

  Widget buildwww(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.white,
      body: Center(
        child: YoutubePlayerBuilder(
          player: YoutubePlayer(
            controller: _controller,
            showVideoProgressIndicator: true,
            progressIndicatorColor: AppColors.amber,
            progressColors: ProgressBarColors(
              playedColor: AppColors.amber,
              handleColor: Colors.amberAccent,
            ),
            onReady: () {
              _controller.addListener(() {});
            },
          ),
          builder: (context, player) => player,
        ),
      ),
    );
  }

  @override
  void dispose() {
    _controller.dispose();
    SystemChrome.setPreferredOrientations(DeviceOrientation.values);
    super.dispose();
  }
}
