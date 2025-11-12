import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

class HomePage extends StatelessWidget {
  const HomePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Inicio')),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('Base Flutter lista 👌'),
            const SizedBox(height: 12),
            FilledButton.tonal(
              onPressed: () => context.go('/tasks'),
              child: const Text('Ir a Tareas (demo estado)'),
            ),
          ],
        ),
      ),
    );
  }
}
