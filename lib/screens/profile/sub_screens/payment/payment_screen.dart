import 'package:flutter/material.dart';
import 'saved_payment_screen.dart';
import 'add_new_card_screen.dart';
import 'package:graduation_project/services/payment_service/payment_service.dart';
import 'package:graduation_project/models/profile/payment_model.dart';

class PaymentScreen extends StatefulWidget {
  const PaymentScreen({super.key});

  @override
  State<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends State<PaymentScreen> {
  final Color _boxColor = const Color(0xFF274C77).withOpacity(0.25);
  final Color _borderColor = const Color(0xFF274C77);

  bool _isBalanceVisible = true;
  final PaymentService _paymentService = PaymentService();

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
        title: const Text('Payment',
            style: TextStyle(
                color: Color(0xFF274C77),
                fontWeight: FontWeight.bold,
                fontSize: 20)),
      ),
      body: FutureBuilder<PaymentResponse>(
        future: _paymentService.getPaymentData(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF274C77)));
          } else if (snapshot.hasError) {
            return Center(child: Text("Error: ${snapshot.error}"));
          } else if (!snapshot.hasData) {
            return const Center(child: Text("No data found"));
          }

          final data = snapshot.data!;

          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 24.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                _buildBalanceCard(data.balance.toStringAsFixed(2)),
                const SizedBox(height: 32),
                const Text('Your Payments',
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.black)),
                const SizedBox(height: 16),
                Wrap(
                  spacing: 12,
                  runSpacing: 12,
                  children: [
                    ...data.paymentMethods.map((card) => SizedBox(
                          width: (MediaQuery.of(context).size.width - 60) / 2,
                          child: _buildSavedCardItem(card),
                        )),
                    SizedBox(
                      width: (MediaQuery.of(context).size.width - 60) / 2,
                      child: _buildAddNewCardButton(),
                    ),
                  ],
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildBalanceCard(String balance) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
          color: _boxColor,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: _borderColor)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text('Your Balance',
              style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1D2733))),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_isBalanceVisible ? '$balance\$' : '****',
                  style: const TextStyle(
                      fontSize: 22,
                      fontWeight: FontWeight.w500,
                      color: Color(0xFF404040))),
              IconButton(
                icon: Icon(
                    _isBalanceVisible
                        ? Icons.visibility_outlined
                        : Icons.visibility_off_outlined,
                    color: Colors.grey[700]),
                onPressed: () =>
                    setState(() => _isBalanceVisible = !_isBalanceVisible),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSavedCardItem(PaymentCardModel card) {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(
            builder: (context) => SavedPaymentScreen(paymentMethod: card),
          ),
        );

        if (result == true) {
          setState(() {});
        }
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
            color: _boxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor)),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Row(
                    children: [
                      Flexible(
                        child: Text(
                          card.cardBrand.toUpperCase(),
                          overflow: TextOverflow.ellipsis,
                          maxLines: 1,
                          style: const TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Color(0xFF274C77),
                              fontSize:
                                  12, 
                              fontStyle: FontStyle.italic),
                        ),
                      ),
                      const SizedBox(width: 4),
                      if (card.isDefault)
                        Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 4, vertical: 2),
                            decoration: BoxDecoration(
                                color: const Color(0xFF274C77).withOpacity(0.2),
                                borderRadius: BorderRadius.circular(8)),
                            child: const Text("Main",
                                style: TextStyle(
                                    fontSize: 8, color: Color(0xFF274C77)))),
                    ],
                  ),
                  const SizedBox(height: 4),
                  Text("**** ${card.cardLastFour}",
                      overflow: TextOverflow.ellipsis,
                      style: TextStyle(
                          fontSize: 11,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color)),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios,
                size: 12, color: Color(0xFF274C77)),
          ],
        ),
      ),
    );
  }

  Widget _buildAddNewCardButton() {
    return InkWell(
      onTap: () async {
        final result = await Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const AddNewCardScreen()),
        );
        if (result == true) setState(() {});
      },
      borderRadius: BorderRadius.circular(12),
      child: Container(
        height: 80,
        decoration: BoxDecoration(
            color: _boxColor,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: _borderColor)),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: const [
            Icon(Icons.add, color: Colors.black),
            SizedBox(height: 4),
            Text("Add New Card",
                textAlign: TextAlign.center,
                style: TextStyle(
                    fontSize: 11,
                    color: Colors.black,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
