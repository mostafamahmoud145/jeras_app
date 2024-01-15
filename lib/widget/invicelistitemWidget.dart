import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';

import '../../screens/invoice/userInvoiceDetailsScreen.dart';
import '../models/InvoiceModel.dart';
class InvoiceListItem extends StatelessWidget {
  Invoice invoice;
  InvoiceListItem({required this.invoice });

  @override

  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    DateFormat dateFormat = DateFormat('dd/MM/yy');
    return  Container(
          width: size.width,
          child:  Padding(
            padding: const EdgeInsets.all(8.0),
            child: Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Container(
                    width:(kIsWeb||size.width >= 500)
?size.width*.2:size.width*.40,
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${invoice.user.name}',
                            maxLines: 1,
                            textAlign: TextAlign.start,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                                color: Theme.of(context).primaryColor,
                                fontSize: (kIsWeb||size.width >= 500)
?20:13,
                                fontWeight: FontWeight.w600
                            )),
                        Text('${dateFormat.format(invoice.expire.toDate())}',
                            textAlign: TextAlign.start,
                            style: TextStyle(
                            color: Colors.grey.shade600,
                            fontSize: (kIsWeb||size.width >= 500)
?15:12
                        )),
                      ],
                    ),
                  ),
                  Container(
                    width: 50,
                    height: 30,
                    decoration: BoxDecoration(
                      border: Border.all(color: Theme.of(context).primaryColor,width: .5),
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: Center(
                      child: Text('${invoice.price}',
                          style:TextStyle(
                              color: Theme.of(context).primaryColor,
                              fontSize: 13,
                              fontWeight: FontWeight.w600
                          )),
                    ),
                  ),
                  InkWell(
                    onTap: (){
                    //  getPromoDetails(userId: invoice.user.uid);
                      Navigator.push(context,MaterialPageRoute(
                          builder: (context)=>UserInvoiceItem(invoice:invoice,)));
                    },
                    child: Container(
                      width: 30,
                      height: 30,
                      decoration: BoxDecoration(
                        border: Border.all(color: Theme.of(context).primaryColor,width: 1),
                        color: Theme.of(context).primaryColor.withOpacity(.3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Center(
                          child: Icon(Icons.arrow_forward_outlined,
                            color: Theme.of(context).primaryColor,
                            size: 20,
                          )
                      ),
                    ),
                  )

                ],
              ),
          ),
          decoration: BoxDecoration(
            border: Border.all(color: Theme.of(context).primaryColor,width: 1),
            borderRadius: BorderRadius.circular(10),
          ),
        );
  }
}



