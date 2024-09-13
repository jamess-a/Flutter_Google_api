import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Gps',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 225, 255)),
        useMaterial3: true,
      ),
      darkTheme: ThemeData.dark().copyWith(
        colorScheme: ColorScheme.fromSeed(
            seedColor: const Color.fromARGB(255, 0, 183, 255),
            brightness: Brightness.dark),
        useMaterial3: true,
      ),
      themeMode: ThemeMode.dark,
      home: const MyHomePage(
        title: 'GPS',
      ),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({
    super.key,
    required this.title,
  });

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  GoogleMapController? mapController;
  String _error = '';
  Marker? _origin;
  Marker? _destination;
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  Position? userLocation;

  @override
  void initState() {
    super.initState();
    _getLocation();
  }

  Future<void> _getLocation() async {
    try {
      Position position = await Geolocator.getCurrentPosition(
        locationSettings: const LocationSettings(
          accuracy: LocationAccuracy.high,
        ),
      );
      setState(() {
        userLocation = position;
      });
    } catch (e) {
      setState(() {
        _error = 'Failed to get location';
      });
    }
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final String apiKey =
        'AIzaSyCN5iCJo4eq3UtebW1gvrdTN758Ul7rJO0'; // Replace with your actual API key
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          _polylineCoordinates = _decodePolyline(points);

          setState(() {
            _polylines.add(Polyline(
              polylineId: const PolylineId('route'),
              points: _polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ));
          });

          mapController!.animateCamera(CameraUpdate.newLatLngBounds(
            _getLatLngBounds(_polylineCoordinates),
            50.0,
          ));
        } else {
          setState(() {
            _error = 'No routes found';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch directions';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error occurred while fetching directions';
      });
    }
  }

  List<LatLng> _decodePolyline(String encoded) {
    List<LatLng> polyline = [];
    int index = 0, len = encoded.length;
    int lat = 0, lng = 0;

    while (index < len) {
      int b, shift = 0, result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlat = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lat += dlat;

      shift = 0;
      result = 0;
      do {
        b = encoded.codeUnitAt(index++) - 63;
        result |= (b & 0x1f) << shift;
        shift += 5;
      } while (b >= 0x20);
      int dlng = ((result & 1) != 0 ? ~(result >> 1) : (result >> 1));
      lng += dlng;

      polyline.add(LatLng(lat / 1E5, lng / 1E5));
    }

    return polyline;
  }

  LatLngBounds _getLatLngBounds(List<LatLng> coordinates) {
    double southWestLat = coordinates.first.latitude;
    double southWestLng = coordinates.first.longitude;
    double northEastLat = coordinates.first.latitude;
    double northEastLng = coordinates.first.longitude;

    for (LatLng point in coordinates) {
      if (point.latitude < southWestLat) southWestLat = point.latitude;
      if (point.longitude < southWestLng) southWestLng = point.longitude;
      if (point.latitude > northEastLat) northEastLat = point.latitude;
      if (point.longitude > northEastLng) northEastLng = point.longitude;
    }

    return LatLngBounds(
      southwest: LatLng(southWestLat, southWestLng),
      northeast: LatLng(northEastLat, northEastLng),
    );
  }

  void _addMarker(LatLng position) {
    if (_origin == null && userLocation != null) {
      // Set the current location as origin
      setState(() {
        _origin = Marker(
          markerId: const MarkerId('origin'),
          infoWindow: const InfoWindow(title: 'Current Location'),
          icon:
              BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueGreen),
          position: LatLng(userLocation!.latitude, userLocation!.longitude),
        );
      });
    }

    setState(() {
      _destination = Marker(
        markerId: const MarkerId('destination'),
        infoWindow: const InfoWindow(title: 'Destination'),
        icon: BitmapDescriptor.defaultMarkerWithHue(BitmapDescriptor.hueRed),
        position: position,
      );

      if (_origin != null) {
        _getDirections(_origin!.position, _destination!.position);
      }
    });
  }

  Widget _showMap() {
    return GoogleMap(
      mapType: MapType.normal,
      myLocationEnabled: true,
      polylines: _polylines,
      markers: {
        if (_origin != null) _origin!,
        if (_destination != null) _destination!,
      },
      onMapCreated: (GoogleMapController controller) =>
          mapController = controller,
      initialCameraPosition: CameraPosition(
        target: LatLng(
            userLocation?.latitude ?? 0.0, userLocation?.longitude ?? 0.0),
        zoom: 15,
      ),
      onLongPress: _addMarker,
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        title: Text(widget.title),
      ),
      body: Center(
        child: userLocation == null
            ? const CircularProgressIndicator()
            : Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: <Widget>[
                  Text(
                    'Current Location: ${userLocation!.latitude}, ${userLocation!.longitude}',
                  ),
                  Expanded(
                    child: _showMap(),
                  ),
                ],
              ),
      ),
    );
  }
}
