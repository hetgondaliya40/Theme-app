import 'package:equatable/equatable.dart';

abstract class CoinEvent extends Equatable {
  const CoinEvent();

  @override
  List<Object?> get props => [];
}

class LoadCoinsEvent extends CoinEvent {
  const LoadCoinsEvent();
}

class EarnCoinFromAdEvent extends CoinEvent {
  final int coins;
  const EarnCoinFromAdEvent({this.coins = 10});

  @override
  List<Object?> get props => [coins];
}

class UnlockWallpaperEvent extends CoinEvent {
  final String wallpaperId;
  final int cost;
  const UnlockWallpaperEvent(this.wallpaperId, {this.cost = 10});

  @override
  List<Object?> get props => [wallpaperId, cost];
}

class ClaimDailyStreakEvent extends CoinEvent {
  const ClaimDailyStreakEvent();
}
