import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:google_place/google_place.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';
import 'location.dart';

class SuggestionWidget extends StatefulWidget {
  const SuggestionWidget({super.key});

  @override
  State<SuggestionWidget> createState() => _SuggestionWidgetState();
}

class _SuggestionWidgetState extends State<SuggestionWidget> {
  bool _isLoading = true;
  String _error = '';
  late GooglePlace googlePlace;
  List<SearchResult>? restaurantSuggestions;
  final String apiKey = 'AIzaSyCN5iCJo4eq3UtebW1gvrdTN758Ul7rJO0';
  LatLng? _currentPosition;

  @override
  void initState() {
    super.initState();
    _getCurrentPosition().then((position) {
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      fetchRestaurantSuggestions();
    }).catchError((e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    });
    googlePlace = GooglePlace(apiKey);
  }

  Future<void> fetchRestaurantSuggestions() async {
    if (_currentPosition == null) return;

    var result = await googlePlace.search.getNearBySearch(
      Location(
          lat: _currentPosition!.latitude, lng: _currentPosition!.longitude),
      10000,
      type: 'restaurant',
    );
    print('API ${result?.results}');

    if (result != null && result.results != null) {
      setState(() {
        restaurantSuggestions = result.results;
      });
    } else {
      setState(() {
        restaurantSuggestions = [];
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
        title: Text('Restaurant Suggestions'),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _error.isNotEmpty
              ? Center(child: Text('Error: $_error'))
              : restaurantSuggestions == null || restaurantSuggestions!.isEmpty
                  ? const Center(child: Text('No restaurants found.'))
                  : SingleChildScrollView(
                      child: Column(
                        children: [
                          ListView.builder(
                            shrinkWrap: true,
                            physics: NeverScrollableScrollPhysics(),
                            itemCount: restaurantSuggestions!.length < 3
                                ? restaurantSuggestions!.length
                                : 3,
                            itemBuilder: (context, index) {
                              final restaurant = restaurantSuggestions![index];
                              return _buildRestaurantCard(restaurant);
                            },
                          ),
                        ],
                      ),
                    ),
    );
  }

  Widget _buildRestaurantCard(SearchResult restaurant) {
    return Card(
      margin: const EdgeInsets.all(10),
      elevation: 5,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(15),
      ),
      child: Padding(
        padding: const EdgeInsets.all(10),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            ListTile(
              title: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (restaurant.photos != null &&
                      restaurant.photos!.isNotEmpty)
                    Container(
                      width: double.infinity,
                      height: 150, 
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        image: DecorationImage(
                          image: NetworkImage(
                            "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${restaurant.photos![0].photoReference}&key=$apiKey",
                          ),
                          fit: BoxFit.cover,
                        ),
                      ),
                    )
                  else
                    Container(
                      width: double.infinity,
                      height: 150, // Adjust the height as needed
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(10),
                        color: Colors.grey,
                      ),
                      child: const Icon(Icons.restaurant,
                          size: 100, color: Colors.white),
                    ),
                  const SizedBox(height: 10),
                  Text(
                    restaurant.name ?? 'Restaurant',
                    style: GoogleFonts.lato(
                      textStyle: const TextStyle(
                        fontSize: 24, // Increased font size
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),
              subtitle: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 5),
                  RatingBarIndicator(
                    rating: restaurant.rating?.toDouble() ?? 0.0,
                    itemBuilder: (context, index) => const Icon(
                      Icons.star,
                      color: Colors.amber,
                    ),
                    itemCount: 5,
                    itemSize: 20.0,
                    direction: Axis.horizontal,
                  ),
                  if (restaurant.vicinity != null)
                    Text(
                      'Address: ${restaurant.vicinity!}',
                      style: GoogleFonts.lato(
                        textStyle: const TextStyle(fontSize: 16),
                      ),
                    ),
                ],
              ),
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: <Widget>[
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  onPressed: () {
                    if (_currentPosition != null &&
                        restaurant.geometry?.location != null) {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => MapScreen(
                            destination: LatLng(
                                restaurant.geometry!.location!.lat!,
                                restaurant.geometry!.location!.lng!),
                            destinationname: restaurant.name ?? 'Restaurant',
                          ),
                        ),
                      );
                    }
                  },
                  icon: const Icon(Icons.directions),
                  label: const Text('DIRECTION'),
                ),
                const SizedBox(width: 8),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
