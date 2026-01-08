import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/server_controller.dart';
import '../services/server_service.dart';
import 'category_view.dart';
import 'menu_view.dart';
import 'order_view.dart';
import 'create_order_view.dart';
import 'report_view.dart';
import 'history_view.dart';

class HomeView extends StatefulWidget {
  const HomeView({super.key});

  @override
  State<HomeView> createState() => _HomeViewState();
}

class _HomeViewState extends State<HomeView>
    with SingleTickerProviderStateMixin {
  final ServerController serverController = Get.find();
  final ServerService serverService = ServerService();
  int _selectedIndex = 0;

  @override
  void initState() {
    super.initState();

    // Auto-start server when app opens
    if (!serverController.isRunning.value) {
      Future.delayed(Duration(milliseconds: 500), () {
        serverService.startServer();
        Get.snackbar(
          'Server',
          'Server started automatically',
          snackPosition: SnackPosition.BOTTOM,
          duration: Duration(seconds: 2),
        );
      });
    }
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isPortrait = constraints.maxWidth < 600;

        return Scaffold(
          appBar:
              isPortrait
                  ? AppBar(
                    title: const Text('Tridom Pantry'),
                    backgroundColor: Colors.blue,
                  )
                  : null,
          drawer: isPortrait ? _buildDrawer() : null,
          body: Row(
            children: [
              // Left side navigation rail (hidden in portrait)
              if (!isPortrait) ...[
                SingleChildScrollView(
                  child: ConstrainedBox(
                    constraints: BoxConstraints(
                      minHeight:
                          MediaQuery.of(context).size.height -
                          (isPortrait ? kToolbarHeight : 0),
                    ),
                    child: IntrinsicHeight(
                      child: NavigationRail(
                        selectedIndex: _selectedIndex,
                        onDestinationSelected: (int index) {
                          setState(() {
                            _selectedIndex = index;
                          });
                        },
                        labelType: NavigationRailLabelType.all,
                        backgroundColor: Colors.blue.shade50,
                        selectedIconTheme: const IconThemeData(
                          color: Colors.blue,
                          size: 28,
                        ),
                        selectedLabelTextStyle: const TextStyle(
                          color: Colors.blue,
                          fontWeight: FontWeight.bold,
                        ),
                        unselectedIconTheme: IconThemeData(
                          color: Colors.grey.shade600,
                          size: 24,
                        ),
                        destinations: const [
                          NavigationRailDestination(
                            icon: Icon(Icons.home_outlined),
                            selectedIcon: Icon(Icons.home),
                            label: Text('Home'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.category_outlined),
                            selectedIcon: Icon(Icons.category),
                            label: Text('Categories'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.restaurant_menu_outlined),
                            selectedIcon: Icon(Icons.restaurant_menu),
                            label: Text('Menu'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.receipt_long_outlined),
                            selectedIcon: Icon(Icons.receipt_long),
                            label: Text('Orders'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.assessment_outlined),
                            selectedIcon: Icon(Icons.assessment),
                            label: Text('Completed'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.add_shopping_cart_outlined),
                            selectedIcon: Icon(Icons.add_shopping_cart),
                            label: Text('New Order'),
                          ),
                          NavigationRailDestination(
                            icon: Icon(Icons.history_outlined),
                            selectedIcon: Icon(Icons.history),
                            label: Text('History'),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
                const VerticalDivider(thickness: 1, width: 1),
              ],
              // Main content area
              Expanded(child: _getSelectedView()),
            ],
          ),
        );
      },
    );
  }

  Widget _buildDrawer() {
    return Drawer(
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            margin: EdgeInsets.zero,
            padding: EdgeInsets.zero,
            child: Container(
              width: double.infinity,
              padding: const EdgeInsets.all(16),
              child: const Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.restaurant, size: 42, color: Colors.white),
                  SizedBox(height: 8),
                  Text(
                    'Tridom Pantry',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                _buildDrawerItem(icon: Icons.home, title: 'Home', index: 0),
                _buildDrawerItem(
                  icon: Icons.category,
                  title: 'Categories',
                  index: 1,
                ),
                _buildDrawerItem(
                  icon: Icons.restaurant_menu,
                  title: 'Menu',
                  index: 2,
                ),
                _buildDrawerItem(
                  icon: Icons.receipt_long,
                  title: 'Orders',
                  index: 3,
                ),
                _buildDrawerItem(
                  icon: Icons.assessment,
                  title: 'Reports',
                  index: 4,
                ),
                _buildDrawerItem(
                  icon: Icons.add_shopping_cart,
                  title: 'New Order',
                  index: 5,
                ),
                _buildDrawerItem(
                  icon: Icons.history,
                  title: 'History',
                  index: 6,
                ),
              ],
            ),
          ),
          const Divider(),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Text(
                      'Made with ',
                      style: TextStyle(fontSize: 12, color: Colors.grey),
                    ),
                    Icon(Icons.favorite, size: 14, color: Colors.red.shade400),
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
    );
  }

  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required int index,
  }) {
    final isSelected = _selectedIndex == index;

    return ListTile(
      leading: Icon(
        icon,
        color: isSelected ? Colors.blue : Colors.grey.shade700,
      ),
      title: Text(
        title,
        style: TextStyle(
          color: isSelected ? Colors.blue : Colors.black87,
          fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
        ),
      ),
      selected: isSelected,
      selectedTileColor: Colors.blue.shade50,
      onTap: () {
        setState(() {
          _selectedIndex = index;
        });
        Navigator.pop(context); // Close drawer after selection
      },
    );
  }

  Widget _getSelectedView() {
    switch (_selectedIndex) {
      case 0:
        return _buildHomeTab(Get.context!);
      case 1:
        return CategoryView();
      case 2:
        return MenuView();
      case 3:
        return OrderView();
      case 4:
        return ReportView();
      case 5:
        return CreateOrderView();
      case 6:
        return HistoryView();
      default:
        return _buildHomeTab(Get.context!);
    }
  }

  Widget _buildHomeTab(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isWideScreen = constraints.maxWidth > 600;
        final isLandscape = constraints.maxWidth > constraints.maxHeight;

        if (isWideScreen || isLandscape) {
          // Tablet/Landscape layout - Two columns
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Left column - Server status and controls
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        _buildServerStatusCard(context),
                        const SizedBox(height: 16),
                        _buildServerControls(),
                        const SizedBox(height: 24),
                        _buildFooter(),
                      ],
                    ),
                  ),
                  const SizedBox(width: 16),
                  // Right column - Quick stats
                  Expanded(
                    flex: 1,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: [
                        const Text(
                          'Quick Stats',
                          style: TextStyle(
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 16),
                        _buildQuickStats(),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          );
        } else {
          // Phone portrait layout - Single column
          return SingleChildScrollView(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildServerStatusCard(context),
                  const SizedBox(height: 16),
                  _buildServerControls(),
                  const SizedBox(height: 24),
                  _buildQuickStats(),
                  const SizedBox(height: 24),
                  _buildFooter(),
                ],
              ),
            ),
          );
        }
      },
    );
  }

  Widget _buildQuickStats() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Card(
          elevation: 4,
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Icon(Icons.help_outline, color: Colors.blue, size: 28),
                    const SizedBox(width: 12),
                    const Text(
                      'How to Use',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.blue,
                      ),
                    ),
                  ],
                ),
                const Divider(height: 24),
                _buildHowToStep(
                  number: '1',
                  icon: Icons.category,
                  title: 'Create Categories',
                  description:
                      'Add food categories (e.g., Main Course, Drinks)',
                ),
                const SizedBox(height: 12),
                _buildHowToStep(
                  number: '2',
                  icon: Icons.restaurant_menu,
                  title: 'Add Menu Items',
                  description: 'Add your menu with prices and images',
                ),
                const SizedBox(height: 12),
                _buildHowToStep(
                  number: '3',
                  icon: Icons.add_shopping_cart,
                  title: 'Create Orders',
                  description: 'Create new orders for customers',
                ),
                const SizedBox(height: 12),
                _buildHowToStep(
                  number: '4',
                  icon: Icons.receipt_long,
                  title: 'Manage Orders',
                  description: 'Process orders from New → Process → Done',
                ),
                const SizedBox(height: 12),
                _buildHowToStep(
                  number: '5',
                  icon: Icons.assessment,
                  title: 'View Reports',
                  description: 'Check completed orders and post to history',
                ),
                const SizedBox(height: 16),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.blue.shade50,
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.info, color: Colors.blue, size: 20),
                      const SizedBox(width: 8),
                      Expanded(
                        child: Text(
                          'Server runs on port 8080. Access from other devices on your network.',
                          style: TextStyle(
                            fontSize: 12,
                            color: Colors.blue.shade900,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildServerStatusCard(BuildContext context) {
    return Card(
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
                    serverController.isRunning.value ? 'Running' : 'Stopped',
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
    );
  }

  Widget _buildServerControls() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
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
      ],
    );
  }

  Widget _buildFooter() {
    return Container(
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
              Icon(Icons.favorite, size: 14, color: Colors.red.shade400),
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
    );
  }

  Widget _buildHowToStep({
    required String number,
    required IconData icon,
    required String title,
    required String description,
  }) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Container(
          width: 32,
          height: 32,
          decoration: BoxDecoration(color: Colors.blue, shape: BoxShape.circle),
          child: Center(
            child: Text(
              number,
              style: const TextStyle(
                color: Colors.white,
                fontWeight: FontWeight.bold,
                fontSize: 16,
              ),
            ),
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  Icon(icon, size: 18, color: Colors.blue),
                  const SizedBox(width: 6),
                  Text(
                    title,
                    style: const TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 14,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                description,
                style: TextStyle(fontSize: 12, color: Colors.grey.shade700),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
