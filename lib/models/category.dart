class ServiceCategory {
  final String id;
  final String providerId;
  final String title;
  final String iconUrl;
  final String description;
  final String status;

  ServiceCategory({
    required this.id,
    required this.providerId,
    required this.title,
    required this.iconUrl,
    required this.description,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'providerId': providerId,
      'title': title,
      'iconUrl': iconUrl,
      'description': description,
      'status': status,
    };
  }

  factory ServiceCategory.fromMap(Map<String, dynamic> map, String id) {
    return ServiceCategory(
      id: id,
      providerId: map['providerId'] ?? '',
      title: map['title'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'active',
    );
  }
}
