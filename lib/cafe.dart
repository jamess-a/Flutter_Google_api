import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';
import 'location.dart'; 

class CafeListWidget extends StatefulWidget {
  @override
  _CafeListWidgetState createState() => _CafeListWidgetState();
}

class _CafeListWidgetState extends State<CafeListWidget> {
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _cafes = [];
  LatLng? _currentPosition;
  final String apiKey = 'AIzaSyCN5iCJo4eq3UtebW1gvrdTN758Ul7rJO0';

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

  Future<String?> _getPhotoUrl(String photoReference) async {
    final String photoUrl = 'https://maps.googleapis.com/maps/api/place/photo'
        '?maxwidth=800'
        '&photoreference=$photoReference'
        '&key=$apiKey';

    return photoUrl;
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
        title: Text('Cafés Around Me'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
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
                    final photoReference = cafe['photos'] != null
                        ? cafe['photos'][0]['photo_reference']
                        : null;

                    final statusColor =
                        openNow == 'Open Now' ? Colors.green : Colors.red;

                    

                    return GestureDetector(
                      onTap: () {
                        if (_currentPosition != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (context) => MapScreen(
                                destination: location,
                                destinationname: name,
                              ),
                            ),
                          );
                        }
                      },
                      child: Card(
                        margin: const EdgeInsets.symmetric(
                            vertical: 8.0, horizontal: 16.0),
                        elevation: 5,
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            photoReference != null
                                ? FutureBuilder<String?>(
                                    future: _getPhotoUrl(photoReference),
                                    builder: (context, snapshot) {
                                      if (snapshot.connectionState ==
                                          ConnectionState.waiting) {
                                        return const SizedBox(
                                          width: double.infinity,
                                          height: 200,
                                          child: Center(
                                              child:
                                                  CircularProgressIndicator()),
                                        );
                                      } else if (snapshot.hasData &&
                                          snapshot.data != null) {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(8.0)),
                                            image: DecorationImage(
                                              image:
                                                  NetworkImage(snapshot.data!),
                                              fit: BoxFit.cover,
                                            ),
                                          ),
                                        );
                                      } else {
                                        return Container(
                                          width: double.infinity,
                                          height: 200,
                                          decoration: BoxDecoration(
                                            color: Colors.grey[200],
                                            borderRadius:
                                                const BorderRadius.vertical(
                                                    top: Radius.circular(8.0)),
                                          ),
                                          child: const Center(
                                              child: Icon(Icons.local_cafe,
                                                  size: 100)),
                                        );
                                      }
                                    },
                                  )
                                : Container(
                                    width: double.infinity,
                                    height: 200,
                                    decoration: BoxDecoration(
                                      color: Colors.grey[200],
                                      borderRadius: const BorderRadius.vertical(
                                          top: Radius.circular(8.0)),
                                    ),
                                    child: const Center(
                                        child:
                                            Icon(Icons.local_cafe, size: 100)),
                                  ),
                            Padding(
                              padding: const EdgeInsets.all(16.0),
                              child: Text(name,
                                  style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 18)),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 8.0),
                              child: RichText(
                                text: TextSpan(
                                  children: [
                                    TextSpan(
                                      text: '$address\nStatus: ',
                                      style:
                                          const TextStyle(color: Colors.black),
                                    ),
                                    TextSpan(
                                      text: openNow,
                                      style: TextStyle(color: statusColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
