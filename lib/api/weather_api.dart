import 'package:dio/dio.dart';
import 'package:retrofit/retrofit.dart';
import 'package:weather_app/models/weather.dart';
import '../models/forecast_response.dart';

part 'weather_api.g.dart';

@RestApi(baseUrl: "https://api.openweathermap.org/data/2.5/")
abstract class WeatherApi {
  factory WeatherApi(Dio dio, {String baseUrl}) = _WeatherApi;

  //  météo actuelle par nom de ville
  @GET("weather")
  Future<Weather> getWeather(
      @Query("q") String city,
      @Query("appid") String apiKey,
      @Query("units") String units,
      );

  //  Météo actuelle par coordonnées
  @GET("weather")
  Future<Weather> getWeatherByCoords(
      @Query("lat") double lat,
      @Query("lon") double lon,
      @Query("appid") String apiKey,
      @Query("units") String units,
      @Query("lang") String lang,
      );

  //  Prévisions 5 jours par nom de ville
  @GET("forecast")
  Future<ForecastResponse> getForecast(
      @Query("q") String city,
      @Query("appid") String apiKey,
      @Query("units") String units,
      @Query("lang") String lang,
      );

  // Prévisions 5 jours par coordonnées
  @GET("forecast")
  Future<ForecastResponse> getForecastByCoords(
      @Query("lat") double lat,
      @Query("lon") double lon,
      @Query("appid") String apiKey,
      @Query("units") String units,
      @Query("lang") String lang,
      );
}