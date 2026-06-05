import 'dart:io';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:image_picker/image_picker.dart';
import 'package:camera/camera.dart';
import 'package:graduation_project/screens/bag_tracking/policy_screen.dart';
import 'package:graduation_project/screens/bag_tracking/camera_scanner_screen.dart';
import 'package:graduation_project/services/bag_tracking_service/scan_bags_service.dart';

class ScanBagsScreen extends StatefulWidget {
  const ScanBagsScreen({super.key});

  @override
  State<ScanBagsScreen> createState() => _ScanBagsScreenState();
}

class _ScanBagsScreenState extends State<ScanBagsScreen> {
  final Color primaryBlue = const Color(0xFF274C77);
  final Color lightBlue = const Color(0xFFA3CEF1);
  final Color borderColor = const Color(0xFF274C77);
  final Color greyText = const Color(0xFF4A5565);
  final Color cardBackground = const Color(0xFF274C77).withOpacity(0.20);
  final Color darkBlueBg = const Color(0xFF101828);

  final ScanBagsService _scanBagsService = ScanBagsService();
  final List<Map<String, String>> scannedBags = [];
  Map<String, String>? _lastScannedBag;

  final TextEditingController _manualTagController = TextEditingController();
  List<File> _capturedImages = [];
  final ImagePicker _picker = ImagePicker();

  bool _isScanning = false;

  Future<void> _pickImageFromCamera(StateSetter setDialogState) async {
    final XFile? photo = await _picker.pickImage(source: ImageSource.camera);
    if (photo != null) {
      setDialogState(() {
        _capturedImages.add(File(photo.path));
      });
    }
  }

  Future<void> _scanBag(String qrData, bool enteredManually) async {
    if (qrData.isEmpty) return;

    setState(() => _isScanning = true);

    try {
      final result = await _scanBagsService.scanBag(
        qrData: qrData,
        enteredManually: enteredManually,
      );

      if (!mounted) return;

      if (result.found && result.bag != null) {
        setState(() {
          _lastScannedBag = {
            "tag": result.bag!.tagNumber,
            "destination": result.bag!.destination ?? 'N/A',
            "weight": '${result.bag!.weightKg ?? '-'} kg',
          };
        });

        _showAddBagDialog(
          tagNumber: result.bag!.tagNumber,
          destination: result.bag!.destination ?? 'N/A',
          weight: '${result.bag!.weightKg ?? '-'} kg',
        );
      } else {
        _showErrorSnackbar(result.errorMessage ?? 'Bag not found.');
      }
    } catch (e) {
      _showErrorSnackbar(e.toString().replaceAll('Exception: ', ''));
    } finally {
      if (mounted) setState(() => _isScanning = false);
    }
  }

  void _showErrorSnackbar(String message) {
    if (!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        backgroundColor: Colors.redAccent,
      ),
    );
  }

  void _showAddBagDialog({
    required String tagNumber,
    required String destination,
    required String weight,
  }) {
    _capturedImages = [];

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext dialogContext) {
        bool isSavingLocal = false;

        return StatefulBuilder(
          builder: (innerContext, setDialogState) {
            return Dialog(
              insetPadding: const EdgeInsets.symmetric(horizontal: 20),
              shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20)),
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text("Add Bag Photos",
                            style: TextStyle(
                                fontSize: 18,
                                fontWeight: FontWeight.bold,
                                color: Colors.black)),
                        IconButton(
                          icon: const Icon(Icons.close, color: Colors.black),
                          onPressed: isSavingLocal
                              ? null
                              : () => Navigator.pop(dialogContext),
                        ),
                      ],
                    ),
                    Text("Tag: $tagNumber",
                        style: TextStyle(color: greyText, fontSize: 13)),
                    const SizedBox(height: 20),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.symmetric(
                          vertical: 15, horizontal: 10),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(12),
                        border: Border.all(color: primaryBlue),
                        color: Colors.white,
                      ),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceAround,
                        children: [
                          _dialogInfoItem("Tag Number", tagNumber),
                          _dialogInfoItem("Destination", destination),
                          _dialogInfoItem("Weight", weight),
                        ],
                      ),
                    ),
                    const SizedBox(height: 20),
                    const Text("Bag Photos",
                        style: TextStyle(
                            fontWeight: FontWeight.bold, color: Colors.black)),
                    const SizedBox(height: 10),
                    GestureDetector(
                      onTap: isSavingLocal
                          ? null
                          : () => _pickImageFromCamera(setDialogState),
                      child: Container(
                        width: double.infinity,
                        height: 60,
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: borderColor, width: 1),
                        ),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.add, color: primaryBlue),
                            const SizedBox(width: 8),
                            Text("Add Photos",
                                style: TextStyle(
                                    color: primaryBlue,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                    ),
                    const SizedBox(height: 8),
                    const Text(
                      "Note: Please take 3 to 6 photos of the bag from all sides",
                      style: TextStyle(
                        color: Colors.red,
                        fontSize: 12,
                        fontWeight: FontWeight.w400,
                      ),
                    ),
                    if (_capturedImages.isNotEmpty) ...[
                      const SizedBox(height: 15),
                      SizedBox(
                        height: 90,
                        child: ListView.builder(
                          scrollDirection: Axis.horizontal,
                          itemCount: _capturedImages.length,
                          itemBuilder: (context, index) {
                            return Padding(
                              padding: const EdgeInsets.only(right: 10),
                              child: Stack(
                                children: [
                                  ClipRRect(
                                    borderRadius: BorderRadius.circular(10),
                                    child: Image.file(_capturedImages[index],
                                        width: 90,
                                        height: 90,
                                        fit: BoxFit.cover),
                                  ),
                                  Positioned(
                                    top: 2,
                                    right: 2,
                                    child: GestureDetector(
                                      onTap: isSavingLocal
                                          ? null
                                          : () {
                                              setDialogState(() {
                                                _capturedImages.removeAt(index);
                                              });
                                            },
                                      child: Container(
                                        decoration: const BoxDecoration(
                                            color: Colors.black54,
                                            shape: BoxShape.circle),
                                        child: const Icon(Icons.close,
                                            color: Colors.white, size: 16),
                                      ),
                                    ),
                                  )
                                ],
                              ),
                            );
                          },
                        ),
                      ),
                    ],
                    const SizedBox(height: 30),
                    Row(
                      children: [
                        Expanded(
                          child: OutlinedButton(
                            onPressed: isSavingLocal
                                ? null
                                : () => Navigator.pop(dialogContext),
                            style: OutlinedButton.styleFrom(
                              padding: const EdgeInsets.symmetric(vertical: 12),
                              shape: RoundedRectangleBorder(
                                  borderRadius: BorderRadius.circular(10)),
                              side: BorderSide(color: primaryBlue),
                            ),
                            child: Text("Cancel",
                                style: TextStyle(color: primaryBlue)),
                          ),
                        ),
                        const SizedBox(width: 15),
                        Expanded(
                          child: isSavingLocal
                              ? Center(
                                  child: CircularProgressIndicator(
                                      color: primaryBlue),
                                )
                              : _buildGradientButton("Save Bag", () async {
                                  if (_capturedImages.length < 3) {
                                    ScaffoldMessenger.of(innerContext)
                                        .showSnackBar(
                                      const SnackBar(
                                        content: Text(
                                            "Please add at least 3 photos of the bag."),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                    return;
                                  }

                                  setDialogState(() => isSavingLocal = true);

                                  final messenger =
                                      ScaffoldMessenger.of(context);

                                  try {
                                    final result =
                                        await _scanBagsService.uploadBagPhotos(
                                      tagNumber: tagNumber,
                                      photos: _capturedImages,
                                    );

                                    final String now =
                                        DateFormat('MM/dd/yyyy, hh:mm:ss a')
                                            .format(DateTime.now());

                                    if (dialogContext.mounted) {
                                      Navigator.of(dialogContext).pop();
                                    }

                                    if (mounted) {
                                      setState(() {
                                        scannedBags.insert(0, {
                                          "tag": tagNumber,
                                          "destination":
                                              result.bag?.destination ??
                                                  destination,
                                          "weight": result.bag != null
                                              ? '${result.bag!.weightKg} kg'
                                              : weight,
                                          "time": now,
                                        });
                                      });
                                    }
                                  } catch (e) {
                                    if (mounted) {
                                      setDialogState(
                                          () => isSavingLocal = false);
                                    }
                                    messenger.showSnackBar(
                                      SnackBar(
                                        content: Text(e
                                            .toString()
                                            .replaceAll('Exception: ', '')),
                                        backgroundColor: Colors.redAccent,
                                      ),
                                    );
                                  }
                                }),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  Widget _dialogInfoItem(String label, String value) {
    return Column(
      children: [
        Text(label,
            style: const TextStyle(fontSize: 11, color: Colors.black54)),
        const SizedBox(height: 4),
        Text(value,
            style: const TextStyle(
                fontSize: 13,
                fontWeight: FontWeight.bold,
                color: Colors.black)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios, color: primaryBlue, size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text("Scan Bags",
            style: TextStyle(color: primaryBlue, fontWeight: FontWeight.bold)),
        centerTitle: true,
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.symmetric(horizontal: 20),
        child: Column(
          children: [
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Scan New Bag",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  const SizedBox(height: 15),
                  GestureDetector(
                    onTap: () async {
                      final cameras = await availableCameras();
                      if (cameras.isNotEmpty) {
                        if (!mounted) return;
                        final scannedData = await Navigator.push<String>(
                          context,
                          MaterialPageRoute(
                            builder: (context) =>
                                CameraScannerScreen(camera: cameras.first),
                          ),
                        );
                        if (scannedData != null && scannedData.isNotEmpty) {
                          await _scanBag(scannedData, false);
                        }
                      }
                    },
                    child: _buildCameraPreviewBox(),
                  ),
                  const SizedBox(height: 15),
                  _buildGradientButton("Take Bag Photos", () {
                    if (_lastScannedBag == null) {
                      _showErrorSnackbar(
                          "Please scan a QR code or enter a tag number first.");
                      return;
                    }
                    _showAddBagDialog(
                      tagNumber: _lastScannedBag!['tag']!,
                      destination: _lastScannedBag!['destination']!,
                      weight: _lastScannedBag!['weight']!,
                    );
                  }),
                  const SizedBox(height: 15),
                  const Divider(color: Color(0xFFE5E7EB)),
                  const SizedBox(height: 10),
                  Text("Or enter tag number manually:",
                      style: TextStyle(color: primaryBlue, fontSize: 14)),
                  const SizedBox(height: 8),
                  _buildManualInput(),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildSectionContainer(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Scanned Bags",
                      style: TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.w400,
                          color: Colors.black)),
                  const SizedBox(height: 15),
                  if (scannedBags.isEmpty)
                    Center(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(vertical: 20),
                        child: Text("No bags scanned yet.",
                            style: TextStyle(color: greyText, fontSize: 14)),
                      ),
                    )
                  else
                    ...scannedBags.asMap().entries.map((entry) {
                      return _buildBagCard(entry.value, entry.key);
                    }),
                ],
              ),
            ),
            const SizedBox(height: 20),
            _buildGradientButton("Next", () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const PolicyScreen()),
              );
            }),
            const SizedBox(height: 20),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionContainer({required Widget child}) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: borderColor),
      ),
      child: child,
    );
  }

  Widget _buildCameraPreviewBox() {
    return Container(
      height: 160,
      width: double.infinity,
      decoration: BoxDecoration(
        color: darkBlueBg,
        borderRadius: BorderRadius.circular(15),
      ),
      child: _isScanning
          ? const Center(child: CircularProgressIndicator(color: Colors.white))
          : Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(Icons.camera_alt_outlined,
                    color: Colors.white54, size: 40),
                const SizedBox(height: 10),
                Text("Ready to scan",
                    style: TextStyle(color: Colors.white.withOpacity(0.6))),
              ],
            ),
    );
  }

  Widget _buildManualInput() {
    return Row(
      children: [
        Expanded(
          child: SizedBox(
            height: 45,
            child: TextField(
              controller: _manualTagController,
              decoration: InputDecoration(
                hintText: "BAG123456",
                hintStyle: const TextStyle(color: Colors.grey, fontSize: 14),
                contentPadding: const EdgeInsets.symmetric(horizontal: 15),
                border:
                    OutlineInputBorder(borderRadius: BorderRadius.circular(10)),
                enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: borderColor),
                    borderRadius: BorderRadius.circular(10)),
              ),
            ),
          ),
        ),
        const SizedBox(width: 10),
        _buildGradientButton(
          "Add",
          () => _scanBag(_manualTagController.text, true),
          width: 80,
        ),
      ],
    );
  }

  Widget _buildBagCard(Map<String, String> bag, int index) {
    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: cardBackground,
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: primaryBlue, width: 1.1),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Icon(Icons.luggage_outlined, color: primaryBlue, size: 22),
              const SizedBox(width: 8),
              Text(bag['tag']!,
                  style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Colors.black,
                      fontSize: 15)),
              const Spacer(),
              IconButton(
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints(),
                icon: Icon(Icons.delete_outline, color: greyText, size: 20),
                onPressed: () {
                  setState(() {
                    scannedBags.removeAt(index);
                  });
                },
              ),
            ],
          ),
          const SizedBox(height: 6),
          Row(
            children: [
              _bagInfoItemWidget("Destination:", bag['destination']!),
              const SizedBox(width: 50),
              _bagInfoItemWidget("Weight:", bag['weight']!),
            ],
          ),
          const SizedBox(height: 12),
          Text("Scanned:\n${bag['time']}",
              style: TextStyle(
                  color: greyText,
                  fontSize: 12,
                  fontWeight: FontWeight.w400,
                  height: 1.4)),
        ],
      ),
    );
  }

  Widget _bagInfoItemWidget(String label, String value) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: TextStyle(color: greyText, fontSize: 12)),
        const SizedBox(height: 2),
        Text(value,
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
      ],
    );
  }

  Widget _buildGradientButton(String text, VoidCallback onTap,
      {double? width}) {
    return Container(
      width: width ?? double.infinity,
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(colors: [primaryBlue, lightBlue]),
        borderRadius: BorderRadius.circular(12),
      ),
      child: ElevatedButton(
        onPressed: onTap,
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
          padding: EdgeInsets.zero,
          shape:
              RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        ),
        child: Text(text,
            style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16)),
      ),
    );
  }
}
