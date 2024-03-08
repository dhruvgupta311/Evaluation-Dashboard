// ignore_for_file: public_member_api_docs, sort_constructors_first
import 'dart:convert';

class Mentor {
  String uid;
  String name;
  List<String> assignedStudents;
  Mentor({
    required this.uid,
    required this.name,
    required this.assignedStudents,
  });

  Mentor copyWith({
    String? uid,
    String? name,
    List<String>? studentAssign,
  }) {
    return Mentor(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      assignedStudents: studentAssign ?? this.assignedStudents,
    );
  }

  Map<String, dynamic> toMap() {
    return <String, dynamic>{
      'uid': uid,
      'name': name,
      'studentAssign': assignedStudents,
    };
  }

  factory Mentor.fromMap(Map<String, dynamic> map) {
    return Mentor(
      uid: map['uid'] as String,
      name: map['name'] as String,
      assignedStudents: List<String>.from((map['studentAssign'] as List<String>),
    ));
  }

  String toJson() => json.encode(toMap());

  factory Mentor.fromJson(String source) => Mentor.fromMap(json.decode(source) as Map<String, dynamic>);
}