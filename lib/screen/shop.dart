import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'location.dart';
import 'fav_shop.dart';

class ShopListWidget extends StatefulWidget {
  @override
  _ShopListWidgetWidgetState createState() => _ShopListWidgetWidgetState();
}

class _ShopListWidgetWidgetState extends State<ShopListWidget> {
  Set<String> _favorites = Set<String>();
  bool _isLoading = true;
  String _error = '';
  List<dynamic> _shops = [];
  LatLng? _currentPosition;
  final String apiKey = 'AIzaSyCN5iCJo4eq3UtebW1gvrdTN758Ul7rJO0';
  get isFavorite => null;

  @override
  void initState() {
    super.initState();
    _loadFavorites();
    _getCurrentPosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      _fetchNearbyRestaurants();
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    });
  }

  Future<void> _loadFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      setState(() {
        _favorites =
            prefs.getStringList('shop_favorites')?.toSet() ?? Set<String>();
      });
    } catch (e) {
      print('Error loading favorites: $e');
    }
  }

  Future<void> _saveFavorites() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      await prefs.setStringList('shop_favorites', _favorites.toList());
    } catch (e) {
      print('Error saving favorites: $e');
    }
  }

  Future<void> _fetchNearbyRestaurants() async {
    if (_currentPosition == null) return;

    final String url =
        'https://maps.googleapis.com/maps/api/place/nearbysearch/json'
        '?location=${_currentPosition!.latitude},${_currentPosition!.longitude}'
        '&radius=3000'
        '&type=convenience_store'
        '&keyword=7-Eleven'
        '&key=$apiKey';

    try {
      final response = await http.get(Uri.parse(url));
      if (response.statusCode == 200) {
        final data = json.decode(response.body);
        setState(() {
          _shops = data['results'];
        });
      } else {
        setState(() {
          _error = 'Failed to fetch restaurants';
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
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    Color textColor = isDarkMode ? Colors.white : Colors.black;
    return Scaffold(
      appBar: AppBar(title: Text('Stores Around Me'), actions: [
        IconButton(
          icon: Icon(Icons.favorite),
          color: Colors.red,
          onPressed: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => FavListShop(favorites: _favorites),
              ),
            );
          },
        ),
      ]),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : ListView.builder(
                  itemCount: _shops.length,
                  itemBuilder: (context, index) {
                    final shop = _shops[index];
                    final name = shop['name'] ?? 'Unnamed';
                    final rating = shop['rating'] ?? 0.0;
                    final address = shop['vicinity'] ?? 'No address';
                    final openNow = shop['opening_hours']?['open_now'] == true
                        ? 'Open Now'
                        : 'Closed';
                    final location = LatLng(
                      shop['geometry']['location']['lat'],
                      shop['geometry']['location']['lng'],
                    );
                    final photoReference = shop['photos'] != null
                        ? shop['photos'][0]['photo_reference']
                        : null;

                    final statusColor =
                        openNow == 'Open Now' ? Colors.green : Colors.red;

                    final isFavorite = _favorites.contains(name);

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
                                              child: Icon(
                                                  Icons
                                                      .local_convenience_store_rounded,
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
                                        child: Icon(
                                            Icons
                                                .local_convenience_store_rounded,
                                            size: 100)),
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
                                      style: TextStyle(color: textColor),
                                    ),
                                    TextSpan(
                                      text: openNow,
                                      style: TextStyle(color: statusColor),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                            Padding(
                              padding: const EdgeInsets.symmetric(
                                  horizontal: 16.0, vertical: 1.0),
                              child: Row(
                                mainAxisAlignment: MainAxisAlignment.end,
                                children: [
                                  RatingBarIndicator(
                                    rating: rating?.toDouble() ?? 0.0,
                                    itemBuilder: (context, index) => const Icon(
                                      Icons.star,
                                      color: Colors.amber,
                                    ),
                                    itemCount: 5,
                                    itemSize: 20.0,
                                    direction: Axis.horizontal,
                                  ),
                                  SizedBox(width: 8.0),
                                  Text(
                                    'Rating: $rating',
                                    style: TextStyle(color: textColor),
                                  ),
                                  const Spacer(),
                                  Padding(
                                    padding: const EdgeInsets.only(bottom: 8.0),
                                    child: Align(
                                      alignment: Alignment.bottomRight,
                                      child: IconButton(
                                        icon: Icon(
                                          isFavorite
                                              ? Icons.favorite
                                              : Icons.favorite_border,
                                          color: isFavorite ? Colors.red : null,
                                        ),
                                        onPressed: () {
                                          setState(() {
                                            if (isFavorite) {
                                              _favorites.remove(name);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '$name removed from favorites'),
                                                  backgroundColor: Colors.red,
                                                ),
                                              );
                                            } else {
                                              _favorites.add(name);
                                              ScaffoldMessenger.of(context)
                                                  .showSnackBar(
                                                SnackBar(
                                                  content: Text(
                                                      '$name added to favorites'),
                                                  backgroundColor: Colors.green,
                                                ),
                                              );
                                            }
                                            _saveFavorites();
                                          });
                                        },
                                      ),
                                    ),
                                  ),
                                ],
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
