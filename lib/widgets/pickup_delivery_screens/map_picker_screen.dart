import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import 'package:geolocator/geolocator.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

class MapPickerScreen extends StatefulWidget {
  const MapPickerScreen({super.key});

  @override
  State<MapPickerScreen> createState() => _MapPickerScreenState();
}

class _MapPickerScreenState extends State<MapPickerScreen> {
  GoogleMapController? _mapController;
  final TextEditingController _searchController = TextEditingController();

  LatLng _selectedLocation = const LatLng(30.0444, 31.2357); // Cairo default
  bool _isLoadingLocation = false;
  List<dynamic> _predictions = [];
  bool _showPredictions = false;

  static const String _apiKey = 'AIzaSyCV4S4XJVLJT57AK-OUZTfs4etIavBuPkQ';

  @override
  void dispose() {
    _searchController.dispose();
    _mapController?.dispose();
    super.dispose();
  }

  Future<void> _searchPlaces(String query) async {
    if (query.isEmpty) {
      setState(() {
        _predictions = [];
        _showPredictions = false;
      });
      return;
    }

    final url =
        'https://maps.googleapis.com/maps/api/place/autocomplete/json?input=${Uri.encodeComponent(query)}&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      setState(() {
        _predictions = data['predictions'];
        _showPredictions = true;
      });
    }
  }

  Future<void> _selectPlace(String placeId) async {
    final url =
        'https://maps.googleapis.com/maps/api/place/details/json?place_id=$placeId&key=$_apiKey';

    final response = await http.get(Uri.parse(url));
    final data = json.decode(response.body);

    if (data['status'] == 'OK') {
      final lat = data['result']['geometry']['location']['lat'];
      final lng = data['result']['geometry']['location']['lng'];

      setState(() {
        _selectedLocation = LatLng(lat, lng);
        _showPredictions = false;
        _searchController.clear();
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation, 16),
      );
    }
  }

  Future<void> _detectCurrentLocation() async {
    setState(() => _isLoadingLocation = true);

    try {
      bool serviceEnabled = await Geolocator.isLocationServiceEnabled();
      if (!serviceEnabled) {
        _showError('Location services are disabled. Please enable GPS.');
        return;
      }

      LocationPermission permission = await Geolocator.checkPermission();
      if (permission == LocationPermission.denied) {
        permission = await Geolocator.requestPermission();
        if (permission == LocationPermission.denied) {
          _showError('Location permission denied.');
          return;
        }
      }
      if (permission == LocationPermission.deniedForever) {
        _showError(
            'Location permission permanently denied. Please enable it from settings.');
        return;
      }

      Position position = await Geolocator.getCurrentPosition(
        desiredAccuracy: LocationAccuracy.high,
      );

      setState(() {
        _selectedLocation = LatLng(position.latitude, position.longitude);
      });

      _mapController?.animateCamera(
        CameraUpdate.newLatLngZoom(_selectedLocation, 16),
      );
    } catch (e) {
      _showError('Something went wrong. Please try again.');
    } finally {
      setState(() => _isLoadingLocation = false);
    }
  }

  void _showError(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text(message), backgroundColor: Colors.red),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Stack(
        children: [
          // Google Map
          GoogleMap(
            initialCameraPosition: CameraPosition(
              target: _selectedLocation,
              zoom: 14,
            ),
            onMapCreated: (controller) => _mapController = controller,
            onCameraMove: (position) {
              _selectedLocation = position.target;
            },
            myLocationEnabled: true,
            myLocationButtonEnabled: false,
            zoomControlsEnabled: false,
          ),

          // Pin in center
          const Center(
            child: Padding(
              padding: EdgeInsets.only(bottom: 40),
              child:
                  Icon(Icons.location_pin, color: Color(0xFF274C77), size: 45),
            ),
          ),

          SafeArea(
            child: Column(
              children: [
                Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  child: Row(
                    children: [
                      GestureDetector(
                        onTap: () => Navigator.pop(context),
                        child: Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(10),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: const Icon(Icons.arrow_back_ios,
                              color: Color(0xFF274C77), size: 20),
                        ),
                      ),
                      const SizedBox(width: 10),
                      // Search bar
                      Expanded(
                        child: Container(
                          decoration: BoxDecoration(
                            color: Colors.white,
                            borderRadius: BorderRadius.circular(12),
                            boxShadow: [
                              BoxShadow(color: Colors.black12, blurRadius: 4)
                            ],
                          ),
                          child: TextField(
                            controller: _searchController,
                            onChanged: _searchPlaces,
                            decoration: const InputDecoration(
                              hintText: 'Search for an address...',
                              hintStyle: TextStyle(
                                  color: Color(0xFF7B7B7B), fontSize: 14),
                              prefixIcon:
                                  Icon(Icons.search, color: Color(0xFF274C77)),
                              border: InputBorder.none,
                              contentPadding:
                                  EdgeInsets.symmetric(vertical: 12),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                if (_showPredictions && _predictions.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.symmetric(horizontal: 12),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: ListView.separated(
                      shrinkWrap: true,
                      padding: EdgeInsets.zero,
                      itemCount: _predictions.length,
                      separatorBuilder: (_, __) =>
                          const Divider(height: 1, color: Color(0xFFEEEEEE)),
                      itemBuilder: (context, index) {
                        final prediction = _predictions[index];
                        return ListTile(
                          leading: const Icon(Icons.location_on_outlined,
                              color: Color(0xFF274C77)),
                          title: Text(
                            prediction['description'],
                            style: const TextStyle(fontSize: 13),
                            maxLines: 2,
                          ),
                          onTap: () => _selectPlace(prediction['place_id']),
                        );
                      },
                    ),
                  ),
              ],
            ),
          ),

          Positioned(
            bottom: 30,
            left: 20,
            right: 20,
            child: Column(
              children: [
                GestureDetector(
                  onTap: _isLoadingLocation ? null : _detectCurrentLocation,
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    decoration: BoxDecoration(
                      color: Colors.white,
                      borderRadius: BorderRadius.circular(12),
                      boxShadow: [
                        BoxShadow(color: Colors.black12, blurRadius: 4)
                      ],
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        _isLoadingLocation
                            ? const SizedBox(
                                width: 18,
                                height: 18,
                                child: CircularProgressIndicator(
                                    strokeWidth: 2, color: Color(0xFF274C77)),
                              )
                            : const Icon(Icons.my_location,
                                color: Color(0xFF274C77), size: 20),
                        const SizedBox(width: 8),
                        const Text(
                          'Detect Current Location',
                          style: TextStyle(
                              color: Color(0xFF274C77),
                              fontWeight: FontWeight.w600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 12),
                // Confirm button
                Container(
                  width: double.infinity,
                  height: 50,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                        colors: [Color(0xFF274C77), Color(0xFFA3CEF1)]),
                    borderRadius: BorderRadius.circular(16),
                  ),
                  child: ElevatedButton(
                    onPressed: () {
                      Navigator.pop(context, _selectedLocation);
                    },
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.transparent,
                        shadowColor: Colors.transparent),
                    child: const Text(
                      'Confirm Location',
                      style: TextStyle(
                          color: Colors.white, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
