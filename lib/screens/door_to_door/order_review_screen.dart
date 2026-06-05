import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../../screens/webview_screen/payment_webview_screen.dart';
import 'order_success_screen.dart';
import '../../../widgets/order_review_card.dart';
import '../../../services/customs_services/customs_service.dart';
import '../../../services/payment_service/payment_service.dart';
import '../../../models/servicess/customs_models/invoice_model.dart';
import '../../models/profile/payment_model.dart';

class OrderReviewScreen extends StatefulWidget {
  const OrderReviewScreen({super.key});

  @override
  State<OrderReviewScreen> createState() => _OrderReviewScreenState();
}

class _OrderReviewScreenState extends State<OrderReviewScreen> {
  final CustomsService _customsService = CustomsService();
  final PaymentService _paymentService = PaymentService();

  bool _isLoading = true;
  bool _isPaying = false;

  double _subtotal = 0;
  double _customsValue = 0;
  double _customsFee = 0;
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
        _customsService.getInvoice(),
        _paymentService.getPaymentData(),
      ]);

      final InvoiceModel invoice = results[0] as InvoiceModel;
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
        _customsValue = invoice.breakdown.customsValue;
        _customsFee = invoice.breakdown.customsFee;
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
      final result = await _customsService.confirmOrder();

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
                orderNo: result.orderNumber,
                bags: _totalBags.toString(),
                name: _userName,
                amount: result.totalPaid.toStringAsFixed(2),
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
                    serviceName: "Door to door service",
                    userName: _userName,
                    lastFourDigits: _lastFourDigits,
                    fees: {
                      "Subtotal": _subtotal.toStringAsFixed(2),
                      "Customs value": _customsValue.toStringAsFixed(2),
                      "Customs fee": _customsFee.toStringAsFixed(2),
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
