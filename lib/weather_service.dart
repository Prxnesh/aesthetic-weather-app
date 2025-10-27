import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:geolocator/geolocator.dart';
import 'package:geocoding/geocoding.dart';

class WeatherService {
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';

  // --- PASTE YOUR API KEY HERE ---
  final String _apiKey = '4f5cf074c1df644426fde2b144781839';

  // --- Main public function ---
  // This is the function main.dart is looking for!
  Future<Map<String, dynamic>> fetchWeatherForCurrentLocation() async {
    // 1. Get the user's current position
    final position = await _getCurrentPosition();

    // 2. Convert the position (lat, lon) into a city name
    final cityName = await _getCityFromPosition(position);

    // 3. Use the city name to fetch weather data
    return await fetchWeather(cityName);
  }

  // --- Fetches weather by city name ---
  Future<Map<String, dynamic>> fetchWeather(String cityName) async {
    final uri = Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey&units=metric');
    final response = await http.get(uri);

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to load weather data. Status code: ${response.statusCode}');
    }
  }

  // --- Private helper to get city from position ---
  Future<String> _getCityFromPosition(Position position) async {
    try {
      // Use the geocoding package to reverse geocode
      List<Placemark> placemarks = await placemarkFromCoordinates(
        position.latitude,
        position.longitude,
      );

      // The first placemark usually has the most details
      Placemark place = placemarks[0];

      // We'll return the 'locality' which is typically the city name
      return place.locality ?? 'Unknown';
    } catch (e) {
      print("Error getting city from coordinates: $e");
      return 'Unknown';
    }
  }

  // --- Private helper to get user's current position ---
  Future<Position> _getCurrentPosition() async {
    // 1. Check if location services are enabled
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    // 2. Check location permissions
    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      // If denied, request permission
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied.');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      // If permanently denied, we can't request again
      throw Exception('Location permissions are permanently denied, we cannot request permissions.');
    }

    // 3. If permissions are granted, get the current location
    return await Geolocator.getCurrentPosition(
      desiredAccuracy: LocationAccuracy.low, // 'low' is faster and fine for a city
    );
  }
}