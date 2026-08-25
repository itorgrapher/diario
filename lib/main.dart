import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'firebase_options.dart';
import 'app_state.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/fields_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dreams_screen.dart';
import 'screens/books_screen.dart';
import 'screens/cycle_screen.dart';
import 'screens/burn_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.android);
  await initializeDateFormatting('es');
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const TuDiarioApp(),
    ),
  );
}

class TuDiarioApp extends StatelessWidget {
  const TuDiarioApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Tu diario',
      debugShowCheckedModeBanner: false,
      theme: buildAppTheme(),
      home: const AuthGate(),
      routes: {
        '/login': (_) => const LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/calendar': (_) => const CalendarScreen(),
        '/new-entry': (_) => const NewEntryScreen(),
        '/tracking': (_) => const TrackingScreen(),
        '/fields': (_) => const FieldsScreen(),
        '/profile': (_) => const ProfileScreen(),
        '/dreams': (_) => const DreamsScreen(),
        '/books': (_) => const BooksScreen(),
        '/cycle': (_) => const CycleScreen(),
        '/burn': (_) => const BurnScreen(),
      },
    );
  }
}

/// Decides the very first screen based on whether Firebase already has a
/// signed-in user (session persists automatically between app launches).
class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    return StreamBuilder<User?>(
      stream: FirebaseAuth.instance.authStateChanges(),
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(body: Center(child: CircularProgressIndicator()));
        }
        final user = snapshot.data;
        if (user == null) {
          return const LoginScreen();
        }
        final app = context.read<AppState>();
        if (app.uid != user.uid) {
          app.initializeForUser(user.uid);
        }
        return const CalendarScreen();
      },
    );
  }
}

