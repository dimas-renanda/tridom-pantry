import 'package:get/get.dart';
import 'package:hive/hive.dart';
import 'dart:io';
import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_ringtone_player/flutter_ringtone_player.dart';
import '../models/order.dart';

class OrderController extends GetxController {
  final RxList<Order> orders = <Order>[].obs;
  final RxList<Order> orderHistory = <Order>[].obs;
  late Box<Order> _orderBox;
  late Box<Order> _historyBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    _orderBox = await Hive.openBox<Order>('orders');
    _historyBox = await Hive.openBox<Order>('order_history');
    _loadOrders();
    _loadHistory();
  }

  void _loadOrders() {
    orders.value = _orderBox.values.toList();
    print('OrderController: Loaded ${orders.length} orders from database');
  }

  void _loadHistory() {
    orderHistory.value = _historyBox.values.toList();
    print('OrderController: Loaded ${orderHistory.length} orders from history');
    for (var order in orderHistory) {
      print('  - History Order: ${order.id}, Status: ${order.status}');
    }

    // Sync any misplaced "posted" orders from active orders to history
    _syncPostedOrders();
  }

  void _syncPostedOrders() {
    final postedOrders =
        _orderBox.values.where((order) => order.status == 'posted').toList();

    if (postedOrders.isNotEmpty) {
      print(
        'OrderController: Found ${postedOrders.length} misplaced posted orders in active database',
      );

      for (var order in postedOrders) {
        print('  - Moving order ${order.id} to history');

        // Add to history
        _historyBox.put(order.id, order);
        if (!orderHistory.any((o) => o.id == order.id)) {
          orderHistory.add(order);
        }

        // Remove from active orders
        _orderBox.delete(order.id);
        orders.removeWhere((o) => o.id == order.id);
      }

      orderHistory.refresh();
      orders.refresh();

      print(
        'OrderController: Sync complete. History now has ${orderHistory.length} orders',
      );
    }
  }

  void createOrder(
    List<OrderItem> items,
    double total, {
    String? ipAddress,
    String? username,
    String? docNo,
    String? notes,
  }) {
    final order = Order(
      id:
          docNo != null && docNo.isNotEmpty
              ? docNo
              : DateTime.now().millisecondsSinceEpoch.toString(),
      items: items,
      total: total,
      status: 'new',
      createdAt: DateTime.now(),
      ipAddress: ipAddress,
      username: username,
      notes: notes != null && notes.isNotEmpty ? notes : '-',
    );
    orders.add(order);
    _orderBox.put(order.id, order);

    // Play notification feedback
    _playNotificationSound();
  }

  Future<void> _playNotificationSound() async {
    try {
      // Play device's default notification sound
      await FlutterRingtonePlayer().playNotification();

      // Show visual notification
      Get.snackbar(
        '🔔 New Order',
        'New order received!',
        snackPosition: SnackPosition.TOP,
        backgroundColor: Colors.green,
        colorText: Colors.white,
        duration: const Duration(seconds: 2),
      );
    } catch (e) {
      print('Error playing notification: $e');
    }
  }

  void updateOrderStatus(String orderId, String status) {
    final orderIndex = orders.indexWhere((order) => order.id == orderId);
    if (orderIndex != -1) {
      final order = orders[orderIndex];

      // If status is being set to 'posted', use postToHistory instead
      if (status == 'posted') {
        print(
          'OrderController: Status changed to posted - moving to history instead',
        );
        postToHistory(orderId);
        return;
      }

      // Update status
      order.status = status;
      _orderBox.put(orderId, order);
      orders.refresh();

      // Trigger client notifications if order has IP address
      if (order.ipAddress != null && order.ipAddress!.isNotEmpty) {
        print(
          'OrderController: Triggering notifications to ${order.ipAddress}',
        );
        _triggerClientNotifications(order.ipAddress!);
      } else {
        print(
          'OrderController: No IP address for order $orderId - skipping notifications',
        );
      }
    }
  }

  Future<void> _triggerClientNotifications(String ipAddress) async {
    print('OrderController: Starting notifications to $ipAddress');
    // Call both /refresh and /notifyorder endpoints
    await Future.wait([
      _triggerNotificationRequest(ipAddress, '/refresh'),
      _triggerNotificationRequest(ipAddress, '/notifyorder'),
    ]);
    print('OrderController: Completed notifications to $ipAddress');
  }

  Future<void> _triggerNotificationRequest(
    String ipAddress,
    String endpoint,
  ) async {
    try {
      // Clean up IP address - remove any http:// prefix if present
      String cleanIp = ipAddress;
      if (cleanIp.startsWith('http://')) {
        cleanIp = cleanIp.replaceFirst('http://', '');
      }
      if (cleanIp.startsWith('https://')) {
        cleanIp = cleanIp.replaceFirst('https://', '');
      }
      // Remove any port suffix
      if (cleanIp.contains(':')) {
        cleanIp = cleanIp.split(':')[0];
      }

      final fullUrl = 'http://$cleanIp:8080$endpoint';
      print('OrderController: Sending $endpoint to $fullUrl');

      final client = HttpClient();
      final uri = Uri.parse(fullUrl);

      final request = await client.getUrl(uri);
      request.headers.set('Content-Type', 'application/json');

      // Set a 15-second timeout to avoid blocking if the client is unreachable
      final response = await request.close().timeout(
        Duration(seconds: 15),
        onTimeout: () {
          print(
            'OrderController: ⚠️ Request to $fullUrl timed out after 15 seconds',
          );
          client.close();
          throw TimeoutException('Request timeout');
        },
      );

      print(
        'OrderController: ✅ Notification sent to $fullUrl - Status: ${response.statusCode}',
      );
      await response.drain();
      client.close();
    } catch (e) {
      print(
        'OrderController: ❌ Failed to send notification to $ipAddress$endpoint: $e',
      );
      // Don't throw error - this is a background notification, not critical
    }
  }

  List<Order> getAllOrders() {
    return orders;
  }

  List<Order> getAllHistory() {
    return orderHistory;
  }

  void postToHistory(String orderId) {
    print('OrderController: Attempting to post order $orderId to history');
    final orderIndex = orders.indexWhere((order) => order.id == orderId);

    if (orderIndex != -1) {
      final order = orders[orderIndex];
      print(
        'OrderController: Found order ${order.id}, current status: ${order.status}',
      );

      // Update status to POSTED
      order.status = 'posted';
      print('OrderController: Updated status to: ${order.status}');

      // Add to history
      _historyBox.put(order.id, order);
      orderHistory.add(order);
      print(
        'OrderController: Added to history box and list. History count: ${orderHistory.length}',
      );

      // Remove from active orders
      orders.removeAt(orderIndex);
      _orderBox.delete(orderId);
      print(
        'OrderController: Removed from active orders. Active count: ${orders.length}',
      );

      orderHistory.refresh();
      orders.refresh();

      print('OrderController: Order $orderId successfully posted to history');
    } else {
      print(
        'OrderController: ERROR - Order $orderId not found in active orders',
      );
    }
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

  // Delete history with optional date filter
  int deleteHistory({DateTime? endDate}) {
    List<Order> ordersToDelete;

    if (endDate != null) {
      // Filter orders created at or before endDate
      ordersToDelete =
          orderHistory.where((order) {
            return order.createdAt.isBefore(endDate) ||
                order.createdAt.isAtSameMomentAs(endDate);
          }).toList();

      print(
        'OrderController: Deleting ${ordersToDelete.length} history orders until ${endDate.toIso8601String()}',
      );
    } else {
      // Delete all history
      ordersToDelete = List.from(orderHistory);
      print(
        'OrderController: Deleting all ${ordersToDelete.length} history orders',
      );
    }

    // Delete from database and list
    for (var order in ordersToDelete) {
      _historyBox.delete(order.id);
      orderHistory.removeWhere((o) => o.id == order.id);
    }

    orderHistory.refresh();

    print('OrderController: Deleted ${ordersToDelete.length} history orders');
    return ordersToDelete.length;
  }

  // Manual sync method that can be called to fix misplaced orders
  void syncPostedOrders() {
    _syncPostedOrders();
  }
}
