import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import '../../models/service_request.dart';
import '../../services/db_service.dart';
import '../../utils/styles.dart';
import 'package:intl/intl.dart';

class ProviderRequestsScreen extends StatelessWidget {
  ProviderRequestsScreen({super.key});

  final DbService _db = DbService();

  @override
  Widget build(BuildContext context) {
    final user = FirebaseAuth.instance.currentUser;
    final String providerId = user?.uid ?? '';

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        title: Text(
          'SERVICE REQUESTS',
          style: AppTextStyles.header.copyWith(
            fontSize: 16,
            color: AppColors.textPrimary,
          ),
        ),
        backgroundColor: Colors.transparent,
      ),
      body: StreamBuilder<List<ServiceRequest>>(
        stream: _db.getRequests(providerId: providerId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }
          if (snapshot.hasError) {
            return Center(
              child: Padding(
                padding: const EdgeInsets.all(24),
                child: SelectableText(
                  'Error: ${snapshot.error}',
                  textAlign: TextAlign.center,
                  style: const TextStyle(
                      color: AppColors.textSecondary, fontSize: 13),
                ),
              ),
            );
          }

          final requests = snapshot.data ?? [];
          if (requests.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  const Icon(Icons.inbox_outlined,
                      size: 64, color: AppColors.border),
                  const SizedBox(height: 16),
                  Text('Queue is currently empty.',
                      style: AppTextStyles.bodySecondary),
                ],
              ),
            );
          }

          return ListView.builder(
            padding: const EdgeInsets.all(20),
            itemCount: requests.length,
            itemBuilder: (context, index) {
              final request = requests[index];
              final isPending = request.status == 'pending';
              final accentColor =
                  isPending ? AppColors.secondary : AppColors.primary;

              return Card(
                margin: const EdgeInsets.only(bottom: 20),
                shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(24)),
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Expanded(
                            child: Text(
                              request.serviceName.toUpperCase(),
                              style: const TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.bold,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 12, vertical: 6),
                            decoration: BoxDecoration(
                              color: accentColor.withValues(alpha: 0.1),
                              borderRadius: BorderRadius.circular(8),
                              border: Border.all(
                                  color: accentColor.withValues(alpha: 0.1)),
                            ),
                            child: Text(
                              request.status.toUpperCase(),
                              style: TextStyle(
                                color: accentColor,
                                fontWeight: FontWeight.bold,
                                fontSize: 10,
                                letterSpacing: 1,
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 16),
                      _buildInfoRow(Icons.person_outline, 'Customer',
                          request.customerName),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.phone_outlined, 'Contact',
                          request.customerPhone),
                      const SizedBox(height: 12),
                      _buildInfoRow(Icons.location_on_outlined, 'Location',
                          request.customerAddress),
                      const Divider(height: 48, color: AppColors.border),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                'CREATED AT',
                                style: TextStyle(
                                  fontSize: 9,
                                  color: AppColors.textLight
                                      .withValues(alpha: 0.7),
                                  letterSpacing: 1.5,
                                ),
                              ),
                              Text(
                                DateFormat('MMM dd, hh:mm a')
                                    .format(request.createdAt),
                                style: const TextStyle(
                                    fontSize: 12, fontWeight: FontWeight.w500),
                              ),
                            ],
                          ),
                          if (isPending)
                            ElevatedButton(
                              onPressed: () =>
                                  _updateStatus(context, request, 'completed'),
                              style: ElevatedButton.styleFrom(
                                backgroundColor: AppColors.primary,
                                foregroundColor: Colors.white,
                                shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(12)),
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 24, vertical: 12),
                              ),
                              child: const Text('COMPLETE',
                                  style:
                                      TextStyle(fontWeight: FontWeight.bold)),
                            ),
                        ],
                      ),
                    ],
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String label, String value) {
    return Row(
      children: [
        Icon(icon, size: 16, color: AppColors.textSecondary),
        const SizedBox(width: 12),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(label.toUpperCase(),
                style: TextStyle(
                    color: AppColors.textLight, fontSize: 9, letterSpacing: 1)),
            Text(value,
                style: const TextStyle(
                    color: AppColors.textPrimary,
                    fontSize: 13,
                    fontWeight: FontWeight.w500)),
          ],
        ),
      ],
    );
  }

  void _updateStatus(
      BuildContext context, ServiceRequest request, String newStatus) async {
    try {
      await _db.updateRequestStatus(request.id, newStatus);
      if (context.mounted) {
        AppUIHelpers.showSnackBar(context, 'Request marked as $newStatus',
            isError: false);
      }
    } catch (e) {
      if (context.mounted) {
        AppUIHelpers.showSnackBar(context, e.toString());
      }
    }
  }
}
