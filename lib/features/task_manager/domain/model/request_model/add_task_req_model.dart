class AddTaskReqModel {
  final String title;
  final String description;
  final DateTime? dueDate;

  const AddTaskReqModel({
    required this.title,
    this.description = '',
    this.dueDate,
  });
}
