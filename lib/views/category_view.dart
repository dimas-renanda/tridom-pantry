import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../controllers/category_controller.dart';

class CategoryView extends StatelessWidget {
  final CategoryController categoryController = Get.find();
  final TextEditingController nameController = TextEditingController();

  CategoryView({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Manage Categories'),
        backgroundColor: Colors.blue,
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Add Category Form
            Card(
              elevation: 4,
              child: Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text(
                      'Add New Category',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Category Name',
                        border: OutlineInputBorder(),
                      ),
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () {
                        if (nameController.text.isNotEmpty) {
                          categoryController.addCategory(nameController.text);
                          nameController.clear();
                          Get.snackbar(
                            'Success',
                            'Category added',
                            snackPosition: SnackPosition.BOTTOM,
                          );
                        }
                      },
                      child: const Text('Add Category'),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 16),

            // Categories List
            const Text(
              'Categories',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            Expanded(
              child: Obx(
                () =>
                    categoryController.categories.isEmpty
                        ? const Center(child: Text('No categories yet'))
                        : ListView.builder(
                          itemCount: categoryController.categories.length,
                          itemBuilder: (context, index) {
                            final category =
                                categoryController.categories[index];
                            return Card(
                              child: ListTile(
                                leading: const Icon(Icons.category),
                                title: Text(category.name),
                                subtitle: Text('ID: ${category.id}'),
                                trailing: Row(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    IconButton(
                                      icon: const Icon(
                                        Icons.edit,
                                        color: Colors.blue,
                                      ),
                                      onPressed:
                                          () => _showEditDialog(
                                            context,
                                            category,
                                          ),
                                    ),
                                    IconButton(
                                      icon: const Icon(
                                        Icons.delete,
                                        color: Colors.red,
                                      ),
                                      onPressed:
                                          () => _showDeleteDialog(
                                            context,
                                            category,
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

  void _showEditDialog(BuildContext context, category) {
    final editController = TextEditingController(text: category.name);

    Get.dialog(
      AlertDialog(
        title: const Text('Edit Category'),
        content: TextField(
          controller: editController,
          decoration: const InputDecoration(
            labelText: 'Category Name',
            border: OutlineInputBorder(),
          ),
        ),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              if (editController.text.isNotEmpty) {
                categoryController.updateCategory(
                  category.id,
                  editController.text,
                );
                Get.back();
                Get.snackbar(
                  'Success',
                  'Category updated',
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

  void _showDeleteDialog(BuildContext context, category) {
    Get.dialog(
      AlertDialog(
        title: const Text('Delete Category'),
        content: Text('Are you sure you want to delete "${category.name}"?'),
        actions: [
          TextButton(onPressed: () => Get.back(), child: const Text('Cancel')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () {
              categoryController.deleteCategory(category.id);
              Get.back();
              Get.snackbar(
                'Success',
                'Category deleted',
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
