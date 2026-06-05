import 'package:flutter/material.dart';
import 'package:graduation_project/widgets/pickup_delivery_screens/delivery_address_screen.dart'
    as delivery_widget;
import 'package:graduation_project/services/car_service/resolve_location_service.dart';
import 'package:graduation_project/services/car_service/update_location_service.dart';
import 'package:graduation_project/screens/car_service/to_home/date_time_screen.dart';

class DeliveryAddressScreen extends StatelessWidget {
  const DeliveryAddressScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final resolveService = CarResolveLocationService();
    final updateService = CarServiceUpdateLocationService();

    return Scaffold(
      body: delivery_widget.DeliveryAddressScreen(
        onResolveLocation: (lat, lng) => resolveService.resolveLocation(
          latitude: lat,
          longitude: lng,
        ),
        onUpdateLocation: (data) async {
          await updateService.updateLocation(locationData: data);
        },
        readOnlyLocationType: true,
        onConfirm: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => const DeliveryDateTimeScreen(),
            ),
          );
        },
      ),
    );
  }
}
