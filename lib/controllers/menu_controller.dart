import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/menu.dart';

class MenuController extends GetxController {
  final RxList<Menu> menuItems = <Menu>[].obs;
  late Box<Menu> _menuBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    _menuBox = await Hive.openBox<Menu>('menus');
    _loadMenus();
  }

  void _loadMenus() {
    menuItems.value = _menuBox.values.toList();
  }

  void addMenu(
    String name,
    double price,
    String categoryId,
    String? imagePath,
  ) {
    final menu = Menu(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
      price: price,
      categoryId: categoryId,
      imagePath: imagePath,
    );
    menuItems.add(menu);
    _menuBox.put(menu.id, menu);
  }

  List<Menu> getAllMenus() {
    return menuItems;
  }

  Menu? getMenuById(String id) {
    try {
      return menuItems.firstWhere((menu) => menu.id == id);
    } catch (e) {
      return null;
    }
  }

  List<Menu> getMenusByCategory(String categoryId) {
    return menuItems.where((menu) => menu.categoryId == categoryId).toList();
  }

  void updateMenu(
    String id,
    String name,
    double price,
    String categoryId,
    String? imagePath,
  ) {
    final index = menuItems.indexWhere((menu) => menu.id == id);
    if (index != -1) {
      final updatedMenu = Menu(
        id: id,
        name: name,
        price: price,
        categoryId: categoryId,
        imagePath: imagePath,
      );
      menuItems[index] = updatedMenu;
      _menuBox.put(id, updatedMenu);
    }
  }

  void deleteMenu(String id) {
    menuItems.removeWhere((menu) => menu.id == id);
    _menuBox.delete(id);
  }
}
