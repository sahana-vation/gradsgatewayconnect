class Lead {
  final String name;
  final String phone;
  final String email;
  final String status;
  final List<String> applicationStatuses; // Store only application statuses

  Lead({
    required this.name,
    required this.phone,
    required this.email,
    required this.status,
    required this.applicationStatuses,
  });

  factory Lead.fromJson(Map<String, dynamic> json) {
    return Lead(
      name: json['name'] ?? '',
      phone: json['phone'] ?? '',
      email: json['email'] ?? '',
      status: json['status'] ?? '',
      applicationStatuses: (json['applications'] as List<dynamic>?)
          ?.map((app) => app['application_status'] as String)
          .toList() ??
          [],
    );
  }
}
