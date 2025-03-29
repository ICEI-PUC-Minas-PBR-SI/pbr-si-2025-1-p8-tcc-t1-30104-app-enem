import 'package:app/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/home/home_page.dart';
import 'register_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final TextEditingController _emailCtrl = TextEditingController();
  final TextEditingController _senhaCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  void _loginEmail() async {
  try {
    await _authService.loginWithEmail(_emailCtrl.text, _senhaCtrl.text);

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro: ${e.toString()}')),
    );
  }
}


  void _loginGoogle() async {
  try {
    await _authService.loginWithGoogle();

    if (!mounted) return;

    Navigator.pushReplacement(
      context,
      MaterialPageRoute(builder: (_) => const HomePage()),
    );
  } catch (e) {
    if (!mounted) return;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Erro com Google: ${e.toString()}')),
    );
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: ListView(
          children: [
            const SizedBox(height: 80),
            const Text("Login", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 32),
            TextField(controller: _emailCtrl, decoration: const InputDecoration(labelText: 'Email')),
            const SizedBox(height: 12),
            TextField(controller: _senhaCtrl, decoration: const InputDecoration(labelText: 'Senha'), obscureText: true),
            const SizedBox(height: 24),
            ElevatedButton(
              onPressed: _loginEmail,
              style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
              child: const Text("Entrar", style: TextStyle(color: Colors.white)),
            ),
            const SizedBox(height: 16),
            OutlinedButton.icon(
              icon: const Icon(Icons.login),
              label: const Text("Entrar com Google"),
              onPressed: _loginGoogle,
            ),
            TextButton(
              onPressed: () => Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const RegisterPage()),
              ),
              child: const Text("Criar conta", style: TextStyle(color: Colors.deepPurple)),
            ),
          ],
        ),
      ),
    );
  }
}
