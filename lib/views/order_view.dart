import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/order_controller.dart';

class OrderView extends StatelessWidget {
  final OrderController orderController = Get.find();

  OrderView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Orders'), backgroundColor: Colors.blue),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'All Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                // Filter to show only 'new' and 'process' orders
                final activeOrders =
                    orderController.orders
                        .where(
                          (order) =>
                              order.status == 'new' ||
                              order.status == 'process',
                        )
                        .toList();

                return activeOrders.isEmpty
                    ? const Center(child: Text('No active orders'))
                    : ListView.builder(
                      itemCount: activeOrders.length,
                      itemBuilder: (context, index) {
                        final order = activeOrders[index];
                        return Card(
                          elevation: 4,
                          margin: const EdgeInsets.only(bottom: 16),
                          child: Padding(
                            padding: const EdgeInsets.all(16.0),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Row(
                                  mainAxisAlignment:
                                      MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      'Order #${order.id}',
                                      style: const TextStyle(
                                        fontSize: 16,
                                        fontWeight: FontWeight.bold,
                                      ),
                                    ),
                                    Row(
                                      children: [
                                        Chip(
                                          label: Text(
                                            order.status.toUpperCase(),
                                          ),
                                          backgroundColor:
                                              order.status == 'new'
                                                  ? Colors.blue
                                                  : order.status == 'process'
                                                  ? Colors.orange
                                                  : Colors.green,
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 8),
                                const Text(
                                  'Items:',
                                  style: TextStyle(fontWeight: FontWeight.bold),
                                ),
                                ...order.items.map(
                                  (item) => Padding(
                                    padding: const EdgeInsets.only(
                                      left: 16,
                                      top: 4,
                                    ),
                                    child: Text(
                                      '${item.menuName} x${item.quantity} - Rp ${NumberFormat('#,###', 'id_ID').format((item.price * item.quantity).toInt())}',
                                    ),
                                  ),
                                ),
                                const SizedBox(height: 8),
                                Text(
                                  'Total: Rp ${NumberFormat('#,###', 'id_ID').format(order.total.toInt())}',
                                  style: const TextStyle(
                                    fontSize: 16,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 8),
                                if (order.username != null) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.person,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'User: ${order.username}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                if (order.ipAddress != null) ...[
                                  Row(
                                    children: [
                                      const Icon(
                                        Icons.computer,
                                        size: 16,
                                        color: Colors.grey,
                                      ),
                                      const SizedBox(width: 4),
                                      Text(
                                        'IP: ${order.ipAddress}',
                                        style: const TextStyle(fontSize: 12),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 4),
                                ],
                                Text(
                                  'Created: ${order.createdAt.toString()}',
                                  style: const TextStyle(fontSize: 12),
                                ),
                                const SizedBox(height: 8),
                                if (order.status == 'new') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      orderController.updateOrderStatus(
                                        order.id,
                                        'process',
                                      );
                                      Get.snackbar(
                                        'Success',
                                        'Order is now being processed',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.orange,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Proccess'),
                                  ),
                                ] else if (order.status == 'process') ...[
                                  ElevatedButton(
                                    onPressed: () {
                                      orderController.updateOrderStatus(
                                        order.id,
                                        'done',
                                      );
                                      Get.snackbar(
                                        'Success',
                                        'Order marked as done',
                                        snackPosition: SnackPosition.BOTTOM,
                                      );
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.green,
                                      foregroundColor: Colors.white,
                                    ),
                                    child: const Text('Mark as Done'),
                                  ),
                                ],
                              ],
                            ),
                          ),
                        );
                      },
                    );
              }),
            ),
          ],
        ),
      ),
    );
  }
}
