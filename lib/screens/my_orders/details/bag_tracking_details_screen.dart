import 'package:flutter/material.dart';
import '../../../models/orders/order_detail_model.dart';
import '../../../services/orders/order_detail_service.dart';
import '../../../widgets/order_details/generic_order_header.dart';
import '../../../widgets/order_details/tracking_status_card.dart';
import '../../../widgets/order_details/order_action_buttons.dart';
import '../../../widgets/cancel_order_dialog.dart';

class BagTrackingDetailsScreen extends StatefulWidget {
  final int orderId;

  const BagTrackingDetailsScreen({super.key, required this.orderId});

  @override
  State<BagTrackingDetailsScreen> createState() =>
      _BagTrackingDetailsScreenState();
}

class _BagTrackingDetailsScreenState extends State<BagTrackingDetailsScreen> {
  final OrderDetailService _service = OrderDetailService();
  OrderDetailModel? _order;
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadDetails();
  }

  Future<void> _loadDetails() async {
    try {
      final order = await _service.getOrderDetail(widget.orderId);
      setState(() {
        _order = order;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
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
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          'Order Details',
          style: TextStyle(
              color: Color(0xFF274C77),
              fontWeight: FontWeight.w600,
              fontSize: 20),
        ),
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF274C77)))
          : _error != null
              ? Center(child: Text(_error!))
              : _buildBody(),
    );
  }

  Widget _buildBody() {
    final order = _order!;
    return SingleChildScrollView(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          GenericOrderHeader(
            title: order.packageName,
            orderId: order.orderId.toString(),
            status: order.status,
            iconPath: 'assets/images/bag_tracking_icon.png',
            numberOfBags: order.numberOfBags.toString(),
            totalWeight: '${order.totalWeight} kg',
          ),
          const SizedBox(height: 20),
          TrackingStatusCard(
            steps: order.trackingStatus
                .map((s) => TrackingStep(
                      title: s.step,
                      subtitle: s.description,
                      dateTime: s.timestamp,
                      isCompleted: s.isDone,
                      isPending: !s.isDone,
                    ))
                .toList(),
          ),
          const SizedBox(height: 30),
          OrderActions(
            showBoardingPass: false,
            onCancel: order.canCancel
                ? () => showCancelOrderDialog(context, orderId: widget.orderId)
                : () {},
          ),
        ],
      ),
    );
  }
}
