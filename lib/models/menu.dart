import 'package:hive/hive.dart';

part 'menu.g.dart';

@HiveType(typeId: 1)
class Menu {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final String name;

  @HiveField(2)
  final double price;

  @HiveField(3)
  final String categoryId;

  @HiveField(4)
  final String? imagePath;

  @HiveField(5)
  final bool isEnabled;

  Menu({
    required this.id,
    required this.name,
    required this.price,
    required this.categoryId,
    this.imagePath,
    this.isEnabled = true,
  });

  factory Menu.fromJson(Map<String, dynamic> json) {
    return Menu(
      id: json['id'] as String,
      name: json['name'] as String,
      price: (json['price'] as num).toDouble(),
      categoryId: json['categoryId'] as String,
      imagePath: json['imagePath'] as String?,
      isEnabled: json['isEnabled'] as bool? ?? true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'price': price,
      'categoryId': categoryId,
      'imagePath': imagePath,
      'isEnabled': isEnabled,
    };
  }
}
