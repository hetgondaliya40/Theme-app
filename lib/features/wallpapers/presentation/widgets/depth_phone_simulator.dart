import 'package:flutter/material.dart';
import '../../data/models/depth_wallpaper_model.dart';
import '../../data/models/depth_clock_config.dart';
import 'clock_layer_widget.dart';

class DepthPhoneSimulator extends StatefulWidget {
  final DepthWallpaperModel wallpaper;
  final DepthClockConfig clockConfig;
  final double scale;
  final GlobalKey? repaintKey;

  const DepthPhoneSimulator({
    super.key,
    required this.wallpaper,
    required this.clockConfig,
    this.scale = 1.0,
    this.repaintKey,
  });

  @override
  State<DepthPhoneSimulator> createState() => _DepthPhoneSimulatorState();
}

class _DepthPhoneSimulatorState extends State<DepthPhoneSimulator> {
  double _dragX = 0.0;
  double _dragY = 0.0;

  @override
  Widget build(BuildContext context) {
    final frameWidth = 240.0 * widget.scale;
    final frameHeight = 480.0 * widget.scale;

    final hasDistinctCutout =
        widget.wallpaper.foregroundCutoutUrl != widget.wallpaper.backgroundUrl &&
            widget.wallpaper.foregroundCutoutUrl.isNotEmpty;

    Widget layersStack = Stack(
      children: [
        // LAYER 1: Background Wallpaper (Parallax Factor 0.3)
        Positioned.fill(
          child: Transform.translate(
            offset: Offset(_dragX * 0.3, _dragY * 0.3),
            child: Transform.scale(
              scale: 1.15,
              child: Image.network(
                widget.wallpaper.backgroundUrl,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) => Container(
                  color: Colors.indigo.shade900,
                ),
              ),
            ),
          ),
        ),

        // LAYER 2: Depth Clock (BEHIND Foreground Subject)
        if (widget.clockConfig.isBehindForeground && hasDistinctCutout)
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 54 * widget.scale),
                child: Transform.translate(
                  offset: Offset(_dragX * 0.5, _dragY * 0.5),
                  child: ClockLayerWidget(
                    config: widget.clockConfig,
                    scale: widget.scale,
                  ),
                ),
              ),
            ),
          ),

        // LAYER 3: Foreground Subject Cutout (Parallax Factor 0.8)
        if (hasDistinctCutout)
          Positioned.fill(
            child: Transform.translate(
              offset: Offset(_dragX * 0.8, _dragY * 0.8),
              child: Transform.scale(
                scale: 1.15,
                child: Image.network(
                  widget.wallpaper.foregroundCutoutUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (context, error, stackTrace) =>
                      const SizedBox(),
                ),
              ),
            ),
          ),

        // LAYER 4: Depth Clock (IN FRONT of Foreground Subject or default)
        if (!widget.clockConfig.isBehindForeground || !hasDistinctCutout)
          Positioned.fill(
            child: Align(
              alignment: Alignment.topCenter,
              child: Padding(
                padding: EdgeInsets.only(top: 54 * widget.scale),
                child: Transform.translate(
                  offset: Offset(_dragX * 0.5, _dragY * 0.5),
                  child: ClockLayerWidget(
                    config: widget.clockConfig,
                    scale: widget.scale,
                  ),
                ),
              ),
            ),
          ),
      ],
    );

    if (widget.repaintKey != null) {
      layersStack = RepaintBoundary(
        key: widget.repaintKey,
        child: layersStack,
      );
    }

    Widget contentStack = Stack(
      children: [
        Positioned.fill(child: layersStack),

        // LAYER 5: Status Bar Notch Shell
        Positioned(
          top: 0,
          left: 0,
          right: 0,
          child: Container(
            padding: EdgeInsets.symmetric(
              horizontal: 16 * widget.scale,
              vertical: 8 * widget.scale,
            ),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Center(
                  child: Container(
                    width: 60 * widget.scale,
                    height: 12 * widget.scale,
                    decoration: BoxDecoration(
                      color: Colors.black,
                      borderRadius:
                          BorderRadius.circular(10 * widget.scale),
                    ),
                  ),
                ),
                SizedBox(height: 4 * widget.scale),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '3D DEPTH',
                      style: TextStyle(
                        color: Colors.white70,
                        fontSize: 8 * widget.scale,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 1,
                      ),
                    ),
                    Row(
                      children: [
                        Icon(Icons.wifi,
                            size: 10 * widget.scale,
                            color: Colors.white),
                        SizedBox(width: 4 * widget.scale),
                        Icon(Icons.battery_full_rounded,
                            size: 10 * widget.scale,
                            color: Colors.white),
                      ],
                    ),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );

    return GestureDetector(
      onPanUpdate: (details) {
        setState(() {
          _dragX = (_dragX + details.delta.dx * 0.05).clamp(-15.0, 15.0);
          _dragY = (_dragY + details.delta.dy * 0.05).clamp(-15.0, 15.0);
        });
      },
      onPanEnd: (_) {
        setState(() {
          _dragX = 0.0;
          _dragY = 0.0;
        });
      },
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        width: frameWidth,
        height: frameHeight,
        decoration: BoxDecoration(
          color: const Color(0xFF121214),
          borderRadius: BorderRadius.circular(36 * widget.scale),
          border: Border.all(
            color: widget.wallpaper.accentColor.withValues(alpha: 0.6),
            width: 4 * widget.scale,
          ),
          boxShadow: [
            BoxShadow(
              color: widget.wallpaper.accentColor.withValues(alpha: 0.35),
              blurRadius: 24 * widget.scale,
              spreadRadius: 2 * widget.scale,
            ),
          ],
        ),
        child: ClipRRect(
          borderRadius: BorderRadius.circular(32 * widget.scale),
          child: contentStack,
        ),
      ),
    );
  }
}
