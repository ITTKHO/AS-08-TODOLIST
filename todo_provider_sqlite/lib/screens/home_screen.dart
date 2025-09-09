import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../models/todo.dart';
import '../providers/todo_provider.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final _searchCtrl = TextEditingController();

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  Color _priorityColor(int p) {
    switch (p) {
      case 1: return Colors.red;
      case 2: return Colors.orange;
      default: return Colors.green;
    }
  }

  String _priorityLabel(int p) {
    switch (p) {
      case 1: return 'High';
      case 2: return 'Medium';
      default: return 'Low';
    }
  }

  Future<void> _openEditor({Todo? todo}) async {
    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      showDragHandle: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
          left: 16, right: 16, top: 8,
        ),
        child: _TodoEditor(todo: todo),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final p = context.watch<TodoProvider>();

    return Scaffold(
appBar: AppBar(
  title: const Text('To-Do LIST DON'),
  actions: [
    IconButton(
      tooltip: 'รีโหลด',
      onPressed: () => p.loadTodos(),
      icon: const Icon(Icons.refresh),
    ),
    IconButton(
      tooltip: 'ลบทั้งหมด',
      icon: const Icon(Icons.delete_forever),
      onPressed: p.items.isEmpty
          ? null
          : () async {
              final confirm = await showDialog<bool>(
                context: context,
                builder: (_) => AlertDialog(
                  title: const Text('ลบงานทั้งหมด?'),
                  content: const Text('คุณต้องการลบทุกงานออกจากลิสต์หรือไม่?'),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context, false),
                      child: const Text('ยกเลิก'),
                    ),
                    FilledButton(
                      onPressed: () => Navigator.pop(context, true),
                      child: const Text('ลบทั้งหมด'),
                    ),
                  ],
                ),
              );
              if (confirm == true) {
                await context.read<TodoProvider>().clearAll();
              }
            },
    ),
          PopupMenuButton(
            tooltip: 'เรียงตาม',
            icon: const Icon(Icons.sort),
            onSelected: (value) =>
                p.setSort(value as SortBy),
            itemBuilder: (ctx) => const [
              PopupMenuItem(value: SortBy.created, child: Text('ล่าสุดสร้าง')),
              PopupMenuItem(value: SortBy.dueDate, child: Text('กำหนดส่งใกล้สุด')),
              PopupMenuItem(value: SortBy.priority, child: Text('ความสำคัญ')),
            ],
          ),
        ],
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(60),
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
            child: TextField(
              controller: _searchCtrl,
              onChanged: p.setQuery,
              decoration: InputDecoration(
                hintText: 'ค้นหาชื่องาน/รายละเอียด...',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: p.query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchCtrl.clear();
                          p.setQuery('');
                        },
                      ),
                border: const OutlineInputBorder(),
                isDense: true,
              ),
            ),
          ),
        ),
      ),
      body: Column(
        children: [
          // สรุป & ตัวกรอง
          Card(
            margin: const EdgeInsets.fromLTRB(12, 12, 12, 4),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Wrap(
                spacing: 8, runSpacing: 4, crossAxisAlignment: WrapCrossAlignment.center,
                children: [
                  Chip(
                    avatar: const Icon(Icons.list_alt, size: 18),
                    label: Text('ทั้งหมด ${p.total}'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.radio_button_unchecked, size: 18),
                    label: Text('ค้าง ${p.activeCount}'),
                  ),
                  Chip(
                    avatar: const Icon(Icons.check_circle, size: 18),
                    label: Text('เสร็จ ${p.doneCount}'),
                  ),
                  const SizedBox(width: 8),
                  FilterChip(
                    selected: p.filter == Filter.all,
                    label: const Text('ทั้งหมด'),
                    onSelected: (_) => p.setFilter(Filter.all),
                  ),
                  FilterChip(
                    selected: p.filter == Filter.active,
                    label: const Text('ค้าง'),
                    onSelected: (_) => p.setFilter(Filter.active),
                  ),
                  FilterChip(
                    selected: p.filter == Filter.done,
                    label: const Text('เสร็จ'),
                    onSelected: (_) => p.setFilter(Filter.done),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: p.isLoading
                ? const Center(child: CircularProgressIndicator())
                : p.items.isEmpty
                    ? const Center(child: Text('ไม่มีงานที่ตรงเงื่อนไข'))
                    : ListView.separated(
                        padding: const EdgeInsets.fromLTRB(12, 8, 12, 100),
                        itemCount: p.items.length,
                        separatorBuilder: (_, __) => const SizedBox(height: 8),
                        itemBuilder: (ctx, i) {
                          final t = p.items[i];
                          final fmt = DateFormat('dd/MM/yyyy');
                          return Dismissible(
                            key: ValueKey(t.id ?? '${t.title}-$i'),
                            direction: DismissDirection.endToStart,
                            background: Container(
                              alignment: Alignment.centerRight,
                              padding: const EdgeInsets.symmetric(horizontal: 20),
                              decoration: BoxDecoration(
                                color: Colors.red.shade400,
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: const Icon(Icons.delete, color: Colors.white),
                            ),
                            confirmDismiss: (_) async {
                              return await showDialog<bool>(
                                context: context,
                                builder: (_) => AlertDialog(
                                  title: const Text('ลบงานนี้หรือไม่?'),
                                  content: Text(t.title),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.pop(context, false),
                                      child: const Text('ยกเลิก'),
                                    ),
                                    FilledButton(
                                      onPressed: () => Navigator.pop(context, true),
                                      child: const Text('ลบ'),
                                    ),
                                  ],
                                ),
                              ) ?? false;
                            },
                            onDismissed: (_) => context.read<TodoProvider>().deleteTodo(t),
                            child: Card(
                              elevation: 1,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(12),
                              ),
                              child: ListTile(
                                onTap: () => context.read<TodoProvider>().toggleDone(t),
                                onLongPress: () => _openEditor(todo: t),
                                leading: Checkbox(
                                  value: t.isDone,
                                  onChanged: (_) => context.read<TodoProvider>().toggleDone(t),
                                ),
                                title: Text(
                                  t.title,
                                  maxLines: 1,
                                  overflow: TextOverflow.ellipsis,
                                  style: TextStyle(
                                    decoration: t.isDone ? TextDecoration.lineThrough : null,
                                    color: t.isDone ? Colors.grey : null,
                                    fontWeight: FontWeight.w600,
                                  ),
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    if ((t.description ?? '').isNotEmpty)
                                      Text(
                                        t.description!,
                                        maxLines: 2,
                                        overflow: TextOverflow.ellipsis,
                                      ),
                                    Row(
                                      children: [
                                        if (t.dueDate != null) ...[
                                          const Icon(Icons.event, size: 16),
                                          const SizedBox(width: 4),
                                          Text(DateFormat('dd MMM yyyy').format(t.dueDate!)),
                                          const SizedBox(width: 12),
                                        ],
                                        Icon(Icons.flag, size: 16, color: _priorityColor(t.priority)),
                                        const SizedBox(width: 4),
                                        Text(_priorityLabel(t.priority)),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: IconButton(
                                  tooltip: 'แก้ไข',
                                  icon: const Icon(Icons.edit),
                                  onPressed: () => _openEditor(todo: t),
                                ),
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _openEditor(),
        icon: const Icon(Icons.add),
        label: const Text('เพิ่มงาน'),
      ),
    );
  }
}

class _TodoEditor extends StatefulWidget {
  final Todo? todo;
  const _TodoEditor({this.todo});
  @override
  State<_TodoEditor> createState() => _TodoEditorState();
}

class _TodoEditorState extends State<_TodoEditor> {
  final _title = TextEditingController();
  final _desc = TextEditingController();
  DateTime? _due;
  int _priority = 2;

  @override
  void initState() {
    super.initState();
    final t = widget.todo;
    if (t != null) {
      _title.text = t.title;
      _desc.text = t.description ?? '';
      _due = t.dueDate;
      _priority = t.priority;
    }
  }

  @override
  void dispose() {
    _title.dispose();
    _desc.dispose();
    super.dispose();
  }

  Future<void> _pickDueDate() async {
    final now = DateTime.now();
    final d = await showDatePicker(
      context: context,
      firstDate: DateTime(now.year - 2),
      lastDate: DateTime(now.year + 5),
      initialDate: _due ?? now,
    );
    if (!mounted) return;
    setState(() => _due = d);
  }

  @override
  Widget build(BuildContext context) {
    final isEdit = widget.todo != null;
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(isEdit ? 'แก้ไขงาน' : 'เพิ่มงานใหม่', style: Theme.of(context).textTheme.titleLarge),
        const SizedBox(height: 12),
        TextField(
          controller: _title,
          textInputAction: TextInputAction.next,
          decoration: const InputDecoration(
            labelText: 'ชื่องาน *',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        TextField(
          controller: _desc,
          maxLines: 3,
          decoration: const InputDecoration(
            labelText: 'รายละเอียด',
            border: OutlineInputBorder(),
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: DropdownButtonFormField<int>(
                value: _priority,
                decoration: const InputDecoration(
                  labelText: 'ความสำคัญ',
                  border: OutlineInputBorder(),
                ),
                items: const [
                  DropdownMenuItem(value: 1, child: Text('High')),
                  DropdownMenuItem(value: 2, child: Text('Medium')),
                  DropdownMenuItem(value: 3, child: Text('Low')),
                ],
                onChanged: (v) => setState(() => _priority = v ?? 2),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: InkWell(
                onTap: _pickDueDate,
                child: InputDecorator(
                  decoration: const InputDecoration(
                    labelText: 'กำหนดส่ง',
                    border: OutlineInputBorder(),
                  ),
                  child: Text(
                    _due == null ? '—' : DateFormat('dd/MM/yyyy').format(_due!),
                  ),
                ),
              ),
            ),
          ],
        ),
        const SizedBox(height: 16),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('ยกเลิก'),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton.icon(
                icon: const Icon(Icons.save),
                label: const Text('บันทึก'),
                onPressed: () async {
                  final title = _title.text.trim();
                  if (title.isEmpty) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('กรุณากรอกชื่องาน')),
                    );
                    return;
                  }
                  if (widget.todo == null) {
                    await context.read<TodoProvider>().addTodo(
                      title: title,
                      description: _desc.text,
                      dueDate: _due,
                      priority: _priority,
                    );
                  } else {
                    await context.read<TodoProvider>().editTodo(
                          widget.todo!,
                          title: title,
                          description: _desc.text,
                          dueDate: _due,
                          priority: _priority,
                        );
                  }
                  if (mounted) Navigator.pop(context);
                },
              ),
            ),
          ],
        ),
        const SizedBox(height: 8),
      ],
    );
  }
}
