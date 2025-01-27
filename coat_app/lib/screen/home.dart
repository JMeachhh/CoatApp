import 'dart:convert';
import 'dart:ffi';

import 'package:do_i_need_a_coat/consts.dart';
import 'package:flutter/material.dart';
import 'package:do_i_need_a_coat/screen/settings.dart';
import 'package:do_i_need_a_coat/styles/button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:weather/weather.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

class AppWeather {
  final DateTime date;
  final double? dayTemp;
  final double? minTemp;
  final double? maxTemp;
  final double? feelsLikeTemp;
  final String? description;
  final String? icon;

  AppWeather({
    required this.date,
    this.dayTemp,
    this.minTemp,
    this.maxTemp,
    this.feelsLikeTemp,
    this.description,
    this.icon,
  });

  factory AppWeather.fromJson(Map<String, dynamic> json) {
    return AppWeather(
      date: DateTime.parse(json['dt_txt']),
      dayTemp: (json['main']['temp'] as num).toDouble(),
      minTemp: (json['main']['temp_min'] as num).toDouble(),
      maxTemp: (json['main']['temp_max'] as num).toDouble(),
      feelsLikeTemp: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'],
      icon: json['weather'][0]['icon'],
    );
  }
}

class HomeScreen extends StatefulWidget {
  final Color backgroundColor;
  double latitude;
  double longitude;

  HomeScreen({
    super.key,
    required this.backgroundColor,
    required this.latitude,
    required this.longitude,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

// function from stackOverflow which darkens when amount is closer to 0.
Color darken(Color color, [double amount = 0.2]) {
  assert(amount >= 0 && amount <= 1);

  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));

  return hslDark.toColor();
}

class _HomeScreenState extends State<HomeScreen> {
  final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';

  int selectedIndex = 0;

  List<AppWeather> _forecast = [];

  @override
  void initState() {
    super.initState();
    // Use the latitude and longitude passed from SettingsScreen
    _fetchFiveDayForecast(widget.latitude, widget.longitude);
  }

  void _fetchFiveDayForecast(double latitude, double longitude) async {
    final url = 'https://api.openweathermap.org/data/2.5/forecast'
        '?lat=${widget.latitude}&lon=${widget.longitude}&units=metric&appid=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        final forecastList = data['list'] as List;

        if (mounted) {
          // Ensure widget is still mounted
          setState(() {
            _forecast = forecastList
                .map<AppWeather>((item) => AppWeather.fromJson(item))
                .where((weather) => weather.date.hour == 12)
                .toList();
          });
        }
      } else {
        _showError(
            'Failed to load forecast. Status code: ${response.statusCode}, ${response.body}');
      }
    } catch (e) {
      if (mounted) {
        // Ensure widget is still mounted
        _showError('Error fetching forecast: $e');
      }
    }
  }

  void _showError(String message) {
    print(message);
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  void updateLocation(String location, double latitude, double longitude) {
    setState(() {
      widget.latitude = latitude; // Update latitude
      widget.longitude = longitude; // Update longitude
    });
    _fetchFiveDayForecast(
        latitude, longitude); // Fetch weather for new location
  }

  @override
  Widget build(BuildContext context) {
    double topPadd = MediaQuery.of(context).padding.top;
    Color widgetColor = const Color.fromARGB(255, 226, 239, 255);

    Color shadowColor = darken(widget.backgroundColor);

    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double widgetSize = screenWidth * 0.8;
    double barHeight = screenHeight * 0.09;

    double buttonSize = barHeight * 0.7;

    double barLocation = topPadd + screenHeight * 0.50;
    double widgetLocation = topPadd + screenHeight * 0.07;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          Container(
            color: widget.backgroundColor,
          ),
          Positioned(
            top: widgetLocation,
            left: (screenWidth - widgetSize) / 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: shadowColor,
                      offset: Offset(0, 0),
                      blurRadius: 15,
                      spreadRadius: 1)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: widgetSize,
                  height: widgetSize,
                  color: widgetColor,
                  child: Stack(
                    alignment: Alignment(0, 0),
                    children: [
                      const Image(
                        image: AssetImage('assets/wardrobe_with_clock.jpg'),
                      ),
                      const Image(
                        image: AssetImage('assets/plant.png'),
                      ),
                      const Image(
                        image: AssetImage('assets/football.png'),
                      ),
                      const Image(
                        image: AssetImage('assets/blue_shoe_box.png'),
                      ),
                      Image(
                        image: AssetImage(dayDisplay(selectedIndex)),
                      ),
                      Image(
                        image: AssetImage(coatDisplay(selectedIndex)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: barLocation,
            left: (screenWidth - widgetSize) / 2,
            child: Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(15),
                boxShadow: [
                  BoxShadow(
                      color: shadowColor,
                      offset: Offset(0, 0),
                      blurRadius: 15,
                      spreadRadius: 1)
                ],
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: widgetSize,
                  height: barHeight,
                  color: widgetColor,
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [],
                  ),
                ),
              ),
            ),
          ),
          Positioned(
            top: (barLocation) + barHeight / 6.7,
            left: ((screenWidth - widgetSize) / 2) + 10,
            child: Row(
              children: [
                for (int i = 0; i < 5; i++)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 4),
                    child: gradientButton(buttonSize, () => onPressed(i),
                        setDay(i), isButtonSelected(i, selectedIndex), i),
                  ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  String coatDisplay(int selectedIndex) {
    if (_forecast.isEmpty || selectedIndex >= _forecast.length) {
      return 'assets/football.png';
    }

    final AppWeather selectedDay = _forecast[selectedIndex];
    final double? feelsLikeCelsius = selectedDay.feelsLikeTemp;
    final String? description = selectedDay.description?.toLowerCase();

    if (feelsLikeCelsius == null || feelsLikeCelsius >= 12) {
      if (description != null &&
          (description.contains('rain') || description.contains('drizzle'))) {
        print("It's raining. You need a coat.");
        return 'assets/green_coat_rain.png';
      }
      print("No coat needed. Temp is: $feelsLikeCelsius°C");
      return 'assets/red_coat.png';
    } else {
      print("Coat needed. Temp is: $feelsLikeCelsius°C");
      return 'assets/green_coat_cold.png';
    }
  }

  String setDay(int index) {
    final day = DateTime.now().add(Duration(days: index));
    return DateFormat('EEEE').format(day).substring(0, 3).toUpperCase();
  }

  bool isButtonSelected(int index, int selectedIndex) {
    return (index == selectedIndex);
  }

  void onPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
  }

  String dayDisplay(int selecteIndex) {
    switch (setDay(selecteIndex)) {
      case 'MON':
        return 'assets/monday_clock_display.png';
      case 'TUE':
        return 'assets/tuesday_clock_display.png';
      case 'WED':
        return 'assets/wednesday_clock_display.png';
      case 'THU':
        return 'assets/thursday_clock_display.png';
      case 'FRI':
        return 'assets/friday_clock_display.png';
      case 'SAT':
        return 'assets/saturday_clock_display.png';
      case 'SUN':
        return 'assets/sunday_clock_display.png';
    }
    return '';
  }
}
