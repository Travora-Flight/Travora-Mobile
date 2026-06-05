import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

class CameraScannerScreen extends StatefulWidget {
  final CameraDescription camera;
  const CameraScannerScreen({super.key, required this.camera});

  @override
  State<CameraScannerScreen> createState() => _CameraScannerScreenState();
}

class _CameraScannerScreenState extends State<CameraScannerScreen> {
  late CameraController _controller;
  late Future<void> _initializeControllerFuture;

  @override
  void initState() {
    super.initState();
    _controller = CameraController(
      widget.camera,
      ResolutionPreset.high,
      enableAudio: false,
    );
    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: FutureBuilder<void>(
        future: _initializeControllerFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.done) {
            return Stack(
              children: [
                LayoutBuilder(
                  builder: (context, constraints) {
                    final double previewWidth =
                        _controller.value.previewSize!.height;
                    final double previewHeight =
                        _controller.value.previewSize!.width;

                    final double screenWidth = constraints.maxWidth;
                    final double screenHeight = constraints.maxHeight;
                    final double scale = screenHeight /
                        (screenWidth * (previewHeight / previewWidth));

                    return ClipRect(
                      child: OverflowBox(
                        maxHeight: screenHeight,
                        maxWidth: screenWidth,
                        child: Transform.scale(
                          scale: scale,
                          child: Center(
                            child: CameraPreview(_controller),
                          ),
                        ),
                      ),
                    );
                  },
                ),
                _buildScannerOverlay(context),
                _buildUIControls(context),
              ],
            );
          } else {
            return const Center(
                child: CircularProgressIndicator(color: Color(0xFF274C77)));
          }
        },
      ),
    );
  }

  Widget _buildScannerOverlay(BuildContext context) {
    return Stack(
      children: [
        ColorFiltered(
          colorFilter: ColorFilter.mode(
            Colors.black.withOpacity(0.5),
            BlendMode.srcOut,
          ),
          child: Stack(
            children: [
              Container(
                decoration: const BoxDecoration(
                  color: Colors.black,
                  backgroundBlendMode: BlendMode.dstOut,
                ),
              ),
              Align(
                alignment: Alignment.center,
                child: Container(
                  height: 280,
                  width: 280,
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(25),
                  ),
                ),
              ),
            ],
          ),
        ),
        Align(
          alignment: Alignment.center,
          child: Container(
            height: 280,
            width: 280,
            decoration: BoxDecoration(
              border: Border.all(color: const Color(0xFFA3CEF1), width: 3),
              borderRadius: BorderRadius.circular(25),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildUIControls(BuildContext context) {
    return Stack(
      children: [
        Positioned(
          top: 50,
          left: 20,
          child: IconButton(
            icon: const Icon(Icons.close, color: Colors.white, size: 30),
            onPressed: () => Navigator.pop(context),
          ),
        ),
        Positioned(
          bottom: 60,
          left: 0,
          right: 0,
          child: Center(
            child: GestureDetector(
              onTap: () async {
                try {
                  await _initializeControllerFuture;
                  await _controller.takePicture();
                  if (!mounted) return;
                  Navigator.pop(context, true);
                } catch (e) {
                  debugPrint(e.toString());
                }
              },
              child: Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  border: Border.all(color: Colors.white, width: 4),
                  color: Colors.white24,
                ),
                child: const Icon(Icons.qr_code_scanner,
                    color: Colors.white, size: 40),
              ),
            ),
          ),
        ),
      ],
    );
  }
}
