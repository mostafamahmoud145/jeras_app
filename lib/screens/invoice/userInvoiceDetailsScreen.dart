import 'dart:convert';

import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/app_fonts.dart';
import '../../config/colors_file.dart';
import '../../localization/localization_methods.dart';
import '../../models/InvoiceModel.dart';

class UserInvoiceItem extends StatefulWidget {
  Invoice invoice;

  UserInvoiceItem({required this.invoice});

  @override
  State<UserInvoiceItem> createState() => _UserInvoiceItemState();
}

class _UserInvoiceItemState extends State<UserInvoiceItem> {
  String status = " ";
  bool load = true;

  void initState() {
    checkStatus();
    super.initState();
  }

  checkStatus() async {
    try {
      final uri =
          Uri.parse('https://api.tap.company/v2/invoices/' + widget.invoice.id);
      final headers = {
        'Content-Type': 'application/json',
        'Accept': 'application/json',
        //'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
        'Authorization': "Bearer sk_live_C7V9cpBMFWbt2ukjd3fRxIeD",
        'Connection': 'keep-alive',
        'Accept-Encoding': 'gzip, deflate, br',
        "Access-Control-Allow-Origin": "*",
        'Content-Type': 'application/json',
        'Accept': '*/*'
      };
      var response = await get(
        uri,
        headers: headers,
      );
      String responseBody = response.body;
      var res = json.decode(responseBody);
      setState(() {
        status = res['status'];
        load = false;
      });
    } catch (e) {}
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    return Scaffold(
      body: SingleChildScrollView(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Container(
                width: size.width,
                child: SafeArea(
                  child: Padding(
                    padding: const EdgeInsets.only(
                        left: AppPadding.p20,
                        right: AppPadding.p20,
                        top: AppPadding.p10,
                        bottom: AppPadding.p10),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.start,
                          children: [
                            IconButton1(
                              onPress: Navigator.of(context).pop,
                              Width: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? AppSize.w97.w
                                  : AppSize.w50_6.w,
                              Height: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 97.0.h
                                  : 50.6.h,
                              ButtonRadius: (kIsWeb ||
                                      size.width >= AppConstants.kIsWebValue)
                                  ? 24.r
                                  : 10.6.r,
                              IconWidth: 32.w,
                              IconHeight: 32.h,
                              IconColor: Theme.of(context).primaryColor,
                              Icon:
                                  AssetsManager.blackArrowRightIconPath,
                              ButtonBackground: AppColors.white,
                            ),
                            const SizedBox(width: 10),
                            Text(
                              getTranslated(context, "invoices"),
                              textAlign: TextAlign.left,
                              style: TextStyle(
                                fontWeight: AppFontsWeightManager.bold300,
                                fontFamily: getTranslated(context, "Ithra"),
                                fontStyle: FontStyle.normal,
                                fontSize: (kIsWeb ||
                                        size.width >= AppConstants.kIsWebValue)
                                    ? AppFontsSizeManager.s31.sp
                                    : AppFontsSizeManager.s15.sp,
                                color: AppColors.black2,
                              ),
                            ),
                          ],
                        ),
                        IconButton(
                            onPressed: () {
                              Clipboard.setData(
                                  ClipboardData(text: widget.invoice.invoice));
                              Fluttertoast.showToast(
                                msg: getTranslated(context, "textCopy"),
                                toastLength: Toast.LENGTH_LONG,
                                gravity: ToastGravity.TOP,
                                timeInSecForIosWeb: 5,
                                backgroundColor: AppColors.green2,
                                textColor: AppColors.white,
                                fontSize: AppFontsSizeManager.s16,
                              );
                            },
                            icon: Icon(
                              Icons.copy,
                              color: Theme.of(context).primaryColor,
                            )),
                      ],
                    ),
                  ),
                )),
            SizedBox(height: AppSize.h40),
            Stack(
              alignment: Alignment.center,
              children: [
                Container(
                  height: AppSize.h81,
                  width: AppSize.w81,
                  decoration: BoxDecoration(
                    border: Border.all(color: AppColors.grey, width: AppSize.w1),
                    shape: BoxShape.circle,
                    color: AppColors.white,
                  ),
                  child: Container(
                    height: AppSize.h80,
                    width: AppSize.w80,
                    decoration: BoxDecoration(
                      border: Border.all(color: AppColors.white, width: AppSize.w5),
                      shape: BoxShape.circle,
                      color: AppColors.white,
                    ),
                    child: widget.invoice.user.image!.isEmpty
                        ? Image.asset(
                            AssetsManager.whiteJerasLogoIconPath,
                            width: AppSize.w40,
                            height: AppSize.h40,
                            fit: BoxFit.fill,
                          )
                        : ClipRRect(
                            borderRadius: BorderRadius.circular(AppRadius.r100),
                            child: FadeInImage.assetNetwork(
                              placeholder: AssetsManager.lodeGif,
                              placeholderScale: 0.5,
                              imageErrorBuilder: (context, error, stackTrace) =>
                                  Image.asset(
                                      AssetsManager.whiteJerasLogoIconPath,
                                      width: AppSize.w80,
                                      height: AppSize.h80,
                                      fit: BoxFit.fill),
                              image: widget.invoice.user.image!,
                              fit: BoxFit.cover,
                              fadeInDuration: Duration(
                                  milliseconds: AppConstants.milliseconds250),
                              fadeInCurve: Curves.easeInOut,
                              fadeOutDuration: Duration(
                                  milliseconds: AppConstants.milliseconds150),
                              fadeOutCurve: Curves.easeInOut,
                            ),
                          ),
                  ),
                ),
                Image.asset(
                  AssetsManager.dashBorder,
                  width: AppSize.w86,
                  height: AppSize.h86,
                )
              ],
            ),
            SizedBox(height: AppSize.h15),
            Text(widget.invoice.user.name!,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: TextStyle(
                    color: Theme.of(context).primaryColor,
                    fontSize: AppFontsSizeManager.s13,
                    fontWeight: FontWeight.w600)),
            SizedBox(height: AppSize.h50),
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppSize.w0_3
                      : AppSize.w20),
              child: Card(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(AppRadius.r15.r),
                ),
                elevation: 2,
                shadowColor: Theme.of(context).primaryColor,
                color: AppColors.white,
                child: Container(
                  width: size.width * AppSize.w8,
                  child: Padding(
                    padding: const EdgeInsets.all(AppPadding.p20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Row(
                          children: [
                            Text(getTranslated(context, "clientName"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                            Spacer(),
                            Text(widget.invoice.user.name!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSize.h20),
                        Row(
                          children: [
                            Text(getTranslated(context, "clientaccount"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                            Spacer(),
                            Text(widget.invoice.email,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSize.h20),
                        Row(
                          children: [
                            Text(getTranslated(context, "phoneNumber"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                            Spacer(),
                            Text(widget.invoice.user.phone!,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSize.h20),
                        Row(
                          children: [
                            Text(getTranslated(context, "due"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                            Spacer(),
                            Text(
                                '${dateFormat.format(widget.invoice.timestamp.toDate())}',
                                //'${dateFormat.format(widget.invoice.due.toDate())}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSize.h20),
                        Row(
                          children: [
                            Text(getTranslated(context, "expireDate"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                            Spacer(),
                            Text(
                                '${dateFormat.format(widget.invoice.expire.toDate())}',
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSize.h20),
                        Row(
                          children: [
                            Text(getTranslated(context, "price"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                            Spacer(),
                            Text(widget.invoice.price,
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                        SizedBox(height: AppSize.h20),
                        Row(
                          children: [
                            Text(getTranslated(context, "status"),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                                style: TextStyle(
                                    color: Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s13,
                                    fontWeight: FontWeight.w600)),
                            Spacer(),
                            //Icon(Icons.check_circle_outline,color: Colors.green,)
                            load
                                ? CircularProgressIndicator()
                                : Text(status,
                                    maxLines: 1,
                                    overflow: TextOverflow.ellipsis,
                                    style: TextStyle(
                                        color: Theme.of(context).primaryColor,
                                        fontSize: AppFontsSizeManager.s13,
                                        fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ],
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
