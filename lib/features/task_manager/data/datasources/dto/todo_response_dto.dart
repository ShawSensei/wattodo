import 'package:json_annotation/json_annotation.dart';
import 'package:uuid/uuid.dart';
import '../../../domain/model/data_model/task_data_model.dart';

part 'todo_response_dto.g.dart';

// Separate from TaskDataModel because API shape shouldn't dictate domain model
@JsonSerializable()
class TodoResponseDto {
  @JsonKey(name: 'id')
  final int id;

  @JsonKey(name: 'title')
  final String title;

  @JsonKey(name: 'completed')
  final bool completed;

  const TodoResponseDto({
    required this.id,
    required this.title,
    required this.completed,
  });

  factory TodoResponseDto.fromJson(Map<String, dynamic> json) =>
      _$TodoResponseDtoFromJson(json);

  Map<String, dynamic> toJson() => _$TodoResponseDtoToJson(this);

  // Generate a UUID so seeded tasks share the same id format as local tasks
  TaskDataModel toTaskDataModel() => TaskDataModel(
        id: const Uuid().v4(),
        title: title,
        isCompleted: completed,
        createdAt: DateTime.now(),
      );
}
