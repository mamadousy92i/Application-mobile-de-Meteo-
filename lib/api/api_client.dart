import 'package:dio/dio.dart';
import 'weather_api.dart';

class ApiClient {
  static final Dio _dio = Dio();
  static final WeatherApi _weatherApi = WeatherApi(_dio);

  static WeatherApi get weatherApi => _weatherApi;
}