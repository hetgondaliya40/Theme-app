import 'package:flutter/material.dart';

class ClassicColorPalette {
  final String id;
  final String name;
  final String eraOrStyle;
  final String description;
  final Color primary;
  final Color secondary;
  final Color accent;
  final Color surface;
  final Color background;
  final List<String> hexCodes;
  final String contrastRating;
  final String recommendedUsage;

  const ClassicColorPalette({
    required this.id,
    required this.name,
    required this.eraOrStyle,
    required this.description,
    required this.primary,
    required this.secondary,
    required this.accent,
    required this.surface,
    required this.background,
    required this.hexCodes,
    required this.contrastRating,
    required this.recommendedUsage,
  });
}
