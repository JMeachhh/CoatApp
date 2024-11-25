import 'package:flutter/material.dart';
import 'package:do_i_need_a_coat/styles/button.dart';
import 'package:geolocator/geolocator.dart';

class SettingsScreen extends StatefulWidget {
  final bool locationSelected;
  final VoidCallback onLocationSet;
  final Color backgroundColor;
  final Function(String, double, double) updateLocation;

  const SettingsScreen({
    super.key,
    required this.locationSelected,
    required this.onLocationSet,
    required this.backgroundColor,
    required this.updateLocation,
  });

  @override
  State<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends State<SettingsScreen> {
  String location = '';

  String? lat;
  String? long;

  @override
  void initState() {
    super.initState();
    // Check if location has already been selected
    if (widget.locationSelected) {
      setState(() {
        location =
            widget.locationSelected ? 'Latitude: $lat , Longitude: $long' : '';
      });
    }
  }

  Future<Position> _getCurrentLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request');
    }

    return await Geolocator.getCurrentPosition();
  }

  void _liveLocation() {
    LocationSettings locationSettings = const LocationSettings(
      accuracy: LocationAccuracy.high,
      distanceFilter: 100,
    );

    Geolocator.getPositionStream(locationSettings: locationSettings)
        .listen((Position position) {
      lat = position.latitude.toString();
      long = position.longitude.toString();

      setState(() {
        location = 'Latitude: $lat , Longitude: $long';
        widget.updateLocation(location, position.latitude, position.longitude);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: widget.backgroundColor,
      body: SafeArea(
        child: Column(
          children: [
            // Only display location when it's fetched
            // if (widget.locationSelected)
            //   Text(location, style: TextStyle(fontSize: 18)),

            ElevatedButton(
              onPressed: () {
                _getCurrentLocation().then((value) {
                  lat = '${value.latitude}';
                  long = '${value.longitude}';
                  setState(() {
                    location =
                        'Latitude: $lat , Longitude: $long'; // Update the location text
                  });
                  widget.updateLocation(location, value.latitude,
                      value.longitude); // Update the parent with the location
                  _liveLocation(); // Start live location stream
                  widget.onLocationSet(); // Update the locationSelected status
                });
              },
              child: Text(
                widget.locationSelected
                    ? 'Location Selected'
                    : 'Get Location', // Change button text based on locationSelected
              ),
            ),
          ],
        ),
      ),
    );
  }

  String getLocation() {
    return location;
  }
}
