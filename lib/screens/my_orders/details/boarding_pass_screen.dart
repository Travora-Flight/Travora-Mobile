import 'package:flutter/material.dart';
import 'package:barcode_widget/barcode_widget.dart';
import 'package:screenshot/screenshot.dart';
import 'package:image_gallery_saver/image_gallery_saver.dart';
import 'package:share_plus/share_plus.dart';
import 'dart:typed_data';
import '../../../models/orders/boarding_pass_model.dart';
import '../../../services/orders/boarding_pass_service.dart';

class BoardingPassScreen extends StatefulWidget {
  final int orderId;

  const BoardingPassScreen({super.key, required this.orderId});

  @override
  State<BoardingPassScreen> createState() => _BoardingPassScreenState();
}

class _BoardingPassScreenState extends State<BoardingPassScreen> {
  final ScreenshotController screenshotController = ScreenshotController();
  final BoardingPassService _service = BoardingPassService();

  List<BoardingPassModel> _passes = [];
  bool _isLoading = true;
  String? _error;

  @override
  void initState() {
    super.initState();
    _loadBoardingPass();
  }

  Future<void> _loadBoardingPass() async {
    try {
      final passes = await _service.getBoardingPasses(widget.orderId);
      setState(() {
        _passes = passes;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _error = e.toString();
        _isLoading = false;
      });
    }
  }

  Future<void> _downloadTicket() async {
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        await ImageGallerySaver.saveImage(image,
            name:
                "BoardingPass_${_passes.isNotEmpty ? _passes[0].flightNumber : 'VOID'}");
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text("Ticket saved to Gallery!")),
          );
        }
      }
    } catch (e) {
      debugPrint("Error saving ticket: $e");
    }
  }

  Future<void> _shareTicket() async {
    try {
      final Uint8List? image = await screenshotController.capture();
      if (image != null) {
        await Share.shareXFiles([
          XFile.fromData(image,
              name: 'boarding_pass.png', mimeType: 'image/png')
        ],
            text:
                'My Boarding Pass for ${_passes.isNotEmpty ? _passes[0].flightNumber : "Flight"}');
      }
    } catch (e) {
      debugPrint("Error sharing ticket: $e");
    }
  }

  void _showActionsDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (context) => Center(
        child: Container(
          margin: const EdgeInsets.symmetric(horizontal: 60),
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          decoration: BoxDecoration(
            color: const Color(0xFF274C77),
            borderRadius: BorderRadius.circular(24),
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              _buildDialogButton("Share", Icons.share_outlined, () {
                Navigator.pop(context);
                _shareTicket();
              }),
              const SizedBox(height: 12),
              _buildDialogButton("Download", Icons.file_download_outlined, () {
                Navigator.pop(context);
                _downloadTicket();
              }),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildDialogButton(String title, IconData icon, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        width: double.infinity,
        height: 45,
        decoration: BoxDecoration(
          border: Border.all(
              color:
                  Theme.of(context).scaffoldBackgroundColor.withOpacity(0.5)),
          borderRadius: BorderRadius.circular(30),
        ),
        child: Center(
          child: Text(
            title,
            style: TextStyle(
              color: Theme.of(context).scaffoldBackgroundColor,
              fontSize: 20,
              fontWeight: FontWeight.w500,
              decoration: TextDecoration.none,
            ),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, color: Color(0xFF274C77)),
          onPressed: () => Navigator.pop(context),
        ),
        title: const Text("Boarding Pass",
            style: TextStyle(
                color: Color(0xFF274C77), fontWeight: FontWeight.bold)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      ),
      body: _isLoading
          ? const Center(
              child: CircularProgressIndicator(color: Color(0xFF274C77)))
          : _error != null
              ? Center(child: Text(_error!))
              : _passes.isEmpty
                  ? const Center(child: Text("No boarding pass available"))
                  : _buildPassContent(_passes[0]),
    );
  }

  Widget _buildPassContent(BoardingPassModel data) {
    return SingleChildScrollView(
      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
      child: Screenshot(
        controller: screenshotController,
        child: Container(
          color: Theme.of(context).scaffoldBackgroundColor,
          child: CustomPaint(
            painter: TicketPainter(context),
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  _buildAirLineHeader(context, data),
                  const SizedBox(height: 30),
                  _buildRouteInfo(data),
                  const SizedBox(height: 35),
                  _buildPassengerInfo(data),
                  const SizedBox(height: 60),
                  _buildBarcodeSection(data),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildAirLineHeader(BuildContext context, BoardingPassModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Row(
          children: [
            Image.asset('assets/images/Egyptair.png', height: 24),
            const SizedBox(width: 8),
            Text(data.airlineName.isEmpty ? "EGYPT AIR" : data.airlineName,
                style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontWeight: FontWeight.bold,
                    fontSize: 16)),
          ],
        ),
        Row(
          children: [
            Text(data.flightNumber.isEmpty ? "MS882" : data.flightNumber,
                style: TextStyle(
                    color: Theme.of(context).scaffoldBackgroundColor,
                    fontSize: 14)),
            const SizedBox(width: 8),
            GestureDetector(
              onTap: () => _showActionsDialog(context),
              child: Icon(Icons.more_horiz,
                  color: Theme.of(context).scaffoldBackgroundColor),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildRouteInfo(BoardingPassModel data) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        _columnText(
            data.fromCity.isEmpty ? "Accra" : data.fromCity,
            data.from.isEmpty ? "ACC" : data.from,
            data.departureTime.isEmpty ? "11:00 PM" : data.departureTime),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10),
                child: Divider(
                  color: Theme.of(context)
                      .scaffoldBackgroundColor
                      .withOpacity(0.3),
                  thickness: 1,
                ),
              ),
              Transform.translate(
                offset: const Offset(0, -11),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(data.duration.isEmpty ? "" : data.duration,
                        style:
                            const TextStyle(color: Colors.white, fontSize: 12)),
                    const SizedBox(height: 4),
                    Image.asset(
                      'assets/images/tracking_container.png',
                      width: 24,
                      color: Theme.of(context).scaffoldBackgroundColor,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
        _columnText(
            data.toCity.isEmpty ? "Cairo" : data.toCity,
            data.to.isEmpty ? "CAI" : data.to,
            data.arrivalTime.isEmpty ? "01:00 AM" : data.arrivalTime),
      ],
    );
  }

  Widget _columnText(String city, String code, String time) {
    return Column(
      children: [
        Text(city,
            style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 12)),
        Text(code,
            style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 32,
                fontWeight: FontWeight.bold)),
        Text(time,
            style: TextStyle(
                color: Theme.of(context).scaffoldBackgroundColor,
                fontSize: 12)),
      ],
    );
  }

  Widget _buildPassengerInfo(BoardingPassModel data) {
    return Column(
      children: [
        _infoRow(
            "PASSENGER NAME",
            "SEAT NUM",
            data.passengerName.isEmpty ? "---" : data.passengerName,
            data.seatNumber.isEmpty ? "---" : data.seatNumber),
        const SizedBox(height: 16),
        _infoRow(
            "TERMINAL",
            "GATE",
            data.terminal.isEmpty ? "---" : data.terminal,
            data.gate.isEmpty ? "---" : data.gate),
        const SizedBox(height: 16),
        _infoRow(
            "CLASS",
            "FLIGHT DATE",
            data.boardingClass.isEmpty ? "---" : data.boardingClass,
            data.flightDate.isEmpty ? "---" : data.flightDate),
        const SizedBox(height: 16),
        _infoRow("BOARDING TIME", "",
            data.boardingTime.isEmpty ? "---" : data.boardingTime, ""),
      ],
    );
  }

  Widget _infoRow(String t1, String t2, String v1, String v2) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(t1,
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontSize: 10)),
              Text(v1,
                  style: TextStyle(
                      color: Theme.of(context).scaffoldBackgroundColor,
                      fontWeight: FontWeight.bold,
                      fontSize: 14)),
            ],
          ),
        ),
        if (t2.isNotEmpty)
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(t2,
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontSize: 10)),
                Text(v2,
                    style: TextStyle(
                        color: Theme.of(context).scaffoldBackgroundColor,
                        fontWeight: FontWeight.bold,
                        fontSize: 14)),
              ],
            ),
          ),
      ],
    );
  }

  Widget _buildBarcodeSection(BoardingPassModel data) {
    return Transform.translate(
      offset: const Offset(0, -15),
      child: Container(
        width: 323,
        height: 64,
        margin: const EdgeInsets.only(top: 0),
        child: BarcodeWidget(
          barcode: Barcode.code128(),
          data: data.barcodeData.isEmpty ? "TRAVORA-VOID" : data.barcodeData,
          drawText: false,
          color: Theme.of(context).textTheme.bodyLarge!.color!,
          width: double.infinity,
          height: double.infinity,
        ),
      ),
    );
  }
}

class TicketPainter extends CustomPainter {
  final BuildContext context;
  TicketPainter(this.context);

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = const Color(0xFF274C77).withOpacity(0.7)
      ..style = PaintingStyle.fill;

    const double radius = 26.0;
    const double clipRadius = 14.0;
    final double clipPos = size.height * 0.73;

    Path path = Path();
    path.addRRect(RRect.fromLTRBR(
        0, 0, size.width, size.height, const Radius.circular(radius)));

    Path clipPath = Path();
    clipPath.addOval(
        Rect.fromCircle(center: Offset(0, clipPos), radius: clipRadius));
    clipPath.addOval(Rect.fromCircle(
        center: Offset(size.width, clipPos), radius: clipRadius));

    final finalPath = Path.combine(PathOperation.difference, path, clipPath);
    canvas.drawPath(finalPath, paint);

    final dashPaint = Paint()
      ..color = Theme.of(context).scaffoldBackgroundColor.withOpacity(0.3)
      ..strokeWidth = 1
      ..style = PaintingStyle.stroke;

    double dashWidth = 5;
    double dashSpace = 5;
    double startX = clipRadius + 5;
    while (startX < size.width - clipRadius - 5) {
      canvas.drawLine(Offset(startX, clipPos),
          Offset(startX + dashWidth, clipPos), dashPaint);
      startX += dashWidth + dashSpace;
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) => false;
}
