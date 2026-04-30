import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';

import '../widgets/shared_widgets.dart';
import 'task_detail_screen.dart';

class MyApplicationsScreen extends StatefulWidget {
  const MyApplicationsScreen({super.key});

  @override
  State<MyApplicationsScreen> createState() => _MyApplicationsScreenState();
}

class _MyApplicationsScreenState extends State<MyApplicationsScreen>
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
    final apps = db.getApplicationsByUser(user.id);
    final pending = apps.where((a) => a.status == ApplicationStatus.pending).toList();
    final accepted = apps.where((a) => a.status == ApplicationStatus.accepted).toList();
    final rejected = apps.where((a) => a.status == ApplicationStatus.rejected).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: Column(
          children: [
            Container(
              color: Colors.white,
              padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Text('My Applications',
                      style: TextStyle(
                          fontSize: 22, fontWeight: FontWeight.w800,
                          color: AppTheme.textPrimary, letterSpacing: -0.3)),
                  const SizedBox(height: 4),
                  Text('${apps.length} total applications',
                      style: const TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                  const SizedBox(height: 16),

                  // Summary row
                  if (apps.isNotEmpty) ...[
                    Row(
                      children: [
                        _chip('${pending.length} Pending', AppTheme.warning),
                        const SizedBox(width: 8),
                        _chip('${accepted.length} Accepted', AppTheme.success),
                        const SizedBox(width: 8),
                        _chip('${rejected.length} Declined', AppTheme.danger),
                      ],
                    ),
                    const SizedBox(height: 16),
                  ],

                  TabBar(
                    controller: _tabs,
                    labelColor: AppTheme.primary,
                    unselectedLabelColor: AppTheme.textSecondary,
                    indicatorColor: AppTheme.primary,
                    dividerColor: AppTheme.divider,
                    tabs: [
                      Tab(text: 'Pending (${pending.length})'),
                      Tab(text: 'Accepted (${accepted.length})'),
                      Tab(text: 'All (${apps.length})'),
                    ],
                  ),
                ],
              ),
            ),
            Expanded(
              child: TabBarView(
                controller: _tabs,
                children: [
                  _appList(pending),
                  _appList(accepted),
                  _appList(apps),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _appList(List<TaskApplication> apps) {
    if (apps.isEmpty) {
      return EmptyState(
        emoji: '📭',
        title: 'Nothing Here',
        subtitle: 'Browse tasks and apply for volunteer opportunities!',
      );
    }
    return ListView.builder(
      padding: const EdgeInsets.all(16),
      itemCount: apps.length,
      itemBuilder: (_, i) {
        final app = apps[i];
        final task = db.getTask(app.taskId);
        if (task == null) return const SizedBox.shrink();
        final catColor = AppConstants.categoryColors[task.category] ?? AppTheme.primary;

        return GestureDetector(
          onTap: () => Navigator.push(context,
              MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: task.id)))
              .then((_) => setState(() {})),
          child: Container(
            margin: const EdgeInsets.only(bottom: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppTheme.divider),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Task info
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: catColor.withOpacity(0.06),
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
                  ),
                  child: Row(
                    children: [
                      Text(task.imageEmoji, style: const TextStyle(fontSize: 28)),
                      const SizedBox(width: 12),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(task.title,
                                style: const TextStyle(
                                    fontWeight: FontWeight.w700, fontSize: 14,
                                    color: AppTheme.textPrimary)),
                            const SizedBox(height: 2),
                            Text(task.organizationName,
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.primary,
                                    fontWeight: FontWeight.w600)),
                          ],
                        ),
                      ),
                      AppStatusBadge(status: app.status),
                    ],
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          const Icon(Icons.location_on_outlined, size: 13, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(task.location,
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                          const SizedBox(width: 12),
                          const Icon(Icons.calendar_today_outlined, size: 13, color: AppTheme.textLight),
                          const SizedBox(width: 4),
                          Text(DateFormat('MMM d, yyyy').format(task.date),
                              style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 10),
                      Container(
                        padding: const EdgeInsets.all(10),
                        decoration: BoxDecoration(
                          color: AppTheme.surface,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Icon(Icons.chat_bubble_outline, size: 14, color: AppTheme.textLight),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                app.message,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: const TextStyle(
                                    fontSize: 12, color: AppTheme.textSecondary, height: 1.4),
                              ),
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Row(
                            children: [
                              const Icon(Icons.schedule_outlined, size: 12, color: AppTheme.textLight),
                              const SizedBox(width: 4),
                              Text('Available: ${app.availability}',
                                  style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
                            ],
                          ),
                          Text(
                            'Applied ${DateFormat('MMM d').format(app.appliedAt)}',
                            style: const TextStyle(fontSize: 11, color: AppTheme.textLight),
                          ),
                        ],
                      ),
                      if (app.status == ApplicationStatus.accepted) ...[
                        const SizedBox(height: 10),
                        Container(
                          padding: const EdgeInsets.all(10),
                          decoration: BoxDecoration(
                            color: AppTheme.successLight,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Row(
                            children: [
                              Icon(Icons.celebration, color: AppTheme.success, size: 16),
                              SizedBox(width: 8),
                              Text('Congratulations! You\'ve been accepted.',
                                  style: TextStyle(
                                      fontSize: 12, color: AppTheme.success,
                                      fontWeight: FontWeight.w600)),
                            ],
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  Widget _chip(String label, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Text(label,
          style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700)),
    );
  }
}