part of 'user_bloc.dart';

sealed class UserEvent extends Equatable {
  const UserEvent();

  @override
  List<Object> get props => [];
}

class UserPuzzleSolved extends UserEvent {
  final bool isCorrect;
  final int score;
  final int openedCells;
  final int flagsPlaced;
  final bool usedShield;
  final bool usedMagnifier;
  final int timeSpent;

  const UserPuzzleSolved(
      {required this.isCorrect,
      required this.score,
      required this.openedCells,
      required this.flagsPlaced,
      required this.usedShield,
      required this.usedMagnifier,
      required this.timeSpent});

  @override
  List<Object> get props => [
        isCorrect,
        score,
        openedCells,
        flagsPlaced,
        usedShield,
        usedMagnifier,
        timeSpent
      ];
}

class UserAchievementEarned extends UserEvent {
  final int achievementId;

  const UserAchievementEarned(this.achievementId);

  @override
  List<Object> get props => [achievementId];
}

class UserLoadData extends UserEvent {
  const UserLoadData();
}

class UserAddCoins extends UserEvent {
  final int coins;

  const UserAddCoins(this.coins);

  @override
  List<Object> get props => [coins];
}

class UserRemoveCoins extends UserEvent {
  final int coins;

  const UserRemoveCoins(this.coins);

  @override
  List<Object> get props => [coins];
}

