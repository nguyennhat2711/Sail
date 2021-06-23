import 'package:config_repository/config_repository.dart';
import 'package:flutter/material.dart';
import 'package:easy_localization/easy_localization.dart';
import 'package:hybrid_sailmate/app.dart';
import 'package:hybrid_sailmate/onboarding/model/model_onboarding.dart';
import 'package:hybrid_sailmate/widgets/text_styles.dart';
import 'package:shared_preferences/shared_preferences.dart';

class OnBoarding extends StatefulWidget {
  OnBoarding({ @required this.configRepository}) : super();

  final ConfigRepository configRepository;

  @override
  _OnBoardingState createState() => _OnBoardingState(configRepository: configRepository);
}

class _OnBoardingState extends State<OnBoarding> {
  _OnBoardingState({ @required this.configRepository }) : super();

  final ConfigRepository configRepository;

  List<OnBoardingModel> onboardingArr = [
    OnBoardingModel('onboarding.onboarding1.title'.tr(), 'onboarding.onboarding1.detail'.tr(), 'assets/images/onboarding1.png'),
    OnBoardingModel('onboarding.onboarding2.title'.tr(), 'onboarding.onboarding2.detail'.tr(), 'assets/images/onboarding2.png'),
    OnBoardingModel('onboarding.onboarding3.title'.tr(), 'onboarding.onboarding3.detail'.tr(), 'assets/images/onboarding3.png')
  ];

  int _current = 0;

  Widget _createOnboardingScreen(OnBoardingModel model, BuildContext context) {
    return Column(
      children: [
        Image(
          image: AssetImage(model.iamgeUrl),
          height: MediaQuery.of(context).size.height / 2.0 - 36.0,
          width: double.infinity,
          fit: BoxFit.fill,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SizedBox(height: 80,),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(model.title, style: TextStyles.onboardingtitle(),)
            ),
            SizedBox(height: 16.0,),
            Container(
                margin: EdgeInsets.symmetric(horizontal: 40.0),
                child: Text(model.desc, style: TextStyles.bottomSheetItemLabelGrey12(),)
            ),
          ],
        ),
      ],
    );
  }

  void _passedOnboarding(BuildContext context) async {
    var prefs = await SharedPreferences.getInstance();
    await prefs.setBool('OnBoarding', true);
    await Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => App(configRepository: configRepository)));
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      builder: (context, child) {
        return Scaffold(
          body: Stack(
            children: [
              PageView.builder(
                physics: ClampingScrollPhysics(),
                itemCount: onboardingArr.length,
                onPageChanged: (int pageIndex) {
                  print('current page index + ${_current}');
                  setState(() {
                    _current = pageIndex;
                  });
                },
                itemBuilder: (context, index) {
                  return _createOnboardingScreen(onboardingArr[index], context);
                },
              ),
              Center(
                child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: onboardingArr.map((url) {
                      var index = onboardingArr.indexOf(url);
                      return Container(
                        width: 8.0,
                        height: 8.0,
                        margin: EdgeInsets.symmetric(vertical: 10.0, horizontal: 2.0),
                        decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            color: _current == index ? mainBlue : mainBlue.withOpacity(0.2)
                        ),
                      );
                    }).toList()
                ),
              ),
              Positioned(
                bottom: 40.0,
                left: 40.0,
                right: 40.0,
                child: Container(
                  child: SizedBox(
                    height: 46.0,
                    child: RaisedButton(
                      onPressed: () => {
                        _passedOnboarding(context)
                      },
                      color: mainBlue,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.all(Radius.circular(8.0)),
                      ),
                      child: Text('Get started', style: TextStyles.buttonWhite(),),
                    ),
                  ),
                ),
              )
            ],
          ),
        );
      },
    );
  }
}

