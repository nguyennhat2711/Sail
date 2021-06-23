import 'package:geodesy/geodesy.dart' as geo;
import 'package:hybrid_sailmate/map/bloc/map_bloc.dart';
import 'package:hybrid_sailmate/widgets/bottomsheet/bottom_properties.dart';
import 'package:hybrid_sailmate/widgets/bottomsheet/bottom_sheet_carousel.dart';
import 'package:hybrid_sailmate/widgets/bottomsheet/bottom_sheet_description.dart';
import 'package:hybrid_sailmate/widgets/bottomsheet/bottom_sheet_preview.dart';
import 'package:hybrid_sailmate/widgets/common/main_button_decoration.dart';
import 'package:hybrid_sailmate/widgets/on_map/course_line/course_line_widget.dart';
import 'package:hybrid_sailmate/widgets/on_map/speed_and_heading_info_box.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:fontisto_flutter/fontisto_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:mapbox_gl/mapbox_gl.dart';
import 'package:point_of_interest_repository/point_of_interest_repository.dart';
import 'package:wakelock/wakelock.dart';

class MapPage extends HookWidget {
  const MapPage({
    @required this.mapboxApiKey,
    @required this.mapboxStyleString,
    @required this.scaffoldKey
  }) : super();

  final String mapboxApiKey;
  final String mapboxStyleString;
  final GlobalKey<ScaffoldState> scaffoldKey;

  static Route route(String mapboxApiKey, String mapboxStyleString, GlobalKey scaffoldKey) {
    return MaterialPageRoute<void>(
      builder: (_) => MapPage(mapboxApiKey: mapboxApiKey, mapboxStyleString: mapboxStyleString, scaffoldKey: scaffoldKey)
    );
  }

  void showBottomSheet(PointOfInterest harbour, BuildContext context, geo.LatLng currentLocation) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      isDismissible: true,
      backgroundColor: Colors.transparent,
      builder: (context) => DraggableScrollableSheet(
        initialChildSize: 260 / MediaQuery.of(context).size.height,
        minChildSize: 0.2,
        maxChildSize: 0.95,
        builder: (context, controller) {
          BlocProvider.of<MapBloc>(context).add(PoiDetailsBottomSheetShown());
          return Container(
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
              )
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.only(
                topRight: Radius.circular(20.0),
                topLeft: Radius.circular(20.0),
              ),
              child: Column(
                children: [
                  SizedBox(height: 16.0,),
                  Row(
                    children: [
                      Spacer(),
                      Container(
                        width: 92,
                        height: 4,
                        decoration: BoxDecoration(
                          color: Colors.grey[300],
                          borderRadius: BorderRadius.all(Radius.circular(2.0)),
                        ),
                      ),
                      Spacer()
                    ],
                  ),
                  SizedBox(height: 16.0,),
                  Expanded(
                    child: SingleChildScrollView(
                      controller: controller,
                      child: Container(
                        child: Column(
                          children: [
                            BottomSheetHeader(port: harbour, currentLocation: currentLocation),
                            SizedBox(height: 24.0,),
                            BottomSheetCarousel(harbour: harbour),
                            SizedBox(height: 16.0,),
                            BottomProperties(properties: harbour.point_of_interest_properties),
                            BottomSheetDescription(properties: harbour.point_of_interest_properties),
                            Container(
                              color: Colors.white,
                              height: 200,
                            )
                          ],
                        ),
                      ),
                    ),
                  ),
                ],
              ),
            ),
          );
        }
      )
    );
  }

  bool mapIsLoading(MapState state) {
    return state is MapCreateInProgress ||
      state is MapCreateRequested ||
      state is PointOfInterestsRequested ||
      state is PointOfInterestsLoadInProgress ||
      state is MapRenderRequested ||
      state is MapRenderInProgress;
  }

  @override
  Widget build(BuildContext context) {
    Wakelock.enable();
    // ignore: close_sinks
    final bloc = BlocProvider.of<MapBloc>(context);

    var height = MediaQuery.of(context).size.height;

    return Container(
        child: FutureBuilder<Position>(
          future: Geolocator.getCurrentPosition(),
          builder: (BuildContext context, AsyncSnapshot<Position> snapshot) {
            var latitude = snapshot.data?.latitude;
            var longitude = snapshot.data?.longitude;

            if (snapshot.hasError) {
              print('Error fetching current location');
            }

            return Center(
              child: Stack(
                children: [
                  BlocConsumer<MapBloc, MapState>(
                    listener: (context, state) {
                      if (state is PoiClicked) {
                        showBottomSheet(state.poi, context, geo.LatLng(latitude, longitude));
                      }
                    },
                    builder: (context, state) {
                      if (state is MapInitial) {
                        BlocProvider.of<MapBloc>(context).add(MapCreateRequested(accessToken: mapboxApiKey, styleString: mapboxStyleString));
                      }

                      if (state is MapRendered && latitude != null && longitude != null) {
                        bloc
                          .add(
                            CameraUpdateRequested(location: LatLng(latitude, longitude), zoom: 10)
                          );
                      }

                      if (state is CameraUpdated) {
                        bloc.add(PointOfInterestsRequested());
                      }

                      if (bloc.getMap() != null) {
                        return Stack(
                          children: [
                            bloc.getMap(),
                            IgnorePointer(
                              child: CourseLineWidget(mapBloc: bloc),
                            ),
                            SpeedAndHeadingInfoBox(top: height < 670 ? 25 : 58),
                            Positioned(
                              bottom: 40,
                              right: 24,
                              child: FloatingActionButton(
                                onPressed: () {
                                  bloc.add(CameraUpdateRequested(location: LatLng(snapshot.data.latitude, snapshot.data.longitude)));
                                  bloc.add(TrackingModeUpdateRequested(mode: MyLocationTrackingMode.Tracking));
                                },
                                child:  Image.asset('assets/icons/ic_crosshair.png'),
                              )
                            ),
                          ]
                        );
                      }

                      return Stack(
                          children: [
                            Container(
                              decoration: BoxDecoration(color: Colors.white.withOpacity(0.98)),
                            ),
                            Center(
                              child: CircularProgressIndicator(),
                            )
                          ],
                        );
                    }
                  ),
                  Positioned(
                    left: 24,
                    top: height < 670 ? 25 : 58,
                    child: SizedBox(
                      height: 46,
                      width: 46,
                      child: DecoratedBox(
                        decoration: MainButtonDecoration(),
                        child: FlatButton(
                          onPressed: () {
                            Scaffold.of(context).openDrawer();
                          },
                          child: Icon(Istos.nav_icon, color: Colors.grey, size: 12),
                        ),
                      ),
                    ),
                  ),
                ],
              )
            );
          }
        )
    );
  }
}
