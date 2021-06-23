import 'package:bloc/bloc.dart';
import 'package:mapbox_gl/mapbox_gl.dart';

class MapTrackingModeBloc extends Cubit<MyLocationTrackingMode> {
  MapTrackingModeBloc() : super(MyLocationTrackingMode.None);
}
