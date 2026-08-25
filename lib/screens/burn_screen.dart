import 'package:flutter/material.dart';
import '../theme.dart';

class BurnScreen extends StatefulWidget {
  const BurnScreen({super.key});

  @override
  State<BurnScreen> createState() => _BurnScreenState();
}

class _BurnScreenState extends State<BurnScreen> {
  final TextEditingController _controller = TextEditingController();
  bool _armed = false;
  bool _done = false;

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _burn() {
    if (_controller.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('Escribe algo antes de quemarlo')));
      return;
    }
    if (!_armed) {
      setState(() => _armed = true);
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('No podrás recuperarlo. Pulsa Quemar de nuevo para confirmar.')));
      return;
    }
    setState(() {
      _armed = false;
      _done = true;
      _controller.clear();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_done) {
      return Scaffold(
        appBar: AppBar(title: const Text('Desahogo')),
        body: Center(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Icon(Icons.local_fire_department, size: 30, color: Colors.grey.shade500),
                const SizedBox(height: 12),
                const Text('Se ha quemado', style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600)),
                const SizedBox(height: 6),
                const Text('Que empiece de nuevo.', style: TextStyle(fontSize: 12, color: Colors.grey)),
                const SizedBox(height: 16),
                OutlinedButton(onPressed: () => setState(() => _done = false), child: const Text('Escribir otra vez')),
              ],
            ),
          ),
        ),
      );
    }
    return Scaffold(
      appBar: AppBar(title: const Text('Desahogo')),
      body: Column(
        children: [
          const Padding(
            padding: EdgeInsets.fromLTRB(16, 8, 16, 8),
            child: Text('Esto no se guarda en ningún sitio. Escribe lo que necesites soltar y luego quémalo.', style: TextStyle(fontSize: 11, color: Colors.grey, height: 1.4)),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: TextField(
                controller: _controller,
                maxLines: null,
                expands: true,
                textAlignVertical: TextAlignVertical.top,
                decoration: const InputDecoration(hintText: 'Escribe aquí, sin filtro...', border: InputBorder.none),
                onChanged: (_) {
                  if (_armed) setState(() => _armed = false);
                },
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(16),
            child: SizedBox(
              width: double.infinity,
              child: FilledButton.icon(
                style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
                onPressed: _burn,
                icon: const Icon(Icons.local_fire_department),
                label: const Text('Quemar'),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
