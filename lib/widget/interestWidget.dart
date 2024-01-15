import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:jeras/localization/localization_methods.dart';
import 'package:jeras/widget/responsive.dart';

import '../../config/colors_file.dart';
import '../config/paths.dart';
import '../models/interests.dart';
import 'component/textWidget.dart';

class InterestWidget extends StatefulWidget {
  List<dynamic>?interestListIds;
  InterestWidget({required this.interestListIds});

  @override
  _InterestWidgetState createState() => _InterestWidgetState();
}

class _InterestWidgetState extends State<InterestWidget>
    with SingleTickerProviderStateMixin {
  bool selected = false, loadInterest = true;
  List<Interests> _interestList = [];
  @override
  void initState() {
    super.initState();
    getInterests();
  }

  @override
  Widget build(BuildContext context) {
    Size size = MediaQuery.of(context).size;
    return Padding(
      padding: const EdgeInsets.only(right: 10, top: 5),
      child:   InkWell(
        onTap: () {
          setState(() {
            selected = !selected;
          });
        },
        child: Container(
          width: size.width,
          child: Row(
            mainAxisSize: MainAxisSize.max,
            children: <Widget>[
              Container(
                height: (kIsWeb||size.width >= 500)
?50:30,
                width: (kIsWeb||size.width >= 500)
?50:30,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Colors.orange[700],
                ),
                child: Icon(
                  Icons.star,
                  color: AppColors.white,
                  size: (kIsWeb||size.width >= 500)
?20:15,
                ),
              ),
              const SizedBox(width: 5),
              Icon(
                selected
                    ? Icons.arrow_back_ios_outlined
                    : Icons.arrow_forward_ios,
                color: AppColors.grey,
                size: (kIsWeb||size.width >= 500)
?18:15.0,
              ),
              const SizedBox(width: 5),
              Expanded(
                  flex: 2,
                  child: selected
                      ? _interestWidget(size)
                      : SizedBox(
                    width: size.width - 60,
                  ))
            ],
          ),
        ),
      ),
    );
  }

  Widget _interestWidget(Size size) {
    return Container(
      height: (kIsWeb||size.width >= 500)
?50:30,
      width: MediaQuery.of(context).size.width,
      child: ListView.separated(
          shrinkWrap: true,
          scrollDirection: Axis.horizontal,
          physics: ScrollPhysics(),
          separatorBuilder: (BuildContext context, int index) {
            return SizedBox(width: 10);
          },
          itemCount: _interestList.length,
          itemBuilder: (context, index) {
            return  Container(
              width: (kIsWeb||size.width >= 500)
?size.width * .1:size.width * .2,
              padding: EdgeInsets.all(5),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular((kIsWeb||size.width >= 500)
?60:15.0),
                boxShadow: [
                  BoxShadow(
                    color: AppColors.lightGrey,
                    blurRadius: 2.0,
                    spreadRadius: 0.0,
                    offset: Offset(0.0, 1.0),
                  )
                ],
              ),
              child: Center(
                child:
                TextWidget( text:getTranslated(context, "lang")=="ar"?
                _interestList[index].arName: _interestList[index].enName, color: Colors.black,
                  lines: 1,align:TextAlign.center,size: (kIsWeb||size.width >= 500)
?25.sp:10.sp, weight: FontWeight.w300 ,),

              ),
            );
          }),
    );
  }

  getInterests() async {
    try {
         if(widget.interestListIds!.length>0){
           List<Interests> _interests = [];
         for(int x=0;x<widget.interestListIds!.length;x++){
           DocumentSnapshot documentSnapshot =await FirebaseFirestore.instance.
           collection(Paths.interestsPath).doc(widget.interestListIds![x]).get();
           if(documentSnapshot.exists)
           _interests.add(Interests.fromMap(documentSnapshot.data() as Map));
         }
           setState(() {
             _interestList = _interests;
             loadInterest = false;
           });
}
         else
           setState(() {
             loadInterest=false;
           });
    } catch (e) {
      setState(() {
        loadInterest=false;
      });
    }
  }
}
