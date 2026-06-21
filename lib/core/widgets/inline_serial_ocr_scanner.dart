import 'dart:async';
import 'dart:io';
import 'dart:typed_data';

import 'package:camera/camera.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:google_mlkit_text_recognition/google_mlkit_text_recognition.dart';

class SerialOcrResult {
  final String serialNumber;
  final String rawText;

  const SerialOcrResult({
    required this.serialNumber,
    required this.rawText,
  });
}

class InlineSerialOcrScanner extends StatefulWidget {
  final int scannedSerialCount;
  final void Function(SerialOcrResult result) onDetect;

  const InlineSerialOcrScanner({
    super.key,
    required this.scannedSerialCount,
    required this.onDetect,
  });

  @override
  State<InlineSerialOcrScanner> createState() => _InlineSerialOcrScannerState();
}

class _InlineSerialOcrScannerState extends State<InlineSerialOcrScanner> {
  final _textRecognizer = TextRecognizer(script: TextRecognitionScript.latin);
  CameraController? _controller;
  bool _isStarting = true;
  bool _isProcessing = false;
  bool _disposed = false;
  String? _error;
  String? _lastSerial;
  DateTime? _lastSerialAt;
  DateTime? _lastProcessedAt;

  @override
  void initState() {
    super.initState();
    unawaited(_startCamera());
  }

  @override
  void dispose() {
    _disposed = true;
    _controller?.dispose();
    _textRecognizer.close();
    super.dispose();
  }

  Future<void> _startCamera() async {
    if (kIsWeb || !(Platform.isAndroid || Platform.isIOS)) {
      if (mounted) {
        setState(() {
          _isStarting = false;
          _error = 'Serial OCR is available on Android and iOS cameras.';
        });
      }
      return;
    }

    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        throw CameraException('no_camera', 'No camera found');
      }

      final camera = cameras.firstWhere(
        (camera) => camera.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        camera,
        ResolutionPreset.medium,
        enableAudio: false,
        imageFormatGroup: Platform.isAndroid
            ? ImageFormatGroup.nv21
            : ImageFormatGroup.bgra8888,
      );

      await controller.initialize();
      if (_disposed) {
        await controller.dispose();
        return;
      }

      await controller.startImageStream(_processCameraImage);
      if (!mounted) return;
      setState(() {
        _controller = controller;
        _isStarting = false;
        _error = null;
      });
    } on CameraException catch (e) {
      if (!mounted) return;
      setState(() {
        _isStarting = false;
        _error = _cameraErrorMessage(e);
      });
    } catch (e) {
      if (!mounted) return;
      setState(() {
        _isStarting = false;
        _error = 'Could not start serial OCR camera.';
      });
    }
  }

  Future<void> _processCameraImage(CameraImage image) async {
    final now = DateTime.now();
    if (_isProcessing ||
        (_lastProcessedAt != null &&
            now.difference(_lastProcessedAt!) <
                const Duration(milliseconds: 650))) {
      return;
    }
    _isProcessing = true;
    _lastProcessedAt = now;

    try {
      final inputImage = _inputImageFromCameraImage(image);
      if (inputImage == null) return;

      final recognizedText = await _textRecognizer.processImage(inputImage);
      final serialNumber = extractSerialNumberFromText(recognizedText.text);
      if (serialNumber == null) return;

      final isFastDuplicate = _lastSerial == serialNumber &&
          _lastSerialAt != null &&
          now.difference(_lastSerialAt!) < const Duration(seconds: 2);
      if (isFastDuplicate) return;

      _lastSerial = serialNumber;
      _lastSerialAt = now;
      widget.onDetect(
        SerialOcrResult(
          serialNumber: serialNumber,
          rawText: recognizedText.text,
        ),
      );
    } catch (_) {
      // OCR frames fail occasionally while the camera is moving; keep scanning.
    } finally {
      _isProcessing = false;
    }
  }

  InputImage? _inputImageFromCameraImage(CameraImage image) {
    final controller = _controller;
    if (controller == null) return null;

    final rotation = InputImageRotationValue.fromRawValue(
          controller.description.sensorOrientation,
        ) ??
        InputImageRotation.rotation0deg;
    final format = InputImageFormatValue.fromRawValue(image.format.raw);
    if (format == null) return null;

    final bytes = _concatenatePlanes(image.planes);
    final metadata = InputImageMetadata(
      size: Size(image.width.toDouble(), image.height.toDouble()),
      rotation: rotation,
      format: format,
      bytesPerRow: image.planes.first.bytesPerRow,
    );

    return InputImage.fromBytes(bytes: bytes, metadata: metadata);
  }

  Uint8List _concatenatePlanes(List<Plane> planes) {
    final allBytes = WriteBuffer();
    for (final plane in planes) {
      allBytes.putUint8List(plane.bytes);
    }
    return allBytes.done().buffer.asUint8List();
  }

  String _cameraErrorMessage(CameraException error) {
    if (error.code == 'CameraAccessDenied' ||
        error.code == 'CameraAccessDeniedWithoutPrompt') {
      return 'Camera permission is required for serial OCR.';
    }
    return error.description ?? 'Camera unavailable. Check camera permission.';
  }

  @override
  Widget build(BuildContext context) {
    final controller = _controller;

    return ClipRRect(
      borderRadius: BorderRadius.circular(10),
      child: SizedBox(
        height: 164,
        child: Stack(
          fit: StackFit.expand,
          children: [
            if (_isStarting)
              const _OcrMessage(message: 'Starting OCR camera...')
            else if (_error != null)
              _OcrMessage(message: _error!, showProgress: false)
            else if (controller != null && controller.value.isInitialized)
              CameraPreview(controller)
            else
              const _OcrMessage(
                message: 'Camera unavailable.',
                showProgress: false,
              ),
            Center(
              child: IgnorePointer(
                child: Container(
                  width: MediaQuery.sizeOf(context).width.clamp(220.0, 430.0),
                  height: 62,
                  decoration: BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.10),
                    border: Border.all(color: Colors.greenAccent, width: 3),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  child: Align(
                    alignment: Alignment.bottomCenter,
                    child: Container(
                      height: 2,
                      margin: const EdgeInsets.symmetric(
                        horizontal: 30,
                        vertical: 9,
                      ),
                      color: Colors.greenAccent,
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
                  color: Colors.black.withValues(alpha: 0.64),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Padding(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                  child: Row(
                    children: [
                      const Icon(Icons.document_scanner_outlined,
                          color: Colors.white, size: 18),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          widget.scannedSerialCount == 0
                              ? 'Aim at the Serial Number text.'
                              : '${widget.scannedSerialCount} serial(s) added. Keep scanning.',
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
        ),
      ),
    );
  }
}

String? extractSerialNumberFromText(String text) {
  final normalizedText = text
      .replaceAll('\r', '\n')
      .replaceAll(RegExp(r'[|]'), 'I')
      .replaceAll(RegExp(r'[ \t]+'), ' ');

  final labeledPatterns = [
    RegExp(
      r'(?:serial\s*(?:number|no\.?|#)?|s\s*/\s*n|s\.n\.?|sn)\s*[:#\-]?\s*([A-Z0-9][A-Z0-9\-_/\.]{3,})',
      caseSensitive: false,
    ),
    RegExp(
      r'(?:serial\s*(?:number|no\.?|#)?|s\s*/\s*n|s\.n\.?|sn)\s*$\s*([A-Z0-9][A-Z0-9\-_/\.]{3,})',
      caseSensitive: false,
      multiLine: true,
    ),
  ];

  for (final pattern in labeledPatterns) {
    final match = pattern.firstMatch(normalizedText);
    final candidate = match?.group(1);
    final cleaned = _cleanSerialCandidate(candidate);
    if (cleaned != null) return cleaned;
  }

  for (final line in normalizedText.split('\n')) {
    final cleanedLine = line.trim();
    if (!_looksLikeSerialLine(cleanedLine)) continue;
    final fallback = RegExp(r'\b[A-Z0-9][A-Z0-9\-_/\.]{5,}\b',
            caseSensitive: false)
        .firstMatch(cleanedLine)
        ?.group(0);
    final cleaned = _cleanSerialCandidate(fallback);
    if (cleaned != null) return cleaned;
  }

  return null;
}

bool _looksLikeSerialLine(String line) {
  final lower = line.toLowerCase();
  return lower.contains('serial') ||
      lower.contains('s/n') ||
      lower.startsWith('sn ') ||
      lower.startsWith('sn:');
}

String? _cleanSerialCandidate(String? value) {
  if (value == null) return null;
  final cleaned = value
      .trim()
      .replaceAll(RegExp(r'^[#:\-\s]+'), '')
      .replaceAll(RegExp(r'[^A-Z0-9\-_/\.]', caseSensitive: false), '')
      .toUpperCase();
  final alphanumericCount = RegExp(r'[A-Z0-9]').allMatches(cleaned).length;
  if (cleaned.length < 4 || alphanumericCount < 4) return null;
  return cleaned;
}

class _OcrMessage extends StatelessWidget {
  final String message;
  final bool showProgress;

  const _OcrMessage({
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
                style: const TextStyle(color: Colors.white, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
