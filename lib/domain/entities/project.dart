import 'package:equatable/equatable.dart';
import 'package:hive/hive.dart';

part 'project.g.dart';

@HiveType(typeId: 0)
class Project extends Equatable {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final String description;

  @HiveField(3)
  final bool archived;

  @HiveField(4)
  final DateTime createdAt;

  const Project({
    required this.id,
    required this.name,
    required this.description,
    this.archived = false,
    required this.createdAt,
  });

  Project copyWith({
    String? name,
    String? description,
    bool? archived,
  }) {
    return Project(
      id: id,
      name: name ?? this.name,
      description: description ?? this.description,
      archived: archived ?? this.archived,
      createdAt: createdAt,
    );
  }

  @override
  List<Object?> get props => [id, name, description, archived, createdAt];
}