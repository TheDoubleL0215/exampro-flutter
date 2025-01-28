class Task {
  final int id;
  final String subject;
  final String date;
  final String type;
  final String examType;
  final String description;

  Task({
    this.description = "",
    required this.id,
    required this.subject,
    required this.date,
    required this.type,
    required this.examType,
  });
}
