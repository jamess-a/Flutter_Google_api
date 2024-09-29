import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location_api/config.dart';
import 'dart:convert';
import 'package:path_provider/path_provider.dart';

enum LocationType { home, work }

class MapCard extends StatefulWidget {
  final LatLng? destination;
  final String? destinationname;
  final Function(LatLng) onLocationSaved;
  final LocationType locationType;

  MapCard({
    required this.destination,
    this.destinationname,
    required this.onLocationSaved,
    required this.locationType,
  });

  @override
  _MapCardState createState() => _MapCardState();
}

class _MapCardState extends State<MapCard> {
  GoogleMapController? mapController;
  LatLng _currentPosition = LatLng(0.0, 0.0);
  LatLng? _markedPosition;
  bool _isLoading = true;
  bool _isFetchingDirections = false;
  String _error = '';
  Set<Polyline> _polylines = {};
  List<LatLng> _polylineCoordinates = [];
  Set<Marker> _markers = {};
  LatLng? _savedLocation;
  bool _showDialog = false;

  @override
  void initState() {
    super.initState();
    _retrieveSavedLocation();
    _getCurrentPosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });

      if (mapController != null) {
        mapController!.animateCamera(
            CameraUpdate.newLatLng(_savedLocation ?? LatLng(0.0, 0.0)));
      }

      _getDirections(_currentPosition, _savedLocation ?? LatLng(0.0, 0.0));
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

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> _localFile(LocationType type) async {
    final path = await _localPath;
    String fileName;
    switch (type) {
      case LocationType.home:
        fileName = 'location_home.txt';
        break;
      case LocationType.work:
        fileName = 'location_work.txt';
        break;
    }
    return File('$path/$fileName');
  }

  Future<void> writeLocation(LocationType type, LatLng location) async {
    final file = await _localFile(type);
    await file.writeAsString('${location.latitude},${location.longitude}');
  }

  Future<LatLng?> readLocation(LocationType type) async {
    try {
      final file = await _localFile(type);
      final contents = await file.readAsString();
      final parts = contents.split(',');
      final latitude = double.parse(parts[0]);
      final longitude = double.parse(parts[1]);
      return LatLng(latitude, longitude);
    } catch (e) {
      return null;
    }
  }

  Future<void> _retrieveSavedLocation() async {
    final location = await readLocation(widget.locationType);
    if (location != null) {
      setState(() {
        _savedLocation = location;
        _markers.add(Marker(
          markerId: MarkerId('saved_location'),
          position: _savedLocation!,
          infoWindow: InfoWindow(
            title: 'Saved Location',
          ),
        ));
      });
    }
  }

  Future<void> _saveMarkedLocation() async {
    if (_markedPosition != null) {
      await writeLocation(widget.locationType, _markedPosition!);
      setState(() {
        _savedLocation = _markedPosition;
        _markers.add(Marker(
          markerId: MarkerId('saved_location'),
          position: _savedLocation!,
          infoWindow: const InfoWindow(
            title: 'Saved Location',
          ),
        ));
        _error = '';
        _showDialog = true;
        _getDirections(_currentPosition, _markedPosition!);
      });
      widget.onLocationSaved(_markedPosition!);
    } else {
      setState(() {
        _error = 'No location marked.';
      });
    }
  }

  Future<void> _deleteLocation() async {
    setState(() {
      _savedLocation = null;
      _markers = {};
      _polylines = {};
      _polylineCoordinates = [];
      _markedPosition = null;
    });

    final file = await _localFile(widget.locationType);
    try {
      await file.delete();
    } catch (e) {
      setState(() {
        _error = 'Failed to delete saved location data.';
      });
    }
  }

  Future<void> _getDirections(LatLng origin, LatLng destination) async {
    setState(() {
      _isFetchingDirections = true;
    });

    final String apiKey = Config.apiKey;
    final String url =
        'https://maps.googleapis.com/maps/api/directions/json?origin=${origin.latitude},${origin.longitude}&destination=${destination.latitude},${destination.longitude}&key=$apiKey';

    final response = await http.get(Uri.parse(url));

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      if (data['routes'].isNotEmpty) {
        final points = data['routes'][0]['overview_polyline']['points'];
        _polylineCoordinates = _decodePolyline(points);

        setState(() {
          _polylines.add(Polyline(
            polylineId: PolylineId('route'),
            points: _polylineCoordinates,
            color: Colors.blue,
            width: 5,
          ));
        });

        mapController!.animateCamera(CameraUpdate.newLatLngBounds(
          _getLatLngBounds(_polylineCoordinates),
          50.0,
        ));
      }
    } else {
      setState(() {
        _error = 'Failed to fetch directions';
      });
    }

    setState(() {
      _isFetchingDirections = false;
    });
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${widget.destinationname ?? "Map"}'),
        actions: [
          IconButton(
            icon: Icon(Icons.delete),
            onPressed: _deleteLocation,
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : Stack(
              children: [
                GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition:
                      CameraPosition(target: _currentPosition, zoom: 14.0),
                  myLocationEnabled: true,
                  myLocationButtonEnabled: true,
                  markers: _markers,
                  polylines: _polylines,
                  onTap: (position) {
                    setState(() {
                      _markedPosition = position;
                      _markers.add(Marker(
                        markerId: MarkerId('marked_position'),
                        position: position,
                        infoWindow: InfoWindow(
                          title: 'Marked Location',
                        ),
                      ));
                    });
                  },
                ),
                if (_error.isNotEmpty)
                  Positioned(
                    bottom: 10.0,
                    left: 10.0,
                    right: 10.0,
                    child: Container(
                      color: Colors.red,
                      padding: EdgeInsets.all(8.0),
                      child: Text(
                        _error,
                        style: TextStyle(color: Colors.white),
                        textAlign: TextAlign.center,
                      ),
                    ),
                  ),
                if (_showDialog)
                  AlertDialog(
                    title: const Text('Location Saved'),
                    content: const Text(
                        'Your marked location has been saved successfully.'),
                    actions: <Widget>[
                      TextButton(
                        onPressed: () {
                          setState(() {
                            _showDialog = false;
                          });
                        },
                        child: const Text('OK'),
                      ),
                    ],
                  ),
              ],
            ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _saveMarkedLocation,
        label: Text('Save Location'),
        icon: Icon(Icons.save),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }

  Future<Position> _getCurrentPosition() async {
    bool serviceEnabled;
    LocationPermission permission;

    serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      throw Exception('Location services are disabled.');
    }

    permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        throw Exception('Location permissions are denied');
      }
    }

    if (permission == LocationPermission.deniedForever) {
      throw Exception(
          'Location permissions are permanently denied, we cannot request permissions.');
    }

    return await Geolocator.getCurrentPosition();
  }
}
