import 'package:flutter/material.dart';
import 'package:fontisto_flutter/fontisto_flutter.dart';
import 'package:hybrid_sailmate/widgets/common/main_button_decoration.dart';

class ArrowBackButton extends StatelessWidget {
  ArrowBackButton({ this.onTap }) : super();

  final Function onTap;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 46,
      width: 46,
      child: DecoratedBox(
        decoration: MainButtonDecoration(),
        child: FlatButton(
          onPressed: () {
            onTap != null ? onTap() : Navigator.of(context).pop();
          },
          child: Icon(Istos.arrow_left, color: Colors.grey, size: 12),
        ),
      ),
    );
  }
}
