
import 'package:flutter/material.dart';
import 'package:jeras/widget/responsive.dart';
import 'package:webview_flutter/webview_flutter.dart';

import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';

class PrivecyScreen extends StatefulWidget {

  @override
  _PrivecyScreenState createState() => _PrivecyScreenState();
}

class _PrivecyScreenState extends State<PrivecyScreen>with SingleTickerProviderStateMixin {
  bool isLoading=true;
  final _key = UniqueKey();
  // WebViewController controller = WebViewController();

  @override
  void initState() {
    //if (Platform.isAndroid) WebView.platform = SurfaceAndroidWebView();
    super.initState();
//     controller..setJavaScriptMode(JavaScriptMode.unrestricted)
//     ..setBackgroundColor(const Color(0x00000000))
//     ..setNavigationDelegate(
//     NavigationDelegate(
//     onProgress: (int progress) {
//     // Update loading bar.
//     },
//     onPageStarted: (String url) {},
// onPageFinished: (finish) {
//         setState(() {
//           isLoading = false;
//         });},
//       onWebResourceError: (WebResourceError error) {},
//     onNavigationRequest: (NavigationRequest request) {
//     // if (request.url.startsWith('https://www.youtube.com/')) {
//     // return NavigationDecision.prevent;
//     // }
//     // return NavigationDecision.navigate;
//
//       return NavigationDecision.navigate;
//     },
//     ),
//     )
//     ..loadRequest(Uri.parse(getTranslated(context, 'lang')=="ar"?"https://www.jeras.io/privacypolicy/?lang=ar":"https://www.jeras.io/privacypolicy/"));
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: Column(
        children: <Widget>[
          Container(
            width: size.width,
            height:100,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.only(
                bottomLeft: Radius.circular(0.0),
                bottomRight: Radius.circular(0.0),
              ),
            ),
            child: SafeArea(
              bottom: false,
              child: Padding(
                padding: const EdgeInsets.only(
                    left: AppPadding.p16, right: AppPadding.p16, top: 0.0, bottom: AppPadding.p16),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ClipRRect(
                      borderRadius: BorderRadius.circular(AppRadius.r50),
                      child: Material(
                        color: Colors.transparent,
                        child: InkWell(
                          splashColor: Colors.white.withOpacity(0.6),
                          onTap: () {
                            Navigator.pop(context);
                          },
                          child: Container(
                            decoration: BoxDecoration(
                              color: Colors.transparent,
                            ),
                            width: AppSize.w38.w,
                            height: AppSize.h35.h,
                            child: Icon(
                              Icons.arrow_back,
                              color:Colors.white,
                              size: AppSize.w24,
                            ),
                          ),
                        ),
                      ),
                    ),
                    SizedBox(
                      width: AppSize.w20,
                    ),
                    Expanded(
                      child: Text(
                        getTranslated(context, "policy"),
                        overflow: TextOverflow.ellipsis,
                        softWrap: true,
                        maxLines: 3,
                        style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                          color:Colors.white,
                          fontSize: AppFontsSizeManager.s20,
                          fontWeight: AppFontsWeightManager.semiBold,
                          letterSpacing: AppConstants.letterSpacing0_3,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Expanded(
            child: Stack(
              children: <Widget>[
                WebView(
                  key: _key,
                  initialUrl: getTranslated(context, 'lang')=="ar"?"https://www.jeras.io/privacypolicy/?lang=ar":"https://www.jeras.io/privacypolicy/",
                  javascriptMode: JavascriptMode.unrestricted,
                  gestureNavigationEnabled: true,
                  initialMediaPlaybackPolicy: AutoMediaPlaybackPolicy.always_allow,
                  onPageFinished: (finish) {
                    setState(() {
                      isLoading = false;
                    });
                  },
                ),
                isLoading ? Center( child: CircularProgressIndicator(),)
                    : Stack(),
              ],
            ),
          ),
        ],
      ),
    );
  }
  ////=======================
 /* static final String tokenizationKey = 'sandbox_nd8wjs74_wvd373kdkt2j5755';

  void showNonce(BraintreePaymentMethodNonce nonce) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('Payment method nonce:'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: <Widget>[
            Text('Nonce: ${nonce.nonce}'),
            SizedBox(height: 16),
            Text('Type label: ${nonce.typeLabel}'),
            SizedBox(height: 16),
            Text('Description: ${nonce.description}'),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Braintree example app'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            ElevatedButton(
              onPressed: () async {
                var request = BraintreeDropInRequest(
                  tokenizationKey: tokenizationKey,
                  collectDeviceData: true,
                 *//* googlePaymentRequest: BraintreeGooglePaymentRequest(
                    totalPrice: '4.20',
                    currencyCode: 'USD',
                    billingAddressRequired: false,
                  ),*//*
                  paypalRequest: BraintreePayPalRequest(
                    amount: '150.00',
                    displayName: 'Example company',
                  ),
                  cardEnabled: false,
                );
                final result = await BraintreeDropIn.start(request);
                if (result != null) {
                  String url='https://us-central1-influence2win-811cf.cloudfunctions.net/braintreePaypal';
                 // showNonce(result.paymentMethodNonce);
                  final http.Response response=await http.post(Uri.tryParse('$url?payment_method_nonce=${result.paymentMethodNonce.nonce}&device_data=${result.deviceData}'));
                  final paypalResult=jsonDecode(response.body);
                  if(paypalResult['result']=='success')
                  else
                    {
                    }

                }
              },
              child: Text('LAUNCH NATIVE DROP-IN'),
            ),
            ElevatedButton(
              onPressed: () async {
                final request = BraintreeCreditCardRequest(
                  cardNumber: '4111111111111111',
                  expirationMonth: '12',
                  expirationYear: '2021',
                  cvv: '123',
                );
                final result = await Braintree.tokenizeCreditCard(
                  tokenizationKey,
                  request,
                );
                if (result != null) {
                  showNonce(result);
                }
              },
              child: Text('TOKENIZE CREDIT CARD'),
            ),
            ElevatedButton(
              onPressed: () async {
                final request = BraintreePayPalRequest(
                  billingAgreementDescription:
                  'I hereby agree that flutter_braintree is great.',
                  displayName: 'Your Company',
                );
                final result = await Braintree.requestPaypalNonce(
                  tokenizationKey,
                  request,
                );
                if (result != null) {
                  showNonce(result);
                }
              },
              child: Text('PAYPAL VAULT FLOW'),
            ),
            ElevatedButton(
              onPressed: () async {
                final request = BraintreePayPalRequest(amount: '13.37');
                final result = await Braintree.requestPaypalNonce(
                  tokenizationKey,
                  request,
                );
                if (result != null) {
                  showNonce(result);
                }
              },
              child: Text('PAYPAL CHECKOUT FLOW'),
            ),
          ],
        ),
      ),
    );
  }*/
}
