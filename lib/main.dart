import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'controllers/category_controller.dart';
import 'controllers/menu_controller.dart' as menu_ctrl;
import 'controllers/order_controller.dart';
import 'controllers/server_controller.dart';
import 'models/category.dart';
import 'models/menu.dart';
import 'models/order.dart';
import 'views/home_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive
  await Hive.initFlutter();

  // Register Hive adapters
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(MenuAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(OrderItemAdapter());

  // Initialize GetX controllers
  Get.put(CategoryController());
  Get.put(menu_ctrl.MenuController());
  Get.put(OrderController());
  Get.put(ServerController());

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return GetMaterialApp(
      title: 'TridomPantry',
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.blue),
        useMaterial3: true,
      ),
      home: HomeView(),
      debugShowCheckedModeBanner: false,
    );
  }
}
