import 'package:bloc/bloc.dart';
import 'package:booms/src/core/dependency_injection.dart';
import 'package:booms/src/feature/rituals/model/achievement.dart';
import 'package:booms/src/feature/rituals/model/level.dart';
import 'package:booms/src/feature/rituals/model/user.dart';
import 'package:booms/src/feature/rituals/repository/user_repository.dart';
import 'package:equatable/equatable.dart';

part 'user_event.dart';
part 'user_state.dart';

class UserBloc extends Bloc<UserEvent, UserState> {
  final UserRepository userRepository = locator<UserRepository>();

  UserBloc() : super(const UserLoading()) {
    on<UserLoadData>(_onUserLoadData);
    on<UserPuzzleSolved>(_onPuzzleSolved);
    on<UserAchievementEarned>(_onAchievementEarned);
    on<UserAddCoins>(_onAddCoins);
    on<UserRemoveCoins>(_onRemoveCoins);
  }

  Future<void> _onUserLoadData(
    UserLoadData event,
    Emitter<UserState> emit,
  ) async {
    emit(const UserLoading());
    try {
      final user = await userRepository.load() ?? User.initial;
      final achievements = await userRepository.loadAchievements();

      emit(
        UserLoaded(
          user: user,
          achievements: achievements,
        ),
      );
    } catch (e) {
      emit(UserError('Произошла ошибка при загрузке: $e'));
    }
  }

  void _onPuzzleSolved(UserPuzzleSolved event, Emitter<UserState> emit) {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;

    final wasCorrect = event.isCorrect;

    if (!wasCorrect) return;
    final oldUser = current.user;
    final levels = [...oldUser.levels];

    if (wasCorrect) {
      levels.add(Level(id: levels.length + 1, score: event.score));
    }

    final newCoins = wasCorrect ? oldUser.coins + 5 : oldUser.coins;

    final newUser = oldUser.copyWith(
      coins: newCoins,
      levels: levels,
    );

    emit(current.copyWith(user: newUser));

    checkAndUnlockAchievements(newUser, event.openedCells, event.flagsPlaced,
        event.usedShield, event.usedMagnifier, event.timeSpent);
  }

  void _onAchievementEarned(
    UserAchievementEarned event,
    Emitter<UserState> emit,
  ) {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;
    final oldUser = current.user;

    if (oldUser.achievements.contains(event.achievementId)) return;

    Achievement? achievement;
    try {
      achievement =
          current.achievements.firstWhere((a) => a.id == event.achievementId);
    } catch (_) {
      return;
    }

    final newAchievements = List<int>.from(oldUser.achievements)
      ..add(achievement.id);
    final newCoins = oldUser.coins + achievement.reward;

    final newUser = oldUser.copyWith(
      achievements: newAchievements,
      coins: newCoins,
    );

    emit(current.copyWith(user: newUser));
  }

  void _onAddCoins(UserAddCoins event, Emitter<UserState> emit) {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;
    final newUser = current.user.copyWith(coins: current.user.coins + event.coins);
    emit(current.copyWith(user: newUser));
  }

  void _onRemoveCoins(UserRemoveCoins event, Emitter<UserState> emit) {
    if (state is! UserLoaded) return;
    final current = state as UserLoaded;
    final newUser = current.user.copyWith(coins: current.user.coins - event.coins);
    emit(current.copyWith(user: newUser));
  }


  void checkAndUnlockAchievements(User user, int openedCells, int flagsPlaced,
      bool usedShield, bool usedMagnifier, int timeSpent) {
    // Проверяем условия для достижения 'First Step'
    if (openedCells >= 1) {
      add(const UserAchievementEarned(1)); // Achievement 'First Step'
    }

    // Проверяем условия для достижения 'Master of Minefields'
    if (openedCells >= 50) {
      add(const UserAchievementEarned(2));
    }

    // Проверяем условия для достижения 'Immunity'
    if (openedCells > 0 &&
        flagsPlaced == 0 &&
        usedShield == false &&
        usedMagnifier == false) {
      add(const UserAchievementEarned(3));
    }

    // Проверяем условия для достижения 'Mine Magnet'
    if (usedMagnifier) {
      add(const UserAchievementEarned(4));
    }

    // Проверяем условия для достижения 'Shield Protector'
    if (usedShield) {
      add(const UserAchievementEarned(5));
    }

    // Проверяем условия для достижения 'Fearless'
    if (openedCells >= 100) {
      add(const UserAchievementEarned(6));
    }

    // Проверяем условия для достижения 'Auto-Winner'
    if (timeSpent < 60) {
      add(const UserAchievementEarned(7));
    }

    // Проверяем условия для достижения 'Flagging Expert'
    if (flagsPlaced >= 10) {
      add(const UserAchievementEarned(8));
    }

    // Проверяем условия для достижения 'Time Titan'
    if (timeSpent <= 300) {
      add(const UserAchievementEarned(9));
    }

    // Проверяем условия для достижения 'Instant Victory'
    if (timeSpent <= 60) {
      add(const UserAchievementEarned(10));
    }

    // Дополнительные достижения

    // Проверяем условия для достижения 'No Mines Detected'
    if (flagsPlaced == 0) {
      add(const UserAchievementEarned(11));
    }

    // Проверяем условия для достижения 'Perfectionist'
    if (flagsPlaced == openedCells) {
      add(const UserAchievementEarned(12));
    }

    // Проверяем условия для достижения 'Lucky Escape'
    if (openedCells == 1 && flagsPlaced == 0 && usedShield) {
      add(const UserAchievementEarned(13));
    }

    // Проверяем условия для достижения 'Swift as the Wind'
    if (timeSpent <= 180) {
      add(const UserAchievementEarned(14));
    }

    // Проверяем условия для достижения 'Master Strategist'
    if (flagsPlaced >= 20) {
      add(const UserAchievementEarned(15));
    }

    // Проверяем условия для достижения 'Treasure Hunter'
    if (openedCells == flagsPlaced && timeSpent <= 150) {
      add(const UserAchievementEarned(16));
    }

    // Проверяем условия для достижения 'The Great Escape'
    if (usedShield && usedMagnifier) {
      add(const UserAchievementEarned(17));
    }

    // Проверяем условия для достижения 'Minefield Navigator'
    if (openedCells >= 200) {
      add(const UserAchievementEarned(18));
    }

    // Проверяем условия для достижения 'Super Flagger'
    if (flagsPlaced >= 30) {
      add(const UserAchievementEarned(19));
    }

    // Проверяем условия для достижения 'Time Master'
    if (timeSpent <= 120) {
      add(const UserAchievementEarned(20));
    }
  }
}
