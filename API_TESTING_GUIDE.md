# API Testing Guide

## Quick Reference for Testing the Flutter Local HTTP Server

### Prerequisites
1. Start the Flutter app: `flutter run`
2. In the app, tap "Start Server" button
3. Note the IP address displayed (e.g., `http://192.168.1.100:8080`)

Replace `YOUR_IP` in the examples below with your actual server IP address.

---

## Complete Workflow Example

### Step 1: Create a Category
```bash
curl -X POST http://YOUR_IP:8080/category/add \
  -H "Content-Type: application/json" \
  -d '{"name": "Beverages"}'
```

**Copy the `id` from the response (e.g., "1732108800000")**

---

### Step 2: Upload an Image
```bash
curl -X POST http://YOUR_IP:8080/menu/upload-image \
  -F "file=@/path/to/your/image.jpg"
```

**Copy the `imagePath` from the response (e.g., "/images/1732108800001_image.jpg")**

---

### Step 3: Add a Menu Item
```bash
curl -X POST http://YOUR_IP:8080/menu/add \
  -H "Content-Type: application/json" \
  -d '{
    "name": "Cappuccino",
    "price": 4.99,
    "categoryId": "1732108800000",
    "imagePath": "/images/1732108800001_image.jpg"
  }'
```

**Copy the menu item `id` from the response**

---

### Step 4: View All Categories
```bash
curl -X GET http://YOUR_IP:8080/category
```

---

### Step 5: View All Menu Items
```bash
curl -X GET http://YOUR_IP:8080/menu
```

---

### Step 6: Create an Order
```bash
curl -X POST http://YOUR_IP:8080/orders/create \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {
        "menuId": "1732108800002",
        "menuName": "Cappuccino",
        "quantity": 2,
        "price": 4.99
      }
    ],
    "total": 9.98
  }'
```

**Copy the order `id` from the response**

---

### Step 7: View All Orders
```bash
curl -X GET http://YOUR_IP:8080/orders
```

---

### Step 8: Update Order Status
```bash
curl -X POST http://YOUR_IP:8080/orders/update-status \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "1732108800003",
    "status": "done"
  }'
```

---

### Step 9: Access an Uploaded Image

**In Browser:**
```
http://YOUR_IP:8080/images/1732108800001_image.jpg
```

**Using curl (save to file):**
```bash
curl http://YOUR_IP:8080/images/1732108800001_image.jpg -o downloaded_image.jpg
```

---

## Postman Collection

### 1. Create Environment in Postman
- Variable name: `base_url`
- Initial value: `http://YOUR_IP:8080`
- Variable name: `category_id`
- Initial value: (leave empty, will be set from response)

### 2. Import Requests

**Request 1: Add Category**
```
POST {{base_url}}/category/add
Content-Type: application/json

{
  "name": "Beverages"
}

// In Tests tab, add:
pm.environment.set("category_id", pm.response.json().data.id);
```

**Request 2: Add Menu**
```
POST {{base_url}}/menu/add
Content-Type: application/json

{
  "name": "Espresso",
  "price": 3.50,
  "categoryId": "{{category_id}}"
}

// In Tests tab, add:
pm.environment.set("menu_id", pm.response.json().data.id);
```

**Request 3: Create Order**
```
POST {{base_url}}/orders/create
Content-Type: application/json

{
  "items": [
    {
      "menuId": "{{menu_id}}",
      "menuName": "Espresso",
      "quantity": 1,
      "price": 3.50
    }
  ],
  "total": 3.50
}

// In Tests tab, add:
pm.environment.set("order_id", pm.response.json().data.id);
```

---

## Python Testing Script

Save this as `test_api.py`:

```python
import requests
import json

# Replace with your server IP
BASE_URL = "http://YOUR_IP:8080"

def test_category():
    # Add category
    response = requests.post(
        f"{BASE_URL}/category/add",
        json={"name": "Beverages"}
    )
    print("Add Category:", response.json())
    
    # Get all categories
    response = requests.get(f"{BASE_URL}/category")
    print("All Categories:", response.json())
    return response.json()['data'][0]['id']

def test_menu(category_id):
    # Add menu item
    response = requests.post(
        f"{BASE_URL}/menu/add",
        json={
            "name": "Coffee",
            "price": 5.99,
            "categoryId": category_id
        }
    )
    print("Add Menu:", response.json())
    
    # Get all menus
    response = requests.get(f"{BASE_URL}/menu")
    print("All Menus:", response.json())
    return response.json()['data'][0]['id']

def test_order(menu_id):
    # Create order
    response = requests.post(
        f"{BASE_URL}/orders/create",
        json={
            "items": [
                {
                    "menuId": menu_id,
                    "menuName": "Coffee",
                    "quantity": 2,
                    "price": 5.99
                }
            ],
            "total": 11.98
        }
    )
    print("Create Order:", response.json())
    
    # Get all orders
    response = requests.get(f"{BASE_URL}/orders")
    print("All Orders:", response.json())
    return response.json()['data'][0]['id']

def test_update_order(order_id):
    response = requests.post(
        f"{BASE_URL}/orders/update-status",
        json={
            "orderId": order_id,
            "status": "done"
        }
    )
    print("Update Order Status:", response.json())

if __name__ == "__main__":
    category_id = test_category()
    menu_id = test_menu(category_id)
    order_id = test_order(menu_id)
    test_update_order(order_id)
```

Run with:
```bash
python test_api.py
```

---

## JavaScript/Node.js Testing Script

Save this as `test_api.js`:

```javascript
const BASE_URL = "http://YOUR_IP:8080";

async function testCategory() {
  // Add category
  const response = await fetch(`${BASE_URL}/category/add`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({ name: "Beverages" })
  });
  const data = await response.json();
  console.log("Add Category:", data);
  
  // Get all categories
  const getResponse = await fetch(`${BASE_URL}/category`);
  const categories = await getResponse.json();
  console.log("All Categories:", categories);
  
  return categories.data[0].id;
}

async function testMenu(categoryId) {
  const response = await fetch(`${BASE_URL}/menu/add`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      name: "Latte",
      price: 6.50,
      categoryId: categoryId
    })
  });
  const data = await response.json();
  console.log("Add Menu:", data);
  
  return data.data.id;
}

async function testOrder(menuId) {
  const response = await fetch(`${BASE_URL}/orders/create`, {
    method: 'POST',
    headers: { 'Content-Type': 'application/json' },
    body: JSON.stringify({
      items: [{
        menuId: menuId,
        menuName: "Latte",
        quantity: 1,
        price: 6.50
      }],
      total: 6.50
    })
  });
  const data = await response.json();
  console.log("Create Order:", data);
  
  return data.data.id;
}

async function runTests() {
  const categoryId = await testCategory();
  const menuId = await testMenu(categoryId);
  const orderId = await testOrder(menuId);
  console.log("All tests completed!");
}

runTests();
```

Run with:
```bash
node test_api.js
```

---

## Common Issues & Solutions

### Issue: Connection Refused
**Solution:** Ensure both devices are on the same WiFi network and the server is running.

### Issue: 404 Not Found
**Solution:** Check the endpoint URL. Make sure you're using the correct path.

### Issue: Image Upload Fails
**Solution:** Ensure you're using multipart/form-data and the file exists at the specified path.

### Issue: Invalid JSON
**Solution:** Validate your JSON using a tool like jsonlint.com before sending the request.

---

## Tips for Testing

1. **Use the App First**: Before testing with curl/Postman, add some data through the app UI to understand the flow.

2. **Save IDs**: When you create resources (categories, menus, orders), save their IDs for future requests.

3. **Check the App**: After making API calls, check the app UI to verify the changes.

4. **Real-time Updates**: The app uses GetX, so changes should appear immediately in the UI.

5. **Browser Testing**: For GET requests, you can simply paste the URL in your browser.

---

## Example Complete Test Sequence

```bash
# 1. Add Beverages category
curl -X POST http://YOUR_IP:8080/category/add \
  -H "Content-Type: application/json" \
  -d '{"name": "Beverages"}'
# Response: {"success":true,"message":"Category added","data":{"name":"Beverages"}}

# 2. Add Food category
curl -X POST http://YOUR_IP:8080/category/add \
  -H "Content-Type: application/json" \
  -d '{"name": "Food"}'

# 3. Get all categories
curl http://YOUR_IP:8080/category

# 4. Add menu items (use actual category IDs from step 1 and 2)
curl -X POST http://YOUR_IP:8080/menu/add \
  -H "Content-Type: application/json" \
  -d '{"name":"Coffee","price":4.99,"categoryId":"CATEGORY_ID_HERE"}'

curl -X POST http://YOUR_IP:8080/menu/add \
  -H "Content-Type: application/json" \
  -d '{"name":"Sandwich","price":7.99,"categoryId":"FOOD_CATEGORY_ID_HERE"}'

# 5. Get all menus
curl http://YOUR_IP:8080/menu

# 6. Create an order (use actual menu IDs)
curl -X POST http://YOUR_IP:8080/orders/create \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"menuId":"MENU_ID_1","menuName":"Coffee","quantity":2,"price":4.99},
      {"menuId":"MENU_ID_2","menuName":"Sandwich","quantity":1,"price":7.99}
    ],
    "total": 17.97
  }'

# 7. View orders
curl http://YOUR_IP:8080/orders

# 8. Update order status (use actual order ID)
curl -X POST http://YOUR_IP:8080/orders/update-status \
  -H "Content-Type: application/json" \
  -d '{"orderId":"ORDER_ID_HERE","status":"done"}'

# 9. Check updated orders
curl http://YOUR_IP:8080/orders
```

---

## Update and Delete Operations (CRUD Complete)

### Category Update and Delete

**Update Category:**
```bash
curl -X POST http://YOUR_IP:8080/category/update \
  -H "Content-Type: application/json" \
  -d '{
    "id": "CATEGORY_ID_HERE",
    "name": "Updated Beverages"
  }'
```

**Delete Category:**
```bash
curl -X POST http://YOUR_IP:8080/category/delete \
  -H "Content-Type: application/json" \
  -d '{
    "id": "CATEGORY_ID_HERE"
  }'
```

### Menu Update and Delete

**Update Menu Item:**
```bash
curl -X POST http://YOUR_IP:8080/menu/update \
  -H "Content-Type: application/json" \
  -d '{
    "id": "MENU_ID_HERE",
    "name": "Updated Coffee",
    "price": 5.99,
    "categoryId": "CATEGORY_ID_HERE",
    "imagePath": "/images/existing_image.jpg"
  }'
```

**Delete Menu Item:**
```bash
curl -X POST http://YOUR_IP:8080/menu/delete \
  -H "Content-Type: application/json" \
  -d '{
    "id": "MENU_ID_HERE"
  }'
```

### Order Delete

**Delete Order:**
```bash
curl -X POST http://YOUR_IP:8080/orders/delete \
  -H "Content-Type: application/json" \
  -d '{
    "id": "ORDER_ID_HERE"
  }'
```

**Important:** Orders can only be deleted if their status is "done". If you try to delete an order with status "ongoing", you will receive a 403 error:
```json
{
  "success": false,
  "message": "Only orders with status \"done\" can be deleted",
  "data": {
    "currentStatus": "ongoing"
  }
}
```

To delete an order with "ongoing" status, first update it to "done":
```bash
# First, update order status to "done"
curl -X POST http://YOUR_IP:8080/orders/update-status \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "ORDER_ID_HERE",
    "status": "done"
  }'

# Then delete the order
curl -X POST http://YOUR_IP:8080/orders/delete \
  -H "Content-Type: application/json" \
  -d '{
    "id": "ORDER_ID_HERE"
  }'
```

---

## Complete CRUD Testing Sequence

```bash
# === CATEGORY CRUD ===

# Create
curl -X POST http://YOUR_IP:8080/category/add \
  -H "Content-Type: application/json" \
  -d '{"name": "Test Category"}'
# Save the returned ID as CATEGORY_ID

# Read
curl http://YOUR_IP:8080/category

# Update
curl -X POST http://YOUR_IP:8080/category/update \
  -H "Content-Type: application/json" \
  -d '{"id":"CATEGORY_ID","name":"Updated Category"}'

# Delete
curl -X POST http://YOUR_IP:8080/category/delete \
  -H "Content-Type: application/json" \
  -d '{"id":"CATEGORY_ID"}'

# === MENU CRUD ===

# Create
curl -X POST http://YOUR_IP:8080/menu/add \
  -H "Content-Type: application/json" \
  -d '{"name":"Test Menu","price":9.99,"categoryId":"CATEGORY_ID"}'
# Save the returned ID as MENU_ID

# Read
curl http://YOUR_IP:8080/menu

# Update
curl -X POST http://YOUR_IP:8080/menu/update \
  -H "Content-Type: application/json" \
  -d '{"id":"MENU_ID","name":"Updated Menu","price":12.99,"categoryId":"CATEGORY_ID"}'

# Delete
curl -X POST http://YOUR_IP:8080/menu/delete \
  -H "Content-Type: application/json" \
  -d '{"id":"MENU_ID"}'

# === ORDER CRUD ===

# Create
curl -X POST http://YOUR_IP:8080/orders/create \
  -H "Content-Type: application/json" \
  -d '{"items":[{"menuId":"MENU_ID","menuName":"Test Menu","quantity":1,"price":9.99}],"total":9.99}'
# Save the returned ID as ORDER_ID

# Read
curl http://YOUR_IP:8080/orders

# Update Status
curl -X POST http://YOUR_IP:8080/orders/update-status \
  -H "Content-Type: application/json" \
  -d '{"orderId":"ORDER_ID","status":"done"}'

# Delete
curl -X POST http://YOUR_IP:8080/orders/delete \
  -H "Content-Type: application/json" \
  -d '{"id":"ORDER_ID"}'
```

---

## API Endpoints Summary

### Categories
- `GET /category` - Get all categories
- `POST /category/add` - Create category
- `POST /category/update` - Update category
- `POST /category/delete` - Delete category

### Menu
- `GET /menu` - Get all menu items (with full image URLs)
- `POST /menu/add` - Create menu item
- `POST /menu/update` - Update menu item
- `POST /menu/delete` - Delete menu item
- `POST /menu/upload-image` - Upload menu image
- `GET /images/{filename}` - Get uploaded image
- `GET /images/list` - List all uploaded images

### Orders
- `GET /orders` - Get all orders
- `POST /orders/create` - Create order
- `POST /orders/update-status` - Update order status
- `POST /orders/delete` - Delete order
