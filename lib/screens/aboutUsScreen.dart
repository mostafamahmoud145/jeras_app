import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/divider_widget.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:jeras/widget/custom_back_button.dart';

import '../../localization/language_constants.dart';
import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_values.dart';
import '../config/assets_manager.dart';
import '../config/colors_file.dart';

class AboutUsScreen extends StatefulWidget {
  @override
  _AboutUsScreenState createState() => _AboutUsScreenState();
}

class _AboutUsScreenState extends State<AboutUsScreen>
    with SingleTickerProviderStateMixin {
  bool isLoading = true;
  final _key = UniqueKey();
  String theme = "light";
  String url = "https://www.jeras.io/?lang=ar", lang = "ar";

  // WebViewController controller = WebViewController();

  @override
  void initState() {
    super.initState();

    // controller..setJavaScriptMode(JavaScriptMode.unrestricted)
    //   ..setBackgroundColor(const Color(0x00000000))
    //   ..setNavigationDelegate(
    //     NavigationDelegate(
    //       onProgress: (int progress) {
    //         // Update loading bar.
    //       },
    //       onPageStarted: (String url) {},
    //       onPageFinished: (finish) {
    //         setState(() {
    //           isLoading = false;
    //         });},
    //       onWebResourceError: (WebResourceError error) {},
    //       onNavigationRequest: (NavigationRequest request) {
    //         // if (request.url.startsWith('https://www.youtube.com/')) {
    //         // return NavigationDecision.prevent;
    //         // }
    //         // return NavigationDecision.navigate;
    //
    //         return NavigationDecision.navigate;
    //       },
    //     ),
    //   )
    //   ..loadRequest(Uri.parse(getTranslated(context, "lang")=='ar'?url:'https://www.jeras.io/'));
  }

  @override
  void didChangeDependencies() {
    getThemeName().then((theme) {
      setState(() {
        this.theme = theme;
      });
    });
    super.didChangeDependencies();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");
    if (lang != "ar") url = "https://www.jeras.io/";
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                    padding: EdgeInsets.only(
                        left: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_06 : AppPadding.p20,
                        right:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_06 : AppPadding.p20,
                        top: AppPadding.p10,
                        bottom: AppPadding.p10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.start,
                      children: [
                        CustomBackButton(),
                      
                        SizedBox(width: AppSize.w10.w),
                        Text(
                          getTranslated(context, "aboutUs"),
                          style: TextStyle(
                            fontFamily: getTranslated(context, "Ithra"),
                            fontSize:
                            (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppFontsSizeManager.s34.sp : AppFontsSizeManager.s21_3.sp,
                            fontWeight: FontWeight.bold,
                            color: AppColors.black1,
                          ),
                        ),
                      ],
                    ),
                  ))),
          Center(
              child: DividerWidget(
            height: AppSize.h1.h,
            width: size.width.w,
          )),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebView(
                  key: _key,
                  initialUrl: url,
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy:
                      AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading
                    ? Center(
                        child: CircularProgressIndicator(),
                      )
                    : Stack(),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
