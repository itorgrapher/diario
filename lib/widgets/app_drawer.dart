import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:provider/provider.dart';
import '../app_state.dart';
import '../screens/fields_screen.dart';
import '../screens/profile_screen.dart';
import '../screens/books_screen.dart';
import '../screens/cycle_screen.dart';

class AppDrawer extends StatelessWidget {
  const AppDrawer({super.key});

  @override
  Widget build(BuildContext context) {
    final app = context.watch<AppState>();
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
                    children: [
                      Text(FirebaseAuth.instance.currentUser?.email ?? '', style: const TextStyle(fontWeight: FontWeight.w600, fontSize: 13)),
                    ],
                  ),
                ],
              ),
            ),
            const Divider(height: 1),
            _item(context, Icons.tune, 'Configurar campos', const FieldsScreen()),
            _item(context, Icons.person, 'Perfil', const ProfileScreen()),
            if (app.booksEnabled || app.cycleEnabled) ...[
              const Divider(height: 1),
              if (app.booksEnabled) _item(context, Icons.menu_book, 'Mis lecturas', const BooksScreen()),
              if (app.cycleEnabled) _item(context, Icons.water_drop, 'Ciclo', const CycleScreen()),
            ],
            const Spacer(),
            const Divider(height: 1),
            ListTile(
              leading: const Icon(Icons.logout),
              title: const Text('Cerrar sesión'),
              onTap: () async {
                await FirebaseAuth.instance.signOut();
                if (context.mounted) Navigator.of(context).popUntil((route) => route.isFirst);
              },
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: 8, left: 16),
              child: Text('Ánima · versión 1.0', style: TextStyle(fontSize: 10, color: Colors.grey)),
            ),
          ],
        ),
      ),
    );
  }

  Widget _item(BuildContext context, IconData icon, String label, Widget screen) {
    return ListTile(
      leading: Icon(icon, size: 20),
      title: Text(label, style: const TextStyle(fontSize: 14)),
      onTap: () {
        Navigator.of(context).pop();
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => screen));
      },
    );
  }
}
