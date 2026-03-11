import 'package:flutter/material.dart';

class GradientScaffold extends StatelessWidget {
  const GradientScaffold({
    super.key,
    required this.child,
    this.appBar,
    this.floatingActionButton,
  });

  final Widget child;
  final PreferredSizeWidget? appBar;
  final Widget? floatingActionButton;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: appBar,
      floatingActionButton: floatingActionButton,
      body: DecoratedBox(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [Color(0xFFFFF8EE), Color(0xFFFBE4D8), Color(0xFFF6CFC4)],
          ),
        ),
        child: Stack(
          children: [
            Positioned(
              top: -80,
              right: -20,
              child: _GlowOrb(
                color: Colors.white.withValues(alpha: 0.7),
                size: 180,
              ),
            ),
            Positioned(
              bottom: 40,
              left: -50,
              child: _GlowOrb(
                color: const Color(0xFFE56B5D).withValues(alpha: 0.16),
                size: 220,
              ),
            ),
            SafeArea(child: child),
          ],
        ),
      ),
    );
  }
}

class _GlowOrb extends StatelessWidget {
  const _GlowOrb({required this.color, required this.size});

  final Color color;
  final double size;

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          color: color,
          shape: BoxShape.circle,
          boxShadow: [
            BoxShadow(
              color: color,
              blurRadius: 60,
              spreadRadius: 20,
            ),
          ],
        ),
      ),
    );
  }
}
