import 'package:flutter/material.dart';
import 'package:geodesy/geodesy.dart';
import 'package:hybrid_sailmate/widgets/button/icon_button.dart';
import 'package:hybrid_sailmate/widgets/text_styles.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:point_of_interest_repository/point_of_interest_repository.dart';

class BottomSheetHeader extends StatelessWidget {
  final PointOfInterest port;
  final LatLng currentLocation;

  const BottomSheetHeader({Key key, @required this.port, @required this.currentLocation}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var portNumber = port.point_of_interest_properties
      .firstWhere(
        (element) => element.key == 'PORT_NUMBER',
        orElse: () => PointOfInterestProperty(key: 'PORT_NUMBER', value: '')
      ).value;

    var distance = Geodesy().distanceBetweenTwoGeoPoints(currentLocation, LatLng(port.lat, port.lon));

    var chartUrl = port.point_of_interest_properties
      .firstWhere(
        (element) => element.key == 'HARBOURCHART_URL',
        orElse: () => PointOfInterestProperty(key: 'HARBOURCHART_URL', value: null)
      ).value;

    var distanceTitle = 'poi.distance'.tr();

    return Container(
      padding: EdgeInsets.only(left: 16.0, right: 24.0),
      height: 210,
      child: Stack(
        children: [
          Container(
            margin: EdgeInsets.only(left: 8.0, top: 8.0),
            child: Row(
              children: [
                ClipRRect(
                  child: Image(
                    width: 170,
                    image: chartUrl != null ? Image.network(chartUrl).image : AssetImage('assets/images/sailmate_rounded.png'),
                    fit: BoxFit.cover,
                  ),
                ),
                SizedBox(width: 16.0,),
                Expanded(
                  child: Container(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text('${port.name} - $portNumber', style: TextStyles.bottomSheetItemLabel(), softWrap: false, overflow: TextOverflow.ellipsis),
                        Text(port.poi_type, style: TextStyles.bottomSheetItemLabelGrey12()),
                        SizedBox(height: 4.0,),
                        Row(
                          children: [
                            Image(
                              width: 10.0,
                              height: 12.0,
                              image: AssetImage('assets/images/ic_latlng.png'),
                            ),
                            SizedBox(width: 4.0,),
                            Text('${port.lat.toStringAsFixed(3)} N ${port.lon.toStringAsFixed(3)} E', style: TextStyles.bottomSheetItemLabel12(),),
                          ],
                        ),
                        Text('${(distance / 1000).toStringAsFixed(1)} $distanceTitle', style: TextStyles.bottomSheetItemLabelLigtGrey12(),),
                        SizedBox(height: 16.0,),
                        CustomIconButton(
                          txt: 'Route to',
                          icon: Icons.watch_later_outlined,
                          txtColor: Colors.white,
                          iconColor: Colors.white,
                          paddingHorizontal: 31.5,
                          backgroundColor: mainBlue,
                          radius: 8.0,
                          paddingVertical: 10.0
                        ),
                        SizedBox(height: 8.0,),
                        CustomIconButton(txt: 'Save place', icon: Icons.favorite_border, txtColor: Colors.white, iconColor: Colors.white, paddingHorizontal: 31.5, backgroundColor: mainBlue, radius: 8.0, paddingVertical: 10.0),
                      ],
                    ),
                  ),
                )
              ],
            ),
          ),
          Positioned(
            top: 0.0,
            left: 0.0,
            child: Container(
              alignment: Alignment.center,
              height: 34.0,
              width: 34.0,
              decoration: BoxDecoration(
                borderRadius: BorderRadius.all(Radius.circular(4.0)),
                color: Colors.lightBlueAccent[100],
              ),
              child: Image(
                height: 12.0,
                width: 12.0,
                image: AssetImage('assets/images/ic_port.png'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
