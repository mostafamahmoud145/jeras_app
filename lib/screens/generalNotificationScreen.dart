
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:linkwell/linkwell.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';

class GeneralNotificationScreen extends StatefulWidget {
final String title;
final String body;
final String? image;
final String? link;

  const GeneralNotificationScreen({Key? key, required this.title, required this.body, this.image, this.link}) : super(key: key);
  @override
  _GeneralNotificationScreenState createState() => _GeneralNotificationScreenState();
}

class _GeneralNotificationScreenState extends State<GeneralNotificationScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true;
  String theme="light";

  @override
  void initState() {
    setState(() {
      this.theme = theme;
    });
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,


              // height: 80,
              // color: Colors.white,
              child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: AppPadding.p10, right: AppPadding.p10, top: 0.0, bottom:AppPadding.p6),
                    child: Row(
                     // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Container(
                          height: AppSize.h35.r,
                          width: AppSize.w35.r,
                          child: Center(
                            child: IconButton(
                              onPressed: () {
                                Navigator.pop(context);
                              },
                              icon: SvgPicture.asset(
                                AssetsManager.rightArrowIconPath,
                                width: AppSize.w30.r,
                                height: AppSize.h30.r,
                              ),
                            ),
                          ),
                        ),
                        Center(
                          child: Text(
                            getTranslated(context, "notification"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize:AppFontsSizeManager.s16.sp,
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.bold),
                          ),
                        ),
                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h2.h,
                  width: size.width * AppSize.w0_9.w)),


          Column(children: [
            SizedBox(height: AppSize.h20.h,),
            ( widget.image!=null&&widget.image!="noImage"&&widget.image!.isEmpty==false)? Center(
              child: Container(
                height: size.height*AppSize.h0_25.h,
                width: size.width*AppSize.w0_9.w,
                decoration: BoxDecoration(
                 // border: Border.all(color: Colors.grey[200],width: 1),
                  shape: BoxShape.rectangle,
                 // color: Colors.white,
                ),
                child: widget.image!.isEmpty ?
                Center(child: Icon( Icons.image,color:Colors.grey,size: AppSize.w50, ))
                    :ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r10.r),
                      child: FadeInImage.assetNetwork(
                      placeholder:
                      AssetsManager.lodeGif,
                      placeholderScale: 0.5,
                      imageErrorBuilder:(context, error, stackTrace) => Icon(
                        Icons.image,color:Colors.grey,size: AppSize.w50,
                      ),
                      image: widget.image!,
                      fit: BoxFit.cover,
                      fadeInDuration:
                      Duration(milliseconds: AppConstants.milliseconds250),
                      fadeInCurve: Curves.easeInOut,
                      fadeOutDuration:
                      Duration(milliseconds: AppConstants.milliseconds150),
                      fadeOutCurve: Curves.easeInOut,
                    ),
                  ),
              ),
            ):SizedBox(),
            (widget.image!=null&&widget.image!="noImage"&&widget.image!.isEmpty==false)?SizedBox(height: 20.h,):SizedBox(),
            Center(
              child: Text(
                widget.title,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 3,
                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                  color: Theme.of(context).primaryColor,
                  fontSize: AppFontsSizeManager.s15.sp,
                  fontWeight: FontWeight.normal,
                  letterSpacing: AppConstants.letterSpacing0_3,
                ),
              ),
            ),
            SizedBox(height: AppSize.h10.h,),
            Center(
              child: LinkWell(
                widget.body,
                textAlign: TextAlign.center,
                overflow: TextOverflow.ellipsis,
                softWrap: true,
                maxLines: 5,
                style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                  color: Theme.of(context).primaryColor,
                  fontSize: AppFontsSizeManager.s15.sp,
                  fontWeight: FontWeight.normal,
                  letterSpacing: AppConstants.letterSpacing0_3,
                ),
                linkStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                  color: AppColors.blue,
                  fontSize: AppFontsSizeManager.s15.sp,
                  fontWeight: FontWeight.normal,
                  letterSpacing: AppConstants.letterSpacing0_3,
                ),),
            ),

            SizedBox(height: AppSize.h10.h,),

          ],)
        ],
      ),
    );
  }
}
