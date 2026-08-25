import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class DreamsScreen extends StatelessWidget {
  const DreamsScreen({super.key});

  void _addDream(BuildContext context, AppState app) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Qué recuerdas de tu sueño?'),
        content: TextField(controller: controller, autofocus: true, maxLines: 4),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              app.addDream(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Guardar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Diario de sueños')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...app.dreams.map((d) => Card(
                child: Padding(
                  padding: const EdgeInsets.all(12),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(d['date'] ?? '', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                      const SizedBox(height: 4),
                      Text(d['text'] ?? '', style: const TextStyle(fontSize: 13, height: 1.5)),
                    ],
                  ),
                ),
              )),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () => _addDream(context, app), icon: const Icon(Icons.add, size: 16), label: const Text('Añadir sueño de hoy')),
        ],
      ),
    );
  }
}
