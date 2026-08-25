import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  bool isLogin = true;
  bool loading = false;
  String? error;

  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _confirmController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    _confirmController.dispose();
    super.dispose();
  }

  String _friendlyError(FirebaseAuthException e) {
    switch (e.code) {
      case 'invalid-email':
        return 'Ese email no parece válido.';
      case 'user-not-found':
      case 'wrong-password':
      case 'invalid-credential':
        return 'Email o contraseña incorrectos.';
      case 'email-already-in-use':
        return 'Ya existe una cuenta con ese email.';
      case 'weak-password':
        return 'La contraseña debe tener al menos 6 caracteres.';
      case 'network-request-failed':
        return 'Sin conexión a internet. Comprueba tu red.';
      default:
        return 'Algo ha fallado (${e.code}). Inténtalo de nuevo.';
    }
  }

  Future<void> _submit() async {
    final email = _emailController.text.trim();
    final password = _passwordController.text;

    if (email.isEmpty || password.isEmpty) {
      setState(() => error = 'Rellena email y contraseña.');
      return;
    }
    if (!isLogin && password != _confirmController.text) {
      setState(() => error = 'Las contraseñas no coinciden.');
      return;
    }

    setState(() {
      loading = true;
      error = null;
    });

    try {
      if (isLogin) {
        await FirebaseAuth.instance.signInWithEmailAndPassword(email: email, password: password);
      } else {
        await FirebaseAuth.instance.createUserWithEmailAndPassword(email: email, password: password);
      }
      // No navegamos manualmente: AuthGate detecta el cambio de sesión y
      // cambia de pantalla solo (a onboarding si es cuenta nueva, o al
      // calendario si ya existía).
    } on FirebaseAuthException catch (e) {
      setState(() => error = _friendlyError(e));
    } catch (e) {
      setState(() => error = 'Algo ha fallado. Inténtalo de nuevo.');
    } finally {
      if (mounted) setState(() => loading = false);
    }
  }

  Future<void> _forgotPassword() async {
    final email = _emailController.text.trim();
    if (email.isEmpty) {
      setState(() => error = 'Escribe tu email arriba primero.');
      return;
    }
    try {
      await FirebaseAuth.instance.sendPasswordResetEmail(email: email);
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Te hemos enviado un enlace para restablecer la contraseña.')),
        );
      }
    } on FirebaseAuthException catch (e) {
      setState(() => error = _friendlyError(e));
    }
  }

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
                    Expanded(child: _tab('Iniciar sesión', isLogin, () => setState(() { isLogin = true; error = null; }))),
                    Expanded(child: _tab('Crear cuenta', !isLogin, () => setState(() { isLogin = false; error = null; }))),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              TextField(
                controller: _emailController,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(hintText: 'tu@email.com'),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: _passwordController,
                obscureText: true,
                decoration: const InputDecoration(hintText: 'Contraseña'),
              ),
              if (!isLogin) ...[
                const SizedBox(height: 10),
                TextField(
                  controller: _confirmController,
                  obscureText: true,
                  decoration: const InputDecoration(hintText: 'Confirmar contraseña'),
                ),
              ],
              if (error != null) ...[
                const SizedBox(height: 10),
                Text(error!, style: const TextStyle(color: Color(0xFFA32D2D), fontSize: 12)),
              ],
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  onPressed: loading ? null : _submit,
                  child: loading
                      ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(strokeWidth: 2))
                      : Text(isLogin ? 'Entrar' : 'Crear cuenta'),
                ),
              ),
              if (isLogin)
                Padding(
                  padding: const EdgeInsets.only(top: 8),
                  child: GestureDetector(
                    onTap: _forgotPassword,
                    child: Text('¿Olvidaste tu contraseña?', style: TextStyle(color: Colors.blue.shade700, fontSize: 12)),
                  ),
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
