class FoodResource {
  final String name;
  final String address;
  final String phone;
  final String website;
  final String hours;
  final String type;
  final String imageUrl;
  final int rating;
  final double? latitude;
  final double? longitude;

  FoodResource({
    required this.name,
    required this.address,
    required this.phone,
    required this.website,
    required this.hours,
    required this.type,
    required this.imageUrl,
    required this.rating,
    this.latitude,
    this.longitude,
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
      latitude: json['latitude']?.toDouble(),
      longitude: json['longitude']?.toDouble(),
    );
  }
}
