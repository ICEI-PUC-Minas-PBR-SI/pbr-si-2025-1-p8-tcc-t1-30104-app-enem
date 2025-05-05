import 'package:flutter/material.dart';
import 'questions_page.dart';

class TopicsPage extends StatefulWidget {
  final List<dynamic> topics;
  final String subjectName;

  const TopicsPage({
    super.key,
    required this.topics,
    required this.subjectName,
  });

  @override
  State<TopicsPage> createState() => _TopicsPageState();
}

class _TopicsPageState extends State<TopicsPage> {
  String selectedDifficulty = 'todas';

  Widget _buildDifficultySelector() {
    final options = ['todas', 'fácil', 'médio', 'difícil'];
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 12),
      child: Wrap(
        spacing: 8,
        children: options.map((option) {
          final isSelected = selectedDifficulty == option;
          return ChoiceChip(
            label: Text(
              option[0].toUpperCase() + option.substring(1),
              style: TextStyle(
                color: isSelected ? Colors.white : Colors.deepPurple,
                fontWeight: FontWeight.bold,
              ),
            ),
            selected: isSelected,
            selectedColor: Colors.deepPurple,
            backgroundColor: Colors.grey[200],
            onSelected: (_) {
              setState(() => selectedDifficulty = option);
            },
          );
        }).toList(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        title: Text(
          'Exercícios de ${widget.subjectName}',
          style: const TextStyle(
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        backgroundColor: Colors.deepPurple,
        centerTitle: true,
        elevation: 5,
      ),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _buildDifficultySelector(),
            const Padding(
              padding: EdgeInsets.only(bottom: 16),
              child: Text(
                'Escolha o tópico abaixo:',
                style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: widget.topics.length,
                itemBuilder: (context, index) {
                  final topic = widget.topics[index];
                  return GestureDetector(
                    onTap: () {
                      final filteredQuestions = selectedDifficulty == 'todas'
                          ? topic['questions']
                          : topic['questions'].where((q) => q['difficulty'] == selectedDifficulty).toList();
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => QuestionsPage(
                            questions: filteredQuestions,
                            topicTitle: topic['title'],
                            subjectName: widget.subjectName,
                          ),
                        ),
                      );
                    },
                    child: Container(
                      margin: const EdgeInsets.symmetric(vertical: 8),
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(16),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.grey.withOpacity(0.3),
                            blurRadius: 8,
                            offset: const Offset(3, 3),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.topic, size: 40, color: Colors.deepPurple),
                          const SizedBox(width: 16),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  topic['title'],
                                  style: const TextStyle(
                                    fontSize: 18,
                                    fontWeight: FontWeight.bold,
                                    color: Colors.black87,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  topic['description'],
                                  style: TextStyle(
                                    fontSize: 14,
                                    color: Colors.grey[700],
                                  ),
                                ),
                              ],
                            ),
                          ),
                          const Icon(Icons.arrow_forward_ios, color: Colors.deepPurple),
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
    );
  }
}
