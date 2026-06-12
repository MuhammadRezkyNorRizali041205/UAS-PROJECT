// lib/features/attendance/presentation/screens/qr_scanner_screen.dart
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import '../../../../shared/theme/app_colors.dart';
import '../../../../shared/theme/app_text_styles.dart';
import '../providers/attendance_provider.dart';

class QrScannerScreen extends ConsumerStatefulWidget {
  const QrScannerScreen({super.key});

  @override
  ConsumerState<QrScannerScreen> createState() => _QrScannerScreenState();
}

class _QrScannerScreenState extends ConsumerState<QrScannerScreen> {
  final MobileScannerController _ctrl = MobileScannerController();
  bool _processing = false;
  bool _done = false;

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  Future<void> _onDetect(BarcodeCapture capture) async {
    if (_processing || _done) return;
    final code = capture.barcodes.firstOrNull?.rawValue;
    if (code == null || code.isEmpty) return;

    setState(() => _processing = true);
    await _ctrl.stop();

    final err = await ref.read(scanQrProvider.notifier).scan(code);

    if (!mounted) return;
    setState(() => _processing = false);

    if (err != null) {
      _showResult(context, success: false, message: err);
    } else {
      setState(() => _done = true);
      _showResult(context, success: true, message: 'Presensi berhasil dicatat!');
    }
  }

  void _showResult(BuildContext ctx,
      {required bool success, required String message}) {
    showModalBottomSheet(
      context: ctx,
      isDismissible: false,
      builder: (_) => Padding(
        padding: const EdgeInsets.all(28),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              success
                  ? Icons.check_circle_rounded
                  : Icons.cancel_rounded,
              size: 56,
              color: success ? AppColors.success : AppColors.danger,
            ),
            const SizedBox(height: 12),
            Text(
              success ? 'Berhasil!' : 'Gagal',
              style: AppTextStyles.headingMedium,
            ),
            const SizedBox(height: 8),
            Text(message,
                style: AppTextStyles.bodySmall,
                textAlign: TextAlign.center),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: () {
                  Navigator.pop(ctx);
                  if (success) {
                    context.pop();
                  } else {
                    setState(() {
                      _processing = false;
                      _done = false;
                    });
                    _ctrl.start();
                  }
                },
                child: Text(success ? 'Selesai' : 'Coba Lagi'),
              ),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
        title: const Text('Scan QR Presensi'),
        actions: [
          IconButton(
            icon: const Icon(Icons.flash_on_rounded),
            onPressed: () => _ctrl.toggleTorch(),
          ),
        ],
      ),
      body: Stack(
        children: [
          // Camera
          MobileScanner(
            controller: _ctrl,
            onDetect: _onDetect,
          ),

          // Overlay frame
          Center(
            child: Container(
              width: 240,
              height: 240,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.primary, width: 3),
                borderRadius: BorderRadius.circular(16),
              ),
            ),
          ),

          // Label
          Positioned(
            bottom: 60,
            left: 0,
            right: 0,
            child: Text(
              _processing
                  ? 'Memproses...'
                  : 'Arahkan kamera ke QR code presensi',
              style: AppTextStyles.bodyMedium
                  .copyWith(color: Colors.white),
              textAlign: TextAlign.center,
            ),
          ),

          // Processing spinner
          if (_processing)
            Container(
              color: Colors.black54,
              child: const Center(
                child: CircularProgressIndicator(
                  color: AppColors.primary,
                ),
              ),
            ),
        ],
      ),
    );
  }
}
