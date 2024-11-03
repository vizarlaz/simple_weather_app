import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class WeatherScreen extends StatefulWidget {
  const WeatherScreen({super.key});

  @override
  State<WeatherScreen> createState() => _WeatherScreenState();
}

class _WeatherScreenState extends State<WeatherScreen> {
  String city = 'Jakarta';
  Map<String, dynamic>? weatherData;

  Future<void> fetchWeather(String cityName) async {
    try {
      final locationUrl = Uri.parse(
          'https://www.metaweather.com/api/location/search/?query=$cityName');
      final locationResponse = await http.get(locationUrl);
      final locationData = json.decode(locationResponse.body);

      if (locationData.isNotEmpty) {
        final woeid = locationData[0]['woeid'];
        final weatherId =
            Uri.parse('https://www.metaweather.com/api/location/$woeid/');
        final weatherResponse = await http.get(weatherId);
        final weatherDataDecoded = json.decode(weatherResponse.body);

        setState(() {
          weatherData = weatherDataDecoded;
        });
      } else {
        setState(() {
          weatherData = null;
        });
      }
    } catch (e) {
      // ignore: avoid_print
      print("error: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    fetchWeather(city);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Cuaca Sederhana'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              decoration: const InputDecoration(
                labelText: 'Masukan nama kota',
              ),
              onSubmitted: (value) {
                setState(() {
                  city = value;
                });
                fetchWeather(value);
              },
            ),
            const SizedBox(
              height: 20,
            ),
            weatherData != null
                ? Column(
                    children: [
                      Text(
                        'Cuaca di ${weatherData!['title']}',
                        style: const TextStyle(
                            fontSize: 20, fontWeight: FontWeight.bold),
                      ),
                      Text(
                        'Suhu: ${weatherData!['consolidated_weather'][0]['the_temp'].toStringAsFixed(1)}°C',
                        style: const TextStyle(fontSize: 18),
                      ),
                      Text(
                        'Kondisi: ${weatherData!['consolidated_weather'][0]['weather_state_name']}',
                        style: const TextStyle(fontSize: 18),
                      ),
                    ],
                  )
                : const Text(
                    'data cuaca tidak ditemukan',
                    style: TextStyle(fontSize: 16),
                  ),
          ],
        ),
      ),
    );
  }
}
