import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/widget/component/IconButton.dart';
import 'package:jeras/widget/responsive.dart';

import '../../FireStorePagnation/paginate_firestore.dart';
import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/InvoiceModel.dart';
import '../../widget/invicelistitemWidget.dart';
import 'addInvoiceScreen.dart';

class AllInvoicesScreen extends StatefulWidget {
  @override
  _AllInvoicesScreenState createState() => _AllInvoicesScreenState();
}

class _AllInvoicesScreenState extends State<AllInvoicesScreen>
    with SingleTickerProviderStateMixin {
  @override
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;

    return Scaffold(
      body: Stack(children: <Widget>[
        Padding(
          padding: const EdgeInsets.only(top: 10),
          child: Column(
            children: <Widget>[
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
                        // mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          IconButton1(
                            onPress: Navigator.of(context).pop,
                            Width:
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.w97.w : AppSize.w50_6.w,
                            Height:
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h97.h : AppSize.h50_6.h,
                            ButtonRadius:
                                (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppRadius.r24.r : AppRadius.r10_6.r,
                            IconWidth: AppSize.w32.w,
                            IconHeight: AppSize.h32.h,
                            IconColor: Theme.of(context).primaryColor,
                            Icon:
                                AssetsManager.blackArrowRightIconPath,
                            ButtonBackground: AppColors.white,
                          ),
                        ],
                      ),
                    ),
                  )),
              Divider(
                thickness: 1,
                color: AppColors.lightGrey,
              ),
              SizedBox(
                height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h10 : AppSize.h20,
              ),
              Padding(
                padding: EdgeInsets.symmetric(
                    horizontal:
                        (kIsWeb || size.width >= AppConstants.kIsWebValue) ? size.width * AppPadding.p0_4 : AppPadding.p0),
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: AppMargin.m80),
                         color: AppColors.black45,
                        width: AppSize.w60,
                        height: AppSize.h1,
                      ),
                    ),
                    SizedBox(height: AppSize.h6),
                    Align(
                      alignment: Alignment.topLeft,
                      child: Container(
                        margin: EdgeInsets.only(left: AppMargin.m80),
                         color: AppColors.black45,
                        width: AppSize.w100,
                        height: AppSize.h1,
                      ),
                    ),
                    Text(
                      getTranslated(context, "invoices"),
                      style: TextStyle(
                        color: Theme.of(context).primaryColor,
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s35,
                        fontWeight: AppFontsWeightManager.bold500,
                        letterSpacing:AppConstants.letterSpacing0_5,
                      ),
                    ),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.only(right: AppMargin.m80),
                         color: AppColors.black45,
                        width: AppSize.w100,
                        height: AppSize.h1,
                      ),
                    ),
                    SizedBox(height: AppSize.h6),
                    Align(
                      alignment: Alignment.topRight,
                      child: Container(
                        margin: EdgeInsets.only(right: AppMargin.m80),
                         color: AppColors.black45,
                        width: AppSize.w60,
                        height: AppSize.h1,
                      ),
                    ),
                    SizedBox(height: AppSize.h10),
                  ],
                ),
              ),
              Expanded(
                child: PaginateFirestore(
                  separator: SizedBox(
                    height: (kIsWeb || size.width >= AppConstants.kIsWebValue) ? AppSize.h20 : AppSize.h10,
                  ),
                  itemBuilderType: PaginateBuilderType.listView,
                  padding: EdgeInsets.only(
                      left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppPadding.p0_3
                          : AppPadding.p16,
                      right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                          ? size.width * AppPadding.p0_3
                          : AppPadding.p16,
                      bottom: AppPadding.p16,
                      top: AppPadding.p16,),
                  //Change types accordingly
                  itemBuilder: (context, documentSnapshot, index) {
                    return InvoiceListItem(
                      invoice: Invoice.fromMap(
                          documentSnapshot[index].data() as Map),
                    );
                  },
                  query: FirebaseFirestore.instance
                      .collection(Paths.invoicePath)
                      .orderBy('timestamp', descending: true),
                  // to fetch real-time data
                  isLive: true,
                ),
              )
            ],
          ),
        ),
      ]),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          Navigator.push(context,
              MaterialPageRoute(builder: (context) => AddInvoiceScreen()));
        },
        child: Icon(Icons.add),
        backgroundColor: Theme.of(context).primaryColor,
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.startFloat,
    );
  }
}
