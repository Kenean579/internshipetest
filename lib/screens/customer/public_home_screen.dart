import 'package:flutter/material.dart';
import '../../models/category.dart';
import '../../models/service_item.dart';
import '../../services/db_service.dart';
import '../../utils/styles.dart';
import 'request_form_screen.dart';
import 'package:intl/intl.dart';

class PublicHomeScreen extends StatelessWidget {
  PublicHomeScreen({super.key});

  final DbService _db = DbService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'Service Catalog',
          style: AppTextStyles.header.copyWith(fontSize: 20),
        ),
        centerTitle: true,
      ),
      body: StreamBuilder<List<ServiceCategory>>(
        stream: _db.getCategories(),
        builder: (context, catSnapshot) {
          if (catSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          final categories = catSnapshot.data ?? [];

          return StreamBuilder<List<ServiceItem>>(
            stream: _db.getServices(),
            builder: (context, servSnapshot) {
              if (servSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              }
              final allServices = servSnapshot.data ?? [];

              return ListView.builder(
                padding: const EdgeInsets.all(16),
                itemCount: categories.length,
                itemBuilder: (context, index) {
                  final category = categories[index];
                  final categoryServices = allServices
                      .where((s) => s.categoryId == category.id)
                      .toList();

                  if (categoryServices.isEmpty) return const SizedBox.shrink();

                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 8),
                        child: Row(
                          children: [
                            if (category.iconUrl.isNotEmpty) ...[
                              SizedBox(
                                width: 24,
                                height: 24,
                                child: Image.network(
                                  category.iconUrl,
                                  errorBuilder: (_, __, ___) =>
                                      const Icon(Icons.category),
                                ),
                              ),
                              const SizedBox(width: 8),
                            ],
                            Text(
                              category.title,
                              style: AppTextStyles.header.copyWith(
                                fontSize: 20,
                              ),
                            ),
                          ],
                        ),
                      ),
                      ...categoryServices.map(
                        (service) => Card(
                          margin: const EdgeInsets.only(bottom: 12),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: ListTile(
                            title: Text(
                              service.serviceName,
                              style: AppTextStyles.subHeader,
                            ),
                            subtitle: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  category.description,
                                  style: AppTextStyles.bodySecondary.copyWith(
                                    fontSize: 12,
                                  ),
                                ),
                                const SizedBox(height: 4),
                                Text(
                                  'Price: ${NumberFormat.currency(symbol: '\$').format(service.totalPrice)}',
                                  style: AppTextStyles.body.copyWith(
                                    fontWeight: FontWeight.bold,
                                    color: AppColors.primary,
                                  ),
                                ),
                              ],
                            ),
                            trailing: ElevatedButton(
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 16,
                                ),
                              ),
                              onPressed: () {
                                Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (_) =>
                                        RequestFormScreen(service: service),
                                  ),
                                );
                              },
                              child: const Text('Request'),
                            ),
                          ),
                        ),
                      ),
                      const SizedBox(height: 16),
                    ],
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
