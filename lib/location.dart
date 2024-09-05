import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';

class MapScreen extends StatefulWidget {
  @override
  _MapScreenState createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController; // Changed to nullable
  LatLng _currentPosition = LatLng(0.0, 0.0);
  final TextEditingController _searchController = TextEditingController();
  bool _isLoading = true;
  String _error = '';

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

  void _searchLocation() async {
    final query = _searchController.text;
    if (query.isNotEmpty) {
      final position = LatLng(37.7749, -122.4194);
      if (mapController != null) {
        mapController!.animateCamera(CameraUpdate.newLatLng(position));
      }
      setState(() {
        _currentPosition = position;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Google Maps'),
        actions: [
          IconButton(
            icon: Icon(Icons.search),
            onPressed: () {
              showSearch(
                context: context,
                delegate: LocationSearchDelegate(
                  onSearch: (query) {
                    _searchController.text = query;
                    _searchLocation();
                  },
                ),
              );
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : GoogleMap(
                  onMapCreated: _onMapCreated,
                  initialCameraPosition: CameraPosition(
                    target: _currentPosition,
                    zoom: 14.0,
                  ),
                  markers: {
                    Marker(
                      markerId: MarkerId('currentLocation'),
                      position: _currentPosition,
                      infoWindow: InfoWindow(title: 'Your Location'),
                    ),
                  },
                ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          if (mapController != null) {
            mapController!
                .animateCamera(CameraUpdate.newLatLng(_currentPosition));
          }
        },
        child: Icon(Icons.my_location),
        tooltip: 'Center on Current Location',
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

class LocationSearchDelegate extends SearchDelegate<String> {
  final Function(String) onSearch;

  LocationSearchDelegate({required this.onSearch});

  @override
  List<Widget>? buildActions(BuildContext context) {
    return [
      IconButton(
        icon: Icon(Icons.clear),
        onPressed: () {
          query = '';
        },
      ),
    ];
  }

  @override
  Widget buildLeading(BuildContext context) {
    return IconButton(
      icon: Icon(Icons.arrow_back),
      onPressed: () {
        Navigator.pop(context);
      },
    );
  }

  @override
  Widget buildSuggestions(BuildContext context) {
    // Build your suggestions here if needed
    return Center(child: Text('Suggestions will go here'));
  }

  @override
  Widget buildResults(BuildContext context) {
    final query = this.query;
    onSearch(query);
    return Center(child: Text('Searching for: $query'));
  }
}
