import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import '../app_state.dart';
import '../theme.dart';
import '../widgets/app_drawer.dart';
import 'entry_detail_screen.dart';

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
              if (app.habits.isEmpty)
                const Padding(padding: EdgeInsets.fromLTRB(16, 0, 16, 12), child: Text('Todavía no tienes ninguna racha creada.', style: TextStyle(fontSize: 12, color: Colors.grey))),
              ...app.habits.map((h) => ListTile(
                    leading: const Icon(Icons.local_fire_department, size: 20),
                    title: Text(h['name'] as String),
                    onTap: () {
                      app.setFilter('habit', h['name'] as String);
                      Navigator.pop(ctx);
                    },
                  )),
            ],
          ),
        );
      },
    );
  }

  void _openDay(BuildContext context, DateTime date) {
    Navigator.of(context).push(MaterialPageRoute(builder: (_) => EntryDetailScreen(date: date)));
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isFieldFilter = app.filterType == 'field';
    final currentDef = isFieldFilter ? fieldDefs[app.filterKey] : null;
    final monthLabel = DateFormat.yMMMM('es').format(app.visibleMonth);

    return Scaffold(
      drawer: const AppDrawer(),
      appBar: AppBar(
        title: Text(_capitalize(monthLabel)),
        centerTitle: true,
        actions: [
          IconButton(
            icon: Icon(app.entryText.isNotEmpty ? Icons.edit_outlined : Icons.add),
            tooltip: app.entryText.isNotEmpty ? 'Continuar entrada de hoy' : 'Nueva entrada',
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
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _legend(app)),
          const SizedBox(height: 8),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _calendarGrid(context, app)),
          const SizedBox(height: 12),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _todoCard(context, app)),
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _waterCard(context, app)),
          const SizedBox(height: 10),
          Padding(padding: const EdgeInsets.symmetric(horizontal: 16), child: _exerciseCard(context, app)),
        ],
      ),
    );
  }

  static String _capitalize(String s) => s.isEmpty ? s : s[0].toUpperCase() + s.substring(1);

  Widget _legend(AppState app) {
    List<Widget> chips;
    if (app.filterType == 'habit') {
      chips = [
        _legendDot(AppColors.greenBg, Icons.check, AppColors.greenFg),
        _legendDot(AppColors.redBg, Icons.close, AppColors.redFg),
      ];
    } else {
      final f = fieldDefs[app.filterKey]!;
      chips = f.order.map((v) => _legendDot(valueColorBg(f.key, v), valueIcon(f.key, v), valueColorFg(f.key, v))).toList();
    }
    return Wrap(spacing: 10, children: chips);
  }

  Widget _legendDot(Color bg, IconData icon, Color fg) {
    return CircleAvatar(radius: 11, backgroundColor: bg, child: Icon(icon, size: 12, color: fg));
  }

  Widget _calendarGrid(BuildContext context, AppState app) {
    final month = app.visibleMonth;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = DateTime(month.year, month.month, 1).weekday - 1; // Monday = 0
    final todayDay = DateTime.now().year == month.year && DateTime.now().month == month.month ? DateTime.now().day : -1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth + leadingEmpty,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 5, crossAxisSpacing: 5, childAspectRatio: 1),
      itemBuilder: (ctx, i) {
        if (i < leadingEmpty) return const SizedBox.shrink();
        final day = i - leadingEmpty + 1;

        Color? bg;
        if (app.filterType == 'field') {
          final entry = app.monthEntries[day];
          final daily = app.monthDaily[day];
          String? v;
          if (app.filterKey == 'hidratacion') {
            final water = daily?['water'] as int?;
            if (water != null) v = water <= 3 ? 'bajo' : (water <= 6 ? 'medio' : 'alto');
          } else if (app.filterKey == 'ejercicio') {
            v = daily?['exercise'] as String?;
          } else {
            v = entry?[app.filterKey] as String?;
          }
          if (v != null) bg = valueColorBg(app.filterKey, v);
        }
        // Habit-based history isn't tracked per past day in this milestone yet.

        final isToday = day == todayDay;
        return GestureDetector(
          onTap: () => _openDay(context, DateTime(month.year, month.month, day)),
          child: Container(
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: bg ?? Colors.transparent,
              border: bg == null ? Border.all(color: isToday ? AppColors.accent : Colors.grey.shade300, width: isToday ? 1.4 : 1) : null,
              borderRadius: BorderRadius.circular(6),
            ),
            child: Text('$day', style: TextStyle(fontSize: 11, color: bg == null ? (isToday ? AppColors.accent : Colors.grey) : Colors.black87, fontWeight: isToday ? FontWeight.w700 : FontWeight.normal)),
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
