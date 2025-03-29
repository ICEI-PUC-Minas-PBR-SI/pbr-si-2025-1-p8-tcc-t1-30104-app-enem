import 'package:cloud_firestore/cloud_firestore.dart';

class TestService {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<List<Map<String, dynamic>>> fetchSubjects() async {
    final subjectsSnapshot = await _firestore.collection('subjects').get();

    final subjects = await Future.wait(subjectsSnapshot.docs.map((subjectDoc) async {
      final subjectName = subjectDoc['name'] ?? 'Sem Nome';

      final topicsSnapshot = await subjectDoc.reference.collection('topics').get();

      final topics = await Future.wait(topicsSnapshot.docs.map((topicDoc) async {
        final topicData = topicDoc.data();
        final topicTitle = topicData['title'] ?? 'Tópico';
        final topicDescription = topicData['description'] ?? '';

        final questionsSnapshot = await topicDoc.reference.collection('questions').get();

        final questions = questionsSnapshot.docs.map((q) => q.data()).toList();

        return {
          'title': topicTitle,
          'description': topicDescription,
          'questions': questions,
        };
      }));

      return {
        'name': subjectName,
        'topics': topics,
      };
    }));

    return subjects;
  }
}
