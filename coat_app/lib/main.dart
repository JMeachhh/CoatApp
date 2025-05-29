import 'package:flutter/material.dart';
import 'package:do_i_need_a_coat/screen/home.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:geolocator/geolocator.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await dotenv.load(fileName: '.env');

  // Initialize Google Mobile Ads SDK
  MobileAds.instance.initialize();

  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  bool _didPreload = false;
  bool _isReady = false;

  double latitude = 0;
  double longitude = 0;

  @override
  void initState() {
    super.initState();
    _getInitialLocation();
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    if (!_didPreload) {
      _preloadAssets(context).then((_) {
        setState(() {
          _isReady = true;
        });
      });
      _didPreload = true;
    }
  }

  Future<void> _preloadAssets(BuildContext context) async {
    final imageAssets = [
      'assets/wardrobe_empty.jpg',
      'assets/football.png',
      'assets/blue_shoe_box.png',
      'assets/plant.png',
      'assets/monday_clock_display.png',
      'assets/tuesday_clock_display.png',
      'assets/wednesday_clock_display.png',
      'assets/thursday_clock_display.png',
      'assets/friday_clock_display.png',
      'assets/saturday_clock_display.png',
      'assets/sunday_clock_display.png',
      'assets/green_coat_rain.png',
      'assets/red_coat.png',
      'assets/green_coat_cold.png',
      'assets/wardrobe_with_clock.jpg',
    ];

    for (var asset in imageAssets) {
      await precacheImage(AssetImage(asset), context);
    }
  }

  Future<void> _getInitialLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        latitude = position.latitude;
        longitude = position.longitude;
      });

      _listenToLocationUpdates();
    } catch (e) {
      print('Error getting location: $e');
    }
  }

  void _listenToLocationUpdates() {
    const locationSettings = LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings).listen((Position pos) {
      setState(() {
        latitude = pos.latitude;
        longitude = pos.longitude;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    double screenHeight = MediaQuery.of(context).size.height;
    double fontSize = screenHeight * 0.05;

    Color backgroundColor = const Color.fromARGB(255, 37, 60, 87);
    Color appBarColor = const Color.fromARGB(255, 247, 247, 247);
    Color titleColor = const Color.fromARGB(255, 19, 101, 156);
    double toolbarHeight = screenHeight * 0.18;

    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: Scaffold(
        extendBodyBehindAppBar: true,
        appBar: PreferredSize(
          preferredSize: Size.fromHeight(toolbarHeight),
          child: Stack(
            children: [
              Positioned.fill(
                child: Container(
                  height: toolbarHeight,
                  decoration: BoxDecoration(
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.3),
                        blurRadius: 15,
                        spreadRadius: 1,
                        offset: Offset(0, -(screenHeight * 0.025)),
                      ),
                    ],
                  ),
                ),
              ),
              ClipPath(
                clipper: CloudClipper(),
                child: Container(
                  color: appBarColor,
                  height: toolbarHeight,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: ClipPath(
                  clipper: CloudClipper(),
                  child: Container(
                    color: Colors.transparent,
                    child: AppBar(
                      backgroundColor: appBarColor,
                      title: Text(
                        'Do I Need A Coat?',
                        style: TextStyle(
                          fontFamily: 'Adena',
                          fontSize: fontSize,
                          color: titleColor,
                        ),
                      ),
                      toolbarHeight: toolbarHeight,
                      centerTitle: true,
                      elevation: 0,
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
        body: (_isReady && latitude != 0 && longitude != 0)
            ? HomeScreen(
                backgroundColor: backgroundColor,
                latitude: latitude,
                longitude: longitude,
              )
            : const Center(child: CircularProgressIndicator()),
      ),
    );
  }
}

class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();
    path.moveTo(0, size.height);
    path.lineTo(0, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.9,
        size.width * 0.2, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.9,
        size.width * 0.5, size.height * 0.8);
    path.quadraticBezierTo(size.width * 0.68, size.height * 0.9,
        size.width * 0.75, size.height * 0.8);
    path.quadraticBezierTo(
        size.width * 0.88, size.height * 0.9, size.width, size.height * 0.8);
    path.lineTo(size.width, 0);
    path.lineTo(0, 0);
    path.close();
    return path;
  }

  @override
  bool shouldReclip(CustomClipper<Path> oldClipper) => false;
}
