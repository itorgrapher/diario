import 'package:flutter/material.dart';
import '../theme.dart';

class EntryDetailScreen extends StatefulWidget {
  const EntryDetailScreen({super.key});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  bool editing = false;
  final TextEditingController _controller = TextEditingController(
    text: 'Hoy hice la primera sesión de fotos del proyecto nuevo. Salió mejor de lo esperado, la luz de la tarde ayudó mucho.',
  );

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _confirmDelete() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('¿Eliminar esta entrada?'),
        content: const Text('No se puede deshacer.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: AppColors.danger),
            onPressed: () {
              Navigator.pop(ctx);
              Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  void _shareAsImage() {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        content: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(color: AppColors.amberBg, borderRadius: BorderRadius.circular(12)),
          child: const Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.sentiment_very_satisfied, color: AppColors.amberFg),
              SizedBox(height: 8),
              Text('"Primera sesión del proyecto nuevo, salió mejor de lo esperado."', style: TextStyle(fontStyle: FontStyle.italic)),
              SizedBox(height: 8),
              Text('22 de agosto · Granada', style: TextStyle(fontSize: 11)),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(onPressed: () => Navigator.pop(ctx), child: const Text('Descargar')),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(''),
        actions: [
          IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => setState(() => editing = !editing)),
          IconButton(icon: const Icon(Icons.share_outlined), onPressed: _shareAsImage),
          IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: _confirmDelete),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          Row(
            children: [
              const CircleAvatar(backgroundColor: AppColors.amberBg, child: Icon(Icons.sentiment_very_satisfied, color: AppColors.amberFg, size: 18)),
              const SizedBox(width: 10),
              const Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text('22 de agosto', style: TextStyle(fontWeight: FontWeight.w600)),
                  Row(children: [Icon(Icons.location_on_outlined, size: 12, color: Colors.grey), SizedBox(width: 3), Text('Granada', style: TextStyle(fontSize: 11, color: Colors.grey))]),
                ],
              ),
              const Spacer(),
              const Icon(Icons.lock_outline, size: 16, color: AppColors.accent),
            ],
          ),
          const SizedBox(height: 14),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: const [Icon(Icons.checklist, size: 15), SizedBox(width: 6), Text('Tareas de ese día', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)), Spacer(), Text('3 de 4 completadas', style: TextStyle(fontSize: 11, color: Colors.grey))]),
                  const SizedBox(height: 6),
                  _readonlyTask('Entregar fotos al cliente', true),
                  _readonlyTask('Revisar horarios del restaurante', true),
                  _readonlyTask('Actualizar la web', false),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(children: [
                    Icon(Icons.water_drop, size: 15, color: AppColors.accent),
                    const SizedBox(width: 6),
                    const Text('Hidratación de ese día', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    const Text('6/8 · medio', style: TextStyle(fontSize: 11, color: Colors.grey)),
                  ]),
                  const SizedBox(height: 8),
                  Row(
                    children: List.generate(8, (i) {
                      final filled = i < 6;
                      return Expanded(
                        child: Container(
                          margin: const EdgeInsets.symmetric(horizontal: 2),
                          height: 24,
                          decoration: BoxDecoration(color: filled ? AppColors.bgAccent : const Color(0xFFF1EFE8), borderRadius: BorderRadius.circular(6)),
                          child: Icon(filled ? Icons.local_drink : Icons.local_drink_outlined, size: 13, color: filled ? AppColors.accent : Colors.grey),
                        ),
                      );
                    }),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 10),
          Card(
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                children: const [
                  Icon(Icons.directions_run, size: 15),
                  SizedBox(width: 6),
                  Text('Ejercicio ese día', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                  Spacer(),
                  CircleAvatar(radius: 13, backgroundColor: AppColors.greenBg, child: Icon(Icons.check, size: 13, color: AppColors.greenFg)),
                ],
              ),
            ),
          ),
          const SizedBox(height: 14),
          editing
              ? TextField(controller: _controller, maxLines: 6, decoration: const InputDecoration(border: InputBorder.none))
              : Text(_controller.text, style: const TextStyle(fontSize: 14, height: 1.6)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 6,
            children: const [
              Chip(label: Text('#fotografía', style: TextStyle(fontSize: 11)), backgroundColor: AppColors.bgAccent),
              Chip(label: Text('#proyecto', style: TextStyle(fontSize: 11)), backgroundColor: AppColors.bgAccent),
            ],
          ),
        ],
      ),
    );
  }

  Widget _readonlyTask(String text, bool done) {
    return Row(
      children: [
        Icon(done ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: done ? AppColors.accent : Colors.grey),
        const SizedBox(width: 8),
        Expanded(child: Text(text, style: TextStyle(fontSize: 13, decoration: done ? TextDecoration.lineThrough : null, color: done ? Colors.grey : Colors.black87))),
      ],
    );
  }
}
