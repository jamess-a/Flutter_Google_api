import 'dart:io';

import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:path_provider/path_provider.dart';
import 'componant/CardDirection.dart'; // Import the MapCard component

class ScrollerWidget extends StatefulWidget {
  const ScrollerWidget({super.key});

  @override
  State<ScrollerWidget> createState() => _ScrollerWidgetState();
}

class _ScrollerWidgetState extends State<ScrollerWidget> {
  bool _isLoading = true;
  LatLng? _savedLocation;

  @override
  void initState() {
    _retrieveSavedLocation();
    super.initState();
  }

  Future<String> get _localPath async {
    final directory = await getApplicationDocumentsDirectory();
    return directory.path;
  }

  Future<File> get _localFile async {
    final path = await _localPath;
    return File('$path/location.txt');
  }

  Future<LatLng?> readLocation() async {
    try {
      final file = await _localFile;
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
    final location = await readLocation();
    if (location != null) {
      setState(() {
        _onLocationSaved(location);
      });
    }
  }

  void _onLocationSaved(LatLng location) {
    setState(() {
      _savedLocation = location;
    });
  }

  void _getDirections() async {
    if (_savedLocation != null) {
      await Navigator.of(context).push(MaterialPageRoute(
          builder: (context) => MapCard(
              destination: _savedLocation,
              destinationname: 'Home Location',
              onLocationSaved: (location) {
                _onLocationSaved(location);
              })));
      _retrieveSavedLocation();
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;

    return Container(
      height: 150,
      margin: EdgeInsets.all(2),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(
          children: <Widget>[
            Container(
              width: 300,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.home, color: textColor),
                      title: Text(
                        'Home',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        'Day off is waiting for you! GO home now.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('ADD LOCATION'),
                          onPressed: _savedLocation == null
                              ? () {
                                  Navigator.of(context).push(MaterialPageRoute(
                                      builder: (context) => MapCard(
                                          destination: null,
                                          destinationname: 'Add Location',
                                          onLocationSaved: _onLocationSaved)));
                                }
                              : null,
                        ),
                        TextButton(
                          child: const Text('DIRECTION'),
                          onPressed: _savedLocation != null
                              ? () {
                                  _getDirections();
                                }
                              : null,
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 300,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.work_history, color: textColor),
                      title: Text(
                        'Digio',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        'Back to work. your boss is waiting for you! GO now.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('DIRECTION'),
                          onPressed: () {
                            // Add direction logic here
                          },
                        ),
                        const SizedBox(width: 8),
                      ],
                    ),
                  ],
                ),
              ),
            ),
            Container(
              width: 300,
              child: Card(
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  children: <Widget>[
                    ListTile(
                      leading: Icon(Icons.local_convenience_store_rounded,
                          color: textColor),
                      title: Text(
                        '7-Eleven',
                        style: TextStyle(color: textColor),
                      ),
                      subtitle: Text(
                        'Want to eat! GO 7-11 now.',
                        style: TextStyle(color: textColor),
                      ),
                    ),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: <Widget>[
                        TextButton(
                          child: const Text('DIRECTION'),
                          onPressed: () {
                            // Add direction logic here
                          },
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
