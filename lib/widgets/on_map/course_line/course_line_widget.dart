import 'dart:math';

import 'package:animator/animator.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:geodesy/geodesy.dart' as geo;
import 'package:geolocator/geolocator.dart';
import 'package:hybrid_sailmate/map/bloc/map_bloc.dart';
import 'package:hybrid_sailmate/widgets/on_map/course_line/course_line_painter.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class CourseLineWidget extends HookWidget {
  CourseLineWidget({ @required this.mapBloc }) : super();

  final MapBloc mapBloc;
  final List<double> headings = <double>[0, 0];

  double _naturalDirection(heading, previousHeading) {
    if (heading > 270 && previousHeading < 90) {
      return 0;
    }
    if (heading < 90 && previousHeading > 270) {
      return 360;
    }

    return heading;
  }

  @override
  Widget build(BuildContext context) {
    final location = useStream(Geolocator.getPositionStream(desiredAccuracy: LocationAccuracy.best));
    final mapChanging = useStream(mapBloc.mapChanging);
    final mapTracking = useStream(mapBloc.mapTracking);

    if (location.data == null || mapChanging == null || mapTracking == null) {
      return Container();
    }

    final latitude = location.data?.latitude;
    final longitude = location.data?.longitude;
    final speed = location.data?.speed;
    final heading = location.data?.heading;

    var destinationPoint = geo.Geodesy().destinationPointByDistanceAndBearing(geo.LatLng(latitude, longitude), (speed * (5 * 60)), heading);
    var destinationPoint30 = geo.Geodesy().destinationPointByDistanceAndBearing(geo.LatLng(latitude, longitude), (speed * 30 * 60), heading);
    var destinationPoint60 = geo.Geodesy().destinationPointByDistanceAndBearing(geo.LatLng(latitude, longitude), (speed * 60 * 60), heading);

    headings.add(heading);
    if (headings.length > 6) {
      headings.removeAt(0);
    }

    return FutureBuilder<Map<String, dynamic>>(
      future: mapBloc.screenLocationAndDistance(
        LatLng(latitude, longitude),
        LatLng(destinationPoint.latitude, destinationPoint.longitude),
        LatLng(destinationPoint30.latitude, destinationPoint30.longitude),
        LatLng(destinationPoint60.latitude, destinationPoint60.longitude),
      ),
      builder: (BuildContext context, AsyncSnapshot<Map<String, dynamic>> snapshot) {
        var begin = headings[headings.length - 2];
        var end = _naturalDirection(heading, begin);

        return Animator(
          tween: Tween<double>(begin: begin, end: end),
          duration: Duration(milliseconds: 500),
          curve: Curves.linear,
          resetAnimationOnRebuild: true,
          builder: (context, animatorState, child) {
            var courseLine = CourseLinePainter(
              animatedHeading: animatorState.value,
              listenable: animatorState.animation,
            );
            courseLine.currentLocation = snapshot.data != null ? snapshot.data['startPoint'] : Point(0, 0);
            courseLine.distance = snapshot.data != null ? snapshot.data['distance'] : 0;
            courseLine.distance30 = snapshot.data != null ? snapshot.data['distance30'] : 0;
            courseLine.distance60 = snapshot.data != null ? snapshot.data['distance60'] : 0;

            if (
              snapshot.data == null ||
              speed == null || speed < 0.5 ||
              (mapChanging.data == true && (mapTracking.data == MyLocationTrackingMode.None || mapTracking.data == null))) {
              return Container();
            }

            return CustomPaint(painter: courseLine, child: Container());
          },
        );
      }
    );
  }
}
