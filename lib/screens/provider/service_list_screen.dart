import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/service_item.dart';
import '../../services/db_service.dart';
import '../../utils/styles.dart';
import 'edit_service_screen.dart';
import 'package:intl/intl.dart';

class ServiceListScreen extends StatefulWidget {
  final ServiceCategory category;

  const ServiceListScreen({super.key, required this.category});

  @override
  State<ServiceListScreen> createState() => _ServiceListScreenState();
}

class _ServiceListScreenState extends State<ServiceListScreen> {
  final DbService _db = DbService();
  final TextEditingController _searchController = TextEditingController();
  String _searchQuery = '';

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(widget.category.title),
        actions: [
          IconButton(
            icon: const Icon(Icons.add),
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                  builder: (_) => EditServiceScreen(category: widget.category)),
            ),
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.all(16),
            child: TextField(
              controller: _searchController,
              decoration: const InputDecoration(
                hintText: 'Search services...',
                prefixIcon: Icon(Icons.search),
              ),
              onChanged: (v) => setState(() => _searchQuery = v.toLowerCase()),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<ServiceItem>>(
              stream: _db.getServices(categoryId: widget.category.id),
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return const Center(child: CircularProgressIndicator());
                }
                var services = snapshot.data ?? [];
                if (_searchQuery.isNotEmpty) {
                  services = services
                      .where((s) =>
                          s.serviceName.toLowerCase().contains(_searchQuery))
                      .toList();
                }

                if (services.isEmpty) {
                  return const Center(child: Text('No items found'));
                }

                return ListView.builder(
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  itemCount: services.length,
                  itemBuilder: (context, index) {
                    final service = services[index];
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
                          child: (service.imageUrl ?? '').isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(12),
                                  child: Image.network(
                                    service.imageUrl!,
                                    fit: BoxFit.cover,
                                    errorBuilder: (c, e, s) => const Icon(
                                        Icons.image_outlined,
                                        color: AppColors.textLight),
                                  ),
                                )
                              : const Icon(Icons.image_outlined,
                                  color: AppColors.textLight),
                        ),
                        title: Text(
                          service.serviceName,
                          style: AppTextStyles.subHeader,
                        ),
                        subtitle: Text(
                          'ETB ${NumberFormat('#,##0').format(service.totalPrice)}',
                          style: AppTextStyles.bodySecondary.copyWith(
                            color: AppColors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        onTap: () => Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => EditServiceScreen(
                                  category: widget.category, service: service)),
                        ),
                        trailing: IconButton(
                          icon: const Icon(Icons.delete_outline,
                              color: AppColors.error),
                          onPressed: () => _showDeleteDialog(context, service),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, ServiceItem service) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('REMOVE ITEM?'),
        content:
            const Text('This will permanently delete this service offering.'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(ctx), child: const Text('CANCEL')),
          ElevatedButton(
            onPressed: () {
              _db.deleteService(service.id);
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
