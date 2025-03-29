import 'package:app/service/auth.service.dart';
import 'package:flutter/material.dart';
import 'package:app/screens/home/home_page.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final _nomeCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _senhaCtrl = TextEditingController();
  final _idadeCtrl = TextEditingController();
  final AuthService _authService = AuthService();

  void _register() async {
    if (!_formKey.currentState!.validate()) return;

    try {
      await _authService.registerWithEmail(
        nome: _nomeCtrl.text,
        idade: int.parse(_idadeCtrl.text),
        email: _emailCtrl.text,
        senha: _senhaCtrl.text,
      );

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text("Cadastro realizado com sucesso! Faça login.")),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Erro ao cadastrar: ${e.toString()}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Cadastro"), backgroundColor: Colors.deepPurple),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              const Text("Crie sua conta", style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold)),
              const SizedBox(height: 20),
              TextFormField(
                controller: _nomeCtrl,
                decoration: const InputDecoration(labelText: 'Nome'),
                validator: (value) => value!.isEmpty ? 'Digite seu nome' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _idadeCtrl,
                decoration: const InputDecoration(labelText: 'Idade'),
                keyboardType: TextInputType.number,
                validator: (value) {
                  if (value!.isEmpty) return 'Informe sua idade';
                  final idade = int.tryParse(value);
                  if (idade == null || idade < 5) return 'Idade inválida';
                  return null;
                },
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _emailCtrl,
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                validator: (value) => value!.isEmpty ? 'Digite seu email' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _senhaCtrl,
                decoration: const InputDecoration(labelText: 'Senha'),
                obscureText: true,
                validator: (value) => value!.length < 6 ? 'Mínimo 6 caracteres' : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _register,
                style: ElevatedButton.styleFrom(backgroundColor: Colors.deepPurple),
                child: const Text("Cadastrar", style: TextStyle(color: Colors.white)),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
