import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/localization/localization_methods.dart';

import '../../config/colors_file.dart';
import '../../models/user.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/paths.dart';
import '../screens/YoutubePlayerDemoScreen.dart';

class PlatListWidget extends StatefulWidget {
  final String consultantUid;

  PlatListWidget({required this.consultantUid});

  @override
  _PlatListWidgetState createState() => _PlatListWidgetState();
}

class _PlatListWidgetState extends State<PlatListWidget>
    with SingleTickerProviderStateMixin {
  List<Video> list = [];

  @override
  void initState() {
    super.initState();
    getVideosList();
  }

  @override
  Widget build(BuildContext context) {
    return list.length == 0
        ? SizedBox()
        : Container(
            height: kIsWeb || (MediaQuery.of(context).size.width >= 500)
                ? AppSize.h240
                : AppSize.h200,
            margin: EdgeInsets.symmetric(horizontal: AppMargin.m14),
            child: ListView.builder(
                itemCount: list.length,
                shrinkWrap: true,
                scrollDirection: Axis.horizontal,
                itemBuilder: (context, index) => Container(
                      width:
                          kIsWeb || (MediaQuery.of(context).size.width >= 500)
                              ? AppSize.w240
                              : AppSize.w200,
                      margin: EdgeInsets.all(8),
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.start,
                        children: [
                          Container(
                            height: AppSize.h150,
                            child: Stack(children: <Widget>[
                              Container(
                                  height: AppSize.h150,
                                  width: AppSize.w200,
                                  child: ClipRRect(
                                    borderRadius: const BorderRadius.all(
                                        Radius.circular(AppRadius.r25)),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: AssetsManager.lodeGif,
                                      placeholderScale: 0.5,
                                      imageErrorBuilder: (context, error,
                                              stackTrace) =>
                                          Center(
                                              child: Image.asset(
                                                  AssetsManager.whiteJerasLogoIconPath,
                                                  width: AppSize.w70,
                                                  height: AppSize.h70,
                                                  fit: BoxFit.fill)),
                                      image: "https://img.youtube.com/vi/" +
                                          list[index]
                                              .link!
                                              .replaceAll(
                                                  "https://www.youtube.com/watch?v=",
                                                  "")
                                              .trim()
                                              .replaceAll(
                                                  "https://www.youtube.com/shorts/",
                                                  "")
                                              .trim() +
                                          "/hqdefault.jpg",
                                      fit: BoxFit.fill,
                                      fadeInDuration: Duration(
                                          milliseconds:
                                              AppConstants.milliseconds250),
                                      fadeInCurve: Curves.easeInOut,
                                      fadeOutDuration: Duration(
                                          milliseconds:
                                              AppConstants.milliseconds150),
                                      fadeOutCurve: Curves.easeInOut,
                                    ),
                                  )),
                              InkWell(
                                onTap: () async {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            YoutubePlayerDemoScreen(
                                                link: list[index].link != null
                                                    ? list[index].link!
                                                    : '',
                                                desc: list[index].desc != null
                                                    ? list[index].desc!
                                                    : '')),
                                  );
                                },
                                child: Container(
                                  height: AppSize.h150, //width: size.width*.40,
                                  padding: EdgeInsets.only(
                                      left: AppPadding.p10,
                                      right: AppPadding.p10),
                                  decoration: BoxDecoration(
                                    color: Colors.transparent,
                                    borderRadius: BorderRadius.circular(AppRadius.r8),
                                  ),
                                  child: Center(
                                      child: Icon(
                                    Icons.play_circle_outline,
                                    color: AppColors.white,
                                    size: AppSize.w50,
                                  )),
                                ),
                              ),
                            ]),
                          ),
                          SizedBox(
                            height: AppSize.h5,
                          ),
                          list[index].desc != null
                              ? Text(
                                  list[index].desc!,
                                  textAlign: TextAlign.center,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 1,
                                  style: TextStyle(
                                      fontFamily:
                                          getTranslated(context, "Ithra"),
                                      fontSize: kIsWeb ||
                                              (MediaQuery.of(context)
                                                      .size
                                                      .width >=
                                                  500)
                                          ? 22
                                          : 11.0,
                                      color: AppColors.grey),
                                )
                              : SizedBox(),
                        ],
                      ),
                    )));
  }

  Future<void> getVideosList() async {
    try {
      List<Video> _list = [];
      await FirebaseFirestore.instance
          .collection(Paths.videoPath)
          .where(
            'consultUid',
            isEqualTo: widget.consultantUid,
          )
          .get()
          .then((value) async {
        if (value.docs.length > 0) {
          for (var doc in value.docs) {
            _list.add(Video.fromMap(doc.data()));
          }
          setState(() {
            list = _list;
          });
        } else {
          setState(() {
            list = [];
          });
        }
      }).catchError((err) {});
    } catch (e) {}
  }
}
