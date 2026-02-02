class AppUser {
  final String id;
  final String fullName;
  final String email;
  final String phone;
  final String companyName;
  final String licenseNumber;
  final String? slug;

  AppUser({
    required this.id,
    required this.fullName,
    required this.email,
    required this.phone,
    required this.companyName,
    required this.licenseNumber,
    this.slug,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'fullName': fullName,
      'email': email,
      'phone': phone,
      'companyName': companyName,
      'licenseNumber': licenseNumber,
      'slug': slug ?? fullName.toLowerCase().replaceAll(' ', '-'),
    };
  }

  factory AppUser.fromMap(Map<String, dynamic> map, String id) {
    return AppUser(
      id: id,
      fullName: map['fullName'] ?? '',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      companyName: map['companyName'] ?? '',
      licenseNumber: map['licenseNumber'] ?? '',
      slug: map['slug'],
    );
  }
}
