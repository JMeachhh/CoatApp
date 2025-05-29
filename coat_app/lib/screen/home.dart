import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:do_i_need_a_coat/styles/button.dart';
import 'package:http/http.dart' as http;
import 'package:intl/intl.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';

class AppWeather {
  final DateTime date;
  final double? feelsLikeTemp;
  final String? description;

  AppWeather({
    required this.date,
    this.feelsLikeTemp,
    this.description,
  });

  factory AppWeather.fromJson(Map<String, dynamic> json) {
    return AppWeather(
      date: DateTime.parse(json['dt_txt']),
      feelsLikeTemp: (json['main']['feels_like'] as num).toDouble(),
      description: json['weather'][0]['description'],
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

Color darken(Color color, [double amount = 0.2]) {
  final hsl = HSLColor.fromColor(color);
  final hslDark = hsl.withLightness((hsl.lightness - amount).clamp(0.0, 1.0));
  return hslDark.toColor();
}

class _HomeScreenState extends State<HomeScreen> {
  final apiKey = dotenv.env['OPENWEATHER_API_KEY'] ?? '';
  int selectedIndex = 0;
  List<AppWeather> _forecast = [];
  double _coatThreshold = 12.0;

  late BannerAd _bannerAd;
  bool _isBannerAdReady = false;

  @override
  void initState() {
    super.initState();

    _fetchFiveDayForecast(widget.latitude, widget.longitude);

    // Initialize Banner Ad
    _bannerAd = BannerAd(
      adUnitId: dotenv.env['BANNER_AD_UNIT_ID'] ?? '<YOUR_BANNER_AD_UNIT_ID>',
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) {
            setState(() {
              _isBannerAdReady = true;
            });
          }
        },
        onAdFailedToLoad: (ad, err) {
          debugPrint('Failed to load a banner ad: ${err.message}');
          ad.dispose();
        },
      ),
    );

    _bannerAd.load();
  }

  @override
  void dispose() {
    _bannerAd.dispose();
    super.dispose();
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
          setState(() {
            _forecast = forecastList
                .map<AppWeather>((item) => AppWeather.fromJson(item))
                .where((weather) => weather.date.hour == 12)
                .toList();
          });
        }
      } else {
        _showError(
            'Failed to load forecast. Status code: ${response.statusCode}');
      }
    } catch (e) {
      if (mounted) _showError('Error fetching forecast: $e');
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(message)));
  }

  @override
  Widget build(BuildContext context) {
    double topPadding = MediaQuery.of(context).padding.top;
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double widgetSize = screenWidth * 0.8;
    double barHeight = screenHeight * 0.09;
    double barLocation = topPadding + screenHeight * 0.50;
    double widgetLocation = topPadding + screenHeight * 0.07;

    Color widgetColor = const Color.fromARGB(255, 226, 239, 255);
    Color shadowColor = darken(widget.backgroundColor);
    double buttonSize = barHeight * 0.7;

    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: Stack(
        children: [
          Positioned(
            top: widgetLocation,
            left: (screenWidth - widgetSize) / 2,
            child: Container(
              decoration: _boxDecoration(shadowColor),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: widgetSize,
                  height: widgetSize,
                  color: widgetColor,
                  child: Stack(
                    alignment: Alignment.center,
                    children: [
                      const Image(
                          image: AssetImage('assets/wardrobe_with_clock.jpg')),
                      const Image(image: AssetImage('assets/plant.png')),
                      const Image(image: AssetImage('assets/football.png')),
                      const Image(
                          image: AssetImage('assets/blue_shoe_box.png')),
                      Image(image: AssetImage(dayDisplay(selectedIndex))),
                      Image(image: AssetImage(coatDisplay(selectedIndex))),
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
              decoration: _boxDecoration(shadowColor),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  width: widgetSize,
                  height: barHeight,
                  color: widgetColor,
                ),
              ),
            ),
          ),
          Positioned(
            top: barLocation + barHeight / 6.7,
            left: ((screenWidth - widgetSize) / 2) + 10,
            child: Row(
              children: List.generate(
                5,
                (i) => Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 4),
                  child: gradientButton(
                    buttonSize,
                    () => setState(() => selectedIndex = i),
                    setDay(i),
                    i == selectedIndex,
                    i,
                  ),
                ),
              ),
            ),
          ),

          Positioned(
            bottom: screenHeight - screenHeight / 1.1,
            left: (screenWidth - _bannerAd.size.width.toDouble()) / 2,
            width: widgetSize,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Center(
                  child: Text(
                    'Too Warm For A Coat: ${_coatThreshold.toStringAsFixed(1)}°C',
                    style: const TextStyle(
                      fontSize: 16,
                      color: Colors.white,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ),
                Slider(
                  value: _coatThreshold,
                  min: -5,
                  max: 25,
                  divisions: 60,
                  label: '${_coatThreshold.toStringAsFixed(1)}°C',
                  activeColor: Colors.blueAccent,
                  inactiveColor: Colors.blueGrey[200],
                  onChanged: (value) {
                    setState(() {
                      _coatThreshold = value;
                    });
                  },
                ),
              ],
            ),
          ),

          // Banner Ad positioned at the bottom center
          if (_isBannerAdReady)
            Positioned(
              bottom: 0,
              left: (screenWidth - _bannerAd.size.width.toDouble()) / 2,
              width: _bannerAd.size.width.toDouble(),
              height: _bannerAd.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd),
            ),
        ],
      ),
    );
  }

  BoxDecoration _boxDecoration(Color shadowColor) => BoxDecoration(
        borderRadius: BorderRadius.circular(15),
        boxShadow: [
          BoxShadow(
            color: shadowColor,
            offset: Offset(0, 0),
            blurRadius: 15,
            spreadRadius: 1,
          )
        ],
      );

  String coatDisplay(int index) {
    if (_forecast.isEmpty || index >= _forecast.length) {
      return 'assets/football.png';
    }
    final forecast = _forecast[index];
    final temp = forecast.feelsLikeTemp;
    final desc = forecast.description?.toLowerCase() ?? '';

    print(temp);

    if (temp == null || temp >= _coatThreshold) {
      return desc.contains('rain') || desc.contains('drizzle')
          ? 'assets/green_coat_rain.png'
          : 'assets/red_coat.png';
    } else {
      return 'assets/green_coat_cold.png';
    }
  }

  String setDay(int index) => DateFormat('EEEE')
      .format(DateTime.now().add(Duration(days: index)))
      .substring(0, 3)
      .toUpperCase();

  String dayDisplay(int index) {
    switch (setDay(index)) {
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
      default:
        return '';
    }
  }
}
