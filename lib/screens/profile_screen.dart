import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:volunteer/screens/settings_screen.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';

import '../widgets/shared_widgets.dart';

import 'onboarding_screen.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final db = DatabaseService();
  bool _editMode = false;

  late TextEditingController _nameCtrl;
  late TextEditingController _bioCtrl;
  late TextEditingController _orgNameCtrl;
  late TextEditingController _orgDescCtrl;
  late List<String> _skills;

  @override
  void initState() {
    super.initState();
    _initControllers();
  }

  void _initControllers() {
    final user = db.currentUser!;
    _nameCtrl = TextEditingController(text: user.name);
    _bioCtrl = TextEditingController(text: user.bio ?? '');
    _orgNameCtrl = TextEditingController(text: user.orgName ?? '');
    _orgDescCtrl = TextEditingController(text: user.orgDescription ?? '');
    _skills = List.from(user.skills);
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
    final user = db.currentUser!;
    await db.updateUser(
      user.copyWith(
        name: _nameCtrl.text.trim(),
        bio: _bioCtrl.text.trim().isEmpty ? null : _bioCtrl.text.trim(),
        orgName: _orgNameCtrl.text.trim().isEmpty ? null : _orgNameCtrl.text.trim(),
        orgDescription: _orgDescCtrl.text.trim().isEmpty ? null : _orgDescCtrl.text.trim(),
        skills: _skills,
      ),
    );
    setState(() => _editMode = false);
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text('✅ Profile updated!')));
    }
  }

  @override
  Widget build(BuildContext context) {
    final user = db.currentUser!;
    final isOrg = user.role == UserRole.organization;
    final apps = isOrg ? <TaskApplication>[] : db.getApplicationsByUser(user.id);
    final acceptedCount = apps.where((a) => a.status == ApplicationStatus.accepted).length;

    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : AppTheme.surface,
      body: CustomScrollView(
        slivers: [
          SliverAppBar(
            expandedHeight: 200,
            pinned: true,
            backgroundColor: AppTheme.primary,
            foregroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
            actions: [
              if (!_editMode)
                IconButton(
                  icon: const Icon(Icons.edit_outlined),
                  onPressed: () => setState(() {
                    _editMode = true;
                    _initControllers();
                  }),
                ),
              if (_editMode) ...[
                TextButton(
                  onPressed: () => setState(() => _editMode = false),
                  child: const Text('Cancel', style: TextStyle(color: Colors.white70)),
                ),
                TextButton(
                  onPressed: _save,
                  child: const Text(
                    'Save',
                    style: TextStyle(color: Colors.white, fontWeight: FontWeight.w700),
                  ),
                ),
              ],
              IconButton(
                icon: const Icon(Icons.settings_outlined),
                onPressed: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SettingsScreen())).then((_) => setState(() {})),
              ),
            ],
            flexibleSpace: FlexibleSpaceBar(
              background: Container(
                decoration: const BoxDecoration(
                  gradient: LinearGradient(begin: Alignment.topLeft, end: Alignment.bottomRight, colors: [AppTheme.primaryDark, AppTheme.primary]),
                ),
                child: SafeArea(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const SizedBox(height: 30),
                      CircleAvatar(
                        radius: 38,
                        backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white.withOpacity(0.2),
                        child: Text(
                          user.name[0].toUpperCase(),
                          style: const TextStyle(fontSize: 32, fontWeight: FontWeight.w700, color: Colors.white),
                        ),
                      ),
                      const SizedBox(height: 10),
                      Text(
                        user.name,
                        style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: Colors.white),
                      ),
                      const SizedBox(height: 4),
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white.withOpacity(0.2),
                          borderRadius: BorderRadius.circular(20),
                        ),
                        child: Text(
                          isOrg ? '🏢 Organization' : '👤 Volunteer',
                          style: const TextStyle(fontSize: 12, color: Colors.white, fontWeight: FontWeight.w600),
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
                  // Stats
                  if (!isOrg) ...[
                    Row(
                      children: [
                        Expanded(child: _statCard('${apps.length}', 'Applied', Icons.send_outlined, AppTheme.primary)),
                        const SizedBox(width: 10),
                        Expanded(child: _statCard('$acceptedCount', 'Accepted', Icons.check_circle_outline, AppTheme.success)),
                        const SizedBox(width: 10),
                        Expanded(
                          child: _statCard(DateFormat('MMM y').format(user.joinedAt), 'Joined', Icons.calendar_today_outlined, AppTheme.accent),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                  ],

                  if (_editMode) _buildEditForm(isOrg, user) else _buildViewMode(isOrg, user),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildViewMode(bool isOrg, AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        if (isOrg && user.orgName != null) ...[
          _sectionCard([
            _infoRow(context, Icons.business_outlined, 'Organization', user.orgName!),
            if (user.orgDescription != null) _infoRow(context, Icons.description_outlined, 'About', user.orgDescription!),
          ]),
          const SizedBox(height: 16),
        ],

        _sectionCard([
          _infoRow(context, Icons.person_outline, 'Name', user.name),
          _infoRow(context, Icons.email_outlined, 'Email', user.email),
          if (user.bio != null && user.bio!.isNotEmpty) _infoRow(context, Icons.notes_outlined, 'Bio', user.bio!),
        ]),

        if (!isOrg && user.skills.isNotEmpty) ...[
          const SizedBox(height: 20),
          const SectionHeader(title: 'My Skills'),
          const SizedBox(height: 12),
          Wrap(spacing: 8, runSpacing: 8, children: user.skills.map((s) => SkillChip(skill: s, selected: true)).toList()),
        ],

        const SizedBox(height: 20),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _logout,
            icon: const Icon(Icons.logout, color: AppTheme.danger),
            label: const Text('Sign Out', style: TextStyle(color: AppTheme.danger)),
            style: OutlinedButton.styleFrom(
              side: const BorderSide(color: AppTheme.danger),
              padding: const EdgeInsets.symmetric(vertical: 14),
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildEditForm(bool isOrg, AppUser user) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
        ),
        const SizedBox(height: 16),
        if (!isOrg) ...[
          TextFormField(
            controller: _bioCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Bio (optional)', prefixIcon: Icon(Icons.notes_outlined)),
          ),
          const SizedBox(height: 20),
          const Text(
            'My Skills',
            style: TextStyle(fontSize: 15, fontWeight: FontWeight.w700, color: AppTheme.textPrimary),
          ),
          const SizedBox(height: 10),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: AppConstants.allSkills.map((s) {
              final sel = _skills.contains(s);
              return GestureDetector(
                onTap: () => setState(() => sel ? _skills.remove(s) : _skills.add(s)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 150),
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(
                    s,
                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary),
                  ),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          TextFormField(
            controller: _orgNameCtrl,
            decoration: const InputDecoration(labelText: 'Organization Name', prefixIcon: Icon(Icons.business_outlined)),
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _orgDescCtrl,
            maxLines: 3,
            decoration: const InputDecoration(labelText: 'Description', prefixIcon: Icon(Icons.description_outlined)),
          ),
        ],
      ],
    );
  }

  Widget _sectionCard(List<Widget> children) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: AppTheme.divider),
      ),
      child: Column(
        children: children.map((child) {
          final idx = children.indexOf(child);
          return Column(
            children: [
              child,
              if (idx < children.length - 1) const Divider(color: AppTheme.divider, height: 20),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _infoRow(BuildContext context, IconData icon, String label, String value) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 18, color: AppTheme.textLight),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              label,
              style: TextStyle(
                fontSize: 11,
                color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSecondaryText : AppTheme.textLight,
                fontWeight: FontWeight.w500,
              ),
            ),
            const SizedBox(height: 2),
            Text(
              value,
              style: TextStyle(
                fontSize: 14,
                color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkText : AppTheme.textPrimary,
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ],
    );
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
        children: [
          Icon(icon, color: color, size: 18),
          const SizedBox(height: 6),
          Text(
            value,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w800, color: color),
            textAlign: TextAlign.center,
          ),
          Text(
            label,
            style: const TextStyle(fontSize: 10, color: AppTheme.textSecondary),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }

  Future<void> _logout() async {
    final confirm = await showDialog<bool>(
      context: context,
      builder: (_) => AlertDialog(
        title: const Text('Sign Out'),
        content: const Text('Are you sure you want to sign out?'),
        actions: [
          TextButton(onPressed: () => Navigator.pop(context, false), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () => Navigator.pop(context, true),
            style: ElevatedButton.styleFrom(backgroundColor: AppTheme.danger),
            child: const Text('Sign Out'),
          ),
        ],
      ),
    );
    if (confirm == true && mounted) {
      await db.logout();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const OnboardingScreen()), (_) => false);

    }
  }
}
