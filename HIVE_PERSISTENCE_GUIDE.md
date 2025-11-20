# 🗄️ Hive Persistent Storage - Implementation Guide

## ✅ What Changed

Your app now has **permanent data storage** using Hive database!

---

## 🎉 What This Means

### Before (In-Memory):
- ❌ Data lost when app closes
- ❌ Data lost when server stops
- ❌ Data lost on app restart

### After (Hive Persistent):
- ✅ **Categories saved permanently**
- ✅ **Menu items saved permanently**
- ✅ **Orders saved permanently**
- ✅ **Data persists after app restart**
- ✅ **Data survives device reboot**
- ✅ **Automatic save on every change**

---

## 📦 What Was Added

### 1. New Dependencies
```yaml
dependencies:
  hive: ^2.2.3
  hive_flutter: ^1.1.0

dev_dependencies:
  build_runner: ^2.5.4
  hive_generator: ^2.0.1
```

### 2. Model Annotations
All models now have Hive annotations:

**Category Model:**
```dart
@HiveType(typeId: 0)
class Category {
  @HiveField(0)
  final String id;
  
  @HiveField(1)
  final String name;
  // ...
}
```

**Menu Model:**
```dart
@HiveType(typeId: 1)
class Menu {
  @HiveField(0)
  final String id;
  // ...
}
```

**Order Models:**
```dart
@HiveType(typeId: 2)
class Order { ... }

@HiveType(typeId: 3)
class OrderItem { ... }
```

### 3. Generated Adapters
Build runner generated these files:
- `lib/models/category.g.dart`
- `lib/models/menu.g.dart`
- `lib/models/order.g.dart`

### 4. Updated Controllers
All controllers now:
- Open Hive boxes on initialization
- Load existing data on startup
- Save automatically on every change

**Example (CategoryController):**
```dart
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

  void addCategory(String name) {
    final category = Category(...);
    categories.add(category);
    _categoryBox.put(category.id, category); // ← Saves to Hive!
  }
}
```

### 5. Updated main.dart
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Hive
  await Hive.initFlutter();
  
  // Register adapters
  Hive.registerAdapter(CategoryAdapter());
  Hive.registerAdapter(MenuAdapter());
  Hive.registerAdapter(OrderAdapter());
  Hive.registerAdapter(OrderItemAdapter());
  
  // Initialize controllers
  Get.put(CategoryController());
  Get.put(menu_ctrl.MenuController());
  Get.put(OrderController());
  Get.put(ServerController());

  runApp(const MyApp());
}
```

---

## 🧪 How to Test Persistence

### Test 1: Add Data and Restart
1. Run the app: `flutter run`
2. Add a category (e.g., "Beverages")
3. Add a menu item
4. **Close the app completely** (stop it)
5. **Restart the app**: `flutter run`
6. ✅ Your data should still be there!

### Test 2: Create Order and Restart
1. Create an order via API
2. Check the Orders page in the app
3. **Close and restart the app**
4. ✅ The order should still be visible!

### Test 3: Update Status and Restart
1. Mark an order as "done"
2. **Restart the app**
3. ✅ The status should remain "done"

---

## 📊 Data Storage Location

Hive stores data in:
- **iOS**: `~/Library/Application Support/order/`
- **Android**: `/data/data/com.example.order/app_flutter/`
- **macOS**: `~/Library/Containers/com.example.order/Data/Library/Application Support/`

Each box is stored as a separate file:
- `categories.hive`
- `menus.hive`
- `orders.hive`

---

## 🔧 Hive Operations

### Automatic Operations (Already Implemented)

**Add Category:**
```dart
void addCategory(String name) {
  final category = Category(...);
  categories.add(category);
  _categoryBox.put(category.id, category); // ← Auto-save
}
```

**Update Order Status:**
```dart
void updateOrderStatus(String orderId, String status) {
  orders[index].status = status;
  _orderBox.put(orderId, orders[index]); // ← Auto-save
  orders.refresh();
}
```

**Load on Startup:**
```dart
void _loadCategories() {
  categories.value = _categoryBox.values.toList(); // ← Auto-load
}
```

### Manual Operations (If Needed)

**Delete a Category:**
```dart
void deleteCategory(String id) {
  categories.removeWhere((cat) => cat.id == id);
  _categoryBox.delete(id);
}
```

**Clear All Categories:**
```dart
void clearAllCategories() {
  categories.clear();
  _categoryBox.clear();
}
```

**Get Single Item:**
```dart
Category? getCategory(String id) {
  return _categoryBox.get(id);
}
```

---

## 🚀 Advanced Features You Can Add

### 1. Add Delete Functionality

**In CategoryController:**
```dart
void deleteCategory(String id) {
  categories.removeWhere((cat) => cat.id == id);
  _categoryBox.delete(id);
}
```

**API Endpoint:**
```dart
else if (path == '/category/delete' && method == 'POST') {
  await _deleteCategory(request);
}

Future<void> _deleteCategory(HttpRequest request) async {
  final body = await _getRequestBody(request);
  final id = body['id'] as String?;
  
  if (id != null) {
    categoryController.deleteCategory(id);
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Category deleted',
    });
  }
}
```

### 2. Add Clear All Data

```dart
void clearAllData() async {
  await _categoryBox.clear();
  await _menuBox.clear();
  await _orderBox.clear();
  categories.clear();
  menuItems.clear();
  orders.clear();
}
```

### 3. Export/Import Data

**Export to JSON:**
```dart
Map<String, dynamic> exportAllData() {
  return {
    'categories': _categoryBox.values.map((c) => c.toJson()).toList(),
    'menus': _menuBox.values.map((m) => m.toJson()).toList(),
    'orders': _orderBox.values.map((o) => o.toJson()).toList(),
  };
}
```

---

## 🎓 How Hive Works

### Type Adapters
Hive needs to know how to serialize/deserialize your custom classes:

```dart
@HiveType(typeId: 0)  // ← Unique ID for this class
class Category {
  @HiveField(0)  // ← Unique ID for this field
  final String id;
  
  @HiveField(1)  // ← Unique ID for this field
  final String name;
}
```

### Boxes
Think of boxes as tables in a database:
- `categories` box = Categories table
- `menus` box = Menus table
- `orders` box = Orders table

### Keys
Each item is stored with a unique key:
```dart
_categoryBox.put(category.id, category);
//              ↑ Key         ↑ Value
```

---

## 🔄 Regenerating Adapters

If you modify model fields, regenerate adapters:

```bash
flutter pub run build_runner build --delete-conflicting-outputs
```

---

## 🐛 Troubleshooting

### Issue: Data not persisting
**Solution:** Make sure you're calling `.put()` when adding/updating data.

### Issue: "Type is not a subtype" error
**Solution:** Regenerate adapters and restart the app.

### Issue: Old data conflicts
**Solution:** Clear Hive boxes or uninstall/reinstall the app.

### Clear Hive Data (for testing):
```dart
await Hive.deleteBoxFromDisk('categories');
await Hive.deleteBoxFromDisk('menus');
await Hive.deleteBoxFromDisk('orders');
```

---

## 📈 Performance Notes

- **Fast**: Hive is optimized for mobile
- **Efficient**: No SQL overhead
- **Lazy**: Only loads data when accessed
- **Compact**: Efficient binary storage

---

## 🔐 Data Safety

- ✅ Data persists across app restarts
- ✅ Data survives device reboots
- ✅ Automatic backup with device backup
- ⚠️ Not encrypted by default (add `hive_flutter` encryption if needed)
- ⚠️ Stored locally only (no cloud sync)

---

## 🎉 Summary

You now have:
- ✅ **Permanent data storage**
- ✅ **Automatic save on every change**
- ✅ **Automatic load on app start**
- ✅ **Fast and efficient storage**
- ✅ **Type-safe operations**

**Your app data will now persist even after closing the app!**

---

## 📚 Additional Resources

- [Hive Documentation](https://docs.hivedb.dev/)
- [Hive Flutter Plugin](https://pub.dev/packages/hive_flutter)
- [Type Adapters Guide](https://docs.hivedb.dev/#/custom-objects/type_adapters)

**Happy coding with persistent storage! 🚀**
