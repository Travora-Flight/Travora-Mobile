import 'package:flutter/material.dart';
import 'package:graduation_project/models/home/flight_model.dart';

class MyFlightsScreen extends StatelessWidget {
  const MyFlightsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<FlightModel> myFlights = [
      FlightModel(
        flightNumber: 'TK1885',
        flightStatus: 'On Time',
        departureIataCode: 'ADB',
        arrivalIataCode: 'VIE',
        airlineName: 'Turkish Airlines',
        aircraftRegistrationNumber: 'TC-JVC',
        scheduledArrivalTime: '1h 15m',
        airlineLogoUrl: 'assets/images/turkish_airlines_logo.png',
        liveProgress: 0.6,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text("My Flights",
            style: TextStyle(
                color: Color(0xFF274C77),
                fontWeight: FontWeight.bold,
                fontSize: 22)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF274C77)),
          onPressed: () => Navigator.pop(context),
        ),
      ),
      body: myFlights.isEmpty
          ? const Center(child: Text("No flights found"))
          : ListView.builder(
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 15),
              itemCount: myFlights.length,
              itemBuilder: (context, index) {
                return Padding(
                  padding: const EdgeInsets.only(bottom: 20),
                  child: FlightTrackingCard(flight: myFlights[index]),
                );
              },
            ),
    );
  }
}

class FlightTrackingCard extends StatelessWidget {
  final FlightModel flight;
  const FlightTrackingCard({super.key, required this.flight});

  @override
  Widget build(BuildContext context) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
      decoration: BoxDecoration(
        color: const Color(0xFF274C77).withOpacity(0.85),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  Image.asset(
                    flight.airlineLogoUrl,
                    height: 35,
                    errorBuilder: (context, error, stackTrace) => const Icon(
                        Icons.airplanemode_active,
                        color: Colors.white),
                  ),
                  const SizedBox(width: 8),
                  Text(flight.flightNumber,
                      style: const TextStyle(
                          color: Colors.white,
                          fontSize: 20,
                          fontWeight: FontWeight.bold)),
                ],
              ),
              Row(
                children: [
                  _buildIdChip('40751'),
                  const SizedBox(width: 8),
                  _buildIdChip(flight.aircraftRegistrationNumber),
                ],
              ),
            ],
          ),
          const SizedBox(height: 32),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              _buildCityBox(
                  "Izmir", flight.departureIataCode, CrossAxisAlignment.start),
              Expanded(
                child: Padding(
                  padding:
                      const EdgeInsets.only(bottom: 15, left: 12, right: 12),
                  child: Stack(
                    alignment: Alignment.center,
                    clipBehavior: Clip.none,
                    children: [
                      Row(
                        children: [
                          Expanded(
                            flex: (flight.liveProgress * 5).toInt(),
                            child: const Divider(
                                color: Color(0xFF8C2019), thickness: 2.5),
                          ),
                          Expanded(
                            flex: 5 - (flight.liveProgress * 5).toInt(),
                            child: Divider(
                                color: Colors.white.withOpacity(0.3),
                                thickness: 2.5),
                          ),
                        ],
                      ),
                      Align(
                        alignment: Alignment(
                          (flight.liveProgress * 2) - 1.0,
                          0,
                        ),
                        child: Image.asset(
                          'assets/images/tracking_container.png',
                          width: 28,
                          height: 28,
                          errorBuilder: (context, error, stackTrace) =>
                              const Icon(Icons.flight,
                                  color: Colors.white, size: 20),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
              _buildCityBox(
                  "Vienna", flight.arrivalIataCode, CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
      ),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 12, fontWeight: FontWeight.w600)),
    );
  }

  Widget _buildCityBox(String city, String code, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(city, style: const TextStyle(color: Colors.white70, fontSize: 14)),
        Text(code,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                height: 1.0)),
      ],
    );
  }
}
