import 'dart:async';
import 'package:flutter/material.dart';
import 'package:geolocator/geolocator.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:pandahealthhospital/constants/constants.dart';
import 'package:pandahealthhospital/custom_widgets/custom_appbar.dart';
import 'package:pandahealthhospital/custom_widgets/custom_button.dart';
import 'package:flutter_google_maps_webservices/places.dart';
import 'package:flutter_typeahead/flutter_typeahead.dart';

class PickLocation extends StatefulWidget {
  final Function(double lat, double lng) onLocationPicked;

  const PickLocation({super.key, required this.onLocationPicked});

  @override
  _PickLocationState createState() => _PickLocationState();
}

class _PickLocationState extends State<PickLocation> {
  final Completer<GoogleMapController> _controller =
      Completer<GoogleMapController>();
  LatLng _selectedLocation = const LatLng(6.5244, 3.3792); // Default to Lagos
  final TextEditingController _searchController = TextEditingController();
  final GoogleMapsPlaces _places = GoogleMapsPlaces(apiKey: googleApiKey);
  Set<Marker> markers = {};

  @override
  void initState() {
    super.initState();
    _getUserLocation();
  }

  void _getUserLocation() async {
    bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
    if (!serviceEnabled) {
      return;
    }

    LocationPermission permission = await Geolocator.checkPermission();
    if (permission == LocationPermission.denied) {
      permission = await Geolocator.requestPermission();
      if (permission == LocationPermission.denied) {
        return;
      }
    }

    try {
      Position position = await Geolocator.getCurrentPosition();
      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
        _updateMarker(_selectedLocation);
      });

      final GoogleMapController controller = await _controller.future;
      controller.animateCamera(CameraUpdate.newCameraPosition(
        CameraPosition(target: _selectedLocation, zoom: 15),
      ));
    } catch (e) {
      debugPrint('Error getting location: $e');
    }
  }

  void _updateMarker(LatLng position) {
    setState(() {
      markers = {
        Marker(
          markerId: const MarkerId('selected_location'),
          position: position,
          draggable: true,
          onDragEnd: (newPosition) {
            setState(() {
              _selectedLocation = newPosition;
            });
          },
        ),
      };
    });
  }

  Future<List<Prediction>> _fetchSuggestions(String input) async {
    if (input.isEmpty) return [];

    try {
      final response = await _places.autocomplete(input);
      return response.predictions;
    } catch (e) {
      debugPrint('Error fetching suggestions: $e');
      return [];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const CustomTitleBar(title: "Pick Location"),
      body: Stack(
        children: [
          GoogleMap(
            mapType: MapType.normal,
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 15,
            ),
            onMapCreated: _controller.complete,
            markers: markers,
            onTap: (position) {
              setState(() {
                _selectedLocation = position;
                _updateMarker(position);
              });
            },
          ),
          Positioned(
            top: 10,
            left: 15,
            right: 15,
            child: TypeAheadField<Prediction>(
              controller: _searchController,
              builder: (context, controller, focusNode) {
                return TextField(
                  controller: controller,
                  focusNode: focusNode,
                  decoration: InputDecoration(
                    hintText: 'Search location...',
                    fillColor: Colors.white,
                    filled: true,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(10),
                      borderSide: BorderSide.none,
                    ),
                    prefixIcon: const Icon(Icons.search),
                  ),
                );
              },
              suggestionsCallback: _fetchSuggestions,
              itemBuilder: (context, Prediction suggestion) {
                return ListTile(
                  title: Text(suggestion.description ?? ''),
                );
              },
              onSelected: (Prediction suggestion) async {
                final details =
                    await _places.getDetailsByPlaceId(suggestion.placeId!);
                final location = details.result.geometry!.location;
                final newPosition = LatLng(location.lat, location.lng);

                setState(() {
                  _selectedLocation = newPosition;
                  _updateMarker(newPosition);
                });

                final GoogleMapController controller = await _controller.future;
                controller.animateCamera(CameraUpdate.newCameraPosition(
                  CameraPosition(target: newPosition, zoom: 15),
                ));
              },
            ),
          ),
          Positioned(
            bottom: 20,
            left: 20,
            right: 20,
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              decoration: BoxDecoration(
                color: Colors.white,
                borderRadius: BorderRadius.circular(12),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.1),
                    blurRadius: 10,
                    offset: const Offset(0, 5),
                  ),
                ],
              ),
              child: CustomButton(
                onPressed: () {
                  widget.onLocationPicked(
                    _selectedLocation.latitude,
                    _selectedLocation.longitude,
                  );
                  Navigator.pop(context);
                },
                gradient: [lightGreen, lightGreen.withOpacity(0.8)],
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text(
                    'Confirm Location',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w600,
                      color: Colors.white,
                    ),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
