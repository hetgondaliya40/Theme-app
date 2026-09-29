import 'package:equatable/equatable.dart';
import '../data/models/app_theme_model.dart';
import '../data/sources/mock_themes_data.dart';

class ThemeState extends Equatable {
  final AppThemeModel activeTheme;
  final Set<String> favoriteIds;
  final List<AppThemeModel> themes;

  ThemeState({
    AppThemeModel? activeTheme,
    this.favoriteIds = const {},
    List<AppThemeModel>? themes,
  })  : activeTheme = activeTheme ?? MockThemesData.sampleThemes.first,
        themes = themes ?? MockThemesData.sampleThemes;

  bool isFavorite(String themeId) => favoriteIds.contains(themeId);

  ThemeState copyWith({
    AppThemeModel? activeTheme,
    Set<String>? favoriteIds,
    List<AppThemeModel>? themes,
  }) {
    return ThemeState(
      activeTheme: activeTheme ?? this.activeTheme,
      favoriteIds: favoriteIds ?? this.favoriteIds,
      themes: themes ?? this.themes,
    );
  }

  @override
  List<Object?> get props => [activeTheme, favoriteIds, themes];
}
