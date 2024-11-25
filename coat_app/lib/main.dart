import 'dart:developer';
import 'dart:ffi' as ffi;
import 'package:flutter/material.dart';
import 'package:do_i_need_a_coat/screen/home.dart';
import 'package:do_i_need_a_coat/screen/settings.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';

void main() async {
  await dotenv.load(fileName: '.env');
  runApp(const CoatApp());
}

class CoatApp extends StatelessWidget {
  const CoatApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      theme: ThemeData(useMaterial3: true),
      home: const MyApp(),
    );
  }
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  int currentPageIndex = 0;
  bool locationSelected = false;
  String location = '';

  double latitude = 0;
  double longitude = 0;

  @override
  void initState() {
    super.initState();
    // Instead of loading images directly in initState, delay the load to after the widget is mounted
    Future.delayed(Duration.zero, () {
      loadImage('assets/wardrobe_empty.jpg', context);
      loadImage('assets/football.png', context);
      loadImage('assets/blue_shoe_box.png', context);
      loadImage('assets/plant.png', context);
      loadImage('assets/monday_clock_display.png', context);
      loadImage('assets/tuesday_clock_display.png', context);
      loadImage('assets/wednesday_clock_display.png', context);
      loadImage('assets/thursday_clock_display.png', context);
      loadImage('assets/friday_clock_display.png', context);
      loadImage('assets/saturday_clock_display.png', context);
      loadImage('assets/sunday_clock_display.png', context);
    });
  }

  @override
  void dispose() {
    // Cancel any ongoing tasks if needed
    super.dispose();
  }

  Future<void> loadImage(String imageUrl, BuildContext context) async {
    try {
      // Only load if the widget is still mounted
      if (!mounted) return;

      await precacheImage(AssetImage(imageUrl), context);
      print('Image loaded and cached successfully!');
    } catch (e) {
      print('Failed to load and cache the image: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    double screenWidth = MediaQuery.of(context).size.width;
    double screenHeight = MediaQuery.of(context).size.height;

    double iconSize = screenWidth * 0.1;
    double buttonSize = screenHeight * 0.1;

    double toolbarHeight = screenHeight * 0.18;

    double fontSize = screenHeight * 0.05;

    Color backgroundColor = const Color.fromARGB(255, 37, 60, 87);
    Color appBarColor = const Color.fromARGB(255, 247, 247, 247);
    Color navBarColor = const Color.fromARGB(255, 87, 113, 143);
    Color titleColor = const Color.fromARGB(255, 19, 101, 156);
    Color selectionColor = titleColor;
    Color navBarUnselected = const Color.fromARGB(255, 150, 150, 150);

    return Scaffold(
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
                      ),
                      toolbarHeight: toolbarHeight,
                      centerTitle: true,
                      titleTextStyle: TextStyle(
                          fontFamily: 'Adena',
                          fontSize: fontSize,
                          color: titleColor),
                    ),
                  ),
                ),
              )
            ],
          )),
      bottomNavigationBar: Container(
        color: backgroundColor,
        child: Container(
          decoration: BoxDecoration(
            boxShadow: [
              BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  spreadRadius: 5,
                  blurRadius: 10,
                  offset: Offset(0, 3)),
            ],
          ),
          child: ClipRRect(
            borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
            child: Container(
              color: navBarColor,
              child: NavigationBar(
                backgroundColor: navBarColor,
                labelBehavior: NavigationDestinationLabelBehavior.alwaysHide,
                onDestinationSelected: (int index) {
                  setState(() {
                    currentPageIndex = index;
                  });
                },
                indicatorColor: selectionColor,
                selectedIndex: currentPageIndex,
                destinations: <Widget>[
                  /// Home Tab
                  NavigationDestination(
                    selectedIcon: CustomIconBox(
                      icon: Icons.cloud,
                      isSelected: true,
                      iconSize: iconSize,
                      backgroundColor: navBarUnselected,
                      locationSelected: true,
                      buttonSize: buttonSize,
                      navBarColor: navBarColor,
                    ),
                    icon: CustomIconBox(
                      icon: Icons.cloud,
                      isSelected: false,
                      iconSize: iconSize,
                      backgroundColor: navBarUnselected,
                      locationSelected: true,
                      buttonSize: buttonSize,
                      navBarColor: navBarColor,
                    ),
                    label: '',
                  ),

                  /// Settings Tab
                  NavigationDestination(
                    selectedIcon: CustomIconBox(
                      icon: Icons.settings,
                      isSelected: true,
                      iconSize: iconSize,
                      backgroundColor: navBarUnselected,
                      locationSelected:
                          locationSelected, // Ensure this value is passed
                      buttonSize: buttonSize,
                      navBarColor: navBarColor,
                    ),
                    icon: CustomIconBox(
                      icon: Icons.settings,
                      isSelected: false,
                      iconSize: iconSize,
                      backgroundColor: navBarUnselected,
                      locationSelected:
                          locationSelected, // Ensure this value is passed
                      buttonSize: buttonSize,
                      navBarColor: navBarColor,
                    ),
                    label: '',
                  )
                ],
              ),
            ),
          ),
        ),
      ),
      body: <Widget>[
        HomeScreen(
          backgroundColor: backgroundColor,
          latitude: latitude,
          longitude: longitude,
        ),
        SettingsScreen(
          locationSelected: locationSelected,
          onLocationSet: changeLocationSelected,
          backgroundColor: backgroundColor,
          updateLocation: updateLocation,
        )
      ][currentPageIndex],
    );
  }

  void updateLocation(String location, double latitude, double longitude) {
    setState(() {
      this.latitude = latitude;
      this.longitude = longitude;
    });
  }

  void changeLocationSelected() {
    setState(() {
      locationSelected = true;
    });
  }
}

class CloudClipper extends CustomClipper<Path> {
  @override
  Path getClip(Size size) {
    Path path = Path();

    path.moveTo(0, size.height);

    path.lineTo(0, size.height * 0.8);

    // first bump
    path.quadraticBezierTo(size.width * 0.1, size.height * 0.9,
        size.width * 0.2, size.height * 0.8);

    // second bump
    path.quadraticBezierTo(size.width * 0.3, size.height * 0.9,
        size.width * 0.5, size.height * 0.8);

    // third bump
    path.quadraticBezierTo(size.width * 0.68, size.height * 0.9,
        size.width * 0.75, size.height * 0.8);

    // fourth bump
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

class CustomIconBox extends StatelessWidget {
  final IconData icon;
  final bool isSelected;
  final double iconSize;
  final Color backgroundColor;
  final bool locationSelected; // Add this line
  final double buttonSize;
  final Color navBarColor;

  const CustomIconBox({
    super.key,
    required this.icon,
    required this.isSelected,
    required this.iconSize,
    required this.backgroundColor,
    required this.locationSelected, // Include this parameter
    required this.buttonSize,
    required this.navBarColor,
  });

  @override
  Widget build(BuildContext context) {
    Color selectedColorOne = const Color.fromARGB(255, 21, 130, 255);
    Color selectedColorThree = const Color.fromARGB(255, 111, 250, 255);

    double badgeLocation = buttonSize * 0.2;
    return Stack(
      alignment: Alignment.center,
      children: [
        Container(
          width: iconSize * 1.6,
          height: iconSize * 1.5,
          decoration: BoxDecoration(
            gradient: isSelected
                ? LinearGradient(
                    colors: [selectedColorThree, selectedColorOne],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  )
                : null,
            color: isSelected ? null : navBarColor,
            borderRadius: BorderRadius.circular(12),
          ),
          alignment: Alignment.center,
          child: Icon(
            icon,
            size: iconSize,
            color: isSelected ? Colors.white : Colors.grey,
          ),
        ),
        if (!locationSelected) // Check the value of locationSelected
          Positioned(
            right: badgeLocation,
            top: badgeLocation,
            child: CircleAvatar(
              radius: iconSize * 0.2,
              backgroundColor: const Color.fromARGB(255, 255, 48, 48),
            ),
          ),
      ],
    );
  }
}
