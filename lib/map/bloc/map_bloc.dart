import 'dart:async';
import 'dart:math';

import 'package:flutter/material.dart';
import 'package:hybrid_sailmate/map/bloc/map_dragging_bloc.dart';
import 'package:hybrid_sailmate/map/bloc/map_tracking_mode_bloc.dart';
import 'package:hybrid_sailmate/map/map.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:meta/meta.dart';
import 'package:bloc/bloc.dart';
import 'package:equatable/equatable.dart';

import 'package:point_of_interest_repository/point_of_interest_repository.dart';

abstract class MapEvent extends Equatable {
  const MapEvent();

  @override
  List<Object> get props => [];
}

class MapCreateRequested extends MapEvent {
  final String accessToken;
  final String styleString;

  const MapCreateRequested({
    @required this.accessToken,
    @required this.styleString,
  }) : assert(accessToken != null && styleString != null);

  @override
  List<Object> get props => [accessToken, styleString];
}

class MapRenderRequested extends MapEvent {
  @override
  List<Object> get props => [];
}

class CameraUpdateRequested extends MapEvent {
  final LatLng location;
  final double zoom;

  const CameraUpdateRequested({
    @required this.location,
    this.zoom,
  }) : assert(location != null);

  @override
  List<Object> get props => [location, zoom];
}

class TrackingModeUpdateRequested extends MapEvent {
  final MyLocationTrackingMode mode;

  const TrackingModeUpdateRequested({
    @required this.mode,
  }) : assert(mode != null);

  @override
  List<Object> get props => [mode];
}

// TODO: move to separate file
// Point of interest

class PointOfInterestsRequested extends MapEvent {
  const PointOfInterestsRequested();

  @override
  List<Object> get props => [];
}

class MapMarkerClicked extends MapEvent {
  MapMarkerClicked({ @required this.clickedMarker}) : assert(clickedMarker != null);

  final PointOfInterest clickedMarker;

  @override
  List<Object> get props => [clickedMarker];

}

class PoiDetailsBottomSheetShown extends MapEvent {}

// Point of interest end

abstract class MapState extends Equatable {
  const MapState();

  @override
  List<Object> get props => [];
}
abstract class MapVisible extends MapState {
  const MapVisible();

  @override
  List<Object> get props => [];
}

class MapClicked extends MapState {}

class PoiClicked extends MapState {
  final PointOfInterest poi;

  const PoiClicked({@required this.poi}) : assert(poi != null);

  @override
  List<Object> get props => [poi];
}

class PoiDetailsBottomSheetCleared extends MapState {}

class MapInitial extends MapState {}

class MapRenderInProgress extends MapVisible {}
class MapRendered extends MapVisible {}

class MapCreateInProgress extends MapState {}



class MapReady extends MapVisible {
  final MapboxMap mapboxMap;

  const MapReady({@required this.mapboxMap}) : assert(mapboxMap != null);

  @override
  List<Object> get props => [mapboxMap];
}

class CameraUpdateInProgress extends MapVisible {}
class CameraUpdated extends MapVisible {}

class TrackingModeUpdateInProgress extends MapVisible {}
class TrackingModeUpdated extends MapVisible {}

class PointOfInterestsLoadInProgress extends MapVisible {}

class PointOfInterestsLoadSuccess extends MapVisible {
  final List<PointOfInterest> pointOfInterests;

  const PointOfInterestsLoadSuccess({@required this.pointOfInterests}) : assert(pointOfInterests != null);

  @override
  List<Object> get props => [pointOfInterests];
}

class PointOfInterestsLoadFailure extends MapVisible {}

class MapBloc extends Bloc<MapEvent, MapState> {
  final PointOfInterestRepository pointOfInterestRepository;

  List<PointOfInterest> targetInterestPlaces;
  MapboxMapController _mapController;
  MapboxMap _map;

  MapPage parentPage;

  MapDraggingBloc mapChanging = MapDraggingBloc();
  MapTrackingModeBloc mapTracking = MapTrackingModeBloc();

  MapBloc({@required this.pointOfInterestRepository})
      : assert(pointOfInterestRepository != null),
        super(MapInitial());

  MapboxMap _createMapSync(String accessToken, String styleString) {
    return MapboxMap(
      accessToken: accessToken,
      styleString: './assets/mapbox/style.json',
      rotateGesturesEnabled: false,
      onMapClick: (point, location) {
        _mapController.updateMyLocationTrackingMode(MyLocationTrackingMode.None);
      },
      onCameraTrackingChanged: (mode) => mapTracking.emit(mode),
      onMapCreated: (controller) {
        _mapController = controller;
        _mapController.addListener(() {
          mapChanging.emit(_mapController.isCameraMoving);
        });
        add(MapRenderRequested());
      },
      // TODO: not the prettiest way to hide attribution
      attributionButtonMargins: Point(0, 10000),
      onStyleLoadedCallback: () {},
      initialCameraPosition: CameraPosition(target: LatLng(60, 20), zoom: 1),
      myLocationEnabled: true,
      myLocationTrackingMode: MyLocationTrackingMode.None,
    );

  }

  bool _isNumeric(String s) {
    if (s == null) {
      return false;
    }
    return double.tryParse(s) != null;
  }

  String _getType(PointOfInterest poi) {
    var hasFuel = poi.point_of_interest_properties
      .firstWhere(
        (property) => property.key == 'FUEL',
        orElse: () => PointOfInterestProperty(key: 'FUEL', value: 'false')
      ).value;
    if (hasFuel == 'true') {
      return 'FUEL';
    }
    if (poi.is_scout_port) {
      return 'SCOUT';
    }

    return 'PORT';
  }

  String _selectIcon(String type) {
    switch (type) {
      case 'FUEL':
        return 'assets/icons/ic_fuel.png';
      case 'SCOUT':
        return 'assets/icons/ic_scout.png';
      default:
        return 'assets/icons/ic_port.png';
    }
  }

  int _selectIconSize(PointOfInterest poi) {
    var places = poi
      .point_of_interest_properties
      .firstWhere(
        (element) => element.key == 'PLACES',
        orElse: () => PointOfInterestProperty(key: 'PLACES', value: '0')
      ).value;
    return _isNumeric(places) ? int.parse(places) : 0;
  }

  Future<MapboxMap> _createMap(String accessToken, String styleString) {
    final completer = Completer<MapboxMap>();
    completer.complete(_createMapSync(accessToken, styleString));
    return completer.future;
  }

  MapboxMap getMap() {
    return _map;
  }

  Future<Point<num>> toScreenLocation(LatLng location) {
    return _mapController?.toScreenLocation(location);
  }
  Future<Map<String, dynamic>> screenLocationAndDistance(
    LatLng location,
    LatLng destination,
    LatLng destination30,
    LatLng destination60
  ) async {
    var startPoint = await _mapController?.toScreenLocation(location);
    var endPoint = await _mapController?.toScreenLocation(destination);
    var endPoint30 = await _mapController?.toScreenLocation(destination30);
    var endPoint60 = await _mapController?.toScreenLocation(destination60);
    var distance = sqrt(pow((startPoint.x - endPoint.x), 2) + pow((startPoint.y - endPoint.y), 2));
    var distance30 = sqrt(pow((endPoint.x - endPoint30.x), 2) + pow((endPoint.y - endPoint30.y), 2));
    var distance60 = sqrt(pow((endPoint30.x - endPoint60.x), 2) + pow((endPoint30.y - endPoint60.y), 2));

    return { 'startPoint': startPoint, 'distance': distance, 'distance30': distance30, 'distance60': distance60 };
  }

  @override
  Stream<MapState> mapEventToState(MapEvent event) async* {
    if (event is MapCreateRequested) {
      yield* _mapMapCreateRequestedToState(event);
    }
    if (event is CameraUpdateRequested) {
      yield* _mapCameraUpdateRequestedToState(event);
    }
    if (event is PointOfInterestsRequested) {
      yield* _mapPointOfInterestsRequestedToState(event);
    }
    if (event is MapRenderRequested) {
      yield MapRenderInProgress();
      yield MapRendered();
    }
    if (event is TrackingModeUpdateRequested) {
      yield TrackingModeUpdateInProgress();
      await _mapController.updateMyLocationTrackingMode(event.mode);
      yield TrackingModeUpdated();
    }
    if (event is MapMarkerClicked) {
      yield PoiClicked(poi: event.clickedMarker);
    }
    if (event is PoiDetailsBottomSheetShown) {
      yield PoiDetailsBottomSheetCleared();
    }
  }

  Stream<MapState> _mapPointOfInterestsRequestedToState(
    PointOfInterestsRequested event,
  ) async* {
    yield PointOfInterestsLoadInProgress();
    try {
      var wrapped = await pointOfInterestRepository.getPointOfInterests();
      var symbolOptions = <SymbolOptions>[];
      var data = <Map<dynamic, dynamic>>[];
      targetInterestPlaces = wrapped.map((PointOfInterestWrapper wrapper) {
        var poi = wrapper.point_of_interest;

        symbolOptions.add(SymbolOptions(
          iconAnchor: 'bottom',
          iconSize: _selectIconSize(poi) < 20 ? 0.6 : 1,
          geometry: LatLng(poi.lat, poi.lon),
          iconImage: _selectIcon(_getType(poi)),
        ));
        data.add({ 'poi': poi });
        return wrapper.point_of_interest;
      }).toList();
      await _mapController.addSymbols(symbolOptions, data);
      _mapController.onSymbolTapped.add(
        (symbol) {
          add(MapMarkerClicked(clickedMarker: symbol.data['poi'] as PointOfInterest));
        }
      );
      yield PointOfInterestsLoadSuccess(pointOfInterests: targetInterestPlaces);
    } catch (_) {
      yield PointOfInterestsLoadFailure();
    }
  }
  Stream<MapState> _mapCameraUpdateRequestedToState(
    CameraUpdateRequested event,
  ) async* {
    yield CameraUpdateInProgress();
    try {
      await _mapController.animateCamera(
        CameraUpdate.newCameraPosition(
          CameraPosition(
            target: event.location,
            zoom: event.zoom
          )
        )
      );
      yield CameraUpdated();
    } catch (_) {
      yield PointOfInterestsLoadFailure();
    }
  }
  Stream<MapState> _mapMapCreateRequestedToState(
    MapCreateRequested event,
  ) async* {
    yield MapCreateInProgress();
    try {
      var map = await _createMap(event.accessToken, event.styleString);
      _map = map;
      mapTracking.emit(map.myLocationTrackingMode);
      await Future.delayed(Duration(seconds: 1));
      yield MapReady(mapboxMap: map);
    } catch (_) {
      yield PointOfInterestsLoadFailure();
    }
  }
}
