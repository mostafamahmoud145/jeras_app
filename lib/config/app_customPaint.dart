import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:jeras/config/colors_file.dart';



class MyPainter1 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
   // Radius corner = Radius.circular(0);
    Paint paint = Paint()
      ..color = AppColors.grey2
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    Path path = Path();
    path.moveTo(w / 10, h / 3); // 5
    path.lineTo(w, h / 3); // 1
    path.lineTo(w, h); // 2
    path.lineTo(w / 10, h); // 3
    path.lineTo(0, h / 1.5); // 4
    // canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), corner), paint);
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyPainter2 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.grey4
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    Path path = Path();
    path.moveTo(w / 10, h / 3); // 6
    path.lineTo(w, h / 3); // 1
    path.lineTo(w / 1.1, h / 1.5); // 2
    path.lineTo(w, h); // 3
    path.lineTo(w / 10, h); // 4
    path.lineTo(0, h / 1.5); // 5

    // canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), corner), paint);
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyPainter3 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.grey4
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    Path path = Path();
    path.moveTo(0, h / 3); // 5
    path.lineTo(w, h / 3); // 1
    path.lineTo(w / 1.1, h / 1.5); // 2
    path.lineTo(w, h); // 3
    path.lineTo(0, h); // 4

    // canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), corner), paint);
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyPainter4 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Radius corner = Radius.circular(0);
    Paint paint = Paint()
      ..color = AppColors.grey2
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    Path path = Path();
    path.moveTo(0, h / 3);   // 5
    path.lineTo(w/ 1.1, h / 3);        // 1
    path.lineTo(w , h / 1.5);     // 2
    path.lineTo(w/ 1.1, h);           // 3
    path.lineTo(0, h);      // 4

    // canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), corner), paint);
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyPainter5 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    Paint paint = Paint()
      ..color = AppColors.grey4
      ..style = PaintingStyle.fill;
    final w = size.width;
    final h = size.height;
    Path path = Path();

    path.moveTo(w/ 1.1, h / 3);   // 1
    path.lineTo(0, h / 3);        // 6
    path.lineTo(w/ 10, h / 1.5);    //5
    path.lineTo(0, h);         //4
    path.lineTo(w/ 1.1, h);    // 3
    path.lineTo(w , h / 1.5);   // 2

    // canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), corner), paint);
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}

class MyPainter6 extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    // Radius corner = Radius.circular(0);
    Paint paint = Paint()
      ..color = AppColors.grey4
      ..style = PaintingStyle.fill;

    final w = size.width;
    final h = size.height;

    Path path = Path();
    path.moveTo(0, h / 3); // 5
    path.lineTo(w, h / 3); // 1
    path.lineTo(w, h); // 2
    path.lineTo(0, h); // 3
    path.lineTo(w / 10, h / 1.5); // 4

    // canvas.drawRRect(RRect.fromRectAndRadius(Rect.fromLTWH(0, 0, w, h), corner), paint);
    canvas.drawPath(
      path,
      paint,
    );
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}