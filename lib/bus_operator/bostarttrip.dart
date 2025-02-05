import 'dart:async';

import 'package:track_bus/bus_operator/bus_shedule.dart';
import 'package:track_bus/bus_operator/navigation/bottom_navigation.dart';
import 'package:track_bus/bus_operator/ratings.dart';
import 'package:track_bus/bus_operator/viewBOprofile.dart';
import 'package:track_bus/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:track_bus/bus_operator/boendtrip.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:google_maps_webservice/places.dart' as gm_places;
import 'package:location/location.dart' as location_lib;
import 'package:url_launcher/url_launcher.dart';

class BOStartTrip extends StatefulWidget {
  const BOStartTrip({Key? key}) : super(key: key);

  @override
  State<BOStartTrip> createState() => _BOStartTripState();
}

class _BOStartTripState extends State<BOStartTrip> {
  int _currentIndex = 0;

  final Completer<GoogleMapController> _controllerGoogleMap =
      Completer<GoogleMapController>();

  late GoogleMapController newGoogleMapController;
  late location_lib.LocationData currentLocation;
  location_lib.Location location = location_lib.Location();
  Set<Marker> markers = {};

  final TextEditingController _destinationController = TextEditingController();
  final gm_places.GoogleMapsPlaces _places = gm_places.GoogleMapsPlaces(
      apiKey: "AIzaSyCFwBrFsTMKu5IrsOOiMY-Nw8y_RNA_ZwE");

  @override
  void initState() {
    super.initState();
    currentLocation = location_lib.LocationData.fromMap({
      'latitude': 0.0,
      'longitude': 0.0,
    });
    _getCurrentLocation();
  }

  Future<void> _getCurrentLocation() async {
    try {
      currentLocation = await location.getLocation();
      setState(() {
        markers.add(
          Marker(
            markerId: const MarkerId('currentLocation'),
            position: LatLng(
                currentLocation.latitude ?? 0, currentLocation.longitude ?? 0),
            infoWindow: const InfoWindow(title: 'Start Location'),
          ),
        );
      });
    } catch (e) {
      print("Error getting location: $e");
    }
  }

  void _startJourney(LatLng destinationLatLng) async {
    final String googleMapsUrl =
        'https://www.google.com/maps/dir/?api=1&origin=${currentLocation.latitude},${currentLocation.longitude}&destination=${destinationLatLng.latitude},${destinationLatLng.longitude}&travelmode=driving';

    if (await canLaunch(googleMapsUrl)) {
      await launch(googleMapsUrl);
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => BOEndTrip(
            startLocationLatLng: LatLng(
              currentLocation.latitude!,
              currentLocation.longitude!,
            ),
            destinationLatLng: destinationLatLng,
          ),
        ),
      );
    } else {
      print("Could not launch Google Maps");
    }
  }

  void _onDestinationChanged(String value) async {
    if (value.isNotEmpty) {
      try {
        final places = await _places.searchByText(value);
        if (places.results.isNotEmpty) {
          final destinationLatLng = LatLng(
            places.results.first.geometry!.location.lat,
            places.results.first.geometry!.location.lng,
          );
          setState(() {
            markers.removeWhere(
                (marker) => marker.markerId.value == 'destinationLocation');
            markers.add(
              Marker(
                markerId: const MarkerId('destinationLocation'),
                position: destinationLatLng,
                infoWindow: const InfoWindow(title: 'Destination Location'),
              ),
            );
          });
        } else {
          _showErrorSnackBar("No results found for the entered destination.");
        }
      } catch (e) {
        _showErrorSnackBar(
            "Error occurred while searching for the destination.");
        print("Error searching for the destination: $e");
      }
    } else {
      setState(() {
        markers.removeWhere(
            (marker) => marker.markerId.value == 'destinationLocation');
      });
    }
  }

  void _showErrorSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.red,
      ),
    );
  }

  @override
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: ListView(
        shrinkWrap: true,
        children: [
          Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Container(
                width: double.infinity,
                height: 550,
                padding: const EdgeInsets.all(5.0),
                child: GoogleMap(
                  mapType: MapType.normal,
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  initialCameraPosition: CameraPosition(
                    target: LatLng(currentLocation.latitude ?? 0,
                        currentLocation.longitude ?? 0),
                    zoom: 14.0,
                  ),
                  padding: const EdgeInsets.only(top: 50),
                  onMapCreated: (GoogleMapController controller) {
                    _controllerGoogleMap.complete(controller);
                    newGoogleMapController = controller;
                  },
                  markers: markers,
                ),
              ),
              Container(
                child: Column(
                  children: [
                    TextField(
                      controller: _destinationController,
                      onChanged: _onDestinationChanged,
                      decoration: const InputDecoration(
                        labelText: 'Destination',
                        hintText: 'Enter destination...',
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 20.0),
                    const Text(
                      "Press on 'Target Icon Button' in the map to get \nyour current location before starting the trip.",
                      style:
                          TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      textAlign: TextAlign.center,
                    ),
                    const SizedBox(height: 15.0),
                    SizedBox(
                      height: 50,
                      width: 150,
                      child: ButtonWidget(
                        title: "Start Trip",
                        onPress: () {
                          if (_destinationController.text.isEmpty) {
                            _showErrorSnackBar("Please enter a destination.");
                            return;
                          }

                          if (markers.isNotEmpty) {
                            LatLng destinationLatLng = markers
                                .where((marker) =>
                                    marker.markerId ==
                                    const MarkerId('destinationLocation'))
                                .first
                                .position;
                            _startJourney(destinationLatLng);
                          } else {
                            _showErrorSnackBar(
                                "Please select a valid destination.");
                          }
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 90.0),
          BottomNavigation(
            currentIndex: _currentIndex,
            onTabTapped: (index) {
              setState(() {
                _currentIndex = index;
                if (index == 0) {
                  // Navigate to home
                } else if (index == 1) {
                  // Navigate to schedule
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const BusScheduleScreen(),
                    ),
                  );
                } else if (index == 2) {
                  // Navigate to star
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const RatingScreen(),
                    ),
                  );
                } else if (index == 3) {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const ProfileTypeScreen(),
                    ),
                  );
                }
              });
            },
          ),
        ],
      ),
    );
  }
}
