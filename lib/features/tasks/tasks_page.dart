import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'tasks_controller.dart';

class TasksPage extends ConsumerStatefulWidget {
  const TasksPage({super.key});
  @override
  ConsumerState<TasksPage> createState() => _TasksPageState();
}

class _TasksPageState extends ConsumerState<TasksPage> {
  final _ctrl = TextEditingController();

  @override
  void dispose() { _ctrl.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final tasks = ref.watch(tasksProvider);
    final controller = ref.read(tasksProvider.notifier);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Tareas'),
        actions: [
          IconButton(
            tooltip: 'Borrar completadas',
            onPressed: controller.clearCompleted,
            icon: const Icon(Icons.clear_all),
          ),
        ],
      ),
      body: SafeArea(
        minimum: const EdgeInsets.all(16),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _ctrl,
                    decoration: const InputDecoration(
                      labelText: 'Nueva tarea',
                      border: OutlineInputBorder(),
                    ),
                    onSubmitted: (_) { controller.add(_ctrl.text); _ctrl.clear(); },
                  ),
                ),
                const SizedBox(width: 8),
                FilledButton(
                  onPressed: () { controller.add(_ctrl.text); _ctrl.clear(); },
                  child: const Text('Añadir'),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Expanded(
              child: tasks.isEmpty
                  ? const Center(child: Text('Sin tareas. Agrega una ↑'))
                  : ListView.builder(
                      itemCount: tasks.length,
                      itemBuilder: (context, i) {
                        final t = tasks[i];
                        return Dismissible(
                          key: ValueKey(t.id),
                          background: Container(color: Colors.red),
                          onDismissed: (_) => controller.remove(t.id),
                          child: CheckboxListTile(
                            value: t.done,
                            onChanged: (_) => controller.toggle(t.id),
                            title: Text(
                              t.title,
                              style: t.done
                                  ? const TextStyle(
                                      decoration: TextDecoration.lineThrough, color: Colors.grey)
                                  : null,
                            ),
                          ),
                        );
                      },
                    ),
            ),
          ],
        ),
      ),
    );
  }
}
