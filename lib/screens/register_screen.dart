import 'package:flutter/material.dart';
import 'package:volunteer/screens/main_nav_screen.dart';
import 'package:volunteer/widgets/theme.dart';
import '../../models/models.dart';

import '../../services/database_service.dart';

import 'login_screen.dart';
import 'profile_completion_screen.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  State<RegisterScreen> createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameCtrl = TextEditingController();
  final _emailCtrl = TextEditingController();
  final _passCtrl = TextEditingController();
  final _orgNameCtrl = TextEditingController();
  final _orgDescCtrl = TextEditingController();

  UserRole _role = UserRole.volunteer;
  List<String> _selectedSkills = [];
  bool _loading = false;
  bool _googleLoading = false;
  bool _obscure = true;
  int _step = 0; // 0=basic, 1=details

  @override
  void dispose() {
    _nameCtrl.dispose(); _emailCtrl.dispose(); _passCtrl.dispose();
    _orgNameCtrl.dispose(); _orgDescCtrl.dispose();
    super.dispose();
  }

  Future<void> _register() async {
    if (!_formKey.currentState!.validate()) return;
    if (_role == UserRole.organization && _orgNameCtrl.text.trim().isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Please enter your organization name')));
      return;
    }
    setState(() => _loading = true);
    final db = DatabaseService();
    final user = await db.register(
      name: _nameCtrl.text.trim(),
      email: _emailCtrl.text.trim(),
      password: _passCtrl.text,
      role: _role,
      skills: _selectedSkills,
      orgName: _orgNameCtrl.text.trim().isEmpty ? null : _orgNameCtrl.text.trim(),
      orgDescription: _orgDescCtrl.text.trim().isEmpty ? null : _orgDescCtrl.text.trim(),
    );
    if (!mounted) return;
    setState(() => _loading = false);
    if (user != null) {
      await db.refreshAll();
      Navigator.pushAndRemoveUntil(context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()), (_) => false);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Email already registered.')));
    }
  }

  Future<void> _signUpWithGoogle() async {
    String? orgName;
    String? orgDescription;

    if (_role == UserRole.organization) {
      final orgInfo = await _showOrgInfoDialog();
      if (orgInfo == null) return;
      orgName = orgInfo.orgName;
      orgDescription = orgInfo.orgDescription;
    }

    setState(() => _googleLoading = true);
    final db = DatabaseService();
    final result = await db.signInWithGoogle(
      role: _role,
      orgName: orgName,
      orgDescription: orgDescription,
    );
    if (!mounted) return;
    setState(() => _googleLoading = false);

    if (result != null) {
      if (result.isNewUser) {
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (_) => ProfileCompletionScreen(user: result.user)),
        );
      } else {
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(builder: (_) => const MainNavScreen()),
          (_) => false,
        );
      }
    } else {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Google sign-up cancelled or failed.')),
        );
      }
    }
  }

  Future<_OrgInfo?> _showOrgInfoDialog() async {
    final orgNameCtrl = TextEditingController(text: _orgNameCtrl.text);
    final orgDescCtrl = TextEditingController(text: _orgDescCtrl.text);

    final result = await showDialog<_OrgInfo>(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Organization details'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: orgNameCtrl,
                  decoration: const InputDecoration(labelText: 'Organization Name'),
                ),
                const SizedBox(height: 12),
                TextField(
                  controller: orgDescCtrl,
                  maxLines: 3,
                  decoration: const InputDecoration(labelText: 'Description (optional)'),
                ),
              ],
            ),
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('Cancel'),
            ),
            ElevatedButton(
              onPressed: () {
                if (orgNameCtrl.text.trim().isEmpty) return;
                Navigator.pop(
                  context,
                  _OrgInfo(
                    orgName: orgNameCtrl.text.trim(),
                    orgDescription: orgDescCtrl.text.trim().isEmpty ? null : orgDescCtrl.text.trim(),
                  ),
                );
              },
              child: const Text('Continue'),
            ),
          ],
        );
      },
    );

    orgNameCtrl.dispose();
    orgDescCtrl.dispose();
    return result;
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => _step == 0 ? Navigator.pop(context) : setState(() => _step = 0),
        ),
        title: Text('Step ${_step + 1} of 2'),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(4),
          child: LinearProgressIndicator(
            value: (_step + 1) / 2,
            backgroundColor: AppTheme.divider,
            color: AppTheme.primary,
          ),
        ),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Form(
            key: _formKey,
            child: _step == 0 ? _buildStep0() : _buildStep1(),
          ),
        ),
      ),
    );
  }

  Widget _buildStep0() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const Text('Create Account',
            style: TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
                color: AppTheme.textPrimary, letterSpacing: -0.5)),
        const SizedBox(height: 8),
        const Text('Who are you joining as?',
            style: TextStyle(fontSize: 15, color: AppTheme.textSecondary)),
        const SizedBox(height: 28),

        // Role selector
        Row(children: [
          Expanded(child: _roleCard(UserRole.volunteer, '👤', 'Volunteer', 'Apply for tasks')),
          const SizedBox(width: 12),
          Expanded(child: _roleCard(UserRole.organization, '🏢', 'Organization', 'Post tasks')),
        ]),
        const SizedBox(height: 24),

        TextFormField(
          controller: _nameCtrl,
          decoration: const InputDecoration(labelText: 'Full Name', prefixIcon: Icon(Icons.person_outline)),
          validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _emailCtrl,
          keyboardType: TextInputType.emailAddress,
          decoration: const InputDecoration(labelText: 'Email', prefixIcon: Icon(Icons.email_outlined)),
          validator: (v) => v == null || !v.contains('@') ? 'Enter valid email' : null,
        ),
        const SizedBox(height: 16),
        TextFormField(
          controller: _passCtrl,
          obscureText: _obscure,
          decoration: InputDecoration(
            labelText: 'Password',
            prefixIcon: const Icon(Icons.lock_outline),
            suffixIcon: IconButton(
              icon: Icon(_obscure ? Icons.visibility_outlined : Icons.visibility_off_outlined),
              onPressed: () => setState(() => _obscure = !_obscure),
            ),
          ),
          validator: (v) => v == null || v.length < 4 ? 'Min 4 characters' : null,
        ),
        const SizedBox(height: 28),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: () {
              if (_formKey.currentState!.validate()) setState(() => _step = 1);
            },
            child: const Text('Continue'),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: OutlinedButton.icon(
            onPressed: _googleLoading ? null : _signUpWithGoogle,
            icon: _googleLoading
                ? const SizedBox(width: 18, height: 18, child: CircularProgressIndicator(strokeWidth: 2))
                : Image.asset('assets/Google_logo.png', width: 18, height: 18),
            label: Text(_googleLoading ? 'Connecting...' : 'Sign up with Google'),
          ),
        ),
        const SizedBox(height: 20),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text('Already have an account?',
                style: TextStyle(color: AppTheme.textSecondary)),
            TextButton(
              onPressed: () => Navigator.pushReplacement(context,
                  MaterialPageRoute(builder: (_) => const LoginScreen())),
              child: const Text('Sign In'),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStep1() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          _role == UserRole.volunteer ? 'Your Skills' : 'Organization Details',
          style: const TextStyle(fontSize: 28, fontWeight: FontWeight.w800,
              color: AppTheme.textPrimary, letterSpacing: -0.5),
        ),
        const SizedBox(height: 8),
        Text(
          _role == UserRole.volunteer
              ? 'Select skills to get matched with relevant tasks.'
              : 'Tell volunteers about your organization.',
          style: const TextStyle(fontSize: 15, color: AppTheme.textSecondary),
        ),
        const SizedBox(height: 28),

        if (_role == UserRole.volunteer) ...[
          const Text('Select your skills:',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
          const SizedBox(height: 12),
          Wrap(
            spacing: 8, runSpacing: 8,
            children: AppConstants.allSkills.map((s) {
              final sel = _selectedSkills.contains(s);
              return GestureDetector(
                onTap: () => setState(() => sel ? _selectedSkills.remove(s) : _selectedSkills.add(s)),
                child: AnimatedContainer(
                  duration: const Duration(milliseconds: 200),
                  padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                  decoration: BoxDecoration(
                    color: sel ? AppTheme.primary : Colors.white,
                    borderRadius: BorderRadius.circular(20),
                    border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                  ),
                  child: Text(s,
                      style: TextStyle(
                        fontSize: 13, fontWeight: FontWeight.w600,
                        color: sel ? Colors.white : AppTheme.textSecondary,
                      )),
                ),
              );
            }).toList(),
          ),
        ] else ...[
          TextFormField(
            controller: _orgNameCtrl,
            decoration: const InputDecoration(
                labelText: 'Organization Name', prefixIcon: Icon(Icons.business_outlined)),
            validator: (v) => _role == UserRole.organization && (v == null || v.trim().isEmpty)
                ? 'Required' : null,
          ),
          const SizedBox(height: 16),
          TextFormField(
            controller: _orgDescCtrl,
            maxLines: 3,
            decoration: const InputDecoration(
                labelText: 'Description (optional)',
                alignLabelWithHint: true,
                prefixIcon: Padding(
                    padding: EdgeInsets.only(bottom: 40),
                    child: Icon(Icons.description_outlined))),
          ),
        ],
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: ElevatedButton(
            onPressed: _loading ? null : _register,
            child: _loading
                ? const SizedBox(width: 20, height: 20,
                    child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                : const Text('Create Account'),
          ),
        ),
      ],
    );
  }

  Widget _roleCard(UserRole role, String emoji, String label, String sub) {
    final sel = _role == role;
    return GestureDetector(
      onTap: () => setState(() => _role = role),
      child: AnimatedContainer(
        duration: const Duration(milliseconds: 200),
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: sel ? AppTheme.primaryLight : Colors.white,
          borderRadius: BorderRadius.circular(16),
          border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider, width: sel ? 2 : 1),
        ),
        child: Column(
          children: [
            Text(emoji, style: const TextStyle(fontSize: 32)),
            const SizedBox(height: 8),
            Text(label, style: TextStyle(
                fontSize: 14, fontWeight: FontWeight.w700,
                color: sel ? AppTheme.primary : AppTheme.textPrimary)),
            const SizedBox(height: 4),
            Text(sub, textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 11, color: AppTheme.textSecondary)),
          ],
        ),
      ),
    );
  }
}

class _OrgInfo {
  final String orgName;
  final String? orgDescription;

  const _OrgInfo({required this.orgName, this.orgDescription});
}