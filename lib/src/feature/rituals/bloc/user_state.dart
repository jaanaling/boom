part of 'user_bloc.dart';

abstract class UserState extends Equatable {
  const UserState();

  @override
  List<Object?> get props => [];
}

class UserLoading extends UserState {
  const UserLoading();
}

class UserLoaded extends UserState {
  final User user;
  final List<Achievement> achievements;


  const UserLoaded({
    required this.user,
    required this.achievements,

  });

  UserLoaded copyWith({
    User? user,
    List<Achievement>? achievements,

  }) {
    return UserLoaded(
      user: user ?? this.user,
      achievements: achievements ?? this.achievements,

    );
  }

  @override
  List<Object?> get props => [user, achievements];
}

class UserError extends UserState {
  final String message;
  const UserError(this.message);

  @override
  List<Object?> get props => [message];
}
