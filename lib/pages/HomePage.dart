import 'package:exam_flutter/components/AddEntryBottomSheet.dart';
import 'package:exam_flutter/components/AgendaListTile.dart';
import 'package:exam_flutter/models/Task.dart';
import 'package:exam_flutter/pages/SubjectsPage.dart';
import 'package:exam_flutter/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:grouped_list/grouped_list.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage> {
  final DatabaseService _databaseService = DatabaseService.instance;

  @override
  void initState() {
    super.initState();
    _databaseService.fetchTasks();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Agenda'),
        actions: [
          IconButton(
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => SubjectsPage()),
              );
            },
            icon: const Icon(LucideIcons.settings2),
          )
        ],
      ),
      body: StreamBuilder<List<Task>>(
        stream: _databaseService.tasksStream,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
            return const Center(child: Text('No tasks available'));
          }

          final tasks = snapshot.data!;
          return GroupedListView<Task, String>(
            elements: tasks,
            groupBy: (task) => task.date, // Group tasks by date
            groupSeparatorBuilder: (String date) => Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    _formatDate(date),
                    style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Theme.of(context).colorScheme.primary),
                  ),
                  Divider(
                    color: Theme.of(context).colorScheme.primary,
                  )
                ],
              ),
            ),
            itemBuilder: (context, Task task) {
              return AgendaListTile(task: task);
            },
            order: GroupedListOrder.ASC,
          );
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          showModalBottomSheet(
            context: context,
            isScrollControlled: true, // Ensures full-screen modal capability
            shape: const RoundedRectangleBorder(
              borderRadius: BorderRadius.vertical(top: Radius.circular(16)),
            ),
            useRootNavigator: true,
            builder: (BuildContext context) {
              return AddEntryBottomSheet();
            },
          ).then((_) => _databaseService
              .fetchTasks()); // Reload tasks after adding a new one
        },
        tooltip: 'Add Entry',
        child: const Icon(Icons.add),
      ),
    );
  }

  String _formatDate(String date) {
    final now = DateTime.now();
    final today = DateTime(now.year, now.month, now.day);
    final yesterday = DateTime(now.year, now.month, now.day - 1);
    final tomorrow = DateTime(now.year, now.month, now.day + 1);

    if (DateTime.parse(date) == today) {
      return 'Today';
    } else if (DateTime.parse(date) == yesterday) {
      return 'Yesterday';
    } else if (DateTime.parse(date) == tomorrow) {
      return 'Tomorrow';
    }
    final parsedDate = DateTime.parse(date.replaceAll('.', '-'));
    return DateFormat('MMMM d').format(parsedDate);
  }
}
