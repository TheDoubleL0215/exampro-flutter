import 'package:exam_flutter/models/Subject.dart';
import 'package:exam_flutter/services/database_service.dart';
import 'package:flutter/material.dart';
import 'package:lucide_icons/lucide_icons.dart';

class SubjectsPage extends StatefulWidget {
  const SubjectsPage({super.key});

  @override
  State<SubjectsPage> createState() => _SubjectsPageState();
}

class _SubjectsPageState extends State<SubjectsPage> {
  final DatabaseService _databaseService = DatabaseService.instance;
  final _subjectNameInput = TextEditingController();

  @override
  void dispose() {
    // Clean up the controller when the widget is removed from the
    // widget tree.
    _subjectNameInput.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: const Text('Subjects'),
        ),
        body: Padding(
          padding: const EdgeInsets.all(8.0),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: TextField(
                        controller: _subjectNameInput,
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          labelText: 'New subject',
                        ),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: FilledButton(
                        onPressed: () {
                          if (_subjectNameInput.text.isNotEmpty) {
                            _databaseService.addSubject(_subjectNameInput.text);
                            _subjectNameInput.clear();
                            setState(() {});
                          }
                        },
                        child: const Text("Add")),
                  ),
                ],
              ),
              const Divider(),
              Expanded(
                child: FutureBuilder(
                    future: _databaseService.getSubjects(),
                    builder: (context, snapshot) {
                      return ListView.builder(
                        itemCount: snapshot.data?.length ?? 0,
                        itemBuilder: (context, index) {
                          Subject subject = snapshot.data![index];
                          return ListTile(
                            title: Text(subject.name),
                            trailing: IconButton(
                              icon: const Icon(LucideIcons.trash2),
                              onPressed: () {
                                _databaseService.deleteSubject(subject.id);
                                setState(() {});
                              },
                            ),
                          );
                        },
                      );
                    }),
              )
            ],
          ),
        ));
  }
}
