import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../utils/styles.dart';
import '../../utils/seeder.dart';

import 'edit_category_screen.dart';
import 'service_list_screen.dart'; // Will create next

class DashboardScreen extends StatelessWidget {
  DashboardScreen({super.key});

  final AuthService _auth = AuthService();
  final DbService _db = DbService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Dashboard',
          style: AppTextStyles.header.copyWith(fontSize: 20),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.cloud_upload),
            tooltip: 'Seed Data',
            onPressed: () async {
              try {
                // Determine if we should import dynamically or if it's already available.
                // Since I cannot modify imports easily in replace_file_content without context,
                // I will assume I can add the action and then I might need to fix imports if I missed it.
                // However, let's just use the `DataSeeder` class.
                await DataSeeder().seedData();
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Data Seeded Successfully!')),
                );
              } catch (e) {
                ScaffoldMessenger.of(
                  context,
                ).showSnackBar(SnackBar(content: Text('Error: $e')));
              }
            },
          ),
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await _auth.logout();
              // AuthWrapper will handle navigation
            },
          ),
        ],
      ),
      body: StreamBuilder<List<ServiceCategory>>(
        stream: _db.getCategories(),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final categories = snapshot.data ?? [];

          if (categories.isEmpty) {
            return Center(
              child: Text(
                'No categories found. Create one!',
                style: AppTextStyles.bodySecondary,
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(16),
            itemCount: categories.length,
            itemBuilder: (context, index) {
              final category = categories[index];
              return Card(
                margin: const EdgeInsets.only(bottom: 12),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor: AppColors.primary.withAlpha(25),
                    child: const Icon(Icons.category, color: AppColors.primary),
                  ),
                  title: Text(
                    category.title,
                    style: AppTextStyles.subHeader.copyWith(fontSize: 16),
                  ),
                  subtitle: Text(
                    category.description,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                  trailing: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      IconButton(
                        icon: const Icon(Icons.edit, color: Colors.blue),
                        onPressed: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) =>
                                  EditCategoryScreen(category: category),
                            ),
                          );
                        },
                      ),
                      IconButton(
                        icon: const Icon(Icons.delete, color: Colors.red),
                        onPressed: () {
                          // Confirm delete
                          showDialog(
                            context: context,
                            builder: (ctx) => AlertDialog(
                              title: const Text('Delete Category?'),
                              content: const Text(
                                'This action cannot be undone.',
                              ),
                              actions: [
                                TextButton(
                                  onPressed: () => Navigator.pop(ctx),
                                  child: const Text('Cancel'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _db.deleteCategory(category.id);
                                    Navigator.pop(ctx);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          );
                        },
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                  onTap: () {
                    // Go to Services for this category
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (_) => ServiceListScreen(category: category),
                      ),
                    );
                  },
                ),
              );
            },
          );
        },
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const EditCategoryScreen()),
          );
        },
        label: const Text('New Category'),
        icon: const Icon(Icons.add),
        backgroundColor: AppColors.primary,
        foregroundColor: Colors.white,
      ),
    );
  }
}
