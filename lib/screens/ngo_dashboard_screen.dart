import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';

import '../widgets/shared_widgets.dart';
import 'task_detail_screen.dart';
import 'create_task_screen.dart';
import 'applicants_screen.dart';

class NgoDashboardScreen extends StatefulWidget {
  const NgoDashboardScreen({super.key});

  @override
  State<NgoDashboardScreen> createState() => _NgoDashboardScreenState();
}

class _NgoDashboardScreenState extends State<NgoDashboardScreen>
    with SingleTickerProviderStateMixin {
  final db = DatabaseService();
  late TabController _tabs;

  @override
  void initState() {
    super.initState();
    _tabs = TabController(length: 3, vsync: this);
  }

  @override
  void dispose() {
    _tabs.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = db.currentUser!;
    final myTasks = db.getTasksByOrg(user.id);
    final openTasks = myTasks.where((t) => t.status == TaskStatus.open).toList();
    final completedTasks = myTasks.where((t) => t.status == TaskStatus.completed).toList();
    final totalApplicants = myTasks.fold<int>(0, (sum, t) {
      return sum + db.getApplicationsForTask(t.id).length;
    });

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: NestedScrollView(
          headerSliverBuilder: (_, __) => [
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Dashboard',
                                  style: TextStyle(
                                      fontSize: 22, fontWeight: FontWeight.w800,
                                      color: AppTheme.textPrimary, letterSpacing: -0.3)),
                              Text(user.orgName ?? user.name,
                                  style: const TextStyle(
                                      fontSize: 13, color: AppTheme.primary,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                        ElevatedButton.icon(
                          onPressed: () => Navigator.push(context,
                              MaterialPageRoute(builder: (_) => const CreateTaskScreen()))
                              .then((_) => setState(() {})),
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Post Task'),
                          style: ElevatedButton.styleFrom(
                            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    // Stats
                    Row(
                      children: [
                        Expanded(child: _statCard('${myTasks.length}', 'Total Tasks', Icons.task_alt, AppTheme.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: _statCard('${openTasks.length}', 'Open', Icons.pending_outlined, AppTheme.success)),
                        const SizedBox(width: 10),
                        Expanded(child: _statCard('$totalApplicants', 'Applicants', Icons.people_outline, AppTheme.accent)),
                      ],
                    ),
                    const SizedBox(height: 16),
                    TabBar(
                      controller: _tabs,
                      labelColor: AppTheme.primary,
                      unselectedLabelColor: AppTheme.textSecondary,
                      indicatorColor: AppTheme.primary,
                      indicatorSize: TabBarIndicatorSize.tab,
                      dividerColor: AppTheme.divider,
                      tabs: [
                        Tab(text: 'Open (${openTasks.length})'),
                        Tab(text: 'All (${myTasks.length})'),
                        Tab(text: 'Done (${completedTasks.length})'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ],
          body: TabBarView(
            controller: _tabs,
            children: [
              _taskList(openTasks),
              _taskList(myTasks),
              _taskList(completedTasks),
            ],
          ),
        ),
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()))
            .then((_) => setState(() {})),
        backgroundColor: AppTheme.primary,
        foregroundColor: Colors.white,
        icon: const Icon(Icons.add),
        label: const Text('Post Task', style: TextStyle(fontWeight: FontWeight.w700)),
      ),
    );
  }

  Widget _taskList(List<Task> tasks) {
    if (tasks.isEmpty) {
      return EmptyState(
        emoji: '📋',
        title: 'No Tasks Here',
        subtitle: 'Post your first volunteer task to get started.',
        buttonLabel: 'Post a Task',
        onButton: () => Navigator.push(context,
            MaterialPageRoute(builder: (_) => const CreateTaskScreen()))
            .then((_) => setState(() {})),
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: tasks.length,
      itemBuilder: (_, i) {
        final task = tasks[i];
        final apps = db.getApplicationsForTask(task.id);
        final pendingCount = apps.where((a) => a.status == ApplicationStatus.pending).length;

        return Container(
          margin: const EdgeInsets.only(bottom: 12),
          decoration: BoxDecoration(
            color: Colors.white,
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: AppTheme.divider),
          ),
          child: Column(
            children: [
              ListTile(
                contentPadding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
                leading: Text(task.imageEmoji, style: const TextStyle(fontSize: 32)),
                title: Text(task.title,
                    style: const TextStyle(fontWeight: FontWeight.w700, fontSize: 14)),
                subtitle: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const SizedBox(height: 4),
                    Row(
                      children: [
                        const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textLight),
                        const SizedBox(width: 3),
                        Text(task.location, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        const SizedBox(width: 10),
                        const Icon(Icons.calendar_today_outlined, size: 12, color: AppTheme.textLight),
                        const SizedBox(width: 3),
                        Text(DateFormat('MMM d').format(task.date),
                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                      ],
                    ),
                  ],
                ),
                trailing: StatusBadge(status: task.status),
                onTap: () => Navigator.push(context,
                    MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)))
                    .then((_) => setState(() {})),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 0, 16, 12),
                child: Row(
                  children: [
                    Expanded(
                      child: OutlinedButton.icon(
                        onPressed: () => Navigator.push(context,
                            MaterialPageRoute(builder: (_) => ApplicantsScreen(task: task)))
                            .then((_) => setState(() {})),
                        icon: const Icon(Icons.people_outline, size: 16),
                        label: Text(
                          '${apps.length} Applicants${pendingCount > 0 ? ' · $pendingCount new' : ''}',
                          style: const TextStyle(fontSize: 12),
                        ),
                        style: OutlinedButton.styleFrom(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          foregroundColor: pendingCount > 0 ? AppTheme.accent : AppTheme.primary,
                          side: BorderSide(
                              color: pendingCount > 0 ? AppTheme.accent : AppTheme.primary),
                        ),
                      ),
                    ),
                    const SizedBox(width: 8),
                    if (task.status == TaskStatus.open)
                      IconButton(
                        onPressed: () => _markCompleted(task),
                        icon: const Icon(Icons.check_circle_outline, color: AppTheme.success),
                        tooltip: 'Mark as completed',
                      ),
                    IconButton(
                      onPressed: () => _deleteTask(task),
                      icon: const Icon(Icons.delete_outline, color: AppTheme.danger),
                      tooltip: 'Delete task',
                    ),
                  ],
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _markCompleted(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Mark as Completed?'),
        content: Text('Are you sure you want to mark "${task.title}" as completed?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(onPressed: () => Navigator.pop(context, true), child: const Text('Confirm')),
        ],
      ),
    );
    if (confirm == true) {
      await db.updateTask(task.copyWith(status: TaskStatus.completed));
      setState(() {});
    }
  }

  Future<void> _deleteTask(Task task) async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Delete Task?'),
        content: Text('This will permanently delete "${task.title}" and all its applications.'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirm == true) {
      await db.deleteTask(task.id);
      setState(() {});
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Task deleted')));
      }
    }
  }

  Widget _statCard(String value, String label, IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: color.withOpacity(0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(icon, color: color, size: 20),
          const SizedBox(height: 8),
          Text(value,
              style: TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: color)),
          Text(label,
              style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary,
                  fontWeight: FontWeight.w500)),
        ],
      ),
    );
  }
}