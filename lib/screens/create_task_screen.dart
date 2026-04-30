import 'package:flutter/material.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';

class CreateTaskScreen extends StatefulWidget {
  const CreateTaskScreen({super.key});

  @override
  State<CreateTaskScreen> createState() => _CreateTaskScreenState();
}

class _CreateTaskScreenState extends State<CreateTaskScreen> {
  final _formKey = GlobalKey<FormState>();
  final _titleCtrl = TextEditingController();
  final _descCtrl = TextEditingController();
  final _locationCtrl = TextEditingController();
  final _durationCtrl = TextEditingController();
  final _spotsCtrl = TextEditingController(text: '10');

  String _category = 'Environment';
  DateTime _date = DateTime.now().add(const Duration(days: 7));
  List<String> _selectedSkills = [];
  String _selectedEmoji = '🌿';
  bool _loading = false;

  final Map<String, String> _categoryEmojis = {
    'Environment': '🌿', 'Animals': '🐾', 'Education': '📚',
    'Social': '🤝', 'Health': '❤️', 'Arts & Media': '🎨',
    'Sports': '⚽', 'Technology': '💻', 'Other': '✨',
  };

  @override
  void dispose() {
    _titleCtrl.dispose(); _descCtrl.dispose();
    _locationCtrl.dispose(); _durationCtrl.dispose(); _spotsCtrl.dispose();
    super.dispose();
  }

  Future<void> _submit() async {
    if (!_formKey.currentState!.validate()) return;
    setState(() => _loading = true);

    final db = DatabaseService();
    final user = db.currentUser!;

    await db.createTask(Task(
      id: '',
      title: _titleCtrl.text.trim(),
      description: _descCtrl.text.trim(),
      organizationId: user.id,
      organizationName: user.orgName ?? user.name,
      category: _category,
      location: _locationCtrl.text.trim(),
      date: _date,
      duration: _durationCtrl.text.trim(),
      volunteersNeeded: int.tryParse(_spotsCtrl.text) ?? 10,
      volunteersApplied: 0,
      requiredSkills: _selectedSkills,
      status: TaskStatus.open,
      postedAt: DateTime.now(),
      imageEmoji: _selectedEmoji,
    ));

    if (!mounted) return;
    setState(() => _loading = false);
    Navigator.pop(context);
    ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('✅ Task posted successfully!')));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppTheme.surface,
      appBar: AppBar(
        title: const Text('Post New Task'),
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
              // Emoji picker
              const Text('Task Icon', style: TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
              const SizedBox(height: 10),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  children: _categoryEmojis.values.map((e) {
                    final sel = _selectedEmoji == e;
                    return GestureDetector(
                      onTap: () => setState(() => _selectedEmoji = e),
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        margin: const EdgeInsets.only(right: 10),
                        width: 52, height: 52,
                        decoration: BoxDecoration(
                          color: sel ? AppTheme.primaryLight : Colors.white,
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider,
                              width: sel ? 2 : 1),
                        ),
                        child: Center(child: Text(e, style: const TextStyle(fontSize: 26))),
                      ),
                    );
                  }).toList(),
                ),
              ),
              const SizedBox(height: 20),

              _label('Task Title'),
              TextFormField(
                controller: _titleCtrl,
                decoration: const InputDecoration(
                    hintText: 'e.g. Beach Clean-Up at Sarıyer'),
                validator: (v) => v == null || v.trim().length < 5 ? 'Min 5 characters' : null,
              ),
              const SizedBox(height: 16),

              _label('Category'),
              DropdownButtonFormField<String>(
                value: _category,
                decoration: const InputDecoration(prefixIcon: Icon(Icons.category_outlined)),
                items: AppConstants.categories.where((c) => c != 'All').map((c) =>
                    DropdownMenuItem(value: c, child: Text(c))).toList(),
                onChanged: (v) => setState(() {
                  _category = v!;
                  _selectedEmoji = _categoryEmojis[v] ?? '✨';
                }),
              ),
              const SizedBox(height: 16),

              _label('Description'),
              TextFormField(
                controller: _descCtrl,
                maxLines: 4,
                decoration: const InputDecoration(
                    hintText: 'Describe the task, what volunteers will do, what to bring...'),
                validator: (v) => v == null || v.trim().length < 20 ? 'Min 20 characters' : null,
              ),
              const SizedBox(height: 16),

              _label('Location'),
              TextFormField(
                controller: _locationCtrl,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.location_on_outlined),
                    hintText: 'e.g. Sarıyer, Istanbul'),
                validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 16),

              Row(children: [
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Date'),
                    GestureDetector(
                      onTap: _pickDate,
                      child: Container(
                        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 14),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12),
                          border: Border.all(color: AppTheme.divider),
                        ),
                        child: Row(
                          children: [
                            const Icon(Icons.calendar_today_outlined, size: 18, color: AppTheme.textLight),
                            const SizedBox(width: 8),
                            Text(
                              '${_date.day}/${_date.month}/${_date.year}',
                              style: const TextStyle(fontSize: 14, color: AppTheme.textPrimary),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ],
                )),
                const SizedBox(width: 12),
                Expanded(child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _label('Duration'),
                    TextFormField(
                      controller: _durationCtrl,
                      decoration: const InputDecoration(hintText: 'e.g. 4 hours'),
                      validator: (v) => v == null || v.trim().isEmpty ? 'Required' : null,
                    ),
                  ],
                )),
              ]),
              const SizedBox(height: 16),

              _label('Volunteer Spots Needed'),
              TextFormField(
                controller: _spotsCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                    prefixIcon: Icon(Icons.people_outline)),
                validator: (v) {
                  final n = int.tryParse(v ?? '');
                  if (n == null || n < 1) return 'Enter a valid number';
                  return null;
                },
              ),
              const SizedBox(height: 20),

              _label('Required Skills (optional)'),
              const SizedBox(height: 8),
              Wrap(
                spacing: 8, runSpacing: 8,
                children: AppConstants.allSkills.map((s) {
                  final sel = _selectedSkills.contains(s);
                  return GestureDetector(
                    onTap: () => setState(() =>
                        sel ? _selectedSkills.remove(s) : _selectedSkills.add(s)),
                    child: AnimatedContainer(
                      duration: const Duration(milliseconds: 150),
                      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: sel ? AppTheme.primary : Colors.white,
                        borderRadius: BorderRadius.circular(20),
                        border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                      ),
                      child: Text(s,
                          style: TextStyle(
                            fontSize: 12, fontWeight: FontWeight.w600,
                            color: sel ? Colors.white : AppTheme.textSecondary,
                          )),
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 32),
              SizedBox(
                width: double.infinity,
                child: ElevatedButton.icon(
                  onPressed: _loading ? null : _submit,
                  icon: _loading
                      ? const SizedBox(width: 18, height: 18,
                          child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                      : const Icon(Icons.publish_outlined),
                  label: Text(_loading ? 'Publishing...' : 'Publish Task'),
                  style: ElevatedButton.styleFrom(minimumSize: const Size(double.infinity, 52)),
                ),
              ),
              const SizedBox(height: 32),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _pickDate() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime.now(),
      lastDate: DateTime.now().add(const Duration(days: 365)),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Widget _label(String text) => Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Text(text,
        style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w600, color: AppTheme.textPrimary)),
  );
}