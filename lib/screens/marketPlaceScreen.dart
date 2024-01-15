
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:jeras/config/app_values.dart';
import 'package:linkwell/linkwell.dart';
import 'package:url_launcher/url_launcher.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../widget/custom_back_button.dart';

class MarketplaceScreen extends StatefulWidget {
  final String link;

  const MarketplaceScreen({Key? key, required  this.link}) : super(key: key);
  @override
  _MarketplaceScreenState createState() => _MarketplaceScreenState();
}

class _MarketplaceScreenState extends State<MarketplaceScreen>with SingleTickerProviderStateMixin {
  // bool isLoading=true;
  // String theme="light";
  // final _key = UniqueKey();

  @override
  void initState() {

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
              child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: AppPadding.p10, right: AppPadding.p10, top: 0.0, bottom: AppPadding.p6),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        CustomBackButton(),
                        const SizedBox(width: AppSize.w10),
                       /* Center(
                          child: Text(
                            getTranslated(context, "notification"),
                            textAlign: TextAlign.center,
                            style: TextStyle(
                                fontFamily: getTranslated(context, "Ithra"),
                                fontSize: AppFontsSizeManager.s16,
                                color: Colors.black.withOpacity(0.8),
                                fontWeight: FontWeight.bold),
                          ),
                        ),*/
                      ],
                    ),
                  ))),
          Center(
              child: Container(
                  color: AppColors.lightGrey,
                  height: AppSize.h2,
                  width: size.width * AppSize.w0_9)),


          Center(
            child: Column(
              mainAxisAlignment:MainAxisAlignment.center,
              crossAxisAlignment:CrossAxisAlignment.center,children: [
              SizedBox(height: 50,),

              Center(
                child: Text(
                  getTranslated(context, "marketplace"),
                  textAlign: TextAlign.center,
                  overflow: TextOverflow.ellipsis,
                  softWrap: true,
                  maxLines: 3,
                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                    color:AppColors.black,
                    fontSize: AppFontsSizeManager.s15,
                    fontWeight: FontWeight.normal,
                    letterSpacing: AppConstants.letterSpacing0_3,
                  ),
                ),
              ),
              SizedBox(height: AppSize.h10,),
             //pressHere
              Center(
                child: InkWell(onTap: (){
                  launchURL(widget.link);
                },
                  child: LinkWell(
                    getTranslated(context, "pressHere"),
                    textAlign: TextAlign.center,
                    overflow: TextOverflow.ellipsis,
                    softWrap: true,
                    maxLines: 5,
                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                      color: Theme.of(context).primaryColor,
                      fontSize: AppFontsSizeManager.s15,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                    linkStyle: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.blue,
                      fontSize: AppFontsSizeManager.s15,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),),
                ),
              ),

              SizedBox(height: AppSize.h10,),

            ],),
          )
        ],
      ),
    );
  }
  launchURL(String url) async {
    Uri _url = Uri.parse(url);
    if (await canLaunchUrl(_url)) {
      await launchUrl(_url);
    } else {
      Fluttertoast.showToast(
          msg: getTranslated(context, "error"),
          toastLength: Toast.LENGTH_SHORT,
          gravity: ToastGravity.BOTTOM,
          backgroundColor:AppColors.red ,
          textColor: AppColors.white,
          fontSize: AppFontsSizeManager.s16);

      throw 'Could not launch $url';
    }

  }
}
