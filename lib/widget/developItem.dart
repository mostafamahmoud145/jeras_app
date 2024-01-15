
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../models/developMessage.dart';
import '../../models/user.dart';
import '../../widget/playrecordWidget.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/assets_manager.dart';

class DevelopItem extends StatelessWidget {

  final DevelopMessage message;
  final GroceryUser user;
  const DevelopItem({
    required this.message,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return  Column(
      children: [
        Container(
          padding: EdgeInsets.only(left: AppPadding.p14,right: AppPadding.p14,top: AppPadding.p10,bottom: AppPadding.p10),
          child: Align(
            alignment: (message.owner!= "SUPPORT"?Alignment.topLeft:Alignment.topRight),
            child:  message.type=="image"?
            chatImage(context,message.message,message.owner):
            message.type=="voice"?
            PlayRecordWidget(url:message.message,owner: message.owner, ):
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.r20),
                color: (message.owner!= "SUPPORT"?Colors.grey.shade200:Colors.purple[50]),
              ),
              padding: EdgeInsets.all(16),
              child: Column( mainAxisAlignment:MainAxisAlignment.start,crossAxisAlignment:CrossAxisAlignment.start,children: [
                LinkWell(
                  message.message,
                  linkStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                    color: Colors.blue,
                    fontSize: AppFontsSizeManager.s15,
                  ),
                  textAlign:TextAlign.start ,
                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                    color: Colors.black,
                    fontSize: AppFontsSizeManager.s15,
                  ),),
                message.ownerName!=null?Text(
                  message.ownerName,
                  textAlign:TextAlign.end ,
                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                    fontSize: 11.0,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ):SizedBox(),
                message.messageTimeUtc!=null?Text(
                  //DateTime.parse(message.messageTimeUtc).toLocal().toString(),
                  '${new DateFormat('dd MMM yyyy, hh:mm a').format( DateTime.parse(message.messageTimeUtc).toLocal())}',
                  textAlign:TextAlign.end ,
                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s11,
                    color: Colors.black.withOpacity(0.6),
                  ),
                ):SizedBox(),
              ],),
            ),
          ),
        ),
        SizedBox(height: AppSize.h5,),

      ],
    );
  }
  launchURL(String url) async {
    if (!url.contains('http')) url = 'https://$url';
    if (await canLaunch(url)) {
      await launch(url);
    } else {
      // showSnakbar('Could not launch $url', false);

      throw 'Could not launch $url';
    }

  }
  static Widget chatImage(BuildContext context, String chatContent,String type) {
    return Container(
        padding: EdgeInsets.only(left: AppPadding.p14,right: AppPadding.p14,top: AppPadding.p10,bottom: AppPadding.p10),
        child: Align(
          alignment: (type!= "SUPPORT"?Alignment.topLeft:Alignment.topRight),
          child: Container(
            child: ElevatedButton(
                child: Material(
                  child: kIsWeb
                      ? widgetShowImages(chatContent, 250)
                      : widgetShowImages(chatContent, 150),//100
                  borderRadius: BorderRadius.all(Radius.circular(5.0)),
                  //clipBehavior: Clip.hardEdge,
                ),
                onPressed: ()  async {
                  // launchURL(chatContent);
                  var url=chatContent;
                  if (!url.contains('http')) {
                    url = 'https://$url';
                  }
                  await launch(url);
                },
                style: ElevatedButton.styleFrom(padding: EdgeInsets.all(0.0))),
            margin: type=="SUPPORT"
                ? EdgeInsets.only(
                bottom:  AppMargin.m10,
                right: AppMargin.m10)
                : EdgeInsets.only(left: AppMargin.m10),
          ),)
    );
  }

  // Show Images from network
  static Widget widgetShowImages(String imageUrl, double imageSize) {
    return  FadeInImage.assetNetwork(
      placeholder:AssetsManager.lodeGif,
      placeholderScale: 0.5,
      imageErrorBuilder: (context, error, stackTrace) => Icon(
        Icons.image_not_supported,
        size: AppSize.w50,
      ),
      height: imageSize,
      width: imageSize,
      image: imageUrl,
      fit: BoxFit.cover,
      fadeInDuration: Duration(milliseconds: AppConstants.milliseconds250),
      fadeInCurve: Curves.easeInOut,
      fadeOutDuration: Duration(milliseconds: AppConstants.milliseconds150),
      fadeOutCurve: Curves.easeInOut,
    );

  }
}
