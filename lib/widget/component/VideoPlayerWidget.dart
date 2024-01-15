import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:jeras/api/api.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/colors_file.dart';
import 'package:jeras/config/paths.dart';
import 'package:jeras/models/user.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:video_player/video_player.dart';
import 'package:path/path.dart' as p;
import 'package:youtube_player_flutter/youtube_player_flutter.dart';
import '../../config/app_values.dart';
import '../../localization/localization_methods.dart';
import '../jerasDialogWidget.dart';
import '../videoWidget.dart';
import 'IconButton.dart';

class VideoPlayerWidget extends StatefulWidget {
  final File videoUrl;
  late GroceryUser user;


  VideoPlayerWidget(this.videoUrl, this.user,);

  @override
  _VideoPlayerWidgetState createState() =>
      _VideoPlayerWidgetState(videoUrl, user);
}

class _VideoPlayerWidgetState extends State<VideoPlayerWidget> {
  PlatformFile? pickedfile;
  File? file;
  XFile?webFile;
  UploadTask? task;
  late String downloadurl = '';
  late  VideoPlayerController videoPlayerController;
  late  VideoPlayerController newVideoPlayerController;

  File videoUrl;
  GroceryUser user;
  double videoDuration = 0;
  double currentDuration = 0;

  _VideoPlayerWidgetState(this.videoUrl, this.user);

  GroceryUser? consultant;
  bool uploadingVid = false;
  bool deletingVid = false;
  bool replaceVid = false;
  bool selectVid = false;
  bool updateVid = false;

  @override
  void initState() {
    super.initState();
if(user.link == null){
  videoPlayerController = VideoPlayerController.file(videoUrl);
}else{
  // if(user.link!
  //     .contains('firebase')){
  {
    videoPlayerController =
        VideoPlayerController.network(user.link.toString());
  }

}
    videoPlayerController.initialize().then((_) {
      setState(() {
        videoDuration =
            videoPlayerController.value.duration.inMilliseconds.toDouble();
      });
    });

    videoPlayerController.addListener(() {
      // setState(() {
      //   currentDuration =
      //       videoPlayerController.value.position.inMilliseconds.toDouble();
      // });
    });
    print(videoUrl);
  }

  @override
  Widget build(BuildContext context) {

    return Container(
      child: Container(
          color: AppColors.white,
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: <Widget>[
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: IconButton1(
                      onPress: () {
                        if (videoPlayerController.value.isPlaying) {
                          videoPlayerController.pause();
                        }
                        Navigator.pop(context);
                      },
                      Width: 50.6.w,
                      Height: 50.6.h,
                      ButtonRadius: 10.6.r,
                      IconWidth: 22.w,
                      IconHeight: 20.h,
                      IconColor: AppColors.black,
                      Icon: '${AppConstants.iconsPath}cancel-svgrepo-com.svg',
                      ButtonBackground: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 25.h,
              ),

              (widget.user.link != null)? Container(
                color: AppColors.white,
                constraints: BoxConstraints(maxHeight: 300),
                child: !widget.user.link!.contains('firebase')?
                Container(
                  height: 150,
                  child: VideoWidget(
                    link:widget.user.link!,
                    VideoAppid:widget.user.link!.toString()
                        .substring(
                        widget.user!.link
                            .toString()
                            .indexOf("=") +
                            1,
                        widget.user!.link
                            .toString()
                            .length),
                  ),
                )
                    : videoPlayerController.value.isInitialized
                    ?
                InkWell(
                    onTap: () {
                      setState(() {
                        videoPlayerController.value.isPlaying
                            ? videoPlayerController.pause()
                            : videoPlayerController.play();
                      });
                    },
                    child:  AspectRatio(
                      aspectRatio: videoPlayerController.value.aspectRatio,
                      child: VideoPlayer(videoPlayerController),
                    )
                )
                    : Container(
                  height: 200,
                  color: AppColors.white,
                  child:  Center(
                    child: CircularProgressIndicator(),
                  ),
                ),
              ):
              Container(
                color: AppColors.primaryColor,
                constraints: BoxConstraints(maxHeight: 300),
                child: videoPlayerController.value.isInitialized
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
                  child:  Center(
                    child: Text(
                      '',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s21.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),

              SizedBox(height: AppSize.h16.h,),
              /*Slider(
                value: currentDuration,
                max: videoDuration,
                onChanged: (value) => videoPlayerController
                    .seekTo(Duration(milliseconds: value.toInt())),
              ),*/
              (widget.user.link != null)
                  ? Padding(
                    padding:  EdgeInsets.only(left: AppPadding.p16.w,right: AppPadding.p16.w),
                    child: Row(
                children: [
                    Container(
                      width: AppSize.w160.w,
                      height: AppSize.h56.h,
                      //   alignment: Alignment.center,
                      decoration: BoxDecoration(
                        color: AppColors.linear2,
                        borderRadius:
                        BorderRadius.circular(AppRadius.r10_6.r),
                      ),
                      child: InkWell(
                          child: Center(
                            child: Text(
                              getTranslated(context, "replace"),
                              style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize:AppFontsSizeManager.s21_3.sp,
                                  color: AppColors.white,
                                  fontWeight: FontWeight.normal),
                            ),
                          ),
                          onTap:(){
                            setState(() {

                               selectVideoForUpdate();

                            });
                          }
                      ),
                    ),
                    SizedBox(width: AppSize.w45.w,),
                    Container(
                      width: AppSize.w160.w,
                      height: AppSize.h56.h,
                      //   alignment: Alignment.center,
                      decoration: BoxDecoration(
                          borderRadius: BorderRadius.all(
                              Radius.circular(AppRadius.r10_6.r)),
                          border: Border.all(
                            color: AppColors.linear2,
                            width: 1.5.w,
                          )),
                      child: InkWell(
                          child: deletingVid
                              ? Center(
                            heightFactor: 1,
                            widthFactor: 1,
                            child: SizedBox(
                              width: 16,
                              height: 16,
                              child: CircularProgressIndicator(
                                color: AppColors.white,
                              ),
                            ),
                          ):Center(
                                child: Text(
                            getTranslated(context, "delete"),
                            style: TextStyle(
                                  fontFamily: getTranslated(context, "Ithra"),
                                  fontSize:AppFontsSizeManager.s21_3.sp,
                                  color: AppColors.linear2,
                                  fontWeight: FontWeight.normal),
                          ),
                              ),
                          onTap: () async {

                              // final result = FirebaseStorage.instance
                              //     .refFromURL(widget.user.link!)
                              //     .delete();
                              //
                              //
                              // if (result != null) {
                                DocumentReference docRef = FirebaseFirestore
                                    .instance
                                    .collection(Paths.usersPath)
                                    .doc(widget.user.uid);
                                await docRef.get().then((value) async {
                                  Map data = value.data() as Map;
                                  print(data['link']);
                                  if (data['link']
                                      .toString()
                                      .isNotEmpty) {
                                    await FirebaseFirestore.instance
                                        .collection(Paths.usersPath)
                                        .doc(widget.user.uid)
                                        .set({
                                      'link': null,
                                    }, SetOptions(merge: true));
                                    widget.user.link = null;
                                    Navigator.pop(context);
                                    final snackBar = SnackBar(
                                      content: Center(
                                        child: Text(
                                          getTranslated(context,
                                              'YourVideoIsDeletedSuccessfully'),
                                          style: TextStyle(
                                            color: AppColors.white,
                                            fontSize: AppFontsSizeManager.s21
                                                .sp,
                                            fontWeight: FontWeight.w600,
                                          ),
                                        ),
                                      ),
                                      backgroundColor: AppColors.linear1,
                                    );
                                    ScaffoldMessenger.of(context)
                                        .showSnackBar(snackBar);
                                  }
                                  setState(() {
                                    deletingVid = true;
                                  });
                                });
                                print('Delete successful');
                             // }

                          }),
                    ),
                ],
              ),
                  )
                  : Padding(
                    padding:  EdgeInsets.only(bottom: AppPadding.p16.w),
                    child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12.0.h),
                      child: Container(
                        width: AppSize.w160.w,
                        height: AppSize.h56.h,
                        //   alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.linear2,
                          borderRadius:
                          BorderRadius.circular(AppRadius.r10_6.r),
                        ),
                        child: InkWell(
                            child: uploadingVid
                                ? Center(
                              heightFactor: 1,
                              widthFactor: 1,
                                  child: SizedBox(
                              width: 16,
                                    height: 16,
                                    child: CircularProgressIndicator(
                              color: AppColors.white,
                            ),
                                  ),
                                )
                                : Center(
                                  child: Text(
                              getTranslated(context, "upload"),
                                    style: TextStyle(
                                        fontFamily: getTranslated(context, "Ithra"),
                                        fontSize:AppFontsSizeManager.s21_3.sp,
                                        color: AppColors.white,
                                        fontWeight: FontWeight.normal),
                            ),
                                ),
                            onTap: () {
                              setState(() {
                                uploadingVid = true;
                              });
                              uploadVideo(File(widget.videoUrl.path));

                            }),
                      ),
                    ),
                    ///
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom:24.0),
                    //   child: InkWell(
                    //       child: Icon(
                    //         videoPlayerController.value.isPlaying
                    //             ? Icons.pause
                    //             : Icons.play_arrow,
                    //       ),
                    //       onTap: () {
                    //         setState(() {
                    //           videoPlayerController.value.isPlaying
                    //               ? videoPlayerController.pause()
                    //               : videoPlayerController.play();
                    //         });
                    //       }),
                    // ),
                    // Padding(
                    //   padding: const EdgeInsets.only(bottom:24.0),
                    //   child: InkWell(
                    //       child: Text('Delete',style: TextStyle(fontSize: 20.sp,color: AppColors.black),),
                    //       onTap: () {
                    //         final result =FirebaseStorage.instance.refFromURL(videoUrl).delete();
                    //         if(result!=null){
                    //           Navigator.pop(context);
                    //           print('Delete successful');
                    //         }
                    //       }),
                    // ),
                    ///

                ],
              ),
                  )
            ],
          )),
    );
  }
  showFirstUploadDialog() {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Container(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Row(
                children: [
                  Padding(
                    padding: EdgeInsets.only(right: 15.w),
                    child: IconButton1(
                      onPress: () {
                        Navigator.pop(context);
                      },
                      Width: 50.6.w,
                      Height: 50.6.h,
                      ButtonRadius: 10.6.r,
                      IconWidth: 22.w,
                      IconHeight: 20.h,
                      IconColor: AppColors.black,
                      Icon: '${AppConstants.iconsPath}cancel-svgrepo-com.svg',
                      ButtonBackground: Colors.white,
                    ),
                  ),
                ],
              ),
              SizedBox(
                height: 15.h,
              ),

              Container(
                color: AppColors.primaryColor,
                constraints: BoxConstraints(maxHeight: 300),
                child: videoPlayerController.value.isInitialized
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
                  child:  Center(
                    child: Text(
                      '',
                      style: TextStyle(
                        color: AppColors.black,
                        fontSize: AppFontsSizeManager.s21.sp,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
              ),
              Padding(
                padding:  EdgeInsets.only(bottom: AppPadding.p16.w),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    Padding(
                      padding: EdgeInsets.only(top: 12.0.h),
                      child: Container(
                        width: AppSize.w160.w,
                        height: AppSize.h56.h,
                        //   alignment: Alignment.center,
                        decoration: BoxDecoration(
                          color: AppColors.linear2,
                          borderRadius:
                          BorderRadius.circular(AppRadius.r10_6.r),
                        ),
                        child: InkWell(
                            child: uploadingVid
                                ? Center(
                              heightFactor: 1,
                              widthFactor: 1,
                              child: SizedBox(
                                width: 16,
                                height: 16,
                                child: CircularProgressIndicator(
                                  color: AppColors.white,
                                ),
                              ),
                            )
                                : Center(
                              child: Text(
                                getTranslated(context, "upload"),
                                style: TextStyle(
                                    fontFamily: getTranslated(context, "Ithra"),
                                    fontSize:AppFontsSizeManager.s21_3.sp,
                                    color: AppColors.white,
                                    fontWeight: FontWeight.normal),
                              ),
                            ),
                            onTap: () {
                              setState(() {
                                uploadingVid = true;
                              });
                              uploadVideo(File(widget.videoUrl.path));

                            }),
                      ),
                    ),
                    ///
                    /*Padding(
                      padding: const EdgeInsets.only(bottom:24.0),
                      child: InkWell(
                          child: Icon(
                            videoPlayerController.value.isPlaying
                                ? Icons.pause
                                : Icons.play_arrow,
                          ),
                          onTap: () {
                            setState(() {
                              videoPlayerController.value.isPlaying
                                  ? videoPlayerController.pause()
                                  : videoPlayerController.play();
                            });
                          }),
                    ),
                    Padding(
                      padding: const EdgeInsets.only(bottom:24.0),
                      child: InkWell(
                          child: Text('Delete',style: TextStyle(fontSize: 20.sp,color: AppColors.black),),
                          onTap: () {
                            final result =FirebaseStorage.instance.refFromURL(videoUrl).delete();
                            if(result!=null){
                              Navigator.pop(context);
                              print('Delete successful');
                            }
                          }),
                    ),*/
                    ///

                  ],
                ),
              )
            ],
          ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }

  showUpdateDialog() {
    return showDialog(
      builder: (context) => JerasDialogWidget(
        dialogContent: Container(
          child: Column(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            Row(
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 15.w),
                  child: IconButton1(
                    onPress: () {
                      Navigator.pop(context);
                    },
                    Width: 50.6.w,
                    Height: 50.6.h,
                    ButtonRadius: 10.6.r,
                    IconWidth: 22.w,
                    IconHeight: 20.h,
                    IconColor: AppColors.black,
                    Icon: '${AppConstants.iconsPath}cancel-svgrepo-com.svg',
                    ButtonBackground: Colors.white,
                  ),
                ),
              ],
            ),
            SizedBox(
              height: 15.h,
            ),

            Container(
              color: AppColors.primaryColor,
              constraints: BoxConstraints(maxHeight: 300),
              child: videoPlayerController.value.isInitialized
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
                child:  Center(
                  child: Text(
                    '',
                    style: TextStyle(
                      color: AppColors.black,
                      fontSize: AppFontsSizeManager.s21.sp,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ),
            ),
            Padding(
              padding:  EdgeInsets.only(left: AppPadding.p16.w,right: AppPadding.p16.w,top: AppPadding.p16.h),
              child: Row(
                children: [
                  Container(
                    width: AppSize.w160.w,
                    height: AppSize.h56.h,
                    //   alignment: Alignment.center,
                    decoration: BoxDecoration(
                      color: AppColors.linear2,
                      borderRadius:
                      BorderRadius.circular(AppRadius.r10_6.r),
                    ),
                    child: InkWell(
                        child: updateVid
                            ? Center(
                          heightFactor: 1,
                          widthFactor: 1,
                          child: SizedBox(
                            width: 16,
                            height: 16,
                            child: CircularProgressIndicator(
                              color: AppColors.white,
                            ),
                          ),
                        )
                            :  Center(
                              child: Text(
                        getTranslated(context, "upload"),
                    style: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize:AppFontsSizeManager.s21_3.sp,
                        color: AppColors.white,
                        fontWeight: FontWeight.normal),
                  ),
                            ),
                        onTap: ()async {
                          await updateFile();
                          Navigator.pop(context);
                          Navigator.pop(context);

                          final snackBar = SnackBar(
                            content: Center(
                              child: Text(
                                getTranslated(context, "YourVideoIsUploadedSuccessfully"),
                                style: TextStyle(
                                  color: AppColors.white,
                                  fontSize: AppFontsSizeManager.s21.sp,
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                            ),
                            backgroundColor: AppColors.linear1,
                          );
                          ScaffoldMessenger.of(context).showSnackBar(snackBar);
                        }),
                  ),
                  SizedBox(width: AppSize.w45.w,),
                  Container(
                    width: AppSize.w160.w,
                    height: AppSize.h56.h,
                    //   alignment: Alignment.center,
                    decoration: BoxDecoration(
                        borderRadius: BorderRadius.all(
                            Radius.circular(AppRadius.r10_6.r)),
                        border: Border.all(
                          color: AppColors.linear2,
                          width: 1.5.w,
                        )),
                    child: InkWell(
                        child: Center(
                          child: Text(
                            getTranslated(context, "replace"),
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize:AppFontsSizeManager.s21_3.sp,
                                color: AppColors.linear2,
                                fontWeight: FontWeight.normal),
                          ),
                        ),
                        onTap:(){
                          selectVideoForUpdate();
                        }
                    ),
                  ),

                ],
              ),
            ),
          ],
      ),
        ),
      ),
      barrierDismissible: false,
      context: context,
    );
  }


  ///--------------------------<<<Select video before update>>>----------------------------///

  selectVideoForUpdate()async{
    if (widget.user.link != null) {
      final result = await FilePicker.platform.pickFiles(
        type: FileType.video,
        //allowedExtensions:['mp4'],
        allowMultiple: false,
      );
      if (result != null ) {
        String newVideoPath = result.files.single.path.toString();
        videoPlayerController = VideoPlayerController.file(File(newVideoPath));

        videoPlayerController.initialize().then((_) {
          //Navigator.pop(context);

          showUpdateDialog();


        });

      }
      if (result == null) return;
      setState(() {
          final res = result.files.single.path!;
          file = File(res);
      });
    }
  }

List<String> paths=[];

  ///--------------------------<<<Update Video To Firebase>>>----------------------------///

  Future updateFile() async {
    final filename = p.basename(file!.path);
    final destination = 'consultVideos/$filename';
    task = APIs.uploadTask(destination, file!);
    if (task == null) return print('error');
    final snap = await task!.whenComplete(() {});
    final url = await snap.ref.getDownloadURL();
    downloadurl = url.toString();



    print('Link:$downloadurl');
    print('Update successful');
    DocumentReference docRef = FirebaseFirestore.instance
        .collection(Paths.usersPath)
        .doc(widget.user.uid);
    await docRef.get().then((value) async {
      Map data = value.data() as Map;
      print(data['link']);
      if (data['link'] != null) {
        await FirebaseFirestore.instance
            .collection(Paths.usersPath)
            .doc(widget.user.uid)
            .set({
          'link': downloadurl,
        }, SetOptions(merge: true));
      }
    });




  }


  ///--------------------------<<<Upload Video To Firebase>>>----------------------------///

  void uploadVideo(File file) async {
    var fileName = p.basename(widget.videoUrl.path);
    var storageRef = FirebaseStorage.instance.ref().child("consultVideos/$fileName");

    try {
      await storageRef.putFile(file);

      downloadurl = await storageRef.getDownloadURL();
      print("Video uploaded. Download URL: $downloadurl");

      DocumentReference _documentReference = FirebaseFirestore.instance
          .collection(Paths.usersPath)
          .doc(widget.user.uid);
      DocumentSnapshot documentSnapshot = await _documentReference.get();
      Map<String, dynamic> data =
          documentSnapshot.data() as Map<String, dynamic>;

      if (data['link'] == null) {
        await _documentReference.set({
          'link': downloadurl,
        }, SetOptions(merge: true));
      }
      paths.add(downloadurl);
      Navigator.pop(context);

      final snackBar = SnackBar(
        content: Center(
          child: Text(
            getTranslated(context, "YourVideoIsUploadedSuccessfully"),
            style: TextStyle(
              color: AppColors.white,
              fontSize: AppFontsSizeManager.s21.sp,
              fontWeight: FontWeight.w600,
            ),
          ),
        ),
        backgroundColor: AppColors.linear1,
      );
      ScaffoldMessenger.of(context).showSnackBar(snackBar);
    } catch (e) {
      print("Error uploading the video: $e");
    }
  }
  Future<void> deleteOldVideo(String oldVideoPath) async {
    final Reference storageReference = FirebaseStorage.instance.ref().child("consultVideos/");

    try {
      await storageReference.delete();
      print("Old video deleted");
    } catch (e) {
      print("Error deleting old video: $e");
    }
  }
  @override
  void dispose() {

    //videoPlayerController.dispose();

    super.dispose();
  }



}
