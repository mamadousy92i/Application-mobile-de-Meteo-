import '../models/weather.dart';
import '../models/coord.dart';
import '../models/clouds.dart';
import '../models/main_weather.dart';
import '../models/sys.dart';
import '../models/wind.dart';
import '../models/weather_element.dart';

// Liste de villes avec différentes conditions météo
final List<Weather> mockCities = [
  // Dakar - Ensoleillé et chaud
  Weather(
    coord: Coord(lon: -17.45, lat: 14.69),
    weather: [
      WeatherElement(
        id: 800,
        main: "Clear",
        description: "ciel dégagé",
        icon: "01d",
      ),
    ],
    base: "stations",
    main: Main(
      temp: 32.0,
      feelsLike: 35.1,
      tempMin: 28.0,
      tempMax: 36.0,
      pressure: 1013,
      humidity: 45,
      seaLevel: 1013,
      grndLevel: 1009,
    ),
    visibility: 10000,
    wind: Wind(speed: 3.2, deg: 210),
    clouds: Clouds(all: 0),
    dt: 1657190400,
    sys: Sys(
      type: 1,
      id: 1234,
      country: "SN",
      sunrise: 1657156789,
      sunset: 1657203456,
    ),
    timezone: 0,
    id: 2253354,
    name: "Dakar",
    cod: 200,
  ),

  // Paris - Nuageux et frais
  Weather(
    coord: Coord(lon: 2.35, lat: 48.85),
    weather: [
      WeatherElement(
        id: 803,
        main: "Clouds",
        description: "nuageux",
        icon: "04d",
      ),
    ],
    base: "stations",
    main: Main(
      temp: 15.5,
      feelsLike: 14.2,
      tempMin: 12.0,
      tempMax: 18.0,
      pressure: 1018,
      humidity: 72,
      seaLevel: 1018,
      grndLevel: 1015,
    ),
    visibility: 8000,
    wind: Wind(speed: 6.8, deg: 270),
    clouds: Clouds(all: 75),
    dt: 1657190400,
    sys: Sys(
      type: 1,
      id: 5615,
      country: "FR",
      sunrise: 1657165234,
      sunset: 1657218976,
    ),
    timezone: 7200,
    id: 2988507,
    name: "Paris",
    cod: 200,
  ),

  // Moscou - Neige et très froid
  Weather(
    coord: Coord(lon: 37.62, lat: 55.75),
    weather: [
      WeatherElement(
        id: 601,
        main: "Snow",
        description: "neige",
        icon: "13d",
      ),
    ],
    base: "stations",
    main: Main(
      temp: -8.0,
      feelsLike: -12.5,
      tempMin: -12.0,
      tempMax: -5.0,
      pressure: 1025,
      humidity: 85,
      seaLevel: 1025,
      grndLevel: 1022,
    ),
    visibility: 2000,
    wind: Wind(speed: 8.2, deg: 45),
    clouds: Clouds(all: 90),
    dt: 1657190400,
    sys: Sys(
      type: 1,
      id: 9029,
      country: "RU",
      sunrise: 1657172345,
      sunset: 1657201234,
    ),
    timezone: 10800,
    id: 524901,
    name: "Moscou",
    cod: 200,
  ),

  // Dubai - Très chaud et ensoleillé
  Weather(
    coord: Coord(lon: 55.33, lat: 25.26),
    weather: [
      WeatherElement(
        id: 800,
        main: "Clear",
        description: "ciel dégagé",
        icon: "01d",
      ),
    ],
    base: "stations",
    main: Main(
      temp: 42.0,
      feelsLike: 48.5,
      tempMin: 38.0,
      tempMax: 45.0,
      pressure: 1008,
      humidity: 35,
      seaLevel: 1008,
      grndLevel: 1005,
    ),
    visibility: 10000,
    wind: Wind(speed: 2.1, deg: 180),
    clouds: Clouds(all: 0),
    dt: 1657190400,
    sys: Sys(
      type: 1,
      id: 1598,
      country: "AE",
      sunrise: 1657154678,
      sunset: 1657201345,
    ),
    timezone: 14400,
    id: 292223,
    name: "Dubai",
    cod: 200,
  ),

  // Londres - Pluvieux et gris
  Weather(
    coord: Coord(lon: -0.13, lat: 51.51),
    weather: [
      WeatherElement(
        id: 500,
        main: "Rain",
        description: "pluie légère",
        icon: "10d",
      ),
    ],
    base: "stations",
    main: Main(
      temp: 12.0,
      feelsLike: 10.8,
      tempMin: 9.0,
      tempMax: 15.0,
      pressure: 1012,
      humidity: 88,
      seaLevel: 1012,
      grndLevel: 1009,
    ),
    visibility: 6000,
    wind: Wind(speed: 4.7, deg: 225),
    clouds: Clouds(all: 85),
    dt: 1657190400,
    sys: Sys(
      type: 1,
      id: 1414,
      country: "GB",
      sunrise: 1657167890,
      sunset: 1657223456,
    ),
    timezone: 3600,
    id: 2643743,
    name: "Londres",
    cod: 200,
  ),Weather(
    coord: Coord(lon: -0.13, lat: 51.51),
    weather: [
      WeatherElement(
        id: 500,
        main: "Rain",
        description: "pluie légère",
        icon: "10d",
      ),
    ],
    base: "stations",
    main: Main(
      temp: 12.0,
      feelsLike: 10.8,
      tempMin: 9.0,
      tempMax: 15.0,
      pressure: 1012,
      humidity: 88,
      seaLevel: 1012,
      grndLevel: 1009,
    ),
    visibility: 6000,
    wind: Wind(speed: 4.7, deg: 225),
    clouds: Clouds(all: 85),
    dt: 1657190400,
    sys: Sys(
      type: 1,
      id: 1414,
      country: "GB",
      sunrise: 1657167890,
      sunset: 1657223456,
    ),
    timezone: 3600,
    id: 2643743,
    name: "Londres",
    cod: 200,
  ),

];