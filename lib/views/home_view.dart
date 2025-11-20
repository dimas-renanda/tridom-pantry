import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/server_controller.dart';
import '../services/server_service.dart';
import 'category_view.dart';
import 'menu_view.dart';
import 'order_view.dart';
import 'create_order_view.dart';
import 'report_view.dart';

class HomeView extends StatelessWidget {
  final ServerController serverController = Get.find();
  final ServerService serverService = ServerService();

  HomeView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Tridom Pantry'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Server Status Card
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Obx(
                  () => Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Server Status',
                        style: Theme.of(context).textTheme.titleLarge,
                      ),
                      const SizedBox(height: 16),
                      Row(
                        children: [
                          Icon(
                            serverController.isRunning.value
                                ? Icons.check_circle
                                : Icons.cancel,
                            color:
                                serverController.isRunning.value
                                    ? Colors.green
                                    : Colors.red,
                          ),
                          const SizedBox(width: 8),
                          Text(
                            serverController.isRunning.value
                                ? 'Running'
                                : 'Stopped',
                            style: const TextStyle(fontSize: 16),
                          ),
                        ],
                      ),
                      if (serverController.isRunning.value) ...[
                        const SizedBox(height: 8),
                        Text(
                          'Address: http://${serverController.serverAddress.value}:${serverController.serverPort.value}',
                          style: const TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ],
                  ),
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Start Server Button
            Obx(
              () => ElevatedButton.icon(
                onPressed:
                    serverController.isRunning.value
                        ? null
                        : () {
                          serverService.startServer();
                          Get.snackbar(
                            'Server',
                            'Server starting...',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        },
                icon: const Icon(Icons.play_arrow),
                label: const Text('Start Server'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.green,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 8),

            // Stop Server Button
            Obx(
              () => ElevatedButton.icon(
                onPressed:
                    serverController.isRunning.value
                        ? () {
                          serverService.stopServer();
                          Get.snackbar(
                            'Server',
                            'Server stopped',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                        : null,
                icon: const Icon(Icons.stop),
                label: const Text('Stop Server'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.all(16),
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
            const SizedBox(height: 24),

            // Navigation to Admin Pages
            const Text(
              'Admin Pages',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.to(() => CategoryView()),
              child: const Text('Manage Categories'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.to(() => MenuView()),
              child: const Text('Manage Menu'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.to(() => OrderView()),
              child: const Text('View Orders'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.to(() => ReportView()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                foregroundColor: Colors.white,
              ),
              child: const Text('View Reports'),
            ),
            const SizedBox(height: 8),
            ElevatedButton(
              onPressed: () => Get.to(() => CreateOrderView()),
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blue,
                foregroundColor: Colors.white,
              ),
              child: const Text('Create New Order'),
            ),
            const Spacer(),
            // Footer
            Container(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text(
                        'Made with ',
                        style: TextStyle(fontSize: 12, color: Colors.grey),
                      ),
                      Icon(
                        Icons.favorite,
                        size: 14,
                        color: Colors.red.shade400,
                      ),
                    ],
                  ),
                  const SizedBox(height: 4),
                  const Text(
                    'Powered by DEV_IT',
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.blue,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
