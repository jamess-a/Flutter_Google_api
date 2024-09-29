import 'dart:io';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_api/componant/CardDirection.dart';
import 'package:path_provider/path_provider.dart';

class ScrollerWidget extends StatefulWidget {
  const ScrollerWidget({super.key});

  @override
  State<ScrollerWidget> createState() => _ScrollerWidgetState();
}

class _ScrollerWidgetState extends State<ScrollerWidget> {
  LatLng? _savedLocationHome;
  LatLng? _savedLocationWork;

  @override
  void initState() {
    super.initState();
    _retrieveSavedLocations();
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

  Future<void> saveLocation(LocationType type, LatLng location) async {
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

  Future<void> _retrieveSavedLocations() async {
    final locationHome = await readLocation(LocationType.home);
    final locationWork = await readLocation(LocationType.work);
    setState(() {
      _savedLocationHome = locationHome;
      _savedLocationWork = locationWork;
    });
  }

  void _onLocationSaved(LocationType type, LatLng location) {
    setState(() {
      switch (type) {
        case LocationType.home:
          _savedLocationHome = location;
          break;
        case LocationType.work:
          _savedLocationWork = location;
          break;
      }
    });
    saveLocation(type, location);
  }

  void _getDirections(LocationType type) async {
    LatLng? location;
    String locationName;
    if (type == LocationType.home) {
      location = _savedLocationHome;
      locationName = 'Home Location';
    } else {
      location = _savedLocationWork;
      locationName = 'Work Location';
    }
    if (location != null) {
      await Navigator.of(context).push(MaterialPageRoute(
        builder: (context) => MapCard(
          destination: location,
          destinationname: locationName,
          onLocationSaved: (loc) => _onLocationSaved(type, loc),
          locationType: type,
        ),
      ));
      _retrieveSavedLocations();
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
            buildLocationCard(
              context,
              textColor,
              'Home',
              'Day off is waiting for you! GO home now.',
              Icons.home,
              LocationType.home,
              _savedLocationHome,
            ),
            buildLocationCard(
              context,
              textColor,
              'Work',
              'Back to work. your boss is waiting for you! GO now.',
              Icons.work,
              LocationType.work,
              _savedLocationWork,
            ),
            buildStaticCard(
              context,
              textColor,
              '7-Eleven',
              'Want to eat! GO 7-11 now.',
              Icons.local_convenience_store_rounded,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLocationCard(
      BuildContext context,
      Color textColor,
      String title,
      String subtitle,
      IconData icon,
      LocationType type,
      LatLng? savedLocation) {
    return Container(
      width: 300,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ListTile(
              leading: Icon(icon, color: textColor),
              title: Text(title, style: TextStyle(color: textColor)),
              subtitle: Text(subtitle, style: TextStyle(color: textColor)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('ADD LOCATION'),
                  onPressed: () {
                    Navigator.of(context).push(MaterialPageRoute(
                      builder: (context) => MapCard(
                        destination: null,
                        destinationname: 'Add Location',
                        onLocationSaved: (location) =>
                            _onLocationSaved(type, location),
                        locationType: type,
                      ),
                    ));
                  },
                ),
                TextButton(
                  child: const Text('DIRECTION'),
                  onPressed: savedLocation != null
                      ? () {
                          _getDirections(type);
                        }
                      : null,
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }

  Widget buildStaticCard(BuildContext context, Color textColor, String title,
      String subtitle, IconData icon) {
    return Container(
      width: 300,
      child: Card(
        child: Column(
          mainAxisSize: MainAxisSize.max,
          children: <Widget>[
            ListTile(
              leading: Icon(icon, color: textColor),
              title: Text(title, style: TextStyle(color: textColor)),
              subtitle: Text(subtitle, style: TextStyle(color: textColor)),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                TextButton(
                  child: const Text('DIRECTION'),
                  onPressed: () {},
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
