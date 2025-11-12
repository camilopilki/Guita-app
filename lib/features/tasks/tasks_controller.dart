import 'package:flutter_riverpod/flutter_riverpod.dart';

class Task {
  final String id;
  final String title;
  final bool done;
  Task({required this.id, required this.title, this.done = false});

  Task copyWith({String? id, String? title, bool? done}) =>
      Task(id: id ?? this.id, title: title ?? this.title, done: done ?? this.done);
}

// v3: Notifier en lugar de StateNotifier
class TasksController extends Notifier<List<Task>> {
  @override
  List<Task> build() => const []; // estado inicial

  void add(String title) {
    final t = title.trim();
    if (t.isEmpty) return;
    state = [...state, Task(id: DateTime.now().millisecondsSinceEpoch.toString(), title: t)];
  }

  void toggle(String id) {
    state = [
      for (final x in state) x.id == id ? x.copyWith(done: !x.done) : x,
    ];
  }

  void remove(String id) {
    state = state.where((x) => x.id != id).toList();
  }

  void clearCompleted() {
    state = state.where((x) => !x.done).toList();
  }
}

// v3: NotifierProvider en lugar de StateNotifierProvider
final tasksProvider =
    NotifierProvider<TasksController, List<Task>>(TasksController.new);
