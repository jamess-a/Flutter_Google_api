import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

import 'location.dart'; // Import the MapScreen

class CafeListWidget extends StatefulWidget {
  @override
  _CafeListWidgetState createState() => _CafeListWidgetState();
}

class _CafeListWidgetState extends State<CafeListWidget> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _cafes = [];
  LatLng? _currentPosition;
  final String apiKey = 'AIzaSyCN5iCJo4eq3UtebW1gvrdTN758Ul7rJO0'; // Replace with your API key

  @override
  void initState() {
    super.initState();
    _getCurrentPosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _fetchNearbyCafes();
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    });
  }

  Future<void> _fetchNearbyCafes() async {
    if (_currentPosition == null) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=3000'
        '&type=cafe'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _cafes = data['results'];
        });
      } else {
        setState(() {
          _error = 'Failed to fetch cafes';
        });
      }
    } catch (e) {
      setState(() {
        _error = e.toString();
      });
    }
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Cafes Around Me'),
      ),
      body: _isLoading
          ? Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _cafes.length,
                  itemBuilder: (context, index) {
                    final cafe = _cafes[index];
                    final name = cafe['name'] ?? 'Unnamed';
                    final address = cafe['vicinity'] ?? 'No address';
                    final openNow = cafe['opening_hours']?['open_now'] == true
                        ? 'Open Now'
                        : 'Closed';
                    final location = LatLng(
                      cafe['geometry']['location']['lat'],
                      cafe['geometry']['location']['lng'],
                    );

                    return Card(
                      margin: const EdgeInsets.all(8.0),
                      child: ListTile(
                        leading: Icon(Icons.local_cafe, size: 50),
                        title: Text(name),
                        subtitle: Text('$address\nStatus: $openNow'),
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                destination: location,
                              ),
                            ),
                          );
                        },
                      ),
                    );
                  },
                ),
    );
  }
}
