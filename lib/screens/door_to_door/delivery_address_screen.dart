import 'package:flutter/material.dart';
import 'date_time_screen.dart';
import 'package:graduation_project/widgets/pickup_delivery_screens/delivery_address_screen.dart'
    as ui;
import 'package:graduation_project/services/door_to_door_service/resolve_location_service.dart';
import 'package:graduation_project/services/door_to_door_service/update_location_service.dart';

class DeliveryAddressScreen extends StatelessWidget {
  const DeliveryAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resolveService = ResolveLocationService();
    final updateService = DoorToDoorUpdateLocationService();

    return ui.DeliveryAddressScreen(
      onResolveLocation: (lat, lng) => resolveService.resolveLocation(
        latitude: lat,
        longitude: lng,
        locationType: 'Delivery',
      ),
      onUpdateLocation: (data) async {
        await updateService.updateLocation(locationData: data);
      },
      onConfirm: () {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => const DateTimeScreen(),
          ),
        );
      },
    );
  }
}
