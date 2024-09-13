import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class Map extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<Map> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0);
  bool _isLoading = true;
  String _error = '';
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};
  Marker? _destinationMarker;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
      }
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    });
  }

  void _onMapCreated(GoogleMapController controller) {
    mapController = controller;
    if (_currentPosition.latitude != 0.0) {
      mapController!.animateCamera(CameraUpdate.newLatLng(_currentPosition));
    }
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    final String apiKey = 'AIzaSyCN5iCJo4eq3UtebW1gvrdTN758Ul7rJO0'; 
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['routes'].isNotEmpty) {
          final points = data['routes'][0]['overview_polyline']['points'];
          final polylineCoordinates = _decodePolyline(points);

          setState(() {
            _polylines.clear();
            _polylines.add(Polyline(
              polylineId: PolylineId('route'),
              points: polylineCoordinates,
              color: Colors.blue,
              width: 5,
            ));
          });

          mapController!.animateCamera(CameraUpdate.newLatLngBounds(
            _getLatLngBounds(polylineCoordinates),
            50.0,
          ));
        } else {
          setState(() {
            _error = 'No routes found';
          });
        }
      } else {
        setState(() {
          _error = 'Failed to fetch directions: ${response.reasonPhrase}';
        });
      }
    } catch (e) {
      setState(() {
        _error = 'Error fetching directions: $e';
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

  void _addDestinationMarker(LatLng position, String? name) {
    setState(() {
      _destinationMarker = Marker(
        markerId: MarkerId('destination'),
        position: position,
        infoWindow: InfoWindow(
          title: name ?? 'Destination',
        ),
      );
      _markers.add(_destinationMarker!);
    });

    _getDirections(_currentPosition, position);
  }

  void _onMapTap(LatLng position) {
    print('Map tapped at: $position'); // Debug print statement
    setState(() {
      _markers.removeWhere((marker) => marker.markerId.value == 'destination');
      _addDestinationMarker(position, 'New Destination');
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Map'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  onTap: _onMapTap,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14,
                  ),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  polylines: _polylines,
                  markers: _markers,
                ),
    );
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return Future.error('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return Future.error('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      return Future.error(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }
}
