import 'package:json_annotation/json_annotation.dart';

part 'weather_element.g.dart';

@JsonSerializable()
class WeatherElement {
  int id;
  String main;
  String description;
  String icon;

  WeatherElement({
    required this.id,
    required this.main,
    required this.description,
    required this.icon,
  });

  factory WeatherElement.fromJson(Map<String, dynamic> json) => _$WeatherElementFromJson(json);
  Map<String, dynamic> toJson() => _$WeatherElementToJson(this);
}
