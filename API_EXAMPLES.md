# API Examples - GET Menu and Orders

## Quick Start

Replace `YOUR_IP` with your actual server IP address (e.g., `192.168.30.100`)

---

## GET Menu API

### Endpoint
```
GET http://YOUR_IP:8080/menu
```

### Description
Retrieves all menu items with their details, including full image URLs.

### Request Example

**Using cURL:**
```bash
curl http://192.168.30.100:8080/menu
```

**Using Browser:**
```
http://192.168.30.100:8080/menu
```

**Using JavaScript/Fetch:**
```javascript
fetch('http://192.168.30.100:8080/menu')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Using Python:**
```python
import requests

response = requests.get('http://192.168.30.100:8080/menu')
data = response.json()
print(data)
```

### Response Example

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Menus retrieved",
  "data": [
    {
      "id": "1732108800001",
      "name": "Cappuccino",
      "price": 15000,
      "categoryId": "1732108700000",
      "imagePath": "/images/1732108900000_coffee.jpg",
      "imageUrl": "http://192.168.30.100:8080/images/1732108900000_coffee.jpg"
    },
    {
      "id": "1732108800002",
      "name": "Nasi Goreng",
      "price": 25000,
      "categoryId": "1732108700001",
      "imagePath": "/images/1732108900001_nasigoreng.jpg",
      "imageUrl": "http://192.168.30.100:8080/images/1732108900001_nasigoreng.jpg"
    },
    {
      "id": "1732108800003",
      "name": "Mie Ayam",
      "price": 18000,
      "categoryId": "1732108700001",
      "imagePath": null,
      "imageUrl": null
    }
  ]
}
```

**Empty Response (No menu items):**
```json
{
  "success": true,
  "message": "Menus retrieved",
  "data": []
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always `true` for successful requests |
| `message` | string | Status message |
| `data` | array | Array of menu objects |
| `data[].id` | string | Unique menu item ID (timestamp-based) |
| `data[].name` | string | Menu item name |
| `data[].price` | number | Price in Rupiah (without decimals) |
| `data[].categoryId` | string | Reference to category ID |
| `data[].imagePath` | string\|null | Relative image path or null |
| `data[].imageUrl` | string\|null | Full HTTP URL to image or null |

### Image URL Usage

The `imageUrl` field provides a complete URL that can be used directly:

```html
<!-- In HTML -->
<img src="http://192.168.30.100:8080/images/1732108900000_coffee.jpg" alt="Cappuccino">
```

```javascript
// In React/React Native
<Image source={{ uri: 'http://192.168.30.100:8080/images/1732108900000_coffee.jpg' }} />
```

---

## GET Orders API

### Endpoint
```
GET http://YOUR_IP:8080/orders
```

### Description
Retrieves all orders with their items, totals, status, and customer information.

### Request Example

**Using cURL:**
```bash
curl http://192.168.30.100:8080/orders
```

**Using Browser:**
```
http://192.168.30.100:8080/orders
```

**Using JavaScript/Fetch:**
```javascript
fetch('http://192.168.30.100:8080/orders')
  .then(response => response.json())
  .then(data => console.log(data));
```

**Using Python:**
```python
import requests

response = requests.get('http://192.168.30.100:8080/orders')
data = response.json()
print(data)
```

---

## GET Orders by Username API

### Endpoint
```
GET http://YOUR_IP:8080/orders/by-username?username=xxx
```

### Description
Retrieves all orders for a specific username (case-insensitive).

### Query Parameters

| Parameter | Type | Required | Description |
|-----------|------|----------|-------------|
| `username` | string | Yes | The username to filter orders by |

### Request Example

**Using cURL:**
```bash
curl "http://192.168.30.100:8080/orders/by-username?username=John%20Doe"
```

**Using Browser:**
```
http://192.168.30.100:8080/orders/by-username?username=John Doe
```

**Using JavaScript/Fetch:**
```javascript
const username = 'John Doe';
fetch(`http://192.168.30.100:8080/orders/by-username?username=${encodeURIComponent(username)}`)
  .then(response => response.json())
  .then(data => console.log(data));
```

**Using Python:**
```python
import requests

username = 'John Doe'
response = requests.get(
    'http://192.168.30.100:8080/orders/by-username',
    params={'username': username}
)
data = response.json()
print(data)
```

### Response Example

**Success Response (200 OK) - Orders Found:**
```json
{
  "success": true,
  "message": "Orders retrieved for username: John Doe",
  "count": 2,
  "data": [
    {
      "id": "1732109000001",
      "items": [
        {
          "menuId": "1732108800001",
          "menuName": "Cappuccino",
          "quantity": 2,
          "price": 15000
        }
      ],
      "total": 30000,
      "status": "new",
      "createdAt": "2025-11-20T10:30:00.000Z",
      "ipAddress": "192.168.30.120",
      "username": "John Doe"
    },
    {
      "id": "1732109000004",
      "items": [
        {
          "menuId": "1732108800002",
          "menuName": "Nasi Goreng",
          "quantity": 1,
          "price": 25000
        }
      ],
      "total": 25000,
      "status": "done",
      "createdAt": "2025-11-20T11:00:00.000Z",
      "ipAddress": "192.168.30.120",
      "username": "John Doe"
    }
  ]
}
```

**Success Response (200 OK) - No Orders Found:**
```json
{
  "success": true,
  "message": "Orders retrieved for username: NonExistent",
  "count": 0,
  "data": []
}
```

**Error Response (400 Bad Request) - Missing Username:**
```json
{
  "success": false,
  "message": "Username query parameter is required"
}
```

### Features

- **Case-insensitive search**: "John Doe", "john doe", and "JOHN DOE" all match
- **Exact match**: Only returns orders with exact username match (after case normalization)
- **Includes count**: Response includes total number of orders found
- **Null handling**: Filters out orders with null username

### Response Example

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Orders retrieved",
  "data": [
    {
      "id": "1732109000001",
      "items": [
        {
          "menuId": "1732108800001",
          "menuName": "Cappuccino",
          "quantity": 2,
          "price": 15000
        },
        {
          "menuId": "1732108800002",
          "menuName": "Nasi Goreng",
          "quantity": 1,
          "price": 25000
        }
      ],
      "total": 55000,
      "status": "new",
      "createdAt": "2025-11-20T10:30:00.000Z",
      "ipAddress": "192.168.30.120",
      "username": "John Doe"
    },
    {
      "id": "1732109000002",
      "items": [
        {
          "menuId": "1732108800003",
          "menuName": "Mie Ayam",
          "quantity": 3,
          "price": 18000
        }
      ],
      "total": 54000,
      "status": "process",
      "createdAt": "2025-11-20T10:35:00.000Z",
      "ipAddress": "192.168.30.121",
      "username": "Jane Smith"
    },
    {
      "id": "1732109000003",
      "items": [
        {
          "menuId": "1732108800001",
          "menuName": "Cappuccino",
          "quantity": 1,
          "price": 15000
        }
      ],
      "total": 15000,
      "status": "done",
      "createdAt": "2025-11-20T09:00:00.000Z",
      "ipAddress": null,
      "username": null
    }
  ]
}
```

**Empty Response (No orders):**
```json
{
  "success": true,
  "message": "Orders retrieved",
  "data": []
}
```

### Response Fields

| Field | Type | Description |
|-------|------|-------------|
| `success` | boolean | Always `true` for successful requests |
| `message` | string | Status message |
| `data` | array | Array of order objects |
| `data[].id` | string | Unique order ID (timestamp-based) |
| `data[].items` | array | Array of order items |
| `data[].items[].menuId` | string | Reference to menu item ID |
| `data[].items[].menuName` | string | Menu item name (snapshot) |
| `data[].items[].quantity` | number | Quantity ordered |
| `data[].items[].price` | number | Price per unit at time of order |
| `data[].total` | number | Total order amount in Rupiah |
| `data[].status` | string | Order status: `"new"`, `"process"`, or `"done"` |
| `data[].createdAt` | string | ISO 8601 timestamp |
| `data[].ipAddress` | string\|null | Customer's IP address (optional) |
| `data[].username` | string\|null | Customer's name (optional) |

### Order Status Flow

```
new → process → done
```

- **new**: Order just created, waiting to be processed
- **process**: Order is being prepared
- **done**: Order completed (moved to reports)

### Status Update with Client Notification

When an order status is updated via the API, the server automatically sends refresh notifications to the client's IP address (if the order has an `ipAddress` field).

**Automatic Notification Requests:**
```
GET http://{order.ipAddress}:8080/refresh
GET http://{order.ipAddress}:8080/notifyorder
```

Both requests are sent in parallel when the order status is updated.

This allows client devices to be notified when their order status changes, enabling real-time updates on the client side.

**Example Flow:**
1. Client creates order from IP `192.168.30.120`
2. Server stores the order with `ipAddress: "192.168.30.120"`
3. Admin updates order status to "process"
4. Server automatically sends GET requests to:
   - `http://192.168.30.120:8080/refresh`
   - `http://192.168.30.120:8080/notifyorder`
5. Client receives both notifications and can refresh the order display

**Implementation Notes:**
- Both requests are sent in parallel using `Future.wait()`
- Each request has a 3-second timeout to prevent blocking
- Failures are logged but don't affect the status update operation
- Client must have a server running on port 8080 to receive notifications
- Client should implement both `/refresh` and `/notifyorder` endpoints

---

## Filtering Examples

### Filter by Status (Client-side)

Since the API returns all orders, you can filter client-side:

**JavaScript Example:**
```javascript
fetch('http://192.168.30.100:8080/orders')
  .then(response => response.json())
  .then(data => {
    // Get only new orders
    const newOrders = data.data.filter(order => order.status === 'new');
    
    // Get only processing orders
    const processingOrders = data.data.filter(order => order.status === 'process');
    
    // Get completed orders
    const completedOrders = data.data.filter(order => order.status === 'done');
    
    console.log('New:', newOrders);
    console.log('Processing:', processingOrders);
    console.log('Completed:', completedOrders);
  });
```

**Python Example:**
```python
import requests

response = requests.get('http://192.168.30.100:8080/orders')
data = response.json()

# Filter orders by status
new_orders = [order for order in data['data'] if order['status'] == 'new']
processing_orders = [order for order in data['data'] if order['status'] == 'process']
completed_orders = [order for order in data['data'] if order['status'] == 'done']

print(f"New orders: {len(new_orders)}")
print(f"Processing: {len(processing_orders)}")
print(f"Completed: {len(completed_orders)}")
```

---

## Complete Workflow Example

### 1. Get All Menu Items
```bash
curl http://192.168.30.100:8080/menu
```

### 2. Get All Orders
```bash
curl http://192.168.30.100:8080/orders
```

### 3. Display Menu with Images (HTML)
```html
<!DOCTYPE html>
<html>
<head>
    <title>Menu Display</title>
</head>
<body>
    <h1>Our Menu</h1>
    <div id="menu-container"></div>

    <script>
        fetch('http://192.168.30.100:8080/menu')
            .then(response => response.json())
            .then(data => {
                const container = document.getElementById('menu-container');
                
                data.data.forEach(item => {
                    const div = document.createElement('div');
                    div.innerHTML = `
                        <h3>${item.name}</h3>
                        ${item.imageUrl ? `<img src="${item.imageUrl}" width="200">` : ''}
                        <p>Rp ${item.price.toLocaleString('id-ID')}</p>
                        <hr>
                    `;
                    container.appendChild(div);
                });
            });
    </script>
</body>
</html>
```

### 4. Display Orders Dashboard (JavaScript)
```javascript
async function loadDashboard() {
    const response = await fetch('http://192.168.30.100:8080/orders');
    const data = await response.json();
    
    // Calculate statistics
    const stats = {
        total: data.data.length,
        new: data.data.filter(o => o.status === 'new').length,
        processing: data.data.filter(o => o.status === 'process').length,
        completed: data.data.filter(o => o.status === 'done').length,
        revenue: data.data
            .filter(o => o.status === 'done')
            .reduce((sum, o) => sum + o.total, 0)
    };
    
    console.log('Dashboard Statistics:');
    console.log(`Total Orders: ${stats.total}`);
    console.log(`New: ${stats.new}`);
    console.log(`Processing: ${stats.processing}`);
    console.log(`Completed: ${stats.completed}`);
    console.log(`Total Revenue: Rp ${stats.revenue.toLocaleString('id-ID')}`);
    
    return stats;
}

loadDashboard();
```

---

## Error Handling

### Network Error
```javascript
fetch('http://192.168.30.100:8080/menu')
    .then(response => {
        if (!response.ok) {
            throw new Error(`HTTP error! status: ${response.status}`);
        }
        return response.json();
    })
    .then(data => console.log(data))
    .catch(error => console.error('Error fetching menu:', error));
```

### Server Not Running
If the server is not running, you'll get a connection error:
```
Error: connect ECONNREFUSED 192.168.30.100:8080
```

**Solution**: Start the server in the app by tapping "Start Server"

---

## Common Use Cases

### 1. Mobile App Menu Screen
```dart
// Flutter example
Future<List<Menu>> fetchMenu() async {
  final response = await http.get(
    Uri.parse('http://192.168.30.100:8080/menu'),
  );
  
  if (response.statusCode == 200) {
    final data = json.decode(response.body);
    return (data['data'] as List)
        .map((item) => Menu.fromJson(item))
        .toList();
  }
  throw Exception('Failed to load menu');
}
```

### 2. Kitchen Display System
```javascript
// Continuously check for new orders
setInterval(async () => {
    const response = await fetch('http://192.168.30.100:8080/orders');
    const data = await response.json();
    
    const newOrders = data.data.filter(order => order.status === 'new');
    
    if (newOrders.length > 0) {
        console.log(`${newOrders.length} new order(s) to prepare!`);
        // Play notification sound or update UI
    }
}, 5000); // Check every 5 seconds
```

### 3. Sales Report
```python
import requests
from datetime import datetime

response = requests.get('http://192.168.30.100:8080/orders')
orders = response.json()['data']

# Filter completed orders from today
today = datetime.now().date()
today_completed = [
    order for order in orders 
    if order['status'] == 'done' and 
    datetime.fromisoformat(order['createdAt'].replace('Z', '+00:00')).date() == today
]

total_revenue = sum(order['total'] for order in today_completed)
print(f"Today's Revenue: Rp {total_revenue:,}")
print(f"Orders Completed: {len(today_completed)}")
```

### 4. Client-Side Notification Handler

To receive order status notifications, implement both endpoints on the client:

**Flutter/Dart Example:**
```dart
// Handle notification endpoints in client server
void _handleRequest(HttpRequest request) async {
  final path = request.uri.path;
  final method = request.method;

  if (path == '/refresh' && method == 'GET') {
    print('Refresh notification received!');
    // Reload order list
    await fetchOrders();
    
    request.response.statusCode = 200;
    request.response.write('OK');
    request.response.close();
  } 
  else if (path == '/notifyorder' && method == 'GET') {
    print('Order notification received!');
    // Show notification to user
    showNotification('Your order status has been updated!');
    // Reload order list
    await fetchOrders();
    
    request.response.statusCode = 200;
    request.response.write('OK');
    request.response.close();
  }
}
```

**Node.js/Express Example:**
```javascript
const express = require('express');
const app = express();

app.get('/refresh', (req, res) => {
  console.log('Refresh notification received!');
  // Trigger UI refresh
  io.emit('refreshOrders'); // Using Socket.io to notify frontend
  res.send('OK');
});

app.get('/notifyorder', (req, res) => {
  console.log('Order notification received!');
  // Show notification and refresh
  io.emit('orderUpdated', { message: 'Order status updated!' });
  res.send('OK');
});

app.listen(8080, () => {
  console.log('Client server listening on port 8080');
});
```

**Python/Flask Example:**
```python
from flask import Flask
app = Flask(__name__)

@app.route('/refresh', methods=['GET'])
def refresh():
    print('Refresh notification received!')
    # Trigger data refresh
    return 'OK', 200

@app.route('/notifyorder', methods=['GET'])
def notify_order():
    print('Order notification received!')
    # Show notification and refresh
    return 'OK', 200

if __name__ == '__main__':
    app.run(host='0.0.0.0', port=8080)
```

---

## Response Time

Typical response times on local network:
- **GET /menu**: ~10-50ms
- **GET /orders**: ~10-50ms

*Note: Response time may vary based on:*
- Network latency
- Number of items/orders
- Device performance

