import 'package:flutter/material.dart';
import 'package:jeras/config/app_values.dart';
import 'package:shimmer/shimmer.dart';
class LoadWidget extends StatefulWidget {
  const LoadWidget({Key? key}) : super(key: key);

  @override
  State<LoadWidget> createState() => _LoadWidgetState();
}

class _LoadWidgetState extends State<LoadWidget> {
  @override
  Widget build(BuildContext context) {
    return Shimmer.fromColors(
        period: Duration(milliseconds: 800),
        baseColor: Colors.grey.withOpacity(0.6),
        highlightColor: Colors.black.withOpacity(0.6),
        child: Container(
          height: AppSize.h60,
          width: MediaQuery.of(context).size.width * AppSize.w0_9,
          padding: const EdgeInsets.all(8.0),
          margin: const EdgeInsets.symmetric(
            horizontal: AppPadding.p16,
          ),
          decoration: BoxDecoration(
            color: Colors.black.withOpacity(0.2),
            borderRadius: BorderRadius.circular(AppRadius.r30),
          ),
        ));
  }
}
