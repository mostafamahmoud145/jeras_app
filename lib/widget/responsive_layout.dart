import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout(
      {super.key, required this.desktop, required this.mobile});

  final Widget desktop;


  final Widget mobile;
  //old
  //size >400
  //desktop
  //size >=1100
  //tablet
  //size >599
  //mobile
  //size <=599

  //h
  //c.w.if.d.w.c.i.t.t.m.t.a.c.t.w




  @override
  Widget build(BuildContext context) {
    final Size size = MediaQuery.of(context).size;

    return kIsWeb||size.width >= 500 ? desktop : mobile;
  }
}
