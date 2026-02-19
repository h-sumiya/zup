import 'package:flutter/material.dart';

class Atmosphere extends StatelessWidget {
  const Atmosphere({super.key});

  @override
  Widget build(BuildContext context) {
    return IgnorePointer(
      child: Stack(
        children: [
          Positioned(
            right: -120,
            top: -80,
            child: Container(
              width: 340,
              height: 340,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x40FFA15C), Color(0x0014314A)],
                ),
              ),
            ),
          ),
          Positioned(
            left: -120,
            bottom: -100,
            child: Container(
              width: 360,
              height: 360,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [Color(0x3065FFE8), Color(0x00080F1D)],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
