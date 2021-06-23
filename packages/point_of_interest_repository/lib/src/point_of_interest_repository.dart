import 'package:json_annotation/json_annotation.dart';
import 'package:retrofit/retrofit.dart';
import 'package:dio/dio.dart';

part 'point_of_interest_repository.g.dart';

@RestApi(baseUrl: 'https://api.sailmate.fi')
abstract class PointOfInterestRepository {
  factory PointOfInterestRepository(Dio dio, {String baseUrl}) = _PointOfInterestRepository;

  @GET('/point_of_interests.json')
  Future<List<PointOfInterestWrapper>> getPointOfInterests();
}

@JsonSerializable()
class PointOfInterestWrapper {
  // ignore: non_constant_identifier_names
  PointOfInterest point_of_interest;
  // ignore: non_constant_identifier_names
  PointOfInterestWrapper({this.point_of_interest});

  factory PointOfInterestWrapper.fromJson(Map<String, dynamic> json) => _$PointOfInterestWrapperFromJson(json);
  Map<String, dynamic> toJson() => _$PointOfInterestWrapperToJson(this);
}

@JsonSerializable()
class PointOfInterest {
  int id;
  String name;
  double lat;
  double lon;
  String poi_type;
  bool is_scout_port;
  List<PointOfInterestProperty> point_of_interest_properties;

  PointOfInterest({this.id, this.name, this.lat, this.lon, this.poi_type, this.is_scout_port});

  factory PointOfInterest.fromJson(Map<String, dynamic> json) => _$PointOfInterestFromJson(json);
  Map<String, dynamic> toJson() => _$PointOfInterestToJson(this);
}

@JsonSerializable()
class PointOfInterestProperty {
  String key;
  dynamic value;

  PointOfInterestProperty({this.key, this.value});

  factory PointOfInterestProperty.fromJson(Map<String, dynamic> json) => _$PointOfInterestPropertyFromJson(json);
  Map<String, dynamic> toJson() => _$PointOfInterestPropertyToJson(this);
}
