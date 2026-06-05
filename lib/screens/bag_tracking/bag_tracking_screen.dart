import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'scan_bags_screen.dart';
import 'package:graduation_project/screens/auth/signup/passport_scanner_screen.dart';
import 'package:graduation_project/services/bag_tracking_service/bag_tracking_service.dart';
import 'package:graduation_project/models/servicess/validate_flight_request.dart';
import 'package:graduation_project/models/servicess/validate_flight_response.dart';
import 'package:graduation_project/models/servicess/validate_companion_request.dart';
import 'package:graduation_project/models/servicess/validate_companion_response.dart';

class BagTrackingScreen extends StatefulWidget {
  const BagTrackingScreen({super.key});

  @override
  State<BagTrackingScreen> createState() => _BagTrackingScreenState();
}

class _BagTrackingScreenState extends State<BagTrackingScreen> {
  String status = 'idle';
  bool isFlightDataVisible = true;
  bool _isCheckingFlight = false;

  final TextEditingController _ticketNumController = TextEditingController();
  final TextEditingController _flightNumController = TextEditingController();
  final TextEditingController _depDateController = TextEditingController();
  final TextEditingController _totalBagsController = TextEditingController();
  final List<TextEditingController> _companionTicketControllers = [];
  final List<File?> _companionImages = [];

  final BagTrackingService _bagTrackingService = BagTrackingService();

  String passengerName = "";
  String seatNumber = "";
  String terminalGate = "";
  String travelClass = "";
  String boardingTime = "";
  String flightDate = "";

  @override
  void dispose() {
    _ticketNumController.dispose();
    _flightNumController.dispose();
    _depDateController.dispose();
    _totalBagsController.dispose();
    for (var c in _companionTicketControllers) c.dispose();
    super.dispose();
  }

  void _showSnackBar(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: const Color(0xFFDC3545),
      ),
    );
  }

  String _parseError(Object e) {
    if (e is Exception) {
      return e.toString().replaceFirst("Exception: ", "");
    }
    return e.toString();
  }

  Future<void> _checkFlight() async {
    if (_ticketNumController.text.trim().isEmpty) {
      _showSnackBar("Please enter Ticket Number");
      return;
    }
    if (_flightNumController.text.trim().isEmpty) {
      _showSnackBar("Please enter Flight Number");
      return;
    }
    if (_depDateController.text.trim().isEmpty) {
      _showSnackBar("Please select Departure Date");
      return;
    }
    if (_totalBagsController.text.trim().isEmpty) {
      _showSnackBar("Please enter Total Bags");
      return;
    }

    try {
      setState(() => _isCheckingFlight = true);

      final request = ValidateFlightRequest(
        ticketNumber: _ticketNumController.text.trim(),
        flightNumber: _flightNumController.text.trim(),
        flightDate: _depDateController.text.trim(),
        baggageCount: int.tryParse(_totalBagsController.text.trim()) ?? 0,
      );

      final ValidateFlightResponse response =
          await _bagTrackingService.validateFlight(request);

      if (response.isValid) {
        setState(() {
          status = 'valid';
          passengerName =
              "${response.passengerInfo?.firstName ?? ''} ${response.passengerInfo?.lastName ?? ''}"
                  .trim();
          seatNumber = response.passengerInfo?.seatNumber ?? '';
          terminalGate =
              "${response.flightInfo?.terminal ?? ''} • Gate ${response.flightInfo?.gate ?? ''}";
          travelClass = response.passengerInfo?.travelClass ?? '';
          boardingTime = response.flightInfo?.boardingTimeUtc ?? '';
          flightDate = response.flightInfo?.flightDate ?? '';
        });

        if (_companionTicketControllers.isNotEmpty) {
          final companionsOk = await _checkCompanions();
          if (companionsOk) {
            await _goToNextScreen();
          }
        } else {
          await _goToNextScreen();
        }
      } else {
        setState(() => status = 'invalid');
        _showSnackBar(response.errorMessage ??
            "There is no flight assigned to your Passport Num");
      }
    } catch (e) {
      setState(() => status = 'invalid');
      _showSnackBar(_parseError(e));
    } finally {
      setState(() => _isCheckingFlight = false);
    }
  }

  Future<bool> _checkCompanions() async {
    for (int i = 0; i < _companionTicketControllers.length; i++) {
      final ticketNum = _companionTicketControllers[i].text.trim();
      final image = _companionImages[i];

      if (ticketNum.isEmpty) {
        _showSnackBar("Member ${i + 2}: Please enter Ticket Number");
        return false;
      }

      if (image == null) {
        _showSnackBar("Member ${i + 2}: Please upload Passport Photo");
        return false;
      }

      try {
        final request = ValidateCompanionRequest(
          ticketNumber: ticketNum,
        );

        final ValidateCompanionResponse response =
            await _bagTrackingService.validateCompanion(
          requestData: request,
          passportImagePath: image.path,
        );

        if (!response.isValid) {
          _showSnackBar(
            "Member ${i + 2}: ${response.errorMessage ?? 'Invalid companion data'}",
          );
          return false;
        }
      } catch (e) {
        _showSnackBar("Member ${i + 2}: ${_parseError(e)}");
        return false;
      }
    }
    return true;
  }

  Future<void> _goToNextScreen() async {
    try {
      final baggageResult = await _bagTrackingService.validateBaggage();
      if (baggageResult.isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => const ScanBagsScreen()),
        );
      } else {
        _showSnackBar(
            baggageResult.errorMessage ?? "Baggage validation failed");
      }
    } catch (e) {
      _showSnackBar(_parseError(e));
    }
  }

  Future<File?> _pickImageFromGallery() async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: ImageSource.gallery);
    if (picked != null) return File(picked.path);
    return null;
  }

  Future<void> _pickDepDate() async {
    final now = DateTime.now();
    final firstOfMonth = DateTime(now.year, now.month, 1);
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: firstOfMonth,
      firstDate: firstOfMonth,
      lastDate: DateTime(2030),
    );
    if (picked != null) {
      setState(() {
        _depDateController.text =
            "${picked.month}/${picked.day.toString().padLeft(2, '0')}/${picked.year}";
      });
    }
  }

  void _addMember() {
    setState(() {
      _companionTicketControllers.add(TextEditingController());
      _companionImages.add(null);
    });
  }

  void _removeMember(int indexInList) {
    setState(() {
      _companionTicketControllers[indexInList].dispose();
      _companionTicketControllers.removeAt(indexInList);
      _companionImages.removeAt(indexInList);
    });
  }

  Future<void> _showImagePickerSheet(int companionIndex) async {
    await showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) => SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                margin: const EdgeInsets.only(bottom: 20),
                decoration: BoxDecoration(
                  color: Colors.grey[300],
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const Text(
                "Upload Passport Photo",
                style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                    color: Colors.black),
              ),
              const SizedBox(height: 20),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F0FB),
                  child:
                      Icon(Icons.camera_alt_outlined, color: Color(0xFF274C77)),
                ),
                title: const Text("Scan Passport",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final File? result = await Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => const PassportScannerScreen()),
                  );
                  if (result != null) {
                    setState(() {
                      _companionImages[companionIndex] = result;
                    });
                  }
                },
              ),
              const Divider(),
              ListTile(
                leading: const CircleAvatar(
                  backgroundColor: Color(0xFFE8F0FB),
                  child: Icon(Icons.photo_library_outlined,
                      color: Color(0xFF274C77)),
                ),
                title: const Text("Upload from Gallery",
                    style: TextStyle(fontWeight: FontWeight.w500)),
                onTap: () async {
                  Navigator.pop(ctx);
                  final File? result = await _pickImageFromGallery();
                  if (result != null) {
                    setState(() {
                      _companionImages[companionIndex] = result;
                    });
                  }
                },
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF274C77)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text(
          "Bag Tracking",
          style:
              TextStyle(color: Color(0xFF274C77), fontWeight: FontWeight.bold),
        ),
        centerTitle: true,
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.fromLTRB(20, 0, 20, 30),
        child: _buildNextButton(),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text("Flight data",
                    style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black)),
                IconButton(
                  icon: Icon(
                    isFlightDataVisible
                        ? Icons.keyboard_arrow_up
                        : Icons.keyboard_arrow_down,
                    color: Colors.black,
                    size: 30,
                  ),
                  onPressed: () => setState(
                      () => isFlightDataVisible = !isFlightDataVisible),
                ),
              ],
            ),
            const SizedBox(height: 10),
            Visibility(
              visible: isFlightDataVisible,
              child: Column(
                children: [
                  _buildInputField(
                      "Ticket Num", "Enter Ticket Num", _ticketNumController),
                  _buildInputField(
                      "Flight Num", "Enter Flight Num", _flightNumController),
                  Row(
                    children: [
                      Expanded(
                          child:
                              _buildDatePickerField("DEP Date", "M/DD/YYYY")),
                      const SizedBox(width: 15),
                      Expanded(
                          child: _buildNumberInputField(
                              "Total Bags", "0", _totalBagsController)),
                    ],
                  ),
                  const Padding(
                    padding: EdgeInsets.only(bottom: 10),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.red, size: 16),
                        SizedBox(width: 6),
                        Expanded(
                          child: Text(
                            "Note: Total bags include you and all added members (if applicable).",
                            style: TextStyle(
                              color: Colors.red,
                              fontSize: 12,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
            if (_companionTicketControllers.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _companionTicketControllers.length,
                itemBuilder: (context, i) => _buildMemberCard(i),
              ),
            TextButton(
              onPressed: _addMember,
              child: const Text("+ add member",
                  style: TextStyle(
                      color: Color(0xFF274C77),
                      fontWeight: FontWeight.w600,
                      decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 10),
            if (status == 'valid')
              _buildValidFlightCard()
            else if (status == 'invalid')
              _buildInvalidMessage()
            else
              const SizedBox(height: 50),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(int i) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40, color: Colors.black, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Member ${i + 2} data",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => _removeMember(i),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInputField(
            "Ticket Num", "Enter Ticket Num", _companionTicketControllers[i]),
        _buildUploadButton(i),
        const Padding(
          padding: EdgeInsets.only(top: 10, left: 5),
          child: Text(
            "Note: members must be in the same flight number",
            style: TextStyle(
                color: Colors.red, fontSize: 12, fontWeight: FontWeight.w500),
          ),
        ),
        const SizedBox(height: 20),
      ],
    );
  }

  Widget _buildInputField(
      String label, String hint, TextEditingController? controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF7B7B7B), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF274C77).withOpacity(0.20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNumberInputField(
      String label, String hint, TextEditingController? controller) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black)),
          const SizedBox(height: 8),
          TextField(
            controller: controller,
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.digitsOnly,
            ],
            style: const TextStyle(color: Colors.black, fontSize: 14),
            decoration: InputDecoration(
              hintText: hint,
              hintStyle:
                  const TextStyle(color: Color(0xFF7B7B7B), fontSize: 14),
              filled: true,
              fillColor: const Color(0xFF274C77).withOpacity(0.20),
              border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: BorderSide.none),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildDatePickerField(String label, String hint) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 15),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label,
              style: const TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 16,
                  color: Colors.black)),
          const SizedBox(height: 8),
          GestureDetector(
            onTap: _pickDepDate,
            child: AbsorbPointer(
              child: TextField(
                controller: _depDateController,
                style: const TextStyle(color: Colors.black, fontSize: 14),
                decoration: InputDecoration(
                  hintText: hint,
                  hintStyle:
                      const TextStyle(color: Color(0xFF7B7B7B), fontSize: 14),
                  filled: true,
                  fillColor: const Color(0xFF274C77).withOpacity(0.20),
                  border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none),
                  contentPadding:
                      const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                  suffixIcon: const Icon(Icons.calendar_today,
                      color: Color(0xFF274C77), size: 20),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildUploadButton(int companionIndex) {
    final image = _companionImages[companionIndex];
    final hasImage = image != null;

    return SizedBox(
      width: double.infinity,
      height: 80,
      child: ElevatedButton(
        onPressed: () => _showImagePickerSheet(companionIndex),
        style: ElevatedButton.styleFrom(
          backgroundColor:
              hasImage ? const Color(0xFFE8F5E9) : const Color(0xFFF1F4F8),
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
            side: BorderSide(
              color: hasImage
                  ? const Color(0xFF28A745)
                  : const Color(0xFF7B7B7B).withOpacity(0.5),
              width: hasImage ? 2 : 1,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              hasImage ? Icons.check_circle_outline : Icons.camera_alt_outlined,
              color:
                  hasImage ? const Color(0xFF28A745) : const Color(0xFF7B7B7B),
              size: 28,
            ),
            const SizedBox(width: 12),
            Text(
              hasImage ? "Passport Photo Uploaded ✓" : "Scan Passport",
              style: TextStyle(
                  color: hasImage
                      ? const Color(0xFF28A745)
                      : const Color(0xFF7B7B7B),
                  fontSize: 16),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildValidFlightCard() {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        border: Border.all(color: Colors.black.withOpacity(0.2)),
        borderRadius: BorderRadius.circular(16),
      ),
      child: Column(
        children: [
          const Row(
            children: [
              Icon(Icons.check_circle, color: Color(0xFF28A745), size: 18),
              SizedBox(width: 12),
              Text("Flight found for Passport Number",
                  style: TextStyle(
                      color: Color(0xFF28A745), fontWeight: FontWeight.bold)),
            ],
          ),
          const Divider(height: 32),
          _buildInfoRow("Passenger", passengerName, "Seat", seatNumber),
          const SizedBox(height: 20),
          _buildInfoRow("Terminal/Gate", terminalGate, "Class", travelClass),
          const SizedBox(height: 20),
          _buildInfoRow("Boarding", boardingTime, "Date", flightDate),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String l1, String v1, String l2, String v2) {
    return Row(
      children: [
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l1,
              style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13)),
          Text(v1,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ])),
        Expanded(
            child:
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          Text(l2,
              style: const TextStyle(color: Color(0xFF6C757D), fontSize: 13)),
          Text(v2,
              style:
                  const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
        ])),
      ],
    );
  }

  Widget _buildInvalidMessage() {
    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: const Color(0xFFFFE5E5),
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Row(
        children: [
          Icon(Icons.error_outline, color: Color(0xFFDC3545)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              "There is no flight assigned to your Passport Num",
              style: TextStyle(
                  color: Color(0xFFDC3545), fontWeight: FontWeight.bold),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildNextButton() {
    return Container(
      width: double.infinity,
      height: 50,
      decoration: BoxDecoration(
          gradient: const LinearGradient(
              colors: [Color(0xFF274C77), Color(0xFFA3CEF1)]),
          borderRadius: BorderRadius.circular(16)),
      child: ElevatedButton(
        onPressed: _isCheckingFlight ? null : _checkFlight,
        style: ElevatedButton.styleFrom(
            backgroundColor: Colors.transparent,
            shadowColor: Colors.transparent),
        child: _isCheckingFlight
            ? const SizedBox(
                height: 22,
                width: 22,
                child: CircularProgressIndicator(
                    color: Colors.white, strokeWidth: 2.5))
            : Text(
                status == 'valid' ? "Next" : "Check Flight",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
      ),
    );
  }
}
