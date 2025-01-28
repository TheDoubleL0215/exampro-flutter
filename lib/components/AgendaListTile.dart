import 'package:exam_flutter/models/Task.dart';
import 'package:exam_flutter/pages/EditTaskPage.dart';
import 'package:exam_flutter/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class AgendaListTile extends StatefulWidget {
  AgendaListTile({super.key, required this.task});

  final Task? task;

  @override
  State<AgendaListTile> createState() => _AgendaListTileState();
}

class _AgendaListTileState extends State<AgendaListTile> {
  final DatabaseService _databaseService = DatabaseService.instance;

  Task get task => widget.task!;

  final Map<String, IconData> _listTileIcon = {
    'homework': LucideIcons.home,
    'exam': LucideIcons.fileEdit,
    'reminder': LucideIcons.bell,
  };

  String _formatTileTitle(String type, String examType) {
    switch (type) {
      case 'homework':
        return "${type[0].toUpperCase()}${type.substring(1).toLowerCase()}";
      case 'exam':
        return "${type[0].toUpperCase()}${type.substring(1).toLowerCase()} - ${examType[0].toUpperCase()}${examType.substring(1).toLowerCase()}";
      case 'reminder':
        return 'Reminders';
      default:
        return type;
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      onTap: () {
        Navigator.push(
          context,
          MaterialPageRoute(
              builder: (context) => EditTaskPage(
                    task: task,
                  )),
        );
      },
      leading: CircleAvatar(child: Icon(_listTileIcon[task.type]!)),
      title: Text(_formatTileTitle(task.type, task.examType)),
      subtitle: Text(task.subject),
    );
  }
}
