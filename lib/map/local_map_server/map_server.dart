import 'package:flutter/foundation.dart';
import 'package:shelf_router/shelf_router.dart';
import 'package:shelf/shelf.dart';
import 'package:http/http.dart' as http;

class Service {
  Service({
    @required this.mapboxApiKey,
  }) : assert(mapboxApiKey != null);

  final String mapboxApiKey;

  Handler get handler {
    final router = Router();

    router.get('/tiles/<z>/<x>/<y>', (Request request, String z, String x, String y) async {
      var response = await http.Client().send(
        http.Request(
          'GET',
          Uri.parse('https://api.mapbox.com/styles/v1/mapbox/streets-v11/tiles/$z/$x/$y@2x?access_token=$mapboxApiKey')
        )
      );

      return Response(response.statusCode, body: response.stream, headers: response.headers);
    });

    // You can catch all verbs and use a URL-parameter with a regular expression
    // that matches everything to catch app.
    router.all('/<ignored|.*>', (Request request) {
      return Response.notFound('Page not found');
    });

    return router;
  }
}
