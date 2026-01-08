# Menu Enable/Disable Feature

## Overview
Added functionality to enable or disable menu items. Only enabled menu items are returned through the API server service, while the UI shows all items with visual indicators for their status.

## Changes Made

### 1. Menu Model (`lib/models/menu.dart`)
- Added `isEnabled` field (HiveField 5) with default value `true`
- Updated `fromJson()` and `toJson()` methods to handle the new field
- Regenerated Hive adapter with `flutter pub run build_runner build --delete-conflicting-outputs`

### 2. Menu Controller (`lib/controllers/menu_controller.dart`)
- Updated `addMenu()` to accept optional `isEnabled` parameter (defaults to `true`)
- Added `getEnabledMenus()` method to retrieve only enabled menu items
- Updated `updateMenu()` to accept optional `isEnabled` parameter
- Added `toggleMenuEnabled(String id)` method to toggle menu item status

### 3. Server Service API (`lib/services/server_service.dart`)
- **GET /menu**: Now returns only enabled menu items using `getEnabledMenus()`
- **POST /menu/add**: Accepts optional `isEnabled` field in request body (defaults to `true`)
- **POST /menu/update**: Accepts optional `isEnabled` field to update menu status
- **POST /menu/toggle-enabled**: New endpoint to toggle menu enabled status
  - Request body: `{"id": "menu_id"}`
  - Response: `{"success": true, "message": "Menu enabled status toggled", "data": {"id": "...", "isEnabled": true/false}}`

### 4. Menu View UI (`lib/views/menu_view.dart`)
- Added toggle switch to each menu item in the list
- Visual indicators for disabled items:
  - Grey text color
  - Strike-through on menu name
  - "(Disabled)" label in subtitle
- Switch provides immediate feedback with snackbar notification

## API Usage

### Get Menu Items (Only Enabled)
```http
GET /menu
Response:
{
  "success": true,
  "message": "Menus retrieved",
  "data": [
    {
      "id": "...",
      "name": "Pizza",
      "price": 12.99,
      "categoryId": "...",
      "imagePath": "/images/pizza.jpg",
      "imageUrl": "http://192.168.1.100:8080/images/pizza.jpg",
      "isEnabled": true
    }
  ]
}
```

### Add Menu Item with Status
```http
POST /menu/add
Body:
{
  "name": "Burger",
  "price": 9.99,
  "categoryId": "cat123",
  "imagePath": "/images/burger.jpg",
  "isEnabled": false  // Optional, defaults to true
}
```

### Update Menu Item Status
```http
POST /menu/update
Body:
{
  "id": "menu123",
  "name": "Burger",
  "price": 9.99,
  "categoryId": "cat123",
  "imagePath": "/images/burger.jpg",
  "isEnabled": false
}
```

### Toggle Menu Enabled Status
```http
POST /menu/toggle-enabled
Body:
{
  "id": "menu123"
}
Response:
{
  "success": true,
  "message": "Menu enabled status toggled",
  "data": {
    "id": "menu123",
    "isEnabled": false
  }
}
```

## User Experience

### In the Flutter App (Admin View)
- All menu items are visible (both enabled and disabled)
- Each item has a toggle switch to enable/disable
- Disabled items appear greyed out with strike-through text
- Toggle provides instant visual feedback

### Through the API (Client/Customer View)
- Only enabled menu items are returned in GET /menu
- Disabled items are completely hidden from API consumers
- This allows restaurant staff to temporarily remove items without deleting them

## Benefits
- **Seasonal Items**: Easily disable items that are out of season
- **Temporary Unavailability**: Hide items that are temporarily unavailable without losing their data
- **Menu Testing**: Disable new items while testing before making them public
- **Inventory Management**: Quickly disable items when ingredients are out of stock
- **Data Preservation**: Keep historical menu data even when items are no longer offered
