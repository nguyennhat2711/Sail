import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:point_of_interest_repository/point_of_interest_repository.dart';

import '../text_styles.dart';

class BottomProperties extends HookWidget {
  final List<PointOfInterestProperty> properties;

  const BottomProperties({Key key, @required this.properties}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    var places = properties
      .firstWhere(
        (element) => element.key == 'PLACES',
        orElse: () => PointOfInterestProperty(key: 'PLACES', value: '-')
      ).value;
    var depth = properties
      .firstWhere(
        (element) => element.key == 'DEPTH',
        orElse: () => PointOfInterestProperty(key: 'DEPTH', value: '-')
      ).value;

    return Column(
      children: [
        Container(
          padding: EdgeInsets.symmetric(horizontal: 84.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Column(
                children: [
                  Text('$places', style: TextStyles.bottomSheetItemLabel(),),
                  Text('poi.places'.tr(), style: TextStyles.bottomSheetItemLabelLigtGrey12(),)
                ],
              ),
              Column(
                children: [
                  Text('$depth', style: TextStyles.bottomSheetItemLabel(),),
                  Text('poi.depth'.tr(), style: TextStyles.bottomSheetItemLabelLigtGrey12(),)
                ],
              )
            ],
          ),
        ),
        SizedBox(height: 25.0,),
        Container(
          padding: EdgeInsets.symmetric(horizontal: 24.0),
          child: Wrap(
            direction: Axis.horizontal,
            spacing: 24,
            runSpacing: 16,
            children: [
            ],
          ),
        ),
        SizedBox(height: 24.0),
      ],
    );
  }
}
