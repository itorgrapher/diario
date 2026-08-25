import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';

const Map<String, List<dynamic>> _statusMeta = {
  'leyendo': ['Leyendo', AppColors.tealBg, AppColors.tealFg],
  'terminado': ['Terminado', AppColors.grayBg, AppColors.grayFg],
  'pendiente': ['Pendiente', AppColors.amberBg, AppColors.amberFg],
};

class BooksScreen extends StatelessWidget {
  const BooksScreen({super.key});

  void _addBook(BuildContext context, AppState app) {
    final titleController = TextEditingController();
    final authorController = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Añadir libro'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(controller: titleController, autofocus: true, decoration: const InputDecoration(hintText: 'Título')),
            const SizedBox(height: 8),
            TextField(controller: authorController, decoration: const InputDecoration(hintText: 'Autor')),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancelar')),
          FilledButton(
            onPressed: () {
              app.addBook(titleController.text, authorController.text);
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
      appBar: AppBar(title: const Text('Mis lecturas')),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          ...app.books.map((b) {
            final status = b['status'] as String;
            final meta = _statusMeta[status]!;
            return Card(
              child: ListTile(
                leading: Container(width: 34, height: 46, decoration: BoxDecoration(color: const Color(0xFFF1EFE8), borderRadius: BorderRadius.circular(4)), child: const Icon(Icons.menu_book, size: 18, color: Colors.grey)),
                title: Text(b['title'] as String, style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                subtitle: Row(
                  children: [
                    Text(b['author'] as String, style: const TextStyle(fontSize: 11, color: Colors.grey)),
                  ],
                ),
                trailing: Container(
                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                  decoration: BoxDecoration(color: meta[1] as Color, borderRadius: BorderRadius.circular(10)),
                  child: Text(meta[0] as String, style: TextStyle(fontSize: 10, color: meta[2] as Color)),
                ),
              ),
            );
          }),
          const SizedBox(height: 8),
          OutlinedButton.icon(onPressed: () => _addBook(context, app), icon: const Icon(Icons.add, size: 16), label: const Text('Añadir libro')),
        ],
      ),
    );
  }
}
