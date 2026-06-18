import 'dart:convert';
import 'package:hive_flutter/hive_flutter.dart';
import '../../../../core/repositories/interfaces.dart';
import '../models/todo.dart';

class HiveTodoRepository implements TodoRepository {
  static const _boxName = 'todos';
  static const _key = 'list';

  Future<Box> _getBox() => Hive.openBox(_boxName);

  @override
  Future<List<Map<String, dynamic>>> getAll() async {
    final box = await _getBox();
    final raw = box.get(_key, defaultValue: '[]') as String;
    final list = jsonDecode(raw) as List;
    return list.cast<Map<String, dynamic>>();
  }

  @override
  Future<void> add(Map<String, dynamic> todo) async {
    final items = await getAll();
    items.add(todo);
    await _save(items);
  }

  @override
  Future<void> update(String id, Map<String, dynamic> todo) async {
    final items = await getAll();
    final index = items.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      items[index] = todo;
      await _save(items);
    }
  }

  @override
  Future<void> delete(String id) async {
    final items = await getAll();
    items.removeWhere((t) => t['id'] == id);
    await _save(items);
  }

  @override
  Future<void> toggle(String id) async {
    final items = await getAll();
    final index = items.indexWhere((t) => t['id'] == id);
    if (index != -1) {
      final t = Todo.fromJson(items[index]);
      items[index] = t.copyWith(isCompleted: !t.isCompleted).toJson();
      await _save(items);
    }
  }

  Future<void> _save(List<Map<String, dynamic>> items) async {
    final box = await _getBox();
    await box.put(_key, jsonEncode(items));
  }
}
