import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:mobile_scanner/mobile_scanner.dart';

class InlineLotScanner extends StatefulWidget {
  final int scannedLotCount;
  final void Function(String? code) onDetect;

  const InlineLotScanner({
    super.key,
    required this.scannedLotCount,
    required this.onDetect,
  });

  @override
  State<InlineLotScanner> createState() => _InlineLotScannerState();
}

class _InlineLotScannerState extends State<InlineLotScanner> {
  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 132,
        child: LayoutBuilder(
          builder: (context, constraints) {
            final windowWidth = math.min(constraints.maxWidth - 28, 420.0);
            const windowHeight = 54.0;
            final scanWindow = Rect.fromCenter(
              center: Offset(
                constraints.maxWidth / 2,
                constraints.maxHeight / 2,
              ),
              width: windowWidth,
              height: windowHeight,
            );

            return Stack(
              fit: StackFit.expand,
              children: [
                MobileScanner(
                  fit: BoxFit.cover,
                  scanWindow: scanWindow,
                  startDelay: true,
                  placeholderBuilder: (context, child) =>
                      const _ScannerMessage(message: 'Starting camera...'),
                  errorBuilder: (context, error, child) => _ScannerMessage(
                    message: _scannerErrorMessage(error),
                    showProgress: _isStartingError(error),
                  ),
                  onDetect: (capture) {
                    for (final barcode in capture.barcodes) {
                      widget.onDetect(barcode.rawValue);
                    }
                  },
                ),
                Positioned.fromRect(
                  rect: scanWindow,
                  child: IgnorePointer(
                    child: DecoratedBox(
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.12),
                        border: Border.all(color: Colors.amberAccent, width: 3),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Align(
                        alignment: Alignment.bottomCenter,
                        child: Container(
                          height: 2,
                          margin: const EdgeInsets.symmetric(
                            horizontal: 28,
                            vertical: 8,
                          ),
                          color: Colors.amberAccent,
                        ),
                      ),
                    ),
                  ),
                ),
                Positioned(
                  left: 8,
                  right: 8,
                  bottom: 8,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: Colors.black.withValues(alpha: 0.62),
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 10,
                        vertical: 6,
                      ),
                      child: Row(
                        children: [
                          const Icon(
                            Icons.qr_code_scanner,
                            color: Colors.white,
                            size: 18,
                          ),
                          const SizedBox(width: 8),
                          Expanded(
                            child: Text(
                              widget.scannedLotCount == 0
                                  ? 'Place barcode inside the frame.'
                                  : '${widget.scannedLotCount} lot(s) scanned. Keep scanning.',
                              maxLines: 1,
                              overflow: TextOverflow.ellipsis,
                              style: const TextStyle(
                                color: Colors.white,
                                fontSize: 12,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            );
          },
        ),
      ),
    );
  }

  String _scannerErrorMessage(MobileScannerException error) {
    final rawMessage = error.errorDetails?.message;
    if (_isStartingError(error)) {
      return 'Starting camera...';
    }
    if (error.errorCode == MobileScannerErrorCode.permissionDenied) {
      return 'Camera permission is required to scan lots.';
    }
    if (error.errorCode == MobileScannerErrorCode.unsupported) {
      return 'Camera scanning is not available on this device.';
    }
    return rawMessage ?? 'Camera unavailable. Check camera permission.';
  }

  bool _isStartingError(MobileScannerException error) {
    return error.errorCode == MobileScannerErrorCode.controllerUninitialized ||
        error.errorDetails?.message
                ?.contains('Called state before initializing') ==
            true;
  }
}

class _ScannerMessage extends StatelessWidget {
  final String message;
  final bool showProgress;

  const _ScannerMessage({
    required this.message,
    this.showProgress = true,
  });

  @override
  Widget build(BuildContext context) {
    return ColoredBox(
      color: Colors.black,
      child: Center(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              if (showProgress) ...[
                const SizedBox(
                  width: 22,
                  height: 22,
                  child: CircularProgressIndicator(strokeWidth: 2),
                ),
                const SizedBox(height: 10),
              ],
              Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
