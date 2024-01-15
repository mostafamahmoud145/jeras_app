import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/controller/blocs/replace_video_bloc/state.dart';
import 'package:jeras/models/user.dart';
import 'package:video_player/video_player.dart';

import '../../../screens/video_loading_screen.dart';

class VideoCubit extends Cubit<VideoStates> {
  VideoCubit(super.VideoInitialState);

  static VideoCubit get(context) => BlocProvider.of(context);

  VideoPlayerController? replaceVidController;
  bool replaceVideo = false;
  XFile? picRepMainVideo;

  void changeState(
    context,
    GroceryUser user,
    Video consultVideo,
    String? consultUid,
    XFile replaceMainVideo,
  ) {
    picRepMainVideo = replaceMainVideo;
    replaceVideo = true;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute(
          builder: (BuildContext context) => LoadingScreen(
                user: user,
                consultVideo: consultVideo,
                check: true,
                consultUid: consultUid,
              )),
    );
  }
}
