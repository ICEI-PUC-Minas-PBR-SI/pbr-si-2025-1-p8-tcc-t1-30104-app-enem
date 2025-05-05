import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/tests/questions_page.dart';
import 'package:app/service/tests.service.dart';

class SimuladoPage extends StatefulWidget {
  const SimuladoPage({super.key});

  @override
  State<SimuladoPage> createState() => _SimuladoPageState();
}

class _SimuladoPageState extends State<SimuladoPage> {
  bool _loading = true;
  List<Map<String, dynamic>> _allSubjects = [];

  final _testService = TestService();

  final List<String> materiasDia1 = ['Português', 'Inglês', 'História', 'Geografia'];
  final List<String> materiasDia2 = ['Matemática', 'Física', 'Química', 'Biologia'];

  @override
  void initState() {
    super.initState();
    _loadSubjects();
  }

  Future<void> _loadSubjects() async {
    final user = FirebaseAuth.instance.currentUser;
    if (user == null) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Você precisa estar logado para acessar o simulado.')),
      );
      return;
    }

    try {
      final subjects = await _testService.fetchSubjects();
      setState(() {
        _allSubjects = subjects;
        _loading = false;
      });
    } catch (e) {
      setState(() => _loading = false);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao carregar questões: $e')),
      );
    }
  }

  void _startSimulado(String tipo) {
    final areas = tipo == 'dia1' ? materiasDia1 : materiasDia2;
    final filtered = _allSubjects.where((s) => areas.contains(s['name'])).toList();

    List<Map<String, dynamic>> allQuestions = [];

    for (var subject in filtered) {
      final topics = subject['topics'] as List<dynamic>;
      for (var topic in topics) {
        final questions = (topic['questions'] ?? []) as List<dynamic>;
        if (questions.isNotEmpty) {
          allQuestions.addAll(questions.map<Map<String, dynamic>>((q) => {
            ...Map<String, dynamic>.from(q),
            'topicTitle': topic['title'],
            'subjectName': subject['name'],
          }));
        }
      }
    }

    if (allQuestions.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Nenhuma questão encontrada.')),
      );
      return;
    }

    final selected = List<Map<String, dynamic>>.from(allQuestions)..shuffle();
    final sorteadas = selected.take(45).toList();

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => QuestionsPage(
          questions: sorteadas,
          topicTitle: tipo == 'dia1' ? 'Simulado ENEM - Dia 1' : 'Simulado ENEM - Dia 2',
          subjectName: 'Multi',
          isSimulado: true,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Simulado ENEM', style: TextStyle(color: Colors.white),),
        backgroundColor: Colors.deepPurple,
      ),
      body: _loading
          ? const Center(child: CircularProgressIndicator())
          : Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Text(
                    'Selecione o tipo de simulado que deseja iniciar:',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 32),

                  _buildSimuladoCard(
                    title: 'Simulado Dia 1',
                    subtitle: 'Linguagens e Códigos + Ciências Humanas',
                    icon: Icons.menu_book,
                    onTap: () => _startSimulado('dia1'),
                  ),
                  const SizedBox(height: 24),

                  _buildSimuladoCard(
                    title: 'Simulado Dia 2',
                    subtitle: 'Matemática + Ciências da Natureza',
                    icon: Icons.science,
                    onTap: () => _startSimulado('dia2'),
                  ),
                ],
              ),
            ),
    );
  }

  Widget _buildSimuladoCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.deepPurple.shade50,
          borderRadius: BorderRadius.circular(20),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 8,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Row(
          children: [
            Icon(icon, color: Colors.deepPurple, size: 36),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(title,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w600,
                        color: Colors.black87,
                      )),
                  const SizedBox(height: 4),
                  Text(
                    subtitle,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey.shade800,
                    ),
                  ),
                ],
              ),
            ),
            const Icon(Icons.arrow_forward_ios, size: 20, color: Colors.deepPurple),
          ],
        ),
      ),
    );
  }
}