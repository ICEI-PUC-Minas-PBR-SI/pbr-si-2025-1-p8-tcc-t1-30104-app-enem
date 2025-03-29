import 'dart:convert';
import 'package:flutter/services.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

Future<void> uploadQuestionsToFirestore() async {
  final jsonString = await rootBundle.loadString('lib/assets/question.json');
  final jsonData = json.decode(jsonString);

  final firestore = FirebaseFirestore.instance;

  for (var subject in jsonData['subjects']) {
    final subjectRef = firestore.collection('subjects').doc(subject['name']);

    await subjectRef.set({'name': subject['name']});

    for (var topic in subject['topics']) {
      final topicRef = subjectRef.collection('topics').doc(topic['title']);

      await topicRef.set({
        'title': topic['title'],
        'description': topic['description'],
      });

      for (var question in topic['questions']) {
        await topicRef.collection('questions').add({
          'question': question['question'],
          'options': question['options'],
          'answer': question['answer'],
          'difficulty': question['difficulty'] ?? 'fácil',
        });
      }
    }
  }

  print('✅ Importação concluída!');
}
