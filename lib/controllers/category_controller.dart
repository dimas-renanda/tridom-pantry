import 'package:get/get.dart';
import 'package:hive/hive.dart';
import '../models/category.dart';

class CategoryController extends GetxController {
  final RxList<Category> categories = <Category>[].obs;
  late Box<Category> _categoryBox;

  @override
  void onInit() {
    super.onInit();
    _initHive();
  }

  Future<void> _initHive() async {
    _categoryBox = await Hive.openBox<Category>('categories');
    _loadCategories();
  }

  void _loadCategories() {
    categories.value = _categoryBox.values.toList();
  }

  void addCategory(String name) {
    final category = Category(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      name: name,
    );
    categories.add(category);
    _categoryBox.put(category.id, category);
  }

  List<Category> getAllCategories() {
    return categories;
  }

  Category? getCategoryById(String id) {
    try {
      return categories.firstWhere((cat) => cat.id == id);
    } catch (e) {
      return null;
    }
  }

  void updateCategory(String id, String name) {
    final index = categories.indexWhere((cat) => cat.id == id);
    if (index != -1) {
      final updatedCategory = Category(id: id, name: name);
      categories[index] = updatedCategory;
      _categoryBox.put(id, updatedCategory);
    }
  }

  void deleteCategory(String id) {
    categories.removeWhere((cat) => cat.id == id);
    _categoryBox.delete(id);
  }
}
