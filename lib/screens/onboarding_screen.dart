import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';

class _Q {
  final String id;
  final IconData icon;
  final String text;
  final Color? circleColor;
  const _Q(this.id, this.icon, this.text, {this.circleColor});
}

const _questions = [
  _Q('animo', Icons.mood, '¿Quieres registrar tu estado de ánimo cada día?'),
  _Q('energia', Icons.bolt, '¿Quieres registrar tu nivel de energía?'),
  _Q('sueno', Icons.bedtime, '¿Quieres hacer seguimiento de tus horas de sueño?'),
  _Q('diario_suenos', Icons.auto_awesome, '¿Quieres llevar un diario de sueños aparte de tus entradas?'),
  _Q('ejercicio', Icons.directions_run, '¿Quieres registrar si haces ejercicio cada día?'),
  _Q('hidratacion', Icons.water_drop, '¿Quieres registrar cuánta agua bebes?', circleColor: Color(0xFFE6F1FB)),
  _Q('estres', Icons.psychology, '¿Quieres registrar tu nivel de estrés?'),
  _Q('ciclo', Icons.water_drop, '¿Quieres activar el seguimiento de tu ciclo menstrual?', circleColor: Color(0xFFFCEBEB)),
  _Q('libido', Icons.local_fire_department, '¿Quieres hacer seguimiento de tu líbido?'),
  _Q('gratitud', Icons.favorite, '¿Quieres anotar algo por lo que estés agradecido cada día?'),
  _Q('todo', Icons.checklist, '¿Quieres tener una lista de tareas para cada día?'),
  _Q('lectura', Icons.menu_book, '¿Quieres llevar una lista de los libros que vas leyendo?'),
];

class OnboardingScreen extends StatefulWidget {
  const OnboardingScreen({super.key});

  @override
  State<OnboardingScreen> createState() => _OnboardingScreenState();
}

enum _Stage { welcome, question, summary }

class _OnboardingScreenState extends State<OnboardingScreen> {
  _Stage stage = _Stage.welcome;
  int idx = 0;
  final Map<String, bool> answers = {};

  void _answer(bool value) {
    answers[_questions[idx].id] = value;
    setState(() {
      idx++;
      if (idx >= _questions.length) stage = _Stage.summary;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: switch (stage) {
          _Stage.welcome => _welcome(),
          _Stage.question => _question(),
          _Stage.summary => _summary(context),
        },
      ),
    );
  }

  Widget _welcome() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 28),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.menu_book, size: 38, color: Color(0xFF185FA5)),
          const SizedBox(height: 14),
          const Text('Tu diario, a tu manera', style: TextStyle(fontSize: 17, fontWeight: FontWeight.w600)),
          const SizedBox(height: 10),
          const Text(
            'Te vamos a hacer unas preguntas rápidas para saber qué te gustaría registrar. Puedes cambiarlo cuando quieras.',
            textAlign: TextAlign.center,
            style: TextStyle(fontSize: 13, color: Colors.grey, height: 1.5),
          ),
          const SizedBox(height: 20),
          FilledButton(onPressed: () => setState(() => stage = _Stage.question), child: const Text('Empezar')),
        ],
      ),
    );
  }

  Widget _question() {
    final q = _questions[idx];
    return Column(
      children: [
        const SizedBox(height: 18),
        Wrap(
          alignment: WrapAlignment.center,
          spacing: 4,
          children: List.generate(_questions.length, (i) {
            final done = i < idx;
            final current = i == idx;
            return Container(
              width: current ? 14 : 6,
              height: 6,
              decoration: BoxDecoration(
                color: done || current ? const Color(0xFF2C2C2A) : Colors.grey.shade300,
                borderRadius: BorderRadius.circular(3),
              ),
            );
          }),
        ),
        Expanded(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  width: 64,
                  height: 64,
                  margin: const EdgeInsets.only(top: 32),
                  decoration: BoxDecoration(color: q.circleColor ?? const Color(0xFFE6F1FB), shape: BoxShape.circle),
                  child: Icon(q.icon, size: 26, color: q.circleColor != null ? Colors.black87 : const Color(0xFF185FA5)),
                ),
                const SizedBox(height: 22),
                Text(q.text, textAlign: TextAlign.center, style: const TextStyle(fontSize: 15, height: 1.5)),
                const Spacer(),
                Row(
                  children: [
                    Expanded(child: OutlinedButton(onPressed: () => _answer(false), child: const Text('Ahora no'))),
                    const SizedBox(width: 10),
                    Expanded(child: FilledButton(onPressed: () => _answer(true), child: const Text('Sí'))),
                  ],
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _summary(BuildContext context) {
    final accepted = _questions.where((q) => answers[q.id] == true).toList();
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 24),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.check_circle, size: 30, color: Color(0xFF3B6D11)),
          const SizedBox(height: 12),
          const Text('Tu diario está listo', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600)),
          const SizedBox(height: 6),
          const Text('Podrás cambiar esto cuando quieras desde Configurar campos.', textAlign: TextAlign.center, style: TextStyle(fontSize: 12, color: Colors.grey)),
          const SizedBox(height: 14),
          Wrap(
            spacing: 10,
            runSpacing: 10,
            alignment: WrapAlignment.center,
            children: accepted
                .map((q) => CircleAvatar(backgroundColor: const Color(0xFFF1EFE8), child: Icon(q.icon, size: 16, color: Colors.black87)))
                .toList(),
          ),
          const SizedBox(height: 18),
          FilledButton(
            onPressed: () async {
              await context.read<AppState>().completeOnboarding(answers);
              // AuthGate detecta que onboardingComplete pasó a true y
              // cambia solo a la pantalla del calendario.
            },
            child: const Text('Empezar a escribir'),
          ),
        ],
      ),
    );
  }
}
