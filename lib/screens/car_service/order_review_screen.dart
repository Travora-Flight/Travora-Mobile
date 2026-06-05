import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/webview_screen/payment_webview_screen.dart';
import 'order_success_screen.dart';
import '../../../widgets/order_review_card.dart';
import '../../services/car_service/order_review_service.dart';
import '../../services/payment_service/payment_service.dart';
import '../../models/servicess/car_service/invoice.dart';
import '../../models/profile/payment_model.dart';

class CarServiceOrderReviewScreen extends StatefulWidget {
  const CarServiceOrderReviewScreen({super.key});

  @override
  State<CarServiceOrderReviewScreen> createState() =>
      _CarServiceOrderReviewScreenState();
}

class _CarServiceOrderReviewScreenState
    extends State<CarServiceOrderReviewScreen> {
  final CarServiceOrderService _orderService = CarServiceOrderService();
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = true;
  bool _isPaying = false;

  double _subtotal = 0;
  double _extraBaggageFee = 0;
  double _taxAmount = 0;
  double _totalAmount = 0;
  int _totalBags = 0;

  String _userName = '';
  String _lastFourDigits = '';

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    try {
      final results = await Future.wait([
        _orderService.getInvoice(),
        _paymentService.getPaymentData(),
      ]);

      final CarServiceInvoiceModel invoice =
          results[0] as CarServiceInvoiceModel;
      final PaymentResponse paymentData = results[1] as PaymentResponse;

      final prefs = await SharedPreferences.getInstance();
      final firstName = prefs.getString('firstName') ?? '';

      PaymentCardModel? defaultCard;
      if (paymentData.paymentMethods.isNotEmpty) {
        defaultCard = paymentData.paymentMethods.firstWhere(
          (card) => card.isDefault,
          orElse: () => paymentData.paymentMethods.first,
        );
      }

      setState(() {
        _subtotal = invoice.breakdown.subtotal;
        _extraBaggageFee = invoice.breakdown.baggageDetails.extraBaggageFee;
        _taxAmount = invoice.breakdown.taxAmount;
        _totalAmount = invoice.breakdown.totalAmount;
        _totalBags = invoice.breakdown.baggageDetails.totalBags;
        _userName = defaultCard?.cardHolderName ?? firstName;
        _lastFourDigits = defaultCard?.cardLastFour ?? '';
        _isLoading = false;
      });
    } catch (e) {
      setState(() => _isLoading = false);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  Future<void> _onPayPressed(String total) async {
    setState(() => _isPaying = true);

    try {
      final result = await _orderService.confirmOrder();

      if (!result.success) {
        throw Exception(result.errorMessage ?? "Something went wrong");
      }

      final paymentUrl = await _paymentService.initiatePayment(
        orderId: result.orderId,
      );

      if (paymentUrl.isEmpty) {
        throw Exception("Payment URL not received");
      }

      if (!mounted) return;

      // تثبيت مرجع الـ Navigator لمنع الـ Crash والخروج من التطبيق
      final navigator = Navigator.of(context);

      final bool? isPaymentSuccessful = await navigator.push<bool>(
        MaterialPageRoute(
          builder: (context) => PaymentWebViewScreen(
            url: paymentUrl,
            successUrl: "payments/callback",
          ),
        ),
      );

      if (!mounted) return;

      if (isPaymentSuccessful == true) {
        final status = await _paymentService.getPaymentStatus(
          orderId: result.orderId,
        );

        if (status.isPaid) {
          if (!mounted) return;

          navigator.pushAndRemoveUntil(
            MaterialPageRoute(
              builder: (context) => OrderSuccessScreen(
                orderNumber: result.orderNumber,
                numberOfBags: _totalBags.toString(),
                customerName: _userName,
                totalAmount: result.totalPaid.toStringAsFixed(2),
              ),
            ),
            (route) => false,
          );
        } else {
          if (!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text("Payment not confirmed yet, please try again"),
              backgroundColor: Colors.orange,
            ),
          );
        }
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text("Payment was cancelled or failed"),
            backgroundColor: Colors.orange,
          ),
        );
      }
    } catch (e) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(e.toString().replaceAll("Exception: ", "")),
          backgroundColor: Colors.red,
        ),
      );
    } finally {
      if (mounted) setState(() => _isPaying = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    const Color darkBlue = Color(0xFF274C77);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: darkBlue),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Order Review",
          style: TextStyle(color: darkBlue, fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator(color: darkBlue))
          : Stack(
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20),
                  child: OrderReviewWidget(
                    serviceName: "Car Service",
                    userName: _userName,
                    lastFourDigits: _lastFourDigits,
                    fees: {
                      "Subtotal": _subtotal.toStringAsFixed(2),
                      "Extra Baggage Fee": _extraBaggageFee.toStringAsFixed(2),
                      "Taxes": _taxAmount.toStringAsFixed(2),
                    },
                    onPayPressed: _isPaying ? (_) {} : _onPayPressed,
                  ),
                ),
                if (_isPaying)
                  Container(
                    color: Colors.black.withOpacity(0.3),
                    child: const Center(
                      child: CircularProgressIndicator(color: darkBlue),
                    ),
                  ),
              ],
            ),
    );
  }
}
