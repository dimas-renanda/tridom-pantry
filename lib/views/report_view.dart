import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/order_controller.dart';

class ReportView extends StatelessWidget {
  final OrderController orderController = Get.find();

  ReportView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Order Reports'),
        backgroundColor: Colors.green,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Completed Orders',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(() {
                // Filter to show only 'done' orders
                final doneOrders =
                    orderController.orders
                        .where((order) => order.status == 'done')
                        .toList();

                return doneOrders.isEmpty
                    ? const Center(child: Text('No completed orders yet'))
                    : ListView.builder(
                      itemCount: doneOrders.length,
                      itemBuilder: (context, index) {
                        final order = doneOrders[index];
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
                                        const Chip(
                                          label: Text('DONE'),
                                          backgroundColor: Colors.green,
                                        ),
                                        IconButton(
                                          icon: const Icon(
                                            Icons.delete,
                                            color: Colors.red,
                                          ),
                                          onPressed:
                                              () => _showDeleteOrderDialog(
                                                context,
                                                order,
                                              ),
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

  void _showDeleteOrderDialog(BuildContext context, order) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Order'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Are you sure you want to delete order #${order.id}?'),
            const SizedBox(height: 8),
            const Text(
              'This will permanently remove the order from reports.',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              orderController.deleteOrder(order.id);
              Get.back();
              Get.snackbar(
                'Success',
                'Order deleted from reports',
                snackPosition: SnackPosition.BOTTOM,
              );
            },
            child: const Text('Delete'),
          ),
        ],
      ),
    );
  }
}
