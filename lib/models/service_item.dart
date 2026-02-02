class ServiceItem {
  final String id;
  final String providerId;
  final String categoryId;
  final String serviceName;
  final double basePrice;
  final double vatPercent;
  final double discountAmount;
  final String? imageUrl;
  final String description;

  ServiceItem({
    required this.id,
    required this.providerId,
    required this.categoryId,
    required this.serviceName,
    required this.basePrice,
    required this.vatPercent,
    required this.discountAmount,
    required this.description,
    this.imageUrl,
  });

  double get totalPrice {
    double vatAmount = basePrice * (vatPercent / 100);
    double total = (basePrice + vatAmount) - discountAmount;
    return total < 0 ? 0 : total;
  }

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'categoryId': categoryId,
      'serviceName': serviceName,
      'basePrice': basePrice,
      'vatPercent': vatPercent,
      'discountAmount': discountAmount,
      'imageUrl': imageUrl,
      'description': description,
    };
  }

  factory ServiceItem.fromMap(Map<String, dynamic> map, String id) {
    return ServiceItem(
      id: id,
      providerId: map['providerId'] ?? '',
      categoryId: map['categoryId'] ?? '',
      serviceName: map['serviceName'] ?? '',
      basePrice: (map['basePrice'] ?? 0).toDouble(),
      vatPercent: (map['vatPercent'] ?? 0).toDouble(),
      discountAmount: (map['discountAmount'] ?? 0).toDouble(),
      description: map['description'] ?? '',
      imageUrl: map['imageUrl'] as String?,
    );
  }
}
