import 'package:flutter/material.dart';
import '../theme.dart';

class ProfileScreen extends StatelessWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Perfil')),
      body: ListView(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Row(
              children: [
                CircleAvatar(radius: 24, backgroundColor: AppColors.bgAccent, child: Text('AG', style: TextStyle(color: AppColors.accent, fontWeight: FontWeight.w600))),
                SizedBox(width: 12),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text('Aitor García', style: TextStyle(fontWeight: FontWeight.w600)),
                    Text('aitor@email.com', style: TextStyle(fontSize: 12, color: Colors.grey)),
                  ],
                ),
              ],
            ),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('General', style: TextStyle(fontSize: 11, color: Colors.grey))),
          SwitchListTile(secondary: const Icon(Icons.fingerprint), title: const Text('Bloqueo con huella o Face ID'), value: true, onChanged: (_) {}),
          ListTile(
            leading: const Icon(Icons.text_fields),
            title: const Text('Tamaño de texto'),
            trailing: const Text('Mediano', style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriría el selector S/M/L'))),
          ),
          ListTile(
            leading: const Icon(Icons.notifications_none),
            title: const Text('Recordatorio diario'),
            trailing: const Text('21:30', style: TextStyle(color: Colors.grey, fontSize: 12)),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriría los ajustes del recordatorio'))),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('Tus datos', style: TextStyle(fontSize: 11, color: Colors.grey))),
          ListTile(leading: const Icon(Icons.tune), title: const Text('Configurar campos'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).pushNamed('/fields')),
          ListTile(
            leading: const Icon(Icons.download_outlined),
            title: const Text('Exportar mis datos'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () => ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Abriría exportar datos'))),
          ),
          const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('Cuenta', style: TextStyle(fontSize: 11, color: Colors.grey))),
          ListTile(leading: const Icon(Icons.mail_outline), title: const Text('Cambiar email'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const ChangeEmailScreen()))),
          const ListTile(leading: Icon(Icons.key_outlined), title: Text('Cambiar contraseña')),
          ListTile(leading: const Icon(Icons.devices_outlined), title: const Text('Dispositivos con sesión iniciada'), trailing: const Icon(Icons.chevron_right), onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DevicesScreen()))),
          ListTile(leading: const Icon(Icons.logout), title: const Text('Cerrar sesión'), onTap: () => Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false)),
          ListTile(
            leading: const Icon(Icons.delete_outline, color: AppColors.danger),
            title: const Text('Eliminar cuenta', style: TextStyle(color: AppColors.danger)),
            onTap: () => Navigator.of(context).push(MaterialPageRoute(builder: (_) => const DeleteAccountScreen())),
          ),
          const Padding(padding: EdgeInsets.symmetric(vertical: 16), child: Center(child: Text('Tu diario · versión 1.0', style: TextStyle(fontSize: 10, color: Colors.grey)))),
        ],
      ),
    );
  }
}

class ChangeEmailScreen extends StatefulWidget {
  const ChangeEmailScreen({super.key});

  @override
  State<ChangeEmailScreen> createState() => _ChangeEmailScreenState();
}

class _ChangeEmailScreenState extends State<ChangeEmailScreen> {
  final _newEmailController = TextEditingController();
  final _passwordController = TextEditingController();

  @override
  void dispose() {
    _newEmailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Cambiar email')),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Email actual', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(enabled: false, controller: TextEditingController(text: 'aitor@email.com')),
            const SizedBox(height: 14),
            const Text('Nuevo email', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(controller: _newEmailController, decoration: const InputDecoration(hintText: 'nuevo@email.com')),
            const SizedBox(height: 14),
            const Text('Confirma tu contraseña', style: TextStyle(fontSize: 12, color: Colors.grey)),
            const SizedBox(height: 4),
            TextField(controller: _passwordController, obscureText: true, decoration: const InputDecoration(hintText: 'Contraseña')),
            const SizedBox(height: 12),
            const Text('Te enviaremos un enlace de confirmación al nuevo email antes de aplicar el cambio.', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
            const SizedBox(height: 16),
            SizedBox(width: double.infinity, child: FilledButton(onPressed: () => Navigator.pop(context), child: const Text('Enviar confirmación'))),
          ],
        ),
      ),
    );
  }
}

class DevicesScreen extends StatelessWidget {
  const DevicesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Dispositivos')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Card(child: ListTile(leading: const Icon(Icons.smartphone), title: const Text('Este dispositivo'), subtitle: const Text('Activo ahora'))),
          Card(child: ListTile(leading: const Icon(Icons.laptop_mac), title: const Text('Chrome en Windows'), subtitle: const Text('Hace 3 días'), trailing: IconButton(icon: const Icon(Icons.close), onPressed: () {}))),
        ],
      ),
    );
  }
}

class DeleteAccountScreen extends StatefulWidget {
  const DeleteAccountScreen({super.key});

  @override
  State<DeleteAccountScreen> createState() => _DeleteAccountScreenState();
}

class _DeleteAccountScreenState extends State<DeleteAccountScreen> {
  final _controller = TextEditingController();
  String? _error;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirm() {
    if (_controller.text.trim() != 'ELIMINAR') {
      setState(() => _error = 'Escribe ELIMINAR exactamente para confirmar');
      return;
    }
    Navigator.of(context).pushNamedAndRemoveUntil('/login', (r) => false);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Eliminar cuenta')),
      body: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.warning_amber_outlined, size: 30, color: AppColors.danger),
            const SizedBox(height: 12),
            const Text('Eliminar tu cuenta', style: TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            const Text('Se borrarán todas tus entradas, fotos, rachas y ajustes de forma permanente. Esta acción no se puede deshacer.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey, height: 1.5)),
            const SizedBox(height: 16),
            Align(alignment: Alignment.centerLeft, child: const Text('Escribe ELIMINAR para confirmar', style: TextStyle(fontSize: 12, color: Colors.grey))),
            const SizedBox(height: 4),
            TextField(controller: _controller, decoration: InputDecoration(hintText: 'ELIMINAR', errorText: _error)),
            const SizedBox(height: 16),
            Row(
              children: [
                Expanded(child: OutlinedButton(onPressed: () => Navigator.pop(context), child: const Text('Cancelar'))),
                const SizedBox(width: 10),
                Expanded(child: FilledButton(style: FilledButton.styleFrom(backgroundColor: AppColors.danger), onPressed: _confirm, child: const Text('Eliminar cuenta'))),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
