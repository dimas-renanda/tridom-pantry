import 'package:hive/hive.dart';

part 'order.g.dart';

@HiveType(typeId: 2)
class Order {
  @HiveField(0)
  final String id;

  @HiveField(1)
  final List<OrderItem> items;

  @HiveField(2)
  final double total;

  @HiveField(3)
  String status; // new, process, done

  @HiveField(4)
  final DateTime createdAt;

  @HiveField(5)
  final String? ipAddress;

  @HiveField(6)
  final String? username;

  Order({
    required this.id,
    required this.items,
    required this.total,
    required this.status,
    required this.createdAt,
    this.ipAddress,
    this.username,
  });

  factory Order.fromJson(Map<String, dynamic> json) {
    return Order(
      id: json['id'] as String,
      items:
          (json['items'] as List)
              .map((item) => OrderItem.fromJson(item))
              .toList(),
      total: (json['total'] as num).toDouble(),
      status: json['status'] as String,
      createdAt: DateTime.parse(json['createdAt'] as String),
      ipAddress: json['ipAddress'] as String?,
      username: json['username'] as String?,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'items': items.map((item) => item.toJson()).toList(),
      'total': total,
      'status': status,
      'createdAt': createdAt.toIso8601String(),
      'ipAddress': ipAddress,
      'username': username,
    };
  }
}

@HiveType(typeId: 3)
class OrderItem {
  @HiveField(0)
  final String menuId;

  @HiveField(1)
  final String menuName;

  @HiveField(2)
  final int quantity;

  @HiveField(3)
  final double price;

  OrderItem({
    required this.menuId,
    required this.menuName,
    required this.quantity,
    required this.price,
  });

  factory OrderItem.fromJson(Map<String, dynamic> json) {
    return OrderItem(
      menuId: json['menuId'] as String,
      menuName: json['menuName'] as String,
      quantity: json['quantity'] as int,
      price: (json['price'] as num).toDouble(),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'menuId': menuId,
      'menuName': menuName,
      'quantity': quantity,
      'price': price,
    };
  }
}
