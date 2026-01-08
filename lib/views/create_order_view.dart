import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:intl/intl.dart';
import '../controllers/menu_controller.dart' as menu_ctrl;
import '../controllers/order_controller.dart';
import '../controllers/server_controller.dart';
import '../models/order.dart';

class CreateOrderView extends StatefulWidget {
  const CreateOrderView({super.key});

  @override
  State<CreateOrderView> createState() => _CreateOrderViewState();
}

class _CreateOrderViewState extends State<CreateOrderView> {
  final menu_ctrl.MenuController menuController = Get.find();
  final OrderController orderController = Get.find();
  final ServerController serverController = Get.find();

  final selectedItems = <String, RxInt>{}.obs;
  final total = 0.0.obs;
  late final TextEditingController usernameController;
  late final TextEditingController notesController;
  late final TextEditingController ipAddressController;

  @override
  void initState() {
    super.initState();
    usernameController = TextEditingController();
    notesController = TextEditingController();
    ipAddressController = TextEditingController(
      text: serverController.serverAddress.value,
    );
  }

  @override
  void dispose() {
    usernameController.dispose();
    notesController.dispose();
    ipAddressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
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
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            TextField(
              controller: usernameController,
              decoration: const InputDecoration(
                labelText: 'Order Name',
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
            const SizedBox(height: 8),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(
                labelText: 'Notes (Optional)',
                border: OutlineInputBorder(),
                prefixIcon: Icon(Icons.note),
                hintText: 'Add any special instructions...',
              ),
              maxLines: 2,
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
                if (usernameController.text.trim().isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please enter a username',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
                  );
                  return;
                }

                if (selectedItems.isEmpty) {
                  Get.snackbar(
                    'Error',
                    'Please select at least one item',
                    snackPosition: SnackPosition.BOTTOM,
                    backgroundColor: Colors.red,
                    colorText: Colors.white,
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
                  username: usernameController.text.trim(),
                  notes:
                      notesController.text.trim().isNotEmpty
                          ? notesController.text.trim()
                          : null,
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Order created successfully',
                  snackPosition: SnackPosition.BOTTOM,
                  backgroundColor: Colors.green,
                  colorText: Colors.white,
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
