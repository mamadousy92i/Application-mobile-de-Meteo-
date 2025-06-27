class DailyForecast {
  final DateTime date;
  final String dayName;
  final double tempMax;
  final double tempMin;
  final String description;
  final String icon;
  final int humidity;
  final double windSpeed;
  final double precipitationProbability;
  final int weatherId;
  final String weatherMain;

  DailyForecast({
    required this.date,
    required this.dayName,
    required this.tempMax,
    required this.tempMin,
    required this.description,
    required this.icon,
    required this.humidity,
    required this.windSpeed,
    this.precipitationProbability = 0.0,
    this.weatherId = 800,
    this.weatherMain = 'Clear',
  });

  // Méthode utilitaire pour obtenir le nom du jour en français
  static String getDayName(DateTime date) {
    final days = [
      'Lundi', 'Mardi', 'Mercredi', 'Jeudi',
      'Vendredi', 'Samedi', 'Dimanche'
    ];
    return days[date.weekday - 1];
  }

  // Méthode utilitaire pour obtenir le nom du jour court
  static String getShortDayName(DateTime date) {
    final shortDays = [
      'Lun', 'Mar', 'Mer', 'Jeu',
      'Ven', 'Sam', 'Dim'
    ];
    return shortDays[date.weekday - 1];
  }

  // Obtenir le nom du jour approprié selon la distance
  String get appropriateDayName {
    final now = DateTime.now();
    final difference = date.difference(now).inDays;

    if (difference == 0) return 'Aujourd\'hui';
    if (difference == 1) return 'Demain';

    return getShortDayName(date);
  }

  // Factory pour créer depuis l'API
  factory DailyForecast.fromApiData({
    required DateTime date,
    required double tempMax,
    required double tempMin,
    required String description,
    required String weatherMain,
    required int weatherId,
    required int humidity,
    required double windSpeed,
    double precipitationProbability = 0.0,
  }) {
    return DailyForecast(
      date: date,
      dayName: getShortDayName(date),
      tempMax: tempMax,
      tempMin: tempMin,
      description: description,
      icon: weatherMain.toLowerCase(),
      humidity: humidity,
      windSpeed: windSpeed,
      precipitationProbability: precipitationProbability,
      weatherId: weatherId,
      weatherMain: weatherMain,
    );
  }

  @override
  String toString() {
    return 'DailyForecast{date: $date, dayName: $dayName, tempMax: $tempMax, tempMin: $tempMin, description: $description}';
  }
}