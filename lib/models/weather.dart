import 'package:json_annotation/json_annotation.dart';
import 'coord.dart';
import 'main_weather.dart';
import 'wind.dart';
import 'clouds.dart';
import 'sys.dart';
import 'weather_element.dart';

part 'weather.g.dart';

@JsonSerializable()
class Weather {
  Coord coord;
  List<WeatherElement> weather;
  String base;
  Main main;
  int visibility;
  Wind wind;
  Clouds clouds;
  int dt;
  Sys sys;
  int timezone;
  int id;
  String name;
  @JsonKey(includeFromJson: false, includeToJson: false)
  String? displayName; // Nom affiché depuis Nominatim
  int cod;

  Weather({
    required this.coord,
    required this.weather,
    required this.base,
    required this.main,
    required this.visibility,
    required this.wind,
    required this.clouds,
    required this.dt,
    required this.sys,
    required this.timezone,
    required this.id,
    required this.name,
    this.displayName,
    required this.cod,
  });

  factory Weather.fromJson(Map<String, dynamic> json, {String? displayName}) {
    final weather = _$WeatherFromJson(json);
    return weather.copyWith(displayName: displayName ?? json['name']);
  }

  Map<String, dynamic> toJson() => _$WeatherToJson(this);

  Weather copyWith({
    Coord? coord,
    List<WeatherElement>? weather,
    String? base,
    Main? main,
    int? visibility,
    Wind? wind,
    Clouds? clouds,
    int? dt,
    Sys? sys,
    int? timezone,
    int? id,
    String? name,
    String? displayName,
    int? cod,
  }) {
    return Weather(
      coord: coord ?? this.coord,
      weather: weather ?? this.weather,
      base: base ?? this.base,
      main: main ?? this.main,
      visibility: visibility ?? this.visibility,
      wind: wind ?? this.wind,
      clouds: clouds ?? this.clouds,
      dt: dt ?? this.dt,
      sys: sys ?? this.sys,
      timezone: timezone ?? this.timezone,
      id: id ?? this.id,
      name: name ?? this.name,
      displayName: displayName ?? this.displayName,
      cod: cod ?? this.cod,
    );
  }

  // Getter pour obtenir le nom à afficher
  String get displayNameOrName => displayName ?? name;
}