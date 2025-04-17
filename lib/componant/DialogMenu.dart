import 'package:flutter/material.dart';
import 'package:google_place/google_place.dart';
import 'package:geolocator/geolocator.dart';
import 'package:location_api/componant/Status.dart';
import 'dart:math';
import 'package:location_api/config.dart';

class StarRating extends StatelessWidget {
  final double rating;
  final int starCount;

  const StarRating({Key? key, required this.rating, this.starCount = 5})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    List<Widget> stars = [];
    for (int i = 1; i <= starCount; i++) {
      stars.add(
        Icon(
          i <= rating ? Icons.star : Icons.star_border,
          color: Colors.yellow,
          size: 20.0,
        ),
      );
    }
    return Row(children: stars);
  }
}

class DialogWidget extends StatefulWidget {
  const DialogWidget({super.key});

  @override
  State<DialogWidget> createState() => _DialogWidgetState();
}

class _DialogWidgetState extends State<DialogWidget> {
  late GooglePlace googlePlace;
  bool _isLoading = false;
  String _error = '';
  SearchResult? _randomRestaurant;
  DetailsResult? _restaurantDetails;

  @override
  void initState() {
    super.initState();
    googlePlace = GooglePlace(Config.apiKey);
  }

  Future<void> _showMyDialog() async {
    setState(() {
      _isLoading = true;
      _error = '';
      _randomRestaurant = null;
      _restaurantDetails = null;
    });
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return const AlertDialog(
          content: Row(
            children: [
              CircularProgressIndicator(),
              SizedBox(width: 20),
              Text('Loading...'),
            ],
          ),
        );
      },
    );

    Position position;
    try {
      position = await _getCurrentPosition();
      await _fetchRandomRestaurant(position);
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
      Navigator.of(context).pop(); // Close the loading dialog
      _showErrorDialog(_error);
      return;
    }

    setState(() {
      _isLoading = false;
    });

    Navigator.of(context).pop(); // Close the loading dialog

    if (_randomRestaurant != null) {
      await _fetchRestaurantDetails(); // Fetch the details separately
      _showRestaurantDialog();
    } else if (_error.isNotEmpty) {
      _showErrorDialog(_error);
    }
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

    return await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high);
  }

  Future<void> _fetchRandomRestaurant(Position position) async {
    var result = await googlePlace.search.getNearBySearch(
      Location(lat: position.latitude, lng: position.longitude),
      5000,
      type: 'restaurant',
    );

    if (result != null &&
        result.results != null &&
        result.results!.isNotEmpty) {
      var restaurants = result.results!;
      var randomIndex = Random().nextInt(restaurants.length);
      setState(() {
        _randomRestaurant = restaurants[randomIndex];
      });
    } else {
      setState(() {
        _error = 'ไม่พบร้านอาหารที่เเนะนำใกล้ท่าน';
      });
    }
  }

  Future<void> _fetchRestaurantDetails() async {
    if (_randomRestaurant != null && _randomRestaurant!.placeId != null) {
      var details = await googlePlace.details.get(_randomRestaurant!.placeId!);
      if (details != null && details.result != null) {
        setState(() {
          _restaurantDetails = details.result; // Store the details
        });
      }
    }
  }

  void _showRestaurantDialog() {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text(_randomRestaurant!.name ?? 'Restaurant'),
          content: SingleChildScrollView(
            child: ListBody(
              children: <Widget>[
                if (_randomRestaurant!.photos != null &&
                    _randomRestaurant!.photos!.isNotEmpty)
                  Container(
                    width: 800,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10),
                      child: Image.network(
                        "https://maps.googleapis.com/maps/api/place/photo?maxwidth=800&photoreference=${_randomRestaurant!.photos![0].photoReference}&key=${Config.apiKey}",
                        fit: BoxFit.cover,
                        width: 800,
                        height: 200,
                        loadingBuilder: (BuildContext context, Widget child,
                            ImageChunkEvent? loadingProgress) {
                          if (loadingProgress == null) return child;
                          return Center(
                            child: CircularProgressIndicator(
                              value: loadingProgress.expectedTotalBytes != null
                                  ? loadingProgress.cumulativeBytesLoaded /
                                      loadingProgress.expectedTotalBytes!
                                  : null,
                            ),
                          );
                        },
                      ),
                    ),
                  )
                else
                  Container(
                    width: double.infinity,
                    height: 200,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(10),
                      color: Colors.grey,
                    ),
                    child: const Icon(Icons.restaurant,
                        size: 100, color: Colors.white),
                  ),
                const SizedBox(height: 10),
                StarRating(
                  rating: _randomRestaurant!.rating ?? 0.0,
                ),
                const SizedBox(height: 10),
                Text(
                    'Rating: ${_randomRestaurant!.rating?.toStringAsFixed(1) ?? 'N/A'}'),
                Text(_randomRestaurant!.vicinity ?? 'No address available'),
                if (_restaurantDetails != null &&
                    _restaurantDetails!.openingHours != null) ...[
                  const SizedBox(height: 10),
                  CompactOpeningHoursWidget(
                    weekdayText: _restaurantDetails!.openingHours!.weekdayText!,
                    openingTimes: _restaurantDetails!.openingHours!.periods
                        ?.map((period) {
                      return '${period.open?.time} - ${period.close?.time}';
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 10),
                Text(
                    'Price level: ${_restaurantDetails!.priceLevel?.toString() ?? 'N/A'}'),
                if (_restaurantDetails!.formattedPhoneNumber != null)
                  Text('Phone: ${_restaurantDetails!.formattedPhoneNumber}'),
                if (_restaurantDetails!.website != null)
                  Text('Website: ${_restaurantDetails!.website}'),
              ],
            ),
          ),
          actions: <Widget>[
            TextButton(
              child: const Text('Cancel'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
            TextButton(
              child: const Text('Approve'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  void _showErrorDialog(String error) {
    showDialog<void>(
      context: context,
      barrierDismissible: true,
      builder: (BuildContext context) {
        return AlertDialog(
          title: const Text('เเจ้งเตือน'),
          content: Text(error),
          actions: <Widget>[
            TextButton(
              child: const Text('ปิด'),
              onPressed: () {
                Navigator.of(context).pop();
              },
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () {
        _showMyDialog();
      },
      child: const Card(
        margin: EdgeInsets.only(left: 5, right: 5),
        elevation: 5,
        child: ListTile(
          leading: Icon(Icons.fastfood),
          title: Text('Random Meal! Tap Now'),
          subtitle:
              Text('Don\'t know what meal is waiting for you! GO get it now!'),
        ),
      ),
    );
  }
}
