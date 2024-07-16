import 'dart:convert';
import 'dart:developer';
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';
import 'package:http/http.dart' as http;
import 'package:weather_app/models/weather_model.dart';

class WeatherService {
  static const BASE_URL = 'https://api.openweathermap.org/data/2.5/weather';
  final String apikey;
  Weather? _cachedWeather;
  String? _cachedCity;

  WeatherService(this.apikey);

  // Added caching and timeout to the HTTP request
  Future<Weather> getWeather(String cityName) async {
    if (_cachedCity == cityName && _cachedWeather != null) {
      log('Returning cached weather for $cityName');
      return _cachedWeather!;
    }

    try {
      final url = '$BASE_URL?q=$cityName&appid=$apikey';
      log('Fetching weather from: $url');

      final response = await http.get(Uri.parse(url)).timeout(const Duration(seconds: 10));

      if (response.statusCode == 200) {
        final weather = Weather.fromJson(jsonDecode(response.body));
        _cachedCity = cityName;
        _cachedWeather = weather;
        return weather;
      } else {
        log('Failed to load weather data: ${response.statusCode}');
        throw Exception('Failed to load weather data');
      }
    } catch (e) {
      log('Error fetching weather data: $e');
      throw Exception('Failed to load weather data: $e');
    }
  }

  // Get current city based on the user's location
  Future<String> getCurrentCity() async {
    try {
      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
      }

      Position position = await Geolocator.getCurrentPosition(desiredAccuracy: LocationAccuracy.high);
      log('Position: ${position.latitude}, ${position.longitude}');

      List<Placemark> placemarks = await placemarkFromCoordinates(position.latitude, position.longitude);
      log('Placemarks: $placemarks');

      String? city = placemarks[0].locality;
      return city ?? "";
    } catch (e) {
      log('Error: $e');
      throw e;
    }
  }
}
