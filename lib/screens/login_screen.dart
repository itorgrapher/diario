import 'package:flutter/material.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            children: [
              const SizedBox(height: 40),
              const Icon(Icons.menu_book, size: 40, color: Color(0xFF185FA5)),
              const SizedBox(height: 8),
              const Text('Tu diario', style: TextStyle(fontSize: 18, fontWeight: FontWeight.w600)),
              const SizedBox(height: 28),
              Container(
                decoration: BoxDecoration(color: const Color(0xFFF1EFE8), borderRadius: BorderRadius.circular(10)),
                padding: const EdgeInsets.all(3),
                child: Row(
                  children: [
                    Expanded(child: _tab('Iniciar sesión', isLogin, () => setState(() => isLogin = true))),
                    Expanded(child: _tab('Crear cuenta', !isLogin, () => setState(() => isLogin = false))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(decoration: const InputDecoration(hintText: 'tu@email.com')),
              const SizedBox(height: 10),
              TextField(obscureText: true, decoration: const InputDecoration(hintText: 'Contraseña')),
              if (!isLogin) ...[
                const SizedBox(height: 10),
                TextField(obscureText: true, decoration: const InputDecoration(hintText: 'Confirmar contraseña')),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: () => Navigator.of(context).pushReplacementNamed('/onboarding'),
                  child: Text(isLogin ? 'Entrar' : 'Crear cuenta'),
                ),
              ),
              if (isLogin)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                ),
              const SizedBox(height: 16),
              Row(children: const [
                Expanded(child: Divider()),
                Padding(padding: EdgeInsets.symmetric(horizontal: 8), child: Text('o continúa con', style: TextStyle(fontSize: 11, color: Colors.grey))),
                Expanded(child: Divider()),
              ]),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Google'))),
                  const SizedBox(width: 10),
                  Expanded(child: OutlinedButton(onPressed: () {}, child: const Text('Apple'))),
                ],
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }

  Widget _tab(String label, bool active, VoidCallback onTap) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 8),
        decoration: BoxDecoration(
          color: active ? const Color(0xFF2C2C2A) : Colors.transparent,
          borderRadius: BorderRadius.circular(8),
        ),
        child: Text(
          label,
          textAlign: TextAlign.center,
          style: TextStyle(fontSize: 13, color: active ? Colors.white : Colors.black87),
        ),
      ),
    );
  }
}
