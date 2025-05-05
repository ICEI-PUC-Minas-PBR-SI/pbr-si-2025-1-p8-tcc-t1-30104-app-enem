import 'dart:async';
import 'dart:math';
import 'package:app/bd/banco_dados.dart';
import 'package:flutter/material.dart';

class QuestionsPage extends StatefulWidget {
  final List<dynamic> questions;
  final String topicTitle;
  final String subjectName;
  final bool isSimulado;

  const QuestionsPage({
    super.key,
    required this.questions,
    required this.topicTitle,
    required this.subjectName,
    this.isSimulado = false,
  });

  @override
  State<QuestionsPage> createState() => _QuestionsPageState();
}

class _QuestionsPageState extends State<QuestionsPage> {
  late List<dynamic> _selectedQuestions;
  int _currentQuestionIndex = 0;
  String? _selectedOption;
  int _score = 0;

  List<String?> _selectedOptions = [];
  List<int> _wrongAnswers = [];
  bool _isTestFinished = false;

  Timer? _timer;
  int _remainingTime = 120;

  @override
  void initState() {
    super.initState();
    _selectedQuestions = widget.questions.length > 5
        ? widget.questions
        : _getRandomQuestions(widget.questions, 5);
    _selectedOptions = List<String?>.filled(_selectedQuestions.length, null);

    if (widget.isSimulado) {
      _startTimer();
    }
  }

  void _startTimer() {
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_remainingTime > 0) {
        setState(() => _remainingTime--);
      } else {
        timer.cancel();
        _finishTest();
      }
    });
  }

  String _formatTime(int seconds) {
    final min = seconds ~/ 60;
    final sec = seconds % 60;
    return '${min.toString().padLeft(2, '0')}:${sec.toString().padLeft(2, '0')}';
  }

  Future<bool?> _showExitConfirmationDialog() {
    return showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Sair do Teste?"),
        content: const Text("Você ainda não terminou o teste. Tem certeza de que deseja sair?"),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text("Sair", style: TextStyle(color: Colors.red)),
          ),
        ],
      ),
    );
  }

  Future<void> _showSelectOptionDialog() async {
    return showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text("Atenção"),
        content: const Text("Por favor, selecione uma resposta antes de continuar."),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("OK"),
          ),
        ],
      ),
    );
  }

  void _finishTest() async {
    _timer?.cancel();
    final dbHelper = DatabaseHelper();
    await dbHelper.insertResult(
      widget.subjectName,
      widget.topicTitle,
      _score,
      _selectedQuestions.length,
    );

    setState(() => _isTestFinished = true);
  }

  @override
  Widget build(BuildContext context) {
    if (_selectedQuestions.isEmpty) {
      return const Scaffold(
        body: Center(child: Text('Nenhuma questão disponível.')),
      );
    }

    final currentQuestion = _selectedQuestions[_currentQuestionIndex];

    return WillPopScope(
      onWillPop: _onWillPop,
      child: Scaffold(
        backgroundColor: Colors.white,
        appBar: AppBar(
          title: Text(
            _isTestFinished ? 'Revisão do Teste' : 'Questões',
            style: const TextStyle(color: Colors.white),
          ),
          backgroundColor: Colors.deepPurple,
          actions: widget.isSimulado && !_isTestFinished
              ? [
                  Padding(
                    padding: const EdgeInsets.only(right: 16),
                    child: Center(
                      child: Text(
                        _formatTime(_remainingTime),
                        style: const TextStyle(color: Colors.white),
                      ),
                    ),
                  )
                ]
              : null,
        ),
        body: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Pergunta ${_currentQuestionIndex + 1}/${_selectedQuestions.length}',
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 16),
              Text(
                currentQuestion['question'],
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(height: 16),
              ...currentQuestion['options'].map<Widget>((option) {
                final isCorrect = option == currentQuestion['answer'];
                final isWrong =
                    _isTestFinished && _wrongAnswers.contains(_currentQuestionIndex);
                final isSelectedWrong =
                    isWrong && option == _selectedOptions[_currentQuestionIndex];

                final textColor = isSelectedWrong
                    ? Colors.red
                    : isCorrect && _isTestFinished
                        ? Colors.green
                        : Colors.black;
                final bgColor = isSelectedWrong
                    ? Colors.red.withOpacity(0.1)
                    : isCorrect && _isTestFinished
                        ? Colors.green.withOpacity(0.1)
                        : Colors.transparent;

                return Container(
                  decoration: BoxDecoration(
                    color: bgColor,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(
                      color: isSelectedWrong
                          ? Colors.red
                          : isCorrect && _isTestFinished
                              ? Colors.green
                              : Colors.deepPurple,
                    ),
                  ),
                  margin: const EdgeInsets.symmetric(vertical: 6),
                  child: RadioListTile<String>(
                    title: Text(option, style: TextStyle(color: textColor)),
                    value: option,
                    groupValue: _selectedOption,
                    onChanged: !_isTestFinished && _remainingTime > 0
                        ? (value) {
                            setState(() {
                              _selectedOption = value;
                              _selectedOptions[_currentQuestionIndex] = value;
                            });
                          }
                        : null,
                  ),
                );
              }).toList(),
              const Spacer(),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  ElevatedButton(
                    onPressed: _currentQuestionIndex > 0
                        ? () {
                            setState(() {
                              _currentQuestionIndex--;
                              _selectedOption =
                                  _selectedOptions[_currentQuestionIndex];
                            });
                          }
                        : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: const Text('Voltar', style: TextStyle(color: Colors.white)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      if (_isTestFinished) {
                        Navigator.pop(context);
                      } else if (_selectedOption == null) {
                        _showSelectOptionDialog();
                      } else {
                        if (_selectedOption == currentQuestion['answer']) {
                          _score++;
                        } else {
                          _wrongAnswers.add(_currentQuestionIndex);
                        }

                        if (_currentQuestionIndex < _selectedQuestions.length - 1) {
                          setState(() {
                            _currentQuestionIndex++;
                            _selectedOption =
                                _selectedOptions[_currentQuestionIndex];
                          });
                        } else {
                          _finishTest();
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.deepPurple,
                      padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 12),
                    ),
                    child: Text(
                      _isTestFinished ? 'Finalizar' : 'Próxima',
                      style: const TextStyle(color: Colors.white),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<bool> _onWillPop() async {
    return _isTestFinished ? true : (await _showExitConfirmationDialog() ?? false);
  }

  List<dynamic> _getRandomQuestions(List<dynamic> questions, int count) {
    final random = Random();
    final shuffled = List<dynamic>.from(questions)..shuffle(random);
    return shuffled.take(count).toList();
  }

  @override
  void dispose() {
    _timer?.cancel();
    super.dispose();
  }
}
