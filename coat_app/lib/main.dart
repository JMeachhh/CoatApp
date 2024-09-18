import 'dart:developer';

import 'package:flutter/material.dart';

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

    Color backgroundColor = const Color.fromARGB(255, 37, 60, 87);
    Color navBarColor = const Color.fromARGB(255, 87, 113, 143);
    Color titleColor = const Color.fromARGB(255, 75, 183, 255);
    Color selectionColor = titleColor;
    Color navBarUnselected = const Color.fromARGB(255, 150, 150, 150);

    return Scaffold(
      appBar: AppBar(
        backgroundColor: backgroundColor,
        title: Text(
          'Do I Need A Coat?',
        ),
        centerTitle: true,
        foregroundColor: titleColor,
        titleTextStyle: const TextStyle(
            fontWeight: FontWeight.bold, fontFamily: 'roboto', fontSize: 35),
      ),
      bottomNavigationBar: Container(
        color: backgroundColor,
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
    Color selectedColorOne = const Color.fromARGB(255, 110, 178, 255);
    Color selectedColorTwo = const Color.fromARGB(255, 110, 173, 255);
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
                      selectedColorOne,
                      selectedColorTwo,
                      selectedColorThree
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

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
        backgroundColor: widget.backgroundColor,
        body: const Center(
          child: Text('Home Screen'),
        ));
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
      body: ElevatedButton(
        onPressed: widget.onLocationSet,
        child: const Text('Set Location'),
      ),
    );
  }
}

/// hello