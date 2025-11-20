import 'dart:io';
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:image_picker/image_picker.dart';
import '../controllers/category_controller.dart';
import '../controllers/menu_controller.dart' as menu_ctrl;

class MenuView extends StatelessWidget {
  final menu_ctrl.MenuController menuController = Get.find();
  final CategoryController categoryController = Get.find();
  final TextEditingController nameController = TextEditingController();
  final TextEditingController priceController = TextEditingController();
  final RxString selectedCategoryId = ''.obs;
  final RxString selectedImagePath = ''.obs;

  MenuView({super.key});

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();
    final XFile? image = await picker.pickImage(source: ImageSource.gallery);

    if (image != null) {
      selectedImagePath.value = image.path;
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Menu'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add Menu Form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Menu Item',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Menu Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    TextField(
                      controller: priceController,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Price',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 8),
                    Obx(
                      () => DropdownButtonFormField<String>(
                        decoration: const InputDecoration(
                          labelText: 'Category',
                          border: OutlineInputBorder(),
                        ),
                        value:
                            selectedCategoryId.value.isEmpty
                                ? null
                                : selectedCategoryId.value,
                        items:
                            categoryController.categories
                                .map(
                                  (category) => DropdownMenuItem(
                                    value: category.id,
                                    child: Text(category.name),
                                  ),
                                )
                                .toList(),
                        onChanged: (value) {
                          if (value != null) {
                            selectedCategoryId.value = value;
                          }
                        },
                      ),
                    ),
                    const SizedBox(height: 8),
                    ElevatedButton.icon(
                      onPressed: _pickImage,
                      icon: const Icon(Icons.image),
                      label: const Text('Pick Image'),
                    ),
                    Obx(
                      () =>
                          selectedImagePath.value.isNotEmpty
                              ? Padding(
                                padding: const EdgeInsets.only(top: 8.0),
                                child: Image.file(
                                  File(selectedImagePath.value),
                                  height: 100,
                                  width: 100,
                                  fit: BoxFit.cover,
                                ),
                              )
                              : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty &&
                            priceController.text.isNotEmpty &&
                            selectedCategoryId.value.isNotEmpty) {
                          menuController.addMenu(
                            nameController.text,
                            double.parse(priceController.text),
                            selectedCategoryId.value,
                            selectedImagePath.value.isNotEmpty
                                ? selectedImagePath.value
                                : null,
                          );
                          nameController.clear();
                          priceController.clear();
                          selectedCategoryId.value = '';
                          selectedImagePath.value = '';
                          Get.snackbar(
                            'Success',
                            'Menu item added',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text('Add Menu Item'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Menu List
            const Text(
              'Menu Items',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(
                () =>
                    menuController.menuItems.isEmpty
                        ? const Center(child: Text('No menu items yet'))
                        : ListView.builder(
                          itemCount: menuController.menuItems.length,
                          itemBuilder: (context, index) {
                            final menu = menuController.menuItems[index];
                            final category = categoryController.getCategoryById(
                              menu.categoryId,
                            );
                            return Card(
                              child: ListTile(
                                leading:
                                    menu.imagePath != null
                                        ? Image.file(
                                          File(menu.imagePath!),
                                          width: 50,
                                          height: 50,
                                          fit: BoxFit.cover,
                                        )
                                        : const Icon(Icons.restaurant_menu),
                                title: Text(menu.name),
                                subtitle: Text(
                                  'Price: \$${menu.price.toStringAsFixed(2)}\nCategory: ${category?.name ?? "Unknown"}',
                                ),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _showEditMenuDialog(
                                            context,
                                            menu,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _showDeleteMenuDialog(
                                            context,
                                            menu,
                                          ),
                                    ),
                                  ],
                                ),
                              ),
                            );
                          },
                        ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _showEditMenuDialog(BuildContext context, menu) {
    final editNameController = TextEditingController(text: menu.name);
    final editPriceController = TextEditingController(
      text: menu.price.toString(),
    );
    final editCategoryId = menu.categoryId.obs;
    final editImagePath = (menu.imagePath ?? '').obs;

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Menu Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: editNameController,
                decoration: const InputDecoration(
                  labelText: 'Menu Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: editPriceController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(
                  labelText: 'Price',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 8),
              Obx(
                () => DropdownButtonFormField<String>(
                  decoration: const InputDecoration(
                    labelText: 'Category',
                    border: OutlineInputBorder(),
                  ),
                  value: editCategoryId.value,
                  items:
                      categoryController.categories
                          .map(
                            (category) => DropdownMenuItem(
                              value: category.id,
                              child: Text(category.name),
                            ),
                          )
                          .toList(),
                  onChanged: (value) {
                    if (value != null) {
                      editCategoryId.value = value;
                    }
                  },
                ),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (editNameController.text.isNotEmpty &&
                  editPriceController.text.isNotEmpty) {
                menuController.updateMenu(
                  menu.id,
                  editNameController.text,
                  double.parse(editPriceController.text),
                  editCategoryId.value,
                  editImagePath.value.isNotEmpty ? editImagePath.value : null,
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Menu item updated',
                  snackPosition: SnackPosition.BOTTOM,
                );
              }
            },
            child: const Text('Update'),
          ),
        ],
      ),
    );
  }

  void _showDeleteMenuDialog(BuildContext context, menu) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Menu Item'),
        content: Text('Are you sure you want to delete "${menu.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              menuController.deleteMenu(menu.id);
              Get.back();
              Get.snackbar(
                'Success',
                'Menu item deleted',
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
