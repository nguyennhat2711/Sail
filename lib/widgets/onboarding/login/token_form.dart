import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_hooks/flutter_hooks.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hybrid_sailmate/auth/bloc/auth_bloc.dart';
import 'package:hybrid_sailmate/widgets/text_styles.dart';
import 'package:pin_code_fields/pin_code_fields.dart';

final background = Color(int.parse('0xffE9E9E9'));
final mainBlue = Color(int.parse('0xff4B7CC6'));

class TokenForm extends HookWidget {
  @override
  Widget build(BuildContext context) {
    var token = useState('');
    var hasError = useState(false);
    var textEditingController = TextEditingController();

    return SizedBox.expand(
      child: Container(
        decoration: BoxDecoration(
          color: background,
          image: DecorationImage(
            image: AssetImage('assets/images/login_background.png'),
            alignment: Alignment.topLeft
          ),
        ),
        child: Padding(
          padding: EdgeInsets.only(left: 40, right: 40, bottom: 40, top: 58),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.start,
                children: [
                  Image(image: AssetImage('assets/images/sailmate_rounded.png')),
                  SizedBox(width: 20),
                  Text('logo'.tr(), style: TextStyles.logo()),
                ]
              ),
              SizedBox(height: 47),
              Row(mainAxisAlignment: MainAxisAlignment.start, children: [Text('login.inputToken'.tr(), style: TextStyles.title())]),
              SizedBox(height: 42),
              Container(
                child: PinCodeTextField(
                  appContext: context,
                  length: 6,
                  obscureText: false,
                  obscuringCharacter: '*',
                  animationType: AnimationType.fade,
                  pinTheme: PinTheme(
                    shape: PinCodeFieldShape.box,
                    borderRadius: BorderRadius.circular(5),
                    borderWidth: 0,
                    selectedFillColor: Colors.white,
                    fieldHeight: 40,
                    fieldWidth: 30,
                    inactiveFillColor: Colors.white,
                    inactiveColor: Colors.black45,
                    activeFillColor:
                        hasError.value ? Colors.orange : Colors.white,
                  ),
                  cursorColor: Colors.black,
                  animationDuration: Duration(milliseconds: 300),
                  textStyle: TextStyle(fontSize: 20, height: 1.6),
                  backgroundColor: background,
                  enableActiveFill: true,
                  controller: textEditingController,
                  keyboardType: TextInputType.number,
                  boxShadows: [
                    BoxShadow(
                      offset: Offset(0, 1),
                      color: Colors.black12,
                      blurRadius: 10,
                    )
                  ],
                  onCompleted: (v) {
                    BlocProvider.of<AuthBloc>(context).add(AuthenticateWithToken(token: token.value));
                  },
                  onChanged: (value) {
                    token.value = value;
                  },
                  beforeTextPaste: (text) {
                    return false;
                  },
                ),
              )
            ],
          ),
        ),
      ),
    );
  }
}
