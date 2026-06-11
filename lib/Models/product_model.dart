import 'dart:convert';

class ProductModel {
  final String name;
  final String description;
  final double price;

  ProductModel({
    required this.name,
    required this.description,
    required this.price,
  });

  // object to map
  Map<String, dynamic> toMap() {
    return {
      'name': name,
      'description': description,
      'price': price,
    };
  }

  // map to object
  factory ProductModel.fromMap(Map<String, dynamic> map) {
    double parsedPrice;
    final dynamic rawPrice = map['price'];
    if (rawPrice == null) {
      parsedPrice = 0.0;
    } else if (rawPrice is num) {
      parsedPrice = rawPrice.toDouble();
    } else {
      parsedPrice = double.tryParse(rawPrice.toString()) ?? 0.0;
    }

    return ProductModel(
      name: map['name']?.toString() ?? '',
      description: map['description']?.toString() ?? '',
      price: parsedPrice,
    );
  }

  // object to json string
  String toJson() => json.encode(toMap());

  // json string to object
  factory ProductModel.fromJson(String source) {
    final decoded = json.decode(source);
    return ProductModel.fromMap(Map<String, dynamic>.from(decoded as Map));
  }
}
