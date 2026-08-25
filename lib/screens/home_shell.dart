import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import 'calendar_screen.dart';
import 'tracking_screen.dart';
import 'dreams_screen.dart';
import 'burn_screen.dart';

class _TabDef {
  final String label;
  final IconData icon;
  final Widget screen;
  _TabDef(this.label, this.icon, this.screen);
}

/// Bottom navigation bar for the content sections you use often
/// (Calendario, Seguimiento, Sueños, Desahogo). Settings-type sections
/// (Perfil, Configurar campos, Mis lecturas, Ciclo) live in the side
/// drawer instead — opened from the calendar screen's menu button.
class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
    final tabs = <_TabDef>[
      _TabDef('Calendario', Icons.calendar_month, const CalendarScreen()),
      _TabDef('Seguimiento', Icons.bar_chart, const TrackingScreen()),
      if (app.dreamsEnabled) _TabDef('Sueños', Icons.auto_awesome, const DreamsScreen()),
      _TabDef('Desahogo', Icons.local_fire_department, const BurnScreen()),
    ];
    if (_index >= tabs.length) _index = 0;

    return Scaffold(
      body: IndexedStack(index: _index, children: tabs.map((t) => t.screen).toList()),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: tabs.map((t) => NavigationDestination(icon: Icon(t.icon), label: t.label)).toList(),
      ),
    );
  }
}
