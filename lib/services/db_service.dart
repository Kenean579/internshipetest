import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/category.dart';
import '../models/service_item.dart';
import '../models/service_request.dart';

class DbService {
  final FirebaseFirestore _db = FirebaseFirestore.instance;

  Stream<List<ServiceCategory>> getCategories({String? providerId}) {
    Query query = _db.collection('categories');
    if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceCategory.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addCategory(ServiceCategory category) async {
    await _db.collection('categories').add(category.toMap());
  }

  Future<void> updateCategory(ServiceCategory category) async {
    await _db
        .collection('categories')
        .doc(category.id)
        .update(category.toMap());
  }

  Future<void> deleteCategory(String categoryId) async {
    await _db.collection('categories').doc(categoryId).delete();
  }

  Stream<List<ServiceItem>> getServices(
      {String? categoryId, String? providerId}) {
    Query query = _db.collection('services');
    if (categoryId != null) {
      query = query.where('categoryId', isEqualTo: categoryId);
    }
    if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceItem.fromMap(doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> addService(ServiceItem service) async {
    await _db.collection('services').add(service.toMap());
  }

  Future<void> updateService(ServiceItem service) async {
    await _db.collection('services').doc(service.id).update(service.toMap());
  }

  Future<void> deleteService(String serviceId) async {
    await _db.collection('services').doc(serviceId).delete();
  }

  Future<void> submitRequest(ServiceRequest request) async {
    await _db.collection('requests').add(request.toMap());
  }

  Stream<List<ServiceRequest>> getRequests({String? providerId}) {
    Query query =
        _db.collection('requests').orderBy('createdAt', descending: true);

    if (providerId != null) {
      query = query.where('providerId', isEqualTo: providerId);
    }

    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        return ServiceRequest.fromMap(
            doc.data() as Map<String, dynamic>, doc.id);
      }).toList();
    });
  }

  Future<void> updateRequestStatus(String requestId, String status) async {
    await _db.collection('requests').doc(requestId).update({'status': status});
  }
}
