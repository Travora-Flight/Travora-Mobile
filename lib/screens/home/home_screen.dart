import 'package:flutter/material.dart';
import '../../widgets/service_card.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../profile/profile_screen.dart';
import '../tracker/tracker_screen.dart';
import '../notifications/notifications_screen.dart';
import 'package:graduation_project/screens/my_orders/orders_screen.dart';
import 'package:graduation_project/screens/door_to_door/door_to_door_screen.dart';
import 'package:graduation_project/screens/car_service/car_service_screen.dart';
import 'package:graduation_project/screens/bag_tracking/bag_tracking_screen.dart';
import '../../models/home/flight_model.dart';
import '../../models/home/order_model.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _isReady = true;
  int _selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    final flightData = FlightModel(
      flightNumber: 'TK1885',
      flightStatus: 'On Time',
      departureIataCode: 'ADB',
      arrivalIataCode: 'VIE',
      airlineName: 'Turkish Airlines',
      aircraftRegistrationNumber: 'TC-JVC',
      scheduledArrivalTime: '1h 15m',
      airlineLogoUrl: 'assets/images/turkish_airlines_logo.png',
      liveProgress: 0.5,
    );

    final orderData = OrderModel(
      orderId: '1657392',
      status: 'Bags Loads',
      baggageCount: 2,
      totalAmount: '45.0',
    );

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: !_isReady
            ? const Center(
                child: CircularProgressIndicator(
                    color: Color(0xFF274C77), strokeWidth: 2))
            : SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          SizedBox(
                            width: 165,
                            height: 65,
                            child: Align(
                              alignment: Alignment.centerLeft,
                              child: FractionalTranslation(
                                translation: const Offset(0.4, 0.0),
                                child: Transform.scale(
                                  scale: 2.5,
                                  child: Image.asset(
                                    'assets/images/logo_travora.png',
                                    fit: BoxFit.contain,
                                    color: const Color(0xFF274C77),
                                  ),
                                ),
                              ),
                            ),
                          ),
                          GestureDetector(
                            onTap: () => Navigator.push(
                                context,
                                MaterialPageRoute(
                                    builder: (context) =>
                                        const ProfileScreen())),
                            child: Container(
                              width: 40,
                              height: 40,
                              decoration: BoxDecoration(
                                color:
                                    const Color(0xFF274C77).withOpacity(0.25),
                                shape: BoxShape.circle,
                              ),
                              child: Center(
                                child: Image.asset(
                                    'assets/images/profile_icon.png',
                                    height: 30,
                                    width: 30),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 2),
                    Padding(
                      padding: const EdgeInsets.symmetric(horizontal: 24),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Services',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D2733))),
                          const SizedBox(height: 8),
                          GridView.count(
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            crossAxisCount: 2,
                            crossAxisSpacing: 16,
                            mainAxisSpacing: 16,
                            childAspectRatio: 0.82,
                            children: [
                              ServiceCard(
                                title: 'Flight tracker',
                                imagePath:
                                    'assets/images/flight_tracker_Icon.png',
                                subtitle:
                                    'Track your flight in real-time with live updates',
                                bubbleColor: const Color(0xFFE8EFF5),
                                borderColor:
                                    const Color(0xFF274C77).withOpacity(0.5),
                                iconBgColor:
                                    const Color(0xFF274C77).withOpacity(0.25),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const TrackerScreen())),
                              ),
                              ServiceCard(
                                title: 'Door to door',
                                imagePath:
                                    'assets/images/door_to_door_icon.png',
                                subtitle:
                                    'Complete delivery service from pickup to doorstep',
                                bubbleColor:
                                    const Color(0xFFA3CEF1).withOpacity(0.1),
                                borderColor:
                                    const Color(0xFFA3CEF1).withOpacity(0.5),
                                iconBgColor:
                                    const Color(0xFFA3CEF1).withOpacity(0.25),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const DoorToDoorScreen())),
                              ),
                              ServiceCard(
                                title: 'Car service',
                                imagePath: 'assets/images/car_service_icon.png',
                                subtitle:
                                    'Premium car rental and transfer services',
                                bubbleColor:
                                    const Color(0xFFA3CEF1).withOpacity(0.1),
                                borderColor:
                                    const Color(0xFFA3CEF1).withOpacity(0.5),
                                iconBgColor:
                                    const Color(0xFFA3CEF1).withOpacity(0.25),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const CarServiceScreen())),
                              ),
                              ServiceCard(
                                title: 'Bag tracking',
                                imagePath:
                                    'assets/images/bag_tracking_icon.png',
                                subtitle:
                                    'Monitor your luggage location throughout trip',
                                bubbleColor: const Color(0xFFE8EFF5),
                                borderColor:
                                    const Color(0xFF274C77).withOpacity(0.5),
                                iconBgColor:
                                    const Color(0xFF274C77).withOpacity(0.25),
                                onTap: () => Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            const BagTrackingScreen())),
                              ),
                            ],
                          ),
                          const SizedBox(height: 15),
                          const Text('Tracking',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D2733))),
                          const SizedBox(height: 8),
                          _buildTrackingCard(flight: flightData),
                          const SizedBox(height: 15),
                          const Text('My orders',
                              style: TextStyle(
                                  fontFamily: 'Inter',
                                  fontSize: 18,
                                  fontWeight: FontWeight.w700,
                                  color: Color(0xFF1D2733))),
                          const SizedBox(height: 16),
                          _buildOrdersCard(order: orderData),
                          const SizedBox(height: 40),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
      ),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;
          setState(() => _selectedIndex = index);
          if (index == 1)
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const TrackerScreen()));
          else if (index == 2)
            Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (context) => const NotificationsPage()),
            ).then((_) {
              setState(() => _selectedIndex = 0);
            });
          else if (index == 3)
            Navigator.pushReplacement(context,
                MaterialPageRoute(builder: (context) => const OrdersScreen()));
        },
      ),
    );
  }

  Widget _buildTrackingCard({required FlightModel flight}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 30),
      decoration: BoxDecoration(
        color: const Color(0xFF274C77).withOpacity(0.7),
        borderRadius: BorderRadius.circular(26),
      ),
      child: Column(
        children: [
          Transform.translate(
            offset: const Offset(0, -10),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Row(
                  children: [
                    Image.asset(flight.airlineLogoUrl, height: 36),
                    const SizedBox(width: 8),
                    Text(flight.flightNumber,
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 14,
                            fontWeight: FontWeight.w600)),
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
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              _cityBox(
                  'Izmir', flight.departureIataCode, CrossAxisAlignment.start),
              Expanded(
                child: Column(
                  children: [
                    Text(flight.scheduledArrivalTime,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 14)),
                    const SizedBox(height: 6),
                    Stack(
                      alignment: Alignment.center,
                      children: [
                        const Divider(color: Colors.white, thickness: 1.5),
                        Align(
                          alignment: Alignment.centerLeft,
                          child: FractionallySizedBox(
                            widthFactor: flight.liveProgress,
                            child: const Divider(
                                color: Color(0xFF8C2019), thickness: 2),
                          ),
                        ),
                        Align(
                          alignment: Alignment(flight.liveProgress * 2 - 1, 0),
                          child: Image.asset(
                              'assets/images/tracking_container.png',
                              width: 30,
                              height: 30),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
              _cityBox(
                  'Vienna', flight.arrivalIataCode, CrossAxisAlignment.end),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildIdChip(String text) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
          color: Colors.white.withOpacity(0.25),
          borderRadius: BorderRadius.circular(12)),
      child: Text(text,
          style: const TextStyle(
              color: Colors.white, fontSize: 11, fontWeight: FontWeight.w600)),
    );
  }

  Widget _cityBox(String city, String code, CrossAxisAlignment align) {
    return Column(
      crossAxisAlignment: align,
      children: [
        Text(city, style: const TextStyle(color: Colors.white, fontSize: 12)),
        Text(code,
            style: const TextStyle(
                color: Colors.white,
                fontSize: 24,
                fontWeight: FontWeight.bold)),
      ],
    );
  }

  Widget _buildOrdersCard({required OrderModel order}) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(26),
        border: Border.all(
            color: const Color(0xFF274C77).withOpacity(0.5), width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
                color: const Color(0xFF274C77).withOpacity(0.20),
                borderRadius: BorderRadius.circular(16)),
            child:
                Image.asset('assets/images/door_to_door_icon.png', height: 30),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text('Door To Door',
                    style: TextStyle(
                        fontWeight: FontWeight.w800,
                        fontSize: 16,
                        color: Color(0xFF1D2733))),
                const SizedBox(height: 6),
                Text('ID : ${order.orderId}',
                    style: const TextStyle(
                        color: Color(0xFF6B7D94), fontSize: 12)),
                const SizedBox(height: 12),
                Row(
                  children: [
                    const Icon(Icons.check_circle_outline,
                        size: 14, color: Color(0xFF6B7D94)),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                          color: const Color(0xFF274C77).withOpacity(0.2),
                          borderRadius: BorderRadius.circular(12)),
                      child: Text(order.status,
                          style: const TextStyle(
                              fontSize: 11,
                              fontWeight: FontWeight.w600,
                              color: Color(0xFF274C77))),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(14),
              gradient: const LinearGradient(
                  colors: [Color(0xFFA3CEF1), Color(0xFF274C77)]),
            ),
            child:
                const Icon(Icons.arrow_outward, size: 20, color: Colors.white),
          ),
        ],
      ),
    );
  }
}
