

import 'package:flutter/material.dart';
import 'package:lottie/lottie.dart';

class NoInternetComponent extends StatelessWidget {
  const NoInternetComponent({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded),
          onPressed: (){Navigator.pop(context);},
        ),
      ),
      body: Center(child: Lottie.asset('assets/lotifile/no_internet.json')),
    );
  }
}

