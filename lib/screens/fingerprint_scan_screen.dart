import 'dart:async';

import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

import '../l10n/strings.dart';
import '../state/app_state.dart';

class FingerprintScanScreen extends StatefulWidget {
  const FingerprintScanScreen({super.key});

  @override
  State<FingerprintScanScreen> createState() => _FingerprintScanScreenState();
}

class _FingerprintScanScreenState extends State<FingerprintScanScreen> {
  CameraController? _camera;
  String? _error;
  bool _starting = true;
  final scanned = <int>{};
  int active = 0;
  bool capturing = false;

  @override
  void initState() {
    super.initState();
    _openCamera();
  }

  Future<void> _openCamera() async {
    try {
      final cameras = await availableCameras();
      if (cameras.isEmpty) {
        setState(() {
          _starting = false;
          _error = 'no_camera';
        });
        return;
      }
      final selected = cameras.firstWhere(
        (c) => c.lensDirection == CameraLensDirection.back,
        orElse: () => cameras.first,
      );
      final controller = CameraController(
        selected,
        ResolutionPreset.medium,
        enableAudio: false,
      );
      await controller.initialize();
      if (!mounted) {
        await controller.dispose();
        return;
      }
      setState(() {
        _camera = controller;
        _starting = false;
      });
      _scanNext();
    } catch (_) {
      if (!mounted) return;
      setState(() {
        _starting = false;
        _error = 'fail';
      });
    }
  }

  Future<void> _scanNext() async {
    if (!mounted || capturing || scanned.length >= 4) return;
    capturing = true;
    await Future<void>.delayed(const Duration(milliseconds: 1100));
    if (!mounted) return;
    try {
      if (_camera != null && _camera!.value.isInitialized) {
        await _camera!.takePicture();
      }
    } catch (_) {}
    if (!mounted) return;
    setState(() {
      scanned.add(active);
      if (active < 3) active += 1;
      capturing = false;
    });
    if (scanned.length >= 4) {
      await Future<void>.delayed(const Duration(milliseconds: 700));
      if (mounted) Navigator.pop(context, true);
      return;
    }
    _scanNext();
  }

  @override
  void dispose() {
    _camera?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = S(AppScope.of(context).language);
    final done = scanned.length == 4;
    final camera = _camera;

    return Scaffold(
      backgroundColor: Colors.black,
      appBar: AppBar(
        title: Text(s.fourFingers),
        backgroundColor: Colors.black,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(16),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(24),
                child: Stack(
                  fit: StackFit.expand,
                  children: [
                    if (_starting)
                      const Center(
                        child: CircularProgressIndicator(color: Colors.white),
                      )
                    else if (camera != null && camera.value.isInitialized)
                      CameraPreview(camera)
                    else
                      ColoredBox(
                        color: Colors.grey.shade900,
                        child: Center(
                          child: Padding(
                            padding: const EdgeInsets.all(24),
                            child: Text(
                              s.cameraFail,
                              textAlign: TextAlign.center,
                              style: const TextStyle(color: Colors.white70),
                            ),
                          ),
                        ),
                      ),
                    IgnorePointer(
                      child: CustomPaint(
                        painter: _FingerCutoutPainter(
                          color: Colors.black.withValues(alpha: 0.45),
                        ),
                      ),
                    ),
                    Align(
                      alignment: Alignment.bottomCenter,
                      child: Padding(
                        padding: const EdgeInsets.all(16),
                        child: Text(
                          done ? s.fingerDone : s.cameraBusy,
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.w600,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          Container(
            width: double.infinity,
            color: Colors.black,
            padding: const EdgeInsets.fromLTRB(16, 8, 16, 28),
            child: Column(
              children: [
                Text(
                  s.cameraFingerHint,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Colors.white70),
                ),
                const SizedBox(height: 8),
                Text(
                  '${scanned.length}/4',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 14),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: List.generate(4, (i) {
                    final isOn = scanned.contains(i);
                    final isActive = !done && i == active;
                    return CircleAvatar(
                      radius: 26,
                      backgroundColor: isOn
                          ? Colors.green
                          : isActive
                              ? Colors.blue
                              : Colors.white24,
                      child: Icon(
                        Icons.fingerprint,
                        color: Colors.white,
                        size: 28,
                      ),
                    );
                  }),
                ),
                if (_error != null) ...[
                  const SizedBox(height: 16),
                  OutlinedButton(
                    onPressed: () => Navigator.pop(context, true),
                    child: Text(s.continueBtn),
                  ),
                ],
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class _FingerCutoutPainter extends CustomPainter {
  _FingerCutoutPainter({required this.color});

  final Color color;

  @override
  void paint(Canvas canvas, Size size) {
    final overlay = Path()..addRect(Offset.zero & size);
    final hole = Path()
      ..addRRect(
        RRect.fromRectAndRadius(
          Rect.fromCenter(
            center: Offset(size.width / 2, size.height / 2),
            width: size.width * 0.62,
            height: size.height * 0.55,
          ),
          const Radius.circular(28),
        ),
      );
    canvas.drawPath(
      Path.combine(PathOperation.difference, overlay, hole),
      Paint()..color = color,
    );
  }

  @override
  bool shouldRepaint(covariant _FingerCutoutPainter oldDelegate) =>
      oldDelegate.color != color;
}
