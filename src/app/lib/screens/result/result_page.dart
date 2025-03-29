import 'package:app/bd/banco_dados.dart';
import 'package:flutter/material.dart';

class ResultsPage extends StatefulWidget {
  const ResultsPage({super.key});

  @override
  State<ResultsPage> createState() => _ResultsPageState();
}

class _ResultsPageState extends State<ResultsPage> {
  List<Map<String, dynamic>> _results = [];
  List<String> _subjects = [];
  String? _selectedSubject;

  @override
  void initState() {
    super.initState();
    _loadSubjectsAndResults();
  }

  Future<void> _loadSubjectsAndResults() async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getResults();

    final subjects = results
        .map((result) => result['subject'] as String?)
        .where((subject) => subject != null)
        .cast<String>()
        .toSet()
        .toList();

    setState(() {
      _results = results;
      _subjects = subjects;
    });
  }

  Future<void> _loadFilteredResults(String subject) async {
    final dbHelper = DatabaseHelper();
    final results = await dbHelper.getResults();
    setState(() {
      _results = results.where((result) => result['subject'] == subject).toList();
    });
  }

  Future<void> _deleteResult(int id) async {
    final dbHelper = DatabaseHelper();
    await dbHelper.deleteResult(id);
    if (_selectedSubject != null) {
      _loadFilteredResults(_selectedSubject!);
    } else {
      _loadSubjectsAndResults();
    }
  }

  void _showDeleteConfirmation(int id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          title: const Text(
            'Excluir Resultado?',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
          ),
          content: const Text(
            'Você tem certeza de que deseja excluir este resultado? Essa ação não pode ser desfeita.',
            style: TextStyle(fontSize: 16),
          ),
          actionsAlignment: MainAxisAlignment.spaceBetween,
          actions: [
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.grey[400],
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () => Navigator.pop(context),
              child: const Text(
                'Cancelar',
                style: TextStyle(color: Colors.black),
              ),
            ),
            ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.redAccent,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
              ),
              onPressed: () {
                _deleteResult(id);
                Navigator.pop(context);
              },
              child: const Text('Excluir'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            if (_subjects.isNotEmpty)
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(color: Colors.deepPurpleAccent),
                ),
                child: DropdownButton<String>(
                  value: _selectedSubject,
                  hint: const Text('Filtrar por disciplina'),
                  isExpanded: true,
                  underline: const SizedBox(),
                  icon: const Icon(Icons.arrow_drop_down, color: Colors.deepPurple),
                  items: [
                    DropdownMenuItem(
                      value: null,
                      child: Text(
                        'Todas',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.deepPurple,
                        ),
                      ),
                    ),
                    ..._subjects.map((subject) {
                      return DropdownMenuItem(
                        value: subject,
                        child: Text(
                          subject,
                          style: const TextStyle(fontSize: 16),
                        ),
                      );
                    }).toList(),
                  ],
                  onChanged: (value) {
                    setState(() {
                      _selectedSubject = value;
                    });
                    if (value != null) {
                      _loadFilteredResults(value);
                    } else {
                      _loadSubjectsAndResults();
                    }
                  },
                ),
              ),
            const SizedBox(height: 16),
            Expanded(
              child: _results.isEmpty
                  ? const Center(
                      child: Text(
                        'Nenhum resultado disponível.',
                        style: TextStyle(fontSize: 16),
                      ),
                    )
                  : ListView.separated(
                      itemCount: _results.length,
                      separatorBuilder: (context, index) => const Divider(),
                      itemBuilder: (context, index) {
                        final result = _results[index];
                        final correctAnswers = result['correctAnswers'];
                        final totalQuestions = result['totalQuestions'];
                        final percentage =
                            ((correctAnswers / totalQuestions) * 100).toStringAsFixed(1);

                        return Card(
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          elevation: 3,
                          child: ListTile(
                            leading: CircleAvatar(
                              backgroundColor: Colors.deepPurple,
                              child: const Icon(Icons.assessment, color: Colors.white),
                            ),
                            title: Text(
                              result['topic'],
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontSize: 16,
                              ),
                            ),
                            subtitle: Text(
                              'Acertos: $correctAnswers/$totalQuestions ($percentage%)',
                            ),
                            trailing: IconButton(
                              icon: const Icon(Icons.delete, color: Colors.red),
                              onPressed: () {
                                _showDeleteConfirmation(result['id']);
                              },
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}