import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:jeras/models/user.dart';

import '../models/courses.dart';

 class dynamicLinks {


 static shareConsultantByDynamicLink(String link,BuildContext context, GroceryUser? consultant)
  async {
    try {

    //  showDialog(context: context, builder: (con)=>InitialLoader());



      final response = await http.post(Uri.parse(
          "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyAZ9B_jnmkYC-HmcNAPZ8OxeiRsltBTof4"),
        body: json.encode({"dynamicLinkInfo": {
          "domainUriPrefix": "https://jeras.page.link",
          "link": link,
          "androidInfo": {
            "androidPackageName": "com.app.jeras"
          },
          "iosInfo": {
            "iosBundleId": "com.app.jeras"
          },
          "socialMetaTagInfo" :{
            "socialImageLink":consultant?.photoUrl,
            "socialTitle":"تطبيق غراس",
            "socialDescription": '\n أعجبتني التجربة مع ${consultant?.name} '
                 ' وأحببت مشاركتك.\n '
          }

        },
          "suffix": {
            "option":"UNGUESSABLE"


        }
        }
        ), headers: {"Content-Type": "application/json",


        }

        ,);

      final responseData = json.decode(response.body);



   // Navigator.pop(context);

      return responseData['shortLink'];
    } catch ( exp) {

    //  Navigator.pop(context);

      throw exp;
    }


  }

 static shareProgrambyDynamicLink(String link,BuildContext context, Courses? course)
 async {
   try {

     //  showDialog(context: context, builder: (con)=>InitialLoader());

     final response = await http.post(Uri.parse(
         "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyAZ9B_jnmkYC-HmcNAPZ8OxeiRsltBTof4"),
       body: json.encode({"dynamicLinkInfo": {
         "domainUriPrefix": "https://jeras.page.link",
         "link": link,
         "androidInfo": {
           "androidPackageName": "com.app.jeras"
         },
         "iosInfo": {
           "iosBundleId": "com.app.jeras"
         },
         "socialMetaTagInfo" :{
           //"socialImageLink":course?.image,
           "socialTitle":"تطبيق غراس",
           "socialDescription": '\n أعجبتني البرنامج ${course?.name} '
               ' وأحببت مشاركته.\n '
         }
       },
         "suffix": {
           "option":"UNGUESSABLE"
         }
       }
       ), headers: {"Content-Type": "application/json",
       }
       ,);

     final responseData = json.decode(response.body);



     // Navigator.pop(context);

     return responseData['shortLink'];
   } catch ( exp) {

     //  Navigator.pop(context);

     throw exp;
   }


 }

 static shareAppbyDynamicLink(String link,BuildContext context)
 async {
   try {

     //  showDialog(context: context, builder: (con)=>InitialLoader());

     final response = await http.post(Uri.parse(
         "https://firebasedynamiclinks.googleapis.com/v1/shortLinks?key=AIzaSyAZ9B_jnmkYC-HmcNAPZ8OxeiRsltBTof4"),
       body: json.encode({"dynamicLinkInfo": {
         "domainUriPrefix": "https://jeras.page.link",
         "link": link,
         "androidInfo": {
           "androidPackageName": "com.app.jeras"
         },
         "iosInfo": {
           "iosBundleId": "com.app.jeras"
         },
         "socialMetaTagInfo" :{
           "socialImageLink":"",
           "socialTitle":"تطبيق غراس",
           "socialDescription": '\n أعجبني التطبيق '
               ' وأحببت مشاركته.\n '
         }
       },
         "suffix": {
           "option":"UNGUESSABLE"
         }
       }
       ), headers: {"Content-Type": "application/json",
       }
       ,);

     final responseData = json.decode(response.body);



     // Navigator.pop(context);

     return responseData['shortLink'];
   } catch ( exp) {

     //  Navigator.pop(context);

     throw exp;
   }


 }

}