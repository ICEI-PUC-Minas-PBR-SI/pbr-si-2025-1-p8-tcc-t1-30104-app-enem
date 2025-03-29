import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'firebase_seed.dart';
import 'firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );

  await uploadQuestionsToFirestore(); // 👈 função que faz o seed

  print('✅ Seed finalizado com sucesso!');
}
