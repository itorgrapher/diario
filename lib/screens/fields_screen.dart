import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class _Toggle {
  final IconData icon;
  final String label;
  bool on;
  _Toggle(this.icon, this.label, this.on);
}

class FieldsScreen extends StatefulWidget {
  const FieldsScreen({super.key});

  @override
  State<FieldsScreen> createState() => _FieldsScreenState();
}

class _FieldsScreenState extends State<FieldsScreen> {
  final List<_Toggle> dailyFields = [
    _Toggle(Icons.mood, 'Estado de ánimo', true),
    _Toggle(Icons.bolt, 'Nivel de energía', true),
    _Toggle(Icons.bedtime, 'Horas de sueño', true),
    _Toggle(Icons.psychology, 'Nivel de estrés', true),
    _Toggle(Icons.local_fire_department, 'Líbido', true),
    _Toggle(Icons.favorite, 'Gratitud', true),
  ];
  final List<_Toggle> calendarCards = [
    _Toggle(Icons.checklist, 'Lista de tareas', true),
    _Toggle(Icons.water_drop, 'Hidratación', true),
    _Toggle(Icons.directions_run, 'Ejercicio', true),
  ];

  Widget _section(String title, List<_Toggle> items) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(padding: const EdgeInsets.fromLTRB(4, 12, 4, 4), child: Text(title, style: const TextStyle(fontSize: 11, color: Colors.grey))),
        ...items.map((t) => SwitchListTile(
              secondary: Icon(t.icon, size: 20),
              title: Text(t.label, style: const TextStyle(fontSize: 13)),
              value: t.on,
              onChanged: (v) => setState(() => t.on = v),
              dense: true,
              contentPadding: EdgeInsets.zero,
            )),
      ],
    );
  }

  void _addHabit(AppState app) {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Qué quieres convertir en racha?'),
        content: TextField(controller: controller, autofocus: true, decoration: const InputDecoration(hintText: 'Ej. No fumar')),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              app.addHabit(controller.text);
              Navigator.pop(ctx);
            },
            child: const Text('Añadir'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    return Scaffold(
      appBar: AppBar(title: const Text('Configurar campos')),
      body: ListView(
        padding: const EdgeInsets.symmetric(horizontal: 16),
        children: [
          _section('Campos de la entrada diaria', dailyFields),
          _section('Tarjetas del calendario', calendarCards),
          const Padding(padding: EdgeInsets.fromLTRB(4, 12, 4, 4), child: Text('Secciones del menú', style: TextStyle(fontSize: 11, color: Colors.grey))),
          SwitchListTile(
            secondary: const Icon(Icons.auto_awesome, size: 20),
            title: const Text('Diario de sueños', style: TextStyle(fontSize: 13)),
            value: app.dreamsEnabled,
            onChanged: (v) => app.setSectionEnabled('dreams', v),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.menu_book, size: 20),
            title: const Text('Mis lecturas', style: TextStyle(fontSize: 13)),
            value: app.booksEnabled,
            onChanged: (v) => app.setSectionEnabled('books', v),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          SwitchListTile(
            secondary: const Icon(Icons.water_drop, size: 20),
            title: const Text('Ciclo', style: TextStyle(fontSize: 13)),
            value: app.cycleEnabled,
            onChanged: (v) => app.setSectionEnabled('cycle', v),
            dense: true,
            contentPadding: EdgeInsets.zero,
          ),
          const Padding(padding: EdgeInsets.fromLTRB(4, 12, 4, 4), child: Text('Tus rachas personalizadas', style: TextStyle(fontSize: 11, color: Colors.grey))),
          ...List.generate(app.habits.length, (i) {
            return Card(
              child: ListTile(
                leading: const Icon(Icons.local_fire_department, size: 18),
                title: Text(app.habits[i]['name'] as String, style: const TextStyle(fontSize: 13)),
                trailing: IconButton(icon: const Icon(Icons.delete_outline, size: 18), onPressed: () => app.removeHabit(i)),
              ),
            );
          }),
          OutlinedButton.icon(onPressed: () => _addHabit(app), icon: const Icon(Icons.add, size: 16), label: const Text('Añadir racha')),
          const SizedBox(height: 24),
        ],
      ),
    );
  }
}
