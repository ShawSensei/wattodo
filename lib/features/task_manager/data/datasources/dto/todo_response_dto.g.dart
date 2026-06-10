// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'todo_response_dto.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

TodoResponseDto _$TodoResponseDtoFromJson(Map<String, dynamic> json) =>
    TodoResponseDto(
      id: (json['id'] as num).toInt(),
      title: json['title'] as String,
      completed: json['completed'] as bool,
    );

Map<String, dynamic> _$TodoResponseDtoToJson(TodoResponseDto instance) =>
    <String, dynamic>{
      'id': instance.id,
      'title': instance.title,
      'completed': instance.completed,
    };
