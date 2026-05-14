import 'package:flutter/material.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import 'package:intl/intl.dart';

class TaskCard extends StatelessWidget {
  final Task task;
  final VoidCallback onTap;

  final bool isFavorite;
  final VoidCallback onFavoriteToggle;

  const TaskCard({super.key, required this.task, required this.onTap, required this.isFavorite, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    final catColor = AppConstants.categoryColors[task.category] ?? AppTheme.primary;

    final spotsLeft = task.volunteersNeeded - task.volunteersApplied;

    return GestureDetector(
      onTap: onTap,

      child: Container(
        margin: const EdgeInsets.only(bottom: 12),

        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,

          borderRadius: BorderRadius.circular(16),

          border: Border.all(color: AppTheme.divider),

          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.04), blurRadius: 8, offset: const Offset(0, 2))],
        ),

        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,

          children: [
            // HEADER
            Container(
              padding: const EdgeInsets.all(16),

              decoration: BoxDecoration(
                color: catColor.withOpacity(0.06),

                borderRadius: const BorderRadius.vertical(top: Radius.circular(16)),
              ),

              child: Row(
                children: [
                  Text(task.imageEmoji, style: const TextStyle(fontSize: 32)),

                  const SizedBox(width: 12),

                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,

                      children: [
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),

                          decoration: BoxDecoration(color: catColor.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),

                          child: Text(
                            task.category,

                            style: TextStyle(color: catColor, fontSize: 10, fontWeight: FontWeight.w700, letterSpacing: 0.5),
                          ),
                        ),

                        const SizedBox(height: 4),

                        Text(
                          task.title,

                          style: TextStyle(
                            fontSize: 15,
                            fontWeight: FontWeight.w700,

                            color: Theme.of(context).brightness == Brightness.dark ? Colors.white : AppTheme.textPrimary,
                          ),

                          maxLines: 2,
                          overflow: TextOverflow.ellipsis,
                        ),
                      ],
                    ),
                  ),

                  if (task.status != TaskStatus.open) StatusBadge(status: task.status),

                  const SizedBox(width: 8),

                  GestureDetector(
                    onTap: onFavoriteToggle,

                    child: Icon(isFavorite ? Icons.favorite : Icons.favorite_border, color: isFavorite ? Colors.red : AppTheme.textLight),
                  ),
                ],
              ),
            ),

            // BODY
            Padding(
              padding: const EdgeInsets.all(16),

              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,

                children: [
                  Text(
                    task.description,

                    maxLines: 2,
                    overflow: TextOverflow.ellipsis,

                    style: TextStyle(
                      fontSize: 13,

                      color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSecondaryText : AppTheme.textSecondary,

                      height: 1.5,
                    ),
                  ),

                  const SizedBox(height: 12),

                  Row(
                    children: [
                      _infoChip(Icons.location_on_outlined, task.location),

                      const SizedBox(width: 8),

                      _infoChip(Icons.calendar_today_outlined, DateFormat('MMM d').format(task.date)),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,

                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,

                        children: [
                          Text(
                            '${task.volunteersApplied} applied',

                            style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary, fontWeight: FontWeight.w500),
                          ),

                          Text(
                            task.isFull ? 'Full' : '$spotsLeft spot${spotsLeft == 1 ? '' : 's'} left',

                            style: TextStyle(fontSize: 12, color: task.isFull ? AppTheme.danger : AppTheme.success, fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 6),

                      LinearProgressIndicator(
                        value: task.fillRate.clamp(0.0, 1.0),

                        backgroundColor: AppTheme.divider,

                        valueColor: AlwaysStoppedAnimation(task.isFull ? AppTheme.danger : catColor),

                        minHeight: 6,
                      ),
                    ],
                  ),

                  const SizedBox(height: 12),

                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,

                    children: [
                      Text(
                        task.organizationName,

                        style: const TextStyle(fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600),
                      ),

                      Text(_timeAgo(task.postedAt), style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                    ],
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _infoChip(IconData icon, String label) {
    return Row(
      children: [
        Icon(icon, size: 13, color: AppTheme.textLight),

        const SizedBox(width: 3),

        Text(label, style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
      ],
    );
  }

  String _timeAgo(DateTime dt) {
    final diff = DateTime.now().difference(dt);

    if (diff.inDays > 0) {
      return '${diff.inDays}d ago';
    }

    if (diff.inHours > 0) {
      return '${diff.inHours}h ago';
    }

    return 'Just now';
  }
}

class StatusBadge extends StatelessWidget {
  final TaskStatus status;
  const StatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    switch (status) {
      case TaskStatus.open:
        color = AppTheme.success;
        label = 'Open';
        break;
      case TaskStatus.inProgress:
        color = AppTheme.warning;
        label = 'In Progress';
        break;
      case TaskStatus.completed:
        color = AppTheme.textLight;
        label = 'Completed';
        break;
      case TaskStatus.cancelled:
        color = AppTheme.danger;
        label = 'Cancelled';
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(6)),
      child: Text(
        label,
        style: TextStyle(fontSize: 11, color: color, fontWeight: FontWeight.w700),
      ),
    );
  }
}

class AppStatusBadge extends StatelessWidget {
  final ApplicationStatus status;
  const AppStatusBadge({super.key, required this.status});

  @override
  Widget build(BuildContext context) {
    Color color;
    String label;
    IconData icon;
    switch (status) {
      case ApplicationStatus.pending:
        color = AppTheme.warning;
        label = 'Pending';
        icon = Icons.hourglass_empty;
        break;
      case ApplicationStatus.accepted:
        color = AppTheme.success;
        label = 'Accepted';
        icon = Icons.check_circle_outline;
        break;
      case ApplicationStatus.rejected:
        color = AppTheme.danger;
        label = 'Rejected';
        icon = Icons.cancel_outlined;
        break;
    }
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      decoration: BoxDecoration(color: color.withOpacity(0.12), borderRadius: BorderRadius.circular(20)),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(icon, size: 13, color: color),
          const SizedBox(width: 4),
          Text(
            label,
            style: TextStyle(fontSize: 12, color: color, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}

class SkillChip extends StatelessWidget {
  final String skill;
  final bool selected;
  final VoidCallback? onTap;

  const SkillChip({super.key, required this.skill, this.selected = false, this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
        decoration: BoxDecoration(
          color: selected ? AppTheme.primary : AppTheme.primaryLight,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
        ),
        child: Text(
          skill,
          style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: selected ? Colors.white : AppTheme.primary),
        ),
      ),
    );
  }
}

class SectionHeader extends StatelessWidget {
  final String title;
  final String? action;
  final VoidCallback? onAction;

  const SectionHeader({super.key, required this.title, this.action, this.onAction});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary, letterSpacing: -0.2),
        ),
        if (action != null)
          GestureDetector(
            onTap: onAction,
            child: Text(
              action!,
              style: const TextStyle(fontSize: 13, color: AppTheme.primary, fontWeight: FontWeight.w600),
            ),
          ),
      ],
    );
  }
}

class EmptyState extends StatelessWidget {
  final String emoji;
  final String title;
  final String subtitle;
  final String? buttonLabel;
  final VoidCallback? onButton;

  const EmptyState({super.key, required this.emoji, required this.title, required this.subtitle, this.buttonLabel, this.onButton});

  @override
  Widget build(BuildContext context) {
    return Center(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(40),
        child: Column(
          mainAxisSize: MainAxisSize.min, 
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(emoji, style: const TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            Text(
              title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
            ),
            const SizedBox(height: 8),
            Text(
              subtitle,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            if (buttonLabel != null) ...[
              const SizedBox(height: 24), 
              ElevatedButton(onPressed: onButton, child: Text(buttonLabel!))
            ],
          ],
        ),
      ),
    );
  }
}

class LoadingOverlay extends StatelessWidget {
  final bool isLoading;
  final Widget child;

  const LoadingOverlay({super.key, required this.isLoading, required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        if (isLoading)
          Container(
            color: Colors.black.withOpacity(0.3),
            child: const Center(child: CircularProgressIndicator(color: AppTheme.primary)),
          ),
      ],
    );
  }
}
