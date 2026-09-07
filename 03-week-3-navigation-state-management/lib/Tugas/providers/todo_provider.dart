import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

class TodoNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return const [
      Todo(
        id: '1',
        title: 'Belajar Riverpod 2.x',
      ),
      Todo(
        id: '2',
        title: 'Mengerjakan Refactoring Challenge',
        isCompleted: true,
      ),
    ];
  }

  void add(String title) {
    state = [
      ...state,
      Todo(
        id: DateTime.now().toString(),
        title: title,
      ),
    ];
  }

  void toggle(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(
          isCompleted: !todo.isCompleted,
        );
      }
      return todo;
    }).toList();
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

final todoListProvider =
    NotifierProvider<TodoNotifier, List<Todo>>(
  TodoNotifier.new,
);

class FilterNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setFilter(bool value) {
    state = value;
  }
}

final todoFilterProvider =
    NotifierProvider<FilterNotifier, bool>(
  FilterNotifier.new,
);

final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final showOnlyUncompleted = ref.watch(todoFilterProvider);

  if (showOnlyUncompleted) {
    return todos.where((todo) => !todo.isCompleted).toList();
  }

  return todos;
});


class AsyncErrorNotifier extends Notifier<bool> {
  @override
  bool build() => false;

  void setError(bool value) {
    state = value;
  }
}

final asyncErrorProvider =
    NotifierProvider<AsyncErrorNotifier, bool>(
  AsyncErrorNotifier.new,
);

final todoAsyncProvider = FutureProvider<List<Todo>>((ref) async {
  final todos = ref.watch(todoListProvider);
  final showError = ref.watch(asyncErrorProvider);

  // Simulasi proses asynchronous
  await Future.delayed(
    const Duration(seconds: 1),
  );

  if (showError) {
    throw Exception('Gagal memuat data tugas');
  }

  return todos;
});