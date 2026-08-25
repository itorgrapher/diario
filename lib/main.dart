import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_state.dart';
import 'theme.dart';
import 'screens/login_screen.dart';
import 'screens/onboarding_screen.dart';
import 'screens/calendar_screen.dart';
import 'screens/new_entry_screen.dart';
import 'screens/entry_detail_screen.dart';
import 'screens/tracking_screen.dart';
import 'screens/fields_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/dreams_screen.dart';
import 'screens/books_screen.dart';
import 'screens/cycle_screen.dart';
import 'screens/burn_screen.dart';

void main() {
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
      initialRoute: '/login',
      routes: {
        '/login': (_) => const LoginScreen(),
        '/onboarding': (_) => const OnboardingScreen(),
        '/calendar': (_) => const CalendarScreen(),
        '/new-entry': (_) => const NewEntryScreen(),
        '/entry-detail': (_) => const EntryDetailScreen(),
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
