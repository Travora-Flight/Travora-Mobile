import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/pickup_delivery_screens/pickup_address_screen.dart'
    as custom_widget;
import 'package:graduation_project/services/car_service/resolve_location_service.dart';
import 'package:graduation_project/services/car_service/update_location_service.dart';
import 'package:graduation_project/screens/car_service/to_airport/date_time_screen.dart';

class PickupAddressScreen extends StatelessWidget {
  const PickupAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final service = CarResolveLocationService();
    final updateService = CarServiceUpdateLocationService();

    return custom_widget.PickupAddressScreen(
      readOnlyLocationType: true,
      onResolveLocation: (lat, lng) => service.resolveLocation(
        latitude: lat,
        longitude: lng,
      ),
      onUpdateLocation: (data) async {
        await updateService.updateLocation(locationData: data);
      },
      onConfirm: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const PickupDateTimeScreen(),
          ),
        );
      },
    );
  }
}
