# Flutter Local HTTP Server with GetX# order



A Flutter application that acts as a local HTTP server with a built-in admin interface for managing categories, menu items, and orders.A new Flutter project.



## 📁 Folder Structure## Getting Started



```This project is a starting point for a Flutter application.

/lib

  /controllersA few resources to get you started if this is your first Flutter project:

    category_controller.dart

    menu_controller.dart- [Lab: Write your first Flutter app](https://docs.flutter.dev/get-started/codelab)

    order_controller.dart- [Cookbook: Useful Flutter samples](https://docs.flutter.dev/cookbook)

    server_controller.dart

  /modelsFor help getting started with Flutter development, view the

    category.dart[online documentation](https://docs.flutter.dev/), which offers tutorials,

    menu.dartsamples, guidance on mobile development, and a full API reference.

    order.dart
  /services
    server_service.dart
  /views
    home_view.dart
    category_view.dart
    menu_view.dart
    order_view.dart
  main.dart
```

## 🚀 Getting Started

### Prerequisites
- Flutter SDK (3.0+)
- Dart SDK (3.0+)

### Installation

1. Navigate to the project directory:
```bash
cd order
```

2. Get dependencies:
```bash
flutter pub get
```

3. Run the app:
```bash
flutter run
```

## 📱 App Features

### 1. Home Page
- **Start Server**: Button to start the HTTP server
- **Stop Server**: Button to stop the HTTP server
- **Server Status**: Displays whether server is running and shows the IP address and port
- Navigation buttons to admin pages

### 2. Category Management
- Add new categories
- View all categories
- Categories are stored in-memory

### 3. Menu Management
- Add menu items with name, price, category, and image
- Upload images from gallery
- View all menu items with images
- Images are stored in app's document directory

### 4. Order Management
- View all orders received from API
- Update order status (ongoing → done)
- Real-time updates using GetX

## 🔌 API Endpoints

### Server Address
When the server is running, it will display the local IP address, e.g., `http://192.168.1.100:8080`

### Category Endpoints

#### GET /category
Get all categories

**Request:**
```bash
curl -X GET http://192.168.1.100:8080/category
```

**Response:**
```json
{
  "success": true,
  "message": "Categories retrieved",
  "data": [
    {
      "id": "1700000000000",
      "name": "Beverages"
    }
  ]
}
```

#### POST /category/add
Add a new category

**Request:**
```bash
curl -X POST http://192.168.1.100:8080/category/add \
  -H "Content-Type: application/json" \
  -d '{"name": "Beverages"}'
```

**Response:**
```json
{
  "success": true,
  "message": "Category added",
  "data": {
    "name": "Beverages"
  }
}
```

### Menu Endpoints

#### GET /menu
Get all menu items

**Request:**
```bash
curl -X GET http://192.168.1.100:8080/menu
```

**Response:**
```json
{
  "success": true,
  "message": "Menus retrieved",
  "data": [
    {
      "id": "1700000000001",
      "name": "Coffee",
      "price": 5.99,
      "categoryId": "1700000000000",
      "imagePath": "/images/1700000000001_coffee.jpg"
    }
  ]
}
```

#### POST /menu/add
Add a new menu item

**Request:**
```bash
curl -X POST http://192.168.1.100:8080/menu/add \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coffee",
    "price": 5.99,
    "categoryId": "1700000000000",
    "imagePath": "/images/1700000000001_coffee.jpg"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Menu added",
  "data": {
    "name": "Coffee",
    "price": 5.99,
    "categoryId": "1700000000000",
    "imagePath": "/images/1700000000001_coffee.jpg"
  }
}
```

#### POST /menu/upload-image
Upload an image for a menu item

**Request:**
```bash
curl -X POST http://192.168.1.100:8080/menu/upload-image \
  -F "file=@/path/to/image.jpg"
```

**Response:**
```json
{
  "success": true,
  "message": "Image uploaded",
  "data": {
    "imagePath": "/images/1700000000001_image.jpg",
    "url": "http://192.168.1.100:8080/images/1700000000001_image.jpg"
  }
}
```

### Order Endpoints

#### GET /orders
Get all orders

**Request:**
```bash
curl -X GET http://192.168.1.100:8080/orders
```

**Response:**
```json
{
  "success": true,
  "message": "Orders retrieved",
  "data": [
    {
      "id": "1700000000002",
      "items": [
        {
          "menuId": "1700000000001",
          "menuName": "Coffee",
          "quantity": 2,
          "price": 5.99
        }
      ],
      "total": 11.98,
      "status": "ongoing",
      "createdAt": "2025-11-20T10:30:00.000Z"
    }
  ]
}
```

#### POST /orders/create
Create a new order

**Request:**
```bash
curl -X POST http://192.168.1.100:8080/orders/create \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "menuId": "1700000000001",
        "menuName": "Coffee",
        "quantity": 2,
        "price": 5.99
      }
    ],
    "total": 11.98
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Order created",
  "data": {
    "items": [
      {
        "menuId": "1700000000001",
        "menuName": "Coffee",
        "quantity": 2,
        "price": 5.99
      }
    ],
    "total": 11.98
  }
}
```

#### POST /orders/update-status
Update order status

**Request:**
```bash
curl -X POST http://192.168.1.100:8080/orders/update-status \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "1700000000002",
    "status": "done"
  }'
```

**Response:**
```json
{
  "success": true,
  "message": "Order status updated",
  "data": {
    "orderId": "1700000000002",
    "status": "done"
  }
}
```

### Image Serving

#### GET /images/{filename}
Access uploaded images

**Request:**
```bash
curl -X GET http://192.168.1.100:8080/images/1700000000001_coffee.jpg
```

**Response:**
Returns the image file directly

**Usage in Browser:**
Simply open `http://192.168.1.100:8080/images/1700000000001_coffee.jpg` in your browser

**Usage in HTML:**
```html
<img src="http://192.168.1.100:8080/images/1700000000001_coffee.jpg" alt="Coffee">
```

## 📸 Image Upload & Access

### How Images Work

1. **Upload**: Images are uploaded via the `/menu/upload-image` endpoint using multipart/form-data
2. **Storage**: Images are saved in the app's document directory under `/images/`
3. **Access**: Images can be accessed via HTTP at `/images/{filename}`

### Example Workflow

1. **Upload an image:**
```bash
curl -X POST http://192.168.1.100:8080/menu/upload-image \
  -F "file=@coffee.jpg"
```

Response:
```json
{
  "success": true,
  "message": "Image uploaded",
  "data": {
    "imagePath": "/images/1700520000000_coffee.jpg",
    "url": "http://192.168.1.100:8080/images/1700520000000_coffee.jpg"
  }
}
```

2. **Add menu item with the image:**
```bash
curl -X POST http://192.168.1.100:8080/menu/add \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Coffee",
    "price": 5.99,
    "categoryId": "1700000000000",
    "imagePath": "/images/1700520000000_coffee.jpg"
  }'
```

3. **Access the image:**
- In browser: `http://192.168.1.100:8080/images/1700520000000_coffee.jpg`
- In mobile app: Use the URL from the upload response

## 🛠 Postman Collection

Import these examples into Postman:

### Environment Variables
- `base_url`: `http://192.168.1.100:8080` (replace with your actual server IP)

### Example Requests

**Create Category:**
```
POST {{base_url}}/category/add
Content-Type: application/json

{
  "name": "Beverages"
}
```

**Create Menu Item:**
```
POST {{base_url}}/menu/add
Content-Type: application/json

{
  "name": "Latte",
  "price": 6.50,
  "categoryId": "{{categoryId}}"
}
```

**Create Order:**
```
POST {{base_url}}/orders/create
Content-Type: application/json

{
  "items": [
    {
      "menuId": "{{menuId}}",
      "menuName": "Latte",
      "quantity": 2,
      "price": 6.50
    }
  ],
  "total": 13.00
}
```

## 🔒 CORS

The server has CORS enabled by default, allowing requests from any origin. This is suitable for development and local testing.

## 💾 Data Storage

- All data is stored **in-memory** using GetX reactive lists
- Data will be lost when the app is closed
- For persistent storage, you can extend the controllers to use local databases like Hive or SQLite

## 📝 Notes

- The server binds to all network interfaces (0.0.0.0) on port 8080
- Make sure your device and testing device/computer are on the same network
- The IP address displayed in the app is your device's local network IP
- Images are stored locally on the device running the Flutter app

## 🐛 Troubleshooting

### Server won't start
- Check if port 8080 is already in use
- Ensure your device has network permissions

### Can't access API from another device
- Make sure both devices are on the same WiFi network
- Check firewall settings
- Use the IP address shown in the app, not localhost

### Images not displaying
- Verify the image was uploaded successfully
- Check the imagePath in the menu item
- Ensure you're using the full URL with the server's IP address

## 📄 License

This project is open source and available under the MIT License.
