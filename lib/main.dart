import 'package:flutter/material.dart';
import 'package:supabase_flutter/supabase_flutter.dart';
import 'app/app_router.dart';
import 'core/theme/app_theme.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Inicializar Supabase
  await Supabase.initialize(
    url: 'https://hztpemqwywpsbqxpcryv.supabase.co',
    anonKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6Imh6dHBlbXF3eXdwc2JxeHBjcnl2Iiwicm9sZSI6ImFub24iLCJpYXQiOjE3NjMwNDE0MzIsImV4cCI6MjA3ODYxNzQzMn0.QyHrDIwTDVlPlq6GE5AUQbpX6k6EPfCOEaVuo25UTqE',
  );

  // Login anónimo automático
  final supabase = Supabase.instance.client;

  final session = supabase.auth.currentSession;
  if (session == null) {
    await supabase.auth.signInAnonymously();
  }

  runApp(const GuitaApp());
}

class GuitaApp extends StatelessWidget {
  const GuitaApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
      debugShowCheckedModeBanner: false,
      title: 'Guita',
      theme: buildGuitaTheme(),
      routerConfig: appRouter, 
    );
  }
}
