import 'package:flutter/material.dart';
import 'package:volunteer/screens/profile_Screen.dart';
import 'package:volunteer/widgets/theme.dart';

import '../services/database_service.dart';
import '../models/models.dart';
import 'home_screen.dart';
import 'my_applications_screen.dart';
import 'ngo_dashboard_screen.dart';
import 'favorites_screen.dart';

class MainNavScreen extends StatefulWidget {
  final int initialIndex;
  const MainNavScreen({super.key, this.initialIndex = 0});

  @override
  State<MainNavScreen> createState() => _MainNavScreenState();
}

class _MainNavScreenState extends State<MainNavScreen> {
  late int _currentIndex;
  final db = DatabaseService();

  Set<String> favoriteTasks = {};

  @override
  void initState() {
    super.initState();
    _currentIndex = widget.initialIndex;
  }

  List<Widget> get _screens {
    final user = db.currentUser;
    if (user?.role == UserRole.organization) {
      return [
        HomeScreen(
          favoriteTasks: favoriteTasks,
          onFavoriteToggle: (taskId) {
            setState(() {
              if (favoriteTasks.contains(taskId)) {
                favoriteTasks.remove(taskId);
              } else {
                favoriteTasks.add(taskId);
              }
            });
          },
        ),
        const NgoDashboardScreen(),
        const ProfileScreen(),
      ];
    }
    return [
      HomeScreen(
        favoriteTasks: favoriteTasks,
        onFavoriteToggle: (taskId) {
          setState(() {
            if (favoriteTasks.contains(taskId)) {
              favoriteTasks.remove(taskId);
            } else {
              favoriteTasks.add(taskId);
            }
          });
        },
      ),

<<<<<<< Updated upstream
      FavoritesScreen(favoriteTasks: db.getTasks().where((task) => favoriteTasks.contains(task.id)).toList()),
=======
      FavoritesScreen(favoriteTasks: favoriteTasks.map((id) => db.getTask(id)).whereType<Task>().toList(), onFavoriteToggle: _toggleFavorite),
>>>>>>> Stashed changes
      const MyApplicationsScreen(),
      const ProfileScreen(),
    ];
  }

  List<BottomNavigationBarItem> get _navItems {
    final user = db.currentUser;
    if (user?.role == UserRole.organization) {
      return const [
        BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Browse'),
        BottomNavigationBarItem(icon: Icon(Icons.dashboard_outlined), activeIcon: Icon(Icons.dashboard), label: 'Dashboard'),
        BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
      ];
    }
    return const [
      BottomNavigationBarItem(icon: Icon(Icons.explore_outlined), activeIcon: Icon(Icons.explore), label: 'Browse'),
      BottomNavigationBarItem(icon: Icon(Icons.favorite_border), activeIcon: Icon(Icons.favorite), label: 'Favorites'),
      BottomNavigationBarItem(icon: Icon(Icons.assignment_outlined), activeIcon: Icon(Icons.assignment), label: 'Applications'),
      BottomNavigationBarItem(icon: Icon(Icons.person_outline), activeIcon: Icon(Icons.person), label: 'Profile'),
    ];
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: IndexedStack(index: _currentIndex, children: _screens),
      bottomNavigationBar: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,

          border: const Border(top: BorderSide(color: AppTheme.divider)),
        ),
        child: BottomNavigationBar(
          currentIndex: _currentIndex,
          onTap: (i) => setState(() => _currentIndex = i),
          selectedItemColor: AppTheme.primary,
          unselectedItemColor: Theme.of(context).brightness == Brightness.dark ? Colors.grey : AppTheme.textLight,
          backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkCard : Colors.white,
          elevation: 0,
          type: BottomNavigationBarType.fixed,
          selectedLabelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
          unselectedLabelStyle: const TextStyle(fontSize: 11),
          items: _navItems,
        ),
      ),
    );
  }
}
