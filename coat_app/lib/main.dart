import 'dart:developer';
import 'dart:ffi' as ffi;
import 'dart:ui';

import 'package:flutter/material.dart';
import 'package:do_i_need_a_coat/styles/button.dart';

void main() {
  runApp(const CoatApp());
}

class CoatApp extends StatelessWidget {
  const CoatApp({Key? key}) : super(key: key);

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
  int currentPageIndex = 1;
  bool locationSelected = false;

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
                      locationSelected: locationSelected,
                      buttonSize: buttonSize,
                      navBarColor: navBarColor,
                    ),
                    icon: CustomIconBox(
                      icon: Icons.settings,
                      isSelected: false,
                      iconSize: iconSize,
                      backgroundColor: navBarUnselected,
                      locationSelected: locationSelected,
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
        ),
        SettingsScreen(
          onLocationSet: changeLocationSelected,
          backgroundColor: backgroundColor,
        )
      ][currentPageIndex],
    );
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
  final bool locationSelected;
  final double buttonSize;
  final Color navBarColor;

  const CustomIconBox(
      {super.key,
      required this.icon,
      required this.isSelected,
      required this.iconSize,
      required this.backgroundColor,
      required this.locationSelected,
      required this.buttonSize,
      required this.navBarColor});

  @override
  Widget build(BuildContext context) {
    Color selectedColorOne = const Color.fromARGB(255, 21, 130, 255);
    // Color selectedColorTwo = const Color.fromARGB(255, 110, 173, 255);
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
                    colors: [
                      selectedColorThree,
                      // selectedColorTwo,
                      selectedColorOne
                    ],
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
        if (!locationSelected)
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

class HomeScreen extends StatefulWidget {
  final Color backgroundColor;
  const HomeScreen({super.key, required this.backgroundColor});

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
  int selectedIndex = -1;

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
                  ]),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: Container(
                  width: widgetSize,
                  height: widgetSize,
                  color: widgetColor,
                  child: Stack(
                    alignment: Alignment(0, 0),
                    children: [
                      Text('Widget'),
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

  String setDay(int index) {
    List<String> days = ['Today', 'TUE', 'WED', 'THU', 'FRI'];
    return days[index];
  }

  bool isButtonSelected(int index, int selectedIndex) {
    return (index == selectedIndex);
  }

  void onPressed(int index) {
    setState(() {
      selectedIndex = index;
    });
  }
}

class SettingsScreen extends StatefulWidget {
  final VoidCallback onLocationSet;
  final Color backgroundColor;

  const SettingsScreen(
      {super.key, required this.onLocationSet, required this.backgroundColor});

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: ElevatedButton(
          onPressed: widget.onLocationSet,
          child: const Text('Set Location'),
        ),
      ),
    );
  }
}
