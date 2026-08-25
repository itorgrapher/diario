import 'package:flutter/material.dart';
import 'theme.dart';

class Task {
  String text;
  bool done;
  Task(this.text, this.done);
}

class FieldDef {
  final String key;
  final String label;
  final IconData icon;
  final List<String> order;
  FieldDef(this.key, this.label, this.icon, this.order);
}

class AppState extends ChangeNotifier {
  // Onboarding answers: id -> bool
  final Map<String, bool> onboardingAnswers = {};

  // Calendar filter
  String filterType = 'field'; // 'field' or 'habit'
  String filterKey = 'animo';

  // Today's cards
  final List<Task> tasks = [
    Task('Editar fotos del proyecto', true),
    Task('Responder emails de la tienda', false),
    Task('Preparar horarios de la semana', false),
  ];
  int waterCount = 4;
  String? exerciseToday; // 'si' | 'no' | null

  // New entry field selections
  final Map<String, String?> newEntryFields = {
    'animo': null,
    'sueno': null,
    'energia': null,
    'libido': null,
    'estres': null,
  };
  String gratitudeText = '';
  String entryText = '';

  // Habits (custom streaks)
  final List<String> habits = ['No fumar', 'Meditar'];

  // Dreams
  final List<Map<String, String>> dreams = [
    {'date': '21 de agosto', 'text': 'Estaba en un estudio de fotografía enorme y no encontraba la cámara.'},
    {'date': '17 de agosto', 'text': 'Volaba sobre Granada, veía el Albaicín desde arriba.'},
  ];

  // Books
  final List<Map<String, dynamic>> books = [
    {'title': 'Sapiens', 'author': 'Yuval Noah Harari', 'status': 'leyendo', 'progress': 62},
    {'title': 'El fotógrafo de sombras', 'author': 'Marc Pastor', 'status': 'terminado', 'progress': 100},
    {'title': 'Steal Like an Artist', 'author': 'Austin Kleon', 'status': 'pendiente', 'progress': 0},
  ];

  // Cycle
  int cycleAvgLen = 28;
  int cyclePeriodLen = 5;
  Set<int> cyclePeriodDays = {1, 2, 3, 4, 5};

  // Mock per-day data for the calendar (day number -> field -> value)
  final Map<int, Map<String, dynamic>> dayData = {};

  AppState() {
    _buildMockDayData();
  }

  void _buildMockDayData() {
    const moods = ['feliz', 'tranquilo', 'neutral', 'triste', 'irritado'];
    const levels3 = ['alto', 'medio', 'bajo'];
    final skip = {1, 6, 9, 11, 14, 17, 21, 24, 25, 26, 27, 28, 29, 30, 31};
    for (int d = 1; d <= 31; d++) {
      if (skip.contains(d)) continue;
      dayData[d] = {
        'animo': moods[d % 5],
        'sueno': levels3[d % 3],
        'energia': levels3[(d + 1) % 3],
        'libido': levels3[(d + 2) % 3],
        'estres': levels3[(d + 1) % 3],
        'ejercicio': (d % 3 == 0) ? 'no' : 'si',
        'hidratacion': levels3[d % 3],
        'habits': {
          'No fumar': d >= 10 ? (d == 15 ? 'no' : 'si') : null,
          'Meditar': d >= 20 ? (d == 23 ? 'no' : 'si') : null,
        },
      };
    }
  }

  void toggleTask(int index, bool value) {
    tasks[index].done = value;
    notifyListeners();
  }

  void addTask(String text) {
    if (text.trim().isEmpty) return;
    tasks.add(Task(text.trim(), false));
    notifyListeners();
  }

  void removeTask(int index) {
    tasks.removeAt(index);
    notifyListeners();
  }

  void setWater(int count) {
    waterCount = count.clamp(0, 8);
    notifyListeners();
  }

  void setExercise(String? value) {
    exerciseToday = exerciseToday == value ? null : value;
    notifyListeners();
  }

  void setFilter(String type, String key) {
    filterType = type;
    filterKey = key;
    notifyListeners();
  }

  void setNewEntryField(String field, String? value) {
    newEntryFields[field] = value;
    notifyListeners();
  }

  void addHabit(String name) {
    if (name.trim().isEmpty) return;
    habits.add(name.trim());
    notifyListeners();
  }

  void removeHabit(int index) {
    habits.removeAt(index);
    notifyListeners();
  }

  void addDream(String text) {
    if (text.trim().isEmpty) return;
    dreams.insert(0, {'date': '22 de agosto', 'text': text.trim()});
    notifyListeners();
  }

  void addBook(String title, String author) {
    if (title.trim().isEmpty) return;
    books.insert(0, {
      'title': title.trim(),
      'author': author.trim().isEmpty ? 'Autor desconocido' : author.trim(),
      'status': 'pendiente',
      'progress': 0,
    });
    notifyListeners();
  }

  void togglePeriodDay(int day) {
    if (cyclePeriodDays.contains(day)) {
      cyclePeriodDays.remove(day);
    } else {
      cyclePeriodDays.add(day);
    }
    notifyListeners();
  }
}

final Map<String, FieldDef> fieldDefs = {
  'animo': FieldDef('animo', 'Ánimo', Icons.mood, ['feliz', 'tranquilo', 'neutral', 'triste', 'irritado']),
  'sueno': FieldDef('sueno', 'Sueño', Icons.bedtime, ['alto', 'medio', 'bajo']),
  'energia': FieldDef('energia', 'Energía', Icons.bolt, ['alta', 'media', 'baja']),
  'libido': FieldDef('libido', 'Líbido', Icons.local_fire_department, ['alta', 'media', 'baja']),
  'estres': FieldDef('estres', 'Estrés', Icons.psychology, ['bajo', 'medio', 'alto']),
  'ejercicio': FieldDef('ejercicio', 'Ejercicio', Icons.directions_run, ['si', 'no']),
  'hidratacion': FieldDef('hidratacion', 'Hidratación', Icons.water_drop, ['alto', 'medio', 'bajo']),
};

Color valueColorBg(String field, String value) {
  const scaleGYR = {'alto': AppColors.greenBg, 'medio': AppColors.amberBg, 'bajo': AppColors.redBg};
  const scaleBinaryGR = {'si': AppColors.greenBg, 'no': AppColors.redBg};
  switch (field) {
    case 'animo':
      return const {
        'feliz': AppColors.amberBg,
        'tranquilo': AppColors.tealBg,
        'neutral': AppColors.grayBg,
        'triste': AppColors.blueBg,
        'irritado': AppColors.coralBg,
      }[value]!;
    case 'sueno':
    case 'energia':
    case 'libido':
      return const {'alto': AppColors.tealBg, 'alta': AppColors.tealBg, 'medio': AppColors.grayBg, 'media': AppColors.grayBg, 'bajo': AppColors.coralBg, 'baja': AppColors.coralBg}[value]!;
    case 'estres':
      return scaleGYR[value] ?? AppColors.grayBg;
    case 'ejercicio':
      return scaleBinaryGR[value] ?? AppColors.grayBg;
    case 'hidratacion':
      return scaleGYR[value] ?? AppColors.grayBg;
    default:
      return AppColors.grayBg;
  }
}

Color valueColorFg(String field, String value) {
  const scaleGYR = {'alto': AppColors.greenFg, 'medio': AppColors.amberFg, 'bajo': AppColors.redFg};
  const scaleBinaryGR = {'si': AppColors.greenFg, 'no': AppColors.redFg};
  switch (field) {
    case 'animo':
      return const {
        'feliz': AppColors.amberFg,
        'tranquilo': AppColors.tealFg,
        'neutral': AppColors.grayFg,
        'triste': AppColors.blueFg,
        'irritado': AppColors.coralFg,
      }[value]!;
    case 'sueno':
    case 'energia':
    case 'libido':
      return const {'alto': AppColors.tealFg, 'alta': AppColors.tealFg, 'medio': AppColors.grayFg, 'media': AppColors.grayFg, 'bajo': AppColors.coralFg, 'baja': AppColors.coralFg}[value]!;
    case 'estres':
      return scaleGYR[value] ?? AppColors.grayFg;
    case 'ejercicio':
      return scaleBinaryGR[value] ?? AppColors.grayFg;
    case 'hidratacion':
      return scaleGYR[value] ?? AppColors.grayFg;
    default:
      return AppColors.grayFg;
  }
}

IconData valueIcon(String field, String value) {
  switch (field) {
    case 'animo':
      return const {
        'feliz': Icons.sentiment_very_satisfied,
        'tranquilo': Icons.sentiment_satisfied,
        'neutral': Icons.sentiment_neutral,
        'triste': Icons.sentiment_dissatisfied,
        'irritado': Icons.sentiment_very_dissatisfied,
      }[value]!;
    case 'ejercicio':
      return value == 'si' ? Icons.check : Icons.close;
    default:
      return fieldDefs[field]!.icon;
  }
}
