import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';

import '../widgets/shared_widgets.dart';

class ApplicantsScreen extends StatefulWidget {
  final Task task;
  const ApplicantsScreen({super.key, required this.task});

  @override
  State<ApplicantsScreen> createState() => _ApplicantsScreenState();
}

class _ApplicantsScreenState extends State<ApplicantsScreen> {
  final db = DatabaseService();

  @override
  Widget build(BuildContext context) {
    final apps = db.getApplicationsForTask(widget.task.id);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: Text('${widget.task.title} — Applicants'),
        backgroundColor: Colors.white,
      ),
      body: apps.isEmpty
          ? const EmptyState(
              emoji: '👥',
              title: 'No Applications Yet',
              subtitle: 'Share your task link to attract volunteers.',
            )
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: apps.length,
              itemBuilder: (_, i) {
                final app = apps[i];
                final volunteer = db.getUserById(app.userId);
                if (volunteer == null) return const SizedBox.shrink();

                return Container(
                  margin: const EdgeInsets.only(bottom: 12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppTheme.divider),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 21,
                              backgroundColor: AppTheme.primaryLight,
                              child: Text(
                                volunteer.name[0].toUpperCase(),
                                style: const TextStyle(
                                    fontSize: 18, fontWeight: FontWeight.w700,
                                    color: AppTheme.primary),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(volunteer.name,
                                      style: const TextStyle(
                                          fontWeight: FontWeight.w700, fontSize: 15)),
                                  Text(volunteer.email,
                                      style: const TextStyle(
                                          fontSize: 12, color: AppTheme.textSecondary)),
                                ],
                              ),
                            ),
                            AppStatusBadge(status: app.status),
                          ],
                        ),
                        if (volunteer.skills.isNotEmpty) ...[
                          const SizedBox(height: 10),
                          Wrap(
                            spacing: 6, runSpacing: 6,
                            children: volunteer.skills.map((s) {
                              final isMatch = widget.task.requiredSkills.contains(s);
                              return Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  color: isMatch ? AppTheme.successLight : AppTheme.primaryLight,
                                  borderRadius: BorderRadius.circular(10),
                                ),
                                child: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    if (isMatch) const Icon(Icons.check, size: 10, color: AppTheme.success),
                                    if (isMatch) const SizedBox(width: 3),
                                    Text(s,
                                        style: TextStyle(
                                            fontSize: 11, fontWeight: FontWeight.w600,
                                            color: isMatch ? AppTheme.success : AppTheme.primary)),
                                  ],
                                ),
                              );
                            }).toList(),
                          ),
                        ],
                        const SizedBox(height: 12),
                        Container(
                          padding: const EdgeInsets.all(12),
                          decoration: BoxDecoration(
                            color: AppTheme.surface,
                            borderRadius: BorderRadius.circular(10),
                          ),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              const Text('Message:',
                                  style: TextStyle(
                                      fontSize: 11, fontWeight: FontWeight.w700,
                                      color: AppTheme.textLight)),
                              const SizedBox(height: 4),
                              Text(app.message,
                                  style: const TextStyle(fontSize: 13, color: AppTheme.textPrimary, height: 1.4)),
                              const SizedBox(height: 8),
                              Row(
                                children: [
                                  const Icon(Icons.schedule_outlined, size: 13, color: AppTheme.textLight),
                                  const SizedBox(width: 4),
                                  Text('Available: ${app.availability}',
                                      style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                                  const Spacer(),
                                  Text(DateFormat('MMM d').format(app.appliedAt),
                                      style: const TextStyle(fontSize: 11, color: AppTheme.textLight)),
                                ],
                              ),
                            ],
                          ),
                        ),
                        if (app.status == ApplicationStatus.pending) ...[
                          const SizedBox(height: 12),
                          Row(
                            children: [
                              Expanded(
                                child: OutlinedButton.icon(
                                  onPressed: () => _updateStatus(app, ApplicationStatus.rejected),
                                  icon: const Icon(Icons.close, size: 16),
                                  label: const Text('Decline'),
                                  style: OutlinedButton.styleFrom(
                                    foregroundColor: AppTheme.danger,
                                    side: const BorderSide(color: AppTheme.danger),
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                              const SizedBox(width: 10),
                              Expanded(
                                child: ElevatedButton.icon(
                                  onPressed: () => _updateStatus(app, ApplicationStatus.accepted),
                                  icon: const Icon(Icons.check, size: 16),
                                  label: const Text('Accept'),
                                  style: ElevatedButton.styleFrom(
                                    backgroundColor: AppTheme.success,
                                    padding: const EdgeInsets.symmetric(vertical: 10),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ],
                      ],
                    ),
                  ),
                );
              },
            ),
    );
  }

  Future<void> _updateStatus(TaskApplication app, ApplicationStatus status) async {
    await db.updateApplicationStatus(app.id, status);
    setState(() {});
    if (mounted) {
      final msg = status == ApplicationStatus.accepted ? '✅ Applicant accepted!' : '❌ Application declined.';
      ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    }
  }
}