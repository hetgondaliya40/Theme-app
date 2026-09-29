import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';

class WallpaperShimmer extends StatelessWidget {
  const WallpaperShimmer({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: const Color(0xFF1B1B20),
        borderRadius: BorderRadius.circular(24),
      ),
    )
        .animate(onPlay: (controller) => controller.repeat())
        .shimmer(duration: 1200.ms, color: Colors.white.withValues(alpha: 0.08));
  }
}
