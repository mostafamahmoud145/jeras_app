

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

import '../../localization/localization_methods.dart';
import '../config/app_constat.dart';
import '../config/app_fonts.dart';
import '../config/app_values.dart';
import '../config/colors_file.dart';
import '../config/paths.dart';
import '../models/order.dart';
import 'orderListItem.dart';

class UserOrdersDialog extends StatefulWidget {
  final String consultUid;
  final String loggedUserUid;
  UserOrdersDialog({required this.consultUid,required this.loggedUserUid});

  @override
  _UserOrdersDialogState createState() => _UserOrdersDialogState();
}

class _UserOrdersDialogState extends State<UserOrdersDialog> {
  bool load=true;
  List<Orders>allOrders=[];
  @override
  void initState() {
    getUserOrders();
    super.initState();
  }
  Future<void> getUserOrders() async {
    try{
      List<Orders> orders=[];
      await FirebaseFirestore.instance
          .collection(Paths.ordersPath)
          .where( 'user.uid', isEqualTo: widget.loggedUserUid,)
          .where( 'consult.uid', isEqualTo: widget.consultUid,)
          .where( 'orderStatus', isEqualTo: "completed")
          .get().then((value) async {
        if(value.docs.length>0) {
          for (var doc in value.docs) {
            orders.add(Orders.fromMap(doc.data()));
          }
          setState(() {
            allOrders=orders;
            load=false;
          });


        }
        else {
          setState(() {
            allOrders=[];
            load=false;
          });
        }

      }).catchError((err) {

      });

    }catch(e) {
    }

  }
  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return AlertDialog(
      scrollable: true,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(
          Radius.circular(AppRadius.r15),
        ),
      ),
//      elevation: 5.0,
      contentPadding: EdgeInsets.symmetric(horizontal: AppPadding.p5, vertical: AppPadding.p5),
      content: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.all(AppPadding.p10),
              child: Row(mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    getTranslated(context,'orders'),
                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                       color: AppColors.black87,
                      fontSize: AppFontsSizeManager.s15,
                      fontWeight: AppFontsWeightManager.semiBold,
                      letterSpacing: AppConstants.letterSpacing0_3,
                    ),
                  ),
                  InkWell(onTap: (){
                    Navigator.pop(context);
                  }, child: Icon( Icons.cancel_outlined,color:AppColors.red,size: AppSize.w20, )),

                ],
              ),
            ),
            for(int x=0;x<allOrders.length;x++)
              OrderListItem(
                  order: allOrders[x],
                  type:"USER",
                  fromSupport:false,
                  theme:"light"
              ),
            /* ListView.separated(
                  shrinkWrap: true,
                  physics: ScrollPhysics(),
                  separatorBuilder: (BuildContext context, int index) {
                    return Container(height: 1,width: size.width*.6,color: AppColors.lightGrey,);
                  },
                  itemCount: allOrders.length,
                  itemBuilder: (context, index) {
                    return
                      OrderListItem(
                        order: allOrders[index],
                        type:"USER",
                        fromSupport:false,
                        theme:"light"
                    );
                  }
              ),*/
            Center(
              child: SizedBox(
                width: size.width * AppSize.w0_5,
                child: MaterialButton(
                  onPressed: () {
                    Navigator.pop(context);
                  },
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(AppRadius.r10),
                  ),
                  child: Text(
                    getTranslated(context,'cancel'),
                    style: TextStyle(fontFamily: getTranslated(context, "Ithra"),
                      color: AppColors.red,
                      fontSize: AppFontsSizeManager.s14_5,
                      fontWeight: AppFontsWeightManager.bold500,
                      letterSpacing: AppConstants.letterSpacing0_3,
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
