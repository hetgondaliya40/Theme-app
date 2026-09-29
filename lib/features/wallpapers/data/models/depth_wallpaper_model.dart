import 'package:flutter/material.dart';
import 'depth_clock_config.dart';

class DepthWallpaperModel {
  final String id;
  final String title;
  final String category;
  final String author;
  final String description;
  final double rating;
  final int downloads;
  final String backgroundUrl;
  final String foregroundCutoutUrl;
  final DepthClockConfig defaultClockConfig;
  final List<String> tags;
  final Color accentColor;
  final bool isFeatured;
  final bool isTrending;
  final bool isPremium;

  const DepthWallpaperModel({
    required this.id,
    required this.title,
    required this.category,
    required this.author,
    required this.description,
    required this.rating,
    required this.downloads,
    required this.backgroundUrl,
    required this.foregroundCutoutUrl,
    required this.defaultClockConfig,
    required this.tags,
    required this.accentColor,
    this.isFeatured = false,
    this.isTrending = false,
    this.isPremium = false,
  });

  DepthWallpaperModel copyWith({
    String? id,
    String? title,
    String? category,
    String? author,
    String? description,
    double? rating,
    int? downloads,
    String? backgroundUrl,
    String? foregroundCutoutUrl,
    DepthClockConfig? defaultClockConfig,
    List<String>? tags,
    Color? accentColor,
    bool? isFeatured,
    bool? isTrending,
    bool? isPremium,
  }) {
    return DepthWallpaperModel(
      id: id ?? this.id,
      title: title ?? this.title,
      category: category ?? this.category,
      author: author ?? this.author,
      description: description ?? this.description,
      rating: rating ?? this.rating,
      downloads: downloads ?? this.downloads,
      backgroundUrl: backgroundUrl ?? this.backgroundUrl,
      foregroundCutoutUrl: foregroundCutoutUrl ?? this.foregroundCutoutUrl,
      defaultClockConfig: defaultClockConfig ?? this.defaultClockConfig,
      tags: tags ?? this.tags,
      accentColor: accentColor ?? this.accentColor,
      isFeatured: isFeatured ?? this.isFeatured,
      isTrending: isTrending ?? this.isTrending,
      isPremium: isPremium ?? this.isPremium,
    );
  }
}
