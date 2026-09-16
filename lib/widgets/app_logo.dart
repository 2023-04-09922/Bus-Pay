import 'package:flutter/material.dart';

class AppLogo extends StatelessWidget {
  const AppLogo({
    super.key,
    this.size = 88,
    this.radius,
  });

  final double size;
  final double? radius;

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(radius ?? size * 0.24),
      child: Image.asset(
        'assets/daladala_logo.png',
        width: size,
        height: size,
        fit: BoxFit.cover,
        errorBuilder: (_, _, _) {
          return Image.asset(
            'assets/icon/bus_pay_icon.png',
            width: size,
            height: size,
            fit: BoxFit.cover,
            errorBuilder: (_, _, _) => Container(
              width: size,
              height: size,
              color: const Color(0xFF1E88E5),
              alignment: Alignment.center,
              child: Icon(
                Icons.directions_bus,
                color: Colors.white,
                size: size * 0.55,
              ),
            ),
          );
        },
      ),
    );
  }
}
