import 'dart:ui' as ui;

import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter/services.dart';

/// Hide the soft keyboard and wait until the inset has settled.
Future<void> dismissKeyboardAndWait(BuildContext context) async {
  FocusManager.instance.primaryFocus?.unfocus();
  await SystemChannels.textInput.invokeMethod<void>('TextInput.hide');

  final deadline = DateTime.now().add(const Duration(milliseconds: 600));
  while (context.mounted &&
      MediaQuery.viewInsetsOf(context).bottom > 8 &&
      DateTime.now().isBefore(deadline)) {
    await Future<void>.delayed(const Duration(milliseconds: 20));
  }
  if (context.mounted) {
    await Future<void>.delayed(const Duration(milliseconds: 60));
  }
}

/// Capture a [RepaintBoundary] as a GPU-friendly bitmap for butter-smooth slides.
Future<ui.Image?> captureBoundary(
  GlobalKey key, {
  required double pixelRatio,
}) async {
  final ctx = key.currentContext;
  if (ctx == null) return null;
  final boundary = ctx.findRenderObject() as RenderRepaintBoundary?;
  if (boundary == null || boundary.debugNeedsPaint) {
    await WidgetsBinding.instance.endOfFrame;
  }
  final obj = key.currentContext?.findRenderObject() as RenderRepaintBoundary?;
  if (obj == null) return null;
  try {
    return await obj.toImage(pixelRatio: pixelRatio);
  } catch (_) {
    return null;
  }
}

/// Smooth cover reveal: bitmap/outgoing slides left; [incoming] stays put.
Future<void> playAuthReveal({
  required BuildContext context,
  required Widget outgoing,
  required Widget incoming,
  bool clearStack = false,
  VoidCallback? onSettled,
  ui.Image? outgoingImage,
}) async {
  Widget layer = MediaQuery.removeViewInsets(
    context: context,
    removeBottom: true,
    child: outgoing,
  );
  if (outgoingImage != null) {
    layer = SizedBox.expand(
      child: RawImage(
        image: outgoingImage,
        fit: BoxFit.cover,
        filterQuality: FilterQuality.medium,
      ),
    );
  }

  await dismissKeyboardAndWait(context);
  if (!context.mounted) return;
  await WidgetsBinding.instance.endOfFrame;
  if (!context.mounted) return;

  final reveal = PageRouteBuilder<void>(
    opaque: true,
    transitionDuration: Duration.zero,
    reverseTransitionDuration: Duration.zero,
    pageBuilder: (context, animation, secondaryAnimation) {
      return CoverRevealHost(
        outgoing: layer,
        incoming: incoming,
        onSettled: onSettled,
        disposeImage: outgoingImage,
      );
    },
  );

  if (clearStack) {
    await Navigator.of(context).pushAndRemoveUntil<void>(reveal, (_) => false);
  } else {
    await Navigator.of(context).pushReplacement<void, void>(reveal);
  }
}

/// Host that slides [outgoing] left while [incoming] stays fixed underneath.
class CoverRevealHost extends StatefulWidget {
  const CoverRevealHost({
    super.key,
    required this.outgoing,
    required this.incoming,
    this.duration = const Duration(milliseconds: 400),
    this.onSettled,
    this.disposeImage,
  });

  final Widget outgoing;
  final Widget incoming;
  final Duration duration;
  final VoidCallback? onSettled;
  final ui.Image? disposeImage;

  @override
  State<CoverRevealHost> createState() => _CoverRevealHostState();
}

class _CoverRevealHostState extends State<CoverRevealHost>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<Offset> _outSlide;
  late final Widget _outgoingLayer;
  late final Widget _incomingLayer;
  bool _settled = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: widget.duration,
    );
    _outSlide = Tween<Offset>(
      begin: Offset.zero,
      end: const Offset(-1.0, 0),
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ));

    _outgoingLayer = RepaintBoundary(child: widget.outgoing);
    _incomingLayer = RepaintBoundary(child: widget.incoming);

    WidgetsBinding.instance.addPostFrameCallback((_) => _run());
  }

  Future<void> _run() async {
    // Warm up HomeShell under the cover before sliding (kills conductor scratch).
    await WidgetsBinding.instance.endOfFrame;
    await WidgetsBinding.instance.endOfFrame;
    if (!mounted) return;
    await Future<void>.delayed(const Duration(milliseconds: 32));
    if (!mounted) return;
    await _controller.forward();
    if (!mounted) return;
    setState(() => _settled = true);
    widget.onSettled?.call();
  }

  @override
  void dispose() {
    _controller.dispose();
    widget.disposeImage?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (_settled) return _incomingLayer;

    return Material(
      color: Theme.of(context).scaffoldBackgroundColor,
      child: Stack(
        fit: StackFit.expand,
        children: [
          _incomingLayer,
          SlideTransition(
            position: _outSlide,
            child: IgnorePointer(child: _outgoingLayer),
          ),
        ],
      ),
    );
  }
}

/// Soft enter (fade). Previous route stays painted underneath for SAWA dismiss.
class SoftFadeRoute<T> extends PageRouteBuilder<T> {
  SoftFadeRoute({required WidgetBuilder builder, super.settings})
      : super(
          opaque: false,
          barrierColor: Colors.transparent,
          transitionDuration: const Duration(milliseconds: 260),
          reverseTransitionDuration: Duration.zero,
          pageBuilder: (context, animation, secondaryAnimation) =>
              builder(context),
          transitionsBuilder: (context, animation, secondaryAnimation, child) {
            final curved = CurvedAnimation(
              parent: animation,
              curve: Curves.easeOutCubic,
            );
            return FadeTransition(
              opacity: curved,
              child: child,
            );
          },
        );
}
