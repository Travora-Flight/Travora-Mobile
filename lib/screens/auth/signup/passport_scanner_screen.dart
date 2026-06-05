import 'dart:io';
import 'package:camera/camera.dart';
import 'package:flutter/material.dart';
import 'package:image/image.dart' as img;
import 'package:permission_handler/permission_handler.dart';

class PassportScannerScreen extends StatefulWidget {
  const PassportScannerScreen({super.key});

  @override
  State<PassportScannerScreen> createState() => _PassportScannerScreenState();
}

class _PassportScannerScreenState extends State<PassportScannerScreen> {
  CameraController? _controller;
  bool _isInitialized = false;
  bool _permissionDenied = false;

  final GlobalKey _frameKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _requestCameraPermission();
  }

  Future<void> _requestCameraPermission() async {
    final status = await Permission.camera.request();
    if (status.isGranted) {
      _initializeCamera();
    } else if (status.isPermanentlyDenied) {
      setState(() => _permissionDenied = true);
      openAppSettings();
    } else {
      setState(() => _permissionDenied = true);
    }
  }

  Future<void> _initializeCamera() async {
    final cameras = await availableCameras();
    if (cameras.isNotEmpty) {
      _controller = CameraController(
        cameras[0],
        ResolutionPreset.high,
        enableAudio: false,
      );
      await _controller!.initialize();
      if (!mounted) return;
      setState(() => _isInitialized = true);
    }
  }

  Future<File> _cropImage({
    required File imageFile,
    required double frameLeft,
    required double frameTop,
    required double frameWidth,
    required double frameHeight,
    required double screenWidth,
    required double screenHeight,
  }) async {
    final bytes = await imageFile.readAsBytes();
    var original = img.decodeImage(bytes)!;
    original = img.bakeOrientation(original);

    final imgW = original.width.toDouble();
    final imgH = original.height.toDouble();

    debugPrint("=== CROP DEBUG ===");
    debugPrint("Image size after bake: ${imgW.toInt()} x ${imgH.toInt()}");
    debugPrint("Screen size: $screenWidth x $screenHeight");
    debugPrint(
        "Frame: left=$frameLeft top=$frameTop w=$frameWidth h=$frameHeight");

    // CameraPreview uses BoxFit.cover
    final double scaleW = imgW / screenWidth;
    final double scaleH = imgH / screenHeight;
    final double scale = scaleW < scaleH ? scaleH : scaleW;

    final double offsetX = (imgW - screenWidth * scale) / 2;
    final double offsetY = (imgH - screenHeight * scale) / 2;

    debugPrint("scale=$scale offsetX=$offsetX offsetY=$offsetY");

    final cropX = (offsetX + frameLeft * scale).round();
    final cropY = (offsetY + frameTop * scale).round();
    final cropW = (frameWidth * scale).round();
    final cropH = (frameHeight * scale).round();

    debugPrint("cropX=$cropX cropY=$cropY cropW=$cropW cropH=$cropH");

    final safeX = cropX.clamp(0, original.width - 1);
    final safeY = cropY.clamp(0, original.height - 1);
    final safeW = cropW.clamp(1, original.width - safeX);
    final safeH = cropH.clamp(1, original.height - safeY);

    final cropped = img.copyCrop(
      original,
      x: safeX,
      y: safeY,
      width: safeW,
      height: safeH,
    );

    final croppedPath = imageFile.path.replaceAll('.jpg', '_cropped.jpg');
    final croppedFile = File(croppedPath)
      ..writeAsBytesSync(img.encodeJpg(cropped, quality: 95));

    return croppedFile;
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_permissionDenied) {
      return Scaffold(
        body: Center(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt, size: 60, color: Colors.grey),
              const SizedBox(height: 16),
              const Text(
                'Camera permission is required\nto scan your passport.',
                textAlign: TextAlign.center,
                style: TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: () async {
                  setState(() => _permissionDenied = false);
                  await _requestCameraPermission();
                },
                child: const Text('Grant Permission'),
              ),
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('Go Back'),
              ),
            ],
          ),
        ),
      );
    }

    if (!_isInitialized || _controller == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      backgroundColor: Theme.of(context).textTheme.bodyLarge?.color,
      body: Stack(
        children: [
          Positioned.fill(
            child: Center(
              child: CameraPreview(_controller!),
            ),
          ),
          _buildOverlay(context),
          Positioned(
            top: 40,
            left: 20,
            child: IconButton(
              icon: Icon(Icons.arrow_back_ios,
                  color: Theme.of(context).scaffoldBackgroundColor),
              onPressed: () => Navigator.pop(context),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildOverlay(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;
    final frameWidth = screenWidth * 0.85;
    final frameHeight = screenWidth * 0.55;

    return Column(
      children: [
        Container(
          width: double.infinity,
          padding:
              const EdgeInsets.only(top: 60, bottom: 20, left: 20, right: 20),
          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildInstructionRow(
                  "Scan your passport inside the frame clearly"),
              _buildInstructionRow("Keep the passport steady without tilting"),
              _buildInstructionRow("Make the passport fill the entire frame"),
              _buildInstructionRow(
                  "Align the two bottom lines within the small inner frame"),
            ],
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              color: Colors.transparent,
              border: Border.symmetric(
                vertical: BorderSide(
                    color: Theme.of(context)
                        .textTheme
                        .bodyLarge!
                        .color!
                        .withOpacity(0.6),
                    width: 20),
              ),
            ),
            child: Center(
              child: Container(
                key: _frameKey,
                width: frameWidth,
                height: frameHeight,
                decoration: BoxDecoration(
                  border: Border.all(color: Colors.blueAccent, width: 3),
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Stack(
                  children: [
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Container(
                        margin: const EdgeInsets.all(8),
                        width: double.infinity,
                        height: 45,
                        decoration: BoxDecoration(
                          border: Border.all(
                              color: const Color.fromARGB(255, 160, 34, 34)
                                  .withOpacity(0.7),
                              width: 1.5),
                          borderRadius: BorderRadius.circular(6),
                          color: Theme.of(context)
                              .scaffoldBackgroundColor
                              .withOpacity(0.1),
                        ),
                        child: const Center(
                          child: Text(
                            "PASSPORT DATA ZONE",
                            style: TextStyle(
                              color: Color.fromARGB(255, 130, 120, 120),
                              fontSize: 10,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
        Container(
          width: double.infinity,
          padding: const EdgeInsets.only(bottom: 40, top: 20),
          color: Theme.of(context).textTheme.bodyLarge!.color!.withOpacity(0.6),
          child: Column(
            children: [
              Text(
                "Tap to capture when the passport is steady",
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                ),
              ),
              const SizedBox(height: 20),
              GestureDetector(
                onTap: () async {
                  try {
                    final image = await _controller!.takePicture();
                    if (!mounted) return;

                    final screenWidth = MediaQuery.of(context).size.width;
                    final screenHeight = MediaQuery.of(context).size.height;

                    final RenderBox? frameBox = _frameKey.currentContext
                        ?.findRenderObject() as RenderBox?;
                    final Offset frameOffset =
                        frameBox?.localToGlobal(Offset.zero) ?? Offset.zero;
                    final Size frameSize = frameBox?.size ??
                        Size(screenWidth * 0.85, screenWidth * 0.55);

                    final croppedFile = await _cropImage(
                      imageFile: File(image.path),
                      frameLeft: frameOffset.dx,
                      frameTop: frameOffset.dy,
                      frameWidth: frameSize.width,
                      frameHeight: frameSize.height,
                      screenWidth: screenWidth,
                      screenHeight: screenHeight,
                    );

                    if (!mounted) return;
                    Navigator.pop(context, croppedFile);
                  } catch (e) {
                    debugPrint("Error taking picture: $e");
                  }
                },
                child: Container(
                  height: 75,
                  width: 75,
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.blueAccent, width: 4),
                  ),
                  child: Container(
                    margin: const EdgeInsets.all(4),
                    decoration: BoxDecoration(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        shape: BoxShape.circle),
                    child: const Icon(Icons.camera_alt,
                        color: Colors.blueAccent, size: 35),
                  ),
                ),
              ),
              const SizedBox(height: 15),
              Text(
                "Data will be verified immediately after capture",
                style: TextStyle(
                  color: Theme.of(context).scaffoldBackgroundColor,
                  fontSize: 13,
                  fontWeight: FontWeight.w400,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }

  Widget _buildInstructionRow(String text) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 6),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          const Icon(Icons.check_circle_outline,
              color: Colors.blueAccent, size: 20),
          const SizedBox(width: 12),
          Expanded(
            child: Text(
              text,
              style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 15,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
