import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:jeras/widget/dialogWidget.dart';

import '../Utils/helper.dart';
import '../localization/localization_methods.dart';
import '../models/program.dart';

class ProgramController
{
  File? pickedImage;

  Future onPickImage(BuildContext context) async {
    pickedImage = await Helper.pickImage(context: context,);
  }

  deleteProgram(Program program, BuildContext context) {
    return showDialog(
        builder: (context) =>  DialogWidget(title: getTranslated(context, "deleteProgram"), dialogType: 'confirm', conformText: getTranslated(context, "yes"), cancelText: getTranslated(context, "no"),
          confirmPress: () async {

          var querySnapshot1 = await FirebaseFirestore.instance.collection("Courses").where('programId', isEqualTo: program.id).get();

          for (var doc in querySnapshot1.docs) {
            await FirebaseFirestore.instance.collection("Courses").doc(doc.id).delete();
          };


          await FirebaseFirestore.instance.collection("Program").doc(program.id).delete();

          Navigator.pop(context);
          Navigator.pop(context);
          // Navigator.push(context, MaterialPageRoute(builder: (_)=> ProgramIsSupervisorScreen()));

        }, cancelPress: () { Navigator.pop(context); },), context: context);}
}