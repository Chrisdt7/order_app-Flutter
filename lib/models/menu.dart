class Menu {
  final int id;
  final String name;
  final double price;
  final String description;
  final Category category;
  final String image;

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.description,
    required this.category,
    required this.image,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id_menus'],
      name: json['name'],
      price: json['price'] is int
          ? (json['price'] as int).toDouble()
          : json['price'] is String
              ? double.parse(json['price'])
              : (json['price'] as double),
      description: json['description'],
      category: CategoryExtension.fromString(json['category']),
      image: 'assets/menus/${json['image']}',
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id_menus': id,
      'name': name,
      'price': price,
      'description': description,
      'category': category.toString().split('.').last,
      'image': image.split('/').last,
    };
  }
}

enum Category { Foods, Drinks, Dessert, Others }

extension CategoryExtension on Category {
  static Category fromString(String categoryString) {
    switch (categoryString) {
      case 'Foods':
        return Category.Foods;
      case 'Drinks':
        return Category.Drinks;
      case 'Dessert':
        return Category.Dessert;
      case 'Others':
        return Category.Others;
      default:
        throw Exception('Unknown category: $categoryString');
    }
  }
}
