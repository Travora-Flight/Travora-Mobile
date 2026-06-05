import 'package:flutter/material.dart';
import 'package:google_maps_flutter/google_maps_flutter.dart';
import '../../models/servicess/resolve_location.dart';
import '../../models/servicess/update_location.dart';
import 'map_picker_screen.dart';

class DeliveryAddressScreen extends StatefulWidget {
  final VoidCallback onConfirm;
  final Future<ResolveLocationModel> Function(double latitude, double longitude)
      onResolveLocation;
  final Future<void> Function(UpdateLocationModel data) onUpdateLocation;
  final bool readOnlyLocationType;

  const DeliveryAddressScreen({
    super.key,
    required this.onConfirm,
    required this.onResolveLocation,
    required this.onUpdateLocation,
    this.readOnlyLocationType = false,
  });

  @override
  State<DeliveryAddressScreen> createState() => _DeliveryAddressScreenState();
}

class _DeliveryAddressScreenState extends State<DeliveryAddressScreen> {
  final TextEditingController _locationTypeController = TextEditingController();
  final TextEditingController _streetController = TextEditingController();
  final TextEditingController _stateController = TextEditingController();
  final TextEditingController _cityController = TextEditingController();
  final TextEditingController _countryController = TextEditingController();
  final TextEditingController _postalCodeController = TextEditingController();

  bool _locationResolved = false;
  bool _isUpdating = false;

  @override
  void dispose() {
    _locationTypeController.dispose();
    _streetController.dispose();
    _stateController.dispose();
    _cityController.dispose();
    _countryController.dispose();
    _postalCodeController.dispose();
    super.dispose();
  }

  Future<void> _openMapPicker() async {
    final LatLng? result = await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => const MapPickerScreen()),
    );

    if (result != null) {
      await _resolveLocation(
          latitude: result.latitude, longitude: result.longitude);
    }
  }

  Future<void> _resolveLocation({
    required double latitude,
    required double longitude,
  }) async {
    try {
      final result = await widget.onResolveLocation(latitude, longitude);

      if (!result.isValid && result.streetAddress == null) {
        _showError(result.errorMessage ?? 'Invalid location.');
        return;
      }

      setState(() {
        _locationTypeController.text = result.locationType ?? '';
        _streetController.text = result.streetAddress ?? '';
        _cityController.text = result.city ?? '';
        _stateController.text = result.state ?? '';
        _countryController.text = result.country ?? '';
        _postalCodeController.text = result.postalCode ?? '';
        _locationResolved = true;
      });
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    }
  }

  Future<void> _onConfirmPressed() async {
    if (!_locationResolved) {
      _showError('Please detect your location first.');
      return;
    }

    setState(() => _isUpdating = true);

    try {
      final updateData = UpdateLocationModel(
        locationType: _locationTypeController.text,
        streetAddress: _streetController.text,
        city: _cityController.text,
        state: _stateController.text,
        country: _countryController.text,
        postalCode: _postalCodeController.text,
      );

      await widget.onUpdateLocation(updateData);
      widget.onConfirm();
    } catch (e) {
      _showError(e.toString().replaceFirst('Exception: ', ''));
    } finally {
      setState(() => _isUpdating = false);
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
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF274C77)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Delivery Address",
          style:
              TextStyle(color: Color(0xFF274C77), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildField(
                "Street Address", "Enter Street Address", _streetController),
            _buildField("State", "Enter State", _stateController),
            _buildField("City", "Enter City", _cityController),
            _buildField("Country", "Enter Country", _countryController),
            _buildField(
                "Postal Code", "Enter Postal Code", _postalCodeController),
            const SizedBox(height: 10),
            GestureDetector(
              onTap: _openMapPicker,
              child: ClipRRect(
                borderRadius: BorderRadius.circular(15),
                child: Container(
                  height: 150,
                  width: double.infinity,
                  color: const Color(0xFFF1F4F8),
                  child: _locationResolved
                      ? const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle,
                                color: Color(0xFF274C77), size: 50),
                            SizedBox(height: 8),
                            Text(
                              'Location detected!',
                              style: TextStyle(
                                  color: Color(0xFF274C77),
                                  fontWeight: FontWeight.w500),
                            ),
                            Text(
                              'Tap to update',
                              style: TextStyle(
                                  color: Color(0xFF7B7B7B), fontSize: 12),
                            ),
                          ],
                        )
                      : const Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.my_location,
                                color: Color(0xFF274C77), size: 50),
                            SizedBox(height: 8),
                            Text(
                              'Tap to pick your location',
                              style: TextStyle(
                                  color: Color(0xFF274C77),
                                  fontWeight: FontWeight.w500),
                            ),
                          ],
                        ),
                ),
              ),
            ),
            const SizedBox(height: 20),
            _buildConfirmButton(),
          ],
        ),
      ),
    );
  }

  Widget _buildField(
    String label,
    String hint,
    TextEditingController controller, {
    bool readOnly = false,
  }) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            label,
            style: const TextStyle(
              fontWeight: FontWeight.w500,
              fontSize: 16,
              color: Colors.black,
            ),
          ),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            readOnly: readOnly,
            style: readOnly ? const TextStyle(color: Color(0xFF7B7B7B)) : null,
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF7B7B7B), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF274C77).withOpacity(0.20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF274C77), Color(0xFFA3CEF1)]),
          borderRadius: BorderRadius.circular(16)),
      child: ElevatedButton(
          onPressed: _isUpdating ? null : _onConfirmPressed,
          style: ElevatedButton.styleFrom(
              backgroundColor: Colors.transparent,
              shadowColor: Colors.transparent),
          child: _isUpdating
              ? const SizedBox(
                  height: 22,
                  width: 22,
                  child: CircularProgressIndicator(
                      color: Colors.white, strokeWidth: 2.5),
                )
              : const Text("Confirm",
                  style: TextStyle(
                      color: Colors.white, fontWeight: FontWeight.bold))),
    );
  }
}
