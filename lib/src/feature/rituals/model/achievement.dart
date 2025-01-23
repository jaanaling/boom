// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

import 'package:booms/src/feature/rituals/model/user.dart';

class Achievement {
  final int id;
  final String title;
  final String description;
  final int reward;

  Achievement({
    required this.id,
    required this.title,
    required this.description,
    required this.reward,
  });

  Achievement copyWith({
    int? id,
    String? title,
    String? description,
    int? reward,
  }) {
    return Achievement(
      id: id ?? this.id,
      title: title ?? this.title,
      description: description ?? this.description,
      reward: reward ?? this.reward,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'title': title,
      'description': description,
      'reward': reward,
    };
  }

  factory Achievement.fromMap(Map<String, dynamic> map) {
    return Achievement(
      id: map['id'] as int,
      title: map['title'] as String,
      description: map['description'] as String,
      reward: map['reward'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Achievement.fromJson(String source) =>
      Achievement.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() {
    return 'Achievement(id: $id, title: $title, description: $description, reward: $reward)';
  }

  @override
  bool operator ==(covariant Achievement other) {
    if (identical(this, other)) return true;

    return other.id == id &&
        other.title == title &&
        other.description == description &&
        other.reward == reward;
  }

  @override
  int get hashCode {
    return id.hashCode ^
        title.hashCode ^
        description.hashCode ^
        reward.hashCode;
  }
}

