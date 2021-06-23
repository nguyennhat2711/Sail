import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hybrid_sailmate/widgets/text_styles.dart';
import 'package:point_of_interest_repository/point_of_interest_repository.dart';

class BottomSheetDescription extends StatelessWidget {
  final List<PointOfInterestProperty> properties;

  const BottomSheetDescription({Key key, @required this.properties}) : super(key: key);
  @override
  Widget build(BuildContext context) {
    var description = '';
    var descriptionKey = properties.where((element) => element.key == 'scout_description_fi').toList();
    if (descriptionKey.isNotEmpty) {
      description = descriptionKey.first.value;
    }

    return Container(
      padding: EdgeInsets.symmetric(horizontal: 24.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text('poi.description'.tr(), style: TextStyles.bottomSheetTitle(),),
          SizedBox(height: 4.0,),
          Text('$description', style: TextStyles.bottomSheetItemLabelGrey12(),),
        ],
      ),
    );
  }
}
