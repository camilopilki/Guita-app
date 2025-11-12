import 'package:flutter/material.dart';
import 'app/app_router.dart';
import 'core/theme/app_theme.dart';

void main() => runApp(const GuitaApp());

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
