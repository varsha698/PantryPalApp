class FoodResource {
  final String name;
  final String address;
  final String phone;
  final String website;
  final String hours;
  final String type;
  final String imageUrl;
  final int rating;

  FoodResource({
    required this.name,
    required this.address,
    required this.phone,
    required this.website,
    required this.hours,
    required this.type,
    required this.imageUrl,
    required this.rating,
  });

  factory FoodResource.fromJson(Map<String, dynamic> json) {
    return FoodResource(
      name: json['name'] ?? '',
      address: json['address'] ?? '',
      phone: json['phone'] ?? '',
      website: json['website'] ?? '',
      hours: json['hours'] ?? '',
      type: json['type'] ?? '',
      imageUrl: json['image'] ?? '',
      rating: json['rating'] ?? 0,
    );
  }
}
