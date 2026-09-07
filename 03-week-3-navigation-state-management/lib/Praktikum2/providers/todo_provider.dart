import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/todo.dart';

// 1. Notifier utama untuk mengelola daftar ToDo
class TodoNotifier extends Notifier<List<Todo>> {
  @override
  List<Todo> build() {
    return const [
      Todo(id: '1', title: 'Belajar Riverpod 2.x'),
      Todo(id: '2', title: 'Mengerjakan Refactoring Challenge', isCompleted: true),
    ];
  }

  void add(String title) {
    state = [
      ...state,
      Todo(id: DateTime.now().toString(), title: title),
    ];
  }

  void toggle(String id) {
    state = state.map((todo) {
      if (todo.id == id) {
        return todo.copyWith(isCompleted: !todo.isCompleted);
      }
      return todo;
    }).toList();
  }

  void remove(String id) {
    state = state.where((todo) => todo.id != id).toList();
  }
}

final todoListProvider =
    NotifierProvider<TodoNotifier, List<Todo>>(TodoNotifier.new);


// ================= PERUBAHAN DI SINI =================

// 2. Class Notifier baru pengganti StateProvider
class FilterNotifier extends Notifier<bool> {
  @override
  bool build() => false; // Default: false (tampilkan semua)

  // Method untuk mengubah status filter
  void setFilter(bool value) {
    state = value;
  }
}

// Provider untuk filter menggunakan NotifierProvider
final todoFilterProvider = 
    NotifierProvider<FilterNotifier, bool>(FilterNotifier.new);

// =====================================================


// 3. Provider turunan (Derived Provider) untuk menyaring ToDo
final filteredTodoListProvider = Provider<List<Todo>>((ref) {
  final todos = ref.watch(todoListProvider);
  final showOnlyUncompleted = ref.watch(todoFilterProvider);

  if (showOnlyUncompleted) {
    return todos.where((todo) => !todo.isCompleted).toList();
  }
  return todos;
});