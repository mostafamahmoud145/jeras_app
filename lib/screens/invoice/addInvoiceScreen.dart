import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:fluttertoast/fluttertoast.dart';
import 'package:http/http.dart';
import 'package:jeras/config/app_constat.dart';
import 'package:jeras/config/app_fonts.dart';
import 'package:jeras/config/app_values.dart';
import 'package:uuid/uuid.dart';

import '../../config/colors_file.dart';
import '../../config/paths.dart';
import '../../localization/localization_methods.dart';
import '../../models/user.dart';
class AddInvoiceScreen extends StatefulWidget {
  AddInvoiceScreen();
  @override

  _AddInvoiceScreenState createState() => _AddInvoiceScreenState();
}

class _AddInvoiceScreenState extends State<AddInvoiceScreen> {
  late String owner, code, discount, theme = "light";
  bool createInvoiceDone=false;

  @override
  void initState() {
    super.initState();
    createInvoiceDone=false;
  }
  TextEditingController nameController = TextEditingController();
  TextEditingController consultantNameController = TextEditingController();
  TextEditingController dueDateController = TextEditingController();
  TextEditingController expireDateController = TextEditingController();
  TextEditingController phoneController = TextEditingController();
  TextEditingController emailController = TextEditingController();
  TextEditingController priceController = TextEditingController();
  var _formKey = GlobalKey<FormState>();
  var due, expire;
  late GroceryUser user;
  List<GroceryUser> users = [];
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Scaffold(
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Padding(
            padding: const EdgeInsets.only(top: AppPadding.p60, left: AppPadding.p30, right: AppPadding.p30),
            child: Column(
              children: <Widget>[
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
                Text(getTranslated(context, "createInvoice"),
                  style: TextStyle(
                    color: Theme
                        .of(context)
                        .primaryColor,
                    fontFamily: getTranslated(context, "Ithra"),
                    fontSize: AppFontsSizeManager.s34,
                    fontWeight:AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
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
                SizedBox(height: AppSize.h30),
                TextFormField(
                  controller: nameController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientName");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight:AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.text,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                    helperStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    errorStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                     color: AppColors.black54,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    labelText: getTranslated(context, "clientName"),
                    labelStyle: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight:AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),
                SizedBox(
                 height: AppSize.h30,
                ),
                TextFormField(
                  controller: emailController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientEmail");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight:AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.emailAddress,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                    helperStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    errorStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                     color: AppColors.black54,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    labelText: getTranslated(context, "clientaccount"),
                    labelStyle: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight:AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),
                SizedBox(
                 height: AppSize.h30,
                ),
                TextFormField(
                  controller: phoneController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterClientPhone");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight:AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.phone,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                    helperStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    errorStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                     color: AppColors.black54,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    labelText: getTranslated(context, "phoneNumber"),
                    labelStyle: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight:AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),

                SizedBox(
                 height: AppSize.h30,
                ),
                TextFormField(
                  controller: priceController,
                  textAlignVertical: TextAlignVertical.center,
                  textAlign: TextAlign.center,
                  validator: (value) {
                    if (value!.isEmpty) {
                      return getTranslated(context, "plsEnterPrice");
                    }
                    return null;
                  },
                  onSaved: (val) {},
                  enableInteractiveSelection: true,
                  style: TextStyle(
                    fontFamily: getTranslated(context, "Ithra"),
                    color: AppColors.black,
                    fontSize: AppFontsSizeManager.s14_5,
                    fontWeight:AppFontsWeightManager.bold500,
                    letterSpacing: AppConstants.letterSpacing0_5,
                  ),
                  textInputAction: TextInputAction.done,
                  keyboardType: TextInputType.number,
                  textCapitalization: TextCapitalization.words,
                  decoration: InputDecoration(
                    contentPadding:
                    EdgeInsets.symmetric(horizontal: AppPadding.p15),
                    helperStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      color: Colors.black.withOpacity(0.65),
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    errorStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                      fontSize: AppFontsSizeManager.s13,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    hintStyle: TextStyle(
                      fontFamily: getTranslated(context, "Ithra"),
                     color: AppColors.black54,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight:AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_5,
                    ),
                    labelText: getTranslated(context, "invoiceprice"),
                    labelStyle: TextStyle(
                        fontFamily: getTranslated(context, "Ithra"),
                        fontSize: AppFontsSizeManager.s14_5,
                        fontWeight:AppFontsWeightManager.bold500,
                        letterSpacing: AppConstants.letterSpacing0_5,
                        color: Theme
                            .of(context)
                            .primaryColor
                    ),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(AppRadius.r5),
                    ),
                  ),
                ),
                SizedBox(
                  height: AppSize.h50,
                ),
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    InkWell(
                      onTap: ()  async{
                        if (_formKey.currentState!.validate()) {
                          _formKey.currentState?.save();
                          setState(() {
                            createInvoiceDone=true;
                          });
                          postInvoice(
                              email: emailController.text,
                             // expiry: expireDateController.text,
                              phone: phoneController.text,
                              price: priceController.text,
                              userName: nameController.text
                          );
                        }
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            createInvoiceDone ==true ? CircularProgressIndicator():Container(
                              width: size.width*AppSize.w0_3,
                              height: size.height*AppSize.h0_06,
                              decoration: BoxDecoration(
                                color: Theme
                                    .of(context)
                                    .primaryColor,
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5)),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "createInvoice"),
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color: AppColors.white,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_3,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                    SizedBox(width: size.width*AppSize.w0_05,),
                    InkWell(
                      onTap: (){
                        Navigator.pop(context);
                      },
                      child: Padding(
                        padding: const EdgeInsets.only(left: AppPadding.p10, right: AppPadding.p10),
                        child: Row(mainAxisAlignment: MainAxisAlignment.center,
                          crossAxisAlignment: CrossAxisAlignment.center,
                          children: [
                            Container(
                              width: size.width*AppSize.w0_3,
                              height: size.height*AppSize.h0_06,
                              decoration: BoxDecoration(
                                color: AppColors.white,
                                border: Border.all(color:Theme.of(context).primaryColor),
                                borderRadius: BorderRadius.all(
                                    Radius.circular(5)),
                              ),
                              child: Center(
                                child: Text(
                                  getTranslated(context, "endInvoice"),
                                  style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                                    color:Theme.of(context).primaryColor,
                                    fontSize: AppFontsSizeManager.s15,
                                    fontWeight: FontWeight.bold,
                                    letterSpacing: AppConstants.letterSpacing0_3,
                                  ),
                                ),
                              ),
                            ),

                          ],
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(
                  height: AppSize.h15,
                ),
              ],
            ),
          ),
        ),
      ),

    );
  }

  postInvoice({
    required String userName,
    @required var phone,
    @required var email,
    @required var price,
  }) async {
    try{
      QuerySnapshot querySnapshot = await FirebaseFirestore.instance.collection(Paths.usersPath)
          .where( 'phoneNumber', isEqualTo: phoneController.text, ).get();

      for (var doc in querySnapshot.docs) {
        users.add(GroceryUser.fromMap(doc.data() as Map));
      }
      if(users.length>0)
      {
        user=users[0];
        var dueDate=DateTime.now().add(Duration(minutes: 10));
        var expireDate=DateTime.now().add(Duration(days: 3));
        final uri = Uri.parse('https://api.tap.company/v2/invoices');
        final headers = {
          'Content-Type': 'application/json',
         // 'Authorization':"Bearer sk_test_vUR9IN1ryt0JDHjQzBXYgiCq",
          'Authorization':"Bearer sk_live_C7V9cpBMFWbt2ukjd3fRxIeD",
          'Connection':'keep-alive',
          'Accept-Encoding':'gzip, deflate, br'
        };
        String description="رسوم الخدمة (5%)";
        Map<String, dynamic> body ={
          "draft": false,
          "due": dueDate.microsecondsSinceEpoch,
          "expiry":expireDate.microsecondsSinceEpoch,
          "description": "فاتورة حجز طلب",
          "mode": "INVOICE",
          "note": description,
          "notifications": {
            "channels": [
              "SMS",
              "EMAIL"
            ],
            "dispatch": true
          },
          "currencies": [
            "USD"
          ],
          "metadata": {
            "udf1": "1",
            "udf2": "2",
            "udf3": "3"
          },
          "charge": {
            "receipt": {
              "email": true,
              "sms": true
            },
            "statement_descriptor": description
          },
          "customer": {
            "email": "$email",
            "first_name": userName,
            "last_name": ".",
            "middle_name": ".",
            "phone": {
              "country_code": " ",
              "number": "$phone"
            }
          },
          "order": {
            "amount":double.parse(price)+((double.parse(price)*5)/100),
            "currency": "USD",
            "items": [
              {
                "amount":double.parse(price) ,
                "currency": "USD",
                "description": "order ",
                "discount": {
                  "type": "P",
                  "value": 0
                },
                "image": "",
                "name": "order ",
                "quantity": 1
              }
            ],
            "tax": [
              {
                "description": "test",
                "name": "رسوم الخدمة",
                "rate": {
                  "type": "F",
                  "value": ((double.parse(price)*5)/100)
                }
              }
            ]
          /*  "shipping": {
              "amount": 1,
              "currency": "USD",
              "description": "test",
              "provider": "ARAMEX",
              "service": "test"
            },
            "tax": [
              {
                "description": "test",
                "name": "VAT",
                "rate": {
                  "type": "F",
                  "value": 1
                }
              }
            ]*/
          },
          "payment_methods": [
            ""
          ],
          "post": {
            "url": "http://your_website.com/post_url"
          },
          "redirect": {
            "url": "http://your_website.com/redirect_url"
          },
          "reference": {
            "invoice": "INV_00001",
            "order": "ORD_00001"
          }
        };
        String jsonBody = json.encode(body);
        final encoding = Encoding.getByName('utf-8');
        var response = await post(
          uri,
          headers: headers,
          body: jsonBody,
          encoding: encoding,
        );
        String responseBody = response.body;
        var res = json.decode(responseBody);
        String url = res['url'];
        String invoiceId = Uuid().v4();
        await FirebaseFirestore.instance.collection(Paths.invoicePath) .doc(invoiceId).set({
          'user': {
            'uid': user.uid,
            'name': userName,
            'image': user.photoUrl,
            'phone': phone,
            'countryCode': user.countryCode,
            'countryISOCode': user.countryISOCode,
          },
          'id':res['id'],
          'expiry':expireDate,
          'email':email,
          'price':(double.parse(price.toString())+((double.parse(price.toString())*5)/100)).toString(),
          'invoice':url,
          'timestamp':DateTime.now(),
          "invoiceId":invoiceId,
        }).then((value){
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceCreatedDone"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: AppColors.green2,
            textColor: AppColors.white,
            fontSize: AppFontsSizeManager.s16,
          );
          Navigator.pop(context);
        }).catchError((error){
          Fluttertoast.showToast(
            msg: getTranslated(context, "invoiceDataError"),
            toastLength: Toast.LENGTH_LONG,
            gravity: ToastGravity.TOP,
            timeInSecForIosWeb: 5,
            backgroundColor: AppColors.red,
            textColor: AppColors.white,
            fontSize: AppFontsSizeManager.s16,
          );
          setState(() {
            createInvoiceDone=false;
          });
        });

      }
      else{
        //flutter toast
        Fluttertoast.showToast(
          msg: getTranslated(context, "invoiceDataError"),
          toastLength: Toast.LENGTH_LONG,
          gravity: ToastGravity.TOP,
          timeInSecForIosWeb: 5,
          backgroundColor: AppColors.red,
          textColor: AppColors.white,
          fontSize: AppFontsSizeManager.s16,
        );
        setState(() {
          createInvoiceDone=false;
        });
      }

    }catch(e){
      Fluttertoast.showToast(
        msg: getTranslated(context, "invoiceCreatedError"),
        toastLength: Toast.LENGTH_LONG,
        gravity: ToastGravity.TOP,
        timeInSecForIosWeb: 5,
        backgroundColor: AppColors.red,
        textColor: AppColors.white,
        fontSize: AppFontsSizeManager.s16,
      );
    }
  }

}

