import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/service_item.dart';

class DataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Future<void> seedData() async {
    await _db.collection('providers').doc('test_provider_1').set({
      'id': 'test_provider_1',
      'fullName': 'Kenean Hailu',
      'email': 'kenean@example.com',
      'phone': '0911223344',
      'companyName': 'Kenean Technical Services',
      'licenseNumber': 'LIC-1001',
      'slug': 'kenean-tech',
      'createdAt': DateTime.now().toIso8601String(),
    });

    await _db.collection('providers').doc('test_provider_2').set({
      'id': 'test_provider_2',
      'fullName': 'Helen Gebre',
      'email': 'helen@example.com',
      'phone': '0922334455',
      'companyName': 'Helen Beauty Clinic',
      'licenseNumber': 'LIC-2002',
      'slug': 'helen-beauty',
      'createdAt': DateTime.now().toIso8601String(),
    });

    final providerId = 'test_provider_1';

    final categories = [
      {
        'id': 'cat_maint_001',
        'title': 'Home Maintenance',
        'desc': 'Reliable plumbing, electrical and repair services.',
        'icon': 'https://picsum.photos/seed/maint/100/100'
      },
      {
        'id': 'cat_beauty_002',
        'title': 'Beauty & Salon',
        'desc': 'Professional hair styling and skincare treatments.',
        'icon': 'https://picsum.photos/seed/beauty/100/100'
      },
      {
        'id': 'cat_consult_003',
        'title': 'Consultation',
        'desc': 'Expert advice from certified industry professionals.',
        'icon': 'https://picsum.photos/seed/consult/100/100'
      },
    ];

    for (var cat in categories) {
      await _db.collection('categories').doc(cat['id']!).set(ServiceCategory(
            id: cat['id']!,
            providerId: providerId,
            title: cat['title']!,
            description: cat['desc']!,
            iconUrl: cat['icon']!,
            status: 'active',
          ).toMap());

      if (cat['id'] == 'cat_maint_001') {
        await _addService(
            'svc_flush_01', cat['id']!, providerId, 'Emergency Plumbing', 75.0,
            description:
                'Fix leaks, burst pipes, and drainage issues instantly.');
        await _addService('svc_wire_02', cat['id']!, providerId,
            'Electrical Safety Check', 120.0,
            vat: 15,
            description: 'Full inspection of home wiring and fuse box.');
      } else if (cat['id'] == 'cat_beauty_002') {
        await _addService(
            'svc_hair_03', cat['id']!, providerId, 'Premium Hair Styling', 45.0,
            description: 'Custom cut and style by master stylist.');
        await _addService(
            'svc_skin_04', cat['id']!, providerId, 'Deep Glow Facial', 90.0,
            vat: 15,
            discount: 15,
            description: 'Rejuvenating skin treatment with organic products.');
      } else {
        await _addService(
            'svc_legal_05', cat['id']!, providerId, 'Legal Consultation', 200.0,
            description: '1-hour comprehensive legal strategy session.');
        await _addService(
            'svc_it_06', cat['id']!, providerId, 'Tech Strategy Audit', 150.0,
            discount: 25,
            description: 'Full audit of your business IT infrastructure.');
      }
    }
  }

  Future<void> _addService(String id, String categoryId, String providerId,
      String name, double price,
      {double vat = 0, double discount = 0, String description = ''}) async {
    await _db.collection('services').doc(id).set(ServiceItem(
          id: id,
          providerId: providerId,
          categoryId: categoryId,
          serviceName: name,
          basePrice: price,
          vatPercent: vat,
          discountAmount: discount,
          description: description,
          imageUrl: 'https://picsum.photos/seed/$id/400/300',
        ).toMap());
  }
}
