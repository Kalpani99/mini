import 'package:track_bus/bus_operator/navigation/bottom_navigation.dart';
import 'package:track_bus/passenger/pRatings.dart';
import 'package:track_bus/passenger/passengerhome.dart';
import 'package:track_bus/passenger/viewSchedule.dart';
import 'package:track_bus/passenger/view_Passenger_Profile.dart';
import 'package:track_bus/widget/button_widget.dart';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:firebase_database/firebase_database.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;

class LocationTrack extends StatefulWidget {
  final LatLng departureLocationLatLng;
  final LatLng destinationLatLng;

  const LocationTrack({
    Key? key,
    required this.departureLocationLatLng,
    required this.destinationLatLng,
  }) : super(key: key);

  @override
  _LocationTrackState createState() => _LocationTrackState();
}

class _LocationTrackState extends State<LocationTrack> {
  DatabaseReference busDetailsRef =
      FirebaseDatabase.instance.ref('locations/busdetails');
  DatabaseReference busLocationRef =
      FirebaseDatabase.instance.ref('locations/current_buslocation');
  late GoogleMapController newGoogleMapController;
  Set<Marker> markers = {};
  Set<Polyline> polylines = {};
  List<LatLng> polylineCoordinates = [];
  String _busNo = '';
  String _busName = '';
  LatLng? _busLocation;

  @override
  void initState() {
    super.initState();
    _initMap();
    _listenToFirebase();
  }

  void _initMap() {
    markers.addAll([
      Marker(
        markerId: const MarkerId('DepartureLocation'),
        position: widget.departureLocationLatLng,
        infoWindow: const InfoWindow(title: 'Departure Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
      ),
      Marker(
        markerId: const MarkerId('DestinationLocation'),
        position: widget.destinationLatLng,
        infoWindow: const InfoWindow(title: 'Destination Location'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueBlue),
      ),
    ]);
  }

  void _listenToFirebase() {
    busDetailsRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        setState(() {
          _busName = data['busName']?.toString() ?? 'Unknown';
          _busNo = data['busNo']?.toString() ?? 'Unknown';
        });
      }
    });

    busLocationRef.onValue.listen((DatabaseEvent event) {
      final data = event.snapshot.value;
      if (data != null && data is Map<dynamic, dynamic>) {
        double latitude = (data['latitude'] as num?)?.toDouble() ?? 0.0;
        double longitude = (data['longitude'] as num?)?.toDouble() ?? 0.0;

        LatLng busLocation = LatLng(latitude, longitude);
        _busLocation = busLocation;
        _updateBusLocationMarker(busLocation);
        _updatePolyline(busLocation);
      }
    });
  }

  void _updateBusLocationMarker(LatLng location) {
    markers
        .removeWhere((marker) => marker.markerId.value == 'currentBusLocation');
    markers.add(
      Marker(
        markerId: const MarkerId('currentBusLocation'),
        position: location,
        infoWindow: InfoWindow(
          title: 'Current Bus Location',
          snippet: 'Bus Name: $_busName | Bus No: $_busNo',
        ),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
      ),
    );
    setState(() {});
  }

  void _updatePolyline(LatLng busLocation) async {
    String apiKey = 'AIzaSyCsLwmDRs3JKm4WPugypZ5lDAGd4sV5PMU';
    String url = 'https://maps.googleapis.com/maps/api/directions/json?'
        'origin=${busLocation.latitude},${busLocation.longitude}'
        '&destination=${widget.departureLocationLatLng.latitude},${widget.departureLocationLatLng.longitude}'
        '&key=$apiKey';

    var response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      Map<String, dynamic> data = json.decode(response.body);
      List<dynamic> routes = data['routes'];
      if (routes.isNotEmpty) {
        String points = routes[0]['overview_polyline']['points'];
        polylineCoordinates = _decodePolyline(points);
        polylines.clear();
        polylines.add(
          Polyline(
            polylineId: const PolylineId('polyline'),
            color: Colors.black,
            width: 5,
            points: polylineCoordinates,
          ),
        );
        setState(() {});
      }
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> poly = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1F) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      poly.add(LatLng(lat / 1e5, lng / 1e5));
    }

    return poly;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Column(
        children: [
          Expanded(
            child: GoogleMap(
              mapType: MapType.normal,
              myLocationButtonEnabled: false,
              initialCameraPosition: CameraPosition(
                target: _busLocation ?? widget.departureLocationLatLng,
                zoom: 14.0,
              ),
              onMapCreated: (GoogleMapController controller) {
                newGoogleMapController = controller;
              },
              markers: markers,
              polylines: polylines,
            ),
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 50,
            width: 150,
            child: ButtonWidget(onPress: _endTrip, title: "End Trip"),
          ),
          const SizedBox(height: 20),
          BottomNavigation(
            currentIndex: 0,
            onTabTapped: (index) {
              Navigator.push(context, MaterialPageRoute(
                builder: (context) {
                  return [
                    PassengerHomeScreen(),
                    PassengerScheduleScreen(),
                    PRatingScreen(),
                    ProfileTypeScreenP()
                  ][index];
                },
              ));
            },
          ),
        ],
      ),
    );
  }

  void _endTrip() {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => const PassengerHomeScreen()),
    );
  }
}
