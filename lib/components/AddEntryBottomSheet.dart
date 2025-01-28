import 'package:exam_flutter/models/Task.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';
import 'package:exam_flutter/models/Subject.dart';
import 'package:exam_flutter/services/database_service.dart';

class AddEntryBottomSheet extends StatefulWidget {
  const AddEntryBottomSheet({super.key});

  @override
  State<AddEntryBottomSheet> createState() => _AddEntryBottomSheetState();
}

enum Options { homework, exam, reminder }

enum ExamTypes { quiz, oral, unitTest }

class _AddEntryBottomSheetState extends State<AddEntryBottomSheet> {
  DateTime _selectedDate = DateTime.now();
  Options _optionVariable = Options.homework;
  ExamTypes _examType = ExamTypes.quiz;
  List<Subject> _subjects = []; // Class-level field for subjects
  String? _selectedSubject;

  final DatabaseService _databaseService = DatabaseService.instance;

  void _loadSubjects() async {
    _subjects = await DatabaseService.instance.getSubjects();
    setState(() {}); // Triggers a rebuild
  }

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding:
          MediaQuery.of(context).viewInsets.add(const EdgeInsets.all(16.0)),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          _recordTypeSegments(),
          const SizedBox(height: 20),
          _examTypeSegments(enabled: _optionVariable == Options.exam),
          const SizedBox(height: 20),
          _subjectPickerDropdown(),
          const SizedBox(height: 20),
          _saveOptions(context),
        ],
      ),
    );
  }

  ListTile _subjectPickerDropdown() {
    return ListTile(
      enabled: _subjects.isNotEmpty,
      trailing: Icon(LucideIcons.arrowRight),
      onTap: _showSubjectBottomSheet,
      title: Text("Subject"),
      subtitle: Text(_selectedSubject ?? 'Pick subject!'),
    );
  }

  void _showSubjectBottomSheet() {
    showModalBottomSheet(
      context: context,
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: _subjects.map((subject) {
                return ListTile(
                  title: Text(subject.name),
                  onTap: () {
                    setState(() {
                      _selectedSubject = subject.name;
                    });
                    Navigator.pop(
                        context); // Close the bottom sheet after selection
                  },
                );
              }).toList(),
            ),
          ),
        );
      },
    );
  }

  Row _saveOptions(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        TextButton.icon(
          icon: const Icon(
            Icons.schedule,
            size: 24,
          ),
          onPressed: () async {
            final DateTime? pickedDate = await showDatePicker(
              locale: const Locale('en', 'GB'),
              context: context,
              initialDate: _selectedDate,
              firstDate: DateTime(2000),
              lastDate: DateTime(2030),
            );
            if (pickedDate != null && pickedDate != _selectedDate) {
              setState(() {
                // Reset the time part to midnight (00:00:00)
                _selectedDate =
                    DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
              });
            }
          },
          label: Text(DateFormat('yyyy-MM-dd').format(_selectedDate)),
          style: TextButton.styleFrom(
            padding: EdgeInsets.zero, // Remove padding
            minimumSize: Size.zero, // Ensure minimal space around the button
            alignment: Alignment.centerLeft, // Align the icon and text
          ),
        ),
        FilledButton(
          onPressed: () {
            if (_selectedSubject != null) {
              _databaseService.addTask(
                Task(
                  id: 0,
                  subject: _selectedSubject!,
                  date: _selectedDate.toString().split(' ')[0],
                  type: _optionVariable.name,
                  examType: _examType.name,
                ),
              );
              Navigator.pop(context);
            }
            setState(() {});
          },
          child: const Text("Save"),
        ),
      ],
    );
  }

  SegmentedButton<ExamTypes> _examTypeSegments({bool enabled = false}) {
    return SegmentedButton<ExamTypes>(
      showSelectedIcon: false,
      selected: {_examType},
      onSelectionChanged: (Set<ExamTypes> newSelection) {
        setState(() {
          _examType = newSelection.first;
        });
      },
      segments: <ButtonSegment<ExamTypes>>[
        ButtonSegment(
          label: Text("Oral"),
          value: ExamTypes.oral,
          enabled: enabled,
        ),
        ButtonSegment(
          label: Text("Quiz"),
          value: ExamTypes.quiz,
          enabled: enabled,
        ),
        ButtonSegment(
          label: Text("Unit test"),
          value: ExamTypes.unitTest,
          enabled: enabled,
        ),
      ],
    );
  }

  SegmentedButton<Options> _recordTypeSegments() {
    return SegmentedButton<Options>(
      showSelectedIcon: false,
      selected: {_optionVariable},
      onSelectionChanged: (Set<Options> newSelection) {
        setState(() {
          _optionVariable = newSelection.first;
        });
      },
      segments: const <ButtonSegment<Options>>[
        ButtonSegment(
          value: Options.homework,
          label: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center, // Center align
            children: [
              Icon(LucideIcons.bookOpen),
              //SizedBox(height: 2),
              Text("Homework"),
            ],
          ),
        ),
        ButtonSegment(
          value: Options.exam,
          label: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(LucideIcons.fileEdit),
              SizedBox(height: 4),
              Text("Exam"),
            ],
          ),
        ),
        ButtonSegment(
          value: Options.reminder,
          label: Padding(
            padding: EdgeInsets.all(8.0),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(LucideIcons.bell),
                SizedBox(height: 4),
                Text("Reminder"),
              ],
            ),
          ),
        ),
      ],
    );
  }
}
