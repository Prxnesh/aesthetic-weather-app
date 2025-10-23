// Imports we'll need to talk to the web and decode the data
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherService {
  // This is the base URL for the OpenWeatherMap API
  static const _baseUrl = 'https://api.openweathermap.org/data/2.5/weather';
  
  // --- PASTE YOUR API KEY HERE ---
  final String _apiKey = '4f5cf074c1df644426fde2b144781839';

  // This is the main function that will fetch the weather
  // It's "async" because it needs to wait for the server's response
  Future<Map<String, dynamic>> fetchWeather(String cityName) async {
    
    // This builds the final URL we'll be requesting.
    // We're asking for the city, using our key, and specifying 'metric' units (Celsius)
    final uri = Uri.parse('$_baseUrl?q=$cityName&appid=$_apiKey&units=metric');
    
    // We 'await' for the http package to get the response from the server
    final response = await http.get(uri);

    // If the server responds with '200' (meaning 'OK')
    if (response.statusCode == 200) {
      // We decode the JSON response body into a Dart Map
      return jsonDecode(response.body);
    } else {
      // If the server sends anything else (like '404' Not Found), we throw an error
      throw Exception('Failed to load weather data. Status code: ${response.statusCode}');
    }
  }
}