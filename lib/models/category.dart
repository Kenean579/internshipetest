class ServiceCategory {
  final String id;
  final String title;
  final String iconUrl;
  final String description;
  final String status; // 'active' or 'inactive'

  ServiceCategory({
    required this.id,
    required this.title,
    required this.iconUrl,
    required this.description,
    required this.status,
  });

  Map<String, dynamic> toMap() {
    return {
      'title': title,
      'iconUrl': iconUrl,
      'description': description,
      'status': status,
    };
  }

  factory ServiceCategory.fromMap(Map<String, dynamic> map, String id) {
    return ServiceCategory(
      id: id,
      title: map['title'] ?? '',
      iconUrl: map['iconUrl'] ?? '',
      description: map['description'] ?? '',
      status: map['status'] ?? 'active',
    );
  }
}
