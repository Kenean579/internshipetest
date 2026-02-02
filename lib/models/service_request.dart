class ServiceRequest {
  final String id;
  final String serviceId;
  final String serviceName; // snapshot for history
  final double totalPrice; // snapshot for history
  final String customerName;
  final String customerPhone;
  final String customerAddress;
  final String status; // 'pending', 'completed'
  final DateTime createdAt;

  ServiceRequest({
    required this.id,
    required this.serviceId,
    required this.serviceName,
    required this.totalPrice,
    required this.customerName,
    required this.customerPhone,
    required this.customerAddress,
    required this.status,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'serviceId': serviceId,
      'serviceName': serviceName,
      'totalPrice': totalPrice,
      'customerName': customerName,
      'customerPhone': customerPhone,
      'customerAddress': customerAddress,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ServiceRequest.fromMap(Map<String, dynamic> map, String id) {
    return ServiceRequest(
      id: id,
      serviceId: map['serviceId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      totalPrice: (map['totalPrice'] ?? 0).toDouble(),
      customerName: map['customerName'] ?? '',
      customerPhone: map['customerPhone'] ?? '',
      customerAddress: map['customerAddress'] ?? '',
      status: map['status'] ?? 'pending',
      createdAt: DateTime.parse(
        map['createdAt'] ?? DateTime.now().toIso8601String(),
      ),
    );
  }
}
