import 'package:flutter/material.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';


class ApplyTaskScreen extends StatefulWidget {
  final Task task;
  const ApplyTaskScreen({super.key, required this.task});

  @override
  State<ApplyTaskScreen> createState() => _ApplyTaskScreenState();
}

class _ApplyTaskScreenState extends State<ApplyTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _messageCtrl = TextEditingController();
  String _availability = 'Weekends';
  bool _loading = false;

  final List<String> _availabilityOptions = [
    'Weekends',
    'Weekdays',
    'Mornings only',
    'Afternoons only',
    'Evenings only',
    'Full-time',
    'Flexible',
  ];

  @override
  void dispose() {
    _messageCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final db = DatabaseService();
    final user = db.currentUser!;
    final app = await db.applyForTask(
      taskId: widget.task.id,
      userId: user.id,
      message: _messageCtrl.text.trim(),
      availability: _availability,
    );

    if (!mounted) return;
    setState(() => _loading = false);

    if (app != null) {
      _showSuccessSheet();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('You have already applied for this task.')));
    }
  }

  void _showSuccessSheet() {
    showModalBottomSheet(
      context: context,
      isDismissible: false,
      shape: const RoundedRectangleBorder(
          borderRadius: BorderRadius.vertical(top: Radius.circular(24))),
      builder: (_) => Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Text('🎉', style: TextStyle(fontSize: 64)),
            const SizedBox(height: 16),
            const Text('Application Submitted!',
                style: TextStyle(
                    fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary)),
            const SizedBox(height: 8),
            Text(
              'Your application for "${widget.task.title}" has been sent. The organization will review it soon.',
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 14, color: AppTheme.textSecondary, height: 1.5),
            ),
            const SizedBox(height: 28),
            ElevatedButton(
              onPressed: () {
                Navigator.pop(context); // close sheet
                Navigator.pop(context); // go back to detail
              },
              style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
              child: const Text('Back to Task'),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final db = DatabaseService();
    final user = db.currentUser!;
    final matchedSkills = user.skills.where((s) => widget.task.requiredSkills.contains(s)).toList();

    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Apply for Task'),
        backgroundColor: Colors.white,
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(height: 1, color: AppTheme.divider),
        ),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(20),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Task summary card
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    Text(widget.task.imageEmoji, style: const TextStyle(fontSize: 36)),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(widget.task.title,
                              style: const TextStyle(
                                  fontSize: 15, fontWeight: FontWeight.w700,
                                  color: AppTheme.textPrimary)),
                          const SizedBox(height: 4),
                          Text(widget.task.organizationName,
                              style: const TextStyle(
                                  fontSize: 12, color: AppTheme.primary, fontWeight: FontWeight.w600)),
                          const SizedBox(height: 4),
                          Row(
                            children: [
                              const Icon(Icons.location_on_outlined, size: 12, color: AppTheme.textLight),
                              const SizedBox(width: 3),
                              Text(widget.task.location,
                                  style: const TextStyle(fontSize: 12, color: AppTheme.textSecondary)),
                            ],
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              // Skill match
              if (matchedSkills.isNotEmpty) ...[
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppTheme.successLight,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppTheme.success.withOpacity(0.2)),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.verified, color: AppTheme.success, size: 20),
                      const SizedBox(width: 10),
                      Expanded(
                        child: Text(
                          'Great match! Your skills ${matchedSkills.join(', ')} align with this task.',
                          style: const TextStyle(
                              fontSize: 13, color: AppTheme.success, fontWeight: FontWeight.w500),
                        ),
                      ),
                    ],
                  ),
                ),
              ],

              const SizedBox(height: 24),

              // Applicant info
              const Text('Your Application',
                  style: TextStyle(
                      fontSize: 17, fontWeight: FontWeight.w700, color: AppTheme.textPrimary)),
              const SizedBox(height: 4),
              const Text('Tell the organization why you want to volunteer',
                  style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
              const SizedBox(height: 16),

              // Applicant name (read only)
              Container(
                padding: const EdgeInsets.all(14),
                decoration: BoxDecoration(
                  color: AppTheme.surface,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: AppTheme.divider),
                ),
                child: Row(
                  children: [
                    const Icon(Icons.person_outline, color: AppTheme.textLight, size: 20),
                    const SizedBox(width: 10),
                    Text(user.name,
                        style: const TextStyle(fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                    const Spacer(),
                    const Text('Auto-filled', style: TextStyle(fontSize: 11, color: AppTheme.textLight)),
                  ],
                ),
              ),
              const SizedBox(height: 16),

              // Availability dropdown
              const Text('Availability',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              DropdownButtonFormField<String>(
                value: _availability,
                decoration: const InputDecoration(
                  prefixIcon: Icon(Icons.schedule_outlined),
                ),
                items: _availabilityOptions.map((opt) =>
                    DropdownMenuItem(value: opt, child: Text(opt))).toList(),
                onChanged: (v) => setState(() => _availability = v!),
              ),
              const SizedBox(height: 16),

              // Motivation message
              const Text('Motivation Message',
                  style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 8),
              TextFormField(
                controller: _messageCtrl,
                maxLines: 5,
                maxLength: 500,
                decoration: const InputDecoration(
                  hintText: 'Introduce yourself and explain why you are interested in this task...',
                  alignLabelWithHint: true,
                ),
                validator: (v) {
                  if (v == null || v.trim().length < 20) {
                    return 'Please write at least 20 characters';
                  }
                  return null;
                },
              ),

              // Skills display
              if (user.skills.isNotEmpty) ...[
                const SizedBox(height: 16),
                const Text('Your Skills (will be shared)',
                    style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
                const SizedBox(height: 8),
                Wrap(
                  spacing: 8, runSpacing: 8,
                  children: user.skills.map((s) {
                    final isMatch = widget.task.requiredSkills.contains(s);
                    return Container(
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: isMatch ? AppTheme.successLight : AppTheme.primaryLight,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(
                            color: isMatch ? AppTheme.success.withOpacity(0.3) : AppTheme.divider),
                      ),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          if (isMatch) ...[
                            const Icon(Icons.check, size: 12, color: AppTheme.success),
                            const SizedBox(width: 4),
                          ],
                          Text(s,
                              style: TextStyle(
                                  fontSize: 12, fontWeight: FontWeight.w600,
                                  color: isMatch ? AppTheme.success : AppTheme.primary)),
                        ],
                      ),
                    );
                  }).toList(),
                ),
              ],

              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.send_outlined),
                  label: Text(_loading ? 'Submitting...' : 'Submit Application'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                ),
              ),
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}