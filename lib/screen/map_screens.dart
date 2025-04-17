// lib/screens/map_screen.dart
import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:location_api/service/direction_service.dart';
import 'package:location_api/service/location_service.dart';
import 'package:location_api/widget/map_widget.dart';


class MapScreen extends StatefulWidget {
  final LatLng? destination;
  final String? destinationName;

  const MapScreen({super.key, required this.destination, this.destinationName});

  @override
  State<MapScreen> createState() => _MapScreenState();
}

class _MapScreenState extends State<MapScreen> {
  GoogleMapController? mapController;
  LatLng _currentPosition = const LatLng(0.0, 0.0);
  bool _isLoading = true;
  String _error = '';
  Set<Polyline> _polylines = {};
  Set<Marker> _markers = {};

  @override
  void initState() {
    super.initState();
    _initLocation();
  }

  Future<void> _initLocation() async {
    try {
      final position = await LocationService.getCurrentPosition();
      setState(() {
        _currentPosition = LatLng(position.latitude, position.longitude);
        _isLoading = false;
      });
      mapController?.animateCamera(CameraUpdate.newLatLng(_currentPosition));

      if (widget.destination != null) {
        final polyline = await DirectionService.getRoute(
          origin: _currentPosition,
          destination: widget.destination!,
        );

        setState(() {
          _polylines = polyline.polylines;
          _markers = polyline.markers;
        });
      } else {
        setState(() => _error = 'Destination is not available');
      }
    } catch (e) {
      setState(() {
        _isLoading = false;
        _error = e.toString();
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(widget.destinationName ?? 'Map')),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : MapWidget(
              onMapCreated: (controller) => mapController = controller,
              initialPosition: _currentPosition,
              polylines: _polylines,
              markers: _markers,
            ),
    );
  }
}
