import 'package:dart_json_mapper/dart_json_mapper.dart';

/// Base entity class providing common properties for all entities.
@jsonSerializable
abstract class BaseEntity<TId> {
  BaseEntity({
    required this.id,
    required this.createdDate,
    this.modifiedDate,
    this.deletedDate,
  });

  TId id;
  DateTime createdDate;
  DateTime? modifiedDate;
  DateTime? deletedDate;

  bool get isDeleted => deletedDate != null;

  Map<String, dynamic> toJson() => {
        'id': id,
        'createdDate': createdDate.toIso8601String(),
        'modifiedDate': modifiedDate?.toIso8601String(),
        'deletedDate': deletedDate?.toIso8601String(),
      };

  static Map<String, dynamic> baseFromJson(Map<String, dynamic> json) => {
        'id': json['id'],
        'createdDate': DateTime.parse(json['createdDate'] as String),
        'modifiedDate': json['modifiedDate'] != null ? DateTime.parse(json['modifiedDate'] as String) : null,
        'deletedDate': json['deletedDate'] != null ? DateTime.parse(json['deletedDate'] as String) : null,
      };
}
