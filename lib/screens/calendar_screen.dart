import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:intl/intl.dart';
import 'package:google_fonts/google_fonts.dart';
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

  static Widget _circleButton(BuildContext context, IconData icon, VoidCallback onTap, {String? tooltip}) {
    return Material(
      color: const Color(0xFFF1EFE8),
      shape: const CircleBorder(),
      child: InkWell(
        customBorder: const CircleBorder(),
        onTap: onTap,
        child: Padding(
          padding: const EdgeInsets.all(10),
          child: Icon(icon, size: 18, semanticLabel: tooltip),
        ),
      ),
    );
  }

  static Widget _borderedCard({required Widget child, EdgeInsets? padding}) {
    return Container(
      padding: padding ?? const EdgeInsets.all(12),
      decoration: BoxDecoration(border: Border.all(color: const Color(0xFFE6E3D8)), borderRadius: BorderRadius.circular(12)),
      child: child,
    );
  }

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final isFieldFilter = app.filterType == 'field';
    final currentDef = isFieldFilter ? fieldDefs[app.filterKey] : null;
    final monthLabel = DateFormat.MMMM('es').format(app.visibleMonth).toUpperCase();
    final yearLabel = app.visibleMonth.year.toString();

    return Scaffold(
      backgroundColor: const Color(0xFFFAF7F0),
      drawer: const AppDrawer(),
      body: SafeArea(
        child: Builder(builder: (context) {
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 24),
            children: [
              Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _circleButton(context, Icons.menu, () => Scaffold.of(context).openDrawer(), tooltip: 'Abrir menú'),
                  Expanded(
                    child: Column(
                      children: [
                        Text('ÁNIMA', style: GoogleFonts.playfairDisplay(fontSize: 24, letterSpacing: 2, color: Theme.of(context).colorScheme.onSurface)),
                        const Text('Tu día, a tu manera.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                      ],
                    ),
                  ),
                  _circleButton(context, Icons.tune, () => _openFilterSheet(context), tooltip: 'Filtrar'),
                ],
              ),
              const SizedBox(height: 14),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  IconButton(icon: const Icon(Icons.chevron_left), onPressed: () => app.loadMonth(DateTime(app.visibleMonth.year, app.visibleMonth.month - 1))),
                  Text('$monthLabel $yearLabel', style: GoogleFonts.playfairDisplay(fontSize: 15, letterSpacing: 1)),
                  IconButton(icon: const Icon(Icons.chevron_right), onPressed: () => app.loadMonth(DateTime(app.visibleMonth.year, app.visibleMonth.month + 1))),
                ],
              ),
              Row(
                children: const ['L', 'M', 'X', 'J', 'V', 'S', 'D']
                    .map((d) => Expanded(child: Center(child: Text(d, style: const TextStyle(fontSize: 11, color: Colors.grey)))))
                    .toList(),
              ),
              const SizedBox(height: 4),
              _calendarGrid(context, app),
              const SizedBox(height: 12),
              _legendCard(app),
              const SizedBox(height: 18),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text('Hoy', style: GoogleFonts.playfairDisplay(fontSize: 18)),
                  GestureDetector(
                    onTap: () => Navigator.of(context).pushNamed('/new-entry'),
                    child: Row(
                      children: [
                        Icon(Icons.edit_outlined, size: 14, color: AppColors.accent),
                        const SizedBox(width: 4),
                        Text('Editar', style: TextStyle(fontSize: 12, color: AppColors.accent)),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 10),
              IntrinsicHeight(
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Expanded(child: _todoCard(context, app)),
                    const SizedBox(width: 8),
                    Expanded(child: _waterCard(context, app)),
                    const SizedBox(width: 8),
                    Expanded(child: _exerciseCard(context, app)),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _borderedCard(
                child: Row(
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: AppColors.blueBg, child: Icon(Icons.event_note_outlined, size: 16, color: AppColors.blueFg)),
                    const SizedBox(width: 10),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: const [
                          Text('Hace un año, hoy', style: TextStyle(fontSize: 11, color: Colors.grey)),
                          SizedBox(height: 2),
                          Text('Todavía no hay entradas de hace un año.', style: TextStyle(fontSize: 12, fontStyle: FontStyle.italic)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 10),
              _borderedCard(
                child: Row(
                  children: [
                    CircleAvatar(radius: 18, backgroundColor: AppColors.coralBg, child: Icon(Icons.trending_up, size: 16, color: AppColors.coralFg)),
                    const SizedBox(width: 10),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Patrón detectado', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                          SizedBox(height: 2),
                          Text('Necesitamos más entradas tuyas para detectar patrones fiables.', style: TextStyle(fontSize: 11, color: Colors.grey)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              if (app.habits.isNotEmpty) ...[
                const SizedBox(height: 10),
                _borderedCard(
                  child: Row(
                    children: [
                      CircleAvatar(radius: 18, backgroundColor: AppColors.greenBg, child: Icon(Icons.local_fire_department, size: 16, color: AppColors.greenFg)),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Tus rachas', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600)),
                            const SizedBox(height: 2),
                            Text(app.habits.map((h) => h['name'] as String).join(' · '), style: const TextStyle(fontSize: 11, color: Colors.grey)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
              const SizedBox(height: 20),
              Center(
                child: GestureDetector(
                  onTap: () => Navigator.of(context).pushNamed('/new-entry'),
                  child: Column(
                    children: [
                      Container(
                        width: 52,
                        height: 52,
                        decoration: BoxDecoration(color: AppColors.accent, shape: BoxShape.circle),
                        child: const Icon(Icons.edit, color: Colors.white, size: 20),
                      ),
                      const SizedBox(height: 6),
                      Text(
                        app.entryText.isNotEmpty ? 'Editar entrada de hoy' : 'Nueva entrada de hoy',
                        style: TextStyle(fontSize: 12, color: AppColors.accent),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        }),
      ),
    );
  }

  Widget _legendCard(AppState app) {
    List<Widget> icons;
    if (app.filterType == 'habit') {
      icons = [
        Icon(Icons.check, size: 15, color: AppColors.greenFg),
        Icon(Icons.close, size: 15, color: AppColors.redFg),
      ];
    } else {
      final f = fieldDefs[app.filterKey]!;
      icons = f.order.map((v) => Icon(valueIcon(f.key, v), size: 15, color: valueColorFg(f.key, v))).toList();
    }
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      decoration: BoxDecoration(color: const Color(0xFFF1EFE8), borderRadius: BorderRadius.circular(16)),
      child: Row(mainAxisAlignment: MainAxisAlignment.spaceAround, children: icons),
    );
  }

  Widget _calendarGrid(BuildContext context, AppState app) {
    final month = app.visibleMonth;
    final daysInMonth = DateTime(month.year, month.month + 1, 0).day;
    final leadingEmpty = DateTime(month.year, month.month, 1).weekday - 1;
    final now = DateTime.now();
    final todayDay = now.year == month.year && now.month == month.month ? now.day : -1;

    return GridView.builder(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      itemCount: daysInMonth + leadingEmpty,
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 7, mainAxisSpacing: 2, crossAxisSpacing: 2, childAspectRatio: 0.78),
      itemBuilder: (ctx, i) {
        if (i < leadingEmpty) return const SizedBox.shrink();
        final day = i - leadingEmpty + 1;
        final isToday = day == todayDay;

        String? value;
        Color? bg;
        Color? fg;
        IconData? icon;
        if (app.filterType == 'field') {
          final entry = app.monthEntries[day];
          final daily = app.monthDaily[day];
          if (app.filterKey == 'hidratacion') {
            final water = daily?['water'] as int?;
            if (water != null) value = water <= 3 ? 'bajo' : (water <= 6 ? 'medio' : 'alto');
          } else if (app.filterKey == 'ejercicio') {
            value = daily?['exercise'] as String?;
          } else {
            value = entry?[app.filterKey] as String?;
          }
          if (value != null) {
            bg = valueColorBg(app.filterKey, value);
            fg = valueColorFg(app.filterKey, value);
            icon = valueIcon(app.filterKey, value);
          }
        }

        return GestureDetector(
          onTap: () => _openDay(context, DateTime(month.year, month.month, day)),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                '$day',
                style: TextStyle(fontSize: 10, color: isToday ? AppColors.accent : Colors.grey, fontWeight: isToday ? FontWeight.w700 : FontWeight.normal),
              ),
              const SizedBox(height: 2),
              Container(
                width: 26,
                height: 26,
                decoration: BoxDecoration(
                  color: isToday ? AppColors.accent : (bg ?? Colors.transparent),
                  shape: BoxShape.circle,
                ),
                alignment: Alignment.center,
                child: isToday
                    ? Text('$day', style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white))
                    : (icon != null ? Icon(icon, size: 13, color: fg) : null),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _todoCard(BuildContext context, AppState app) {
    final done = app.tasks.where((t) => t.done).length;
    return _borderedCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [const Icon(Icons.checklist, size: 13), const SizedBox(width: 4), const Text('Tareas', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 6),
          ...app.tasks.take(2).map((t) => Padding(
                padding: const EdgeInsets.only(bottom: 3),
                child: Row(
                  children: [
                    Icon(t.done ? Icons.check_box : Icons.check_box_outline_blank, size: 13, color: t.done ? AppColors.greenFg : Colors.grey),
                    const SizedBox(width: 4),
                    Expanded(child: Text(t.text, maxLines: 1, overflow: TextOverflow.ellipsis, style: TextStyle(fontSize: 10, decoration: t.done ? TextDecoration.lineThrough : null, color: t.done ? Colors.grey : Colors.black87))),
                  ],
                ),
              )),
          const Spacer(),
          Row(
            children: [
              Text(app.tasks.isEmpty ? '0 / 0' : '$done / ${app.tasks.length}', style: const TextStyle(fontSize: 10, color: Colors.grey)),
              const Spacer(),
              GestureDetector(
                onTap: () => Navigator.of(context).pushNamed('/new-entry'),
                child: const Icon(Icons.add_circle_outline, size: 16),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _waterCard(BuildContext context, AppState app) {
    return _borderedCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: [Icon(Icons.water_drop, size: 13, color: AppColors.accent), const SizedBox(width: 4), const Text('Hidratación', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
          const SizedBox(height: 6),
          GridView.builder(
            shrinkWrap: true,
            physics: const NeverScrollableScrollPhysics(),
            itemCount: 8,
            gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(crossAxisCount: 4, mainAxisSpacing: 3, crossAxisSpacing: 3),
            itemBuilder: (ctx, i) {
              final n = i + 1;
              final filled = n <= app.waterCount;
              return GestureDetector(
                onTap: () => app.setWater(app.waterCount == n ? n - 1 : n),
                child: Icon(filled ? Icons.local_drink : Icons.local_drink_outlined, size: 14, color: filled ? AppColors.accent : Colors.grey),
              );
            },
          ),
          const Spacer(),
          Text('${app.waterCount} / 8 vasos', style: const TextStyle(fontSize: 10, color: Colors.grey)),
        ],
      ),
    );
  }

  Widget _exerciseCard(BuildContext context, AppState app) {
    return _borderedCard(
      padding: const EdgeInsets.all(10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(children: const [Icon(Icons.directions_run, size: 13), SizedBox(width: 4), Text('Ejercicio', style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600))]),
          const Spacer(),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _exBtn(app, 'si', Icons.check, AppColors.greenBg, AppColors.greenFg),
              const SizedBox(width: 8),
              _exBtn(app, 'no', Icons.close, const Color(0xFFF1EFE8), Colors.grey),
            ],
          ),
          const Spacer(),
        ],
      ),
    );
  }

  Widget _exBtn(AppState app, String value, IconData icon, Color bg, Color fg) {
    final selected = app.exerciseToday == value;
    return GestureDetector(
      onTap: () => app.setExercise(value),
      child: CircleAvatar(
        radius: 14,
        backgroundColor: selected ? bg : const Color(0xFFF1EFE8),
        child: Icon(icon, size: 13, color: selected ? fg : Colors.grey),
      ),
    );
  }
}
