import 'dart:math';

import 'package:flutter/material.dart';

class CourseLinePainter extends CustomPainter {
  final double animatedHeading;
  final Animation listenable;
  Point<num> currentLocation;
  double distance;
  double distance30;
  double distance60;

  final length = 200;

  CourseLinePainter({ @required this.animatedHeading, @required this.listenable }): super(repaint: listenable);

  double _radians(double degrees) {
    return pi * degrees / 180.0;
  }

  @override
  void paint(Canvas canvas, Size size) {
    var paint = Paint();
    paint.isAntiAlias = true;
    paint.color = Colors.blue[800];
    paint.strokeWidth = 3;

    if (currentLocation != null) {
      var heading = animatedHeading;
      var start = Point(currentLocation.x, currentLocation.y);
      var end = Point(start.x + cos(_radians(heading - 90)) * distance, start.y + sin(_radians(heading - 90)) * distance);
      var end30 = Point(end.x + cos(_radians(heading - 90)) * distance30, end.y + sin(_radians(heading - 90)) * distance30);
      var end60 = Point(end30.x + cos(_radians(heading - 90)) * distance60, end30.y + sin(_radians(heading - 90)) * distance60);
      canvas.drawLine(Offset(start.x, start.y), Offset(end.x, end.y), paint);
      paint.color = Colors.black87;
      canvas.drawCircle(Offset(start.x, start.y), 1.5, paint);
      paint.color = Colors.red[600];
      canvas.drawCircle(Offset(end.x, end.y), 3, paint);
      canvas.drawLine(Offset(end.x, end.y), Offset(end30.x, end30.y), paint);
      paint.color = Colors.red[900];
      canvas.drawCircle(Offset(end30.x, end30.y), 3, paint);
      canvas.drawLine(Offset(end30.x, end30.y), Offset(end60.x, end60.y), paint);
      paint.color = Colors.grey[600];
      canvas.drawCircle(Offset(end60.x, end60.y), 6, paint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) {
    return false;
  }
}
