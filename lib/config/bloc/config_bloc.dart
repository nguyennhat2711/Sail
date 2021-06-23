import 'dart:io';

import 'package:bloc/bloc.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:meta/meta.dart';
import 'package:config_repository/config_repository.dart';

import 'package:hybrid_sailmate/map/local_map_server/map_server.dart';
import 'package:shelf/shelf_io.dart' as shelf_io;

class ConfigBloc extends Cubit<MapConfig> {
  ConfigBloc({
    @required ConfigRepository configRepository,
  }) : _configRepository = configRepository,
  super(null);

  final ConfigRepository _configRepository;

  HttpServer _server;

  void _startLocalMapServer(String mapboxApiKey) async {
    if (_server == null) {
      final service = Service(mapboxApiKey: mapboxApiKey);
      _server = await shelf_io.serve(service.handler, '0.0.0.0', 8080);
      print('server is running: ${_server.port}');
    }
  }

  void _stopLocalMapServer() async {
    await _server.close(force: true);
    _server = null;
  }

  Future<void> init() async {
    var config = await _configRepository.getMapboxConfig();
    SystemChannels.lifecycle.setMessageHandler((msg) async {
      if (msg == 'AppLifecycleState.paused') {
        await _stopLocalMapServer();
      } else if (msg == 'AppLifecycleState.resumed') {
        await _startLocalMapServer(config.mapboxApiKey);
      }

      return msg;
    });
    await _startLocalMapServer(config.mapboxApiKey);
    emit(config);
  }
}
