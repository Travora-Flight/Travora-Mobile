import 'package:flutter/material.dart';
import 'package:flutter/services.dart'; 
import 'package:graduation_project/core/theme/app_colors.dart';
import 'package:graduation_project/services/payment_service/payment_service.dart';

class AddNewCardScreen extends StatefulWidget {
  const AddNewCardScreen({super.key});

  @override
  State<AddNewCardScreen> createState() => _AddNewCardScreenState();
}

class _AddNewCardScreenState extends State<AddNewCardScreen> {
  final _formKey = GlobalKey<FormState>();
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _cardNumberController = TextEditingController();
  final TextEditingController _expiryController = TextEditingController();
  final TextEditingController _cvvController = TextEditingController();

  final PaymentService _paymentService = PaymentService();

  @override
  void dispose() {
    _nameController.dispose();
    _cardNumberController.dispose();
    _expiryController.dispose();
    _cvvController.dispose();
    super.dispose();
  }

  Future<void> _selectDate(BuildContext context) async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2040),
    );
    if (picked != null) {
      setState(() {
        _expiryController.text =
            "${picked.month.toString().padLeft(2, '0')}/${picked.year.toString().substring(2)}";
      });
    }
  }

  void _onConfirm() async {
    if (_formKey.currentState!.validate()) {
      List<String> expiryParts = _expiryController.text.split('/');
      int month =
          expiryParts.isNotEmpty ? int.tryParse(expiryParts[0]) ?? 0 : 0;
      int year =
          expiryParts.length > 1 ? int.tryParse("20${expiryParts[1]}") ?? 0 : 0;

      final Map<String, dynamic> cardData = {
        "cardHolderName": _nameController.text,

        "cardNumber": _cardNumberController.text.replaceAll(' ', ''),
        "expiryMonth": month,
        "expiryYear": year,
        "cvv": _cvvController.text,
        "paymentFunding": "Credit"
      };

      bool success = await _paymentService.addPaymentMethod(cardData);

      if (success) {
        if (!mounted) return;
        Navigator.pop(context, true);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Card Added Successfully!")),
        );
      } else {
        if (!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
              content: Text("Failed to add card. Please try again.")),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        backgroundColor: AppColors.background,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: AppColors.primary, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text('Payment Information',
            style: TextStyle(
                color: AppColors.primary,
                fontWeight: FontWeight.bold,
                fontSize: 18)),
        actions: [
          IconButton(
            icon: Icon(Icons.close, color: AppColors.primary, size: 24),
            onPressed: () => Navigator.pop(context),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24.0),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildEmptyCardPreview(),
              const SizedBox(height: 30),
              _buildInputField("Card Holder Name", "Enter Card Holder Name",
                  _nameController),
              const SizedBox(height: 20),
              _buildInputField(
                  "Card Number", "Enter Card Num", _cardNumberController,
                  isNumber: true,
                  maxLength: 19),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text("Expiry Date",
                            style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w500,
                                color: Theme.of(context)
                                    .textTheme
                                    .bodyLarge
                                    ?.color)),
                        const SizedBox(height: 8),
                        TextFormField(
                          controller: _expiryController,
                          readOnly: true,
                          onTap: () => _selectDate(context),
                          validator: (value) => (value == null || value.isEmpty)
                              ? "Field Required"
                              : null,
                          style: const TextStyle(
                              fontSize: 14, color: Color(0xFF7B7B7B)),
                          decoration: InputDecoration(
                            counterText: "",
                            hintText: "MM/YY",
                            hintStyle: const TextStyle(
                                color: Color(0xFF7B7B7B), fontSize: 14),
                            filled: true,
                            fillColor: const Color(0xFF274C77).withOpacity(0.2),
                            border: OutlineInputBorder(
                                borderRadius: BorderRadius.circular(16),
                                borderSide: BorderSide.none),
                            contentPadding: const EdgeInsets.symmetric(
                                horizontal: 16, vertical: 14),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  Expanded(
                      child: _buildInputField("CVV", "000", _cvvController,
                          isNumber: true, maxLength: 3)),
                ],
              ),
            ],
          ),
        ),
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(24.0, 0, 24.0, 48.0),
        child: _buildConfirmButton(),
      ),
    );
  }

  Widget _buildEmptyCardPreview() {
    return Container(
      width: double.infinity,
      height: 190,
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: const Color(0xFF1E3A5F),
        borderRadius: BorderRadius.circular(16),
        boxShadow: [
          BoxShadow(
              color: Colors.black.withOpacity(0.2),
              blurRadius: 10,
              offset: const Offset(0, 5))
        ],
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Credit",
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: 13)),
              Text("VISA",
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 18,
                      fontStyle: FontStyle.italic)),
            ],
          ),
          const SizedBox(height: 10),
          Container(
            width: 45,
            height: 32,
            alignment: Alignment.center,
            decoration: BoxDecoration(
                color: const Color(0xFFC0A060),
                borderRadius: BorderRadius.circular(5)),
            child: Image.asset('assets/images/visa_icon.png',
                height: 18,
                fit: BoxFit.contain,
                errorBuilder: (context, error, stackTrace) => Icon(
                    Icons.credit_card,
                    color: Theme.of(context).scaffoldBackgroundColor,
                    size: 18)),
          ),
          const Spacer(),
          Text("*************",
              style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w400)),
          Text("**** **** **** ****",
              style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 18,
                  letterSpacing: 2,
                  fontWeight: FontWeight.w500)),
          const SizedBox(height: 5),
        ],
      ),
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController controller,
      {bool isNumber = false, int? maxLength}) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label,
            style: TextStyle(
                fontSize: 16,
                fontWeight: FontWeight.w500,
                color: Theme.of(context).textTheme.bodyLarge?.color)),
        const SizedBox(height: 8),
        TextFormField(
          controller: controller,
          keyboardType: isNumber ? TextInputType.number : TextInputType.text,
          maxLength: maxLength,
          inputFormatters: (label == "Card Number")
              ? [
                  FilteringTextInputFormatter.digitsOnly,
                  CardNumberFormatter(),
                ]
              : null,
          validator: (value) =>
              (value == null || value.isEmpty) ? "Field Required" : null,
          style: const TextStyle(fontSize: 14, color: Color(0xFF7B7B7B)),
          decoration: InputDecoration(
            counterText: "",
            hintText: hint,
            hintStyle: const TextStyle(color: Color(0xFF7B7B7B), fontSize: 14),
            filled: true,
            fillColor: const Color(0xFF274C77).withOpacity(0.2),
            border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(16),
                borderSide: BorderSide.none),
            contentPadding:
                const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
          ),
        ),
      ],
    );
  }

  Widget _buildConfirmButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          gradient: AppColors.mainGradient,
          boxShadow: AppColors.buttonShadow),
      child: ElevatedButton(
        onPressed: _onConfirm,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent,
            shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(16))),
        child: Text("Confirm",
            style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 18,
                fontWeight: FontWeight.w600)),
      ),
    );
  }
}

class CardNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    var text = newValue.text;
    if (newValue.selection.baseOffset == 0) return newValue;

    var buffer = StringBuffer();
    for (int i = 0; i < text.length; i++) {
      buffer.write(text[i]);
      var nonSpaceLength = i + 1;
      if (nonSpaceLength % 4 == 0 && nonSpaceLength != text.length) {
        buffer.write(' ');
      }
    }

    var string = buffer.toString();
    return newValue.copyWith(
        text: string,
        selection: TextSelection.collapsed(offset: string.length));
  }
}
