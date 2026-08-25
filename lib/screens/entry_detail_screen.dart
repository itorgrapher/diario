import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../services/firestore_service.dart';
import '../theme.dart';

class EntryDetailScreen extends StatefulWidget {
  final DateTime date;
  const EntryDetailScreen({super.key, required this.date});

  @override
  State<EntryDetailScreen> createState() => _EntryDetailScreenState();
}

class _EntryDetailScreenState extends State<EntryDetailScreen> {
  final _service = FirestoreService();
  bool loading = true;
  Map<String, dynamic>? entry;
  Map<String, dynamic>? daily;
  bool editing = false;
  final TextEditingController _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _load();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  Future<void> _load() async {
    final uid = context.read<AppState>().uid;
    if (uid == null) return;
    final e = await _service.getEntry(uid, widget.date);
    final d = await _service.watchDaily(uid, widget.date).first;
    if (!mounted) return;
    setState(() {
      entry = e;
      daily = d;
      _controller.text = (e?['text'] as String?) ?? '';
      loading = false;
    });
  }

  Future<void> _saveEdit() async {
    final uid = context.read<AppState>().uid;
    if (uid == null) return;
    await _service.saveEntry(uid, widget.date, {'text': _controller.text});
    setState(() {
      entry = {...?entry, 'text': _controller.text};
      editing = false;
    });
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
            onPressed: () async {
              final uid = context.read<AppState>().uid;
              if (uid != null) {
                await _service.saveEntry(uid, widget.date, {'text': '', 'gratitude': '', 'photoUrls': []});
              }
              if (mounted) Navigator.pop(ctx);
              if (mounted) Navigator.pop(context);
            },
            child: const Text('Eliminar'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final dateLabel = DateFormat("d 'de' MMMM", 'es').format(widget.date);

    if (loading) {
      return Scaffold(appBar: AppBar(title: Text(dateLabel)), body: const Center(child: CircularProgressIndicator()));
    }

    final hasEntry = entry != null && ((entry!['text'] as String?)?.isNotEmpty ?? false);
    final animo = entry?['animo'] as String?;
    final tasksRaw = (daily?['tasks'] as List<dynamic>?) ?? [];
    final waterCount = daily?['water'] as int?;
    final exercise = daily?['exercise'] as String?;
    final tagsRaw = (entry?['tags'] as List<dynamic>?) ?? [];

    return Scaffold(
      appBar: AppBar(
        title: Text(dateLabel, style: const TextStyle(fontSize: 15)),
        actions: hasEntry
            ? [
                IconButton(icon: const Icon(Icons.edit_outlined), onPressed: () => setState(() => editing = !editing)),
                IconButton(icon: const Icon(Icons.delete_outline, color: AppColors.danger), onPressed: _confirmDelete),
              ]
            : null,
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          if (!hasEntry && tasksRaw.isEmpty && waterCount == null && exercise == null)
            const Padding(
              padding: EdgeInsets.only(bottom: 12),
              child: Text('No hay ningún registro guardado para este día.', style: TextStyle(fontSize: 13, color: Colors.grey)),
            ),
          if (hasEntry) ...[
            Row(
              children: [
                if (animo != null) CircleAvatar(backgroundColor: valueColorBg('animo', animo), child: Icon(Icons.mood, color: valueColorFg('animo', animo), size: 18)),
                const SizedBox(width: 10),
                Text(dateLabel, style: const TextStyle(fontWeight: FontWeight.w600)),
              ],
            ),
            const SizedBox(height: 14),
          ],
          if (tasksRaw.isNotEmpty) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(children: const [Icon(Icons.checklist, size: 15), SizedBox(width: 6), Text('Tareas de ese día', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13))]),
                    const SizedBox(height: 6),
                    ...tasksRaw.map((t) {
                      final m = t as Map<String, dynamic>;
                      final done = m['done'] as bool? ?? false;
                      return Row(
                        children: [
                          Icon(done ? Icons.check_box : Icons.check_box_outline_blank, size: 18, color: done ? AppColors.accent : Colors.grey),
                          const SizedBox(width: 8),
                          Expanded(child: Text(m['text'] as String? ?? '', style: TextStyle(fontSize: 13, decoration: done ? TextDecoration.lineThrough : null, color: done ? Colors.grey : Colors.black87))),
                        ],
                      );
                    }),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (waterCount != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    Icon(Icons.water_drop, size: 15, color: AppColors.accent),
                    const SizedBox(width: 6),
                    const Text('Hidratación de ese día', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    Text('$waterCount/8', style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 10),
          ],
          if (exercise != null) ...[
            Card(
              child: Padding(
                padding: const EdgeInsets.all(12),
                child: Row(
                  children: [
                    const Icon(Icons.directions_run, size: 15),
                    const SizedBox(width: 6),
                    const Text('Ejercicio ese día', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    const Spacer(),
                    CircleAvatar(
                      radius: 13,
                      backgroundColor: exercise == 'si' ? AppColors.greenBg : AppColors.redBg,
                      child: Icon(exercise == 'si' ? Icons.check : Icons.close, size: 13, color: exercise == 'si' ? AppColors.greenFg : AppColors.redFg),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 14),
          ],
          if (hasEntry)
            editing
                ? Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      TextField(controller: _controller, maxLines: 6, decoration: const InputDecoration(border: InputBorder.none)),
                      const SizedBox(height: 8),
                      FilledButton(onPressed: _saveEdit, child: const Text('Guardar cambios')),
                    ],
                  )
                : Text(entry!['text'] as String, style: const TextStyle(fontSize: 14, height: 1.6)),
          if (hasEntry && tagsRaw.isNotEmpty) ...[
            const SizedBox(height: 14),
            Wrap(spacing: 6, children: tagsRaw.map((t) => Chip(label: Text('#$t', style: const TextStyle(fontSize: 11)), backgroundColor: AppColors.bgAccent)).toList()),
          ],
          if (!hasEntry)
            Padding(
              padding: const EdgeInsets.only(top: 8),
              child: OutlinedButton.icon(
                onPressed: () => Navigator.of(context).pushNamed('/new-entry'),
                icon: const Icon(Icons.edit_outlined, size: 16),
                label: const Text('Escribir una entrada para este día'),
              ),
            ),
        ],
      ),
    );
  }
}
