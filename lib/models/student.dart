// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Student {
  String uid;
  String executionMarks;
  String ideationMarks;
  String vivaMarks;
  String name;
  bool isAssigned;
  Student({
    required this.uid,
    required this.executionMarks,
    required this.ideationMarks,
    required this.vivaMarks,
    required this.name,
    required this.isAssigned,
  });

  Student copyWith({
    String? uid,
    String? execution,
    String? ideation,
    String? viva,
    String? name,
    bool? isAssigned,
  }) {
    return Student(
      uid: uid ?? this.uid,
      executionMarks: execution ?? this.executionMarks,
      ideationMarks: ideation ?? this.ideationMarks,
      vivaMarks: viva ?? this.vivaMarks,
      name: name ?? this.name,
      isAssigned: isAssigned ?? this.isAssigned,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'execution': executionMarks,
      'ideation': ideationMarks,
      'viva': vivaMarks,
      'name': name,
      'isAssigned':isAssigned,
    };
  }

  factory Student.fromMap(Map<String, dynamic> map) {
    return Student(
      uid: map['uid'] as String,
      executionMarks: map['execution'] as String,
      ideationMarks: map['ideation'] as String,
      vivaMarks: map['viva'] as String,
      name: map['name'] as String,
      isAssigned: map['isAssigned'] as bool,
    );
  }

  String toJson() => json.encode(toMap());

  factory Student.fromJson(String source) =>
      Student.fromMap(json.decode(source) as Map<String, dynamic>);
}