import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:app/bd/banco_dados.dart';
import 'package:flutter/services.dart' show rootBundle;

class StudyPlanPage extends StatefulWidget {
  const StudyPlanPage({super.key});

  @override
  State<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends State<StudyPlanPage> {
  List<Map<String, dynamic>> _studyPlans = [];
  Map<String, List<String>> _subjectsAndTopics = {};
  String? _selectedSubject;
  String? _selectedTopic;
  List<String> _topicsForSelectedSubject = [];

  @override
  void initState() {
    super.initState();
    _loadStudyPlans();
    _loadSubjectsAndTopics();
  }

  Future<void> _loadStudyPlans() async {
    final dbHelper = DatabaseHelper();
    final plans = await dbHelper.getStudyPlan();
    setState(() {
      _studyPlans = plans;
    });
  }

  Future<void> _loadSubjectsAndTopics() async {
    final String response = await rootBundle.loadString('lib/assets/question.json');
    final data = json.decode(response);

    Map<String, List<String>> subjectsMap = {};
    for (var subject in data['subjects']) {
      List<String> topics = (subject['topics'] as List)
          .map<String>((topic) => topic['title'].toString())
          .toList();
      subjectsMap[subject['name'].toString()] = topics;
    }

    setState(() {
      _subjectsAndTopics = subjectsMap;
    });
  }

  Future<void> _addNewTopic() async {
    if (_selectedSubject == null || _selectedTopic == null) {
      return;
    }

    final dbHelper = DatabaseHelper();
    await dbHelper.insertStudyTopic(_selectedSubject!, _selectedTopic!);
    _loadStudyPlans();
    Navigator.pop(context);
  }

  void _showAddTopicDialog() {
    setState(() {
      _selectedSubject = null;
      _selectedTopic = null;
      _topicsForSelectedSubject = [];
    });

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder( // Usa StatefulBuilder para garantir atualização do diálogo
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Adicionar Novo Tópico'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text("Matéria", style: TextStyle(fontWeight: FontWeight.bold)),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Matéria'),
                      value: _selectedSubject,
                      isExpanded: true,
                      items: _subjectsAndTopics.keys.map((subject) {
                        return DropdownMenuItem(
                          value: subject,
                          child: Text(subject, style: const TextStyle(fontWeight: FontWeight.bold)),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _selectedSubject = value;
                          _selectedTopic = null;
                          _topicsForSelectedSubject = _subjectsAndTopics[_selectedSubject] ?? [];
                        });
                      },
                    ),
                  ),
                  const SizedBox(height: 10),
                  const Text("Tópico", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.deepPurple)),
                  SizedBox(
                    width: double.infinity,
                    child: DropdownButtonFormField<String>(
                      decoration: const InputDecoration(labelText: 'Tópico'),
                      value: _selectedTopic,
                      isExpanded: true,
                      items: _topicsForSelectedSubject.map((topic) {
                        return DropdownMenuItem(
                          value: topic,
                          child: Text(topic),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setModalState(() {
                          _selectedTopic = value;
                        });
                      },
                    ),
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Cancelar'),
                ),
                TextButton(
                  onPressed: _addNewTopic,
                  child: const Text('Adicionar'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  Future<void> _updateProgress(int id, int progress) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.updateStudyProgressByTopic(
        _studyPlans.firstWhere((plan) => plan['id'] == id)['subject'],
        _studyPlans.firstWhere((plan) => plan['id'] == id)['topic'],
        progress);
    _loadStudyPlans();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            Expanded(
              child: _studyPlans.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum tópico cadastrado ainda!',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.builder(
                      itemCount: _studyPlans.length,
                      itemBuilder: (context, index) {
                        final plan = _studyPlans[index];
                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: const Icon(Icons.book, color: Colors.white),
                            ),
                            title: Text(
                              plan['subject'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text("Tópico: ${plan['topic']}"),
                                const SizedBox(height: 4),
                                Row(
                                  children: [
                                    Expanded(
                                      child: LinearProgressIndicator(
                                        value: plan['progress'] / 100,
                                        backgroundColor: Colors.grey[300],
                                        color: Colors.deepPurple,
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle, color: Colors.green),
                                      onPressed: () {
                                        int newProgress = (plan['progress'] + 10).clamp(0, 100);
                                        _updateProgress(plan['id'], newProgress);
                                      },
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _showAddTopicDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
