

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../../widget/youtubePlayerWidget.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../screens/videoDetailsScreen.dart';

class VideoDialog extends StatefulWidget {
  final String consultUid;
  VideoDialog({required this.consultUid});

  @override
  _VideoDialogState createState() => _VideoDialogState();
}

class _VideoDialogState extends State<VideoDialog> {
  bool load=true;
  List<Video>list=[];
  @override
  void initState() {
    getVideosList();
    super.initState();
  }
  Future<void> getVideosList() async {
    try{
      List<Video> _list=[];
      await FirebaseFirestore.instance
          .collection(Paths.videoPath)
          .where( 'consultUid', isEqualTo: widget.consultUid,)
          .get().then((value) async {
        if(value.docs.length>0) {
          for (var doc in value.docs) {
            _list.add(Video.fromMap(doc.data()));
          }
          setState(() {
            list=_list;
            load=false;
          });
        }
        else {
          setState(() {
            list=[];
            load=false;
          });
        }

      }).catchError((err) {

      });

    }catch(e) {
    }

  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(15.0),
        ),
      ),
      elevation: 5.0,
      contentPadding: EdgeInsets.symmetric(horizontal: 5.0, vertical: 5.0),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[

            Padding(
              padding: const EdgeInsets.all(10.0),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  InkWell(onTap: (){
                    Navigator.pop(context);
                    Video video=new Video();
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => VideoDetailsScreen(video: video,consultUid: widget.consultUid,), ),);
                  }, child: Icon( Icons.add_circle_outline,color:AppColors.green,size: 20.0, )),
                  Text(
                    getTranslated(context,'addMore'),
                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                       color: AppColors.black87,
                      fontSize: AppFontsSizeManager.s15,
                      fontWeight: AppFontsWeightManager.semiBold,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                  InkWell(onTap: (){
                    Navigator.pop(context);
                  }, child: Icon( Icons.cancel_outlined,color:AppColors.red,size: 20.0, )),

                ],
              ),
            ),
            load?CircularProgressIndicator():ListView.separated(

                shrinkWrap: true,
                physics: ScrollPhysics(),
                separatorBuilder: (BuildContext context, int index) {
                  return Container(height: 1,width: size.width*.6,color: AppColors.lightGrey,);
                },
                itemCount: list.length,
                itemBuilder: (context, index) {
                  String link=list[index].link!;
                  if(list[index].link!.contains("https://www.youtube.com/watch?v="))
                    link=link.replaceAll("https://www.youtube.com/watch?v=","");
                  if(list[index].link!.contains("https://www.youtube.com/shorts/"))
                    link=link.replaceAll("https://www.youtube.com/shorts/","");
                  return YouTubeVideoRow(
                    video:list[index],
                    allowEdit:true,
                    consultUid: widget.consultUid, );
                }
            ),
            Center(
              child: SizedBox(
                width: size.width * 0.5,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r10),
                  ),
                  child: Text(
                    getTranslated(context,'cancel'),
                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.red,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

}
