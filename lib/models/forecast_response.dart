import 'package:json_annotation/json_annotation.dart';
import 'main_weather.dart';
import 'weather_element.dart';
import 'clouds.dart';
import 'wind.dart';

part 'forecast_response.g.dart';

@JsonSerializable()
class ForecastResponse {
  final String cod;
  final int message;
  final int cnt;
  final List<ForecastItem> list;
  final CityInfo city;

  ForecastResponse({
    required this.cod,
    required this.message,
    required this.cnt,
    required this.list,
    required this.city,
  });

  factory ForecastResponse.fromJson(Map<String, dynamic> json) =>
      _$ForecastResponseFromJson(json);
  Map<String, dynamic> toJson() => _$ForecastResponseToJson(this);
}

@JsonSerializable()
class ForecastItem {
  final int dt;
  @JsonKey(name: 'dt_txt')
  final String dtTxt;
  final Main main;
  final List<WeatherElement> weather;
  final Clouds clouds;
  final Wind wind;
  final int visibility;
  @JsonKey(name: 'pop')
  final double probabilityOfPrecipitation;
  @JsonKey(name: 'sys')
  final ForecastSys? sys;

  ForecastItem({
    required this.dt,
    required this.dtTxt,
    required this.main,
    required this.weather,
    required this.clouds,
    required this.wind,
    required this.visibility,
    required this.probabilityOfPrecipitation,
    this.sys,
  });

  factory ForecastItem.fromJson(Map<String, dynamic> json) =>
      _$ForecastItemFromJson(json);
  Map<String, dynamic> toJson() => _$ForecastItemToJson(this);
}

@JsonSerializable()
class CityInfo {
  final int id;
  final String name;
  final Coord coord;
  final String country;
  final int population;
  final int timezone;
  final int sunrise;
  final int sunset;

  CityInfo({
    required this.id,
    required this.name,
    required this.coord,
    required this.country,
    required this.population,
    required this.timezone,
    required this.sunrise,
    required this.sunset,
  });

  factory CityInfo.fromJson(Map<String, dynamic> json) =>
      _$CityInfoFromJson(json);
  Map<String, dynamic> toJson() => _$CityInfoToJson(this);
}

@JsonSerializable()
class Coord {
  final double lat;
  final double lon;

  Coord({
    required this.lat,
    required this.lon,
  });

  factory Coord.fromJson(Map<String, dynamic> json) =>
      _$CoordFromJson(json);
  Map<String, dynamic> toJson() => _$CoordToJson(this);
}

@JsonSerializable()
class ForecastSys {
  final String pod; // part of day (d/n)

  ForecastSys({
    required this.pod,
  });

  factory ForecastSys.fromJson(Map<String, dynamic> json) =>
      _$ForecastSysFromJson(json);
  Map<String, dynamic> toJson() => _$ForecastSysToJson(this);
}