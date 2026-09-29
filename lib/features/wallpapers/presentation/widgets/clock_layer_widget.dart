import 'dart:async';
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import '../../data/models/depth_clock_config.dart';

class ClockLayerWidget extends StatefulWidget {
  final DepthClockConfig config;
  final double scale;

  const ClockLayerWidget({
    super.key,
    required this.config,
    this.scale = 1.0,
  });

  @override
  State<ClockLayerWidget> createState() => _ClockLayerWidgetState();
}

class _ClockLayerWidgetState extends State<ClockLayerWidget> {
  late Timer _timer;
  late DateTime _currentTime;

  @override
  void initState() {
    super.initState();
    _currentTime = DateTime.now();
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (mounted) {
        setState(() {
          _currentTime = DateTime.now();
        });
      }
    });
  }

  @override
  void dispose() {
    _timer.cancel();
    super.dispose();
  }

  String get _formattedTime {
    final hour = _currentTime.hour.toString().padLeft(2, '0');
    final minute = _currentTime.minute.toString().padLeft(2, '0');
    return '$hour:$minute';
  }

  String get _formattedDate {
    final months = [
      'Jan',
      'Feb',
      'Mar',
      'Apr',
      'May',
      'Jun',
      'Jul',
      'Aug',
      'Sep',
      'Oct',
      'Nov',
      'Dec'
    ];
    final days = ['Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat', 'Sun'];
    final dayName = days[_currentTime.weekday - 1];
    final monthName = months[_currentTime.month - 1];
    return '$dayName, ${widget.config.showClock ? monthName : _currentTime.month} ${_currentTime.day}';
  }

  @override
  Widget build(BuildContext context) {
    if (!widget.config.showClock && !widget.config.showDate) {
      return const SizedBox.shrink();
    }

    final double baseFontSize = 72 * widget.scale;
    final TextStyle clockTextStyle = GoogleFonts.getFont(
      widget.config.fontFamily,
      fontSize: baseFontSize,
      fontWeight: FontWeight.w800,
      color: widget.config.clockColor,
      shadows: [
        Shadow(
          color: widget.config.shadowColor,
          blurRadius: 16 * widget.scale,
          offset: Offset(0, 4 * widget.scale),
        ),
      ],
    );

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        if (widget.config.showDate)
          Text(
            _formattedDate,
            style: TextStyle(
              color: widget.config.clockColor.withValues(alpha: 0.9),
              fontSize: 14 * widget.scale,
              fontWeight: FontWeight.w600,
              letterSpacing: 1.2,
              shadows: [
                Shadow(
                  color: widget.config.shadowColor,
                  blurRadius: 8 * widget.scale,
                  offset: Offset(0, 2 * widget.scale),
                ),
              ],
            ),
          ),
        if (widget.config.showClock) ...[
          SizedBox(height: 4 * widget.scale),
          Text(
            _formattedTime,
            style: clockTextStyle,
          ),
        ],
      ],
    );
  }
}
