import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'pickup_address_screen.dart';
import 'package:graduation_project/screens/auth/signup/passport_scanner_screen.dart';
import 'package:graduation_project/services/door_to_door_service/door_to_door_service.dart';
import 'package:graduation_project/models/servicess/validate_flight_request.dart';
import 'package:graduation_project/models/servicess/validate_flight_response.dart';
import 'package:graduation_project/models/servicess/validate_companion_request.dart';
import 'package:graduation_project/models/servicess/validate_companion_response.dart';
import 'package:image_picker/image_picker.dart';

class DoorToDoorScreen extends StatefulWidget {
  const DoorToDoorScreen({super.key});

  @override
  State<DoorToDoorScreen> createState() => _DoorToDoorScreenState();
}

class _MemberData {
  final TextEditingController ticketController = TextEditingController();
  File? passportImageFile;

  void dispose() {
    ticketController.dispose();
  }
}

class _DoorToDoorScreenState extends State<DoorToDoorScreen> {
  String _flightStatus = 'idle';
  bool isFlightDataVisible = true;
  bool _isCheckingFlight = false;
  final TextEditingController _ticketNumController = TextEditingController();
  final TextEditingController _flightNumController = TextEditingController();
  final TextEditingController _depDateController = TextEditingController();
  final TextEditingController _totalBagsController = TextEditingController();

  final List<_MemberData> _members = [];

  final DoorToDoorService _doorToDoorService = DoorToDoorService();

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
    for (var m in _members) m.dispose();
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

  Future<void> _showImagePickerSheet(int index) async {
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
                  final File? result = await Navigator.push<File>(
                    context,
                    MaterialPageRoute(
                        builder: (_) => const PassportScannerScreen()),
                  );
                  if (result != null) {
                    setState(() {
                      _members[index].passportImageFile = result;
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
                  final picker = ImagePicker();
                  final picked =
                      await picker.pickImage(source: ImageSource.gallery);
                  if (picked != null) {
                    setState(() {
                      _members[index].passportImageFile = File(picked.path);
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
          await _doorToDoorService.validateFlight(request);

      if (response.isValid) {
        setState(() {
          _flightStatus = 'valid';
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

        if (_members.isNotEmpty) {
          final companionsOk = await _checkCompanions();
          if (companionsOk) {
            await _goToNextScreen();
          }
        } else {
          await _goToNextScreen();
        }
      } else {
        setState(() => _flightStatus = 'invalid');
        _showSnackBar(response.errorMessage ??
            "There is no flight assigned to your Passport Num");
      }
    } catch (e) {
      setState(() => _flightStatus = 'invalid');
      _showSnackBar(_parseError(e));
    } finally {
      setState(() => _isCheckingFlight = false);
    }
  }

  Future<bool> _checkCompanions() async {
    for (int i = 0; i < _members.length; i++) {
      final member = _members[i];

      if (member.ticketController.text.trim().isEmpty) {
        _showSnackBar("Member ${i + 1}: Please enter Ticket Number");
        return false;
      }

      if (member.passportImageFile == null) {
        _showSnackBar("Member ${i + 1}: Please upload Passport Photo");
        return false;
      }

      try {
        final request = ValidateCompanionRequest(
          ticketNumber: member.ticketController.text.trim(),
        );

        final ValidateCompanionResponse response =
            await _doorToDoorService.validateCompanion(
          requestData: request,
          passportImagePath: member.passportImageFile!.path,
        );

        if (!response.isValid) {
          _showSnackBar(
            "Member ${i + 1}: ${response.errorMessage ?? 'Invalid companion data'}",
          );
          return false;
        }
      } catch (e) {
        _showSnackBar("Member ${i + 1}: ${_parseError(e)}");
        return false;
      }
    }
    return true;
  }

  Future<void> _goToNextScreen() async {
    try {
      final baggageResult = await _doorToDoorService.validateBaggage();
      if (baggageResult.isValid) {
        Navigator.push(
          context,
          MaterialPageRoute(
            builder: (_) => PickupAddressScreen(),
          ),
        );
      } else {
        _showSnackBar(
            baggageResult.errorMessage ?? "Baggage validation failed");
      }
    } catch (e) {
      _showSnackBar(_parseError(e));
    }
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
          "Door-to-door",
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
            if (_members.isNotEmpty)
              ListView.builder(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                itemCount: _members.length,
                itemBuilder: (context, index) => _buildMemberCard(index),
              ),
            TextButton(
              onPressed: () => setState(() {
                _members.add(_MemberData());
              }),
              child: const Text("+ add member",
                  style: TextStyle(
                      color: Color(0xFF274C77),
                      fontWeight: FontWeight.bold,
                      decoration: TextDecoration.underline)),
            ),
            const SizedBox(height: 10),
            if (_flightStatus == 'valid')
              _buildValidFlightCard()
            else if (_flightStatus == 'invalid')
              _buildInvalidMessage()
            else
              const SizedBox(height: 50),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildMemberCard(int index) {
    final member = _members[index];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Divider(height: 40, color: Colors.black, thickness: 1),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text("Member ${index + 1} data",
                style: const TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: Colors.black)),
            IconButton(
              icon: const Icon(Icons.delete_outline, color: Colors.red),
              onPressed: () => setState(() {
                _members.removeAt(index);
              }),
            ),
          ],
        ),
        const SizedBox(height: 10),
        _buildInputField(
            "Ticket Num", "Enter Ticket Num", member.ticketController),
        _buildUploadButton(index),
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

  Widget _buildUploadButton(int index) {
    final member = _members[index];
    final hasImage = member.passportImageFile != null;

    return SizedBox(
      width: double.infinity,
      height: 90,
      child: ElevatedButton(
        onPressed: () => _showImagePickerSheet(index),
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
              "No flight assigned to your Passport Num",
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
                _flightStatus == 'valid' ? "Next" : "Check Flight",
                style: const TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                    fontSize: 16),
              ),
      ),
    );
  }
}
