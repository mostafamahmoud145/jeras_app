import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

import '../screens/RtcScreens/emojis.dart';

class chooseEmojiBottomSheet extends StatefulWidget{

  Function (int  emojeIndex)  ? onchoose  ;
  List<EmojiModle> emojeList=[];
  chooseEmojiBottomSheet(this.onchoose,this.emojeList);


  @override
  State<StatefulWidget> createState() {
    // TODO: implement createState
    return chooseEmojiBottomSheetState();
  }



}

class chooseEmojiBottomSheetState extends State<chooseEmojiBottomSheet>{
  @override
  Widget build(BuildContext context) {
    // TODO: implement build

    return GridView.count(crossAxisCount: 5,
    children: widget.emojeList.asMap().entries.map((e) {

      return InkWell(
        onTap: ()=>widget.onchoose!.call(e.key),

        child:         Lottie.asset(widget.emojeList.elementAt(e.key).emojiPath!,width: 50,height: 50),

      );


    }


    ).toList(),
    );


  }

}