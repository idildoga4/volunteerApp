import 'package:flutter/material.dart';
import '../models/models.dart';
import '../widgets/shared_widgets.dart';
import '../widgets/theme.dart';
import 'task_detail_screen.dart';

class FavoritesScreen extends StatelessWidget {
  final List<Task> favoriteTasks;
  final ValueChanged<String> onFavoriteToggle;

  const FavoritesScreen({super.key, required this.favoriteTasks, required this.onFavoriteToggle});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).brightness == Brightness.dark ? AppTheme.darkSurface : AppTheme.surface,

      appBar: AppBar(title: const Text("Favorites")),

      body: favoriteTasks.isEmpty
          ? const Center(child: Text("No favorite tasks yet", style: TextStyle(fontSize: 16)))
          : ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: favoriteTasks.length,

              itemBuilder: (_, i) {
                return TaskCard(
                  task: favoriteTasks[i],

                  isFavorite: true,

                  onFavoriteToggle: () => onFavoriteToggle(favoriteTasks[i].id),

                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(builder: (_) => TaskDetailScreen(taskId: favoriteTasks[i].id)));
                  },
                );
              },
            ),
    );
  }
}
