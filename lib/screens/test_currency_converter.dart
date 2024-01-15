import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:http/http.dart'as http;
import 'package:jeras/widget/component/TextButton.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:share_plus/share_plus.dart';
import 'package:smooth_star_rating_null_safety/smooth_star_rating_null_safety.dart';

import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
import '../api/dynamicLink.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../screens/ConsultantDetailsScreen.dart';

class TestCurrencyConverter extends StatefulWidget {
  final GroceryUser? loggedUser;
  final GroceryUser consult;
  String lang;
  final String theme;
  TestCurrencyConverter(
      {required this.consult,
        this.loggedUser,
        required this.theme,
        required this.lang});
  @override
  _TestCurrencyConverterState createState() => _TestCurrencyConverterState();
}

class _TestCurrencyConverterState extends State<TestCurrencyConverter>

    with SingleTickerProviderStateMixin {
  share() async {
    try {
      setState(() {
        sharing = true;
      });


      String userUrl = "https://jerasnew.web.app/conslultant?consultant_id=${widget.consult.uid}";

      String url = await dynamicLinks.shareConsultantByDynamicLink(userUrl, context, widget.consult);
      Share.share(url); //${dynamicLink.shortUrl.toString()}
      setState(() {
        sharing = false;
      });
    } catch (e) {

    }
  }
  http.Response? response;
  bool convert = true;
  var result ;
  String apiKey = 'ip00fapY3lANVC3X354zL0RFNPtzagl2';
  testConvertMoney()async {
    response = await http.get(
        Uri.parse(
            'https://api.apilayer.com/exchangerates_data/convert?to=EGP&from=USD&amount=${widget
                .consult.price!}'),
        headers: {
          "apikey": apiKey
        }
    );
    try {
      if (response!.statusCode == 200) {
       result = jsonDecode(response!.body);
        setState(() {
          convert = false;
        });
        print(result['result']);
      }
      }catch(e){
        print('the error is >>>>> $e');
    }
  }
  bool sharing = false;
  @override
  Widget build(BuildContext context) {

    Size size=MediaQuery.of(context).size;
    bool avaliable = false;
    DateTime _now = DateTime.now();
    String dayNow = _now.weekday.toString();
    int timeNow = _now.hour;



    if (widget.consult.workDays!.contains(dayNow)) {
      int localFrom = DateTime.parse(widget.consult.fromUtc!).toLocal().hour;
      int localTo = DateTime.parse(widget.consult.toUtc!).toLocal().hour;
      if (localTo == 0) localTo = 24;
      if (localFrom <= timeNow && localTo > timeNow) {
        avaliable = true;
      }
    }

    return Scaffold(
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(
            convert? widget.consult.price! + "\$" :result.toString(),
            textAlign: TextAlign.center,
            overflow: TextOverflow.ellipsis,
            maxLines:1,
            style: TextStyle(
              fontFamily: getTranslated(context, "Ithra"),
              fontSize: (kIsWeb||size.width >= 500)
                  ?18.sp:14.5.sp,
              fontWeight: FontWeight.bold,
              color: AppColors.shadoColor,
            ),
          ),
          GestureDetector(
              onTap: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    settings: RouteSettings(
                        name: 'conslultant?consultant_id=${widget.consult.uid}',
                        arguments: {"consultant_id": widget.consult.uid}),
                    builder: (context) => ConsultantDetailsScreen(  consoltantId: '${widget.consult.uid}',),
                  ),
                );
              },
              child: Container(
                width:(kIsWeb||size.width >= 500)?300.w:216.w,
                height:(kIsWeb||size.width >= 500)?346.w:300.w,
                decoration: BoxDecoration(
                  color: Color.fromRGBO(247, 247, 247,1),
                  borderRadius: BorderRadius.circular((kIsWeb||size.width >= 500)?50.r:36.r),
                ),
                child: Padding(
                  padding: EdgeInsets.all(15.r),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    crossAxisAlignment: CrossAxisAlignment.center,
                    children: [
                      //dollar sign
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [

                          Stack(
                            alignment: Alignment.center,
                            children: [
                              //image
                              Container(
                                height: (kIsWeb||size.width >= 500)
                                    ?58.h:58.h,
                                width: (kIsWeb||size.width >= 500)
                                    ?58.w:58.w,
                                decoration: BoxDecoration(
                                  border:
                                  Border.all(color: AppColors.white, width: 1.w),
                                  boxShadow: [
                                    BoxShadow(
                                        color: const Color(0x33ae9cce),
                                        offset: Offset(0, 6),
                                        blurRadius: 12,
                                        spreadRadius: 0)
                                  ],
                                  shape: BoxShape.circle,
                                  color: AppColors.white,
                                ),
                                child: Container(
                                  height: (kIsWeb||size.width >= 500)
                                      ?80.h:57.h,
                                  width: (kIsWeb||size.width >= 500)
                                      ?80.w:57.w,
                                  decoration: BoxDecoration(
                                    border:
                                    Border.all(color: AppColors.white, width: 3.w),
                                    shape: BoxShape.circle,
                                    color: AppColors.white,
                                  ),
                                  child: widget.consult.photoUrl!.isEmpty
                                      ? CircleAvatar(
                                    backgroundImage: AssetImage(AssetsManager.whiteJerasLogoIconPath,),
                                  )
                                      : ClipRRect(
                                    borderRadius: BorderRadius.circular(150.0.r),
                                    child: FadeInImage.assetNetwork(
                                      placeholder: AssetsManager.lodeGif,
                                      placeholderScale: 0.5,
                                      imageErrorBuilder: (context, error,
                                          stackTrace) =>
                                          Image.asset(
                                              AssetsManager.whiteJerasLogoIconPath,
                                              width: (kIsWeb||size.width >= 500)?97.r:75.r,
                                              fit: BoxFit.fill),
                                      image: widget.consult.photoUrl!,
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
                              ),
                              //avail icon
                              Positioned(
                                top: 10,
                                left: 1,
                                child: Container(
                                  width: AppSize.w10.w,
                                  height: AppSize.h10.h,
                                  decoration: BoxDecoration(
                                    color:
                                    avaliable ? Color(0xffa5d752) : AppColors.red,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      width: 1.w,
                                      color: Colors.white,
                                    ),
                                  ),
                                ),
                              ),

                            ],
                          ),
                          Expanded(
                            child: Column(
                              mainAxisAlignment: MainAxisAlignment.start,
                              children: [
                                //old
                                /* SizedBox(height: 5),*/
                                //new
                                SizedBox(height: 5.h),
                                Column(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    sharing
                                        ? Container(
                                        height: 20.h,
                                        width: 20.w,
                                        child: CircularProgressIndicator())
                                        : InkWell(
                                      onTap: () async {
                                        share();
                                      },
                                      child: Column(
                                        children: [

                                          //new
                                          Container(
                                            height: (kIsWeb||size.width >= 500)
                                                ?32.h:22.r,
                                            width: (kIsWeb||size.width >= 500)
                                                ?32.w:22.r,
                                            decoration: BoxDecoration(
                                              color: Color.fromRGBO(255 ,255 ,255, 1),
                                              borderRadius: BorderRadius.circular((kIsWeb||size.width >= 500)?25.r:10.0.r),

                                            ),

                                            child: Center(
                                              child: Image.asset(
                                                'assets/applicationIcons/share-icon.png',
                                                width: (kIsWeb||size.width >= 500)
                                                    ?16:15.w,
                                                height: (kIsWeb||size.width >= 500)
                                                    ?16:12.h,
                                              ),
                                            ),
                                          ),

                                          //new
                                          (widget.consult.consultType == "perfect" &&
                                              widget.consult.isGlorified!)
                                              ? Container(
                                              height: 21.h,
                                              margin: EdgeInsets.only(top: 5),
                                              width: 21.w,
                                              // decoration: BoxDecoration(
                                              //   color: AppColors.yellow,
                                              //   borderRadius: BorderRadius.circular(3.0),
                                              // ),
                                              child: Image.asset(
                                                  'assets/applicationIcons/mojeez-icon.png'))
                                              : SizedBox(),
                                        ],
                                      ),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),

                      //name
                      Text(
                        getTranslated(context, "lang")=="ar"?widget.consult.name!:widget.consult.nameEn!,
                        maxLines: 1,
                        textAlign:TextAlign.center,
                        overflow: TextOverflow.ellipsis,
                        style:  TextStyle(
                          color: const Color(0xff202020),
                          fontWeight: AppFontsWeightManager.semiBold,
                          fontFamily:(kIsWeb||size.width >= 500)
                              ?"Montserrat":getTranslated(context, "Ithra"),
                          fontStyle: FontStyle.normal,
                          fontSize: (kIsWeb||size.width >= 500)
                              ?19.sp:12.sp,
                        ),
                      ),
                      //call number data
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [

                          Image.asset(
                            'assets/applicationIcons/greenCall2.png',
                            width: 14.w,
                            height: 14.w,
                          ),

                          SizedBox(width: 1.w),

                          //new
                          Text(
                            widget.consult.ordersNumbers == null
                                ? '0'
                                : widget.consult.ordersNumbers! < 100
                                ? widget.consult.ordersNumbers.toString()
                                : widget.consult.ordersNumbers! < 1000
                                ? "+100"
                                : "+1000",
                            textAlign: TextAlign.center,
                            overflow: TextOverflow.ellipsis,
                            softWrap: false,
                            maxLines: 1,
                            style: TextStyle(
                              color: AppColors.black2,
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily: "Montserrat",
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb||size.width >= 500)
                                  ?14.sp:12.sp,
                            ),
                          ),
                          //old
                          /* SizedBox(width: AppSize.w10.w),*/
                          //new
                          SizedBox(width: AppSize.w10.w),
                          //star change .f
                          SmoothStarRating(
                            allowHalfRating: true,
                            starCount: 1,
                            rating: 1,
                            size: 15.0.r,
                            color: AppColors.yellow,
                            borderColor: AppColors.yellow,
                            spacing: 1.0,
                          ),

                          //new
                          Text(
                            widget.consult.rating == 0
                                ? 0.toString()
                                : widget.consult.rating.toString(),
                            style:  TextStyle(
                              color: AppColors.black2,
                              fontWeight: AppFontsWeightManager.bold500,
                              fontFamily: "Montserrat",
                              fontStyle: FontStyle.normal,
                              fontSize: (kIsWeb||size.width >= 500)
                                  ?14.sp:12.sp,
                            ),
                          ),

                        ],
                      ),
                      //old
                      //new
                      SizedBox(height: 5.h),
                      Icon(
                        Icons.location_on_outlined,
                        color: AppColors.pink,
                        size: (kIsWeb||size.width >= 500)
                            ?13:12.0,
                      ),
                      //old
                      Flexible(
                        child: Text(
                          getTranslated(context, "lang")=="ar"?widget.consult.location!:widget.consult.locationEn!,
                          textAlign: TextAlign.center,
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: TextStyle(
                            fontFamily:(kIsWeb||size.width >= 500)
                                ?"Montserrat":getTranslated(context, "Ithra"),
                            color: AppColors.grey,
                            fontSize: (kIsWeb||size.width >= 500)
                                ?14.sp:12.0.sp,
                            fontWeight: AppFontsWeightManager.semiBold,
                          ),
                        ),
                      ),

                      Flexible(

                        child: TextButton1(onPress: (){},Title: "عرض الملف الشخصي", Width: 148.w, Height: 36.h, ButtonRadius: 5.r, TextSize: 8.sp, TextFont: getTranslated(context, 'fontFamily'), TextColor: Color.fromRGBO(123 ,108 ,150, 1),ButtonBackground: Color.fromRGBO(123, 108, 150, 0.1),Padding:4.h),

                      ),
                    ],
                  ),
                ),
              )
          ),
          Center(child: TextButton(
            onPressed: ()async{
              await testConvertMoney();
               setState(() {
                 convert = false;
               });
            },
            child: Text('Convert',

            ),
          ),
          ),
        ],
      ),
    );
  }
}
