import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'package:location_api/location.dart';

class FavList extends StatelessWidget {
  final Set<String> favorites;

  const FavList({super.key, required this.favorites});

  Future<LatLng?> getLocationFromName(String name, String apiKey) async {
    final String url =
        'https://maps.googleapis.com/maps/api/place/textsearch/json'
        '?query=${Uri.encodeComponent(name)}'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        if (data['results'].isNotEmpty) {
          final location = data['results'][0]['geometry']['location'];
          return LatLng(location['lat'], location['lng']);
        } else {
          throw Exception('No results found');
        }
      } else {
        throw Exception('Failed to load location');
      }
    } catch (e) {
      print('Error: $e');
      return null;
    }
  }

  Future<void> _openMapScreen(BuildContext context, String name) async {
    final apiKey = 'AIzaSyCN5iCJo4eq3UtebW1gvrdTN758Ul7rJO0';
    final location = await getLocationFromName(name, apiKey);
    if (location != null) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (context) => MapScreen(
            destination: location,
            destinationname: name,
          ),
        ),
      );
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Could not find location for $name')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Favorite Cafes'),
      ),
      body: favorites.isEmpty
          ? Center(
              child: Text('No favorites yet.'),
            )
          : ListView.builder(
              itemCount: favorites.length,
              itemBuilder: (context, index) {
                final name = favorites.elementAt(index);
                return GestureDetector(
                    onTap: () {
                      _openMapScreen(context, name);
                    },
                    child: Card(
                        child: ListTile(
                      leading: const Icon(Icons.local_cafe , color: Colors.brown),
                      title: Text(name),
                      trailing: const Icon(Icons.chevron_right),
                    )));
              },
            ),
    );
  }
}
