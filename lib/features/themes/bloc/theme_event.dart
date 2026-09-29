import 'package:equatable/equatable.dart';
import '../data/models/app_theme_model.dart';

abstract class ThemeEvent extends Equatable {
  const ThemeEvent();

  @override
  List<Object?> get props => [];
}

class ApplyThemeEvent extends ThemeEvent {
  final AppThemeModel theme;
  const ApplyThemeEvent(this.theme);

  @override
  List<Object?> get props => [theme];
}

class ToggleThemeFavoriteEvent extends ThemeEvent {
  final String themeId;
  const ToggleThemeFavoriteEvent(this.themeId);

  @override
  List<Object?> get props => [themeId];
}
