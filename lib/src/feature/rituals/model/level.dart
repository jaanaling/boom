// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Level {
  int id;
  int score;
  Level({
    required this.id,
    required this.score,
  });

  Level copyWith({
    int? id,
    int? score,
  }) {
    return Level(
      id: id ?? this.id,
      score: score ?? this.score,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'id': id,
      'score': score,
    };
  }

  factory Level.fromMap(Map<String, dynamic> map) {
    return Level(
      id: map['id'] as int,
      score: map['score'] as int,
    );
  }

  String toJson() => json.encode(toMap());

  factory Level.fromJson(String source) =>
      Level.fromMap(json.decode(source) as Map<String, dynamic>);

  @override
  String toString() => 'Level(id: $id, score: $score)';

  @override
  bool operator ==(covariant Level other) {
    if (identical(this, other)) return true;

    return other.id == id && other.score == score;
  }

  @override
  int get hashCode => id.hashCode ^ score.hashCode;
}
