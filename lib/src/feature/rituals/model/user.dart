// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:booms/src/feature/rituals/model/level.dart';
import 'package:flutter/foundation.dart';


class User {
  int coins;
  List<int> achievements; // Список ID разблокированных достижений
  List<Level> levels;

  // Накопительные данные
  // Время на уровне в секундах

  User({
    required this.coins,
    required this.achievements,
    required this.levels,
  });

  static User get initial => User(
        coins: 0,
        achievements: [],
        levels: [],
      );

  User copyWith({
    int? coins,
    List<int>? achievements,
    List<Level>? levels,
    int? openedCells,
    int? flagsPlaced,
    bool? usedShield,
    bool? usedMagnifier,
    int? timeSpent,
  }) {
    return User(
      coins: coins ?? this.coins,
      achievements: achievements ?? this.achievements,
      levels: levels ?? this.levels,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'coins': coins,
      'achievements': achievements,
      'levels': levels.map((x) => x.toMap()).toList(),
    };
  }

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      coins: map['coins'] as int,
      achievements: List<int>.from(map['achievements'] as List<dynamic>),
      levels: List<Level>.from(
        (map['levels'] as List<dynamic>).map<Level>(
          (x) => Level.fromMap(x as Map<String, dynamic>),
        ),
      ),
    );
  }

  String toJson() => json.encode(toMap());

  factory User.fromJson(String source) =>
      User.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'User(coins: $coins, achievements: $achievements, )';
  }

  @override
  bool operator ==(covariant User other) {
    if (identical(this, other)) return true;

    return other.coins == coins &&
        listEquals(other.achievements, achievements) &&
        listEquals(other.levels, levels);
  }

  @override
  int get hashCode {
    return coins.hashCode ^ achievements.hashCode ^ levels.hashCode;
  }
}
