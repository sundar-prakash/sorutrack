import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../bloc/barcode_scanner/barcode_scanner_bloc.dart';
import 'food_detail_screen.dart';
import 'custom_food_screen.dart';

class BarcodeScannerScreen extends StatefulWidget {
  const BarcodeScannerScreen({super.key});

  @override
  State<BarcodeScannerScreen> createState() => _BarcodeScannerScreenState();
}

class _BarcodeScannerScreenState extends State<BarcodeScannerScreen> {
  final MobileScannerController controller = MobileScannerController();
  bool _isDisposed = false;

  @override
  void dispose() {
    _isDisposed = true;
    controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocListener<BarcodeScannerBloc, BarcodeScannerState>(
      listener: (context, state) {
        if (state is BarcodeScannerSuccess) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (_) => FoodDetailScreen(foodItem: state.foodItem)),
          );
        } else if (state is BarcodeScannerNotFound) {
          _showNotFoundDialog(state.barcode);
        } else if (state is BarcodeScannerError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text(state.message)),
          );
        }
      },
      child: Scaffold(
        appBar: AppBar(title: const Text('Scan Food Barcode')),
        body: Stack(
          children: [
            MobileScanner(
              controller: controller,
              onDetect: (capture) {
                final List<Barcode> barcodes = capture.barcodes;
                if (barcodes.isNotEmpty) {
                  final String? code = barcodes.first.rawValue;
                  if (code != null && !_isDisposed) {
                    context.read<BarcodeScannerBloc>().add(BarcodeScanned(code));
                  }
                }
              },
            ),
            _buildOverlay(),
            BlocBuilder<BarcodeScannerBloc, BarcodeScannerState>(
              builder: (context, state) {
                if (state is BarcodeScannerLoading) {
                  return const Center(
                    child: Card(
                      child: Padding(
                        padding: EdgeInsets.all(24.0),
                        child: Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            CircularProgressIndicator(),
                            SizedBox(height: 16),
                            Text('Looking up product...'),
                          ],
                        ),
                      ),
                    ),
                  );
                }
                return const SizedBox.shrink();
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOverlay() {
    return Container(
      decoration: ShapeDecoration(
        shape: QrScannerOverlayShape(
          borderColor: Theme.of(context).primaryColor,
          borderRadius: 10,
          borderLength: 30,
          borderWidth: 10,
          cutOutSize: 250,
        ),
      ),
    );
  }

  void _showNotFoundDialog(String barcode) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Product Not Found'),
        content: Text('We couldn\'t find a product with barcode: $barcode.\nWould you like to add it manually?'),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (_) => CustomFoodScreen(initialBarcode: barcode)),
              );
            },
            child: const Text('Add Manually'),
          ),
        ],
      ),
    );
  }
}

// Simple overlay shape for the scanner
class QrScannerOverlayShape extends ShapeBorder {
  final Color borderColor;
  final double borderWidth;
  final Color overlayColor;
  final double borderRadius;
  final double borderLength;
  final double cutOutSize;

  const QrScannerOverlayShape({
    this.borderColor = Colors.white,
    this.borderWidth = 10,
    this.overlayColor = const Color.fromRGBO(0, 0, 0, 80),
    this.borderRadius = 0,
    this.borderLength = 40,
    this.cutOutSize = 250,
  });

  @override
  EdgeInsetsGeometry get dimensions => const EdgeInsets.all(10);

  @override
  Path getInnerPath(Rect rect, {TextDirection? textDirection}) => Path();

  @override
  Path getOuterPath(Rect rect, {TextDirection? textDirection}) => Path()..addRect(rect);

  @override
  void paint(Canvas canvas, Rect rect, {TextDirection? textDirection}) {
    final width = rect.width;
    final height = rect.height;

    final backgroundPath = Path()..addRect(rect);
    final cutOutPath = Path()
      ..addRRect(RRect.fromRectAndRadius(
        Rect.fromLTWH(
          rect.left + (width - cutOutSize) / 2,
          rect.top + (height - cutOutSize) / 2,
          cutOutSize,
          cutOutSize,
        ),
        Radius.circular(borderRadius),
      ));

    final backgroundPaint = Paint()
      ..color = overlayColor
      ..style = PaintingStyle.fill;

    canvas.drawPath(
      Path.combine(PathOperation.difference, backgroundPath, cutOutPath),
      backgroundPaint,
    );

    final borderPaint = Paint()
      ..color = borderColor
      ..style = PaintingStyle.stroke
      ..strokeWidth = borderWidth;

    final borderPath = cutOutPath;
    canvas.drawPath(borderPath, borderPaint);
  }

  @override
  ShapeBorder scale(double t) => QrScannerOverlayShape();
}
