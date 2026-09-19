import 'package:flutter/material.dart';
import '../models/task.dart';
import '../services/api_service.dart';
import 'login_screen.dart';

class TasksScreen extends StatefulWidget {
  const TasksScreen({super.key});

  @override
  State<TasksScreen> createState() => _TasksScreenState();
}

class _TasksScreenState extends State<TasksScreen> {
  List<Task> _tasks = [];
  bool _loading = true;
  String? _statusFilter;
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _loadTasks();
  }

  Future<void> _loadTasks() async {
    setState(() => _loading = true);
    try {
      final tasks = await ApiService.fetchTasks(
        status: _statusFilter,
        search: _searchController.text.trim(),
      );
      setState(() => _tasks = tasks);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
        );
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _openTaskForm({Task? task}) async {
    final titleController = TextEditingController(text: task?.title ?? '');
    final descController = TextEditingController(text: task?.description ?? '');
    TaskStatus status = task?.status ?? TaskStatus.TODO;

    await showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => Padding(
        padding: EdgeInsets.only(
          left: 16,
          right: 16,
          top: 16,
          bottom: MediaQuery.of(ctx).viewInsets.bottom + 16,
        ),
        child: StatefulBuilder(
          builder: (ctx, setModalState) => Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Text(task == null ? 'Nouvelle tâche' : 'Modifier la tâche',
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(height: 16),
              TextField(
                controller: titleController,
                decoration: const InputDecoration(labelText: 'Titre', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              TextField(
                controller: descController,
                maxLines: 3,
                decoration: const InputDecoration(labelText: 'Description', border: OutlineInputBorder()),
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<TaskStatus>(
                value: status,
                decoration: const InputDecoration(labelText: 'Statut', border: OutlineInputBorder()),
                items: const [
                  DropdownMenuItem(value: TaskStatus.TODO, child: Text('À faire')),
                  DropdownMenuItem(value: TaskStatus.IN_PROGRESS, child: Text('En cours')),
                  DropdownMenuItem(value: TaskStatus.DONE, child: Text('Terminée')),
                ],
                onChanged: (value) => setModalState(() => status = value ?? TaskStatus.TODO),
              ),
              const SizedBox(height: 20),
              ElevatedButton(
                onPressed: () async {
                  if (titleController.text.trim().isEmpty) return;
                  final newTask = Task(
                    id: task?.id ?? 0,
                    title: titleController.text.trim(),
                    description: descController.text.trim(),
                    status: status,
                    createdAt: task?.createdAt ?? '',
                    updatedAt: task?.updatedAt ?? '',
                  );
                  try {
                    if (task == null) {
                      await ApiService.createTask(newTask);
                    } else {
                      await ApiService.updateTask(task.id, newTask);
                    }
                    if (ctx.mounted) Navigator.pop(ctx);
                    _loadTasks();
                  } catch (e) {
                    if (ctx.mounted) {
                      ScaffoldMessenger.of(ctx).showSnackBar(
                        SnackBar(content: Text(e.toString().replaceFirst('Exception: ', ''))),
                      );
                    }
                  }
                },
                child: const Text('Enregistrer'),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Confirmer'),
        content: Text('Supprimer "${task.title}" ?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Annuler')),
          TextButton(onPressed: () => Navigator.pop(ctx, true), child: const Text('Supprimer')),
        ],
      ),
    );
    if (confirm == true) {
      await ApiService.deleteTask(task.id);
      _loadTasks();
    }
  }

  Color _statusColor(TaskStatus status) {
    switch (status) {
      case TaskStatus.TODO:
        return Colors.grey;
      case TaskStatus.IN_PROGRESS:
        return Colors.orange;
      case TaskStatus.DONE:
        return Colors.green;
    }
  }

  String _statusLabel(TaskStatus status) {
    switch (status) {
      case TaskStatus.TODO:
        return 'À faire';
      case TaskStatus.IN_PROGRESS:
        return 'En cours';
      case TaskStatus.DONE:
        return 'Terminée';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Mes tâches'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await ApiService.logout();
              if (!mounted) return;
              Navigator.of(context).pushReplacement(
                MaterialPageRoute(builder: (_) => const LoginScreen()),
              );
            },
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(12.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    decoration: const InputDecoration(
                      hintText: 'Rechercher...',
                      prefixIcon: Icon(Icons.search),
                      border: OutlineInputBorder(),
                      isDense: true,
                    ),
                    onSubmitted: (_) => _loadTasks(),
                  ),
                ),
                const SizedBox(width: 8),
                DropdownButton<String?>(
                  value: _statusFilter,
                  hint: const Text('Statut'),
                  items: const [
                    DropdownMenuItem(value: null, child: Text('Tous')),
                    DropdownMenuItem(value: 'TODO', child: Text('À faire')),
                    DropdownMenuItem(value: 'IN_PROGRESS', child: Text('En cours')),
                    DropdownMenuItem(value: 'DONE', child: Text('Terminée')),
                  ],
                  onChanged: (value) {
                    setState(() => _statusFilter = value);
                    _loadTasks();
                  },
                ),
              ],
            ),
          ),
          Expanded(
            child: _loading
                ? const Center(child: CircularProgressIndicator())
                : _tasks.isEmpty
                    ? const Center(child: Text('Aucune tâche trouvée.'))
                    : RefreshIndicator(
                        onRefresh: _loadTasks,
                        child: ListView.builder(
                          itemCount: _tasks.length,
                          itemBuilder: (ctx, index) {
                            final task = _tasks[index];
                            return Card(
                              margin: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                              child: ListTile(
                                title: Text(task.title),
                                subtitle: Text(task.description?.isNotEmpty == true
                                    ? task.description!
                                    : 'Sans description'),
                                leading: CircleAvatar(
                                  backgroundColor: _statusColor(task.status),
                                  child: Text(_statusLabel(task.status)[0],
                                      style: const TextStyle(color: Colors.white, fontSize: 12)),
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.edit, size: 20),
                                      onPressed: () => _openTaskForm(task: task),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.delete, size: 20, color: Colors.red),
                                      onPressed: () => _deleteTask(task),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () => _openTaskForm(),
        child: const Icon(Icons.add),
      ),
    );
  }
}
