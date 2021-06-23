import 'package:easy_localization/easy_localization.dart';
import 'package:hybrid_sailmate/app.dart';
import 'package:hybrid_sailmate/auth/bloc/auth_bloc.dart';
import 'package:hybrid_sailmate/map/bloc/map_bloc.dart';
import 'package:flutter/material.dart';
import 'package:config_repository/config_repository.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hybrid_sailmate/onboarding/onboarding.dart';
import 'package:point_of_interest_repository/point_of_interest_repository.dart';
import 'package:dio/dio.dart';
import 'package:shared_preferences/shared_preferences.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  var preferences = await SharedPreferences.getInstance();
  var isPassedOnBoarding = preferences.getBool('OnBoarding');

  var pointOfInterestRepository = PointOfInterestRepository(Dio());
  var authRepository = AuthRepository();
  var configRepository = ConfigRepository();

  runApp(
    EasyLocalization(
      supportedLocales: [Locale('en'), Locale('fi'), Locale('sv')],
      path: 'assets/translations',
      fallbackLocale: Locale('en'),
      child: MultiBlocProvider(
        providers: [
          BlocProvider<MapBloc>(create: (context) => MapBloc(pointOfInterestRepository: pointOfInterestRepository)),
          BlocProvider<AuthBloc>(create: (context) => AuthBloc(authRepository: authRepository))
        ],
        child: isPassedOnBoarding != null
          ? Sailmate(configRepository: configRepository)
          : GoOnBoarding(configRepository: configRepository)
      )
    )
  );
}

class Sailmate extends StatelessWidget {
  Sailmate({ @required this.configRepository }) : super();

  final ConfigRepository configRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      localizationsDelegates: context.localizationDelegates,
      supportedLocales: context.supportedLocales,
      locale: context.locale,
      home:App(configRepository: configRepository)
    );
  }
}

class GoOnBoarding extends StatelessWidget {
  GoOnBoarding({ @required this.configRepository }) : super();

  final ConfigRepository configRepository;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
        localizationsDelegates: context.localizationDelegates,
        supportedLocales: context.supportedLocales,
        locale: context.locale,
        home:OnBoarding(configRepository: configRepository)
    );
  }
}
