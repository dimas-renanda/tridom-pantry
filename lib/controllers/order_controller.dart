import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  final RxList<Order> orders = <Order>[].obs;
  late Box<Order> _orderBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    _orderBox = await Hive.openBox<Order>('orders');
    _loadOrders();
  }

  void _loadOrders() {
    orders.value = _orderBox.values.toList();
  }

  void createOrder(
    List<OrderItem> items,
    double total, {
    String? ipAddress,
    String? username,
  }) {
    final order = Order(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      total: total,
      status: 'new',
      createdAt: DateTime.now(),
      ipAddress: ipAddress,
      username: username,
    );
    orders.add(order);
    _orderBox.put(order.id, order);
  }

  void updateOrderStatus(String orderId, String status) {
    final orderIndex = orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      orders[orderIndex].status = status;
      _orderBox.put(orderId, orders[orderIndex]);
      orders.refresh();
    }
  }

  List<Order> getAllOrders() {
    return orders;
  }

  Order? getOrderById(String id) {
    try {
      return orders.firstWhere((order) => order.id == id);
    } catch (e) {
      return null;
    }
  }

  void deleteOrder(String id) {
    orders.removeWhere((order) => order.id == id);
    _orderBox.delete(id);
  }
}
