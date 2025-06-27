import 'package:json_annotation/json_annotation.dart';

part 'main_weather.g.dart';

@JsonSerializable()
class Main {
  double temp;
  @JsonKey(name: 'feels_like')
  double feelsLike;
  @JsonKey(name: 'temp_min')
  double tempMin;
  @JsonKey(name: 'temp_max')
  double tempMax;
  int pressure;
  int humidity;
  @JsonKey(name: 'sea_level')
  int seaLevel;
  @JsonKey(name: 'grnd_level')
  int grndLevel;

  Main({
    required this.temp,
    required this.feelsLike,
    required this.tempMin,
    required this.tempMax,
    required this.pressure,
    required this.humidity,
    required this.seaLevel,
    required this.grndLevel,
  });

  factory Main.fromJson(Map<String, dynamic> json) => _$MainFromJson(json);
  Map<String, dynamic> toJson() => _$MainToJson(this);
}
