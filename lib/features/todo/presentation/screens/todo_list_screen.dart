import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../../core/di/injection.dart';
import '../../../../core/widgets/app_card.dart';
import '../../../../core/widgets/loading_widget.dart';
import '../../../../core/widgets/empty_widget.dart';
import '../../data/models/todo.dart';

class TodoListScreen extends StatefulWidget {
  const TodoListScreen({super.key});

  @override
  State<TodoListScreen> createState() => _TodoListScreenState();
}

class _TodoListScreenState extends State<TodoListScreen> {
  String _filter = 'all';
  String _sortBy = 'createdAt';

  @override
  void initState() {
    super.initState();
    sl<TodoBloc>().add(LoadTodosEvent());
  }

  List<Todo> _applyFilter(List<Todo> todos) {
    var filtered = List<Todo>.from(todos);
    if (_filter == 'active') filtered = filtered.where((t) => !t.isCompleted).toList();
    if (_filter == 'completed') filtered = filtered.where((t) => t.isCompleted).toList();
    if (_filter == 'high') filtered = filtered.where((t) => t.priority == 'high').toList();
    if (_filter == 'due') {
      filtered = filtered.where((t) => t.dueDate != null && !t.isCompleted).toList();
      filtered.sort((a, b) => a.dueDate!.compareTo(b.dueDate!));
      return filtered;
    }
    switch (_sortBy) {
      case 'title':
        filtered.sort((a, b) => a.title.compareTo(b.title));
      case 'dueDate':
        filtered.sort((a, b) {
          if (a.dueDate == null && b.dueDate == null) return 0;
          if (a.dueDate == null) return 1;
          if (b.dueDate == null) return -1;
          return a.dueDate!.compareTo(b.dueDate!);
        });
      default:
        filtered.sort((a, b) => b.updatedAt.compareTo(a.updatedAt));
    }
    return filtered;
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider<TodoBloc>.value(
      value: sl<TodoBloc>(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Todos'),
          actions: [
            PopupMenuButton<String>(
              icon: const Icon(Icons.sort),
              tooltip: 'Sort by',
              onSelected: (v) => setState(() => _sortBy = v),
              itemBuilder: (_) => [
                CheckedPopupMenuItem(value: 'createdAt', checked: _sortBy == 'createdAt', child: const Text('Recent')),
                CheckedPopupMenuItem(value: 'title', checked: _sortBy == 'title', child: const Text('Title')),
                CheckedPopupMenuItem(value: 'dueDate', checked: _sortBy == 'dueDate', child: const Text('Due Date')),
              ],
            ),
          ],
        ),
        body: BlocBuilder<TodoBloc, TodoState>(
          builder: (context, state) {
            if (state.isLoading) return const LoadingWidget(fullScreen: true);
            final filtered = _applyFilter(state.todos.cast<Todo>().toList());
            return Column(children: [
              _buildFilterBar(),
              if (state.error != null)
                Padding(
                  padding: const EdgeInsets.all(8),
                  child: Text(state.error!, style: TextStyle(color: Colors.red[700], fontSize: 13)),
                ),
              Expanded(
                child: filtered.isEmpty
                    ? const AppEmptyWidget(message: 'No todos yet', icon: Icons.checklist)
                    : RefreshIndicator(
                        onRefresh: () async => sl<TodoBloc>().add(LoadTodosEvent()),
                        child: ListView.builder(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          itemCount: filtered.length,
                          itemBuilder: (context, i) => _buildTodoCard(filtered[i], i),
                        ),
                      ),
              ),
            ]);
          },
        ),
        floatingActionButton: FloatingActionButton(
          onPressed: () => _showTodoDialog(),
          child: const Icon(Icons.add),
        ),
      ),
    );
  }

  Widget _buildFilterBar() {
    final filters = ['all', 'active', 'completed', 'high', 'due'];
    final labels = ['All', 'Active', 'Done', 'High', 'Due'];
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: SingleChildScrollView(
        scrollDirection: Axis.horizontal,
        child: Row(children: List.generate(filters.length, (i) {
          final isActive = _filter == filters[i];
          return Padding(
            padding: const EdgeInsets.only(right: 8),
            child: FilterChip(
              label: Text(labels[i], style: TextStyle(fontSize: 12, color: isActive ? Colors.white : null)),
              selected: isActive,
              onSelected: (_) => setState(() => _filter = filters[i]),
              selectedColor: Theme.of(context).primaryColor,
              checkmarkColor: Colors.white,
              visualDensity: VisualDensity.compact,
              materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
            ),
          );
        })),
      ),
    );
  }

  Widget _buildTodoCard(Todo todo, int index) {
    final now = DateTime.now();
    final isOverdue = todo.dueDate != null && todo.dueDate!.isBefore(now) && !todo.isCompleted;
    final dueToday = todo.dueDate != null &&
        todo.dueDate!.day == now.day &&
        todo.dueDate!.month == now.month &&
        todo.dueDate!.year == now.year &&
        !todo.isCompleted;

    final priorityColors = {'low': Colors.grey, 'medium': Colors.orange, 'high': Colors.red};
    final priorityColor = priorityColors[todo.priority] ?? Colors.grey;
    final categoryColors = {
      'General': Colors.blue,
      'Follow-up': Colors.teal,
      'Meeting': Colors.purple,
      'Task': Colors.indigo,
    };
    final categoryColor = categoryColors[todo.category] ?? Colors.blueGrey;

    return AppCard(
      margin: const EdgeInsets.only(bottom: 8),
      child: InkWell(
        borderRadius: BorderRadius.circular(12),
        onTap: () => _showTodoDialog(todo: todo),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 4),
          child: Row(children: [
            Checkbox(
              value: todo.isCompleted,
              onChanged: (_) => sl<TodoBloc>().add(ToggleTodoEvent(todo.id)),
              shape: const CircleBorder(),
              activeColor: Colors.green,
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(color: categoryColor.withValues(alpha: 0.15), borderRadius: BorderRadius.circular(4)),
                    child: Text(todo.category, style: TextStyle(fontSize: 10, color: categoryColor, fontWeight: FontWeight.w500)),
                  ),
                  const SizedBox(width: 6),
                  Container(
                    width: 8, height: 8,
                    decoration: BoxDecoration(color: priorityColor, shape: BoxShape.circle),
                  ),
                  if (isOverdue) ...[
                    const SizedBox(width: 6),
                    Text('Overdue', style: TextStyle(fontSize: 10, color: Colors.red[700], fontWeight: FontWeight.w500)),
                  ],
                  if (dueToday && !isOverdue) ...[
                    const SizedBox(width: 6),
                    Text('Today', style: TextStyle(fontSize: 10, color: Colors.orange[700], fontWeight: FontWeight.w500)),
                  ],
                ]),
                const SizedBox(height: 4),
                Text(
                  todo.title,
                  style: Theme.of(context).textTheme.titleMedium?.copyWith(
                        decoration: todo.isCompleted ? TextDecoration.lineThrough : null,
                        color: todo.isCompleted ? Colors.grey : null,
                      ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                if (todo.description.isNotEmpty) ...[
                  const SizedBox(height: 2),
                  Text(todo.description, style: Theme.of(context).textTheme.bodySmall?.copyWith(color: Colors.grey[600]), maxLines: 1, overflow: TextOverflow.ellipsis),
                ],
                if (todo.dueDate != null) ...[
                  const SizedBox(height: 2),
                  Row(children: [
                    Icon(Icons.access_time, size: 12, color: isOverdue ? Colors.red : Colors.grey[500]),
                    const SizedBox(width: 4),
                    Text(
                      '${todo.dueDate!.day.toString().padLeft(2, '0')}/${todo.dueDate!.month.toString().padLeft(2, '0')}/${todo.dueDate!.year}',
                      style: TextStyle(fontSize: 11, color: isOverdue ? Colors.red[700] : Colors.grey[500]),
                    ),
                  ]),
                ],
              ]),
            ),
            PopupMenuButton<String>(
              icon: const Icon(Icons.more_vert, size: 18),
              onSelected: (v) {
                if (v == 'edit') _showTodoDialog(todo: todo);
                if (v == 'delete') _confirmDelete(todo);
              },
              itemBuilder: (_) => [
                const PopupMenuItem(value: 'edit', child: ListTile(leading: Icon(Icons.edit, size: 18), title: Text('Edit', style: TextStyle(fontSize: 14)), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
                const PopupMenuItem(value: 'delete', child: ListTile(leading: Icon(Icons.delete, size: 18, color: Colors.red), title: Text('Delete', style: TextStyle(fontSize: 14, color: Colors.red)), dense: true, visualDensity: VisualDensity.compact, contentPadding: EdgeInsets.zero)),
              ],
            ),
          ]),
        ),
      ),
    );
  }

  Future<void> _confirmDelete(Todo todo) async {
    final ok = await showDialog<bool>(context: context, builder: (ctx) => AlertDialog(
      title: const Text('Delete Todo'),
      content: Text('Delete "${todo.title}"?'),
      actions: [
        TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Cancel')),
        ElevatedButton(onPressed: () => Navigator.pop(ctx, true), style: ElevatedButton.styleFrom(backgroundColor: Colors.red), child: const Text('Delete')),
      ],
    ));
    if (ok == true) sl<TodoBloc>().add(DeleteTodoEvent(todo.id));
  }

  Future<void> _showTodoDialog({Todo? todo}) async {
    final titleCtrl = TextEditingController(text: todo?.title ?? '');
    final descCtrl = TextEditingController(text: todo?.description ?? '');
    final isNew = todo == null;
    var priority = todo?.priority ?? 'medium';
    var category = todo?.category ?? 'General';
    DateTime? dueDate = todo?.dueDate;

    await showModalBottomSheet<bool>(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) => StatefulBuilder(builder: (ctx, setSheetState) {
        return Padding(
          padding: EdgeInsets.only(bottom: MediaQuery.of(ctx).viewInsets.bottom),
          child: SingleChildScrollView(
            padding: const EdgeInsets.fromLTRB(24, 12, 24, 24),
            child: Column(mainAxisSize: MainAxisSize.min, crossAxisAlignment: CrossAxisAlignment.start, children: [
              Center(child: Container(width: 40, height: 4, decoration: BoxDecoration(color: Colors.grey[300], borderRadius: BorderRadius.circular(2)))),
              const SizedBox(height: 20),
              Text(isNew ? 'New Todo' : 'Edit Todo', style: Theme.of(context).textTheme.titleLarge),
              const SizedBox(height: 16),
              TextField(controller: titleCtrl, decoration: const InputDecoration(labelText: 'Title'), autofocus: true),
              const SizedBox(height: 12),
              TextField(controller: descCtrl, decoration: const InputDecoration(labelText: 'Description'), maxLines: 3),
              const SizedBox(height: 16),
              Text('Priority', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Row(children: [
                _priorityChip(ctx, 'low', 'Low', priority, setSheetState, (v) => priority = v),
                const SizedBox(width: 8),
                _priorityChip(ctx, 'medium', 'Medium', priority, setSheetState, (v) => priority = v),
                const SizedBox(width: 8),
                _priorityChip(ctx, 'high', 'High', priority, setSheetState, (v) => priority = v),
              ]),
              const SizedBox(height: 16),
              Text('Category', style: Theme.of(ctx).textTheme.titleMedium),
              const SizedBox(height: 8),
              Wrap(spacing: 8, runSpacing: 4, children: ['General', 'Follow-up', 'Meeting', 'Task'].map((c) =>
                ChoiceChip(label: Text(c, style: TextStyle(fontSize: 12, color: category == c ? Colors.white : null)),
                  selected: category == c, onSelected: (_) => setSheetState(() => category = c),
                  selectedColor: Theme.of(ctx).primaryColor,
                  visualDensity: VisualDensity.compact,
                  materialTapTargetSize: MaterialTapTargetSize.shrinkWrap,
                ),
              ).toList()),
              const SizedBox(height: 16),
              Row(children: [
                Expanded(
                  child: InkWell(
                    onTap: () async {
                      final picked = await showDatePicker(context: ctx, initialDate: dueDate ?? DateTime.now(), firstDate: DateTime(2020), lastDate: DateTime(2030));
                      if (picked != null) setSheetState(() => dueDate = picked);
                    },
                    child: InputDecorator(
                      decoration: const InputDecoration(labelText: 'Due Date', prefixIcon: Icon(Icons.calendar_today, size: 18), isDense: true, contentPadding: EdgeInsets.symmetric(horizontal: 8, vertical: 12)),
                      child: Text(dueDate != null ? '${dueDate!.day}/${dueDate!.month}/${dueDate!.year}' : 'Not set', style: Theme.of(ctx).textTheme.bodyMedium),
                    ),
                  ),
                ),
                if (dueDate != null) ...[
                  const SizedBox(width: 8),
                  IconButton(icon: const Icon(Icons.clear, size: 18), onPressed: () => setSheetState(() => dueDate = null)),
                ],
              ]),
              const SizedBox(height: 24),
              SizedBox(width: double.infinity, height: 50, child: ElevatedButton(
                onPressed: () {
                  if (titleCtrl.text.trim().isEmpty) return;
                  if (isNew) {
                    sl<TodoBloc>().add(AddTodoEvent(Todo(
                      id: DateTime.now().millisecondsSinceEpoch.toString(),
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      priority: priority,
                      category: category,
                      dueDate: dueDate,
                    )));
                  } else {
                    sl<TodoBloc>().add(UpdateTodoEvent(todo.copyWith(
                      title: titleCtrl.text.trim(),
                      description: descCtrl.text.trim(),
                      priority: priority,
                      category: category,
                      dueDate: dueDate,
                    )));
                  }
                  Navigator.pop(ctx, true);
                },
                child: Text(isNew ? 'Add Todo' : 'Update', style: const TextStyle(fontSize: 16)),
              )),
            ]),
          ),
        );
      }),
    );
    titleCtrl.dispose();
    descCtrl.dispose();
  }

  Widget _priorityChip(BuildContext ctx, String value, String label, String current, StateSetter setSheetState, Function(String) onChanged) {
    final colors = {'low': Colors.grey, 'medium': Colors.orange, 'high': Colors.red};
    return ChoiceChip(
      label: Text(label, style: TextStyle(fontSize: 12)),
      selected: current == value,
      selectedColor: colors[value]?.withValues(alpha: 0.2),
      onSelected: (_) => setSheetState(() => onChanged(value)),
      visualDensity: VisualDensity.compact,
    );
  }
}
