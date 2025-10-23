import 'package:flutter/material.dart';
import 'weather_service.dart'; // Import our service

void main() {
  runApp(const MainApp());
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    return const MaterialApp(
      debugShowCheckedModeBanner: false, // Hides the little "debug" banner
      home: WeatherPage(), // Our new stateful widget
    );
  }
}

// --- This is our new StatefulWidget ---

class WeatherPage extends StatefulWidget {
  const WeatherPage({super.key});

  @override
  State<WeatherPage> createState() => _WeatherPageState();
}

class _WeatherPageState extends State<WeatherPage> {
  
  // --- 1. State Variables ---
  final WeatherService _weatherService = WeatherService();
  Map<String, dynamic>? _weatherData; // Holds the weather data (or null)
  bool _isLoading = true; // True when we are fetching data
  String? _errorMessage; // Holds any error message (or null)

  // --- 2. initState and Fetch Function ---
  // This function runs ONCE when the widget is first created
  @override
  void initState() {
    super.initState();
    _fetchWeather(); // Start fetching weather immediately
  }

  // This is our function from the previous step
  void _fetchWeather() async {
    try {
      final weatherData = await _weatherService.fetchWeatherForCurrentLocation();
      
      // We got the data, now update the state and stop loading
      setState(() {
        _weatherData = weatherData;
        _isLoading = false;
        _errorMessage = null;
      });
      
      // Also print to console just to confirm
      print("--- UI: Weather data loaded successfully ---");
      print(_weatherData!['name']);
      
    } catch (e) {
      // An error occurred, update the state with the error message
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
      print("--- ERROR FETCHING WEATHER ---");
      print(e);
    }
  }

  // --- 3. Build Method ---
  // This function runs every time setState() is called
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: _buildWeatherUI(), // Use a helper function to build the UI
      ),
    );
  }

  // --- 4. UI Helper Function ---
  // This function decides what to show on the screen
  Widget _buildWeatherUI() {
    
    // If we are still loading, show a loading circle
    if (_isLoading) {
      return const CircularProgressIndicator();
    }
    
    // If there was an error, show the error message
    else if (_errorMessage != null) {
      return Text(
        'Error: $_errorMessage',
        style: const TextStyle(color: Colors.red, fontSize: 16),
        textAlign: TextAlign.center,
      );
    }
    
    // If we have data, show the weather!
    else if (_weatherData != null) {
      // This is the data we'll make aesthetic later
      final cityName = _weatherData!['name'];
      final temperature = _weatherData!['main']['temp'];

      return Column(
        mainAxisSize: MainAxisSize.min, // Make the column wrap its content
        children: [
          // City Name
          Text(
            cityName,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
          
          const SizedBox(height: 10),

          // Temperature
          Text(
            '${temperature.toStringAsFixed(1)}°C', // Format to one decimal place
            style: const TextStyle(fontSize: 48),
          ),
        ],
      );
    }
    
    // Default fallback (shouldn't be reached)
    else {
      return const Text('No weather data to display.');
    }
  }
}