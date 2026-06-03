class Restaurant {
  final String id;
  final String name;
  final String? address;
  final String? image;
  final double? rating;

  Restaurant({
    required this.id,
    required this.name,
    this.address,
    this.image,
    required this.rating,
  });

  factory Restaurant.fromJson(Map<String, dynamic> json){
    return Restaurant(
      id: json["restaurant_id"] ?? "",
      name: json["restaurant_name"] ?? "",
      address: json["address"],
      image: json["image"],
      rating: (json["average_rating"] ?? 0).toDouble(),
    );
  }
}