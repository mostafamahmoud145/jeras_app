
import 'package:flutter/material.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

import '../../screens/videoDetailsScreen.dart';
import '../config/colors_file.dart';
import '../models/user.dart';




class YouTubeVideoRow extends StatefulWidget {
  final Video  video;
  final String  consultUid;
  final bool allowEdit;

  const YouTubeVideoRow({
     Key? key,
    required this.video, required this.allowEdit, required this.consultUid
  }) : super(key: key);

  @override
  _YouTubeVideoRowState createState() => _YouTubeVideoRowState();
}

class _YouTubeVideoRowState extends State<YouTubeVideoRow> {
  late YoutubePlayerController _controller;

  @override
  void initState() {
    super.initState();

    _controller = YoutubePlayerController(
      initialVideoId: widget.video.link!.replaceAll("https://www.youtube.com/watch?v=", "").trim()
          .replaceAll("https://www.youtube.com/shorts/", "").trim(),
      flags: YoutubePlayerFlags(
        autoPlay: false,
        mute: false,
      ),
    );
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return YoutubePlayerBuilder(
        player: YoutubePlayer(
          controller: _controller,
         // aspectRatio:16/3,
          showVideoProgressIndicator: true,

        ),

        builder: (context, player) {
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Stack(children: [
                Container(
                  child: ClipRRect(
                      borderRadius: const BorderRadius.all(Radius.circular(25)),
                      child: player),
                ),
                widget.allowEdit?InkWell(onTap: (){
                  Navigator.pop(context);
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => VideoDetailsScreen(video: widget.video,consultUid: widget.consultUid,), ),);
                },
                  child: Container(width:30,height: 30,
                      padding:EdgeInsets.all(5),
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        color: AppColors.lightPink,),
                      child:
                      Icon( Icons.edit,color:AppColors.pink,size: 20.0, )),
                ):SizedBox(),
              ],),
              SizedBox(height: 10.0),
              widget.video.desc!=null?Text(
                widget.video.desc!,
                textAlign: TextAlign.center,
                overflow:TextOverflow.ellipsis,
                maxLines: 1,
                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),fontSize: 9.0,
                    color:AppColors.grey),
              ):SizedBox(),
            ],
          );

        }
    );
  }
}