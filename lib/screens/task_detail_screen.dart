import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';

import '../widgets/shared_widgets.dart';
import 'apply_task_screen.dart';

class TaskDetailScreen extends StatefulWidget {
  final String taskId;
  const TaskDetailScreen({super.key, required this.taskId});

  @override
  State<TaskDetailScreen> createState() => _TaskDetailScreenState();
}

class _TaskDetailScreenState extends State<TaskDetailScreen> {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final task = db.getTask(widget.taskId);
    if (task == null) {
      return Scaffold(
        appBar: AppBar(title: const Text('Task')),
        body: const Center(child: Text('Task not found')),
      );
    }

    final user = db.currentUser;
    final isVolunteer = user?.role == UserRole.volunteer;
    final existingApp = isVolunteer ? db.getApplicationByUserAndTask(user!.id, task.id) : null;
    final catColor = AppConstants.categoryColors[task.category] ?? AppTheme.primary;
    final spotsLeft = task.volunteersNeeded - task.volunteersApplied;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          // Hero header
          SliverAppBar(
            expandedHeight: 220,
            pinned: true,
            backgroundColor: catColor,
            foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [catColor, catColor.withOpacity(0.7)]),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 40),
                      Text(task.imageEmoji, style: const TextStyle(fontSize: 64)),
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          task.category,
                          style: const TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.w700),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),

          SliverToBoxAdapter(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Title & status
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Expanded(
                        child: Text(
                          task.title,
                          style: TextStyle(
                            fontSize: 22,
                            fontWeight: FontWeight.w800,
                            color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkText : AppTheme.textPrimary,
                            letterSpacing: -0.4,
                          ),
                        ),
                      ),
                      const SizedBox(width: 12),
                      StatusBadge(status: task.status),
                    ],
                  ),
                  const SizedBox(height: 6),
                  Text(
                    task.organizationName,
                    style: const TextStyle(fontSize: 14, color: AppTheme.primary, fontWeight: FontWeight.w600),
                  ),

                  const SizedBox(height: 20),

                  // Info cards
                  _infoGrid(task),

                  const SizedBox(height: 20),

                  // Volunteer progress
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppTheme.divider),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            Text(
                              'Volunteer Spots',
                              style: TextStyle(
                                fontWeight: FontWeight.w700,
                                color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkText : AppTheme.textPrimary,
                              ),
                            ),
                            Text(
                              task.isFull ? '🔴 Full' : '🟢 $spotsLeft left',
                              style: TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: task.isFull ? AppTheme.danger : AppTheme.success),
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        ClipRRect(
                          borderRadius: BorderRadius.circular(6),
                          child: LinearProgressIndicator(
                            value: task.fillRate.clamp(0.0, 1.0),
                            backgroundColor: AppTheme.divider,
                            valueColor: AlwaysStoppedAnimation(task.isFull ? AppTheme.danger : catColor),
                            minHeight: 10,
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          '${task.volunteersApplied} of ${task.volunteersNeeded} volunteers',
                          style: TextStyle(
                            fontSize: 12,
                            color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSecondaryText : AppTheme.textSecondary,
                          ),
                        ),
                      ],
                    ),
                  ),

                  const SizedBox(height: 20),

                  // Description
                  Text(
                    'About this Task',
                    style: TextStyle(
                      fontSize: 17,
                      fontWeight: FontWeight.w700,
                      color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkText : AppTheme.textPrimary,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Text(
                    task.description,
                    style: TextStyle(
                      fontSize: 14,
                      color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSecondaryText : AppTheme.textSecondary,
                      height: 1.7,
                    ),
                  ),

                  if (task.requiredSkills.isNotEmpty) ...[
                    const SizedBox(height: 20),
                    Text(
                      'Required Skills',
                      style: TextStyle(
                        fontSize: 17,
                        fontWeight: FontWeight.w700,
                        color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkText : AppTheme.textPrimary,
                      ),
                    ),
                    const SizedBox(height: 10),
                    Wrap(spacing: 8, runSpacing: 8, children: task.requiredSkills.map((s) => SkillChip(skill: s, selected: true)).toList()),
                  ],

                  if (existingApp != null) ...[
                    const SizedBox(height: 20),
                    Container(
                      padding: const EdgeInsets.all(16),
                      decoration: BoxDecoration(
                        color: AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: AppTheme.primary.withOpacity(0.2)),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.check_circle, color: AppTheme.primary),
                          const SizedBox(width: 12),
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text(
                                'Application Submitted',
                                style: TextStyle(fontWeight: FontWeight.w700, color: AppTheme.primary),
                              ),
                              const SizedBox(height: 2),
                              AppStatusBadge(status: existingApp.status),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                  const SizedBox(height: 100),
                ],
              ),
            ),
          ),
        ],
      ),
      bottomNavigationBar: isVolunteer && task.status == TaskStatus.open && user?.id != task.organizationId
          ? SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: existingApp != null
                    ? Container(
                        padding: const EdgeInsets.all(16),
                        decoration: BoxDecoration(color: AppTheme.successLight, borderRadius: BorderRadius.circular(14)),
                        child: const Row(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check, color: AppTheme.success),
                            SizedBox(width: 8),
                            Text(
                              'Application Submitted',
                              style: TextStyle(color: AppTheme.success, fontWeight: FontWeight.w700),
                            ),
                          ],
                        ),
                      )
                    : ElevatedButton.icon(
                        onPressed: task.isFull
                            ? null
                            : () => Navigator.push(
                                context,
                                MaterialPageRoute(builder: (_) => ApplyTaskScreen(task: task)),
                              ).then((_) => setState(() {})),
                        icon: const Icon(Icons.send_outlined),
                        label: Text(task.isFull ? 'Task Full' : 'Apply to Volunteer'),
                        style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                      ),
              ),
            )
          : null,
    );
  }

  Widget _infoGrid(Task task) {
    return GridView.count(
      crossAxisCount: 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 2.4,
      children: [
        _infoTile(Icons.location_on_outlined, 'Location', task.location, AppTheme.danger),
        _infoTile(Icons.calendar_today_outlined, 'Date', DateFormat('MMM d, yyyy').format(task.date), AppTheme.primary),
        _infoTile(Icons.access_time_outlined, 'Duration', task.duration, AppTheme.success),
        _infoTile(Icons.category_outlined, 'Category', task.category, AppTheme.accent),
      ],
    );
  }

  Widget _infoTile(IconData icon, String label, String value, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
      decoration: BoxDecoration(
        color: color.withOpacity(0.07),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: color.withOpacity(0.15)),
      ),
      child: Row(
        children: [
          Icon(icon, size: 18, color: color),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label,
                  style: const TextStyle(fontSize: 10, color: AppTheme.textLight, fontWeight: FontWeight.w500),
                ),
                Text(
                  value,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkText : AppTheme.textPrimary,
                    fontWeight: FontWeight.w700,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
