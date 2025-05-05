import 'package:app/service/studyPlanService';
import 'package:flutter/material.dart';
import 'package:app/service/tests.service.dart';

class StudyPlanPage extends StatefulWidget {
  const StudyPlanPage({super.key});

  @override
  State<StudyPlanPage> createState() => _StudyPlanPageState();
}

class _StudyPlanPageState extends State<StudyPlanPage> {
  final _studyPlanService = StudyPlanService();
  final _testService = TestService();

  List<Map<String, dynamic>> _studyPlans = [];
  Map<String, List<String>> _subjectsAndTopics = {};
  String? _selectedSubject;
  String? _selectedTopic;
  List<String> _topicsForSelectedSubject = [];

  @override
  void initState() {
    super.initState();
    _loadData();
  }

  Future<void> _loadData() async {
    await _loadSubjectsAndTopics();
    await _loadStudyPlans();
  }

  Future<void> _loadSubjectsAndTopics() async {
    final subjects = await _testService.fetchSubjects();
    final Map<String, List<String>> subjectsMap = {};

    for (var subject in subjects) {
      final String name = subject['name'];
      final List<String> topics = (subject['topics'] as List)
          .map((topic) => topic['title'].toString())
          .toList();
      subjectsMap[name] = topics;
    }

    setState(() {
      _subjectsAndTopics = subjectsMap;
    });
  }

  Future<void> _loadStudyPlans() async {
    final plans = await _studyPlanService.fetchStudyPlans();
    setState(() {
      _studyPlans = plans;
    });
  }

  Future<void> _addNewTopic() async {
    if (_selectedSubject == null || _selectedTopic == null) return;

    await _studyPlanService.addStudyPlan(_selectedSubject!, _selectedTopic!);
    Navigator.pop(context);
    _loadStudyPlans();
  }

  Future<void> _updateProgress(String docId, int progress) async {
    await _studyPlanService.updateStudyProgress(docId, progress);
    _loadStudyPlans();
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
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: const Text('Adicionar Novo Tópico'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<String>(
                    decoration: const InputDecoration(labelText: 'Matéria'),
                    value: _selectedSubject,
                    isExpanded: true,
                    items: _subjectsAndTopics.keys.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(subject),
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
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
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
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar')),
                TextButton(onPressed: _addNewTopic, child: const Text('Adicionar')),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: _studyPlans.isEmpty
            ? const Center(child: Text('Nenhum tópico cadastrado ainda!'))
            : ListView.builder(
                itemCount: _studyPlans.length,
                itemBuilder: (context, index) {
                  final plan = _studyPlans[index];
                  return Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    elevation: 3,
                    child: ListTile(
                      leading: const CircleAvatar(
                        backgroundColor: Colors.deepPurple,
                        child: Icon(Icons.book, color: Colors.white),
                      ),
                      title: Text(plan['subject'], style: const TextStyle(fontWeight: FontWeight.bold)),
                      subtitle: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text("Tópico: ${plan['topic']}"),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              Expanded(
                                child: LinearProgressIndicator(
                                  value: (plan['progress'] ?? 0) / 100,
                                  backgroundColor: Colors.grey[300],
                                  color: Colors.deepPurple,
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.add_circle, color: Colors.green),
                                onPressed: () {
                                  int newProgress = ((plan['progress'] ?? 0) + 10).clamp(0, 100);
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
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.deepPurple,
        onPressed: _showAddTopicDialog,
        child: const Icon(Icons.add, color: Colors.white),
      ),
    );
  }
}
