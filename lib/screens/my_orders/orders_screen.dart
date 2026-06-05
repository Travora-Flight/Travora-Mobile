import 'package:flutter/material.dart';
import '../../widgets/custom_bottom_nav.dart';
import '../../widgets/order_card.dart';
import '../../models/orders/order_model.dart';
import '../../services/orders/order_service.dart';
import '../home/home_screen.dart';
import '../tracker/tracker_screen.dart';
import '../notifications/notifications_screen.dart';
import 'details/door_to_door_details_screen.dart';
import 'details/car_airport_details_screen.dart';
import 'details/car_home_details_screen.dart';
import 'details/bag_tracking_details_screen.dart';

class OrdersScreen extends StatefulWidget {
  const OrdersScreen({super.key});

  @override
  State<OrdersScreen> createState() => _OrdersScreenState();
}

class _OrdersScreenState extends State<OrdersScreen> {
  int _selectedIndex = 3;
  final OrdersService _ordersService = OrdersService();

  List<OrderModel> _orders = [];
  bool _isLoading = true;
  String? _errorMessage;

  @override
  void initState() {
    super.initState();
    _fetchOrders();
  }

  Future<void> _fetchOrders() async {
    try {
      setState(() {
        _isLoading = true;
        _errorMessage = null;
      });
      final orders = await _ordersService.getOrders();
      setState(() {
        _orders = orders;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _errorMessage = e.toString();
        _isLoading = false;
      });
    }
  }

  String _getIconPath(String packageName) {
    final name = packageName.toLowerCase();
    if (name.contains('airport')) {
      return 'assets/images/car_service_icon.png';
    } else if (name.contains('door')) {
      return 'assets/images/door_to_door_icon.png';
    } else if (name.contains('bag') || name.contains('track')) {
      return 'assets/images/bag_tracking_icon.png';
    }
    return 'assets/images/car_service_icon.png';
  }

  void _navigateToDetails(BuildContext context, OrderModel order) {
    final name = order.packageName.toLowerCase();
    Widget screen;

    if (name.contains('door')) {
      screen = DoorToDoorDetailsScreen(orderId: order.orderId);
    } else if (name.contains('airport')) {
      screen = CarAirportDetailsScreen(orderId: order.orderId);
    } else if (name.contains('home') || name.contains('car')) {
      screen = CarHomeDetailsScreen(orderId: order.orderId);
    } else if (name.contains('bag') || name.contains('track')) {
      screen = BagTrackingDetailsScreen(orderId: order.orderId);
    } else {
      screen = DoorToDoorDetailsScreen(orderId: order.orderId);
    }

    Navigator.push(context, MaterialPageRoute(builder: (context) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios,
              color: Color(0xFF274C77), size: 20),
          onPressed: () => Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const HomeScreen()),
          ),
        ),
        title: const Text(
          'My Orders',
          style: TextStyle(
            color: Color(0xFF274C77),
            fontWeight: FontWeight.bold,
            fontSize: 20,
          ),
        ),
      ),
      body: _buildBody(),
      bottomNavigationBar: CustomBottomNav(
        currentIndex: _selectedIndex,
        onTap: (index) {
          if (index == _selectedIndex) return;
          _handleNavigation(index);
        },
      ),
    );
  }

  Widget _buildBody() {
    if (_isLoading) {
      return const Center(
        child: CircularProgressIndicator(color: Color(0xFF274C77)),
      );
    }

    if (_errorMessage != null) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.error_outline, color: Colors.red, size: 48),
            const SizedBox(height: 16),
            Text(
              _errorMessage!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: Colors.red),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: _fetchOrders,
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF274C77),
              ),
              child: const Text('Try Again',
                  style: TextStyle(color: Colors.white)),
            ),
          ],
        ),
      );
    }

    if (_orders.isEmpty) {
      return _buildEmptyBody();
    }

    return _buildOrdersList();
  }

  Widget _buildOrdersList() {
    return RefreshIndicator(
      color: const Color(0xFF274C77),
      onRefresh: _fetchOrders,
      child: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
        itemCount: _orders.length,
        itemBuilder: (context, index) {
          final order = _orders[index];
          return Padding(
            padding: const EdgeInsets.only(bottom: 8),
            child: OrderCard(
              title: order.packageName,
              orderId: order.orderId.toString(),
              statusText: order.orderStatus,
              iconPath: _getIconPath(order.packageName),
              onTap: () => _navigateToDetails(context, order),
            ),
          );
        },
      ),
    );
  }

  Widget _buildEmptyBody() {
    return Center(
      child: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/empty_orders_icon.png',
              width: 190,
              cacheWidth: 500,
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 52),
            const Text(
              'NO ORDER FOUND',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 20,
                fontWeight: FontWeight.w800,
                color: Color.fromARGB(255, 0, 0, 0),
              ),
            ),
            const SizedBox(height: 22),
            const Text(
              'Looks like you haven\'t made your order yet',
              textAlign: TextAlign.center,
              maxLines: 1,
              style: TextStyle(
                fontFamily: 'Inter',
                fontSize: 14,
                fontWeight: FontWeight.w500,
                color: Color(0xFF6B7D94),
              ),
            ),
            const SizedBox(height: 52),
          ],
        ),
      ),
    );
  }

  void _handleNavigation(int index) {
    if (index == 0) {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => const HomeScreen()));
    } else if (index == 1) {
      Navigator.pushReplacement(context,
          MaterialPageRoute(builder: (context) => const TrackerScreen()));
    } else if (index == 2) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (context) => const NotificationsPage()),
      ).then((_) {
        setState(() => _selectedIndex = 3);
      });
    }
  }
}
