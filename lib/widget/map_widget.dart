import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';

class MapWidget extends StatelessWidget {
  final Function(GoogleMapController) onMapCreated;
  final LatLng initialPosition;
  final Set<Polyline> polylines;
  final Set<Marker> markers;

  const MapWidget({
    super.key,
    required this.onMapCreated,
    required this.initialPosition,
    required this.polylines,
    required this.markers,
  });

  @override
  Widget build(BuildContext context) {
    return GoogleMap(
      onMapCreated: onMapCreated,
      initialCameraPosition: CameraPosition(
        target: initialPosition,
        zoom: 14,
      ),
      mapType: MapType.normal,
      myLocationEnabled: true,
      myLocationButtonEnabled: true,
      polylines: polylines,
      markers: markers,
    );
  }
}
