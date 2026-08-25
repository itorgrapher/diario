import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';

class CalendarScreen extends StatelessWidget {
  const CalendarScreen({super.key});

  void _openFilterSheet(BuildContext context) {
    final app = context.read<AppState>();
    showModalBottomSheet(
      context: context,
      builder: (ctx) {
        return SafeArea(
          child: ListView(
            shrinkWrap: true,
            children: [
              const Padding(padding: EdgeInsets.fromLTRB(16, 12, 16, 4), child: Text('Campos', style: TextStyle(fontSize: 12, color: Colors.grey))),
              ...fieldDefs.values.map((f) => ListTile(
                    leading: Icon(f.icon, size: 20),
                    title: Text(f.label),
                    onTap: () {
                      app.setFilter('field', f.key);
                      Navigator.pop(ctx);
                    },
                  )),
              const Padding(padding: EdgeInsets.fromLTRB(16, 8, 16, 4), child: Text('Tus rachas', style: TextStyle(fontSize: 12, color: Colors.grey))),
              ...app.habits.map((h) => ListTile(
                    leading: const Icon(Icons.local_fire_department, size: 20),
                    title: Text(h),
                    onTap: () {
                      app.setFilter('habit', h);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isFieldFilter = app.filterType == 'field';
    final currentDef = isFieldFilter ? fieldDefs[app.filterKey] : null;

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: const Text('Agosto 2026'),
        centerTitle: true,
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.of(context).pushNamed('/new-entry'),
          ),
        ],
      ),
      body: ListView(
        padding: const EdgeInsets.only(bottom: 24),
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                borderRadius: BorderRadius.circular(10),
                onTap: () => _openFilterSheet(context),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                  decoration: BoxDecoration(border: Border.all(color: Colors.grey.shade400), borderRadius: BorderRadius.circular(10)),
                  child: Row(
                    children: [
                      Icon(Icons.filter_alt_outlined, size: 16, color: Colors.grey.shade600),
                      const SizedBox(width: 8),
                      Icon(isFieldFilter ? currentDef!.icon : Icons.local_fire_department, size: 16),
                      const SizedBox(width: 8),
                      Expanded(child: Text(isFieldFilter ? currentDef!.label : app.filterKey, style: const TextStyle(fontSize: 13))),
                      Icon(Icons.keyboard_arrow_down, size: 16, color: Colors.grey.shade600),
                    ],
                  ),
                ),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _legend(app),
          ),
          const SizedBox(height: 8),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _calendarGrid(context, app),
          ),
          const SizedBox(height: 12),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _todoCard(context, app),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _waterCard(context, app),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: _exerciseCard(context, app),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Card(
              child: ListTile(
                leading: const Icon(Icons.format_quote, color: Colors.grey),
                title: const Text('Hace un año, hoy', style: TextStyle(fontSize: 11, color: Colors.grey)),
                subtitle: const Text('"Salí a hacer fotos por el Albaicín al atardecer, luz increíble..."'),
                onTap: () => Navigator.of(context).pushNamed('/entry-detail'),
              ),
            ),
          ),
          const SizedBox(height: 10),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(color: AppColors.bgAccent, borderRadius: BorderRadius.circular(10)),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Icon(Icons.lightbulb_outline, size: 16, color: AppColors.accent),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Los días que duermes menos de 6h sueles marcar el ánimo más bajo. Se repite 6 de las últimas 8 veces.',
                      style: TextStyle(fontSize: 11, color: AppColors.accent, height: 1.4),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _legend(AppState app) {
    List<Widget> chips;
    if (app.filterType == 'habit') {
      chips = [
        _legendDot(AppColors.greenBg, Icons.check, AppColors.greenFg),
        _legendDot(AppColors.redBg, Icons.close, AppColors.redFg),
      ];
    } else {
      final f = fieldDefs[app.filterKey]!;
      chips = f.order
          .map((v) => _legendDot(valueColorBg(f.key, v), valueIcon(f.key, v), valueColorFg(f.key, v)))
          .toList();
    }
    return Wrap(spacing: 10, children: chips);
  }

  Widget _legendDot(Color bg, IconData icon, Color fg) {
    return CircleAvatar(radius: 11, backgroundColor: bg, child: Icon(icon, size: 12, color: fg));
  }

  Widget _calendarGrid(BuildContext context, AppState app) {
    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: 31,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: 1),
      itemBuilder: (ctx, i) {
        final day = i + 1;
        final data = app.dayData[day];
        Color? bg;
        if (data != null) {
          if (app.filterType == 'field') {
            final v = data[app.filterKey] as String?;
            if (v != null) bg = valueColorBg(app.filterKey, v);
          } else {
            final habitsMap = data['habits'] as Map<String, String?>;
            final v = habitsMap[app.filterKey];
            if (v != null) bg = v == 'si' ? AppColors.greenBg : AppColors.redBg;
          }
        }
        return GestureDetector(
          onTap: () => Navigator.of(context).pushNamed('/entry-detail'),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg ?? Colors.transparent,
              border: bg == null ? Border.all(color: Colors.grey.shade300) : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$day', style: TextStyle(fontSize: 11, color: bg == null ? Colors.grey : Colors.black87)),
          ),
        );
      },
    );
  }

  Widget _todoCard(BuildContext context, AppState app) {
    final done = app.tasks.where((t) => t.done).length;
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                const Icon(Icons.checklist, size: 16),
                const SizedBox(width: 6),
                const Text('Tareas de hoy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Text(app.tasks.isEmpty ? '' : '$done/${app.tasks.length}', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 6),
            ...List.generate(app.tasks.length, (i) {
              final t = app.tasks[i];
              return Row(
                children: [
                  Checkbox(value: t.done, onChanged: (v) => app.toggleTask(i, v ?? false)),
                  Expanded(
                    child: Text(
                      t.text,
                      style: TextStyle(fontSize: 13, decoration: t.done ? TextDecoration.lineThrough : null, color: t.done ? Colors.grey : Colors.black87),
                    ),
                  ),
                  IconButton(icon: const Icon(Icons.close, size: 16), onPressed: () => app.removeTask(i)),
                ],
              );
            }),
            _TaskInputRow(onSubmit: app.addTask),
          ],
        ),
      ),
    );
  }

  Widget _waterCard(BuildContext context, AppState app) {
    final cat = app.waterCount <= 3 ? 'bajo' : (app.waterCount <= 6 ? 'medio' : 'alto');
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.water_drop, size: 16, color: AppColors.accent),
                const SizedBox(width: 6),
                const Text('Hidratación de hoy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                const Spacer(),
                Text('${app.waterCount}/8 · $cat', style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
            const SizedBox(height: 8),
            Row(
              children: List.generate(8, (i) {
                final n = i + 1;
                final filled = n <= app.waterCount;
                return Expanded(
                  child: GestureDetector(
                    onTap: () => app.setWater(app.waterCount == n ? n - 1 : n),
                    child: Container(
                      margin: const EdgeInsets.symmetric(horizontal: 2),
                      height: 28,
                      decoration: BoxDecoration(color: filled ? AppColors.bgAccent : const Color(0xFFF1EFE8), borderRadius: BorderRadius.circular(6)),
                      child: Icon(filled ? Icons.local_drink : Icons.local_drink_outlined, size: 14, color: filled ? AppColors.accent : Colors.grey),
                    ),
                  ),
                );
              }),
            ),
          ],
        ),
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, AppState app) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            const Icon(Icons.directions_run, size: 16),
            const SizedBox(width: 6),
            const Text('Ejercicio hoy', style: TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
            const Spacer(),
            _exBtn(app, 'si', Icons.check, AppColors.greenBg, AppColors.greenFg),
            const SizedBox(width: 6),
            _exBtn(app, 'no', Icons.close, AppColors.redBg, AppColors.redFg),
          ],
        ),
      ),
    );
  }

  Widget _exBtn(AppState app, String value, IconData icon, Color bg, Color fg) {
    final selected = app.exerciseToday == value;
    return GestureDetector(
      onTap: () => app.setExercise(value),
      child: CircleAvatar(
        radius: 15,
        backgroundColor: selected ? bg : const Color(0xFFF1EFE8),
        child: Icon(icon, size: 15, color: selected ? fg : Colors.grey),
      ),
    );
  }
}

class _TaskInputRow extends StatefulWidget {
  final ValueChanged<String> onSubmit;
  const _TaskInputRow({required this.onSubmit});

  @override
  State<_TaskInputRow> createState() => _TaskInputRowState();
}

class _TaskInputRowState extends State<_TaskInputRow> {
  final TextEditingController _controller = TextEditingController();

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        const Icon(Icons.add, size: 16, color: Colors.grey),
        Expanded(
          child: TextField(
            controller: _controller,
            decoration: const InputDecoration(hintText: 'Añadir tarea y pulsar intro', border: InputBorder.none, isDense: true),
            onSubmitted: (v) {
              widget.onSubmit(v);
              _controller.clear();
            },
          ),
        ),
      ],
    );
  }
}
