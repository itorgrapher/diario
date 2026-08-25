import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    return Drawer(
      child: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 16, 16, 12),
              child: Row(
                children: [
                  const CircleAvatar(child: Text('AG')),
                  const SizedBox(width: 10),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: const [
                      Text('Aitor García', style: TextStyle(fontWeight: FontWeight.w600)),
                      Text('aitor@email.com', style: TextStyle(fontSize: 12, color: Colors.grey)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _item(context, Icons.calendar_month, 'Calendario', '/calendar'),
            _item(context, Icons.bar_chart, 'Seguimiento', '/tracking'),
            _item(context, Icons.tune, 'Configurar campos', '/fields'),
            _item(context, Icons.person, 'Perfil', '/profile'),
            const Divider(height: 1),
            _item(context, Icons.auto_awesome, 'Diario de sueños', '/dreams'),
            _item(context, Icons.menu_book, 'Mis lecturas', '/books'),
            _item(context, Icons.water_drop, 'Ciclo', '/cycle'),
            _item(context, Icons.local_fire_department, 'Desahogo', '/burn'),
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () => FirebaseAuth.instance.signOut(),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8, left: 16),
              child: Text('Tu diario · versión 1.0', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, String route) {
    final isCurrent = ModalRoute.of(context)?.settings.name == route;
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      selected: isCurrent,
      selectedTileColor: const Color(0xFFE6F1FB),
      onTap: () {
        Navigator.of(context).pop();
        if (!isCurrent) {
          Navigator.of(context).pushNamed(route);
        }
      },
    );
  }
}
