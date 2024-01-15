



class Emojis{

   List<EmojiModle> emojiesList=[];

  Emojis(){

  }

  void getEmojiesList(){



    emojiesList=[EmojiModle(emojiPath: 'assets/lotifile/emojies/waving_emoji.json',soundPath:'sound/emojisound/applause.wav'),
      EmojiModle(emojiPath: 'assets/lotifile/emojies/cat.json',soundPath:'sound/emojisound/luaf.mp3'),
      EmojiModle(emojiPath: 'assets/lotifile/emojies/excellent.json',soundPath:'sound/emojisound/correct.mp3'),
      EmojiModle(emojiPath: 'assets/lotifile/emojies/sademoji.json',soundPath:'sound/emojisound/sadsight.mp3'),

    ];


  }




}

class EmojiModle{
  String ? emojiPath;
  String ? soundPath;

  EmojiModle({this.emojiPath,this.soundPath});
  factory EmojiModle.fromJason(Map<String,dynamic> map){
    return EmojiModle(
    emojiPath:map['emojiPath'] ,
      soundPath: map['soundPath']
    );

  }

  toJson(){
    return {
      'emojiPath':emojiPath,
      'soundPath':soundPath
    };


  }



}