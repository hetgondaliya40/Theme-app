import 'package:flutter/material.dart';

enum IconShape { circle, squircle, roundedSquare, teardrop, diamond }

class AppThemeModel {
  final String id;
  final String title;
  final String category;
  final String author;
  final String description;
  final double rating;
  final int downloads;
  final String homeScreenWallpaperUrl;
  final String lockScreenWallpaperUrl;
  final Color primaryColor;
  final Color secondaryColor;
  final Color backgroundColor;
  final Color surfaceColor;
  final Color accentColor;
  final Color textColor;
  final String classicCombinationName;
  final String fontFamily;
  final IconShape iconShape;
  final bool isDark;
  final List<String> tags;

  const AppThemeModel({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    this.description = '',
    this.rating = 4.8,
    this.downloads = 12000,
    this.homeScreenWallpaperUrl = '',
    this.lockScreenWallpaperUrl = '',
    required this.primaryColor,
    required this.secondaryColor,
    required this.backgroundColor,
    required this.surfaceColor,
    required this.accentColor,
    required this.textColor,
    required this.classicCombinationName,
    this.fontFamily = 'Outfit',
    this.iconShape = IconShape.squircle,
    this.isDark = true,
    required this.tags,
  });
}
