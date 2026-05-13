import 'package:flutter/material.dart';
import 'package:volunteer/widgets/theme.dart';
import '../models/models.dart';
import '../services/database_service.dart';
import '../widgets/shared_widgets.dart';
import 'task_detail_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final db = DatabaseService();
  final _searchCtrl = TextEditingController();
  String _selectedCategory = 'All';
  String _searchQuery = '';
  Set<String> _favoriteTasks = {};

  @override
  void dispose() {
    _searchCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final user = db.currentUser;
    final tasks = db.getTasks(search: _searchQuery, category: _selectedCategory, onlyOpen: false);

    return Scaffold(
      backgroundColor: AppTheme.surface,
      body: SafeArea(
        child: CustomScrollView(
          slivers: [
            // Header
            SliverToBoxAdapter(
              child: Container(
                color: Colors.white,
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Hello, ${user?.name.split(' ').first ?? 'there'} 👋',
                              style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: AppTheme.textPrimary, letterSpacing: -0.3),
                            ),
                            const SizedBox(height: 2),
                            const Text('Find your next volunteer opportunity', style: TextStyle(fontSize: 13, color: AppTheme.textSecondary)),
                          ],
                        ),
                        Container(
                          width: 44,
                          height: 44,
                          decoration: BoxDecoration(color: AppTheme.primaryLight, shape: BoxShape.circle),
                          child: Center(
                            child: Text(
                              (user?.name.isNotEmpty == true) ? user!.name[0].toUpperCase() : '?',
                              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700, color: AppTheme.primary),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    // Search
                    TextField(
                      controller: _searchCtrl,
                      onChanged: (v) => setState(() => _searchQuery = v),
                      decoration: InputDecoration(
                        hintText: 'Search tasks, locations...',
                        prefixIcon: const Icon(Icons.search, color: AppTheme.textLight),
                        suffixIcon: _searchQuery.isNotEmpty
                            ? IconButton(
                                icon: const Icon(Icons.clear, size: 18),
                                onPressed: () {
                                  _searchCtrl.clear();
                                  setState(() => _searchQuery = '');
                                },
                              )
                            : null,
                        filled: true,
                        fillColor: AppTheme.surface,
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.divider),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(color: AppTheme.primary, width: 2),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    // Category chips
                    SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: Row(
                        children: AppConstants.categories.map((cat) {
                          final sel = _selectedCategory == cat;
                          final emoji = cat == 'All' ? '🌐' : AppConstants.categoryEmojis[cat] ?? '✨';
                          return GestureDetector(
                            onTap: () => setState(() => _selectedCategory = cat),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              margin: const EdgeInsets.only(right: 8),
                              padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                              decoration: BoxDecoration(
                                color: sel ? AppTheme.primary : Colors.white,
                                borderRadius: BorderRadius.circular(20),
                                border: Border.all(color: sel ? AppTheme.primary : AppTheme.divider),
                              ),
                              child: Row(
                                children: [
                                  Text(emoji, style: const TextStyle(fontSize: 13)),
                                  const SizedBox(width: 6),
                                  Text(
                                    cat,
                                    style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600, color: sel ? Colors.white : AppTheme.textSecondary),
                                  ),
                                ],
                              ),
                            ),
                          );
                        }).toList(),
                      ),
                    ),
                    const SizedBox(height: 16),
                  ],
                ),
              ),
            ),

            // Stats bar
            SliverToBoxAdapter(
              child: Container(
                margin: const EdgeInsets.fromLTRB(20, 16, 20, 0),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppTheme.primary, AppTheme.primaryDark],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceAround,
                  children: [
                    _statItem('${db.getTasks(onlyOpen: true).length}', 'Open Tasks'),
                    _vDivider(),
                    _statItem('${AppConstants.categories.length - 1}', 'Categories'),
                    _vDivider(),
                    _statItem('3', 'NGOs Active'),
                  ],
                ),
              ),
            ),

            // Task list header
            SliverToBoxAdapter(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 12),
                child: SectionHeader(title: tasks.isEmpty ? 'No tasks found' : '${tasks.length} Tasks'),
              ),
            ),

            // Tasks
            tasks.isEmpty
                ? SliverFillRemaining(
                    child: EmptyState(
                      emoji: '🔍',
                      title: 'No Tasks Found',
                      subtitle: 'Try adjusting your search or filters.',
                      buttonLabel: 'Clear Filters',
                      onButton: () {
                        _searchCtrl.clear();
                        setState(() {
                          _searchQuery = '';
                          _selectedCategory = 'All';
                        });
                      },
                    ),
                  )
                : SliverPadding(
                    padding: const EdgeInsets.fromLTRB(20, 0, 20, 100),
                    sliver: SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (_, i) => TaskCard(
                          task: tasks[i],
                          isFavorite: _favoriteTasks.contains(tasks[i].id),
                          onFavoriteToggle: () {
                            setState(() {
                              if (_favoriteTasks.contains(tasks[i].id)) {
                                _favoriteTasks.remove(tasks[i].id);
                              } else {
                                _favoriteTasks.add(tasks[i].id);
                              }
                            });
                          },
                          onTap: () => Navigator.push(
                            context,
                            MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: tasks[i].id)),
                          ).then((_) => setState(() {})),
                        ),
                        childCount: tasks.length,
                      ),
                    ),
                  ),
          ],
        ),
      ),
    );
  }

  Widget _statItem(String value, String label) {
    return Column(
      children: [
        Text(
          value,
          style: const TextStyle(fontSize: 22, fontWeight: FontWeight.w800, color: Colors.white),
        ),
        const SizedBox(height: 2),
        Text(
          label,
          style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.75), fontWeight: FontWeight.w500),
        ),
      ],
    );
  }

  Widget _vDivider() => Container(width: 1, height: 32, color: Colors.white.withOpacity(0.2));
}
