import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/menu_controller.dart' as menu_ctrl;
import '../controllers/order_controller.dart';
import '../controllers/server_controller.dart';
import '../models/order.dart';

class CreateOrderView extends StatelessWidget {
  final menu_ctrl.MenuController menuController = Get.find();
  final OrderController orderController = Get.find();
  final ServerController serverController = Get.find();

  CreateOrderView({super.key});

  @override
  Widget build(BuildContext context) {
    final selectedItems = <String, RxInt>{}.obs;
    final total = 0.0.obs;
    final usernameController = TextEditingController();
    final ipAddressController = TextEditingController(
      text: serverController.serverAddress.value,
    );

    void updateTotal() {
      double sum = 0.0;
      selectedItems.forEach((menuId, quantity) {
        final menu = menuController.getMenuById(menuId);
        if (menu != null) {
          sum += menu.price * quantity.value;
        }
      });
      total.value = sum;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Create Order'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Username',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.person),
              ),
            ),
            const SizedBox(height: 8),
            TextField(
              controller: ipAddressController,
              decoration: const InputDecoration(
                labelText: 'IP Address',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.computer),
              ),
            ),
            const SizedBox(height: 16),
            const Text(
              'Select Menu Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: Obx(
                () =>
                    menuController.menuItems.isEmpty
                        ? const Center(child: Text('No menu items available'))
                        : ListView.builder(
                          itemCount: menuController.menuItems.length,
                          itemBuilder: (context, index) {
                            final menu = menuController.menuItems[index];

                            return Card(
                              child: ListTile(
                                title: Text(menu.name),
                                subtitle: Text(
                                  'Rp ${NumberFormat('#,###', 'id_ID').format(menu.price.toInt())}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(Icons.remove_circle),
                                      onPressed: () {
                                        if (selectedItems.containsKey(
                                          menu.id,
                                        )) {
                                          if (selectedItems[menu.id]!.value >
                                              0) {
                                            selectedItems[menu.id]!.value--;
                                            if (selectedItems[menu.id]!.value ==
                                                0) {
                                              selectedItems.remove(menu.id);
                                            }
                                            updateTotal();
                                          }
                                        }
                                      },
                                    ),
                                    Obx(
                                      () => Text(
                                        '${selectedItems.containsKey(menu.id) ? selectedItems[menu.id]!.value : 0}',
                                        style: const TextStyle(fontSize: 18),
                                      ),
                                    ),
                                    IconButton(
                                      icon: const Icon(Icons.add_circle),
                                      onPressed: () {
                                        if (!selectedItems.containsKey(
                                          menu.id,
                                        )) {
                                          selectedItems[menu.id] = 1.obs;
                                        } else {
                                          selectedItems[menu.id]!.value++;
                                        }
                                        updateTotal();
                                      },
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
            const SizedBox(height: 16),
            Obx(
              () => Card(
                color: Colors.blue.shade50,
                child: Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Text(
                    'Total: Rp ${NumberFormat('#,###', 'id_ID').format(total.value.toInt())}',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),
            ElevatedButton(
              onPressed: () {
                if (selectedItems.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please select at least one item',
                    snackPosition: SnackPosition.BOTTOM,
                  );
                  return;
                }

                final items = <OrderItem>[];
                selectedItems.forEach((menuId, quantity) {
                  final menu = menuController.getMenuById(menuId);
                  if (menu != null) {
                    items.add(
                      OrderItem(
                        menuId: menuId,
                        menuName: menu.name,
                        quantity: quantity.value,
                        price: menu.price,
                      ),
                    );
                  }
                });

                orderController.createOrder(
                  items,
                  total.value,
                  ipAddress:
                      ipAddressController.text.isNotEmpty
                          ? ipAddressController.text
                          : null,
                  username:
                      usernameController.text.isNotEmpty
                          ? usernameController.text
                          : null,
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Order created successfully',
                  snackPosition: SnackPosition.BOTTOM,
                );
              },
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              child: const Text('Create Order', style: TextStyle(fontSize: 18)),
            ),
          ],
        ),
      ),
    );
  }
}
