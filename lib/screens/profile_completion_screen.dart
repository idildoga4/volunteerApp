import 'package:flutter/material.dart';

import '../models/models.dart';
import '../services/database_service.dart';
import '../widgets/theme.dart';
import 'main_nav_screen.dart';

class ProfileCompletionScreen extends StatefulWidget {
  final AppUser user;

  const ProfileCompletionScreen({super.key, required this.user});

  @override
  State<ProfileCompletionScreen> createState() => _ProfileCompletionScreenState();
}

class _ProfileCompletionScreenState extends State<ProfileCompletionScreen> {
  final _formKey = GlobalKey<FormState>();
  final db = DatabaseService();

  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _orgNameCtrl;
  late TextEditingController _orgDescCtrl;
  late List<String> _skills;
  bool _saving = false;

  @override
  void initState() {
    super.initState();
    _nameCtrl = TextEditingController(text: widget.user.name);
    _bioCtrl = TextEditingController(text: widget.user.bio ?? '');
    _orgNameCtrl = TextEditingController(text: widget.user.orgName ?? '');
    _orgDescCtrl = TextEditingController(text: widget.user.orgDescription ?? '');
    _skills = List.from(widget.user.skills);
  }

  @override
  void dispose() {
    _nameCtrl.dispose();
    _bioCtrl.dispose();
    _orgNameCtrl.dispose();
    _orgDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _save() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _saving = true);

    final updated = widget.user.copyWith(
      name: _nameCtrl.text.trim().isEmpty ? widget.user.name : _nameCtrl.text.trim(),
      bio: widget.user.role == UserRole.volunteer && _bioCtrl.text.trim().isNotEmpty
          ? _bioCtrl.text.trim()
          : null,
      orgName: widget.user.role == UserRole.organization && _orgNameCtrl.text.trim().isNotEmpty
          ? _orgNameCtrl.text.trim()
          : null,
      orgDescription: widget.user.role == UserRole.organization && _orgDescCtrl.text.trim().isNotEmpty
          ? _orgDescCtrl.text.trim()
          : null,
      skills: widget.user.role == UserRole.volunteer ? _skills : widget.user.skills,
    );

    await db.updateUser(updated);
    await db.refreshAll();

    if (!mounted) return;
    setState(() => _saving = false);
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainNavScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) {
    final isOrg = widget.user.role == UserRole.organization;

    final isDark = Theme.of(context).brightness == Brightness.dark;
    final cardColor = isDark ? AppTheme.darkCard : Colors.white;
    final bgColor = isDark ? AppTheme.darkSurface : AppTheme.surface;
    final textColor = isDark ? AppTheme.darkText : AppTheme.textPrimary;
    final subColor = isDark ? AppTheme.darkSecondaryText : AppTheme.textSecondary;

    return Scaffold(
      backgroundColor: bgColor,
      appBar: AppBar(
        title: Text('Complete Profile', style: TextStyle(color: textColor)),
        backgroundColor: cardColor,
        iconTheme: IconThemeData(color: textColor),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(20),
          child: Form(
            key: _formKey,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  isOrg ? 'Tell us about your organization' : 'Tell us about yourself',
                  style: TextStyle(fontSize: 20, fontWeight: FontWeight.w800, color: textColor),
                ),
                const SizedBox(height: 8),
                Text(
                  'You can update this anytime later.',
                  style: TextStyle(fontSize: 13, color: subColor),
                ),
                const SizedBox(height: 24),
                TextFormField(
                  controller: _nameCtrl,
                  decoration: const InputDecoration(labelText: 'Name', prefixIcon: Icon(Icons.person_outline)),
                  validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                if (isOrg) ...[
                  TextFormField(
                    controller: _orgNameCtrl,
                    decoration: const InputDecoration(
                      labelText: 'Organization Name',
                      prefixIcon: Icon(Icons.business_outlined),
                    ),
                    validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                  ),
                  const SizedBox(height: 16),
                  TextFormField(
                    controller: _orgDescCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Organization Description',
                      prefixIcon: Icon(Icons.description_outlined),
                    ),
                  ),
                ] else ...[
                  TextFormField(
                    controller: _bioCtrl,
                    maxLines: 3,
                    decoration: const InputDecoration(
                      labelText: 'Bio (optional)',
                      prefixIcon: Icon(Icons.notes_outlined),
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    'Your Skills',
                    style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700, color: textColor),
                  ),
                  const SizedBox(height: 10),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: AppConstants.allSkills.map((s) {
                      final selected = _skills.contains(s);
                      return GestureDetector(
                        onTap: () => setState(() => selected ? _skills.remove(s) : _skills.add(s)),
                        child: AnimatedContainer(
                          duration: const Duration(milliseconds: 150),
                          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                          decoration: BoxDecoration(
                            color: selected ? AppTheme.primary : cardColor,
                            borderRadius: BorderRadius.circular(20),
                            border: Border.all(color: selected ? AppTheme.primary : AppTheme.divider),
                          ),
                          child: Text(
                            s,
                            style: TextStyle(
                              fontSize: 12,
                              fontWeight: FontWeight.w600,
                              color: selected ? Colors.white : AppTheme.textSecondary,
                            ),
                          ),
                        ),
                      );
                    }).toList(),
                  ),
                ],
                const SizedBox(height: 28),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _saving ? null : _save,
                    child: _saving
                        ? const SizedBox(
                            width: 20,
                            height: 20,
                            child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2),
                          )
                        : const Text('Finish Setup'),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
