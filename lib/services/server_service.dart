import 'dart:io';
import 'dart:convert';
import 'dart:async';
import 'package:get/get.dart';
import 'package:path_provider/path_provider.dart';
import 'package:mime/mime.dart';
import '../controllers/category_controller.dart';
import '../controllers/menu_controller.dart';
import '../controllers/order_controller.dart';
import '../controllers/server_controller.dart';
import '../models/order.dart';

class ServerService {
  HttpServer? _server;
  final CategoryController categoryController = Get.find();
  final MenuController menuController = Get.find();
  final OrderController orderController = Get.find();
  final ServerController serverController = Get.find();

  Future<void> startServer() async {
    try {
      // Get local IP address
      final interfaces = await NetworkInterface.list();
      String localIp = 'localhost';

      for (var interface in interfaces) {
        for (var addr in interface.addresses) {
          if (addr.type == InternetAddressType.IPv4 && !addr.isLoopback) {
            localIp = addr.address;
            break;
          }
        }
      }

      // Bind to any IPv4 address to allow external connections
      _server = await HttpServer.bind(
        InternetAddress.anyIPv4,
        8080,
        shared: true, // Allow multiple instances if needed
      );

      serverController.setServerStatus(true, localIp, 8080);

      print('Server running on http://$localIp:8080');

      await for (HttpRequest request in _server!) {
        _handleRequest(request);
      }
    } catch (e) {
      print('Error starting server: $e');
      serverController.stopServer();
    }
  }

  void _handleRequest(HttpRequest request) async {
    // Enable CORS
    request.response.headers.add('Access-Control-Allow-Origin', '*');
    request.response.headers.add(
      'Access-Control-Allow-Methods',
      'GET, POST, PUT, DELETE',
    );
    request.response.headers.add(
      'Access-Control-Allow-Headers',
      'Content-Type',
    );

    if (request.method == 'OPTIONS') {
      request.response.statusCode = HttpStatus.ok;
      request.response.close();
      return;
    }

    final path = request.uri.path;
    final method = request.method;

    try {
      if (path == '/category' && method == 'GET') {
        await _getCategories(request);
      } else if (path == '/category/add' && method == 'POST') {
        await _addCategory(request);
      } else if (path == '/category/update' && method == 'POST') {
        await _updateCategory(request);
      } else if (path == '/category/delete' && method == 'POST') {
        await _deleteCategory(request);
      } else if (path == '/menu' && method == 'GET') {
        await _getMenus(request);
      } else if (path == '/menu/add' && method == 'POST') {
        await _addMenu(request);
      } else if (path == '/menu/update' && method == 'POST') {
        await _updateMenu(request);
      } else if (path == '/menu/delete' && method == 'POST') {
        await _deleteMenu(request);
      } else if (path == '/menu/toggle-enabled' && method == 'POST') {
        await _toggleMenuEnabled(request);
      } else if (path == '/menu/upload-image' && method == 'POST') {
        await _uploadMenuImage(request);
      } else if (path == '/orders' && method == 'GET') {
        await _getOrders(request);
      } else if (path == '/orders/by-username' && method == 'GET') {
        await _getOrdersByUsername(request);
      } else if (path == '/orders/create' && method == 'POST') {
        await _createOrder(request);
      } else if (path == '/orders/update-status' && method == 'POST') {
        await _updateOrderStatus(request);
      } else if (path == '/orders/post-to-history' && method == 'POST') {
        await _postOrderToHistory(request);
      } else if (path == '/orders/delete' && method == 'POST') {
        await _deleteOrder(request);
      } else if (path == '/history' && method == 'GET') {
        await _getHistory(request);
      } else if (path == '/history/delete' && method == 'DELETE') {
        await _deleteHistory(request);
      } else if (path == '/images/list' && method == 'GET') {
        await _listImages(request);
      } else if (path.startsWith('/images/')) {
        await _serveImage(request);
      } else {
        _sendResponse(request, 404, {
          'success': false,
          'message': 'Endpoint not found',
        });
      }
    } catch (e) {
      _sendResponse(request, 500, {
        'success': false,
        'message': 'Internal server error: $e',
      });
    }
  }

  // Category endpoints
  Future<void> _getCategories(HttpRequest request) async {
    final categories = categoryController.getAllCategories();
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Categories retrieved',
      'data': categories.map((cat) => cat.toJson()).toList(),
    });
  }

  Future<void> _addCategory(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final name = body['name'] as String?;

    if (name == null || name.isEmpty) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Category name is required',
      });
      return;
    }

    categoryController.addCategory(name);
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Category added',
      'data': {'name': name},
    });
  }

  Future<void> _updateCategory(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final id = body['id'] as String?;
    final name = body['name'] as String?;

    if (id == null || name == null || name.isEmpty) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Category ID and name are required',
      });
      return;
    }

    categoryController.updateCategory(id, name);
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Category updated',
      'data': {'id': id, 'name': name},
    });
  }

  Future<void> _deleteCategory(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final id = body['id'] as String?;

    if (id == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Category ID is required',
      });
      return;
    }

    categoryController.deleteCategory(id);
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Category deleted',
      'data': {'id': id},
    });
  }

  // Menu endpoints
  Future<void> _getMenus(HttpRequest request) async {
    // Return only enabled menu items for API consumers
    final menus = menuController.getEnabledMenus();
    final baseUrl =
        'http://${serverController.serverAddress.value}:${serverController.serverPort.value}';

    _sendResponse(request, 200, {
      'success': true,
      'message': 'Menus retrieved',
      'data':
          menus.map((menu) {
            final menuJson = menu.toJson();
            // Convert imagePath to full URL if it exists
            if (menuJson['imagePath'] != null &&
                menuJson['imagePath'].toString().isNotEmpty) {
              final imagePath = menuJson['imagePath'] as String;

              // If it starts with /images/, it's already in correct format
              if (imagePath.startsWith('/images/')) {
                menuJson['imageUrl'] = '$baseUrl$imagePath';
              }
              // If it's a local device path, extract filename and create URL
              else if (imagePath.contains('/')) {
                final filename = imagePath.split('/').last;
                menuJson['imageUrl'] = '$baseUrl/images/$filename';
                menuJson['imagePath'] = '/images/$filename';
              }
              // If it's already a full URL, keep it
              else if (imagePath.startsWith('http')) {
                menuJson['imageUrl'] = imagePath;
              }
            } else {
              menuJson['imageUrl'] = null;
            }
            return menuJson;
          }).toList(),
    });
  }

  Future<void> _addMenu(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final name = body['name'] as String?;
    final price = body['price'];
    final categoryId = body['categoryId'] as String?;
    final imagePath = body['imagePath'] as String?;
    final isEnabled = body['isEnabled'] as bool? ?? true;

    if (name == null || price == null || categoryId == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Name, price, and categoryId are required',
      });
      return;
    }

    menuController.addMenu(
      name,
      (price as num).toDouble(),
      categoryId,
      imagePath,
      isEnabled: isEnabled,
    );
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Menu added',
      'data': {
        'name': name,
        'price': price,
        'categoryId': categoryId,
        'imagePath': imagePath,
        'isEnabled': isEnabled,
      },
    });
  }

  Future<void> _updateMenu(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final id = body['id'] as String?;
    final name = body['name'] as String?;
    final price = body['price'];
    final categoryId = body['categoryId'] as String?;
    final imagePath = body['imagePath'] as String?;
    final isEnabled = body['isEnabled'] as bool?;

    if (id == null || name == null || price == null || categoryId == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'ID, name, price, and categoryId are required',
      });
      return;
    }

    menuController.updateMenu(
      id,
      name,
      (price as num).toDouble(),
      categoryId,
      imagePath,
      isEnabled: isEnabled,
    );
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Menu updated',
      'data': {
        'id': id,
        'name': name,
        'price': price,
        'categoryId': categoryId,
        'imagePath': imagePath,
      },
    });
  }

  Future<void> _deleteMenu(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final id = body['id'] as String?;

    if (id == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Menu ID is required',
      });
      return;
    }

    menuController.deleteMenu(id);
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Menu deleted',
      'data': {'id': id},
    });
  }

  Future<void> _toggleMenuEnabled(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final id = body['id'] as String?;

    if (id == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Menu ID is required',
      });
      return;
    }

    menuController.toggleMenuEnabled(id);
    final menu = menuController.getMenuById(id);

    _sendResponse(request, 200, {
      'success': true,
      'message': 'Menu enabled status toggled',
      'data': {'id': id, 'isEnabled': menu?.isEnabled ?? false},
    });
  }

  Future<void> _uploadMenuImage(HttpRequest request) async {
    try {
      final contentType = request.headers.contentType;
      if (contentType?.mimeType != 'multipart/form-data') {
        _sendResponse(request, 400, {
          'success': false,
          'message': 'Content-Type must be multipart/form-data',
        });
        return;
      }

      final boundary = contentType!.parameters['boundary']!;
      final transformer = MimeMultipartTransformer(boundary);
      final parts = await transformer.bind(request).toList();

      for (var part in parts) {
        final contentDisposition = part.headers['content-disposition'];
        if (contentDisposition != null &&
            contentDisposition.contains('filename')) {
          // Extract filename
          final filenameMatch = RegExp(
            r'filename="([^"]+)"',
          ).firstMatch(contentDisposition);
          if (filenameMatch != null) {
            final filename = filenameMatch.group(1)!;
            final timestamp = DateTime.now().millisecondsSinceEpoch;
            final newFilename = '${timestamp}_$filename';

            // Get app directory
            final directory = await getApplicationDocumentsDirectory();
            final imagesDir = Directory('${directory.path}/images');
            if (!await imagesDir.exists()) {
              await imagesDir.create(recursive: true);
            }

            // Save file
            final filePath = '${imagesDir.path}/$newFilename';
            final file = File(filePath);
            final bytes = await part.toList();
            final allBytes = bytes.expand((x) => x).toList();
            await file.writeAsBytes(allBytes);

            // Return image URL
            _sendResponse(request, 200, {
              'success': true,
              'message': 'Image uploaded',
              'data': {
                'imagePath': '/images/$newFilename',
                'url':
                    'http://${serverController.serverAddress.value}:${serverController.serverPort.value}/images/$newFilename',
              },
            });
            return;
          }
        }
      }

      _sendResponse(request, 400, {
        'success': false,
        'message': 'No file found in request',
      });
    } catch (e) {
      _sendResponse(request, 500, {
        'success': false,
        'message': 'Failed to upload image: $e',
      });
    }
  }

  // Order endpoints
  Future<void> _getOrders(HttpRequest request) async {
    final orders = orderController.getAllOrders();
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Orders retrieved',
      'data': orders.map((order) => order.toJson()).toList(),
    });
  }

  Future<void> _getOrdersByUsername(HttpRequest request) async {
    final username = request.uri.queryParameters['username'];

    if (username == null || username.isEmpty) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Username query parameter is required',
      });
      return;
    }

    final allOrders = orderController.getAllOrders();
    final filteredOrders =
        allOrders.where((order) {
          return order.username != null &&
              order.username!.toLowerCase() == username.toLowerCase();
        }).toList();

    _sendResponse(request, 200, {
      'success': true,
      'message': 'Orders retrieved for username: $username',
      'data': filteredOrders.map((order) => order.toJson()).toList(),
      'count': filteredOrders.length,
    });
  }

  Future<void> _createOrder(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final itemsData = body['items'] as List?;
    final total = body['total'];
    final ipAddress = body['ipAddress'] as String?;
    final username = body['username'] as String?;
    final docNo = body['docNo'] as String?;
    final notes = body['notes'] as String?;

    if (itemsData == null || total == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Items and total are required',
      });
      return;
    }

    final items = itemsData.map((item) => OrderItem.fromJson(item)).toList();
    orderController.createOrder(
      docNo: docNo,
      items,
      (total as num).toDouble(),
      ipAddress: ipAddress,
      username: username,
      notes: notes,
    );

    _sendResponse(request, 200, {
      'success': true,
      'message': 'Order created',
      'data': {
        'items': items.map((item) => item.toJson()).toList(),
        'total': total,
        'ipAddress': ipAddress,
        'username': username,
        'docNo': docNo,
        'notes': notes,
      },
    });
  }

  Future<void> _updateOrderStatus(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final orderId = body['orderId'] as String?;
    final status = body['status'] as String?;

    print('Update Order Status Request - orderId: $orderId, status: $status');

    if (orderId == null || status == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'OrderId and status are required',
      });
      return;
    }

    // Update order status (notifications will be triggered by OrderController)
    orderController.updateOrderStatus(orderId, status);

    _sendResponse(request, 200, {
      'success': true,
      'message': 'Order status updated',
      'data': {'orderId': orderId, 'status': status},
    });
  }

  Future<void> _postOrderToHistory(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final orderId = body['orderId'] as String?;

    print('Post Order to History Request - orderId: $orderId');

    if (orderId == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'OrderId is required',
      });
      return;
    }

    // Check if order exists
    final order = orderController.orders.firstWhereOrNull(
      (o) => o.id == orderId,
    );

    if (order == null) {
      _sendResponse(request, 404, {
        'success': false,
        'message': 'Order not found',
      });
      return;
    }

    // Check if order is done
    if (order.status != 'done') {
      _sendResponse(request, 403, {
        'success': false,
        'message': 'Only orders with status "done" can be posted to history',
        'data': {'currentStatus': order.status},
      });
      return;
    }

    // Post to history
    orderController.postToHistory(orderId);

    _sendResponse(request, 200, {
      'success': true,
      'message': 'Order posted to history',
      'data': {'orderId': orderId, 'status': 'posted'},
    });
  }

  Future<void> _getHistory(HttpRequest request) async {
    // Get optional endDate parameter from query string
    final endDateStr = request.uri.queryParameters['endDate'];

    var history = orderController.getAllHistory();

    // Filter by endDate if provided
    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        // Parse the endDate string (expects format: YYYY-MM-DD or ISO8601)
        DateTime endDate = DateTime.parse(endDateStr);

        // Set to end of day (23:59:59.999)
        endDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );

        // Filter orders created at or before the endDate
        history =
            history.where((order) {
              return order.createdAt.isBefore(endDate) ||
                  order.createdAt.isAtSameMomentAs(endDate);
            }).toList();

        _sendResponse(request, 200, {
          'success': true,
          'message': 'Order history retrieved with date filter',
          'data': history.map((order) => order.toJson()).toList(),
          'count': history.length,
          'filter': {
            'endDate': endDateStr,
            'endDateParsed': endDate.toIso8601String(),
          },
        });
      } catch (e) {
        _sendResponse(request, 400, {
          'success': false,
          'message': 'Invalid endDate format. Use YYYY-MM-DD or ISO8601 format',
          'error': e.toString(),
        });
        return;
      }
    } else {
      // No filter, return all history
      _sendResponse(request, 200, {
        'success': true,
        'message': 'Order history retrieved',
        'data': history.map((order) => order.toJson()).toList(),
        'count': history.length,
      });
    }
  }

  Future<void> _deleteHistory(HttpRequest request) async {
    // Get optional endDate parameter from query string
    final endDateStr = request.uri.queryParameters['endDate'];

    DateTime? endDate;

    // Parse endDate if provided
    if (endDateStr != null && endDateStr.isNotEmpty) {
      try {
        // Parse the endDate string (expects format: YYYY-MM-DD or ISO8601)
        endDate = DateTime.parse(endDateStr);

        // Set to end of day (23:59:59.999)
        endDate = DateTime(
          endDate.year,
          endDate.month,
          endDate.day,
          23,
          59,
          59,
          999,
        );
      } catch (e) {
        _sendResponse(request, 400, {
          'success': false,
          'message': 'Invalid endDate format. Use YYYY-MM-DD or ISO8601 format',
          'error': e.toString(),
        });
        return;
      }
    }

    // Delete history with optional date filter
    final deletedCount = orderController.deleteHistory(endDate: endDate);

    if (endDate != null) {
      _sendResponse(request, 200, {
        'success': true,
        'message': 'History deleted with date filter',
        'deletedCount': deletedCount,
        'filter': {
          'endDate': endDateStr,
          'endDateParsed': endDate.toIso8601String(),
        },
      });
    } else {
      _sendResponse(request, 200, {
        'success': true,
        'message': 'All history deleted',
        'deletedCount': deletedCount,
      });
    }
  }

  Future<void> _deleteOrder(HttpRequest request) async {
    final body = await _getRequestBody(request);
    final orderId = body['orderId'] as String?;

    if (orderId == null) {
      _sendResponse(request, 400, {
        'success': false,
        'message': 'Order ID is required',
      });
      return;
    }

    // Check if order exists and status is "done"
    final order = orderController.orders.firstWhereOrNull(
      (o) => o.id == orderId,
    );

    if (order == null) {
      _sendResponse(request, 404, {
        'success': false,
        'message': 'Order not found',
      });
      return;
    }

    // Allow deletion of orders with status "new" or "done"
    if (order.status != 'new' && order.status != 'done') {
      _sendResponse(request, 403, {
        'success': false,
        'message': 'Only orders with status "new" or "done" can be deleted',
        'data': {'currentStatus': order.status},
      });
      return;
    }

    orderController.deleteOrder(orderId);
    _sendResponse(request, 200, {
      'success': true,
      'message': 'Order deleted',
      'data': {'orderId': orderId},
    });
  }

  // List all images
  Future<void> _listImages(HttpRequest request) async {
    try {
      final directory = await getApplicationDocumentsDirectory();
      final imagesDir = Directory('${directory.path}/images');

      if (!await imagesDir.exists()) {
        _sendResponse(request, 200, {
          'success': true,
          'message': 'No images directory found',
          'data': {'images': [], 'directory': imagesDir.path},
        });
        return;
      }

      final files = await imagesDir.list().toList();
      final imageFiles =
          files.where((f) => f is File).map((f) {
            final filename = f.path.split('/').last;
            return {
              'filename': filename,
              'url':
                  'http://${serverController.serverAddress.value}:${serverController.serverPort.value}/images/$filename',
              'path': f.path,
            };
          }).toList();

      _sendResponse(request, 200, {
        'success': true,
        'message': 'Images retrieved',
        'data': {
          'count': imageFiles.length,
          'images': imageFiles,
          'directory': imagesDir.path,
        },
      });
    } catch (e) {
      _sendResponse(request, 500, {
        'success': false,
        'message': 'Error listing images: $e',
      });
    }
  }

  // Serve images
  Future<void> _serveImage(HttpRequest request) async {
    try {
      final filename = request.uri.path.split('/images/').last;
      final directory = await getApplicationDocumentsDirectory();
      var filePath = '${directory.path}/images/$filename';
      var file = File(filePath);

      print('Looking for image at: $filePath');

      // If not found in images directory, try to find it in the database
      if (!await file.exists()) {
        print('Not found in images directory, searching in menu items...');
        final menus = menuController.getAllMenus();
        for (var menu in menus) {
          if (menu.imagePath != null && menu.imagePath!.contains(filename)) {
            print('Found in menu: ${menu.imagePath}');
            // Try the original path
            file = File(menu.imagePath!);
            if (await file.exists()) {
              filePath = menu.imagePath!;
              break;
            }
          }
        }
      }

      if (await file.exists()) {
        final bytes = await file.readAsBytes();
        request.response.headers.contentType = ContentType('image', 'jpeg');
        request.response.add(bytes);
        request.response.close();
      } else {
        print('Image not found at: $filePath');
        _sendResponse(request, 404, {
          'success': false,
          'message': 'Image not found',
          'requestedFile': filename,
          'searchedPath': filePath,
        });
      }
    } catch (e) {
      _sendResponse(request, 500, {
        'success': false,
        'message': 'Error serving image: $e',
      });
    }
  }

  // Helper methods
  Future<Map<String, dynamic>> _getRequestBody(HttpRequest request) async {
    final content = await utf8.decoder.bind(request).join();
    return jsonDecode(content) as Map<String, dynamic>;
  }

  void _sendResponse(
    HttpRequest request,
    int statusCode,
    Map<String, dynamic> body,
  ) {
    request.response.statusCode = statusCode;
    request.response.headers.contentType = ContentType.json;
    request.response.write(jsonEncode(body));
    request.response.close();
  }

  void stopServer() {
    _server?.close();
    serverController.stopServer();
  }
}
