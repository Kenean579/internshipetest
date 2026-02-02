import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../services/auth_service.dart';
import '../../services/db_service.dart';
import '../../utils/styles.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'edit_category_screen.dart';
import 'service_list_screen.dart';
import 'provider_requests_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  final AuthService _auth = AuthService();
  final DbService _db = DbService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String providerId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: const Text('DASHBOARD'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout_rounded),
            onPressed: () => _auth.logout(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            Row(
              children: [
                Expanded(
                  child: _buildActionCard(
                    context,
                    'REQUESTS',
                    Icons.notifications_active_outlined,
                    AppColors.secondary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => ProviderRequestsScreen()),
                    ),
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: _buildActionCard(
                    context,
                    'NEW CATEGORY',
                    Icons.add_box_outlined,
                    AppColors.primary,
                    () => Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const EditCategoryScreen()),
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            _buildActionCard(
              context,
              'SHARE CATALOG',
              Icons.share_outlined,
              AppColors.accent,
              () async {
                final userData = await AuthService().getCurrentUserData();
                if (userData != null && context.mounted) {
                  final link =
                      'https://servicehub.app/services/${userData.slug}';
                  AppUIHelpers.showSnackBar(
                    context,
                    'Public Link Generated: $link',
                    isError: false,
                  );
                }
              },
            ),
            const SizedBox(height: 32),
            TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search categories...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
            const SizedBox(height: 32),
            const Divider(),
            const SizedBox(height: 16),
            StreamBuilder<List<ServiceCategory>>(
              stream: _db.getCategories(providerId: providerId),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var categories = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  categories = categories
                      .where((cat) =>
                          cat.title.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (categories.isEmpty) {
                  return const Padding(
                    padding: EdgeInsets.symmetric(vertical: 48),
                    child: Text('No categories found'),
                  );
                }

                return ListView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  itemCount: categories.length,
                  itemBuilder: (context, index) {
                    final category = categories[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 12),
                      child: ListTile(
                        leading: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: AppColors.background,
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(color: AppColors.border),
                          ),
                          child: category.iconUrl.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    category.iconUrl,
                                    fit: BoxFit.cover,
                                    errorBuilder:
                                        (context, error, stackTrace) =>
                                            const Icon(Icons.category_outlined,
                                                color: AppColors.textLight),
                                  ),
                                )
                              : const Icon(Icons.category_outlined,
                                  color: AppColors.textLight),
                        ),
                        title: Text(
                          category.title,
                          style: AppTextStyles.subHeader,
                        ),
                        subtitle: Text(
                          category.description,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySecondary,
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) =>
                                  ServiceListScreen(category: category)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.more_vert),
                          onPressed: () => _showMenu(context, category),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildActionCard(BuildContext context, String title, IconData icon,
      Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(24),
        border: Border.all(color: AppColors.border),
        boxShadow: AppColors.shadowSm,
      ),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(24),
        child: Padding(
          padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 16),
          child: Column(
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: color.withValues(alpha: 0.1),
                  shape: BoxShape.circle,
                ),
                child: Icon(icon, color: color, size: 28),
              ),
              const SizedBox(height: 12),
              Text(title,
                  style: AppTextStyles.subHeader.copyWith(
                    fontSize: 12,
                    letterSpacing: 0.5,
                  )),
            ],
          ),
        ),
      ),
    );
  }

  void _showMenu(BuildContext context, ServiceCategory category) {
    showModalBottomSheet(
      context: context,
      builder: (context) => Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          ListTile(
            leading: const Icon(Icons.edit),
            title: const Text('EDIT'),
            onTap: () {
              Navigator.pop(context);
              Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (_) => EditCategoryScreen(category: category)));
            },
          ),
          ListTile(
            leading: const Icon(Icons.delete, color: AppColors.error),
            title:
                const Text('DELETE', style: TextStyle(color: AppColors.error)),
            onTap: () {
              Navigator.pop(context);
              _showDeleteDialog(context, category);
            },
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ServiceCategory category) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('DELETE CATEGORY?'),
        content: const Text('This will remove all items in this category.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              _db.deleteCategory(category.id);
              Navigator.pop(ctx);
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('DELETE'),
          ),
        ],
      ),
    );
  }
}
