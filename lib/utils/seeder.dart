import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/service_item.dart';
import 'package:uuid/uuid.dart';

class DataSeeder {
  final FirebaseFirestore _db = FirebaseFirestore.instance;
  final Uuid _uuid = const Uuid();

  Future<void> seedData() async {
    // 1. Categories
    final categories = [
      ServiceCategory(
        id: _uuid.v4(),
        title: 'Hair Salon',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/3050/3050222.png',
        description: 'Haircuts, styling, and coloring.',
        status: 'active',
      ),
      ServiceCategory(
        id: _uuid.v4(),
        title: 'Plumbing',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/3050/3050253.png',
        description: 'Pipe repairs and installation.',
        status: 'active',
      ),
      ServiceCategory(
        id: _uuid.v4(),
        title: 'Consulting',
        iconUrl: 'https://cdn-icons-png.flaticon.com/512/3050/3050275.png',
        description: 'Business and specialized consulting.',
        status: 'active',
      ),
    ];

    for (var cat in categories) {
      await _db.collection('categories').add(cat.toMap());

      // 2. Services for each category
      if (cat.title == 'Hair Salon') {
        await _addService(cat.id, 'Men\'s Haircut', 15.0);
        await _addService(cat.id, 'Women\'s Styling', 40.0, discount: 5.0);
      } else if (cat.title == 'Plumbing') {
        await _addService(cat.id, 'Leak Repair', 50.0);
        await _addService(cat.id, 'Faucet Installation', 80.0, vat: 10.0);
      } else if (cat.title == 'Consulting') {
        await _addService(cat.id, '1 Hour Consultation', 100.0);
      }
    }
  }

  Future<void> _addService(
    String catId,
    String name,
    double price, {
    double vat = 15.0,
    double discount = 0.0,
  }) async {
    final service = ServiceItem(
      id: _uuid.v4(),
      categoryId: catId,
      serviceName: name,
      basePrice: price,
      vatPercent: vat,
      discountAmount: discount,
      imageUrl: '',
    );
    await _db.collection('services').add(service.toMap());
  }
}
