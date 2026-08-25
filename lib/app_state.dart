import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'theme.dart';
import 'services/firestore_service.dart';

class Task {
  String text;
  bool done;
  Task(this.text, this.done);

  Map<String, dynamic> toMap() => {'text': text, 'done': done};
  factory Task.fromMap(Map<String, dynamic> m) => Task(m['text'] as String? ?? '', m['done'] as bool? ?? false);
}

class FieldDef {
  final String key;
  final String label;
  final IconData icon;
  final List<String> order;
  FieldDef(this.key, this.label, this.icon, this.order);
}

class AppState extends ChangeNotifier {
  final FirestoreService _service = FirestoreService();

  // ---- Auth / onboarding ----
  String? uid;
  bool? onboardingComplete;
  final Map<String, bool> onboardingAnswers = {};

  // ---- Optional sections (toggled in Configurar campos) ----
  bool dreamsEnabled = false;
  bool booksEnabled = false;
  bool cycleEnabled = false;

  // ---- Calendar filter ----
  String filterType = 'field';
  String filterKey = 'animo';

  // ---- Today's cards (persisted per day in Firestore) ----
  List<Task> tasks = [];
  int waterCount = 0;
  String? exerciseToday;

  // ---- New entry field selections (for today) ----
  final Map<String, String?> newEntryFields = {
    'animo': null,
    'sueno': null,
    'energia': null,
    'libido': null,
    'estres': null,
  };
  String gratitudeText = '';
  String entryText = '';
  List<String> entryPhotoUrls = [];

  // ---- Habits (custom streaks) ----
  List<Map<String, dynamic>> habits = []; // each: {id, name}
  StreamSubscription? _habitsSub;

  // ---- Calendar month cache: day-of-month -> saved entry/daily data ----
  Map<int, Map<String, dynamic>> monthEntries = {};
  Map<int, Map<String, dynamic>> monthDaily = {};
  DateTime visibleMonth = DateTime(DateTime.now().year, DateTime.now().month);

  DateTime get today => DateTime.now();

  Future<void> initializeForUser(String newUid) async {
    uid = newUid;
    final profile = await FirebaseFirestore.instance.collection('users').doc(newUid).get();
    final profileData = profile.data();
    final onboardingAnswersSaved = profileData?['onboardingAnswers'] as Map<String, dynamic>?;
    onboardingComplete = (profileData?['onboardingComplete'] as bool?) ?? false;
    dreamsEnabled = (profileData?['dreamsEnabled'] as bool?) ?? (onboardingAnswersSaved?['diario_suenos'] as bool?) ?? false;
    booksEnabled = (profileData?['booksEnabled'] as bool?) ?? (onboardingAnswersSaved?['lectura'] as bool?) ?? false;
    cycleEnabled = (profileData?['cycleEnabled'] as bool?) ?? (onboardingAnswersSaved?['ciclo'] as bool?) ?? false;

    await _loadToday();
    await loadMonth(visibleMonth);
    _subscribeHabits();

    notifyListeners();
  }

  Future<void> setSectionEnabled(String key, bool value) async {
    if (uid == null) return;
    switch (key) {
      case 'dreams':
        dreamsEnabled = value;
        break;
      case 'books':
        booksEnabled = value;
        break;
      case 'cycle':
        cycleEnabled = value;
        break;
    }
    await FirebaseFirestore.instance.collection('users').doc(uid).set({'${key}Enabled': value}, SetOptions(merge: true));
    notifyListeners();
  }

  Future<void> completeOnboarding(Map<String, bool> answers) async {
    if (uid == null) return;
    onboardingAnswers.addAll(answers);
    await FirebaseFirestore.instance.collection('users').doc(uid).set({
      'onboardingComplete': true,
      'onboardingAnswers': answers,
    }, SetOptions(merge: true));
    onboardingComplete = true;
    notifyListeners();
  }

  Future<void> _loadToday() async {
    if (uid == null) return;
    final data = await FirebaseFirestore.instance
        .collection('users')
        .doc(uid)
        .collection('daily')
        .doc(dayId(today))
        .get()
        .then((d) => d.data());
    tasks = (data?['tasks'] as List<dynamic>?)?.map((t) => Task.fromMap(t as Map<String, dynamic>)).toList() ?? [];
    waterCount = (data?['water'] as int?) ?? 0;
    exerciseToday = data?['exercise'] as String?;

    final entry = await _service.getEntry(uid!, today);
    if (entry != null) {
      entryText = entry['text'] as String? ?? '';
      gratitudeText = entry['gratitude'] as String? ?? '';
      entryPhotoUrls = (entry['photoUrls'] as List<dynamic>?)?.cast<String>() ?? [];
      for (final key in newEntryFields.keys) {
        newEntryFields[key] = entry[key] as String?;
      }
    }
  }

  Future<void> _saveToday() async {
    if (uid == null) return;
    final data = {
      'tasks': tasks.map((t) => t.toMap()).toList(),
      'water': waterCount,
      'exercise': exerciseToday,
    };
    await _service.saveDaily(uid!, today, data);
    // Keep the month cache in sync so the calendar reflects the change immediately.
    monthDaily[today.day] = data;
  }

  Future<void> loadMonth(DateTime month) async {
    if (uid == null) return;
    visibleMonth = DateTime(month.year, month.month);
    monthEntries = await _service.getMonthEntries(uid!, month.year, month.month);
    monthDaily = await _service.getMonthDaily(uid!, month.year, month.month);
    notifyListeners();
  }

  void _subscribeHabits() {
    if (uid == null) return;
    _habitsSub?.cancel();
    _habitsSub = _service.watchHabits(uid!).listen((list) {
      habits = list;
      notifyListeners();
    });
  }

  @override
  void dispose() {
    _habitsSub?.cancel();
    super.dispose();
  }

  // ---------- Tasks ----------

  void toggleTask(int index, bool value) {
    tasks[index].done = value;
    _saveToday();
    notifyListeners();
  }

  void addTask(String text) {
    if (text.trim().isEmpty) return;
    tasks.add(Task(text.trim(), false));
    _saveToday();
    notifyListeners();
  }

  void removeTask(int index) {
    tasks.removeAt(index);
    _saveToday();
    notifyListeners();
  }

  // ---------- Water / exercise ----------

  void setWater(int count) {
    waterCount = count.clamp(0, 8);
    _saveToday();
    notifyListeners();
  }

  void setExercise(String? value) {
    exerciseToday = exerciseToday == value ? null : value;
    _saveToday();
    notifyListeners();
  }

  // ---------- Calendar filter ----------

  void setFilter(String type, String key) {
    filterType = type;
    filterKey = key;
    notifyListeners();
  }

  // ---------- New entry ----------

  void setNewEntryField(String field, String? value) {
    newEntryFields[field] = value;
    notifyListeners();
  }

  Future<void> saveEntryNow({required String text, required String gratitude}) async {
    if (uid == null) return;
    entryText = text;
    gratitudeText = gratitude;
    final data = {
      'text': text,
      'gratitude': gratitude,
      'photoUrls': entryPhotoUrls,
      ...newEntryFields,
    };
    await _service.saveEntry(uid!, today, data);
    monthEntries[today.day] = data;
    notifyListeners();
  }

  void addPhotoUrl(String url) {
    entryPhotoUrls.add(url);
    notifyListeners();
  }

  // ---------- Habits ----------

  void addHabit(String name) {
    if (uid == null || name.trim().isEmpty) return;
    _service.addHabit(uid!, name.trim());
  }

  void removeHabit(int index) {
    if (uid == null) return;
    final id = habits[index]['id'] as String;
    _service.removeHabit(uid!, id);
  }

  // ---------- Dreams / books (kept local for this milestone) ----------

  final List<Map<String, String>> dreams = [
    {'date': '21 de agosto', 'text': 'Estaba en un estudio de fotografía enorme y no encontraba la cámara.'},
    {'date': '17 de agosto', 'text': 'Volaba sobre Granada, veía el Albaicín desde arriba.'},
  ];

  void addDream(String text) {
    if (text.trim().isEmpty) return;
    dreams.insert(0, {'date': '22 de agosto', 'text': text.trim()});
    notifyListeners();
  }

  final List<Map<String, dynamic>> books = [
    {'title': 'Sapiens', 'author': 'Yuval Noah Harari', 'status': 'leyendo', 'progress': 62},
    {'title': 'El fotógrafo de sombras', 'author': 'Marc Pastor', 'status': 'terminado', 'progress': 100},
    {'title': 'Steal Like an Artist', 'author': 'Austin Kleon', 'status': 'pendiente', 'progress': 0},
  ];

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

  // ---------- Cycle ----------

  int cycleAvgLen = 28;
  int cyclePeriodLen = 5;
  Set<int> cyclePeriodDays = {};

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
