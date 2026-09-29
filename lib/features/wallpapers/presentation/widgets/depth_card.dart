import 'package:flutter/material.dart';
import 'package:flutter_animate/flutter_animate.dart';
import '../../data/models/depth_wallpaper_model.dart';
import 'clock_layer_widget.dart';
import 'wallpaper_shimmer.dart';

class DepthCard extends StatelessWidget {
  final DepthWallpaperModel item;
  final VoidCallback onTap;
  final VoidCallback? onFavoriteTap;
  final bool isFavorite;
  final bool isUnlocked;
  final int animationIndex;
  final double aspectRatio;

  const DepthCard({
    super.key,
    required this.item,
    required this.onTap,
    this.onFavoriteTap,
    this.isFavorite = false,
    this.isUnlocked = false,
    this.animationIndex = 0,
    this.aspectRatio = 0.52,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(24),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.5),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(24),
          child: Stack(
            children: [
              // Background Wallpaper Image
              Positioned.fill(
                child: Image.network(
                  item.backgroundUrl,
                  fit: BoxFit.cover,
                  cacheWidth: 400,
                  cacheHeight: 700,
                  loadingBuilder: (context, child, loadingProgress) {
                    if (loadingProgress == null) return child;
                    return const WallpaperShimmer();
                  },
                  errorBuilder: (context, error, stackTrace) => Container(
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [
                          item.accentColor.withValues(alpha: 0.3),
                          const Color(0xFF1B1B24),
                        ],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                    ),
                    child: Center(
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(Icons.wallpaper_rounded,
                              color: item.accentColor, size: 28),
                          const SizedBox(height: 6),
                          Padding(
                            padding: const EdgeInsets.symmetric(horizontal: 8.0),
                            child: Text(
                              item.title,
                              textAlign: TextAlign.center,
                              maxLines: 2,
                              style: const TextStyle(
                                color: Colors.white70,
                                fontSize: 10,
                                fontWeight: FontWeight.bold,
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),

              // Clock Layer (if active)
              Positioned.fill(
                child: Align(
                  alignment: Alignment.topCenter,
                  child: Padding(
                    padding: const EdgeInsets.only(top: 18),
                    child: ClockLayerWidget(
                      config: item.defaultClockConfig,
                      scale: 0.55,
                    ),
                  ),
                ),
              ),

              // Cutout Layer
              if (item.foregroundCutoutUrl != item.backgroundUrl &&
                  item.foregroundCutoutUrl.isNotEmpty)
                Positioned.fill(
                  child: Image.network(
                    item.foregroundCutoutUrl,
                    fit: BoxFit.cover,
                    cacheWidth: 400,
                    cacheHeight: 700,
                    errorBuilder: (context, error, stackTrace) =>
                        const SizedBox(),
                  ),
                ),

              // Top Left Badge: 🪙 1 Coin (Locked) or UNLOCKED ✓ (Unlocked)
              Positioned(
                top: 10,
                left: 10,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black.withValues(alpha: 0.8),
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isUnlocked
                          ? Colors.greenAccent
                          : const Color(0xFFFFE500),
                      width: 1,
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(isUnlocked ? '✓' : '🪙',
                          style: TextStyle(
                              fontSize: 10,
                              color: isUnlocked
                                  ? Colors.greenAccent
                                  : Colors.amber)),
                      const SizedBox(width: 3),
                      Text(
                        isUnlocked ? 'Unlocked' : '10 Coins',
                        style: TextStyle(
                          color: isUnlocked
                              ? Colors.greenAccent
                              : const Color(0xFFFFE500),
                          fontSize: 10,
                          fontWeight: FontWeight.w800,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Top Right Favorite Button
              if (onFavoriteTap != null)
                Positioned(
                  top: 10,
                  right: 10,
                  child: GestureDetector(
                    onTap: onFavoriteTap,
                    child: CircleAvatar(
                      radius: 16,
                      backgroundColor: Colors.black54,
                      child: Icon(
                        isFavorite
                            ? Icons.favorite_rounded
                            : Icons.favorite_border_rounded,
                        color: isFavorite ? Colors.redAccent : Colors.white,
                        size: 16,
                      ),
                    ),
                  ),
                ),

              // Bottom Rating Badge
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  decoration: BoxDecoration(
                    color: Colors.black54,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.star_rounded,
                          color: Color(0xFFFFE500), size: 12),
                      const SizedBox(width: 4),
                      Text(
                        '${item.rating}',
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 10,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    )
        .animate()
        .fadeIn(
          duration: 350.ms,
          delay: Duration(milliseconds: (animationIndex % 6) * 60),
        )
        .scale(
          begin: const Offset(0.92, 0.92),
          end: const Offset(1.0, 1.0),
          duration: 350.ms,
          curve: Curves.easeOutCubic,
        );
  }
}
