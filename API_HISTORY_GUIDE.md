# Order History API Guide

## Overview

The Order History feature allows you to archive completed orders by moving them from the active orders database to a separate history database. This keeps your active orders clean while preserving historical data.

---

## API Endpoints

### 1. Post Order to History

**Endpoint:**
```
POST http://YOUR_IP:8080/orders/post-to-history
```

**Description:**
Moves a completed order (status: "done") to the history database and changes its status to "posted".

**Request Body:**
```json
{
  "orderId": "1732108800003"
}
```

**Example (cURL):**
```bash
curl -X POST http://192.168.30.100:8080/orders/post-to-history \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "1732108800003"
  }'
```

**Example (JavaScript):**
```javascript
const orderId = "1732108800003";

fetch('http://192.168.30.100:8080/orders/post-to-history', {
  method: 'POST',
  headers: {
    'Content-Type': 'application/json'
  },
  body: JSON.stringify({ orderId })
})
.then(response => response.json())
.then(data => console.log('Posted to history:', data))
.catch(error => console.error('Error:', error));
```

**Example (Python):**
```python
import requests

order_id = "1732108800003"

response = requests.post(
    'http://192.168.30.100:8080/orders/post-to-history',
    json={'orderId': order_id}
)

print(response.json())
```

**Success Response (200 OK):**
```json
{
  "success": true,
  "message": "Order posted to history",
  "data": {
    "orderId": "1732108800003",
    "status": "posted"
  }
}
```

**Error Response (404 Not Found):**
```json
{
  "success": false,
  "message": "Order not found"
}
```

**Error Response (403 Forbidden):**
```json
{
  "success": false,
  "message": "Only orders with status \"done\" can be posted to history",
  "data": {
    "currentStatus": "process"
  }
}
```

**Error Response (400 Bad Request):**
```json
{
  "success": false,
  "message": "OrderId is required"
}
```

---

### 2. Get Order History

**Endpoint:**
```
GET http://YOUR_IP:8080/history
GET http://YOUR_IP:8080/history?endDate=2025-11-24
```

**Description:**
Retrieves all orders that have been posted to history (status: "posted"). Optionally filter by end date to get history from the beginning until a specific date.

**Query Parameters:**
- `endDate` (optional): Filter history up to this date (format: YYYY-MM-DD or ISO8601)
  - Example: `2025-11-24` returns all history from first order until end of November 24, 2025
  - Example: `2025-11-24T15:30:00Z` returns all history until that specific time

**Example (cURL - All History):**
```bash
curl http://192.168.30.100:8080/history
```

**Example (cURL - Filtered by Date):**
```bash
# Get all history until today
curl http://192.168.30.100:8080/history?endDate=2025-11-24

# Get all history until end of November 2025
curl http://192.168.30.100:8080/history?endDate=2025-11-30
```

**Example (JavaScript - All History):**
```javascript
fetch('http://192.168.30.100:8080/history')
  .then(response => response.json())
  .then(data => {
    console.log(`Total history: ${data.count}`);
    console.log('History orders:', data.data);
  })
  .catch(error => console.error('Error:', error));
```

**Example (JavaScript - Filtered by Date):**
```javascript
// Get history until today
const today = new Date().toISOString().split('T')[0]; // YYYY-MM-DD

fetch(`http://192.168.30.100:8080/history?endDate=${today}`)
  .then(response => response.json())
  .then(data => {
    console.log(`Total history until ${data.filter.endDate}: ${data.count}`);
    console.log('Filtered history:', data.data);
  })
  .catch(error => console.error('Error:', error));
```

**Example (Python - All History):**
```python
import requests

response = requests.get('http://192.168.30.100:8080/history')
data = response.json()

print(f"Total history: {data['count']}")
for order in data['data']:
    print(f"Order #{order['id']} - Rp {order['total']:,}")
```

**Example (Python - Filtered by Date):**
```python
import requests
from datetime import datetime

# Get history until today
today = datetime.now().strftime('%Y-%m-%d')

response = requests.get(
    'http://192.168.30.100:8080/history',
    params={'endDate': today}
)
data = response.json()

print(f"Total history until {today}: {data['count']}")
for order in data['data']:
    created = datetime.fromisoformat(order['createdAt'].replace('Z', '+00:00'))
    print(f"Order #{order['id']} - {created.strftime('%Y-%m-%d')} - Rp {order['total']:,}")
```

**Success Response (200 OK - All History):**
```json
{
  "success": true,
  "message": "Order history retrieved",
  "count": 3,
  "data": [
    {
      "id": "1732108800001",
      "items": [
        {
          "menuId": "1732108800010",
          "menuName": "Cappuccino",
          "quantity": 2,
          "price": 15000
        }
      ],
      "total": 30000,
      "status": "posted",
      "createdAt": "2025-11-21T08:00:00.000Z",
      "ipAddress": "192.168.30.120",
      "username": "John Doe"
    },
    {
      "id": "1732108800002",
      "items": [
        {
          "menuId": "1732108800011",
          "menuName": "Nasi Goreng",
          "quantity": 1,
          "price": 25000
        }
      ],
      "total": 25000,
      "status": "posted",
      "createdAt": "2025-11-21T09:30:00.000Z",
      "ipAddress": "192.168.30.121",
      "username": "Jane Smith"
    }
  ]
}
```

**Success Response (200 OK - Filtered by Date):**
```json
{
  "success": true,
  "message": "Order history retrieved with date filter",
  "count": 2,
  "filter": {
    "endDate": "2025-11-24",
    "endDateParsed": "2025-11-24T23:59:59.999Z"
  },
  "data": [
    {
      "id": "1732108800001",
      "items": [...],
      "total": 30000,
      "status": "posted",
      "createdAt": "2025-11-21T08:00:00.000Z",
      "ipAddress": "192.168.30.120",
      "username": "John Doe"
    }
  ]
}
```

**Error Response (400 Bad Request - Invalid Date):**
```json
{
  "success": false,
  "message": "Invalid endDate format. Use YYYY-MM-DD or ISO8601 format",
  "error": "FormatException: Invalid date format"
}
```

**Empty Response:**
```json
{
  "success": true,
  "message": "Order history retrieved",
  "count": 0,
  "data": []
}
```

---

### 3. Delete History

**Endpoint:**
```
DELETE http://YOUR_IP:8080/history/delete
DELETE http://YOUR_IP:8080/history/delete?endDate=2025-11-24
```

**Description:**
Delete orders from history. Can delete all history or filter by end date to delete only orders created up to a specific date.

**Query Parameters:**
- `endDate` (optional): Delete only history created up to this date (format: YYYY-MM-DD or ISO8601)
  - Example: `2025-11-24` deletes all history from first order until end of November 24, 2025
  - Without parameter: Deletes ALL history

**Example (cURL - Delete All History):**
```bash
curl -X DELETE http://192.168.30.100:8080/history/delete
```

**Example (cURL - Delete History Until Date):**
```bash
# Delete all history until end of November 24, 2025
curl -X DELETE "http://192.168.30.100:8080/history/delete?endDate=2025-11-24"

# Delete all history until end of last month
curl -X DELETE "http://192.168.30.100:8080/history/delete?endDate=2025-10-31"
```

**Example (JavaScript - Delete All):**
```javascript
fetch('http://192.168.30.100:8080/history/delete', {
  method: 'DELETE'
})
.then(response => response.json())
.then(data => {
  console.log(`Deleted ${data.deletedCount} history orders`);
})
.catch(error => console.error('Error:', error));
```

**Example (JavaScript - Delete Until Date):**
```javascript
// Delete history until today
const today = new Date().toISOString().split('T')[0];

fetch(`http://192.168.30.100:8080/history/delete?endDate=${today}`, {
  method: 'DELETE'
})
.then(response => response.json())
.then(data => {
  console.log(`Deleted ${data.deletedCount} orders until ${data.filter.endDate}`);
})
.catch(error => console.error('Error:', error));
```

**Example (Python - Delete All):**
```python
import requests

response = requests.delete('http://192.168.30.100:8080/history/delete')
data = response.json()

print(f"Deleted {data['deletedCount']} history orders")
```

**Example (Python - Delete Until Date):**
```python
import requests
from datetime import datetime, timedelta

# Delete history until last week
last_week = (datetime.now() - timedelta(days=7)).strftime('%Y-%m-%d')

response = requests.delete(
    'http://192.168.30.100:8080/history/delete',
    params={'endDate': last_week}
)
data = response.json()

print(f"Deleted {data['deletedCount']} orders until {last_week}")
```

**Success Response (200 OK - All Deleted):**
```json
{
  "success": true,
  "message": "All history deleted",
  "deletedCount": 10
}
```

**Success Response (200 OK - Filtered Delete):**
```json
{
  "success": true,
  "message": "History deleted with date filter",
  "deletedCount": 5,
  "filter": {
    "endDate": "2025-11-24",
    "endDateParsed": "2025-11-24T23:59:59.999Z"
  }
}
```

**Error Response (400 Bad Request - Invalid Date):**
```json
{
  "success": false,
  "message": "Invalid endDate format. Use YYYY-MM-DD or ISO8601 format",
  "error": "FormatException: Invalid date format"
}
```

---

## Workflow Example

### Complete Order Lifecycle

```bash
# 1. Create a new order
curl -X POST http://192.168.30.100:8080/orders/create \
  -H "Content-Type: application/json" \
  -d '{
    "items": [
      {"menuId": "123", "menuName": "Coffee", "quantity": 2, "price": 15000}
    ],
    "total": 30000,
    "username": "John Doe",
    "ipAddress": "192.168.30.120"
  }'

# Response: Order created with status "new"

# 2. Start processing the order
curl -X POST http://192.168.30.100:8080/orders/update-status \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "1732108800003",
    "status": "process"
  }'

# Response: Order status updated to "process"

# 3. Mark order as done
curl -X POST http://192.168.30.100:8080/orders/update-status \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "1732108800003",
    "status": "done"
  }'

# Response: Order status updated to "done"

# 4. Post order to history
curl -X POST http://192.168.30.100:8080/orders/post-to-history \
  -H "Content-Type: application/json" \
  -d '{
    "orderId": "1732108800003"
  }'

# Response: Order posted to history with status "posted"

# 5. View history
curl http://192.168.30.100:8080/history

# Response: Shows all posted orders
```

---

## Status Flow Diagram

```
NEW → PROCESS → DONE → POSTED (in history)
 ↓       ↓        ↓        ↓
Blue   Orange   Green   Purple
```

---

## Database Structure

### Active Orders Database (`orders`)
- Contains orders with status: `new`, `process`, `done`
- Retrieved via: `GET /orders`
- Modified via: `POST /orders/create`, `POST /orders/update-status`

### History Database (`order_history`)
- Contains orders with status: `posted`
- Retrieved via: `GET /history`
- Modified via: `POST /orders/post-to-history`

### Key Points:
- ✅ Orders are **moved** (not copied) to history
- ✅ Posted orders are **removed** from active orders
- ✅ History is a **separate database** (no mixing)
- ✅ All order data is **preserved** in history

---

## Use Cases

### 1. End-of-Day Archival

Archive all completed orders at the end of the day:

```javascript
// Get all done orders
fetch('http://192.168.30.100:8080/orders')
  .then(response => response.json())
  .then(data => {
    const doneOrders = data.data.filter(order => order.status === 'done');
    
    // Post each to history
    doneOrders.forEach(order => {
      fetch('http://192.168.30.100:8080/orders/post-to-history', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ orderId: order.id })
      });
    });
  });
```

### 2. Generate Reports

Generate revenue report from history:

```python
import requests
from datetime import datetime

response = requests.get('http://192.168.30.100:8080/history')
history = response.json()['data']

# Calculate total revenue
total_revenue = sum(order['total'] for order in history)

# Count orders by date
orders_by_date = {}
for order in history:
    date = datetime.fromisoformat(order['createdAt'].replace('Z', '+00:00')).date()
    orders_by_date[date] = orders_by_date.get(date, 0) + order['total']

print(f"Total Revenue: Rp {total_revenue:,}")
print("\nRevenue by Date:")
for date, revenue in sorted(orders_by_date.items()):
    print(f"{date}: Rp {revenue:,}")
```

### 3. Customer Order History

Get all posted orders for a specific customer:

```javascript
async function getCustomerHistory(username) {
  const response = await fetch('http://192.168.30.100:8080/history');
  const data = await response.json();
  
  const customerOrders = data.data.filter(
    order => order.username === username
  );
  
  console.log(`${username}'s order history:`, customerOrders);
  return customerOrders;
}

getCustomerHistory('John Doe');
```

### 4. Daily Revenue Report

Get history for a specific day using endDate:

```javascript
// Get all history until end of November 24, 2025
async function getDailyReport(date) {
  const response = await fetch(
    `http://192.168.30.100:8080/history?endDate=${date}`
  );
  const data = await response.json();
  
  console.log(`Orders until ${date}: ${data.count}`);
  
  // Calculate total revenue
  const totalRevenue = data.data.reduce((sum, order) => sum + order.total, 0);
  console.log(`Total Revenue: Rp ${totalRevenue.toLocaleString('id-ID')}`);
  
  return data.data;
}

// Get history until today
const today = new Date().toISOString().split('T')[0];
getDailyReport(today);
```

### 5. Monthly Report

Get all history for current month:

```python
import requests
from datetime import datetime

# Get last day of current month
today = datetime.now()
if today.month == 12:
    last_day = datetime(today.year, 12, 31)
else:
    last_day = datetime(today.year, today.month + 1, 1)
    last_day = last_day.replace(day=1) - timedelta(days=1)

end_date = last_day.strftime('%Y-%m-%d')

# Get history until end of month
response = requests.get(
    'http://192.168.30.100:8080/history',
    params={'endDate': end_date}
)
data = response.json()

print(f"Orders until {end_date}: {data['count']}")

# Calculate monthly revenue
total = sum(order['total'] for order in data['data'])
print(f"Monthly Revenue: Rp {total:,}")
```

### 6. Period Comparison

Compare revenue between periods using endDate:

```javascript
async function comparePeriods(date1, date2) {
  // Get history until first date
  const response1 = await fetch(
    `http://192.168.30.100:8080/history?endDate=${date1}`
  );
  const data1 = await response1.json();
  const revenue1 = data1.data.reduce((sum, order) => sum + order.total, 0);
  
  // Get history until second date  
  const response2 = await fetch(
    `http://192.168.30.100:8080/history?endDate=${date2}`
  );
  const data2 = await response2.json();
  const revenue2 = data2.data.reduce((sum, order) => sum + order.total, 0);
  
  console.log(`Revenue until ${date1}: Rp ${revenue1.toLocaleString('id-ID')}`);
  console.log(`Revenue until ${date2}: Rp ${revenue2.toLocaleString('id-ID')}`);
  console.log(`Difference: Rp ${(revenue2 - revenue1).toLocaleString('id-ID')}`);
}

// Compare Nov 15 vs Nov 24
comparePeriods('2025-11-15', '2025-11-24');
```

### 7. Clean Up Old History

Delete old history to free up space:

```javascript
// Delete all history older than 30 days
async function cleanOldHistory(days) {
  const cutoffDate = new Date();
  cutoffDate.setDate(cutoffDate.getDate() - days);
  const dateStr = cutoffDate.toISOString().split('T')[0];
  
  const response = await fetch(
    `http://192.168.30.100:8080/history/delete?endDate=${dateStr}`,
    { method: 'DELETE' }
  );
  const data = await response.json();
  
  console.log(`Deleted ${data.deletedCount} orders older than ${days} days`);
  return data;
}

// Clean history older than 30 days
cleanOldHistory(30);
```

### 8. Monthly Archive Cleanup

Delete previous month's history after archiving:

```python
import requests
from datetime import datetime, timedelta

# Get last day of previous month
today = datetime.now()
first_day_this_month = today.replace(day=1)
last_day_last_month = first_day_this_month - timedelta(days=1)
end_date = last_day_last_month.strftime('%Y-%m-%d')

# Get history for last month (for backup/export)
response = requests.get(
    'http://192.168.30.100:8080/history',
    params={'endDate': end_date}
)
history = response.json()['data']

# Export to file or database here...
print(f"Backed up {len(history)} orders from last month")

# Delete last month's history
delete_response = requests.delete(
    'http://192.168.30.100:8080/history/delete',
    params={'endDate': end_date}
)
result = delete_response.json()
print(f"Deleted {result['deletedCount']} orders from history")
```

### 9. Clear All History

Reset history database (use with caution):

```bash
# Delete ALL history - WARNING: This cannot be undone!
curl -X DELETE http://192.168.30.100:8080/history/delete

# Response: {"success": true, "message": "All history deleted", "deletedCount": 50}
```

---

## Best Practices

1. **Post to History Regularly**
   - Archive completed orders daily or weekly
   - Keeps active orders list manageable

2. **Backup Before Deleting**
   - Always export/backup history data before deletion
   - Use GET endpoint with endDate to retrieve data first
   - Store backups in external database or file system

3. **Use Date Filters for Cleanup**
   - Delete old history periodically (e.g., older than 90 days)
   - Keep recent history for quick reference
   - Schedule automated cleanup tasks

4. **Validate Status Before Posting**
   - Only post orders with status "done"
   - Check response for errors
   - Handle 403/404 responses appropriately

5. **Use Date Filters for Reports**
   - Use `endDate` parameter to get historical data for specific periods
   - Format dates as YYYY-MM-DD for consistency
   - End date is inclusive (includes the entire day until 23:59:59.999)

6. **Preserve Important History**
   - Don't delete all history without backup
   - Consider retention policies (e.g., keep 1 year)
   - Export data before major cleanup operations

7. **Monitor History Size**
   - Periodically check history count
   - Implement cleanup if database grows too large
   - Balance between retention and performance

---

## Error Handling

```javascript
async function postToHistory(orderId) {
  try {
    const response = await fetch(
      'http://192.168.30.100:8080/orders/post-to-history',
      {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ orderId })
      }
    );
    
    const data = await response.json();
    
    if (!response.ok) {
      if (response.status === 403) {
        console.error('Order is not done yet');
      } else if (response.status === 404) {
        console.error('Order not found');
      } else {
        console.error('Error:', data.message);
      }
      return null;
    }
    
    console.log('Successfully posted to history');
    return data;
  } catch (error) {
    console.error('Network error:', error);
    return null;
  }
}
```

---

## Response Time

Typical response times on local network:
- **POST /orders/post-to-history**: ~20-100ms
- **GET /history**: ~10-50ms

*Note: Response time may vary based on:*
- Network latency
- Database size
- Device performance
