import 'package:flutter_bloc/flutter_bloc.dart';
import 'theme_event.dart';
import 'theme_state.dart';

class ThemeBloc extends Bloc<ThemeEvent, ThemeState> {
  ThemeBloc() : super(ThemeState()) {
    on<ApplyThemeEvent>(_onApplyTheme);
    on<ToggleThemeFavoriteEvent>(_onToggleThemeFavorite);
  }

  void _onApplyTheme(ApplyThemeEvent event, Emitter<ThemeState> emit) {
    emit(state.copyWith(activeTheme: event.theme));
  }

  void _onToggleThemeFavorite(
      ToggleThemeFavoriteEvent event, Emitter<ThemeState> emit) {
    final updatedFavs = Set<String>.from(state.favoriteIds);
    if (updatedFavs.contains(event.themeId)) {
      updatedFavs.remove(event.themeId);
    } else {
      updatedFavs.add(event.themeId);
    }
    emit(state.copyWith(favoriteIds: updatedFavs));
  }
}
