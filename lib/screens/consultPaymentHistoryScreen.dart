import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:intl/intl.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/assets_manager.dart';
import 'package:jeras/methods/check_if_web.dart';
import 'package:jeras/methods/convert_pt_to_px.dart';
import 'package:jeras/widget/custom_back_button.dart';
import 'package:jeras/widget/responsive.dart';

import '../../api/pdf_paragraph_api.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/payHistory.dart';
import '../../models/user.dart';
import '../FireStorePagnation/paginate_firestore.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../widget/component/IconButton.dart';
import '../widget/default_text_widget.dart';
import '../widget/divider_widget.dart';
import 'invoice_service.dart';

class ConsultPaymentHistoryScreen extends StatefulWidget {
  final GroceryUser user;

  const ConsultPaymentHistoryScreen({Key? key, required this.user})
      : super(key: key);

  @override
  _ConsultPaymentHistoryScreenState createState() =>
      _ConsultPaymentHistoryScreenState();
}

class _ConsultPaymentHistoryScreenState
    extends State<ConsultPaymentHistoryScreen>
    with SingleTickerProviderStateMixin {
  List<PayHistory> PayHistoryList = [];
  bool load = false;
  String theme = "light";
  final PdfInvoiceService service = PdfInvoiceService();
  DateFormat dateFormat = DateFormat('dd/MM/yy');
  String lang = "";

  @override
  void initState() {
    super.initState();
    getPaymentHistory();
  }

  getPaymentHistory() async {
    try {
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance
          .collection(Paths.payHistoryPath)
          .where('consultUid', isEqualTo: widget.user.uid)
          .orderBy("payDate", descending: true)
          .get();
      var payList = List<PayHistory>.from(
        querySnapshot.docs.map(
          (snapshot) => PayHistory.fromMap(snapshot.data() as Map),
        ),
      );
      setState(() {
        PayHistoryList = payList;
        load = false;
      });
    } catch (e) {
      setState(() {
        load = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    lang = getTranslated(context, "lang");

    return Scaffold(
      body: Column(
        children: <Widget>[
          /// app bar
          Container(
              width: size.width,
              child: SafeArea(
                  child: Padding(
                padding: EdgeInsets.only(
                    left: AppPadding.p20,
                    right: AppPadding.p20,
                    top: AppPadding.p10,
                    bottom: AppPadding.p10),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.start,
                  children: [
                    CustomBackButton(),
                    SizedBox(width: AppSize.w12.w),
                    Text(
                      getTranslated(context, "paymentHistory"),
                      textAlign: TextAlign.left,
                      style: TextStyle(
                          fontFamily: getTranslated(context, "Ithra"),
                          fontSize: checkIfWeb(context)
                              ? convertPtToPx(AppFontsSizeManager.s34.sp)
                              : convertPtToPx(AppFontsSizeManager.s16.sp),
                          color: Colors.black,
                          fontWeight: FontWeight.bold),
                    ),
                  ],
                ),
              ))),
          Center(
              child: DividerWidget(
                height: AppSize.h1.h,
                width: size.width.w,
              )),
          SizedBox(
            height: checkIfWeb(context) ? AppSize.h42.h : convertPtToPx(AppSize.h32.h),
          ),
          SvgPicture.asset(
            AssetsManager.walletIconPath,
            width: checkIfWeb(context)
                ? AppSize.w308_5
                : convertPtToPx(AppSize.w93_5.w),
            height: checkIfWeb(context)
                ? AppSize.h413_8
                : convertPtToPx(AppSize.h125_3.h),
            fit: BoxFit.cover,
          ),

          SizedBox(
            height: checkIfWeb(context)
                ? AppSize.h72_7
                : convertPtToPx(AppSize.h32_6),
          ),
          if (checkIfWeb(context))
            Padding(
              padding: EdgeInsets.symmetric(
                  horizontal: checkIfWeb(context)
                      ? size.width * AppPadding.p0_25
                      : AppPadding.p16.w),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  TextDefaultWidget(
                    title: getTranslated(context, "date"),
                    fontFamily: getTranslated(context, "Ithra"),
                    fontWeight:
                        checkIfWeb(context) ? FontWeight.bold : FontWeight.w400,
                    fontSize: checkIfWeb(context) ? AppFontsSizeManager.s45_3.sp : AppFontsSizeManager.s14.sp,
                    color: AppColors.primaryColor,
                  ),
                  TextDefaultWidget(
                    title: getTranslated(context, "amount"),
                    fontFamily: getTranslated(context, "Ithra"),
                    fontWeight:
                        checkIfWeb(context) ? FontWeight.bold : FontWeight.w400,
                    fontSize: checkIfWeb(context) ? AppFontsSizeManager.s45_3.sp : AppFontsSizeManager.s14.sp,
                    color: AppColors.primaryColor,
                  ),
                  SizedBox(),
                ],
              ),
            ),

          /// list of payment history

          Expanded(
            child: PaginateFirestore(
              itemBuilderType: PaginateBuilderType.listView,
              separator: Container(
                width: size.width,
                height: AppSize.h1.h,
                color:AppColors.greyShade300,
              ),
              padding: EdgeInsets.only(
                  left: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppPadding.p0_25
                      : AppPadding.p16,
                  right: (kIsWeb || size.width >= AppConstants.kIsWebValue)
                      ? size.width * AppPadding.p0_25
                      : AppPadding.p16,
                  bottom: AppPadding.p16,
                  top: AppPadding.p5),
              //Change types accordingly
              itemBuilder: (context, documentSnapshot, index) {
                return payHisItem(
                  PayHistory.fromMap(documentSnapshot[index].data() as Map),
                  size,
                );
              },
              query: FirebaseFirestore.instance
                  .collection(Paths.payHistoryPath)
                  .where('consultUid', isEqualTo: widget.user.uid)
                  .orderBy("payDate", descending: true),
              // to fetch real-time data
              isLive: true,
            ),
          ),
          /*load?CircularProgressIndicator():SingleChildScrollView(
            child: DataTable(
              //sortAscending: true,
                sortColumnIndex: 0,
                //columnSpacing: 2.0,
                dataRowHeight: 53.0,
                headingRowHeight: 70.0,
                columns: [
                  DataColumn(label: Text(getTranslated(context, "amount",),
                    textAlign:TextAlign.start,
                    style:TextStyle(color:theme=="light"?Colors.black:Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                    tooltip: getTranslated(context, "amount"),
                  ),
                  DataColumn(label: Center(
                    child: Text(getTranslated(context, "date"),
                      textAlign:TextAlign.center,
                      style:TextStyle(color:theme=="light"?Colors.black:Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                  ),
                    tooltip: getTranslated(context, "date"),
                  ),
                  DataColumn(label: Text(getTranslated(context, "download"),
                    textAlign:TextAlign.center,
                    style:TextStyle(color:theme=="light"?Colors.black:Colors.white,fontWeight: FontWeight.bold,fontSize: 15),),
                    tooltip: getTranslated(context, "download"),
                  ),
                ],
                rows: [
                  for(int x=0;x<PayHistoryList.length;x++)
                    DataRow(cells: [
                      DataCell(Text(double.parse(PayHistoryList[x].balance.toString()).toStringAsFixed(1)+"\$"),
                        placeholder: true,
                      ),
                      DataCell(Text('${new DateFormat('dd MMM yyyy, hh:mm a').format((PayHistoryList[x].payTime.toDate()))}'),
                      ),
                      DataCell(Center(
                        child: Icon(
                          Icons.arrow_circle_down,
                          color: Colors.black,
                          size: 30.0,
                        ),
                      ),onTap: () async {
                        final String date='${new DateFormat('dd MMM yyyy').format(PayHistoryList[x].payTime.toDate())}';
                        final pdfFile = await PdfParagraphApi.generate(widget.user,PayHistoryList[x],date,size);
                        PdfApi.openFile(pdfFile);

                      })
                    ]),

                ]),
          ),*/
        ],
      ),
    );
  }

  payHisItem(PayHistory pay, Size size) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextDefaultWidget(
          title: '${dateFormat.format(pay.payTime.toDate())}',
          fontFamily: checkIfWeb(context)
              ? getTranslated(context, "Ithralight")
              : getTranslated(context, "Ithra"),
          fontWeight: checkIfWeb(context) ? FontWeight.w600 : FontWeight.w400,
          fontSize: checkIfWeb(context)
              ? AppFontsSizeManager.s32.sp
              : convertPtToPx(AppFontsSizeManager.s12.sp),
          color:
              checkIfWeb(context) ? Color(0xff939393) : AppColors.primaryColor,
        ),
        TextDefaultWidget(
          title: double.parse(pay.balance.toString()).toStringAsFixed(1) + "\$",
          fontFamily: getTranslated(context, "Montserratsemibold"),
          fontWeight: checkIfWeb(context) ? FontWeight.w600 : FontWeight.w500,
          fontSize: checkIfWeb(context)
              ? AppFontsSizeManager.s34.sp
              : convertPtToPx(AppFontsSizeManager.s16.sp),
          color: Color.fromRGBO(30, 30, 30, 1.0),
        ),
        IconButton(
          icon: Icon(
            Icons.arrow_circle_down,
            color: AppColors.primaryColor,
            size: AppSize.w30,
          ),
          onPressed: () async {
            final String date =
                '${new DateFormat('dd MMM yyyy').format(pay.payTime.toDate())}';
            final pdfFile =
                await PdfParagraphApi.generate(widget.user, pay, date, size);
            ///PdfApi.openFile(pdfFile);
          },
        ),
      ],
    );
  }
}
