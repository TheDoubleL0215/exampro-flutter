import 'package:exam_flutter/models/Subject.dart';
import 'package:exam_flutter/models/Task.dart';
import 'package:exam_flutter/services/database_service.dart';
import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lucide_icons/lucide_icons.dart';

class EditTaskPage extends StatefulWidget {
  const EditTaskPage({super.key, required this.task});

  final Task task;

  @override
  State<EditTaskPage> createState() => _EditTaskPageState();
}

enum TaskOptions { homework, exam, reminder }

enum ExamTypes { quiz, oral, unitTest }

class _EditTaskPageState extends State<EditTaskPage> {
  late List<Subject> _subjects = [];
  late DateTime _selectedDate;
  late String _selectedSubject = widget.task.subject;
  late DatabaseService _databaseService;
  late TaskOptions _selectedTask = TaskOptions.values.firstWhere(
    (e) => e.name == widget.task.type,
  );

  late ExamTypes _selectedExamtype = ExamTypes.values.firstWhere(
    (e) => e.name == widget.task.examType,
    orElse: () => ExamTypes.quiz,
  );
  TextEditingController _descriptionController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _databaseService = DatabaseService.instance;
    _selectedDate = DateTime.parse(widget.task.date);
    _descriptionController.text = widget.task.description;
    _loadSubjects();
  }

  void _loadSubjects() async {
    _subjects = await _databaseService.getSubjects();
    setState(() {}); // Triggers a rebuild once subjects are loaded
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Edit Task'),
        ),
        body: SafeArea(
          // Ensures UI is not overlapped by system UI
          child: SingleChildScrollView(
            // Makes the body scrollable
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  _subjectPickerTitle(),
                  _descriptionField(),
                  _setDateField(context),
                  _typeSelecter(),
                  Visibility(
                    child: _examTypeRadioGroup(),
                    visible: _selectedTask == TaskOptions.exam,
                  ),
                  const SizedBox(
                      height: 16), // Adds some spacing before the button
                ],
              ),
            ),
          ),
        ),
        bottomNavigationBar: BottomAppBar(
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              IconButton(
                icon: const Icon(LucideIcons.trash2),
                onPressed: () {
                  _databaseService.deleteTask(widget.task.id);
                  Navigator.pop(context);
                },
              ),
              FilledButton(
                onPressed: () {
                  _databaseService.deleteTask(widget.task.id);
                  _databaseService.addTask(Task(
                    id: 0,
                    subject: _selectedSubject,
                    date: _selectedDate.toString().split(' ')[0],
                    type: _selectedTask.name,
                    description: _descriptionController.text,
                    examType: _selectedTask == TaskOptions.exam
                        ? _selectedExamtype.name
                        : "",
                  ));
                  Navigator.pop(context);
                },
                child: const Text('Save Task'),
              ),
            ],
          ),
        ));
  }

  Column _examTypeRadioGroup() {
    return Column(
      children: [
        RadioListTile<ExamTypes>(
          value: ExamTypes.oral,
          groupValue: _selectedExamtype,
          title: const Text('Oral'),
          onChanged: (value) {
            setState(() {
              _selectedExamtype = value!;
            });
          },
        ),
        RadioListTile<ExamTypes>(
          value: ExamTypes.quiz,
          groupValue: _selectedExamtype,
          title: const Text('Quiz'),
          onChanged: (value) {
            setState(() {
              _selectedExamtype = value!;
            });
          },
        ),
        RadioListTile<ExamTypes>(
          value: ExamTypes.unitTest,
          groupValue: _selectedExamtype,
          title: const Text('Unit test'),
          onChanged: (value) {
            setState(() {
              _selectedExamtype = value!;
            });
          },
        )
      ],
    );
  }

  Padding _typeSelecter() {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 16.0),
      child: SizedBox(
        width: double.infinity, // Makes it full width
        child: SegmentedButton<TaskOptions>(
          showSelectedIcon: false,
          segments: const <ButtonSegment<TaskOptions>>[
            ButtonSegment(
              value: TaskOptions.homework,
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
              value: TaskOptions.exam,
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
              value: TaskOptions.reminder,
              label: Padding(
                padding: EdgeInsets.all(8.0),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(CupertinoIcons.add_circled),
                    SizedBox(height: 4),
                    Text("Reminder"),
                  ],
                ),
              ),
            ),
          ],
          selected: {_selectedTask}, // Wrap it inside a set
          onSelectionChanged: (Set<TaskOptions> newSelection) {
            setState(() {
              _selectedTask = newSelection.first; // Update the selected task
            });
          },
        ),
      ),
    );
  }

  Padding _subjectPickerTitle() {
    return Padding(
      padding: const EdgeInsets.all(16.0),
      child: Container(
        width: double.infinity,
        child: GestureDetector(
          onTap: _showSubjectBottomSheet,
          child: Text(
            textAlign: TextAlign.start,
            _selectedSubject,
            style: const TextStyle(fontSize: 32, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  ListTile _descriptionField() {
    return ListTile(
      leading: const Icon(LucideIcons.text),
      title: TextField(
        onTapOutside: (event) => FocusManager.instance.primaryFocus?.unfocus(),
        controller: _descriptionController,
        keyboardType: TextInputType.multiline,
        minLines: 1, //Normal textInputField will be displayed
        maxLines: 5, // when user presses enter it will adapt to it
        decoration: const InputDecoration(
          contentPadding: EdgeInsets.symmetric(vertical: 10),
          hintText: 'Add description',
          border: OutlineInputBorder(borderSide: BorderSide.none),
        ),
      ),
    );
  }

  void _showSubjectBottomSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true, // Allows dynamic height
      builder: (context) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize
                  .min, // Makes the bottom sheet take only necessary height
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

  ListTile _setDateField(BuildContext context) {
    return ListTile(
      leading: const Icon(
        LucideIcons.clock4,
        size: 24,
      ),
      onTap: () async {
        final DateTime? pickedDate = await showDatePicker(
          locale: const Locale('en', 'GB'),
          context: context,
          initialDate: _selectedDate,
          firstDate: DateTime(2000),
          lastDate: DateTime(2030),
        );
        if (pickedDate != null && pickedDate != _selectedDate) {
          setState(() {
            _selectedDate =
                DateTime(pickedDate.year, pickedDate.month, pickedDate.day);
          });
        }
      },
      title: Text(DateFormat("EEEE, yyyy MMMM dd").format(_selectedDate)),
    );
  }
}
