class Issue {
  final String id;
  final String title;
  final String description;
  final List<String> images;
  final String status;
  final String category;
  final Map<String, dynamic> gps;
  final String city;
  final String? contractorId;
  final DateTime createdAt;

  Issue({
    required this.id,
    required this.title,
    required this.description,
    required this.images,
    required this.status,
    required this.category,
    required this.gps,
    required this.city,
    this.contractorId,
    required this.createdAt,
  });

  factory Issue.fromJson(Map<String, dynamic> json) {
    List<String> parsedImages = [];
    if (json['images'] != null) {
      if (json['images'] is List) {
        parsedImages = List<String>.from(json['images']);
      } else if (json['images'] is String) {
        parsedImages = [json['images']];
      }
    }

    return Issue(
      id: json['_id'] ?? '',
      title: json['title'] ?? 'No Title',
      description: json['description'] ?? 'No Description',
      images: parsedImages,
      status: json['status'] ?? 'reported',
      category: json['category'] ?? 'General',
      gps: json['gps'] ?? {'lat': 0.0, 'lng': 0.0, 'address': ''},
      city: json['city'] ?? '',
      contractorId: json['contractorId'] is Map 
          ? json['contractorId']['_id'] 
          : json['contractorId'],
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
    );
  }
}
